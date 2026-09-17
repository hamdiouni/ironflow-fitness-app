import '../../domain/entities/reminder_settings.dart';
import '../../domain/repositories/reminder_settings_repository.dart';
import '../datasources/hive_reminder_settings_datasource.dart';

/// Implementation of ReminderSettingsRepository using Hive
class ReminderSettingsRepositoryImpl implements ReminderSettingsRepository {
  final HiveReminderSettingsDatasource _datasource;

  ReminderSettingsRepositoryImpl(this._datasource);

  @override
  Future<ReminderSettings> getSettings() async {
    final settings = _datasource.getSettings();
    
    // Return default settings if none exist
    if (settings == null) {
      return const ReminderSettings();
    }
    
    return settings;
  }

  @override
  Future<void> saveSettings(ReminderSettings settings) async {
    await _datasource.saveSettings(settings);
  }

  @override
  Future<void> clearSettings() async {
    await _datasource.clearSettings();
  }
}
