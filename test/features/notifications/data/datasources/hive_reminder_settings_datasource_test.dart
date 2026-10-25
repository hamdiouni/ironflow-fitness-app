import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/notifications/data/datasources/hive_reminder_settings_datasource.dart';
import 'package:progression_tracker/features/notifications/domain/entities/reminder_settings.dart';

void main() {
  late Directory tempDir;
  late Box<Map> settingsBox;

  ReminderSettings settings(int hour) {
    return ReminderSettings(
      workoutRemindersEnabled: true,
      workoutReminderTime: TimeOfDayModel(hour: hour, minute: 15),
    );
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('reminder_settings_');
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

  test('reminder settings are stored separately for each user', () async {
    final aliceSource = HiveReminderSettingsDatasource(userId: 'Alice');
    final bobSource = HiveReminderSettingsDatasource(userId: 'bob');

    await aliceSource.saveSettings(settings(7));
    await bobSource.saveSettings(settings(19));

    expect(
      (await aliceSource.getSettings())?.workoutReminderTime.hour,
      7,
    );
    expect((await bobSource.getSettings())?.workoutReminderTime.hour, 19);
    expect(settingsBox.containsKey('settings_alice'), isTrue);
    expect(settingsBox.containsKey('settings_bob'), isTrue);
    expect(settingsBox.containsKey('settings'), isFalse);
  });

  test('legacy reminder settings are adopted only by first scoped user',
      () async {
    await HiveReminderSettingsDatasource().saveSettings(settings(8));
    final aliceSource = HiveReminderSettingsDatasource(userId: 'Alice');
    final bobSource = HiveReminderSettingsDatasource(userId: 'bob');

    expect(
      (await aliceSource.getSettings())?.workoutReminderTime.hour,
      8,
    );
    expect(await bobSource.getSettings(), isNull);
    expect(settingsBox.containsKey('settings_alice'), isTrue);
    expect(settingsBox.containsKey('settings'), isFalse);
  });

  test('clearSettings removes only the scoped user settings', () async {
    final aliceSource = HiveReminderSettingsDatasource(userId: 'Alice');
    final bobSource = HiveReminderSettingsDatasource(userId: 'bob');
    await aliceSource.saveSettings(settings(7));
    await bobSource.saveSettings(settings(19));

    await aliceSource.clearSettings();

    expect(await aliceSource.getSettings(), isNull);
    expect((await bobSource.getSettings())?.workoutReminderTime.hour, 19);
  });
}
