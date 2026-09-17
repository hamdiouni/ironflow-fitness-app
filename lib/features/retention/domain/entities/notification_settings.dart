import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_settings.freezed.dart';
part 'notification_settings.g.dart';

/// User's notification preferences.
@freezed
class NotificationSettings with _$NotificationSettings {
  const factory NotificationSettings({
    /// Whether notifications are enabled
    required bool isEnabled,

    /// Hour of the day for reminder (0-23)
    required int reminderHour,

    /// Minute of the hour for reminder (0-59)
    required int reminderMinute,

    /// Whether to show achievement notifications
    required bool showAchievements,

    /// Whether to show streak notifications
    required bool showStreakReminders,
  }) = _NotificationSettings;

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);

  /// Creates default notification settings (9 AM reminders enabled)
  factory NotificationSettings.defaults() => const NotificationSettings(
        isEnabled: true,
        reminderHour: 9,
        reminderMinute: 0,
        showAchievements: true,
        showStreakReminders: true,
      );
}
