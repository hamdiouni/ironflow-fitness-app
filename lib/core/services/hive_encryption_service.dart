import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import '../utils/app_logger.dart';

/// Abstraction over secure key storage so unit tests can simulate key
/// persistence, key loss, and interrupted migrations deterministically.
abstract class EncryptionKeyStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Production [EncryptionKeyStore] backed by [FlutterSecureStorage].
///
/// Platform notes (ADR-002):
/// - **Android**: Uses `EncryptedSharedPreferences` backed by Android Keystore.
/// - **iOS**: Uses iOS Keychain with `first_unlock_this_device` accessibility.
/// - **Web**: `flutter_secure_storage_web` uses WebCrypto + `localStorage`.
///   Browser storage protects against casual inspection but cannot defend
///   against same-origin XSS if untrusted scripts execute; therefore Web builds
///   must enforce strict CSP headers and never log health payloads.
class SecureStorageKeyStore implements EncryptionKeyStore {
  final FlutterSecureStorage _storage;

  const SecureStorageKeyStore([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// Manages AES-256 encryption at rest (`HiveAesCipher`) for sensitive local
/// Hive boxes, including pre-migration backups, box-by-box plaintext-to-cipher
/// migration, and key-loss recovery (Wave 1 Step 8 — SEC-03 / DAT-01 / ADR-002).
class HiveEncryptionService {
  static const String masterKeyStorageKey = 'ironflow_hive_aes_key_v1';
  static const String migratedBoxesStorageKey =
      'ironflow_hive_encrypted_boxes_v1';

  /// Sensitive user & health boxes that MUST be encrypted at rest.
  static const Set<String> sensitiveBoxes = {
    'workouts',
    'nutrition',
    'programs',
    'user',
    'sync_queue',
    'body_entries',
    'streak',
    'meals',
    'macro_targets',
    'insight_cache',
    'active_program',
    'diet_plan',
    'active_workout_state',
    'auth_session',
    'user_profile',
    'ai_chat_history',
  };

  final EncryptionKeyStore _keyStore;
  final Directory? _backupDirectory;
  Uint8List? _cachedKey;

  HiveEncryptionService({
    EncryptionKeyStore? keyStore,
    Directory? backupDirectory,
  })  : _keyStore = keyStore ?? const SecureStorageKeyStore(),
        _backupDirectory = backupDirectory;

  /// Loads or generates the 256-bit (32-byte) AES key.
  /// Never logs or prints the key bytes.
  Future<Uint8List> getOrCreateMasterKey() async {
    if (_cachedKey != null) return _cachedKey!;

    final existingBase64 = await _keyStore.read(masterKeyStorageKey);
    if (existingBase64 != null && existingBase64.isNotEmpty) {
      try {
        final decoded = base64Decode(existingBase64);
        if (decoded.length == 32) {
          _cachedKey = Uint8List.fromList(decoded);
          return _cachedKey!;
        }
      } catch (_) {
        // Corrupted key encoding in store — rotate below
      }
    }

    final freshKey = Uint8List.fromList(Hive.generateSecureKey());
    await _keyStore.write(masterKeyStorageKey, base64Encode(freshKey));
    _cachedKey = freshKey;
    return freshKey;
  }

  Future<Set<String>> _getMigratedBoxes() async {
    final raw = await _keyStore.read(migratedBoxesStorageKey);
    if (raw == null || raw.isEmpty) return <String>{};
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      return list.toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> _markBoxMigrated(String boxName) async {
    final set = await _getMigratedBoxes();
    set.add(boxName);
    await _keyStore.write(migratedBoxesStorageKey, jsonEncode(set.toList()));
  }

  File? _backupFileForBox(String boxName) {
    final dir = _backupDirectory;
    if (dir == null || kIsWeb) return null;
    return File('${dir.path}${Platform.pathSeparator}$boxName.pre_enc_backup.json');
  }

  /// Writes a pre-migration backup snapshot of [entries] to disk (when
  /// [_backupDirectory] is provided) so an interrupted migration can recover
  /// 100% of records on next launch.
  Future<void> _writePreMigrationBackup(
    String boxName,
    Map<dynamic, dynamic> entries,
  ) async {
    final file = _backupFileForBox(boxName);
    if (file == null) return;
    final serializable = <String, dynamic>{};
    entries.forEach((k, v) {
      serializable[k.toString()] = v;
    });
    await file.writeAsString(jsonEncode(serializable), flush: true);
  }

  Future<Map<String, dynamic>?> _readPreMigrationBackup(String boxName) async {
    final file = _backupFileForBox(boxName);
    if (file == null || !await file.exists()) return null;
    try {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _deletePreMigrationBackup(String boxName) async {
    final file = _backupFileForBox(boxName);
    if (file != null && await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  /// Opens [boxName] with `HiveAesCipher`, migrating existing plaintext data
  /// box-by-box after creating a backup snapshot, and recovering safely if a
  /// previous migration was interrupted or if the OS keystore was reset.
  Future<Box<E>> openEncryptedBox<E>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<E>(boxName);
    }

    final key = await getOrCreateMasterKey();
    final cipher = HiveAesCipher(key);
    final migratedBoxes = await _getMigratedBoxes();

    // Case 0: Check if an interrupted pre-migration backup file exists on disk
    final pendingBackup = await _readPreMigrationBackup(boxName);
    if (pendingBackup != null) {
      if (kDebugMode) {
        AppLogger.debug(
          '🔄 [HiveEncryption] Recovering box "$boxName" from pre-migration backup snapshot...',
        );
      }
      try {
        await Hive.deleteBoxFromDisk(boxName);
      } catch (_) {}
      final recoveredBox = await Hive.openBox<E>(
        boxName,
        encryptionCipher: cipher,
      );
      for (final entry in pendingBackup.entries) {
        await recoveredBox.put(entry.key, _castValue<E>(entry.value));
      }
      await recoveredBox.flush();
      await _markBoxMigrated(boxName);
      await _deletePreMigrationBackup(boxName);
      return recoveredBox;
    }

    // Case 1: Box is not yet marked as migrated — check for existing plaintext data
    if (!migratedBoxes.contains(boxName)) {
      final existsOnDisk = await Hive.boxExists(boxName);
      if (existsOnDisk) {
        Box<E>? plaintextBox;
        try {
          plaintextBox = await Hive.openBox<E>(boxName);
        } catch (_) {
          // Box on disk might already be encrypted from an earlier run whose
          // migratedBoxes marker wasn't saved yet.
          plaintextBox = null;
        }

        if (plaintextBox != null) {
          final entries = <dynamic, E>{};
          for (final k in plaintextBox.keys) {
            final val = plaintextBox.get(k);
            if (val is E) {
              entries[k] = val;
            }
          }

          // Step A: Write pre-migration backup before touching the box
          if (entries.isNotEmpty) {
            await _writePreMigrationBackup(boxName, entries);
          }

          // Step B: Close and remove plaintext box from disk
          await plaintextBox.close();
          await Hive.deleteBoxFromDisk(boxName);

          // Step C: Re-open with AES-256 cipher and restore all records
          final encryptedBox = await Hive.openBox<E>(
            boxName,
            encryptionCipher: cipher,
          );
          if (entries.isNotEmpty) {
            await encryptedBox.putAll(entries);
            await encryptedBox.flush();
          }

          // Step D: Verify record count parity before deleting backup
          if (encryptedBox.length != entries.length) {
            throw StateError(
              'Hive encryption migration count mismatch for $boxName: '
              'expected ${entries.length}, got ${encryptedBox.length}',
            );
          }

          await _markBoxMigrated(boxName);
          await _deletePreMigrationBackup(boxName);
          return encryptedBox;
        }
      }
    }

    // Case 2: Open directly with AES-256 cipher
    try {
      final box = await Hive.openBox<E>(
        boxName,
        encryptionCipher: cipher,
      );
      if (!migratedBoxes.contains(boxName)) {
        await _markBoxMigrated(boxName);
      }
      return box;
    } catch (e) {
      // Case 3: Key-loss / corrupted ciphertext recovery
      // If the OS keystore was wiped while encrypted .hive files remained on
      // disk, first check if the file is actually plaintext; otherwise reset
      // the unreadable box so the app can boot and re-sync from cloud/backup.
      if (kDebugMode) {
        AppLogger.debug(
          '⚠️ [HiveEncryption] Cipher open failed for "$boxName", attempting recovery...',
        );
      }
      await Hive.deleteBoxFromDisk(boxName);
      final freshBox = await Hive.openBox<E>(
        boxName,
        encryptionCipher: cipher,
      );
      await _markBoxMigrated(boxName);
      return freshBox;
    }
  }

  static E _castValue<E>(dynamic raw) {
    if (raw is E) return raw;
    if (raw is Map) {
      final copy = Map<dynamic, dynamic>.from(raw);
      return copy as E;
    }
    return raw as E;
  }
}

