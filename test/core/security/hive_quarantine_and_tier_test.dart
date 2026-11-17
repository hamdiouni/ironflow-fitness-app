import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/core/services/hive_encryption_service.dart';
import 'package:progression_tracker/core/utils/hive_manager.dart';

class _CountingKeyStore implements EncryptionKeyStore {
  final Map<String, String> store = {};
  int readCount = 0;

  @override
  Future<String?> read(String key) async {
    readCount++;
    return store[key];
  }

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
    tempDir = Directory.systemTemp.createTempSync('wave3_storage_safety_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    HiveManager.resetForTest();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('Wave 3.1 & 3.2 — Storage Quarantine, Caching, Tier-1/2 & Sensitive Boxes', () {
    test('sensitiveBoxes includes settings, notification_settings, food_items_full, and custom_foods', () {
      expect(
        HiveEncryptionService.sensitiveBoxes,
        containsAll(<String>[
          'settings',
          'notification_settings',
          'food_items_full',
          'custom_foods',
        ]),
      );
    });

    test('migrates plaintext settings, notification_settings, and food_items_full with pre-migration backup', () async {
      final settings = await Hive.openBox<Map>('settings');
      await settings.put('prefs', {'unit': 'kg'});
      final notif = await Hive.openBox<Map>('notification_settings');
      await notif.put('settings_u1', {'enabled': true});
      final foodFull = await Hive.openBox<Map>('food_items_full');
      await foodFull.put('f1', {'id': 'f1', 'name': 'Oats_MARKER_PLAIN'});
      await Hive.close();

      final keyStore = _CountingKeyStore();
      final service = HiveEncryptionService(
        keyStore: keyStore,
        backupDirectoryPath: tempDir.path,
        sourceDirectoryPath: tempDir.path,
      );

      final encSettings = await service.openEncryptedBox<Map>('settings');
      final encNotif = await service.openEncryptedBox<Map>('notification_settings');
      final encFoodFull = await service.openEncryptedBox<Map>('food_items_full');

      expect(encSettings.get('prefs')?['unit'], 'kg');
      expect(encNotif.get('settings_u1')?['enabled'], isTrue);
      expect(encFoodFull.get('f1')?['name'], 'Oats_MARKER_PLAIN');
      await Hive.close();

      // Plaintext string must no longer appear unencrypted on disk
      final rawFoodFull = File('${tempDir.path}${Platform.pathSeparator}food_items_full.hive')
          .readAsBytesSync();
      expect(utf8.decode(rawFoodFull, allowMalformed: true), isNot(contains('Oats_MARKER_PLAIN')));
    });

    test('quarantines corrupt or key-lost .hive files instead of deleting without trace', () async {
      final keyStore1 = _CountingKeyStore();
      final svc1 = HiveEncryptionService(
        keyStore: keyStore1,
        backupDirectoryPath: tempDir.path,
        sourceDirectoryPath: tempDir.path,
      );
      final b1 = await svc1.openEncryptedBox<Map>('workouts');
      await b1.put('w1', {'id': 'w1', 'name': 'Important Lift'});
      await Hive.close();

      final originalBytes =
          Uint8List.fromList(File('${tempDir.path}${Platform.pathSeparator}workouts.hive').readAsBytesSync());

      // Simulate keystore wipe (key lost while migrated marker remains)
      final keyStore2 = _CountingKeyStore();
      await keyStore2.write(
        HiveEncryptionService.migratedBoxesStorageKey,
        jsonEncode(['workouts']),
      );
      final svc2 = HiveEncryptionService(
        keyStore: keyStore2,
        backupDirectoryPath: tempDir.path,
        sourceDirectoryPath: tempDir.path,
      );

      final recovered = await svc2.openEncryptedBox<Map>('workouts');
      expect(recovered.isOpen, isTrue);
      expect(svc2.quarantinedBoxes, hasLength(1));

      final qRecord = svc2.quarantinedBoxes.single;
      expect(qRecord.boxName, 'workouts');
      final qFile = File(qRecord.quarantineFilePath);
      expect(await qFile.exists(), isTrue);
      expect(await qFile.readAsBytes(), equals(originalBytes));

      // Also test truncated / corrupt header detection before open
      await Hive.close();
      final corruptFile = File('${tempDir.path}${Platform.pathSeparator}body_entries.hive');
      await corruptFile.writeAsBytes(const [1, 2, 3]); // < 8-byte header
      await keyStore2.write(
        HiveEncryptionService.migratedBoxesStorageKey,
        jsonEncode(['workouts', 'body_entries']),
      );
      final svc3 = HiveEncryptionService(
        keyStore: keyStore2,
        backupDirectoryPath: tempDir.path,
        sourceDirectoryPath: tempDir.path,
      );
      final recoveredCorrupt = await svc3.openEncryptedBox<Map>('body_entries');
      expect(recoveredCorrupt.isOpen, isTrue);
      expect(svc3.quarantinedBoxes.any((r) => r.boxName == 'body_entries'), isTrue);
      final corruptQuarantine =
          svc3.quarantinedBoxes.firstWhere((r) => r.boxName == 'body_entries');
      expect(
        await File(corruptQuarantine.quarantineFilePath).readAsBytes(),
        equals(const [1, 2, 3]),
      );
    });

    test('caches master cipher and migrated-box set across multiple encrypted opens', () async {
      final keyStore = _CountingKeyStore();
      final svc = HiveEncryptionService(
        keyStore: keyStore,
        backupDirectoryPath: tempDir.path,
        sourceDirectoryPath: tempDir.path,
      );

      await svc.openEncryptedBox<Map>('workouts');
      await svc.openEncryptedBox<Map>('meals');
      await svc.openEncryptedBox<Map>('body_entries');

      // Initial reads: 1x master key + 1x migrated set = 2 reads total, NOT 6+
      expect(keyStore.readCount, lessThanOrEqualTo(2));
    });

    test('HiveManager opens only Tier-1 concurrently at initialize, guards Tier-2 until ensureOpen, and clearAll protects catalogs', () async {
      final keyStore = _CountingKeyStore();
      HiveManager.encryptionService = HiveEncryptionService(
        keyStore: keyStore,
        backupDirectoryPath: tempDir.path,
        sourceDirectoryPath: tempDir.path,
      );

      await HiveManager.initializeForDirectory(tempDir.path);

      // Tier-1 opened cleanly
      expect(Hive.isBoxOpen('auth_session'), isTrue);
      expect(Hive.isBoxOpen('user_profile'), isTrue);
      expect(Hive.isBoxOpen('app_settings'), isTrue);
      expect(Hive.isBoxOpen('active_workout_state'), isTrue);

      // Tier-2 remains closed lazily until ensureOpen
      expect(Hive.isBoxOpen('workouts'), isFalse);
      expect(Hive.isBoxOpen('custom_foods'), isFalse);
      expect(() => HiveManager.getWorkoutBox(), throwsStateError);

      final workoutsBox = await HiveManager.ensureOpen<Map>('workouts');
      expect(workoutsBox.isOpen, isTrue);
      await workoutsBox.put('w1', {'id': 'w1'});

      final foodsBox = await HiveManager.ensureOpen<dynamic>('foods');
      await foodsBox.put('foods_cache', [{'id': 'oats'}]);
      final exercisesBox = await HiveManager.ensureOpen<Map>('exercises');
      await exercisesBox.put('bench', {'id': 'bench'});
      final customFoodsBox = await HiveManager.ensureOpen<dynamic>('custom_foods');
      await customFoodsBox.put('custom_foods_u1', [{'id': 'cf1'}]);

      await HiveManager.clearAll();

      expect(workoutsBox.isEmpty, isTrue);
      expect(customFoodsBox.isEmpty, isTrue);
      // Catalogs are protected and NEVER cleared by clearAll()
      expect(foodsBox.containsKey('foods_cache'), isTrue);
      expect(exercisesBox.containsKey('bench'), isTrue);
    });
  });
}
