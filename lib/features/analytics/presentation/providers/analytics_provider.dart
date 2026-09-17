import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../workout/presentation/providers/workout_providers.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../onboarding/domain/entities/user_profile.dart';

/// Analytics statistics
class AnalyticsStats {
  final int totalWorkouts;
  final int currentStreak;
  final double weeklyConsistency;
  final double totalVolume;
  final int totalSets;
  final int totalReps;

  AnalyticsStats({
    required this.totalWorkouts,
    required this.currentStreak,
    required this.weeklyConsistency,
    required this.totalVolume,
    required this.totalSets,
    required this.totalReps,
  });
}

/// Provider for analytics statistics
final analyticsStatsProvider = FutureProvider<AnalyticsStats>((ref) async {
  final workoutHistory = await ref.watch(workoutHistoryProvider.future);
  final userProfile = await ref.watch(userProfileProvider.future);

  if (workoutHistory.isEmpty) {
    return AnalyticsStats(
      totalWorkouts: 0,
      currentStreak: 0,
      weeklyConsistency: 0,
      totalVolume: 0,
      totalSets: 0,
      totalReps: 0,
    );
  }

  // Calculate stats
  final totalWorkouts = workoutHistory.length;
  final currentStreak = _calculateStreak(workoutHistory);
  final weeklyConsistency = _calculateWeeklyConsistency(workoutHistory, userProfile);
  final totalVolume = workoutHistory.fold<double>(
    0,
    (sum, w) => sum + (w.totalVolume as double? ?? 0),
  );
  
  int totalSets = 0;
  int totalReps = 0;
  
  for (final workout in workoutHistory) {
    for (final exercise in workout.exercises) {
      totalSets += exercise.sets.length;
      for (final set in exercise.sets) {
        totalReps += set.reps;
      }
    }
  }

  return AnalyticsStats(
    totalWorkouts: totalWorkouts,
    currentStreak: currentStreak,
    weeklyConsistency: weeklyConsistency,
    totalVolume: totalVolume,
    totalSets: totalSets,
    totalReps: totalReps,
  );
});

/// Calculate current streak
int _calculateStreak(List<dynamic> history) {
  if (history.isEmpty) return 0;

  int streak = 0;
  DateTime? lastDate;

  // Sort by date descending (most recent first)
  final sorted = List.from(history);
  sorted.sort((a, b) => b.date.compareTo(a.date));

  for (final workout in sorted) {
    if (lastDate == null) {
      streak = 1;
      lastDate = workout.date;
    } else {
      final daysDifference = lastDate.difference(workout.date).inDays;
      if (daysDifference == 1) {
        streak++;
        lastDate = workout.date;
      } else {
        break;
      }
    }
  }

  return streak;
}

/// Calculate weekly consistency
double _calculateWeeklyConsistency(List<dynamic> history, UserProfile? profile) {
  if (history.isEmpty) return 0;

  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 7));

  final thisWeekWorkouts = history
      .where((w) => w.date.isAfter(weekStart) && w.date.isBefore(weekEnd))
      .length;

  return (thisWeekWorkouts / (profile?.workoutDaysPerWeek ?? 1)).clamp(0.0, 1.0);
}
