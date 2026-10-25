import '../../domain/entities/entities.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/hive_workout_data_source.dart';
import '../models/workout_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/record_ownership.dart';

/// Concrete implementation of [WorkoutRepository] backed by [HiveWorkoutDataSource].
class WorkoutRepositoryImpl implements WorkoutRepository {
  final HiveWorkoutDataSource dataSource;

  /// Current account scope. Null preserves the signed-out local-only
  /// behaviour used by existing direct constructions.
  final String? userId;

  WorkoutRepositoryImpl(this.dataSource, {this.userId});

  String? get _currentUserId =>
      RecordOwnershipRules.normalizeUserId(userId);

  bool _belongsToCurrentUser(String? ownerId) {
    return RecordOwnershipRules.belongsToCurrentUser(
      ownerId: ownerId,
      currentUserId: _currentUserId,
    );
  }

  bool _isForeign(String? ownerId) {
    return RecordOwnershipRules.isForeignToCurrentUser(
      ownerId: ownerId,
      currentUserId: _currentUserId,
    );
  }

  Future<WorkoutModel?> _findExistingWorkout(String id) async {
    for (final model in await dataSource.getAllWorkouts()) {
      if (model.id == id) return model;
    }
    return null;
  }

  String? _ownerForSave(String? ownerId) {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return ownerId;
    return RecordOwnershipRules.isLegacyUnownedOwner(ownerId)
        ? currentUserId
        : ownerId;
  }

  @override
  Future<void> saveWorkout(Workout workout) async {
    if (_currentUserId != null) {
      // A scoped repository must not create, overwrite, or claim a
      // record proven to belong to another account.
      if (_isForeign(workout.userId)) return;
      final existing = await _findExistingWorkout(workout.id);
      if (existing != null && _isForeign(existing.userId)) return;
    }

    // Phase 1: stamp updatedAt on every save (last-write-wins sync clock).
    // Legacy/guest records written through a scoped repository are
    // stamped with that repository's current account.
    final stamped = workout.copyWith(
      userId: _ownerForSave(workout.userId),
      updatedAt: DateTime.now(),
    );
    final model = WorkoutModel.fromEntity(stamped);
    await dataSource.saveWorkout(model);
  }

  @override
  Future<List<Workout>> getAllWorkouts() async {
    final models = await dataSource.getAllWorkouts();
    return models
        .where((m) => _belongsToCurrentUser(m.userId))
        .map((m) => m.toEntity())
        .toList();
  }

  @override
  Future<List<Workout>> getWorkoutsPaginated({
    int offset = 0,
    int limit = 20,
  }) async {
    final workouts = await getAllWorkouts();
    if (offset >= workouts.length) return <Workout>[];
    final endIndex = (offset + limit).clamp(0, workouts.length);
    return workouts.sublist(offset, endIndex);
  }

  @override
  Future<int> getWorkoutCount() async {
    return (await getAllWorkouts()).length;
  }

  @override
  Future<List<Exercise>> getExerciseHistory(
      String exerciseName, int limit) async {
    final workouts = await getAllWorkouts();
    final exercises = <Exercise>[];

    for (final workout in workouts) {
      final matching = workout.exercises.where(
        // Phase 1: a definition id is accepted as well as a name.
        (e) =>
            e.exerciseDefinitionId == exerciseName ||
            e.name.toLowerCase() == exerciseName.toLowerCase(),
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
    final existing = await _findExistingWorkout(id);
    if (existing != null && _isForeign(existing.userId)) return;
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
