import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/notification_settings.dart';

/// Hive-based data source for notification settings persistence.
class HiveNotificationSettingsDataSource {
  static const String _boxName = 'notification_settings';
  // Was 'settings' — the same box+key used by notifications'
  // HiveReminderSettingsDatasource with an incompatible schema
  // (ReminderSettings). The two silently overwrote each other and both
  // fell back to defaults on parse failure (DATABASE_AND_SYNC_AUDIT F-09).
  // Retention settings now live under their own key.
  static const String _settingsKey = 'retention_settings';

  /// Account that owns settings read/written by this instance.
  /// Existing constructions without a user keep the legacy key.
  final String? userId;

  HiveNotificationSettingsDataSource({this.userId});

  String? get _scopeUserId =>
      RecordOwnershipRules.storageScope(userId);

  String get _scopedSettingsKey {
    final scopeUserId = _scopeUserId;
    return scopeUserId == null
        ? _settingsKey
        : '${_settingsKey}_$scopeUserId';
  }

  Future<Map?> _settingsData(Box<Map> box) async {
    final scopedData = box.get(_scopedSettingsKey);
    if (scopedData != null || _scopedSettingsKey == _settingsKey) {
      return scopedData;
    }

    // One-time adoption of pre-scoping settings, only when no
    // account-scoped settings exist yet for this schema.
    final hasScopedSettings = box.keys.any(
      (key) => key.toString().startsWith('${_settingsKey}_'),
    );
    if (hasScopedSettings) return null;

    final legacyData = box.get(_settingsKey);
    if (legacyData == null) return null;
    await box.put(_scopedSettingsKey, legacyData);
    await box.delete(_settingsKey);
    return legacyData;
  }

  /// Gets the notification settings from Hive storage.
  ///
  /// Returns default settings if none exist.
  Future<NotificationSettings> getSettings() async {
    try {
      final box = Hive.box<Map>(_boxName);
      final settingsData = await _settingsData(box);

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
      await box.put(_scopedSettingsKey, settings.toJson());
    } catch (e) {
      AppLogger.debug('Error saving notification settings: $e');
    }
  }

  /// Clears all notification settings.
  Future<void> clearSettings() async {
    try {
      final box = Hive.box<Map>(_boxName);
      await box.delete(_scopedSettingsKey);
    } catch (e) {
      AppLogger.debug('Error clearing notification settings: $e');
    }
  }
}
