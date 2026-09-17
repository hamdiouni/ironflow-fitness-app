import '../../domain/entities/entities.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/hive_workout_data_source.dart';
import '../models/workout_model.dart';
import '../../../../core/error/exceptions.dart';

/// Concrete implementation of [WorkoutRepository] backed by [HiveWorkoutDataSource].
class WorkoutRepositoryImpl implements WorkoutRepository {
  final HiveWorkoutDataSource dataSource;

  WorkoutRepositoryImpl(this.dataSource);

  @override
  Future<void> saveWorkout(Workout workout) async {
    final model = WorkoutModel.fromEntity(workout);
    await dataSource.saveWorkout(model);
  }

  @override
  Future<List<Workout>> getAllWorkouts() async {
    final models = await dataSource.getAllWorkouts();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Workout>> getWorkoutsPaginated({
    int offset = 0,
    int limit = 20,
  }) async {
    final models = await dataSource.getWorkoutsPaginated(
      offset: offset,
      limit: limit,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> getWorkoutCount() async {
    return await dataSource.getWorkoutCount();
  }

  @override
  Future<List<Exercise>> getExerciseHistory(
      String exerciseName, int limit) async {
    final workouts = await getAllWorkouts();
    final exercises = <Exercise>[];

    for (final workout in workouts) {
      final matching = workout.exercises.where(
        (e) => e.name.toLowerCase() == exerciseName.toLowerCase(),
      );
      exercises.addAll(matching);
      if (exercises.length >= limit) break;
    }

    return exercises.take(limit).toList();
  }

  @override
  Future<List<Workout>> getWorkoutsByDateRange(
      DateTime start, DateTime end) async {
    final allWorkouts = await getAllWorkouts();
    return allWorkouts
        .where((w) => w.date.isAfter(start) && w.date.isBefore(end))
        .toList();
  }

  @override
  Future<void> deleteWorkout(String id) async {
    await dataSource.deleteWorkout(id);
  }
}

/// Wraps a [WorkoutRepository] and retries each operation once on [StorageException].
///
/// Satisfies requirement 15.2: resilient storage with max 1 retry.
class ResilientWorkoutRepository implements WorkoutRepository {
  final WorkoutRepository _inner;

  ResilientWorkoutRepository(this._inner);

  Future<T> _withRetry<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on StorageException {
      // Retry once on transient storage failure
      return await operation();
    }
  }

  @override
  Future<void> saveWorkout(Workout workout) =>
      _withRetry(() => _inner.saveWorkout(workout));

  @override
  Future<List<Workout>> getAllWorkouts() =>
      _withRetry(() => _inner.getAllWorkouts());

  @override
  Future<List<Workout>> getWorkoutsPaginated({
    int offset = 0,
    int limit = 20,
  }) =>
      _withRetry(() => _inner.getWorkoutsPaginated(
            offset: offset,
            limit: limit,
          ));

  @override
  Future<int> getWorkoutCount() =>
      _withRetry(() => _inner.getWorkoutCount());

  @override
  Future<List<Exercise>> getExerciseHistory(
          String exerciseName, int limit) =>
      _withRetry(() => _inner.getExerciseHistory(exerciseName, limit));

  @override
  Future<List<Workout>> getWorkoutsByDateRange(
          DateTime start, DateTime end) =>
      _withRetry(() => _inner.getWorkoutsByDateRange(start, end));

  @override
  Future<void> deleteWorkout(String id) =>
      _withRetry(() => _inner.deleteWorkout(id));
}
