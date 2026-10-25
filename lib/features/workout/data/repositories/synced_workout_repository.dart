import '../../domain/entities/entities.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/hive_workout_data_source.dart';
import '../models/workout_model.dart';
import '../../../../core/utils/record_ownership.dart';
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

  String? get _currentUserId =>
      RecordOwnershipRules.normalizeUserId(_userId);

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
    for (final model in await _hiveDataSource.getAllWorkouts()) {
      if (model.id == id) return model;
    }
    return null;
  }

  String? _ownerForSave(String? ownerId) {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return ownerId ?? _userId;
    return RecordOwnershipRules.isLegacyUnownedOwner(ownerId)
        ? currentUserId
        : ownerId;
  }

  @override
  Future<void> saveWorkout(Workout workout) async {
    if (_currentUserId != null) {
      // Never save over, claim, or enqueue another account's workout.
      if (_isForeign(workout.userId)) return;
      final existing = await _findExistingWorkout(workout.id);
      if (existing != null && _isForeign(existing.userId)) return;
    }

    // Phase 1: stamp ownership + sync clock on the entity itself, so the
    // local record and the queued payload carry a real userId/updatedAt
    // (previously userId was injected into the sync payload only).
    final stamped = workout.copyWith(
      userId: _ownerForSave(workout.userId),
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
    final existing = await _findExistingWorkout(id);
    if (existing != null && _isForeign(existing.userId)) return;

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
