import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/record_ownership.dart';
import '../../../auth/presentation/providers/auth_notifier.dart'
    show currentUserIdProvider;
import '../../domain/entities/notification_settings.dart';
import '../../domain/usecases/schedule_workout_reminder_use_case.dart';
import '../../data/datasources/hive_notification_settings_data_source.dart';

// ---------------------------------------------------------------------------
// Data source provider
// ---------------------------------------------------------------------------

final notificationSettingsDataSourceProvider =
    Provider<HiveNotificationSettingsDataSource>((ref) {
  final userId =
      ref.watch(currentUserIdProvider) ?? RecordOwnershipRules.guestUserId;
  return HiveNotificationSettingsDataSource(userId: userId);
});

// ---------------------------------------------------------------------------
// Notification plugin provider
// ---------------------------------------------------------------------------

final notificationPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
  return FlutterLocalNotificationsPlugin();
});

// ---------------------------------------------------------------------------
// Use case provider
// ---------------------------------------------------------------------------

final scheduleReminderUseCaseProvider =
    Provider<ScheduleWorkoutReminderUseCase>((ref) {
  final plugin = ref.watch(notificationPluginProvider);
  return ScheduleWorkoutReminderUseCase(plugin);
});

// ---------------------------------------------------------------------------
// Notification settings provider
// ---------------------------------------------------------------------------

/// Provides the user's notification settings.
final notificationSettingsProvider =
    FutureProvider<NotificationSettings>((ref) async {
  final dataSource = ref.watch(notificationSettingsDataSourceProvider);
  return dataSource.getSettings();
});

// ---------------------------------------------------------------------------
// Notification settings notifier
// ---------------------------------------------------------------------------

class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  late HiveNotificationSettingsDataSource _dataSource;
  late ScheduleWorkoutReminderUseCase _scheduleReminder;
  bool _disposed = false;

  @override
  NotificationSettings build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _dataSource = ref.watch(notificationSettingsDataSourceProvider);
    _scheduleReminder = ref.watch(scheduleReminderUseCaseProvider);
    _load();
    return NotificationSettings.defaults();
  }

  /// Loads persisted settings, replacing the defaults once available.
  Future<void> _load() async {
    final settings = await _dataSource.getSettings();
    if (!_disposed) state = settings;
  }

  /// Updates notification settings and reschedules reminder if needed.
  Future<void> updateSettings(NotificationSettings settings) async {
    state = settings;
    await _dataSource.saveSettings(settings);

    // Reschedule reminder if enabled
    if (settings.isEnabled) {
      await _scheduleReminder(
        time: TimeOfDay(
          hour: settings.reminderHour,
          minute: settings.reminderMinute,
        ),
        enabled: true,
      );
    } else {
      await _scheduleReminder.cancel();
    }
  }

  /// Toggles notifications on/off.
  Future<void> toggleNotifications() async {
    final updated = state.copyWith(isEnabled: !state.isEnabled);
    await updateSettings(updated);
  }

  /// Updates reminder time.
  Future<void> setReminderTime(int hour, int minute) async {
    final updated = state.copyWith(reminderHour: hour, reminderMinute: minute);
    await updateSettings(updated);
  }

  /// Toggles achievement notifications.
  Future<void> toggleAchievementNotifications() async {
    final updated =
        state.copyWith(showAchievements: !state.showAchievements);
    await updateSettings(updated);
  }

  /// Toggles streak reminder notifications.
  Future<void> toggleStreakReminders() async {
    final updated =
        state.copyWith(showStreakReminders: !state.showStreakReminders);
    await updateSettings(updated);
  }
}

// ---------------------------------------------------------------------------
// Notification settings state notifier provider
// ---------------------------------------------------------------------------

final notificationSettingsNotifierProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  NotificationSettingsNotifier.new,
);
