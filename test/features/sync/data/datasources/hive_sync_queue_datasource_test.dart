import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/sync/data/datasources/hive_sync_queue_datasource.dart';

void main() {
  late Directory tempDir;
  late Box<String> settingsBox;
  late HiveSyncQueueDataSourceImpl dataSource;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('sync_queue_cursor_');
    Hive.init(tempDir.path);
    settingsBox = await Hive.openBox<String>('app_settings');
  });

  setUp(() async {
    await settingsBox.clear();
    dataSource = HiveSyncQueueDataSourceImpl();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('pull cursors are stored separately for each user', () async {
    final aliceTime = DateTime(2026, 1, 2, 12);
    final bobTime = DateTime(2026, 1, 3, 12);

    await dataSource.setCursor('workouts', aliceTime, userId: 'Alice');
    expect(await dataSource.getCursor('workouts', userId: 'bob'), isNull);

    await dataSource.setCursor('workouts', bobTime, userId: 'bob');

    expect(
      await dataSource.getCursor('workouts', userId: 'Alice'),
      aliceTime,
    );
    expect(await dataSource.getCursor('workouts', userId: 'bob'), bobTime);
    expect(settingsBox.containsKey('sync_cursor_workouts_alice'), isTrue);
    expect(settingsBox.containsKey('sync_cursor_workouts_bob'), isTrue);
  });

  test('legacy device-global cursor is not adopted for any user', () async {
    await settingsBox.put(
      'sync_cursor_workouts',
      DateTime(2026, 1, 4, 12).toIso8601String(),
    );

    expect(await dataSource.getCursor('workouts', userId: 'Alice'), isNull);
    expect(await dataSource.getCursor('workouts', userId: 'bob'), isNull);
  });

  test('initial-push markers remain separate for each user', () async {
    await dataSource.markInitialPushComplete('Alice');

    expect(await dataSource.hasCompletedInitialPush('Alice'), isTrue);
    expect(await dataSource.hasCompletedInitialPush('bob'), isFalse);
  });
}
