import '../entities/entities.dart';
import '../repositories/workout_repository.dart';
import 'calculate_workout_volume_use_case.dart';

/// Finalises and persists a completed workout.
///
/// Calculates total volume, stamps the duration, then delegates to the
/// [WorkoutRepository] for storage.
class SaveWorkoutUseCase {
  final WorkoutRepository repository;
  final CalculateWorkoutVolumeUseCase calculateVolume;

  SaveWorkoutUseCase(this.repository, this.calculateVolume);

  Future<void> call(Workout workout, Duration duration) async {
    final totalVolume = calculateVolume(workout);
    final completedWorkout = workout.copyWith(
      duration: duration,
      totalVolume: totalVolume,
    );
    await repository.saveWorkout(completedWorkout);
  }
}
