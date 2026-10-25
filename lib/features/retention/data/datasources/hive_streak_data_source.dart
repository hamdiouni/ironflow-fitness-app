import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/streak.dart';

/// Hive-based data source for streak persistence.
class HiveStreakDataSource {
  static const String _boxName = 'streak';
  static const String _streakKey = 'current_streak';

  /// Account that owns the streak read/written by this instance.
  /// Existing constructions without a user keep the legacy key.
  final String? userId;

  HiveStreakDataSource({this.userId});

  String? get _scopeUserId =>
      RecordOwnershipRules.storageScope(userId);

  String get _scopedStreakKey {
    final scopeUserId = _scopeUserId;
    return scopeUserId == null ? _streakKey : '${_streakKey}_$scopeUserId';
  }

  Future<Map?> _streakData(Box<Map> box) async {
    final scopedData = box.get(_scopedStreakKey);
    if (scopedData != null || _scopedStreakKey == _streakKey) {
      return scopedData;
    }

    // One-time adoption of a pre-scoping streak, only when no
    // account-scoped streak exists yet. Streak records carry no owner
    // field, so the legacy value cannot be attributed safely after
    // scoped streaks have been created.
    final hasScopedStreak =
        box.keys.any((key) => key.toString().startsWith('${_streakKey}_'));
    if (hasScopedStreak) return null;

    final legacyData = box.get(_streakKey);
    if (legacyData == null) return null;
    await box.put(_scopedStreakKey, legacyData);
    await box.delete(_streakKey);
    return legacyData;
  }

  /// Gets the current streak from Hive storage.
  ///
  /// Returns initial streak if none exists.
  Future<Streak> getStreak() async {
    try {
      final box = Hive.box<Map>(_boxName);
      final streakData = await _streakData(box);

      if (streakData == null) {
        return Streak.initial();
      }

      return Streak.fromJson(Map<String, dynamic>.from(streakData));
    } catch (e) {
      return Streak.initial();
    }
  }

  /// Saves the streak to Hive storage.
  Future<void> saveStreak(Streak streak) async {
    try {
      final box = Hive.box<Map>(_boxName);
      await box.put(_scopedStreakKey, streak.toJson());
    } catch (e) {
      // Log error but don't throw
      AppLogger.debug('Error saving streak: $e');
    }
  }

  /// Clears all streak data.
  Future<void> clearStreak() async {
    try {
      final box = Hive.box<Map>(_boxName);
      await box.delete(_scopedStreakKey);
    } catch (e) {
      AppLogger.debug('Error clearing streak: $e');
    }
  }
}
