import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';

/// Validates that analyticsStatsProvider dynamically uses userProfile.workoutDaysPerWeek
/// instead of any hardcoded divisor.
void main() {
  group('Analytics Provider Dynamic Divisor Tests', () {
    test('should use userProfile.workoutDaysPerWeek (6) as divisor instead of hardcoded 5', () async {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      final workouts = [
        _createWorkout(weekStart.add(const Duration(days: 0, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 1, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 2, hours: 10))),
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

      // 4 workouts / 6 target days = ~0.6667 (not 4 / 5 = 0.80)
      expect(stats.weeklyConsistency, closeTo(4 / 6, 0.001));
      expect(stats.weeklyConsistency, isNot(closeTo(4 / 5, 0.001)));
    });

    test('should use userProfile.workoutDaysPerWeek (3) as divisor instead of hardcoded 5', () async {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      final workouts = [
        _createWorkout(weekStart.add(const Duration(days: 0, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 2, hours: 10))),
      ];
      final profile = _createProfile(workoutDaysPerWeek: 3);

      final container = ProviderContainer(
        overrides: [
          workoutHistoryProvider.overrideWith((ref) => Future.value(workouts)),
          userProfileProvider.overrideWith((ref) => Future.value(profile)),
        ],
      );
      addTearDown(container.dispose);

      final stats = await container.read(analyticsStatsProvider.future);

      // 2 workouts / 3 target days = ~0.6667 (not 2 / 5 = 0.40)
      expect(stats.weeklyConsistency, closeTo(2 / 3, 0.001));
      expect(stats.weeklyConsistency, isNot(closeTo(2 / 5, 0.001)));
    });

    test('should correctly compute consistency when target is 5 days', () async {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      final workouts = [
        _createWorkout(weekStart.add(const Duration(days: 0, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 1, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 3, hours: 10))),
      ];
      final profile = _createProfile(workoutDaysPerWeek: 5);

      final container = ProviderContainer(
        overrides: [
          workoutHistoryProvider.overrideWith((ref) => Future.value(workouts)),
          userProfileProvider.overrideWith((ref) => Future.value(profile)),
        ],
      );
      addTearDown(container.dispose);

      final stats = await container.read(analyticsStatsProvider.future);

      // 3 workouts / 5 target days = 0.60
      expect(stats.weeklyConsistency, closeTo(3 / 5, 0.001));
    });

    test('should verify 6-day edge case with 6 completed workouts hits 100%', () async {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      final workouts = [
        _createWorkout(weekStart.add(const Duration(days: 0, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 1, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 2, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 3, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 4, hours: 10))),
        _createWorkout(weekStart.add(const Duration(days: 5, hours: 10))),
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

      expect(stats.weeklyConsistency, equals(1.0));
    });

    test('should handle null profile gracefully without throwing', () async {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      final workouts = [
        _createWorkout(weekStart.add(const Duration(days: 0, hours: 10))),
      ];

      final container = ProviderContainer(
        overrides: [
          workoutHistoryProvider.overrideWith((ref) => Future.value(workouts)),
          userProfileProvider.overrideWith((ref) => Future.value(null)),
        ],
      );
      addTearDown(container.dispose);

      final stats = await container.read(analyticsStatsProvider.future);

      expect(stats.weeklyConsistency, inInclusiveRange(0.0, 1.0));
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
