import 'package:hive/hive.dart';

import '../../domain/entities/streak.dart';

/// Hive-based data source for streak persistence.
class HiveStreakDataSource {
  static const String _boxName = 'streak';
  static const String _streakKey = 'current_streak';

  /// Gets the current streak from Hive storage.
  ///
  /// Returns initial streak if none exists.
  Future<Streak> getStreak() async {
    try {
      final box = Hive.box<Map>(_boxName);
      final streakData = box.get(_streakKey);

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
      await box.put(_streakKey, streak.toJson());
    } catch (e) {
      // Log error but don't throw
      print('Error saving streak: $e');
    }
  }

  /// Clears all streak data.
  Future<void> clearStreak() async {
    try {
      final box = Hive.box<Map>(_boxName);
      await box.delete(_streakKey);
    } catch (e) {
      print('Error clearing streak: $e');
    }
  }
}
