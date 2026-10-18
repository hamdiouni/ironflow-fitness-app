import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/usecases/get_progression_suggestion_use_case.dart';

class MockWorkoutRepository implements WorkoutRepository {
  List<Workout> workouts = [];

  @override
  Future<List<Workout>> getAllWorkouts() async => workouts;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockWorkoutRepository repository;
  late GetProgressionSuggestionUseCase useCase;

  setUp(() {
    repository = MockWorkoutRepository();
    useCase = GetProgressionSuggestionUseCase(repository);
  });

  group('GetProgressionSuggestionUseCase (TRN-03)', () {
    test('returns null when exercise history is empty', () async {
      repository.workouts = [];
      final suggestion = await useCase('Bench Press');
      expect(suggestion, isNull);
    });

    test('excludes warm-up sets when computing average weight and completion', () async {
      repository.workouts = [
        Workout(
          id: 'w1',
          date: DateTime.now(),
          duration: const Duration(minutes: 45),
          totalVolume: 0,
          exercises: [
            Exercise(
              id: 'e1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              suggestedSets: 3,
              suggestedReps: 8,
              sets: [
                // Warm-up: 20kg (must be excluded from avg weight and completion)
                SetEntry.create(reps: 10, weight: 20.0, type: SetType.warmup),
                // 3 Working sets: 100kg
                SetEntry.create(reps: 8, weight: 100.0, type: SetType.normal, rpe: 7),
                SetEntry.create(reps: 8, weight: 100.0, type: SetType.normal, rpe: 7),
                SetEntry.create(reps: 8, weight: 100.0, type: SetType.normal, rpe: 7),
              ],
            ),
          ],
        ),
      ];

      final suggestion = await useCase('Bench Press');
      expect(suggestion, isNotNull);
      // Working weight is 100kg, not (20 + 300) / 4 = 80kg
      // With high completion (3/3 = 100%) and moderate RPE 7.0 <= 7.5, suggests bumping weight
      expect(suggestion!.suggestedWeight, greaterThan(100.0));
      expect(suggestion.isStagnant, isFalse);
    });

    test('suggests deload when user logs high fatigue (RPE >= 9.0)', () async {
      repository.workouts = [
        Workout(
          id: 'w1',
          date: DateTime.now(),
          duration: const Duration(minutes: 45),
          totalVolume: 0,
          exercises: [
            Exercise(
              id: 'e1',
              name: 'Squat',
              type: ExerciseType.strength,
              suggestedSets: 3,
              suggestedReps: 5,
              sets: [
                SetEntry.create(reps: 5, weight: 120.0, type: SetType.normal, rpe: 9),
                SetEntry.create(reps: 4, weight: 120.0, type: SetType.normal, rpe: 10),
                SetEntry.create(reps: 3, weight: 120.0, type: SetType.failure, rpe: 10),
              ],
            ),
          ],
        ),
      ];

      final suggestion = await useCase('Squat');
      expect(suggestion, isNotNull);
      expect(suggestion!.isStagnant, isTrue);
      expect(suggestion.suggestedWeight, lessThan(120.0));
      expect(suggestion.message, contains('High fatigue'));
    });

    test('relying solely on completion rate when no RPE is provided (no fabricated RPE)', () async {
      repository.workouts = [
        Workout(
          id: 'w1',
          date: DateTime.now(),
          duration: const Duration(minutes: 45),
          totalVolume: 0,
          exercises: [
            Exercise(
              id: 'e1',
              name: 'Deadlift',
              type: ExerciseType.strength,
              suggestedSets: 3,
              suggestedReps: 5,
              sets: [
                // Completed all 3 sets with NO RPE entered
                SetEntry.create(reps: 5, weight: 140.0, type: SetType.normal),
                SetEntry.create(reps: 5, weight: 140.0, type: SetType.normal),
                SetEntry.create(reps: 5, weight: 140.0, type: SetType.normal),
              ],
            ),
          ],
        ),
      ];

      final suggestion = await useCase('Deadlift');
      expect(suggestion, isNotNull);
      expect(suggestion!.isStagnant, isFalse);
      expect(suggestion.suggestedWeight, greaterThan(140.0));
      expect(suggestion.message, contains('All target sets completed'));
    });
  });
}
