import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/retention/data/datasources/hive_notification_settings_data_source.dart';
import 'package:progression_tracker/features/retention/domain/entities/notification_settings.dart';

void main() {
  late Directory tempDir;
  late Box<Map> settingsBox;

  NotificationSettings settings(int hour) {
    return NotificationSettings.defaults().copyWith(
      reminderHour: hour,
      reminderMinute: 30,
    );
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('retention_settings_');
    Hive.init(tempDir.path);
    settingsBox = await Hive.openBox<Map>('notification_settings');
  });

  setUp(() async {
    await settingsBox.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('retention settings are stored separately for each user', () async {
    final aliceSource = HiveNotificationSettingsDataSource(userId: 'Alice');
    final bobSource = HiveNotificationSettingsDataSource(userId: 'bob');

    await aliceSource.saveSettings(settings(6));
    await bobSource.saveSettings(settings(21));

    expect((await aliceSource.getSettings()).reminderHour, 6);
    expect((await bobSource.getSettings()).reminderHour, 21);
    expect(settingsBox.containsKey('retention_settings_alice'), isTrue);
    expect(settingsBox.containsKey('retention_settings_bob'), isTrue);
    expect(settingsBox.containsKey('retention_settings'), isFalse);
  });

  test('legacy retention settings are adopted only by first scoped user',
      () async {
    await HiveNotificationSettingsDataSource().saveSettings(settings(5));
    final aliceSource = HiveNotificationSettingsDataSource(userId: 'Alice');
    final bobSource = HiveNotificationSettingsDataSource(userId: 'bob');

    expect((await aliceSource.getSettings()).reminderHour, 5);
    expect((await bobSource.getSettings()).reminderHour, 9);
    expect(settingsBox.containsKey('retention_settings_alice'), isTrue);
    expect(settingsBox.containsKey('retention_settings'), isFalse);
  });

  test('clearSettings removes only the scoped user settings', () async {
    final aliceSource = HiveNotificationSettingsDataSource(userId: 'Alice');
    final bobSource = HiveNotificationSettingsDataSource(userId: 'bob');
    await aliceSource.saveSettings(settings(6));
    await bobSource.saveSettings(settings(21));

    await aliceSource.clearSettings();

    expect((await aliceSource.getSettings()).reminderHour, 9);
    expect((await bobSource.getSettings()).reminderHour, 21);
  });
}
