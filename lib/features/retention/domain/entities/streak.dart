import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak.freezed.dart';
part 'streak.g.dart';

/// Represents a user's workout streak.
///
/// Tracks consecutive days with workouts and resets on missed days.
@freezed
class Streak with _$Streak {
  const factory Streak({
    /// Current consecutive day count
    required int currentStreak,

    /// Longest streak ever achieved
    required int longestStreak,

    /// Date of the last workout
    required DateTime lastWorkoutDate,

    /// Date when the current streak started
    required DateTime streakStartDate,
  }) = _Streak;

  factory Streak.fromJson(Map<String, dynamic> json) =>
      _$StreakFromJson(json);

  /// Creates an initial streak (no workouts yet)
  factory Streak.initial() => Streak(
        currentStreak: 0,
        longestStreak: 0,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 2)),
        streakStartDate: DateTime.now(),
      );

  const Streak._();

  /// Checks if the streak is still active (workout within last 24 hours)
  bool get isActive {
    final now = DateTime.now();
    final daysSinceLastWorkout =
        now.difference(lastWorkoutDate).inDays;
    return daysSinceLastWorkout <= 1;
  }

  /// Updates streak after a new workout
  Streak addWorkout() {
    final now = DateTime.now();
    final daysSinceLastWorkout =
        now.difference(lastWorkoutDate).inDays;

    // If more than 1 day has passed, reset streak
    if (daysSinceLastWorkout > 1) {
      return copyWith(
        currentStreak: 1,
        streakStartDate: now,
        lastWorkoutDate: now,
      );
    }

    // If same day, don't increment
    if (daysSinceLastWorkout == 0) {
      return copyWith(lastWorkoutDate: now);
    }

    // Increment streak
    final newStreak = currentStreak + 1;
    final newLongest = newStreak > longestStreak ? newStreak : longestStreak;

    return copyWith(
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastWorkoutDate: now,
    );
  }

  /// Resets the streak (called when user misses a day)
  Streak reset() => copyWith(
        currentStreak: 0,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 2)),
        streakStartDate: DateTime.now(),
      );
}
