import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/error/exceptions.dart';
import 'package:progression_tracker/core/utils/validators.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/domain/usecases/workout_metrics.dart';

void main() {
  group('WorkoutMetrics (Wave 2 Domain Rules)', () {
    test('rejects negative and non-finite weights while supporting 0 kg bodyweight sets', () {
      expect(WorkoutMetrics.isValidWeight(0.0), isTrue);
      expect(WorkoutMetrics.isValidWeight(100.0), isTrue);
      expect(WorkoutMetrics.isValidWeight(-0.1), isFalse);
      expect(WorkoutMetrics.isValidWeight(-50.0), isFalse);
      expect(WorkoutMetrics.isValidWeight(double.nan), isFalse);
      expect(WorkoutMetrics.isValidWeight(double.infinity), isFalse);
      expect(WorkoutMetrics.isValidWeight(double.negativeInfinity), isFalse);

      expect(Validators.isValidWeight(0.0), isTrue);
      expect(Validators.isValidWeight(double.infinity), isFalse);
      expect(Validators.isValidWeight(double.nan), isFalse);
      expect(Validators.isValidWeight(-1.0), isFalse);

      expect(
        () => SetEntry.create(reps: 10, weight: -5.0),
        throwsA(isA<InvalidWeightException>()),
      );
      expect(
        () => SetEntry.create(reps: 10, weight: double.infinity),
        throwsA(isA<InvalidWeightException>()),
      );
      expect(
        () => SetEntry.create(reps: 10, weight: double.nan),
        throwsA(isA<InvalidWeightException>()),
      );

      final bodyweightSet = SetEntry.create(reps: 15, weight: 0.0);
      expect(WorkoutMetrics.isValidWorkingSet(bodyweightSet), isTrue);
      expect(WorkoutMetrics.calculateSetVolume(bodyweightSet), equals(0.0));
    });

    test('warm-up sets do not count toward working sets, working volume, or PR eligibility', () {
      final warmup = SetEntry.create(
        reps: 12,
        weight: 100.0,
        type: SetType.warmup,
      );
      final working = SetEntry.create(
        reps: 5,
        weight: 140.0,
        type: SetType.normal,
      );

      expect(WorkoutMetrics.isValidWorkingSet(warmup), isFalse);
      expect(WorkoutMetrics.calculateSetVolume(warmup), equals(0.0));
      expect(WorkoutMetrics.isSetPersonalRecord(warmup, const []), isFalse);

      final workout = Workout(
        id: 'w-warmup-check',
        date: DateTime(2026, 10, 28),
        duration: const Duration(minutes: 30),
        totalVolume: 0,
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Barbell Squat',
            type: ExerciseType.strength,
            sets: [warmup, working],
          ),
        ],
      );

      expect(WorkoutMetrics.workingSetCount(workout), equals(1));
      expect(WorkoutMetrics.calculateWorkoutVolume(workout), equals(700.0));
    });

    test('50 kg x 15 does not beat 140 kg x 5 merely due to reps', () {
      final heavyHistory = [
        Exercise(
          id: 'ex-hist',
          name: 'Deadlift',
          type: ExerciseType.strength,
          sets: [
            SetEntry.create(reps: 5, weight: 140.0, type: SetType.normal),
          ],
        ),
      ];

      final lightHighRepSet = SetEntry.create(
        reps: 15,
        weight: 50.0,
        type: SetType.normal,
      );

      expect(
        WorkoutMetrics.calculateEstimated1RM(140.0, 5),
        closeTo(163.33, 0.05),
      );
      expect(
        WorkoutMetrics.calculateEstimated1RM(50.0, 15),
        closeTo(66.67, 0.05),
      );
      expect(
        WorkoutMetrics.isSetPersonalRecord(lightHighRepSet, heavyHistory),
        isFalse,
      );
    });

    test('zero-working-set workouts are detected as having no working sets', () {
      final emptyWorkout = Workout(
        id: 'w-empty',
        date: DateTime(2026, 10, 28),
        duration: Duration.zero,
        totalVolume: 0,
        exercises: const [],
      );
      final warmupOnlyWorkout = Workout(
        id: 'w-warmup-only',
        date: DateTime(2026, 10, 28),
        duration: const Duration(minutes: 10),
        totalVolume: 0,
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [
              SetEntry.create(reps: 10, weight: 40.0, type: SetType.warmup),
            ],
          ),
        ],
      );
      final bodyweightWorkingWorkout = Workout(
        id: 'w-bodyweight',
        date: DateTime(2026, 10, 28),
        duration: const Duration(minutes: 15),
        totalVolume: 0,
        exercises: [
          Exercise(
            id: 'ex-pullup',
            name: 'Pull Up',
            type: ExerciseType.strength,
            sets: [
              SetEntry.create(reps: 12, weight: 0.0, type: SetType.normal),
            ],
          ),
        ],
      );

      expect(WorkoutMetrics.hasWorkingSets(emptyWorkout), isFalse);
      expect(WorkoutMetrics.hasWorkingSets(warmupOnlyWorkout), isFalse);
      expect(WorkoutMetrics.hasWorkingSets(bodyweightWorkingWorkout), isTrue);
    });

    test('converts accurately between kg and lb and rejects invalid inputs', () {
      final pounds = WorkoutMetrics.kgToLb(100.0);
      expect(pounds, closeTo(220.462, 0.01));
      expect(WorkoutMetrics.lbToKg(pounds), closeTo(100.0, 0.001));

      expect(WorkoutMetrics.fromCanonicalKg(80.0, WeightUnit.kg), equals(80.0));
      expect(
        WorkoutMetrics.fromCanonicalKg(80.0, WeightUnit.lb),
        closeTo(176.37, 0.05),
      );
      expect(
        WorkoutMetrics.toCanonicalKg(225.0, WeightUnit.lb),
        closeTo(102.058, 0.01),
      );
      expect(WorkoutMetrics.toCanonicalKg(-10.0, WeightUnit.kg), isNull);
      expect(WorkoutMetrics.toCanonicalKg(double.nan, WeightUnit.lb), isNull);
      expect(
        WorkoutMetrics.toCanonicalKg(double.infinity, WeightUnit.lb),
        isNull,
      );
    });
  });
}

