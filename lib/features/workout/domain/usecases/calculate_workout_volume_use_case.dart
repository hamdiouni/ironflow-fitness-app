import '../entities/entities.dart';

/// Calculates the total training volume for a [Workout].
///
/// Volume = sum of (weight × reps) across all sets of all exercises.
class CalculateWorkoutVolumeUseCase {
  double call(Workout workout) {
    return workout.exercises.fold(0.0, (total, exercise) {
      final exerciseVolume = exercise.sets.fold(0.0, (sum, set) {
        if (set.type == SetType.warmup) return sum;
        return sum + (set.weight * set.reps);
      });
      return total + exerciseVolume;
    });
  }
}
