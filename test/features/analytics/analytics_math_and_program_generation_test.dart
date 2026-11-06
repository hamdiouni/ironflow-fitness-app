import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:progression_tracker/features/analytics/domain/entities/performance_prediction.dart';
import 'package:progression_tracker/features/analytics/domain/usecases/get_consistency_metrics_use_case.dart';
import 'package:progression_tracker/features/analytics/domain/usecases/get_strength_progression_use_case.dart';
import 'package:progression_tracker/features/analytics/domain/usecases/get_weight_tracking_use_case.dart';
import 'package:progression_tracker/features/analytics/domain/usecases/predict_performance_use_case.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_type.dart';
import 'package:progression_tracker/features/workout/domain/entities/set_entry.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/usecases/workout_metrics.dart';

class InMemoryAnalyticsWorkoutRepo implements WorkoutRepository {
  final List<Workout> workouts = [];

  @override
  Future<List<Workout>> getWorkoutsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return workouts
        .where((w) => !w.date.isBefore(start) && !w.date.isAfter(end))
        .toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class InMemoryAnalyticsBodyRepo implements BodyRepository {
  final List<BodyEntry> entries = [];

  @override
  Future<List<BodyEntry>> getBodyEntriesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return entries
        .where((e) => !e.date.isBefore(start) && !e.date.isAfter(end))
        .toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Wave 2.1 — Analytics Math & WorkoutMetrics Characterization', () {
    late InMemoryAnalyticsWorkoutRepo workoutRepo;
    late InMemoryAnalyticsBodyRepo bodyRepo;
    late AnalyticsRepositoryImpl analyticsRepo;

    setUp(() {
      workoutRepo = InMemoryAnalyticsWorkoutRepo();
      bodyRepo = InMemoryAnalyticsBodyRepo();
      analyticsRepo = AnalyticsRepositoryImpl(workoutRepo, bodyRepo);
    });

    test('WorkoutMetrics enforces warm-up exclusion, 10-rep 1RM cap (50x15 < 140x5), 0kg bodyweight sets, and kg/lb math', () {
      final now = DateTime.utc(2026, 4, 15, 10, 0);
      final warmup = SetEntry(
        id: 'w1',
        reps: 10,
        weight: 100.0,
        timestamp: now,
        type: SetType.warmup,
      );
      final workingHeavy = SetEntry(
        id: 's1',
        reps: 5,
        weight: 140.0,
        timestamp: now,
        type: SetType.normal,
      );
      final workingLightHighRep = SetEntry(
        id: 's2',
        reps: 15,
        weight: 50.0,
        timestamp: now,
        type: SetType.normal,
      );
      final bodyweightSet = SetEntry(
        id: 's3',
        reps: 12,
        weight: 0.0,
        timestamp: now,
        type: SetType.normal,
      );
      final invalidNegative = SetEntry(
        id: 's4',
        reps: 8,
        weight: -20.0,
        timestamp: now,
        type: SetType.normal,
      );

      // Warm-ups and negative weights contribute 0 working volume
      expect(WorkoutMetrics.calculateSetVolume(warmup), 0.0);
      expect(WorkoutMetrics.calculateSetVolume(invalidNegative), 0.0);
      expect(WorkoutMetrics.calculateSetVolume(workingHeavy), 700.0);
      expect(WorkoutMetrics.isValidWorkingSet(bodyweightSet), isTrue);

      // 50 kg x 15 must NOT beat 140 kg x 5 in 1RM or PR evaluation
      final e1rmHeavy = WorkoutMetrics.calculateEstimated1RM(140.0, 5);
      final e1rmLight = WorkoutMetrics.calculateEstimated1RM(50.0, 15);
      expect(e1rmHeavy, greaterThan(e1rmLight));

      final history = [
        Exercise(
          id: 'ex_hist',
          name: 'Barbell Squat',
          type: ExerciseType.strength,
          sets: [workingHeavy],
        ),
      ];
      expect(
        WorkoutMetrics.isSetPersonalRecord(workingLightHighRep, history),
        isFalse,
      );

      // Zero-working-set workout is rejected
      final warmupOnlyWorkout = Workout(
        id: 'wo_warmup',
        date: now,
        exercises: [
          Exercise(
            id: 'e1',
            name: 'Squat',
            type: ExerciseType.strength,
            sets: [warmup],
          ),
        ],
        duration: const Duration(minutes: 20),
        totalVolume: 0,
      );
      expect(WorkoutMetrics.hasWorkingSets(warmupOnlyWorkout), isFalse);
    });

    test('GetStrengthProgressionUseCase and PredictPerformanceUseCase compute Epley 1RM series, percentage change, and trend predictions', () async {
      final baseDate = DateTime.now().subtract(const Duration(days: 30));

      for (int i = 0; i < 5; i++) {
        final date = baseDate.add(Duration(days: i * 5));
        final weight = 100.0 + (i * 5.0); // 100, 105, 110, 115, 120 kg
        workoutRepo.workouts.add(
          Workout(
            id: 'w_$i',
            date: date,
            exercises: [
              Exercise(
                id: 'inst_$i',
                exerciseDefinitionId: 'barbell_bench_press',
                name: 'Barbell Bench Press',
                type: ExerciseType.strength,
                sets: [
                  SetEntry(
                    id: 's_$i',
                    reps: 5,
                    weight: weight,
                    timestamp: date,
                  ),
                ],
              ),
            ],
            duration: const Duration(minutes: 45),
            totalVolume: weight * 5,
          ),
        );
      }

      final strengthUseCase = GetStrengthProgressionUseCase(analyticsRepo);
      final progression = await strengthUseCase(
        exerciseId: 'barbell_bench_press',
        startDate: baseDate.subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 1)),
      );

      expect(progression.dataPoints.length, 5);
      expect(progression.currentOneRepMax, closeTo(120.0 * (1 + 5 / 30), 0.01));
      expect(progression.percentageChange, greaterThan(0));

      final predictUseCase = PredictPerformanceUseCase(analyticsRepo);
      final prediction = await predictUseCase(
        userId: 'u_analytics',
        predictionDays: 30,
      );

      expect(prediction.exercisePredictions, isNotEmpty);
      expect(prediction.confidenceLevel, greaterThanOrEqualTo(0.3));
      expect(
        prediction.overallStrength.trend,
        isA<PredictionTrend>(),
      );
    });

    test('GetWeightTrackingUseCase and GetConsistencyMetricsUseCase compute streaks, adherence, and weekly rate', () async {
      final start = DateTime.utc(2026, 4, 1);
      final end = DateTime.utc(2026, 4, 15);

      bodyRepo.entries.addAll([
        BodyEntry(
          id: 'b1',
          date: DateTime.utc(2026, 4, 1),
          weight: 84.0,
          measurements: const {},
        ),
        BodyEntry(
          id: 'b2',
          date: DateTime.utc(2026, 4, 14),
          weight: 82.0,
          measurements: const {},
        ),
      ]);

      // 3 consecutive days of workouts -> longestStreak = 3
      for (int d = 2; d <= 4; d++) {
        workoutRepo.workouts.add(
          Workout(
            id: 'wc_$d',
            date: DateTime.utc(2026, 4, d, 12),
            exercises: const [],
            duration: const Duration(minutes: 60),
            totalVolume: 5000,
          ),
        );
      }

      final weightUseCase = GetWeightTrackingUseCase(analyticsRepo);
      final weightTracking = await weightUseCase(
        userId: 'u1',
        startDate: start,
        endDate: end,
      );
      expect(weightTracking.startingWeight, 84.0);
      expect(weightTracking.currentWeight, 82.0);
      expect(weightTracking.totalChange, -2.0);
      expect(weightTracking.averageWeeklyChange, -1.0);

      final consistencyUseCase = GetConsistencyMetricsUseCase(analyticsRepo);
      const profile = UserProfile(
        goal: FitnessGoal.gainMuscle,
        age: 28,
        weightKg: 82.0,
        heightCm: 180.0,
        fitnessLevel: FitnessLevel.intermediate,
        equipment: EquipmentType.gym,
        workoutDaysPerWeek: 3,
        budget: BudgetLevel.medium,
      );
      final consistency = await consistencyUseCase(
        userId: 'u1',
        userProfile: profile,
        startDate: start,
        endDate: end,
      );

      expect(consistency.totalWorkouts, 3);
      expect(consistency.longestStreak, 3);
      expect(consistency.averageDuration, 60.0);
      expect(consistency.adherenceRate, closeTo(0.5, 0.01));
    });
  });
}
