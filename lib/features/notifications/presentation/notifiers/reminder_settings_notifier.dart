import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reminder_settings.dart';
import '../../domain/repositories/reminder_settings_repository.dart';
import '../../domain/services/notification_service.dart';

/// State notifier for managing reminder settings
class ReminderSettingsNotifier extends StateNotifier<AsyncValue<ReminderSettings>> {
  final ReminderSettingsRepository _repository;
  final NotificationService _notificationService;

  ReminderSettingsNotifier(this._repository, this._notificationService)
      : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  /// Load settings from repository
  Future<void> _loadSettings() async {
    try {
      final settings = await _repository.getSettings();
      state = AsyncValue.data(settings);
      
      // Schedule notifications based on loaded settings
      await _scheduleNotifications(settings);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update workout reminder settings
  Future<void> updateWorkoutReminder({
    bool? enabled,
    TimeOfDayModel? time,
  }) async {
    await state.whenData((currentSettings) async {
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
    await state.whenData((currentSettings) async {
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
    await state.whenData((currentSettings) async {
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
    await state.whenData((currentSettings) async {
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
    // Check if any notifications are enabled
    final hasEnabledNotifications = settings.workoutRemindersEnabled || 
                                   settings.mealRemindersEnabled || 
                                   settings.streakRemindersEnabled;
    
    if (hasEnabledNotifications) {
      // Request exact alarm permission on Android (required for reliable notifications)
      final hasExactAlarmPermission = await _notificationService.requestExactAlarmPermission();
      
      if (!hasExactAlarmPermission) {
        print('⚠️ [Notifications] Exact alarm permission not granted - notifications may not be reliable');
        // Continue anyway - some notifications might still work
      }
    }

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
