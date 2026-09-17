import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/achievement.dart';
import '../../../workout/presentation/providers/workout_providers.dart';
import '../providers/streak_provider.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';

// ---------------------------------------------------------------------------
// Achievements provider
// ---------------------------------------------------------------------------

/// Provides all achievements with their unlock status and progress.
///
/// Watches workout history, streak, and analytics to calculate achievements.
final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final historyAsync = ref.watch(workoutHistoryProvider);
  final streakAsync = ref.watch(streakProvider);
  final analyticsAsync = ref.watch(analyticsStatsProvider);

  // Wait for all data to load
  final history = await historyAsync.when(
    data: (data) => data,
    loading: () => [],
    error: (_, __) => [],
  );

  final streak = await streakAsync.when(
    data: (data) => data,
    loading: () => null,
    error: (_, __) => null,
  );

  final analytics = await analyticsAsync.when(
    data: (data) => data,
    loading: () => null,
    error: (_, __) => null,
  );

  // Calculate achievements
  return AchievementDefinitions.calculateAchievements(
    totalWorkouts: history.length,
    currentStreak: streak?.currentStreak ?? 0,
    totalVolume: analytics?.totalVolume ?? 0.0,
  );
});

// ---------------------------------------------------------------------------
// New achievements provider
// ---------------------------------------------------------------------------

/// Provides only newly unlocked achievements.
///
/// Useful for showing achievement notifications.
final newAchievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  final achievements = await ref.watch(achievementsProvider.future);
  return achievements.where((a) => a.isUnlocked && a.unlockedDate != null).toList();
});

// ---------------------------------------------------------------------------
// Achievement progress provider
// ---------------------------------------------------------------------------

/// Provides progress towards a specific achievement.
final achievementProgressProvider =
    FutureProvider.family<double, String>((ref, achievementId) async {
  final achievements = await ref.watch(achievementsProvider.future);
  final achievement = achievements.firstWhere(
    (a) => a.id == achievementId,
    orElse: () => const Achievement(
      id: '',
      name: '',
      description: '',
      icon: '',
      threshold: 0,
      type: AchievementType.workouts,
      isUnlocked: false,
      progress: 0.0,
    ),
  );
  return achievement.progress;
});
