import '../entities/exercise_definition.dart';
import '../../data/exercise_database.dart';

/// Returns all exercises, optionally filtered by muscle group and/or equipment.
class GetExercisesUseCase {
  List<ExerciseDefinition> call({
    String? query,
    MuscleGroup? muscleGroup,
    Equipment? equipment,
  }) {
    var results = ExerciseDatabase.all;

    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((e) =>
        e.name.toLowerCase().contains(q) ||
        e.subMuscle.toLowerCase().contains(q)
      ).toList();
    }

    if (muscleGroup != null) {
      results = results.where((e) => e.muscleGroup == muscleGroup).toList();
    }

    if (equipment != null) {
      results = results.where((e) => e.equipment == equipment).toList();
    }

    return results;
  }
}
