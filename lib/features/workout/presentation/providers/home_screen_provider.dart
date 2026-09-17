import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nutrition/presentation/providers/nutrition_providers.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../domain/entities/workout.dart';
import 'active_program_providers.dart';
import 'home_workout_provider.dart';

/// Home screen state containing all data needed for display
class HomeScreenState {
  final List<Workout> recentWorkouts;
  final int weeklyWorkoutCount;
  final String? todayWorkoutName;
  final int? todayExerciseCount;
  final double? todayCaloriesConsumed;
  final double? todayCaloriesTarget;
  final double? todayProteinConsumed;
  final double? todayProteinTarget;
  final double? todayCarbsConsumed;
  final double? todayCarbsTarget;
  final double? todayFatsConsumed;
  final double? todayFatsTarget;
  final String? lastWorkoutDate;
  final double? userWeight;
  final bool hasActiveProgram;

  const HomeScreenState({
    required this.recentWorkouts,
    required this.weeklyWorkoutCount,
    required this.todayWorkoutName,
    required this.todayExerciseCount,
    required this.todayCaloriesConsumed,
    required this.todayCaloriesTarget,
    required this.todayProteinConsumed,
    required this.todayProteinTarget,
    required this.todayCarbsConsumed,
    required this.todayCarbsTarget,
    required this.todayFatsConsumed,
    required this.todayFatsTarget,
    required this.lastWorkoutDate,
    required this.userWeight,
    required this.hasActiveProgram,
    required this.weeklyTarget,
  });

  final int? weeklyTarget;

  /// Calculate weekly progress percentage (0-100)
  double get weeklyProgress {
    final target = weeklyTarget ?? 4;
    return ((weeklyWorkoutCount / target) * 100).clamp(0, 100);
  }

  /// Get weekly progress message
  String get weeklyProgressMessage {
    final target = weeklyTarget ?? 4;
    if (weeklyWorkoutCount == 0) {
      return 'Start your first workout!';
    } else if (weeklyWorkoutCount < target) {
      return '${target - weeklyWorkoutCount} more to hit your goal';
    } else {
      return '🎉 Weekly goal achieved!';
    }
  }

  /// Calculate calorie progress percentage (0-100)
  double get calorieProgress {
    if (todayCaloriesTarget == null || todayCaloriesTarget! <= 0) return 0;
    return ((todayCaloriesConsumed ?? 0) / todayCaloriesTarget! * 100).clamp(0, 100);
  }

  /// Calculate protein progress percentage (0-100)
  double get proteinProgress {
    if (todayProteinTarget == null || todayProteinTarget! <= 0) return 0;
    return ((todayProteinConsumed ?? 0) / todayProteinTarget! * 100).clamp(0, 100);
  }

  /// Calculate carbs progress percentage (0-100)
  double get carbsProgress {
    if (todayCarbsTarget == null || todayCarbsTarget! <= 0) return 0;
    return ((todayCarbsConsumed ?? 0) / todayCarbsTarget! * 100).clamp(0, 100);
  }

  /// Calculate fats progress percentage (0-100)
  double get fatsProgress {
    if (todayFatsTarget == null || todayFatsTarget! <= 0) return 0;
    return ((todayFatsConsumed ?? 0) / todayFatsTarget! * 100).clamp(0, 100);
  }

  /// Get today's workout summary text
  String get todayWorkoutSummary {
    if (todayWorkoutName == null) return 'No workout scheduled';
    if (todayExerciseCount == null) return todayWorkoutName!;
    return '$todayWorkoutName - $todayExerciseCount exercises';
  }
}

/// StateNotifier for home screen data
class HomeScreenNotifier extends StateNotifier<AsyncValue<HomeScreenState>> {
  HomeScreenNotifier(this._ref) : super(const AsyncValue.loading()) {
    _loadData();
  }

  final Ref _ref;

  /// Load all data for home screen
  Future<void> _loadData() async {
    state = const AsyncValue.loading();
    
    try {
      // Load all data in parallel
      final results = await Future.wait([
        _ref.read(homeWorkoutDataProvider.future),
        _ref.read(userProfileProvider.future),
        _ref.read(activeProgramProvider.future),
        _ref.read(dailyNutritionSummaryProvider(DateTime.now()).future),
      ]);

      final workouts = results[0] as List<Workout>;
      final profile = results[1];
      final activeProgram = results[2];
      final nutritionSummary = results[3];

      // Calculate weekly workout count
      final now = DateTime.now();
      final weekStart = now.subtract(const Duration(days: 6));
      final weekWorkouts = workouts.where((w) => w.date.isAfter(weekStart)).toList();

      // Get today's workout info from active program
      String? todayWorkoutName;
      int? todayExerciseCount;
      if (activeProgram != null) {
        final currentDay = activeProgram.currentDay;
        todayWorkoutName = currentDay.name;
        todayExerciseCount = currentDay.exercises.length;
      }

      // Get nutrition data
      final nutritionData = nutritionSummary;
      final caloriesConsumed = nutritionData.totalCalories;
      final proteinConsumed = nutritionData.totalProtein;
      final carbsConsumed = nutritionData.totalCarbs;
      final fatsConsumed = nutritionData.totalFats;

      // Get targets from profile
      final caloriesTarget = profile?.dailyCalorieTarget;
      final proteinTarget = profile?.dailyProteinTarget;
      final carbsTarget = profile?.dailyCarbsTarget;
      final fatsTarget = profile?.dailyFatsTarget;

      // Get last workout date
      String? lastWorkoutDate;
      if (workouts.isNotEmpty) {
        final lastWorkout = workouts.first;
        final daysSince = now.difference(lastWorkout.date).inDays;
        if (daysSince == 0) {
          lastWorkoutDate = 'Today';
        } else if (daysSince == 1) {
          lastWorkoutDate = 'Yesterday';
        } else {
          lastWorkoutDate = '$daysSince days ago';
        }
      }

      // Get user weight
      final userWeight = profile?.weightKg;

      // Check if has active program
      final hasActiveProgram = activeProgram != null && activeProgram.isActive;

      // Get weekly target from profile
      final weeklyTarget = profile?.workoutDaysPerWeek;

      state = AsyncValue.data(HomeScreenState(
        recentWorkouts: workouts,
        weeklyWorkoutCount: weekWorkouts.length,
        todayWorkoutName: todayWorkoutName,
        todayExerciseCount: todayExerciseCount,
        todayCaloriesConsumed: caloriesConsumed,
        todayCaloriesTarget: caloriesTarget,
        todayProteinConsumed: proteinConsumed,
        todayProteinTarget: proteinTarget,
        todayCarbsConsumed: carbsConsumed,
        todayCarbsTarget: carbsTarget,
        todayFatsConsumed: fatsConsumed,
        todayFatsTarget: fatsTarget,
        lastWorkoutDate: lastWorkoutDate,
        userWeight: userWeight,
        hasActiveProgram: hasActiveProgram,
        weeklyTarget: weeklyTarget,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    // Invalidate all providers
    _ref.invalidate(homeWorkoutDataProvider);
    _ref.invalidate(userProfileProvider);
    _ref.invalidate(activeProgramProvider);
    _ref.invalidate(dailyNutritionSummaryProvider(DateTime.now()));
    
    // Reload data
    await _loadData();
  }
}

/// Provider for home screen state
final homeScreenProvider = StateNotifierProvider<HomeScreenNotifier, AsyncValue<HomeScreenState>>((ref) {
  return HomeScreenNotifier(ref);
});
