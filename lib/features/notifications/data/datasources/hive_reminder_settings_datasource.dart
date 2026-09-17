import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/reminder_settings.dart';
import '../../../../core/utils/hive_manager.dart';

/// Hive datasource for persisting reminder settings
class HiveReminderSettingsDatasource {
  static const String _settingsKey = 'settings';

  /// Get the Hive box (using HiveManager)
  Box<Map<dynamic, dynamic>> _getBox() {
    return HiveManager.getNotificationSettingsBox();
  }

  /// Get reminder settings from Hive
  ReminderSettings? getSettings() {
    try {
      final box = _getBox();
      final data = box.get(_settingsKey);
      if (data == null) return null;

      // Deep convert all nested maps to Map<String, dynamic>
      final jsonMap = _deepConvertMap(data);
      return ReminderSettings.fromJson(jsonMap);
    } catch (e, stackTrace) {
      print('❌ [ReminderSettings] Error loading settings: $e');
      print('🔍 [ReminderSettings] Stack trace: $stackTrace');
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
      await box.put(_settingsKey, settings.toJson());
      print('✅ [ReminderSettings] Settings saved');
    } catch (e) {
      print('❌ [ReminderSettings] Error saving settings: $e');
      rethrow;
    }
  }

  /// Clear all reminder settings
  Future<void> clearSettings() async {
    try {
      final box = _getBox();
      await box.delete(_settingsKey);
      print('✅ [ReminderSettings] Settings cleared');
    } catch (e) {
      print('❌ [ReminderSettings] Error clearing settings: $e');
      rethrow;
    }
  }
}
