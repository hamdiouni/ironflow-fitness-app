import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reminder_settings.dart';
import '../../domain/repositories/reminder_settings_repository.dart';
import '../../domain/services/notification_service.dart';
import '../providers/notification_providers.dart';

/// AsyncNotifier for managing reminder settings (Wave 3.2).
class ReminderSettingsNotifier extends AsyncNotifier<ReminderSettings> {
  ReminderSettingsNotifier([
    this._injectedRepository,
    this._injectedNotificationService,
  ]);

  final ReminderSettingsRepository? _injectedRepository;
  final NotificationService? _injectedNotificationService;

  late ReminderSettingsRepository _repository;
  late NotificationService _notificationService;

  @override
  Future<ReminderSettings> build() async {
    _repository =
        _injectedRepository ?? ref.watch(reminderSettingsRepositoryProvider);
    _notificationService =
        _injectedNotificationService ?? ref.watch(notificationServiceProvider);
    final settings = await _repository.getSettings();
    await _scheduleNotifications(settings);
    return settings;
  }

  /// Update workout reminder settings
  Future<void> updateWorkoutReminder({
    bool? enabled,
    TimeOfDayModel? time,
  }) async {
    if (enabled == true) {
      await _notificationService.requestPermissions();
    }
    state.whenData((currentSettings) async {
      final newSettings = currentSettings.copyWith(
        workoutRemindersEnabled: enabled ?? currentSettings.workoutRemindersEnabled,
        workoutReminderTime: time ?? currentSettings.workoutReminderTime,
      );
      
      await _saveAndSchedule(newSettings);
    });
  }

  /// Update meal reminder settings
  Future<void> updateMealReminders({
    bool? enabled,
    TimeOfDayModel? breakfastTime,
    TimeOfDayModel? lunchTime,
    TimeOfDayModel? dinnerTime,
  }) async {
    if (enabled == true) {
      await _notificationService.requestPermissions();
    }
    state.whenData((currentSettings) async {
      final newSettings = currentSettings.copyWith(
        mealRemindersEnabled: enabled ?? currentSettings.mealRemindersEnabled,
        breakfastTime: breakfastTime ?? currentSettings.breakfastTime,
        lunchTime: lunchTime ?? currentSettings.lunchTime,
        dinnerTime: dinnerTime ?? currentSettings.dinnerTime,
      );
      
      await _saveAndSchedule(newSettings);
    });
  }

  /// Update streak reminder settings
  Future<void> updateStreakReminder({
    bool? enabled,
    TimeOfDayModel? time,
  }) async {
    if (enabled == true) {
      await _notificationService.requestPermissions();
    }
    state.whenData((currentSettings) async {
      final newSettings = currentSettings.copyWith(
        streakRemindersEnabled: enabled ?? currentSettings.streakRemindersEnabled,
        streakReminderTime: time ?? currentSettings.streakReminderTime,
      );
      
      await _saveAndSchedule(newSettings);
    });
  }

  /// Update sound and vibration settings
  Future<void> updateSoundAndVibration({
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) async {
    state.whenData((currentSettings) async {
      final newSettings = currentSettings.copyWith(
        soundEnabled: soundEnabled ?? currentSettings.soundEnabled,
        vibrationEnabled: vibrationEnabled ?? currentSettings.vibrationEnabled,
      );
      
      await _saveAndSchedule(newSettings);
    });
  }

  /// Save settings and schedule notifications
  Future<void> _saveAndSchedule(ReminderSettings settings) async {
    try {
      await _repository.saveSettings(settings);
      state = AsyncValue.data(settings);
      await _scheduleNotifications(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Schedule all notifications based on settings
  Future<void> _scheduleNotifications(ReminderSettings settings) async {
    // Reminders intentionally use inexact Android scheduling; no
    // exact-alarm special access is requested for ordinary reminders.

    // Schedule workout reminder
    await _notificationService.scheduleWorkoutReminder(
      settings.workoutReminderTime,
      enabled: settings.workoutRemindersEnabled,
    );

    // Schedule meal reminders
    await _notificationService.scheduleMealReminders(
      breakfast: settings.breakfastTime,
      lunch: settings.lunchTime,
      dinner: settings.dinnerTime,
      enabled: settings.mealRemindersEnabled,
    );

    // Schedule streak reminder
    await _notificationService.scheduleStreakReminder(
      settings.streakReminderTime,
      enabled: settings.streakRemindersEnabled,
    );
  }

  /// Test notification (for debugging)
  Future<void> testNotification() async {
    await _notificationService.showNotification(
      id: 999,
      title: '🔔 Test Notification',
      body: 'This is a test notification from IronFlow!',
      payload: 'test',
    );
  }

  /// Clear all settings
  Future<void> clearSettings() async {
    try {
      await _repository.clearSettings();
      await _notificationService.cancelAllNotifications();
      state = const AsyncValue.data(ReminderSettings());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
