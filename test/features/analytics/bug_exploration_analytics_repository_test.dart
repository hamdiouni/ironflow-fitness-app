import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import '../../mocks/mock_body_repository.dart';
import '../../mocks/mock_workout_repository.dart';

/// Validates that AnalyticsRepositoryImpl dynamically uses userProfile.workoutDaysPerWeek
/// for calculating adherenceRate and planned weekly workouts.
void main() {
  group('Analytics Repository Dynamic Multiplier Tests', () {
    late MockWorkoutRepository mockWorkoutRepository;
    late MockBodyRepository mockBodyRepository;
    late AnalyticsRepositoryImpl repository;

    setUp(() {
      mockWorkoutRepository = MockWorkoutRepository();
      mockBodyRepository = MockBodyRepository();
      repository = AnalyticsRepositoryImpl(mockWorkoutRepository, mockBodyRepository);
    });

    test('should use userProfile.workoutDaysPerWeek (3) as multiplier instead of hardcoded 5', () async {
      final startDate = DateTime(2025, 1, 1);
      final endDate = startDate.add(const Duration(days: 28)); // 4 weeks

      // 9 workouts over 4 weeks
      final workouts = List.generate(9, (index) {
        return _createWorkout(startDate.add(Duration(days: index * 3 + 1)));
      });
      mockWorkoutRepository.setWorkouts(workouts);

      final profile = _createProfile(workoutDaysPerWeek: 3);

      final metrics = await repository.getConsistencyMetrics(
        userId: 'test_user',
        userProfile: profile,
        startDate: startDate,
        endDate: endDate,
      );

      // 4 weeks * 3 days/week = 12 target workouts
      // 9 / 12 = 0.75 (75%), NOT 9 / (4 * 5) = 0.45 (45%)
      expect(metrics.adherenceRate, closeTo(0.75, 0.001));
      expect(metrics.adherenceRate, isNot(closeTo(0.45, 0.001)));
    });

    test('should verify edge case with workoutDaysPerWeek=6 over 2 weeks', () async {
      final startDate = DateTime(2025, 1, 1);
      final endDate = startDate.add(const Duration(days: 14)); // 2 weeks

      // 10 workouts over 2 weeks
      final workouts = List.generate(10, (index) {
        return _createWorkout(startDate.add(Duration(days: index + 1)));
      });
      mockWorkoutRepository.setWorkouts(workouts);

      final profile = _createProfile(workoutDaysPerWeek: 6);

      final metrics = await repository.getConsistencyMetrics(
        userId: 'test_user',
        userProfile: profile,
        startDate: startDate,
        endDate: endDate,
      );

      // 2 weeks * 6 days = 12 target workouts
      // 10 / 12 = ~0.8333, NOT 10 / (2 * 5) = 1.0 (clamped)
      expect(metrics.adherenceRate, closeTo(10 / 12, 0.001));
      expect(metrics.adherenceRate, isNot(equals(1.0)));
    });

    test('should verify that valid profile with workoutDaysPerWeek=5 works correctly', () async {
      final startDate = DateTime(2025, 1, 1);
      final endDate = startDate.add(const Duration(days: 21)); // 3 weeks

      // 15 workouts over 3 weeks
      final workouts = List.generate(15, (index) {
        return _createWorkout(startDate.add(Duration(days: index + 1)));
      });
      mockWorkoutRepository.setWorkouts(workouts);

      final profile = _createProfile(workoutDaysPerWeek: 5);

      final metrics = await repository.getConsistencyMetrics(
        userId: 'test_user',
        userProfile: profile,
        startDate: startDate,
        endDate: endDate,
      );

      // 15 / (3 * 5) = 1.0
      expect(metrics.adherenceRate, equals(1.0));
    });

    test('should verify weekly workoutsPlanned field uses userProfile.workoutDaysPerWeek', () async {
      final startDate = DateTime(2025, 1, 1);
      final endDate = startDate.add(const Duration(days: 7)); // 1 week

      final profile = _createProfile(workoutDaysPerWeek: 6);
      mockWorkoutRepository.setWorkouts([]);

      final metrics = await repository.getConsistencyMetrics(
        userId: 'test_user',
        userProfile: profile,
        startDate: startDate,
        endDate: endDate,
      );

      expect(metrics.weeklyData.isNotEmpty, isTrue);
      expect(metrics.weeklyData.first.workoutsPlanned, equals(6));
    });

    test('should handle null profile gracefully with fallback divisor 1', () async {
      final startDate = DateTime(2025, 1, 1);
      final endDate = startDate.add(const Duration(days: 7));

      final metrics = await repository.getConsistencyMetrics(
        userId: 'test_user',
        userProfile: null,
        startDate: startDate,
        endDate: endDate,
      );

      expect(metrics.weeklyData.first.workoutsPlanned, equals(1));
      expect(metrics.adherenceRate, inInclusiveRange(0.0, 1.0));
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
