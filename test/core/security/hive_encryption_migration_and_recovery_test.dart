import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/core/services/hive_encryption_service.dart';

class _InMemoryKeyStore implements EncryptionKeyStore {
  final Map<String, String> store = {};

  @override
  Future<String?> read(String key) async => store[key];

  @override
  Future<void> write(String key, String value) async {
    store[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    store.remove(key);
  }
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_enc_wave1_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('HiveEncryptionService — Backup, Box-by-Box Migration & Key Recovery (Wave 1 Step 8 — ADR-002)', () {
    test('1. Migrates existing plaintext boxes box-by-box to AES-256 without data loss and encrypts bytes on disk', () async {
      // Seed plaintext boxes (simulating pre-Wave-1 install)
      final plainWorkouts = await Hive.openBox<Map>('workouts');
      await plainWorkouts.put('w_1', {
        'id': 'w_1',
        'userId': 'u_alice',
        'name': 'Heavy Squat Session',
        'notes': 'PLAINTEXT_MARKER_SECRET_NOTE_999',
      });
      final plainBody = await Hive.openBox<Map>('body_entries');
      await plainBody.put('b_1', {
        'id': 'b_1',
        'userId': 'u_alice',
        'weight': 78.5,
      });
      await Hive.close();

      // Verify plaintext marker IS visible in raw .hive file before migration
      final rawBefore = File('${tempDir.path}${Platform.pathSeparator}workouts.hive')
          .readAsBytesSync();
      expect(
        utf8.decode(rawBefore, allowMalformed: true),
        contains('PLAINTEXT_MARKER_SECRET_NOTE_999'),
      );

      // Run box-by-box encrypted open + migration
      final keyStore = _InMemoryKeyStore();
      final service = HiveEncryptionService(
        keyStore: keyStore,
        backupDirectory: tempDir,
      );

      final encWorkouts = await service.openEncryptedBox<Map>('workouts');
      final encBody = await service.openEncryptedBox<Map>('body_entries');

      expect(encWorkouts.length, equals(1));
      expect(encWorkouts.get('w_1')?['name'], equals('Heavy Squat Session'));
      expect(
        encWorkouts.get('w_1')?['notes'],
        equals('PLAINTEXT_MARKER_SECRET_NOTE_999'),
      );
      expect(encBody.length, equals(1));
      expect(encBody.get('b_1')?['weight'], equals(78.5));

      await Hive.close();

      // Verify raw .hive file on disk NO LONGER contains plaintext marker
      final rawAfter = File('${tempDir.path}${Platform.pathSeparator}workouts.hive')
          .readAsBytesSync();
      expect(
        utf8.decode(rawAfter, allowMalformed: true).contains('PLAINTEXT_MARKER_SECRET_NOTE_999'),
        isFalse,
        reason: 'Migrated Hive box on disk must be AES-256 ciphertext, not plaintext.',
      );

      // Reopen with the same keyStore -> data is intact
      final serviceReopen = HiveEncryptionService(
        keyStore: keyStore,
        backupDirectory: tempDir,
      );
      final reopened = await serviceReopen.openEncryptedBox<Map>('workouts');
      expect(reopened.get('w_1')?['name'], equals('Heavy Squat Session'));
    });

    test('2. Recovers 100% of records from pre-migration backup snapshot if a migration was interrupted mid-flight', () async {
      final keyStore = _InMemoryKeyStore();
      // Simulate an interrupted migration where workouts.pre_enc_backup.json was written before process termination
      final backupFile = File(
        '${tempDir.path}${Platform.pathSeparator}workouts.pre_enc_backup.json',
      );
      await backupFile.writeAsString(
        jsonEncode({
          'w_recovered': {
            'id': 'w_recovered',
            'userId': 'u_bob',
            'name': 'Recovered Pull Workout',
          },
        }),
      );

      final service = HiveEncryptionService(
        keyStore: keyStore,
        backupDirectory: tempDir,
      );

      final recoveredBox = await service.openEncryptedBox<Map>('workouts');
      expect(recoveredBox.length, equals(1));
      expect(
        recoveredBox.get('w_recovered')?['name'],
        equals('Recovered Pull Workout'),
      );
      // Backup snapshot file is cleaned up after successful recovery
      expect(await backupFile.exists(), isFalse);
    });

    test('3. Key-loss / corrupted key recovery: resets unreadable box cleanly without crash-looping when OS keystore is wiped', () async {
      final keyStore1 = _InMemoryKeyStore();
      final service1 = HiveEncryptionService(
        keyStore: keyStore1,
        backupDirectory: tempDir,
      );

      final box1 = await service1.openEncryptedBox<Map>('workouts');
      await box1.put('w_1', {'id': 'w_1', 'name': 'Encrypted with Key 1'});
      await Hive.close();

      // Simulate OS Keychain / Keystore wipe: a new key is generated while
      // the box is marked as migrated
      final keyStore2 = _InMemoryKeyStore();
      await keyStore2.write(
        HiveEncryptionService.migratedBoxesStorageKey,
        jsonEncode(['workouts']),
      );
      final service2 = HiveEncryptionService(
        keyStore: keyStore2,
        backupDirectory: tempDir,
      );

      // Must recover cleanly into an open encrypted box without throwing
      final recoveredBox = await service2.openEncryptedBox<Map>('workouts');
      expect(recoveredBox.isOpen, isTrue);
      await recoveredBox.put('w_fresh', {'id': 'w_fresh', 'name': 'Post-recovery workout'});
      expect(recoveredBox.get('w_fresh')?['name'], equals('Post-recovery workout'));
    });
  });
}

