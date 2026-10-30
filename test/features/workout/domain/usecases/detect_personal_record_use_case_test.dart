import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/usecases/detect_personal_record_use_case.dart';

class MockWorkoutRepository implements WorkoutRepository {
  List<Exercise> history = [];

  @override
  Future<List<Exercise>> getExerciseHistory(String exerciseName, int limit) async {
    return history;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockWorkoutRepository repository;
  late DetectPersonalRecordUseCase useCase;

  setUp(() {
    repository = MockWorkoutRepository();
    useCase = DetectPersonalRecordUseCase(repository);
  });

  group('DetectPersonalRecordUseCase (TRN-01)', () {
    test('warm-up sets never qualify as personal records', () async {
      final newSet = SetEntry.create(
        reps: 10,
        weight: 150.0,
        type: SetType.warmup,
      );

      final isPR = await useCase('Bench Press', newSet);
      expect(isPR, isFalse);
    });

    test('first recorded working set qualifies as a personal record', () async {
      repository.history = [];

      final newSet = SetEntry.create(
        reps: 8,
        weight: 60.0,
        type: SetType.normal,
      );

      final isPR = await useCase('Bench Press', newSet);
      expect(isPR, isTrue);
    });

    test('ignores historical warm-up sets when checking first working set', () async {
      repository.history = [
        Exercise(
          id: 'e1',
          name: 'Bench Press',
          type: ExerciseType.strength,
          sets: [
            SetEntry.create(reps: 10, weight: 80.0, type: SetType.warmup),
          ],
        ),
      ];

      final newSet = SetEntry.create(
        reps: 5,
        weight: 60.0,
        type: SetType.normal,
      );

      final isPR = await useCase('Bench Press', newSet);
      expect(isPR, isTrue);
    });

    test('qualifies as PR when setting a new heaviest weight', () async {
      repository.history = [
        Exercise(
          id: 'e1',
          name: 'Bench Press',
          type: ExerciseType.strength,
          sets: [
            SetEntry.create(reps: 5, weight: 100.0, type: SetType.normal),
          ],
        ),
      ];

      final newSet = SetEntry.create(
        reps: 1,
        weight: 102.5,
        type: SetType.normal,
      );

      final isPR = await useCase('Bench Press', newSet);
      expect(isPR, isTrue);
    });

    test('qualifies as PR when setting more reps at an identical weight', () async {
      repository.history = [
        Exercise(
          id: 'e1',
          name: 'Bench Press',
          type: ExerciseType.strength,
          sets: [
            SetEntry.create(reps: 8, weight: 90.0, type: SetType.normal),
          ],
        ),
      ];

      final newSet = SetEntry.create(
        reps: 10,
        weight: 90.0,
        type: SetType.normal,
      );

      final isPR = await useCase('Bench Press', newSet);
      expect(isPR, isTrue);
    });

    test('qualifies as PR via higher estimated 1RM (Epley formula)', () async {
      // Historical: 90kg x 5 reps -> 1RM = 90 * (1 + 5/30) = 105.0 kg
      repository.history = [
        Exercise(
          id: 'e1',
          name: 'Bench Press',
          type: ExerciseType.strength,
          sets: [
            SetEntry.create(reps: 5, weight: 90.0, type: SetType.normal),
          ],
        ),
      ];

      // New: 85kg x 9 reps -> 1RM = 85 * (1 + 9/30) = 110.5 kg (heavier 1RM even though absolute weight is lower)
      final newSet = SetEntry.create(
        reps: 9,
        weight: 85.0,
        type: SetType.normal,
      );

      final isPR = await useCase('Bench Press', newSet);
      expect(isPR, isTrue);
    });

    test('does NOT trigger PR from raw volume when weight and estimated 1RM are lower', () async {
      // Historical: 100kg x 5 reps = 500kg volume, 1RM = 100 * (1 + 5/30) = 116.67 kg
      repository.history = [
        Exercise(
          id: 'e1',
          name: 'Bench Press',
          type: ExerciseType.strength,
          sets: [
            SetEntry.create(reps: 5, weight: 100.0, type: SetType.normal),
          ],
        ),
      ];

      // High volume pump set: 50kg x 25 reps = 1250kg volume (2.5x volume!)
      // Due to 10-rep cap on Epley: 1RM = 50 * (1 + 10/30) = 66.67 kg.
      // Must NOT be detected as a PR.
      final newSet = SetEntry.create(
        reps: 25,
        weight: 50.0,
        type: SetType.normal,
      );

      final isPR = await useCase('Bench Press', newSet);
      expect(isPR, isFalse);
    });

    test('50 kg x 15 does not beat 140 kg x 5 merely due to reps', () async {
      repository.history = [
        Exercise(
          id: 'e1',
          name: 'Deadlift',
          type: ExerciseType.strength,
          sets: [
            SetEntry.create(reps: 5, weight: 140.0, type: SetType.normal),
          ],
        ),
      ];

      final newSet = SetEntry.create(
        reps: 15,
        weight: 50.0,
        type: SetType.normal,
      );

      final isPR = await useCase('Deadlift', newSet);
      expect(isPR, isFalse);
    });

    test('rejects negative and non-finite weights and supports valid 0 kg bodyweight sets', () async {
      final now = DateTime.now();
      repository.history = [
        Exercise(
          id: 'e-bw',
          name: 'Pull Up',
          type: ExerciseType.strength,
          sets: [
            SetEntry(id: 's-bw-1', reps: 10, weight: 0.0, timestamp: now),
            // Corrupted historical non-finite set must be ignored
            SetEntry(id: 's-corrupt', reps: 10, weight: double.infinity, timestamp: now),
          ],
        ),
      ];

      // 12 bodyweight reps beats 10 bodyweight reps at 0 kg
      final validBodyweightPR = SetEntry.create(
        reps: 12,
        weight: 0.0,
        type: SetType.normal,
      );
      expect(await useCase('Pull Up', validBodyweightPR), isTrue);

      // Negative and non-finite candidate sets are rejected
      final negativeSet = SetEntry(
        id: 's-neg',
        reps: 10,
        weight: -20.0,
        timestamp: now,
      );
      final nanSet = SetEntry(
        id: 's-nan',
        reps: 10,
        weight: double.nan,
        timestamp: now,
      );
      final infSet = SetEntry(
        id: 's-inf',
        reps: 10,
        weight: double.infinity,
        timestamp: now,
      );

      expect(await useCase('Pull Up', negativeSet), isFalse);
      expect(await useCase('Pull Up', nanSet), isFalse);
      expect(await useCase('Pull Up', infSet), isFalse);
    });
  });
}
