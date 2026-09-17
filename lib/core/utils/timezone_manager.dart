import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Timezone manager for handling timezone-aware timestamps.
///
/// All timestamps are stored in UTC and converted to user's timezone for display.
/// **Validates: Requirements 10.3 (Timezone Support)**
class TimezoneManager {
  static const String _boxName = 'app_settings';
  static const String _timezoneKey = 'timezone_offset';

  /// Get the current timezone offset in hours.
  ///
  /// Returns the user's timezone offset from UTC.
  /// Positive values are east of UTC, negative values are west.
  static int getCurrentTimezoneOffset() {
    final now = DateTime.now();
    return now.timeZoneOffset.inHours;
  }

  /// Get the saved timezone offset from storage.
  static Future<int> getSavedTimezoneOffset() async {
    try {
      final box = await Hive.openBox<int>(_boxName);
      return box.get(_timezoneKey, defaultValue: getCurrentTimezoneOffset()) ?? getCurrentTimezoneOffset();
    } catch (e) {
      print('Error loading timezone: $e');
      return getCurrentTimezoneOffset();
    }
  }

  /// Save the timezone offset to storage.
  static Future<void> saveTimezoneOffset(int offsetHours) async {
    try {
      final box = await Hive.openBox<int>(_boxName);
      await box.put(_timezoneKey, offsetHours);
    } catch (e) {
      print('Error saving timezone: $e');
    }
  }

  /// Convert a UTC timestamp to user's local time.
  static DateTime utcToLocal(DateTime utcTime) {
    return utcTime.toLocal();
  }

  /// Convert a local timestamp to UTC.
  static DateTime localToUtc(DateTime localTime) {
    return localTime.toUtc();
  }

  /// Format a UTC timestamp for display in user's timezone.
  static String formatInUserTimezone(DateTime utcTime, {String format = 'yyyy-MM-dd HH:mm'}) {
    final localTime = utcToLocal(utcTime);
    // Basic formatting - in production, use intl package for proper formatting
    return '${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')} '
           '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
  }

  /// Get the timezone name (e.g., "PST", "EST", "UTC+8").
  static String getTimezoneName() {
    final offset = getCurrentTimezoneOffset();
    if (offset == 0) return 'UTC';
    final sign = offset > 0 ? '+' : '';
    return 'UTC$sign$offset';
  }

  /// Check if daylight saving time is currently active.
  static bool isDaylightSavingTime() {
    final now = DateTime.now();
    final january = DateTime(now.year, 1, 1);
    final july = DateTime(now.year, 7, 1);
    
    final januaryOffset = january.timeZoneOffset.inHours;
    final julyOffset = july.timeZoneOffset.inHours;
    final currentOffset = now.timeZoneOffset.inHours;
    
    // If current offset is different from January, DST is likely active
    return currentOffset != januaryOffset && currentOffset == julyOffset;
  }

  /// Get a list of common timezone offsets for selection.
  static List<TimezoneInfo> getCommonTimezones() {
    return [
      TimezoneInfo(offset: -12, name: 'UTC-12', displayName: 'Baker Island'),
      TimezoneInfo(offset: -11, name: 'UTC-11', displayName: 'American Samoa'),
      TimezoneInfo(offset: -10, name: 'UTC-10', displayName: 'Hawaii'),
      TimezoneInfo(offset: -9, name: 'UTC-9', displayName: 'Alaska'),
      TimezoneInfo(offset: -8, name: 'UTC-8', displayName: 'Pacific Time (US)'),
      TimezoneInfo(offset: -7, name: 'UTC-7', displayName: 'Mountain Time (US)'),
      TimezoneInfo(offset: -6, name: 'UTC-6', displayName: 'Central Time (US)'),
      TimezoneInfo(offset: -5, name: 'UTC-5', displayName: 'Eastern Time (US)'),
      TimezoneInfo(offset: -4, name: 'UTC-4', displayName: 'Atlantic Time'),
      TimezoneInfo(offset: -3, name: 'UTC-3', displayName: 'Buenos Aires'),
      TimezoneInfo(offset: -2, name: 'UTC-2', displayName: 'Mid-Atlantic'),
      TimezoneInfo(offset: -1, name: 'UTC-1', displayName: 'Azores'),
      TimezoneInfo(offset: 0, name: 'UTC', displayName: 'London, Dublin'),
      TimezoneInfo(offset: 1, name: 'UTC+1', displayName: 'Paris, Berlin'),
      TimezoneInfo(offset: 2, name: 'UTC+2', displayName: 'Cairo, Athens'),
      TimezoneInfo(offset: 3, name: 'UTC+3', displayName: 'Moscow, Istanbul'),
      TimezoneInfo(offset: 4, name: 'UTC+4', displayName: 'Dubai'),
      TimezoneInfo(offset: 5, name: 'UTC+5', displayName: 'Pakistan'),
      TimezoneInfo(offset: 5.5, name: 'UTC+5:30', displayName: 'India'),
      TimezoneInfo(offset: 6, name: 'UTC+6', displayName: 'Bangladesh'),
      TimezoneInfo(offset: 7, name: 'UTC+7', displayName: 'Bangkok, Jakarta'),
      TimezoneInfo(offset: 8, name: 'UTC+8', displayName: 'Beijing, Singapore'),
      TimezoneInfo(offset: 9, name: 'UTC+9', displayName: 'Tokyo, Seoul'),
      TimezoneInfo(offset: 10, name: 'UTC+10', displayName: 'Sydney'),
      TimezoneInfo(offset: 11, name: 'UTC+11', displayName: 'Solomon Islands'),
      TimezoneInfo(offset: 12, name: 'UTC+12', displayName: 'Auckland'),
    ];
  }
}

/// Timezone information for display.
class TimezoneInfo {
  final double offset;
  final String name;
  final String displayName;

  TimezoneInfo({
    required this.offset,
    required this.name,
    required this.displayName,
  });

  String get fullDisplayName => '$displayName ($name)';
}

/// Provider for timezone offset.
final timezoneOffsetProvider = StateNotifierProvider<TimezoneOffsetNotifier, int>((ref) {
  return TimezoneOffsetNotifier();
});

/// Notifier for managing timezone offset.
class TimezoneOffsetNotifier extends StateNotifier<int> {
  TimezoneOffsetNotifier() : super(TimezoneManager.getCurrentTimezoneOffset()) {
    _loadTimezone();
  }

  Future<void> _loadTimezone() async {
    final offset = await TimezoneManager.getSavedTimezoneOffset();
    state = offset;
  }

  Future<void> setTimezoneOffset(int offsetHours) async {
    state = offsetHours;
    await TimezoneManager.saveTimezoneOffset(offsetHours);
  }

  String get timezoneName => TimezoneManager.getTimezoneName();
}
