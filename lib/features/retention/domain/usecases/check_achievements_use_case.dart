import 'package:progression_tracker/features/retention/domain/entities/achievement.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';

/// Use case for checking and updating user achievements.
class CheckAchievementsUseCase {
  final WorkoutRepository _workoutRepository;

  CheckAchievementsUseCase(this._workoutRepository);

  /// Checks all achievements and returns updated list with progress.
  ///
  /// [userId] - The ID of the user
  ///
  /// Returns list of [Achievement] with updated progress and unlock status.
  Future<List<Achievement>> call({required String userId}) async {
    // Get user stats
    final workouts = await _workoutRepository.getAllWorkouts();
    final totalWorkouts = workouts.length;

    // Calculate current streak
    int currentStreak = 0;
    if (workouts.isNotEmpty) {
      final sorted = List.from(workouts);
      sorted.sort((a, b) => b.date.compareTo(a.date));

      DateTime? lastDate;
      int tempStreak = 0;

      for (final workout in sorted) {
        if (lastDate == null) {
          tempStreak = 1;
        } else {
          final daysDiff = lastDate.difference(workout.date).inDays;
          if (daysDiff == 1) {
            tempStreak++;
          } else {
            break;
          }
        }
        lastDate = workout.date;
      }
      currentStreak = tempStreak;
    }

    // Calculate total volume
    final totalVolume = workouts.fold<double>(
      0,
      (sum, w) => sum + (w.totalVolume ?? 0),
    );

    // Get achievements with calculated progress
    return AchievementDefinitions.calculateAchievements(
      totalWorkouts: totalWorkouts,
      currentStreak: currentStreak,
      totalVolume: totalVolume,
    );
  }

  /// Gets newly unlocked achievements since last check.
  ///
  /// [userId] - The ID of the user
  /// [previousAchievements] - Previously saved achievements
  ///
  /// Returns list of newly unlocked [Achievement]s.
  Future<List<Achievement>> getNewlyUnlocked({
    required String userId,
    required List<Achievement> previousAchievements,
  }) async {
    final currentAchievements = await call(userId: userId);
    final newlyUnlocked = <Achievement>[];

    for (final current in currentAchievements) {
      if (!current.isUnlocked) continue;

      final previous = previousAchievements.firstWhere(
        (a) => a.id == current.id,
        orElse: () => current.copyWith(isUnlocked: false),
      );

      if (!previous.isUnlocked && current.isUnlocked) {
        newlyUnlocked.add(current);
      }
    }

    return newlyUnlocked;
  }

  /// Gets achievements that are close to being unlocked (>80% progress).
  ///
  /// [userId] - The ID of the user
  ///
  /// Returns list of [Achievement]s close to unlock.
  Future<List<Achievement>> getAlmostUnlocked({
    required String userId,
  }) async {
    final achievements = await call(userId: userId);

    return achievements
        .where((a) => !a.isUnlocked && a.progress >= 0.8)
        .toList();
  }

  /// Gets unlocked achievements count by type.
  ///
  /// [userId] - The ID of the user
  ///
  /// Returns map of achievement type to count.
  Future<Map<AchievementType, int>> getUnlockedByType({
    required String userId,
  }) async {
    final achievements = await call(userId: userId);
    final counts = <AchievementType, int>{};

    for (final type in AchievementType.values) {
      counts[type] = achievements
          .where((a) => a.type == type && a.isUnlocked)
          .length;
    }

    return counts;
  }
}
