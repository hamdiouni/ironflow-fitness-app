import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/notifications/domain/entities/reminder_settings.dart';
import 'package:progression_tracker/features/notifications/domain/repositories/reminder_settings_repository.dart';
import 'package:progression_tracker/features/notifications/domain/services/notification_service.dart';
import 'package:progression_tracker/features/notifications/presentation/notifiers/reminder_settings_notifier.dart';
import 'package:progression_tracker/features/notifications/presentation/providers/notification_providers.dart';

class _FakeReminderRepository implements ReminderSettingsRepository {
  ReminderSettings stored = const ReminderSettings(
    workoutRemindersEnabled: false,
    mealRemindersEnabled: false,
    streakRemindersEnabled: false,
  );

  @override
  Future<ReminderSettings> getSettings() async => stored;

  @override
  Future<void> saveSettings(ReminderSettings settings) async {
    stored = settings;
  }

  @override
  Future<void> clearSettings() async {
    stored = const ReminderSettings();
  }
}

class _SpyNotificationService implements NotificationService {
  int requestPermissionsCallCount = 0;

  @override
  Future<bool> requestPermissions() async {
    requestPermissionsCallCount++;
    return true;
  }

  @override
  Future<void> scheduleWorkoutReminder(TimeOfDayModel time, {bool enabled = true}) async {}

  @override
  Future<void> scheduleMealReminders({
    required TimeOfDayModel breakfast,
    required TimeOfDayModel lunch,
    required TimeOfDayModel dinner,
    required bool enabled,
  }) async {}

  @override
  Future<void> scheduleStreakReminder(TimeOfDayModel time, {bool enabled = true}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Notification Permission Contextual Timing (Wave 1 Step 5)', () {
    test('main.dart does not call notificationService.requestPermissions() during cold boot', () {
      final mainSource = File('lib/main.dart').readAsStringSync();
      expect(
        mainSource.contains('notificationService.requestPermissions()'),
        isFalse,
        reason: 'Notification permissions must not be requested on cold start in main.dart',
      );
    });

    test('NotificationService.initialize configures iOS DarwinInitializationSettings with permission prompts disabled', () {
      final serviceSource = File(
        'lib/features/notifications/domain/services/notification_service.dart',
      ).readAsStringSync();
      expect(serviceSource, contains('requestAlertPermission: false'));
      expect(serviceSource, contains('requestBadgePermission: false'));
      expect(serviceSource, contains('requestSoundPermission: false'));
    });

    test('ReminderSettingsNotifier does not request permissions on load, only when user enables a reminder toggle', () async {
      final repo = _FakeReminderRepository();
      final spyNotifications = _SpyNotificationService();
      final container = ProviderContainer(
        overrides: [
          reminderSettingsProvider.overrideWith(
            () => ReminderSettingsNotifier(repo, spyNotifications),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(reminderSettingsProvider.future);
      final notifier = container.read(reminderSettingsProvider.notifier);

      // Initial load must NOT trigger permission prompt
      expect(spyNotifications.requestPermissionsCallCount, equals(0));

      // Disabling a reminder must NOT trigger permission prompt
      await notifier.updateWorkoutReminder(enabled: false);
      expect(spyNotifications.requestPermissionsCallCount, equals(0));

      // Enabling workout reminder triggers contextual permission prompt
      await notifier.updateWorkoutReminder(enabled: true);
      expect(spyNotifications.requestPermissionsCallCount, equals(1));

      // Enabling meal reminder triggers contextual permission prompt
      await notifier.updateMealReminders(enabled: true);
      expect(spyNotifications.requestPermissionsCallCount, equals(2));
    });
  });
}

