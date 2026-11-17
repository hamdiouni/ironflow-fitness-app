import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import '../platform/platform_file_ops.dart';
import '../utils/app_logger.dart';

/// Abstraction over secure key storage so unit tests can simulate key
/// persistence, key loss, and interrupted migrations deterministically.
abstract class EncryptionKeyStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Production [EncryptionKeyStore] backed by [FlutterSecureStorage].
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

/// Metadata recorded whenever a corrupt or key-lost box is quarantined rather
/// than deleted destructively.
class QuarantinedBoxRecord {
  final String boxName;
  final String originalFilePath;
  final String quarantineFilePath;
  final String reason;
  final DateTime quarantinedAt;

  const QuarantinedBoxRecord({
    required this.boxName,
    required this.originalFilePath,
    required this.quarantineFilePath,
    required this.reason,
    required this.quarantinedAt,
  });
}

/// Manages AES-256 encryption at rest (`HiveAesCipher`) for sensitive local
/// Hive boxes, including:
/// - Cached cipher and migrated-box set in memory (Wave 3.2)
/// - Pre-migration `.hive` + JSON backups and `.hive` header sanity check (Wave 3.1)
/// - Non-destructive quarantine on corrupt header or key-loss recovery (Wave 3.1)
class HiveEncryptionService {
  static const String masterKeyStorageKey = 'ironflow_hive_aes_key_v1';
  static const String migratedBoxesStorageKey =
      'ironflow_hive_encrypted_boxes_v1';
  static const int _minValidNonEmptyHiveBytes = 8;

  /// Sensitive user & health boxes encrypted at rest.
  static const Set<String> sensitiveBoxes = {
    'workouts',
    'nutrition',
    'programs',
    'user',
    'settings',
    'notification_settings',
    'food_items_full',
    'custom_foods',
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
  final String? _backupDirectoryPath;
  final String? _sourceDirectoryPath;
  final void Function(QuarantinedBoxRecord record)? onBoxQuarantined;

  Uint8List? _cachedKey;
  HiveAesCipher? _cachedCipher;
  Set<String>? _cachedMigratedBoxes;
  Future<Uint8List>? _inFlightKeyLoad;
  Future<Set<String>>? _inFlightMigratedLoad;
  final List<QuarantinedBoxRecord> _quarantinedBoxes = <QuarantinedBoxRecord>[];

  HiveEncryptionService({
    EncryptionKeyStore? keyStore,
    Object? backupDirectory,
    String? backupDirectoryPath,
    String? sourceDirectoryPath,
    this.onBoxQuarantined,
  })  : _keyStore = keyStore ?? const SecureStorageKeyStore(),
        _backupDirectoryPath =
            backupDirectoryPath ?? _extractDirectoryPath(backupDirectory),
        _sourceDirectoryPath = sourceDirectoryPath;

  static String? _extractDirectoryPath(Object? directory) {
    if (directory == null) return null;
    if (directory is String) return directory;
    try {
      return (directory as dynamic).path as String?;
    } catch (_) {
      return null;
    }
  }

  /// Quarantined boxes observed during this service lifecycle, enabling a UI
  /// recovery notice or diagnostic export without silent data deletion.
  List<QuarantinedBoxRecord> get quarantinedBoxes =>
      List.unmodifiable(_quarantinedBoxes);

  /// Loads or generates the cached 256-bit (32-byte) AES key.
  /// Never logs or prints key bytes.
  Future<Uint8List> getOrCreateMasterKey() {
    if (_cachedKey != null) return Future<Uint8List>.value(_cachedKey!);
    return _inFlightKeyLoad ??= _loadOrCreateMasterKey().whenComplete(() {
      _inFlightKeyLoad = null;
    });
  }

  Future<Uint8List> _loadOrCreateMasterKey() async {
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

  /// Returns the cached [HiveAesCipher] backed by [getOrCreateMasterKey].
  Future<HiveAesCipher> getOrCreateCipher() async {
    if (_cachedCipher != null) return _cachedCipher!;
    final key = await getOrCreateMasterKey();
    _cachedCipher = HiveAesCipher(key);
    return _cachedCipher!;
  }

  /// Pre-warms cipher and migrated-box cache before concurrent box opens.
  Future<void> warmCache() async {
    await getOrCreateCipher();
    await _getMigratedBoxes();
  }

  Future<Set<String>> _getMigratedBoxes() {
    if (_cachedMigratedBoxes != null) {
      return Future<Set<String>>.value(
        Set<String>.from(_cachedMigratedBoxes!),
      );
    }
    return _inFlightMigratedLoad ??= _loadMigratedBoxes().whenComplete(() {
      _inFlightMigratedLoad = null;
    });
  }

  Future<Set<String>> _loadMigratedBoxes() async {
    if (_cachedMigratedBoxes != null) {
      return Set<String>.from(_cachedMigratedBoxes!);
    }
    final raw = await _keyStore.read(migratedBoxesStorageKey);
    if (raw == null || raw.isEmpty) {
      _cachedMigratedBoxes = <String>{};
      return <String>{};
    }
    try {
      final list = (jsonDecode(raw) as List).cast<String>();
      _cachedMigratedBoxes = list.toSet();
      return Set<String>.from(_cachedMigratedBoxes!);
    } catch (_) {
      _cachedMigratedBoxes = <String>{};
      return <String>{};
    }
  }

  Future<void> _markBoxMigrated(String boxName) async {
    final set = await _getMigratedBoxes();
    if (set.add(boxName)) {
      _cachedMigratedBoxes = Set<String>.from(set);
      await _keyStore.write(migratedBoxesStorageKey, jsonEncode(set.toList()));
    }
  }

  Future<String?> _resolveBackupRoot() async {
    if (_backupDirectoryPath != null && _backupDirectoryPath.isNotEmpty) {
      return _backupDirectoryPath;
    }
    if (!PlatformFileOps.supportsLocalFileSystem) return null;
    return PlatformFileOps.resolveAppDocumentsPath();
  }

  Future<String?> _resolveSourceRoot() async {
    if (_sourceDirectoryPath != null && _sourceDirectoryPath.isNotEmpty) {
      return _sourceDirectoryPath;
    }
    if (_backupDirectoryPath != null && _backupDirectoryPath.isNotEmpty) {
      return _backupDirectoryPath;
    }
    if (!PlatformFileOps.supportsLocalFileSystem) return null;
    return PlatformFileOps.resolveAppDocumentsPath();
  }

  Future<String?> _legacyJsonBackupPath(String boxName) async {
    final root = await _resolveBackupRoot();
    if (root == null) return null;
    return PlatformFileOps.joinPath(root, '$boxName.pre_enc_backup.json');
  }

  Future<String?> _preMigrationDirPath(String boxName) async {
    final root = await _resolveBackupRoot();
    if (root == null) return null;
    return PlatformFileOps.joinPath(
      PlatformFileOps.joinPath(root, 'pre_migration'),
      boxName,
    );
  }

  Future<void> _writePreMigrationBackup(
    String boxName,
    Map<dynamic, dynamic> entries,
  ) async {
    final root = await _resolveBackupRoot();
    if (root == null || kIsWeb) return;

    final serializable = <String, dynamic>{};
    entries.forEach((k, v) {
      serializable[k.toString()] = v;
    });

    await PlatformFileOps.writeUtf8File(
      root,
      '$boxName.pre_enc_backup.json',
      jsonEncode(serializable),
    );

    final srcRoot = await _resolveSourceRoot();
    final preDir = await _preMigrationDirPath(boxName);
    if (srcRoot != null && preDir != null) {
      final srcHive = PlatformFileOps.joinPath(srcRoot, '$boxName.hive');
      if (await PlatformFileOps.fileExists(srcHive)) {
        final dstHive = PlatformFileOps.joinPath(preDir, '$boxName.hive');
        await PlatformFileOps.copyFile(srcHive, dstHive);
      }
    }
  }

  Future<Map<String, dynamic>?> _readPreMigrationBackup(String boxName) async {
    final path = await _legacyJsonBackupPath(boxName);
    if (path == null || !await PlatformFileOps.fileExists(path)) return null;
    try {
      final content = await PlatformFileOps.readUtf8File(path);
      if (content == null || content.isEmpty) return null;
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _deletePreMigrationBackup(String boxName) async {
    final path = await _legacyJsonBackupPath(boxName);
    if (path != null) {
      try {
        await PlatformFileOps.deleteFileIfExists(path);
      } catch (_) {}
    }
  }

  /// Verifies `.hive` file integrity before attempting open/migration.
  /// Non-empty `.hive` files shorter than 8 bytes contain a truncated header
  /// and cannot hold valid Hive frames.
  Future<bool> _hasCorruptHiveHeader(String boxName) async {
    if (!PlatformFileOps.supportsLocalFileSystem) return false;
    final srcRoot = await _resolveSourceRoot();
    if (srcRoot == null) return false;
    final hivePath = PlatformFileOps.joinPath(srcRoot, '$boxName.hive');
    final length = await PlatformFileOps.fileLength(hivePath);
    if (length == null || length == 0) return false;
    if (length < _minValidNonEmptyHiveBytes) {
      return true;
    }
    final prefix =
        await PlatformFileOps.readBytesPrefix(hivePath, _minValidNonEmptyHiveBytes);
    return prefix == null || prefix.length < _minValidNonEmptyHiveBytes;
  }

  /// Copies [boxName].hive (and optional `.lock`) into a timestamped
  /// `quarantine/` folder before removing the broken source file so unreadable
  /// data is never permanently lost on failure.
  Future<QuarantinedBoxRecord?> _quarantineBoxFiles(
    String boxName, {
    required String reason,
  }) async {
    if (!PlatformFileOps.supportsLocalFileSystem) {
      return null;
    }

    final srcRoot = await _resolveSourceRoot();
    final backupRoot = await _resolveBackupRoot();
    if (srcRoot == null || backupRoot == null) {
      throw StateError(
        'Cannot safely quarantine "$boxName" without a resolved storage directory ($reason)',
      );
    }

    final srcHive = PlatformFileOps.joinPath(srcRoot, '$boxName.hive');
    final exists = await PlatformFileOps.fileExists(srcHive);
    if (!exists) {
      return null;
    }

    final stamp = DateTime.now().toUtc().millisecondsSinceEpoch;
    final quarantineDir = PlatformFileOps.joinPath(
      PlatformFileOps.joinPath(backupRoot, 'quarantine'),
      '${stamp}_$boxName',
    );
    final dstHive = PlatformFileOps.joinPath(quarantineDir, '$boxName.hive');
    final copied = await PlatformFileOps.copyFile(srcHive, dstHive);
    if (!copied) {
      throw StateError(
        'Failed to create verified quarantine copy of "$boxName" at $dstHive',
      );
    }

    final srcLock = PlatformFileOps.joinPath(srcRoot, '$boxName.lock');
    if (await PlatformFileOps.fileExists(srcLock)) {
      await PlatformFileOps.copyFile(
        srcLock,
        PlatformFileOps.joinPath(quarantineDir, '$boxName.lock'),
      );
    }

    final record = QuarantinedBoxRecord(
      boxName: boxName,
      originalFilePath: srcHive,
      quarantineFilePath: dstHive,
      reason: reason,
      quarantinedAt: DateTime.now().toUtc(),
    );
    _quarantinedBoxes.add(record);
    onBoxQuarantined?.call(record);

    if (kDebugMode) {
      AppLogger.debug(
        '⚠️ [HiveEncryption] Quarantined "$boxName" -> $dstHive (reason: $reason)',
      );
    }

    // Only remove the broken active file after quarantine verification succeeds.
    await PlatformFileOps.deleteFileIfExists(srcHive);
    await PlatformFileOps.deleteFileIfExists(srcLock);
    return record;
  }

  /// Opens a Hive box while containing Hive 2.2.3's duplicate unlistened
  /// `_openingBoxes` completer error inside an error zone so callers can catch
  /// [HiveError] reliably with `crashRecovery: false`.
  Future<Box<E>> _openBoxGuarded<E>(
    String boxName, {
    HiveCipher? encryptionCipher,
    bool crashRecovery = false,
  }) {
    final completer = Completer<Box<E>>();
    runZonedGuarded(
      () {
        Hive.openBox<E>(
          boxName,
          encryptionCipher: encryptionCipher,
          crashRecovery: crashRecovery,
        ).then(
          (box) {
            if (!completer.isCompleted) completer.complete(box);
          },
          onError: (Object error, StackTrace stackTrace) {
            if (!completer.isCompleted) {
              completer.completeError(error, stackTrace);
            }
          },
        );
      },
      (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
    );
    return completer.future;
  }

  /// Opens [boxName] with `HiveAesCipher`, migrating existing plaintext data
  /// box-by-box after creating pre-migration backups, verifying file headers,
  /// and quarantining any unreadable/corrupted box instead of deleting it.
  Future<Box<E>> openEncryptedBox<E>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<E>(boxName);
    }

    final cipher = await getOrCreateCipher();
    final migratedBoxes = await _getMigratedBoxes();

    // Case 0: Recover interrupted pre-migration backup snapshot if present
    final pendingBackup = await _readPreMigrationBackup(boxName);
    if (pendingBackup != null) {
      if (kDebugMode) {
        AppLogger.debug(
          '🔄 [HiveEncryption] Recovering box "$boxName" from pre-migration backup snapshot...',
        );
      }
      await _quarantineBoxFiles(
        boxName,
        reason: 'interrupted_migration_recovery',
      );
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

    // Header check before opening any existing `.hive` file on disk
    if (await _hasCorruptHiveHeader(boxName)) {
      await _quarantineBoxFiles(boxName, reason: 'corrupt_header_truncated');
    }

    // Case 1: Box is not yet marked migrated — check for plaintext data on disk
    if (!migratedBoxes.contains(boxName)) {
      final existsOnDisk = await Hive.boxExists(boxName);
      if (existsOnDisk) {
        Box<E>? plaintextBox;
        try {
          plaintextBox = await _openBoxGuarded<E>(
            boxName,
            crashRecovery: false,
          );
        } catch (_) {
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

          await _writePreMigrationBackup(boxName, entries);
          await plaintextBox.close();

          // Safely replace original plaintext box after verified pre-migration backup
          if (PlatformFileOps.supportsLocalFileSystem) {
            final srcRoot = await _resolveSourceRoot();
            if (srcRoot != null) {
              await PlatformFileOps.deleteFileIfExists(
                PlatformFileOps.joinPath(srcRoot, '$boxName.hive'),
              );
              await PlatformFileOps.deleteFileIfExists(
                PlatformFileOps.joinPath(srcRoot, '$boxName.lock'),
              );
            }
          } else {
            await Hive.deleteBoxFromDisk(boxName);
          }

          final encryptedBox = await Hive.openBox<E>(
            boxName,
            encryptionCipher: cipher,
          );
          if (entries.isNotEmpty) {
            await encryptedBox.putAll(entries);
            await encryptedBox.flush();
          }

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

    // Case 2: Open directly with cached AES-256 cipher. `crashRecovery: false`
    // prevents Hive from silently truncating corrupted/key-lost frames before
    // our quarantine handler can preserve the original file.
    try {
      final box = await _openBoxGuarded<E>(
        boxName,
        encryptionCipher: cipher,
        crashRecovery: false,
      );
      if (!migratedBoxes.contains(boxName)) {
        await _markBoxMigrated(boxName);
      }
      return box;
    } catch (e) {
      // Case 3: Key-loss / corrupted ciphertext — quarantine BEFORE resetting
      await _quarantineBoxFiles(
        boxName,
        reason: 'cipher_open_failed: $e',
      );
      if (!PlatformFileOps.supportsLocalFileSystem) {
        // Browser IndexedDB has no filesystem copy path; only clear on Web
        // if unreadable so the browser tab can recover.
        await Hive.deleteBoxFromDisk(boxName);
      }
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
      return Map<dynamic, dynamic>.from(raw) as E;
    }
    return raw as E;
  }
}
