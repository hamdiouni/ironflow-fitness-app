import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/workout/presentation/providers/home_screen_provider.dart';

/// Validates that HomeScreenState dynamically reflects the user's weeklyTarget
/// and calculates progress messages without assuming a hardcoded target.
void main() {
  group('Home Screen State Dynamic Target Tests', () {
    test('uses userProfile.workoutDaysPerWeek (3) as weekly target', () {
      final state = HomeScreenState(
        recentWorkouts: const [],
        weeklyWorkoutCount: 2,
        todayWorkoutName: null,
        todayExerciseCount: null,
        todayCaloriesConsumed: null,
        todayCaloriesTarget: null,
        todayProteinConsumed: null,
        todayProteinTarget: null,
        todayCarbsConsumed: null,
        todayCarbsTarget: null,
        todayFatsConsumed: null,
        todayFatsTarget: null,
        lastWorkoutDate: null,
        userWeight: null,
        hasActiveProgram: false,
        weeklyTarget: 3,
      );

      expect(state.weeklyTarget, equals(3));
      expect(state.weeklyProgressMessage, equals('1 more to hit your goal'));
      expect(state.weeklyProgress, closeTo((2 / 3) * 100, 0.01));
    });

    test('uses userProfile.workoutDaysPerWeek (6) as weekly target', () {
      final state = HomeScreenState(
        recentWorkouts: const [],
        weeklyWorkoutCount: 4,
        todayWorkoutName: null,
        todayExerciseCount: null,
        todayCaloriesConsumed: null,
        todayCaloriesTarget: null,
        todayProteinConsumed: null,
        todayProteinTarget: null,
        todayCarbsConsumed: null,
        todayCarbsTarget: null,
        todayFatsConsumed: null,
        todayFatsTarget: null,
        lastWorkoutDate: null,
        userWeight: null,
        hasActiveProgram: false,
        weeklyTarget: 6,
      );

      expect(state.weeklyTarget, equals(6));
      expect(state.weeklyProgressMessage, equals('2 more to hit your goal'));
      expect(state.weeklyProgress, closeTo((4 / 6) * 100, 0.01));
    });

    test('shows goal achieved when completed workouts reach weekly target', () {
      final state = HomeScreenState(
        recentWorkouts: const [],
        weeklyWorkoutCount: 5,
        todayWorkoutName: null,
        todayExerciseCount: null,
        todayCaloriesConsumed: null,
        todayCaloriesTarget: null,
        todayProteinConsumed: null,
        todayProteinTarget: null,
        todayCarbsConsumed: null,
        todayCarbsTarget: null,
        todayFatsConsumed: null,
        todayFatsTarget: null,
        lastWorkoutDate: null,
        userWeight: null,
        hasActiveProgram: false,
        weeklyTarget: 5,
      );

      expect(state.weeklyProgressMessage, equals('🎉 Weekly goal achieved!'));
      expect(state.weeklyProgress, equals(100.0));
    });

    test('handles null weeklyTarget safely without crashing', () {
      final state = HomeScreenState(
        recentWorkouts: const [],
        weeklyWorkoutCount: 2,
        todayWorkoutName: null,
        todayExerciseCount: null,
        todayCaloriesConsumed: null,
        todayCaloriesTarget: null,
        todayProteinConsumed: null,
        todayProteinTarget: null,
        todayCarbsConsumed: null,
        todayCarbsTarget: null,
        todayFatsConsumed: null,
        todayFatsTarget: null,
        lastWorkoutDate: null,
        userWeight: null,
        hasActiveProgram: false,
        weeklyTarget: null,
      );

      expect(state.weeklyTarget, isNull);
      expect(state.weeklyProgressMessage, isNotEmpty);
      expect(state.weeklyProgress, isNotNull);
    });
  });
}
