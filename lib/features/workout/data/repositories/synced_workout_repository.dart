import '../../domain/entities/entities.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/hive_workout_data_source.dart';
import '../models/workout_model.dart';
import 'workout_repository_impl.dart';
import '../../../../core/utils/record_ownership.dart';
import '../../../sync/data/services/sync_service.dart';
import '../../../sync/domain/entities/sync_action.dart';

/// Decorator around [WorkoutRepository] that stamps ownership/timestamps and
/// enqueues cloud sync actions after local writes succeed.
class SyncedWorkoutRepository implements WorkoutRepository {
  final WorkoutRepository _delegate;
  final HiveWorkoutDataSource? _hiveDataSource;
  final SyncService _syncService;
  final String _userId;

  SyncedWorkoutRepository({
    WorkoutRepository? delegate,
    HiveWorkoutDataSource? hiveDataSource,
    required SyncService syncService,
    required String userId,
  })  : assert(
          delegate != null || hiveDataSource != null,
          'Provide either delegate or hiveDataSource.',
        ),
        _delegate = delegate ??
            WorkoutRepositoryImpl(hiveDataSource!, userId: userId),
        _hiveDataSource = hiveDataSource ??
            (delegate is WorkoutRepositoryImpl ? delegate.dataSource : null),
        _syncService = syncService,
        _userId = userId;

  /// The active user ID for this repository
  String get userId => _userId;

  String? get _currentUserId =>
      RecordOwnershipRules.normalizeUserId(_userId);

  bool _isForeign(String? ownerId) {
    return RecordOwnershipRules.isForeignToCurrentUser(
      ownerId: ownerId,
      currentUserId: _currentUserId,
    );
  }

  Future<WorkoutModel?> _findExistingWorkout(String id) async {
    final hiveDataSource = _hiveDataSource;
    if (hiveDataSource == null) return null;
    return hiveDataSource.getWorkoutById(id);
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

    final stamped = workout.copyWith(
      userId: _ownerForSave(workout.userId),
      updatedAt: DateTime.now(),
    );
    await _delegate.saveWorkout(stamped);

    final persisted = _hiveDataSource != null
        ? await _hiveDataSource.getWorkoutById(workout.id)
        : null;
    final data = (persisted ?? WorkoutModel.fromEntity(stamped)).toJson();
    await _syncService.queueAction(
      type: SyncActionType.create,
      dataType: SyncDataType.workout,
      dataId: workout.id,
      data: data,
    );
  }

  @override
  Future<List<Workout>> getAllWorkouts() => _delegate.getAllWorkouts();

  @override
  Future<List<Workout>> getWorkoutsPaginated({
    int offset = 0,
    int limit = 20,
  }) =>
      _delegate.getWorkoutsPaginated(offset: offset, limit: limit);

  @override
  Future<int> getWorkoutCount() => _delegate.getWorkoutCount();

  @override
  Future<List<Exercise>> getExerciseHistory(
    String exerciseName,
    int limit,
  ) =>
      _delegate.getExerciseHistory(exerciseName, limit);

  @override
  Future<List<Workout>> getWorkoutsByDateRange(
    DateTime start,
    DateTime end,
  ) =>
      _delegate.getWorkoutsByDateRange(start, end);

  @override
  Future<void> deleteWorkout(String id) async {
    final existing = await _findExistingWorkout(id);
    if (existing != null && _isForeign(existing.userId)) return;

    await _delegate.deleteWorkout(id);

    await _syncService.queueAction(
      type: SyncActionType.delete,
      dataType: SyncDataType.workout,
      dataId: id,
      data: {'id': id, 'userId': _userId},
    );
  }
}
