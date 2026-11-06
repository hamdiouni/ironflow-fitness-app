import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/body/domain/entities/muscle_recovery_status.dart';
import 'package:progression_tracker/features/body/domain/entities/muscle_region.dart';
import 'package:progression_tracker/features/body/domain/services/muscle_recovery_calculator.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_type.dart';
import 'package:progression_tracker/features/workout/domain/entities/set_entry.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';

void main() {
  const calculator = MuscleRecoveryCalculator();
  final now = DateTime(2026, 11, 6, 20, 0, 0);

  group('MuscleRecoveryCalculator Tests', () {
    test('empty workouts history returns 100% readiness across all 20 regions', () {
      final result = calculator.calculate(
        workouts: const [],
        referenceNow: now,
      );

      expect(result.length, 20);
      for (final region in MuscleRegion.values) {
        final data = result[region];
        expect(data, isNotNull);
        expect(data!.score, 1.0);
        expect(data.tier, RecoveryTier.fresh);
        expect(data.hoursSinceTrained, isNull);
        expect(data.estimatedHoursRemaining, 0.0);
        expect(data.sets7Days, 0);
        expect(data.volumeLoad7Days, 0.0);
        expect(data.isManuallyMarkedSore, isFalse);
      }
    });

    test('recent heavy chest workout yields fatigued tier and accumulates volume', () {
      final recentWorkout = Workout(
        id: 'w-recent-1',
        date: now.subtract(const Duration(hours: 4)),
        duration: const Duration(minutes: 60),
        totalVolume: 4000.0,
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Barbell Bench Press',
            type: ExerciseType.strength,
            exerciseDefinitionId: 'chest_001',
            sets: [
              SetEntry.create(
                reps: 10,
                weight: 100.0,
                type: SetType.normal,
              ),
              SetEntry.create(
                reps: 10,
                weight: 100.0,
                type: SetType.normal,
              ),
              SetEntry.create(
                reps: 10,
                weight: 100.0,
                type: SetType.normal,
              ),
              SetEntry.create(
                reps: 10,
                weight: 100.0,
                type: SetType.normal,
              ),
            ],
          ),
        ],
      );

      final result = calculator.calculate(
        workouts: [recentWorkout],
        referenceNow: now,
      );

      final chest = result[MuscleRegion.chest]!;
      expect(chest.hoursSinceTrained, 4.0);
      expect(chest.sets7Days, 4);
      expect(chest.volumeLoad7Days, 4000.0);
      expect(chest.tier, RecoveryTier.fatigued);
      expect(chest.score, lessThan(0.40));
      expect(chest.estimatedHoursRemaining, greaterThan(20.0));
    });

    test('manual soreness flag forces tier to sore and limits recovery score', () {
      final result = calculator.calculate(
        workouts: const [],
        manualSoreRegionIds: {'chest'},
        referenceNow: now,
      );

      final chest = result[MuscleRegion.chest]!;
      expect(chest.isManuallyMarkedSore, isTrue);
      expect(chest.tier, RecoveryTier.sore);
      expect(chest.score, lessThanOrEqualTo(0.35));

      // Other non-sore regions remain fresh
      final lats = result[MuscleRegion.lats]!;
      expect(lats.isManuallyMarkedSore, isFalse);
      expect(lats.tier, RecoveryTier.fresh);
    });

    test('warmup sets are discounted in volume calculations', () {
      final workoutWithWarmup = Workout(
        id: 'w-warmup',
        date: now.subtract(const Duration(hours: 6)),
        duration: const Duration(minutes: 45),
        totalVolume: 1200.0,
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Barbell Bench Press',
            type: ExerciseType.strength,
            exerciseDefinitionId: 'chest_001',
            sets: [
              SetEntry.create(
                reps: 10,
                weight: 20.0,
                type: SetType.warmup,
              ),
              SetEntry.create(
                reps: 10,
                weight: 100.0,
                type: SetType.normal,
              ),
            ],
          ),
        ],
      );

      final result = calculator.calculate(
        workouts: [workoutWithWarmup],
        referenceNow: now,
      );

      final chest = result[MuscleRegion.chest]!;
      expect(chest.sets7Days, 1);
      expect(chest.volumeLoad7Days, 1040.0);
    });

    test('resolveRegionsForExercise resolves canonical regions for compound movements', () {
      final benchRegions = MuscleRecoveryCalculator.resolveRegionsForExercise(
        exerciseDefinitionId: 'chest_001',
        name: 'Barbell Bench Press',
      );
      expect(benchRegions, contains(MuscleRegion.chest));

      final squatRegions = MuscleRecoveryCalculator.resolveRegionsForExercise(
        exerciseDefinitionId: 'quads_001',
        name: 'Barbell Squat',
      );
      expect(squatRegions, contains(MuscleRegion.quads));
    });
  });
}
