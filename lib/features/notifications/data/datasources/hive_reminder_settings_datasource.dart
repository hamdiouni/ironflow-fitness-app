import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/reminder_settings.dart';
import '../../../../core/utils/hive_manager.dart';
import '../../../../core/utils/record_ownership.dart';

/// Hive datasource for persisting reminder settings
class HiveReminderSettingsDatasource {
  static const String _settingsKey = 'settings';

  /// Account that owns settings read/written by this instance.
  /// Existing constructions without a user keep the legacy key.
  final String? userId;

  HiveReminderSettingsDatasource({this.userId});

  String? get _scopeUserId =>
      RecordOwnershipRules.normalizeUserId(userId);

  String get _scopedSettingsKey {
    final scopeUserId = _scopeUserId;
    return scopeUserId == null
        ? _settingsKey
        : '${_settingsKey}_$scopeUserId';
  }

  /// Get the Hive box (using HiveManager)
  Box<Map<dynamic, dynamic>> _getBox() {
    return HiveManager.getNotificationSettingsBox();
  }

  Future<dynamic> _settingsData(Box<Map<dynamic, dynamic>> box) async {
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

  /// Get reminder settings from Hive
  Future<ReminderSettings?> getSettings() async {
    try {
      final box = _getBox();
      final data = await _settingsData(box);
      if (data == null) return null;

      // Deep convert all nested maps to Map<String, dynamic>
      final jsonMap = _deepConvertMap(data);
      return ReminderSettings.fromJson(jsonMap);
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [ReminderSettings] Error loading settings: $e');
      AppLogger.debug('🔍 [ReminderSettings] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Deep convert Map (handles nested LinkedMaps from Hive)
  Map<String, dynamic> _deepConvertMap(dynamic data) {
    if (data is Map) {
      return data.map((key, value) {
        if (value is Map) {
          return MapEntry(key.toString(), _deepConvertMap(value));
        } else if (value is List) {
          return MapEntry(key.toString(), value.map((e) => e is Map ? _deepConvertMap(e) : e).toList());
        } else {
          return MapEntry(key.toString(), value);
        }
      });
    }
    return {};
  }

  /// Save reminder settings to Hive
  Future<void> saveSettings(ReminderSettings settings) async {
    try {
      final box = _getBox();
      await box.put(_scopedSettingsKey, settings.toJson());
      AppLogger.debug('✅ [ReminderSettings] Settings saved');
    } catch (e) {
      AppLogger.debug('❌ [ReminderSettings] Error saving settings: $e');
      rethrow;
    }
  }

  /// Clear all reminder settings
  Future<void> clearSettings() async {
    try {
      final box = _getBox();
      await box.delete(_scopedSettingsKey);
      AppLogger.debug('✅ [ReminderSettings] Settings cleared');
    } catch (e) {
      AppLogger.debug('❌ [ReminderSettings] Error clearing settings: $e');
      rethrow;
    }
  }
}
