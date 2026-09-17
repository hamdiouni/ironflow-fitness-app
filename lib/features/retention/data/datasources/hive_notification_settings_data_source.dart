import 'package:hive/hive.dart';

import '../../domain/entities/notification_settings.dart';

/// Hive-based data source for notification settings persistence.
class HiveNotificationSettingsDataSource {
  static const String _boxName = 'notification_settings';
  static const String _settingsKey = 'settings';

  /// Gets the notification settings from Hive storage.
  ///
  /// Returns default settings if none exist.
  Future<NotificationSettings> getSettings() async {
    try {
      final box = Hive.box<Map>(_boxName);
      final settingsData = box.get(_settingsKey);

      if (settingsData == null) {
        return NotificationSettings.defaults();
      }

      return NotificationSettings.fromJson(
        Map<String, dynamic>.from(settingsData),
      );
    } catch (e) {
      return NotificationSettings.defaults();
    }
  }

  /// Saves notification settings to Hive storage.
  Future<void> saveSettings(NotificationSettings settings) async {
    try {
      final box = Hive.box<Map>(_boxName);
      await box.put(_settingsKey, settings.toJson());
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }

  /// Clears all notification settings.
  Future<void> clearSettings() async {
    try {
      final box = Hive.box<Map>(_boxName);
      await box.delete(_settingsKey);
    } catch (e) {
      print('Error clearing notification settings: $e');
    }
  }
}
