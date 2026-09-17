import '../entities/entities.dart';

/// Adds an [Exercise] to an existing [Workout], returning the updated workout.
class AddExerciseToWorkoutUseCase {
  Future<Workout> call(Workout workout, Exercise exercise) async {
    return workout.copyWith(
      exercises: [...workout.exercises, exercise],
    );
  }
}
