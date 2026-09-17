import '../entities/workout.dart';
import '../repositories/workout_repository.dart';

/// Use case for retrieving workouts with pagination support.
/// 
/// This enables lazy loading of workout lists to handle large datasets
/// efficiently (Requirement 8.1: Lazy Loading).
class GetWorkoutsPaginatedUseCase {
  final WorkoutRepository _repository;

  GetWorkoutsPaginatedUseCase(this._repository);

  /// Get workouts with pagination.
  /// 
  /// [offset] - Number of workouts to skip
  /// [limit] - Maximum number of workouts to return (default 20)
  /// Returns workouts sorted by date descending.
  Future<List<Workout>> call({
    int offset = 0,
    int limit = 20,
  }) async {
    return await _repository.getWorkoutsPaginated(
      offset: offset,
      limit: limit,
    );
  }
}

/// Use case for getting total workout count.
class GetWorkoutCountUseCase {
  final WorkoutRepository _repository;

  GetWorkoutCountUseCase(this._repository);

  /// Get total number of workouts.
  Future<int> call() async {
    return await _repository.getWorkoutCount();
  }
}