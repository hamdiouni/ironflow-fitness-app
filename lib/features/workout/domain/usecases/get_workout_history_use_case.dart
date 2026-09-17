import '../entities/entities.dart';
import '../repositories/workout_repository.dart';

/// Retrieves all persisted workouts, sorted by date descending.
class GetWorkoutHistoryUseCase {
  final WorkoutRepository repository;

  GetWorkoutHistoryUseCase(this.repository);

  Future<List<Workout>> call() async {
    return await repository.getAllWorkouts();
  }
}
