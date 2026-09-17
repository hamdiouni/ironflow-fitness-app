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

  @override
  Future<void> saveWorkout(Workout workout) async {
    // Save to local Hive first (source of truth)
    final model = WorkoutModel.fromEntity(workout);
    await _hiveDataSource.saveWorkout(model);

    // Queue sync action
    await _syncService.queueAction(
      type: SyncActionType.create,
      dataType: SyncDataType.workout,
      dataId: workout.id,
      data: model.toJson(),
    );
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
        (e) => e.name.toLowerCase() == exerciseName.toLowerCase(),
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
      data: {'id': id},
    );
  }
}
