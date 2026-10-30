import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/domain/usecases/calculate_workout_volume_use_case.dart';

void main() {
  late CalculateWorkoutVolumeUseCase useCase;

  setUp(() {
    useCase = CalculateWorkoutVolumeUseCase();
  });

  group('CalculateWorkoutVolumeUseCase (TRN-01)', () {
    test('excludes warm-up sets from total volume calculation', () {
      final workout = Workout(
        id: 'w1',
        date: DateTime.now(),
        duration: const Duration(minutes: 45),
        totalVolume: 0,
        exercises: [
          Exercise(
            id: 'e1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [
              // Warmup set: 50kg x 10 reps = 500kg (must be excluded)
              SetEntry.create(
                reps: 10,
                weight: 50.0,
                type: SetType.warmup,
              ),
              // Working set 1: 100kg x 8 reps = 800kg
              SetEntry.create(
                reps: 8,
                weight: 100.0,
                type: SetType.normal,
              ),
              // Working set 2 (drop set): 80kg x 10 reps = 800kg
              SetEntry.create(
                reps: 10,
                weight: 80.0,
                type: SetType.drop,
              ),
              // Working set 3 (failure): 70kg x 6 reps = 420kg
              SetEntry.create(
                reps: 6,
                weight: 70.0,
                type: SetType.failure,
              ),
            ],
          ),
        ],
      );

      final volume = useCase(workout);

      // Total expected: 800 + 800 + 420 = 2020.0 kg (warmup 500kg excluded)
      expect(volume, equals(2020.0));
    });

    test('returns 0.0 when a workout contains only warm-up sets', () {
      final workout = Workout(
        id: 'w2',
        date: DateTime.now(),
        duration: const Duration(minutes: 15),
        totalVolume: 0,
        exercises: [
          Exercise(
            id: 'e1',
            name: 'Squat',
            type: ExerciseType.strength,
            sets: [
              SetEntry.create(
                reps: 10,
                weight: 20.0,
                type: SetType.warmup,
              ),
              SetEntry.create(
                reps: 8,
                weight: 40.0,
                type: SetType.warmup,
              ),
            ],
          ),
        ],
      );

      final volume = useCase(workout);
      expect(volume, equals(0.0));
    });

    test('returns 0.0 for an empty workout', () {
      final workout = Workout(
        id: 'w3',
        date: DateTime.now(),
        duration: Duration.zero,
        totalVolume: 0,
        exercises: const [],
      );

      final volume = useCase(workout);
      expect(volume, equals(0.0));
    });

    test('filters negative and non-finite weights while preserving valid 0 kg bodyweight sets', () {
      final now = DateTime.now();
      final workout = Workout(
        id: 'w4',
        date: now,
        duration: const Duration(minutes: 25),
        totalVolume: 0,
        exercises: [
          Exercise(
            id: 'e1',
            name: 'Pull Ups & Weighted Dips',
            type: ExerciseType.strength,
            sets: [
              // Valid 0 kg bodyweight working set -> 0.0 volume
              SetEntry(id: 's1', reps: 12, weight: 0.0, timestamp: now),
              // Valid weighted working set -> 400.0 volume
              SetEntry(id: 's2', reps: 10, weight: 40.0, timestamp: now),
              // Corrupted/unvalidated negative and non-finite sets -> must be filtered out
              SetEntry(id: 's3', reps: 10, weight: -50.0, timestamp: now),
              SetEntry(id: 's4', reps: 10, weight: double.infinity, timestamp: now),
              SetEntry(id: 's5', reps: 10, weight: double.nan, timestamp: now),
            ],
          ),
        ],
      );

      final volume = useCase(workout);
      expect(volume, equals(400.0));
    });
  });
}
