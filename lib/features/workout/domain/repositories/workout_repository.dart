import '../entities/entities.dart';

/// Abstract repository interface for workout data persistence.
///
/// Implementations live in the data layer; the domain layer depends only
/// on this abstraction (Dependency Inversion Principle).
abstract class WorkoutRepository {
  /// Save a workout session to local storage.
  Future<void> saveWorkout(Workout workout);

  /// Retrieve all workouts sorted by date descending.
  Future<List<Workout>> getAllWorkouts();

  /// Get workouts with pagination support (lazy loading).
  /// 
  /// [offset] - Number of workouts to skip
  /// [limit] - Maximum number of workouts to return (default 20)
  /// Returns workouts sorted by date descending.
  Future<List<Workout>> getWorkoutsPaginated({
    int offset = 0,
    int limit = 20,
  });

  /// Get total count of workouts for pagination calculations.
  Future<int> getWorkoutCount();

  /// Get workouts within a date range (inclusive of [start], exclusive of [end]).
  Future<List<Workout>> getWorkoutsByDateRange(DateTime start, DateTime end);

  /// Get the last [limit] performances for a specific exercise by name.
  Future<List<Exercise>> getExerciseHistory(String exerciseName, int limit);

  /// Delete a workout by its [id].
  Future<void> deleteWorkout(String id);
}
