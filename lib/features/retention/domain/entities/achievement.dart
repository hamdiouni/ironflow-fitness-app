import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement.freezed.dart';
part 'achievement.g.dart';

/// Represents a user achievement/badge.
@freezed
class Achievement with _$Achievement {
  const factory Achievement({
    /// Unique identifier for the achievement
    required String id,

    /// Display name of the achievement
    required String name,

    /// Description of what was achieved
    required String description,

    /// Icon emoji or name
    required String icon,

    /// Threshold value to unlock (e.g., 7 for 7 workouts)
    required int threshold,

    /// Type of achievement (workouts, streak, volume, etc.)
    required AchievementType type,

    /// Whether the user has unlocked this achievement
    required bool isUnlocked,

    /// Date when the achievement was unlocked
    DateTime? unlockedDate,

    /// Progress towards unlocking (0.0 to 1.0)
    required double progress,
  }) = _Achievement;

  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
}

/// Types of achievements available.
enum AchievementType {
  workouts,
  streak,
  volume,
  consistency,
  personalRecord,
}

/// Predefined achievements.
class AchievementDefinitions {
  static const List<Achievement> all = [
    // Workout achievements
    Achievement(
      id: 'first_workout',
      name: 'First Step',
      description: 'Complete your first workout',
      icon: '🏋️',
      threshold: 1,
      type: AchievementType.workouts,
      isUnlocked: false,
      progress: 0.0,
    ),
    Achievement(
      id: 'seven_workouts',
      name: 'Week Warrior',
      description: 'Complete 7 workouts',
      icon: '💪',
      threshold: 7,
      type: AchievementType.workouts,
      isUnlocked: false,
      progress: 0.0,
    ),
    Achievement(
      id: 'thirty_workouts',
      name: 'Consistency King',
      description: 'Complete 30 workouts',
      icon: '👑',
      threshold: 30,
      type: AchievementType.workouts,
      isUnlocked: false,
      progress: 0.0,
    ),
    Achievement(
      id: 'hundred_workouts',
      name: 'Century Club',
      description: 'Complete 100 workouts',
      icon: '🎯',
      threshold: 100,
      type: AchievementType.workouts,
      isUnlocked: false,
      progress: 0.0,
    ),

    // Streak achievements
    Achievement(
      id: 'three_day_streak',
      name: 'On Fire',
      description: 'Maintain a 3-day workout streak',
      icon: '🔥',
      threshold: 3,
      type: AchievementType.streak,
      isUnlocked: false,
      progress: 0.0,
    ),
    Achievement(
      id: 'seven_day_streak',
      name: 'Week on Fire',
      description: 'Maintain a 7-day workout streak',
      icon: '🔥🔥',
      threshold: 7,
      type: AchievementType.streak,
      isUnlocked: false,
      progress: 0.0,
    ),
    Achievement(
      id: 'thirty_day_streak',
      name: 'Unstoppable',
      description: 'Maintain a 30-day workout streak',
      icon: '⚡',
      threshold: 30,
      type: AchievementType.streak,
      isUnlocked: false,
      progress: 0.0,
    ),

    // Volume achievements
    Achievement(
      id: 'ten_thousand_kg',
      name: 'Heavy Lifter',
      description: 'Lift 10,000 kg total volume',
      icon: '⚙️',
      threshold: 10000,
      type: AchievementType.volume,
      isUnlocked: false,
      progress: 0.0,
    ),
    Achievement(
      id: 'hundred_thousand_kg',
      name: 'Titan',
      description: 'Lift 100,000 kg total volume',
      icon: '🗿',
      threshold: 100000,
      type: AchievementType.volume,
      isUnlocked: false,
      progress: 0.0,
    ),
  ];

  /// Gets all achievements for a user based on their stats.
  static List<Achievement> calculateAchievements({
    required int totalWorkouts,
    required int currentStreak,
    required double totalVolume,
  }) {
    return all.map((achievement) {
      bool isUnlocked = false;
      double progress = 0.0;

      switch (achievement.type) {
        case AchievementType.workouts:
          progress = (totalWorkouts / achievement.threshold).clamp(0.0, 1.0);
          isUnlocked = totalWorkouts >= achievement.threshold;
          break;
        case AchievementType.streak:
          progress = (currentStreak / achievement.threshold).clamp(0.0, 1.0);
          isUnlocked = currentStreak >= achievement.threshold;
          break;
        case AchievementType.volume:
          progress = (totalVolume / achievement.threshold).clamp(0.0, 1.0);
          isUnlocked = totalVolume >= achievement.threshold;
          break;
        default:
          progress = 0.0;
      }

      return achievement.copyWith(
        isUnlocked: isUnlocked,
        progress: progress,
        unlockedDate: isUnlocked ? DateTime.now() : null,
      );
    }).toList();
  }
}
