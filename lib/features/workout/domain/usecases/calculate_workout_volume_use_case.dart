import '../entities/entities.dart';
import 'workout_metrics.dart';

/// Calculates the total training volume for a [Workout].
///
/// Volume = sum of (weight × reps) across all valid working sets of all exercises.
class CalculateWorkoutVolumeUseCase {
  double call(Workout workout) {
    return WorkoutMetrics.calculateWorkoutVolume(workout);
  }
}
