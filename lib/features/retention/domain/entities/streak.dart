import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:progression_tracker/core/utils/workout_streak_calculator.dart';

part 'streak.freezed.dart';
part 'streak.g.dart';

/// Represents a user's workout streak.
///
/// Tracks consecutive local calendar days with workouts and resets on missed days.
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

  /// Checks if the streak is still active using local calendar dates
  /// (most recent workout was today or yesterday).
  bool get isActive {
    final today = WorkoutStreakCalculator.toLocalCalendarDate(DateTime.now());
    final lastDay = WorkoutStreakCalculator.toLocalCalendarDate(lastWorkoutDate);
    return WorkoutStreakCalculator.calendarDayDifference(lastDay, today) <= 1;
  }

  /// Updates streak after a new workout using local calendar dates.
  Streak addWorkout({DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    final today = WorkoutStreakCalculator.toLocalCalendarDate(timestamp);
    final lastDay = WorkoutStreakCalculator.toLocalCalendarDate(lastWorkoutDate);
    final daysSinceLastWorkout =
        WorkoutStreakCalculator.calendarDayDifference(lastDay, today);

    // Same local calendar day: keep current count, update timestamp.
    if (daysSinceLastWorkout == 0) {
      return copyWith(lastWorkoutDate: timestamp);
    }

    // Gap of 2+ calendar days or initial stale state: start a fresh 1-day streak.
    if (daysSinceLastWorkout > 1 || currentStreak == 0) {
      final newLongest = longestStreak < 1 ? 1 : longestStreak;
      return copyWith(
        currentStreak: 1,
        longestStreak: newLongest,
        streakStartDate: timestamp,
        lastWorkoutDate: timestamp,
      );
    }

    // Consecutive local calendar day (daysSinceLastWorkout == 1): increment.
    final newStreak = currentStreak + 1;
    final newLongest = newStreak > longestStreak ? newStreak : longestStreak;

    return copyWith(
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastWorkoutDate: timestamp,
    );
  }

  /// Resets the streak (called when user misses a day)
  Streak reset() => copyWith(
        currentStreak: 0,
        lastWorkoutDate: DateTime.now().subtract(const Duration(days: 2)),
        streakStartDate: DateTime.now(),
      );
}
