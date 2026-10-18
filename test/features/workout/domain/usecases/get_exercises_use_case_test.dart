import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_definition.dart';
import 'package:progression_tracker/features/workout/domain/usecases/get_exercises_use_case.dart';

void main() {
  group('GetExercisesUseCase', () {
    late GetExercisesUseCase useCase;

    setUp(() {
      useCase = GetExercisesUseCase();
    });

    test('returns all exercises when no filters supplied', () {
      final results = useCase();
      expect(results.length, 150);
    });

    test('filters by query string matching name or subMuscle', () {
      final results = useCase(query: 'bench');
      expect(results.isNotEmpty, isTrue);
      for (final ex in results) {
        final matches = ex.name.toLowerCase().contains('bench') ||
            ex.subMuscle.toLowerCase().contains('bench');
        expect(matches, isTrue);
      }
    });

    test('filters by muscleGroup including primary and secondary targets', () {
      final results = useCase(muscleGroup: MuscleGroup.chest);
      expect(results.isNotEmpty, isTrue);
      for (final ex in results) {
        final matches = ex.muscleGroup == MuscleGroup.chest ||
            ex.primaryMuscles.contains(MuscleGroup.chest);
        expect(matches, isTrue);
      }
    });

    test('filters by equipment', () {
      final results = useCase(equipment: Equipment.dumbbell);
      expect(results.isNotEmpty, isTrue);
      for (final ex in results) {
        expect(ex.equipment, Equipment.dumbbell);
      }
    });

    test('filters by difficulty', () {
      final results = useCase(difficulty: Difficulty.beginner);
      expect(results.isNotEmpty, isTrue);
      for (final ex in results) {
        expect(ex.difficulty, Difficulty.beginner);
      }
    });

    test('combines multiple filters correctly', () {
      final results = useCase(
        muscleGroup: MuscleGroup.chest,
        equipment: Equipment.barbell,
        difficulty: Difficulty.intermediate,
      );
      expect(results.isNotEmpty, isTrue);
      for (final ex in results) {
        final matchesMuscle = ex.muscleGroup == MuscleGroup.chest ||
            ex.primaryMuscles.contains(MuscleGroup.chest);
        expect(matchesMuscle, isTrue);
        expect(ex.equipment, Equipment.barbell);
        expect(ex.difficulty, Difficulty.intermediate);
      }
    });
  });
}
