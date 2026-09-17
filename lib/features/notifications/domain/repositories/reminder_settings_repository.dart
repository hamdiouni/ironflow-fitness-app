import '../entities/reminder_settings.dart';

/// Repository interface for managing reminder settings
abstract class ReminderSettingsRepository {
  /// Get current reminder settings
  Future<ReminderSettings> getSettings();

  /// Save reminder settings
  Future<void> saveSettings(ReminderSettings settings);

  /// Clear all reminder settings
  Future<void> clearSettings();
}
