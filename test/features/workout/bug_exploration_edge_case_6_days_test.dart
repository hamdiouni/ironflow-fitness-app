import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:progression_tracker/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/presentation/providers/home_screen_provider.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import '../../mocks/mock_body_repository.dart';
import '../../mocks/mock_workout_repository.dart';

/// Validates the 6-day edge case across real production code:
/// - HomeScreenState
/// - AnalyticsProvider (analyticsStatsProvider)
/// - AnalyticsRepository (AnalyticsRepositoryImpl)
void main() {
  group('Bug Exploration - Edge Case with workoutDaysPerWeek = 6', () {
    test('should use workoutDaysPerWeek=6 for HomeScreenState target and progress', () {
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
        weeklyTarget: 6,
      );

      expect(state.weeklyTarget, equals(6));
      expect(state.weeklyProgressMessage, equals('1 more to hit your goal'));
      expect(state.weeklyProgress, closeTo((5 / 6) * 100, 0.01));
    });

    test('should calculate consistency as 5/6 (83%) in analyticsStatsProvider, not 100%', () async {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      final workouts = [
        _createWorkout(weekStart.add(const Duration(days: 0, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 1, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 2, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 3, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 4, hours: 10))),
      ];
      final profile = _createProfile(workoutDaysPerWeek: 6);

      final container = ProviderContainer(
        overrides: [
          workoutHistoryProvider.overrideWith((ref) => Future.value(workouts)),
          userProfileProvider.overrideWith((ref) => Future.value(profile)),
        ],
      );
      addTearDown(container.dispose);

      final stats = await container.read(analyticsStatsProvider.future);

      // 5 workouts / 6 target days = ~0.8333, NOT 100% (5/5)
      expect(stats.weeklyConsistency, closeTo(5 / 6, 0.001));
      expect(stats.weeklyConsistency, isNot(equals(1.0)));
    });

    test('should calculate adherence as 10/12 (83%) in AnalyticsRepositoryImpl, not 100%', () async {
      final mockWorkoutRepo = MockWorkoutRepository();
      final mockBodyRepo = MockBodyRepository();
      final repo = AnalyticsRepositoryImpl(mockWorkoutRepo, mockBodyRepo);

      final startDate = DateTime(2025, 1, 1);
      final endDate = startDate.add(const Duration(days: 14)); // 2 weeks

      final workouts = List.generate(10, (i) {
        return _createWorkout(startDate.add(Duration(days: i + 1)));
      });
      mockWorkoutRepo.setWorkouts(workouts);

      final profile = _createProfile(workoutDaysPerWeek: 6);

      final metrics = await repo.getConsistencyMetrics(
        userId: 'test_user',
        userProfile: profile,
        startDate: startDate,
        endDate: endDate,
      );

      // 10 workouts / (2 weeks * 6 days) = 10 / 12 = ~0.8333
      expect(metrics.adherenceRate, closeTo(10 / 12, 0.001));
      expect(metrics.adherenceRate, isNot(equals(1.0)));
    });

    test('should demonstrate comprehensive edge case consistency across components', () async {
      const targetDays = 6;
      const completedWorkouts = 5;

      // 1. HomeScreenState
      final homeState = HomeScreenState(
        recentWorkouts: const [],
        weeklyWorkoutCount: completedWorkouts,
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
        weeklyTarget: targetDays,
      );
      expect(homeState.weeklyTarget, equals(6));
      expect(homeState.weeklyProgressMessage, equals('1 more to hit your goal'));

      // 2. Analytics provider
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final workouts = List.generate(completedWorkouts, (i) {
        return _createWorkout(weekStart.add(Duration(days: i, hours: 10)));
      });

      final container = ProviderContainer(
        overrides: [
          workoutHistoryProvider.overrideWith((ref) => Future.value(workouts)),
          userProfileProvider.overrideWith((ref) => Future.value(_createProfile(workoutDaysPerWeek: targetDays))),
        ],
      );
      addTearDown(container.dispose);

      final stats = await container.read(analyticsStatsProvider.future);
      expect(stats.weeklyConsistency, closeTo(5 / 6, 0.001));

      // 3. Analytics repository
      final mockWorkoutRepo = MockWorkoutRepository();
      final mockBodyRepo = MockBodyRepository();
      final repo = AnalyticsRepositoryImpl(mockWorkoutRepo, mockBodyRepo);
      mockWorkoutRepo.setWorkouts(workouts);

      final metrics = await repo.getConsistencyMetrics(
        userId: 'test_user',
        userProfile: _createProfile(workoutDaysPerWeek: targetDays),
        startDate: weekStart,
        endDate: weekStart.add(const Duration(days: 7)),
      );

      expect(metrics.weeklyData.first.workoutsPlanned, equals(6));
      expect(metrics.weeklyData.first.workoutsCompleted, equals(5));
      expect(metrics.adherenceRate, closeTo(5 / 6, 0.001));
    });
  });
}

UserProfile _createProfile({int workoutDaysPerWeek = 5}) {
  return UserProfile(
    goal: FitnessGoal.maintain,
    age: 25,
    weightKg: 70,
    heightCm: 175,
    fitnessLevel: FitnessLevel.intermediate,
    equipment: EquipmentType.gym,
    workoutDaysPerWeek: workoutDaysPerWeek,
    budget: BudgetLevel.medium,
  );
}

Workout _createWorkout(DateTime date) {
  return Workout(
    id: date.toIso8601String(),
    date: date,
    exercises: const [],
    duration: const Duration(minutes: 45),
    totalVolume: 1000,
  );
}
