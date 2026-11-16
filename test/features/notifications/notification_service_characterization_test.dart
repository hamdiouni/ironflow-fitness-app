import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/notifications/data/datasources/hive_reminder_settings_datasource.dart';
import 'package:progression_tracker/features/notifications/data/repositories/reminder_settings_repository_impl.dart';
import 'package:progression_tracker/features/notifications/domain/entities/reminder_settings.dart';
import 'package:progression_tracker/features/notifications/domain/repositories/reminder_settings_repository.dart';
import 'package:progression_tracker/features/notifications/domain/services/notification_service.dart';
import 'package:progression_tracker/features/notifications/presentation/notifiers/reminder_settings_notifier.dart';
import 'package:progression_tracker/features/notifications/presentation/providers/notification_providers.dart';

class _SpyNotificationService implements NotificationService {
  int requestPermissionsCalls = 0;
  int workoutCalls = 0;
  int mealCalls = 0;
  int streakCalls = 0;
  int showCalls = 0;
  int cancelAllCalls = 0;

  @override
  Future<bool> requestPermissions() async {
    requestPermissionsCalls++;
    return true;
  }

  @override
  Future<void> scheduleWorkoutReminder(TimeOfDayModel time,
      {bool enabled = true}) async {
    workoutCalls++;
  }

  @override
  Future<void> scheduleMealReminders({
    required TimeOfDayModel breakfast,
    required TimeOfDayModel lunch,
    required TimeOfDayModel dinner,
    required bool enabled,
  }) async {
    mealCalls++;
  }

  @override
  Future<void> scheduleStreakReminder(TimeOfDayModel time,
      {bool enabled = true}) async {
    streakCalls++;
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    showCalls++;
  }

  @override
  Future<void> cancelAllNotifications() async {
    cancelAllCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('notif_char_test_');
    Hive.init(tempDir.path);
    await Hive.openBox<Map>('notification_settings');
  });

  setUp(() async {
    await Hive.box<Map>('notification_settings').clear();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('Wave 2.2 — Notifications Repository, Service & Notifier Characterization',
      () {
    test('TimeOfDayModelX formats 12-hour strings and converts to DateTime', () {
      const midnight = TimeOfDayModel(hour: 0, minute: 5);
      const noon = TimeOfDayModel(hour: 12, minute: 30);
      const evening = TimeOfDayModel(hour: 19, minute: 45);

      expect(midnight.toDisplayString(), '12:05 AM');
      expect(noon.toDisplayString(), '12:30 PM');
      expect(evening.toDisplayString(), '7:45 PM');
      expect(evening.toDateTime().hour, 19);
      expect(evening.toDateTime().minute, 45);
    });

    test('ReminderSettingsRepositoryImpl returns defaults when empty and persists/clears settings',
        () async {
      final repo = ReminderSettingsRepositoryImpl(
        HiveReminderSettingsDatasource(userId: 'notif-user-1'),
      );

      final initial = await repo.getSettings();
      expect(initial.workoutRemindersEnabled, isFalse);
      expect(initial.soundEnabled, isTrue);

      final custom = initial.copyWith(
        workoutRemindersEnabled: true,
        mealRemindersEnabled: true,
      );
      await repo.saveSettings(custom);
      expect((await repo.getSettings()).mealRemindersEnabled, isTrue);

      await repo.clearSettings();
      expect((await repo.getSettings()).mealRemindersEnabled, isFalse);
    });

    test('NotificationService fails safely when uninitialized and keeps inexact alarm shim returning true',
        () async {
      final service = NotificationService();
      expect(await service.requestExactAlarmPermission(), isTrue);
      expect(await service.requestPermissions(), isFalse);
      expect(await service.areNotificationsEnabled(), isFalse);
      expect(await service.getLaunchNotificationPayload(), isNull);

      // Should not throw when uninitialized in tests/headless hosts.
      await service.scheduleWorkoutReminder(
        const TimeOfDayModel(hour: 8, minute: 0),
        enabled: true,
      );
      await service.scheduleMealReminders(
        breakfast: const TimeOfDayModel(hour: 8, minute: 0),
        lunch: const TimeOfDayModel(hour: 12, minute: 0),
        dinner: const TimeOfDayModel(hour: 19, minute: 0),
        enabled: false,
      );
      await service.scheduleStreakReminder(
        const TimeOfDayModel(hour: 20, minute: 0),
        enabled: false,
      );
      await service.showNotification(id: 1, title: 'T', body: 'B');
      await service.cancelRestTimer();
      await service.cancelAllNotifications();
    });

    test('ReminderSettingsNotifier updates meal, streak, sound/vibration, testNotification, and clearSettings',
        () async {
      final repo = ReminderSettingsRepositoryImpl(
        HiveReminderSettingsDatasource(userId: 'notif-user-2'),
      );
      final spyService = _SpyNotificationService();
      final container = ProviderContainer(
        overrides: [
          reminderSettingsRepositoryProvider.overrideWithValue(repo),
          notificationServiceProvider.overrideWithValue(spyService),
          reminderSettingsProvider.overrideWith(
            () => ReminderSettingsNotifier(repo, spyService),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(reminderSettingsProvider.future);
      final notifier = container.read(reminderSettingsProvider.notifier);

      await notifier.updateMealReminders(
        enabled: true,
        breakfastTime: const TimeOfDayModel(hour: 7, minute: 30),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(spyService.requestPermissionsCalls, 1);

      await notifier.updateStreakReminder(
        enabled: true,
        time: const TimeOfDayModel(hour: 21, minute: 0),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(spyService.requestPermissionsCalls, 2);

      await notifier.updateSoundAndVibration(
        soundEnabled: false,
        vibrationEnabled: false,
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final updated = container.read(reminderSettingsProvider).valueOrNull;
      expect(updated?.soundEnabled, isFalse);
      expect(updated?.vibrationEnabled, isFalse);
      expect(updated?.mealRemindersEnabled, isTrue);

      await notifier.testNotification();
      expect(spyService.showCalls, 1);

      await notifier.clearSettings();
      expect(spyService.cancelAllCalls, 1);
      expect(
        container.read(reminderSettingsProvider).valueOrNull?.mealRemindersEnabled,
        isFalse,
      );
    });

    test('notification_providers default ReminderSettingsRepository resolves cleanly per scope',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final ReminderSettingsRepository repo =
          container.read(reminderSettingsRepositoryProvider);
      expect(await repo.getSettings(), const ReminderSettings());
    });
  });
}
