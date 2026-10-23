import '../../domain/entities/entities.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/hive_workout_data_source.dart';
import '../models/workout_model.dart';
import '../../../sync/domain/services/sync_service.dart';
import '../../../sync/domain/entities/sync_action.dart';

/// Workout repository with automatic cloud sync
class SyncedWorkoutRepository implements WorkoutRepository {
  final HiveWorkoutDataSource _hiveDataSource;
  final SyncService _syncService;
  final String _userId;

  SyncedWorkoutRepository({
    required HiveWorkoutDataSource hiveDataSource,
    required SyncService syncService,
    required String userId,
  })  : _hiveDataSource = hiveDataSource,
        _syncService = syncService,
        _userId = userId;

  /// The active user ID for this repository
  String get userId => _userId;

  @override
  Future<void> saveWorkout(Workout workout) async {
    // Phase 1: stamp ownership + sync clock on the entity itself, so the
    // local record and the queued payload carry a real userId/updatedAt
    // (previously userId was injected into the sync payload only).
    final stamped = workout.copyWith(
      userId: workout.userId ?? _userId,
      updatedAt: DateTime.now(),
    );
    // Save to local Hive first (source of truth)
    final model = WorkoutModel.fromEntity(stamped);
    await _hiveDataSource.saveWorkout(model);

    // Queue sync action scoped to user
    final data = model.toJson();
    await _syncService.queueAction(
      type: SyncActionType.create,
      dataType: SyncDataType.workout,
      dataId: workout.id,
      data: data,
    );

    // Trigger sync for this user
    _syncService.syncAll(userId: _userId);
  }

  @override
  Future<List<Workout>> getAllWorkouts() async {
    final models = await _hiveDataSource.getAllWorkouts();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Workout>> getWorkoutsPaginated({
    int offset = 0,
    int limit = 20,
  }) async {
    final models = await _hiveDataSource.getWorkoutsPaginated(
      offset: offset,
      limit: limit,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> getWorkoutCount() async {
    return await _hiveDataSource.getWorkoutCount();
  }

  @override
  Future<List<Exercise>> getExerciseHistory(
    String exerciseName,
    int limit,
  ) async {
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
    DateTime start,
    DateTime end,
  ) async {
    final allWorkouts = await getAllWorkouts();
    return allWorkouts
        .where((w) => w.date.isAfter(start) && w.date.isBefore(end))
        .toList();
  }

  @override
  Future<void> deleteWorkout(String id) async {
    // Delete from local Hive first
    await _hiveDataSource.deleteWorkout(id);

    // Queue sync action
    await _syncService.queueAction(
      type: SyncActionType.delete,
      dataType: SyncDataType.workout,
      dataId: id,
      data: {'id': id, 'userId': _userId},
    );

    // Trigger sync for this user
    _syncService.syncAll(userId: _userId);
  }
}
