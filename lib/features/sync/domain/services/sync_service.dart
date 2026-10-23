import 'package:progression_tracker/core/utils/app_logger.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../entities/sync_action.dart';
import '../entities/sync_status.dart';
import '../../data/datasources/hive_sync_queue_datasource.dart';
import '../../data/datasources/firestore_sync_datasource.dart';
import '../../../workout/data/datasources/hive_workout_data_source.dart';
import '../../../workout/data/datasources/hive_active_program_datasource.dart';
import '../../../workout/data/models/workout_model.dart';
import '../../../workout/data/models/active_program_model.dart';
import '../../../nutrition/data/datasources/hive_nutrition_datasource.dart';
import '../../../nutrition/data/models/meal_model.dart';
import '../../../nutrition/data/models/nutrition_targets_model.dart';
import '../../../body/data/datasources/hive_body_data_source.dart';
import '../../../body/data/models/body_entry_model.dart';

/// THE sync engine (Phase 2, DATABASE_AND_SYNC_AUDIT F-03/F-11).
///
/// One outbox (`SyncAction` in the `sync_queue` Hive box), one engine:
///
/// - **Push:** queued actions are applied to Firestore in FIFO order,
///   only those owned by the syncing user. Creates/updates are upserts;
///   deletes write tombstones (see FirestoreSyncDataSource).
/// - **Pull:** each collection is pulled incrementally using a
///   *per-device* `syncedAt` cursor, merged last-write-wins on the
///   record's `updatedAt`, with tombstones applied as local deletes —
///   so two devices converge, including deletions.
/// - **Triggers:** connectivity regain, a 5-minute timer, post-write
///   (via [queueAction]), and explicit [syncAll] calls. Internal
///   triggers resolve the current user through [currentUserIdProvider]
///   (previously they called `syncAll()` with no userId, which by
///   design no-oped — the engine could never fire on its own).
///
/// Nutrition/body pulls are enabled when the corresponding local data
/// sources are provided (the app provider always passes them; older
/// constructions, e.g. tests, simply skip those legs).
class SyncService {
  final HiveSyncQueueDataSource _syncQueue;
  final FirestoreSyncDataSource _firestoreSync;
  final HiveWorkoutDataSource _hiveWorkouts;
  final HiveActiveProgramDataSource _hivePrograms;
  final HiveNutritionDatasource? _hiveNutrition;
  final HiveBodyDataSource? _hiveBody;
  final Connectivity _connectivity;

  /// Resolves the currently signed-in user id for internal triggers.
  final String? Function()? currentUserIdProvider;

  final _syncStatusController = StreamController<SyncStatusEntity>.broadcast();
  Stream<SyncStatusEntity> get syncStatus => _syncStatusController.stream;

  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  Timer? _periodicSyncTimer;

  /// Cursors compare a device clock against server `syncedAt`
  /// timestamps; keep a safety overlap so clock skew can re-pull
  /// (idempotent under LWW) but never skip.
  static const Duration _cursorSafetyMargin = Duration(minutes: 5);

  // Cursor keys (= Firestore collection names).
  static const String _workoutsKey = 'workouts';
  static const String _programsKey = 'programs';
  static const String _nutritionKey = 'nutrition';
  static const String _bodyProgressKey = 'body_progress';

  SyncService({
    required HiveSyncQueueDataSource syncQueue,
    required FirestoreSyncDataSource firestoreSync,
    required HiveWorkoutDataSource hiveWorkouts,
    required HiveActiveProgramDataSource hivePrograms,
    HiveNutritionDatasource? hiveNutrition,
    HiveBodyDataSource? hiveBody,
    Connectivity? connectivity,
    this.currentUserIdProvider,
  })  : _syncQueue = syncQueue,
        _firestoreSync = firestoreSync,
        _hiveWorkouts = hiveWorkouts,
        _hivePrograms = hivePrograms,
        _hiveNutrition = hiveNutrition,
        _hiveBody = hiveBody,
        _connectivity = connectivity ?? Connectivity();

  String? _resolveUserId() {
    try {
      return currentUserIdProvider?.call();
    } catch (_) {
      return null;
    }
  }

  /// Initialize sync service
  Future<void> initialize() async {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        // When online, trigger sync
        syncAll();
      }
    });

    // Set up periodic sync (every 5 minutes when online)
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncAll(),
    );

    // Initial sync
    await syncAll();
  }

  /// Dispose resources
  void dispose() {
    _periodicSyncTimer?.cancel();
    _syncStatusController.close();
  }

  /// Queue a sync action for later execution
  Future<void> queueAction({
    required SyncActionType type,
    required SyncDataType dataType,
    required String dataId,
    required Map<String, dynamic> data,
  }) async {
    final action = SyncAction(
      id: const Uuid().v4(),
      type: type,
      dataType: dataType,
      dataId: dataId,
      data: data,
      timestamp: DateTime.now(),
      status: SyncStatus.pending,
    );

    await _syncQueue.addAction(action);
    _emitStatus();

    // Try to sync immediately if online
    final connectivityResult = await _connectivity.checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      syncAll();
    }
  }

  /// Sync all pending actions and pull latest data from cloud.
  ///
  /// [userId] may be omitted by internal triggers; the current user is
  /// then resolved via [currentUserIdProvider]. With no user at all the
  /// sync is skipped (local-only mode).
  Future<void> syncAll({String? userId}) async {
    if (_isSyncing) {
      AppLogger.debug('Sync already in progress, skipping...');
      return;
    }
    // Set the guard before the first await: several triggers can fire
    // together (queueAction + repository + connectivity), and each
    // would otherwise pass the check above and sync concurrently.
    _isSyncing = true;
    _emitStatus();

    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        AppLogger.debug('No internet connection, sync skipped');
        return;
      }

      final uid = userId ?? _resolveUserId();
      if (uid == null) {
        AppLogger.debug('No user ID provided, sync skipped');
        return;
      }

      // Step 1: Push local changes to cloud
      await _pushLocalChanges(uid);

      // Step 2: Pull cloud changes to local
      await _pullCloudChanges(uid);

      // Step 3: Clean up completed actions
      await _syncQueue.clearCompleted();

      _lastSyncTime = DateTime.now();
      AppLogger.debug('✅ Sync completed successfully');
    } catch (e) {
      AppLogger.debug('❌ Sync failed: $e');
    } finally {
      _isSyncing = false;
      _emitStatus();
    }
  }

  // ---------------------------------------------------------------------------
  // Push
  // ---------------------------------------------------------------------------

  /// Push local changes to cloud
  Future<void> _pushLocalChanges(String userId) async {
    final pendingActions = await _syncQueue.getPendingActions();

    for (final action in pendingActions) {
      // Skip if too many retries
      if (action.retryCount >= 3) {
        AppLogger.debug('Action ${action.id} exceeded max retries, skipping');
        continue;
      }

      // Only push the syncing user's own actions; other accounts'
      // queued actions (shared device) wait for their owner's sync.
      final owner = action.data['userId'];
      if (owner is String && owner.isNotEmpty && owner != userId) {
        continue;
      }

      try {
        await _syncQueue.updateActionStatus(action.id, SyncStatus.syncing);

        switch (action.dataType) {
          case SyncDataType.workout:
            await _syncWorkoutAction(userId, action);
            break;
          case SyncDataType.program:
            await _syncProgramAction(userId, action);
            break;
          case SyncDataType.nutrition:
            await _syncNutritionAction(userId, action);
            break;
          case SyncDataType.bodyProgress:
            await _syncBodyProgressAction(userId, action);
            break;
          case SyncDataType.nutritionTargets:
            await _syncNutritionTargetsAction(userId, action);
            break;
        }

        await _syncQueue.updateActionStatus(action.id, SyncStatus.completed);
        AppLogger.debug('✅ Synced ${action.dataType} ${action.type} for ${action.dataId}');
      } catch (e) {
        await _syncQueue.updateActionStatus(
          action.id,
          SyncStatus.failed,
          error: e.toString(),
        );
        AppLogger.debug('❌ Failed to sync ${action.dataType} ${action.type}: $e');
      }
    }
  }

  Future<void> _syncWorkoutAction(String userId, SyncAction action) async {
    switch (action.type) {
      case SyncActionType.create:
      case SyncActionType.update:
        final workout = WorkoutModel.fromJson(action.data);
        await _firestoreSync.syncWorkout(userId, workout);
        break;
      case SyncActionType.delete:
        await _firestoreSync.deleteWorkout(userId, action.dataId);
        break;
    }
  }

  Future<void> _syncProgramAction(String userId, SyncAction action) async {
    switch (action.type) {
      case SyncActionType.create:
      case SyncActionType.update:
        // Payload is the FULL ActiveProgramModel (plan + progress).
        final program = ActiveProgramModel.fromJson(action.data);
        await _firestoreSync.syncActiveProgram(userId, program);
        break;
      case SyncActionType.delete:
        await _firestoreSync.deleteProgram(userId, action.dataId);
        break;
    }
  }

  Future<void> _syncNutritionAction(String userId, SyncAction action) async {
    switch (action.type) {
      case SyncActionType.create:
      case SyncActionType.update:
        final meal = MealModel.fromJson(action.data);
        await _firestoreSync.syncMeal(userId, meal);
        break;
      case SyncActionType.delete:
        await _firestoreSync.deleteMeal(userId, action.dataId);
        break;
    }
  }

  Future<void> _syncBodyProgressAction(String userId, SyncAction action) async {
    switch (action.type) {
      case SyncActionType.create:
      case SyncActionType.update:
        final entry = BodyEntryModel.fromJson(action.data);
        await _firestoreSync.syncBodyEntry(userId, entry);
        break;
      case SyncActionType.delete:
        await _firestoreSync.deleteBodyEntry(userId, action.dataId);
        break;
    }
  }

  Future<void> _syncNutritionTargetsAction(
    String userId,
    SyncAction action,
  ) async {
    switch (action.type) {
      case SyncActionType.create:
      case SyncActionType.update:
        final targets = NutritionTargetsModel.fromJson(action.data);
        await _firestoreSync.syncNutritionTargets(userId, targets);
        break;
      case SyncActionType.delete:
        // Singleton document: overwritten, never deleted.
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Pull (each leg isolated: one failing collection must not block the rest)
  // ---------------------------------------------------------------------------

  Future<void> _pullCloudChanges(String userId) async {
    await _guardLeg('workouts', () => _pullWorkouts(userId));
    await _guardLeg('program', () => _pullActiveProgram(userId));
    if (_hiveNutrition != null) {
      await _guardLeg('meals', () => _pullMeals(userId));
      await _guardLeg('nutrition targets', () => _pullNutritionTargets(userId));
    }
    if (_hiveBody != null) {
      await _guardLeg('body entries', () => _pullBodyEntries(userId));
    }
  }

  Future<void> _guardLeg(String label, Future<void> Function() leg) async {
    try {
      await leg();
    } catch (e) {
      AppLogger.debug('❌ Failed to pull $label: $e');
    }
  }

  Future<void> _pullWorkouts(String userId) async {
    final since = await _syncQueue.getCursor(_workoutsKey);
    final cloudWorkouts = await _firestoreSync.getWorkouts(userId, since: since);
    if (cloudWorkouts.isNotEmpty) {
      final locals = {
        for (final w in await _hiveWorkouts.getAllWorkouts()) w.id: w,
      };
      for (final cloud in cloudWorkouts) {
        if (cloud.deletedAt != null) {
          // Tombstone: propagate the deletion.
          await _hiveWorkouts.deleteWorkout(cloud.id);
          AppLogger.debug('📥 Deleted workout ${cloud.id} (tombstone)');
          continue;
        }
        final local = locals[cloud.id];
        if (local == null ||
            _isAfter(_workoutClock(cloud), _workoutClock(local))) {
          await _hiveWorkouts.saveWorkout(cloud);
          AppLogger.debug('📥 Pulled workout ${cloud.id}');
        }
      }
    }
    await _advanceCursor(_workoutsKey);
  }

  Future<void> _pullActiveProgram(String userId) async {
    final since = await _syncQueue.getCursor(_programsKey);
    final cloud = await _firestoreSync.getActiveProgram(userId, since: since);
    if (cloud != null) {
      final local = await _hivePrograms.loadActiveProgram();
      if (local == null ||
          _isAfter(_parse(cloud.updatedAt), _parse(local.updatedAt))) {
        // Full state (day index + completed days) comes with the model;
        // the old pull reconstructed a fresh ActiveProgram at day 0.
        await _hivePrograms.saveActiveProgram(cloud);
        AppLogger.debug('📥 Pulled active program ${cloud.id}');
      }
    }
    await _advanceCursor(_programsKey);
  }

  Future<void> _pullMeals(String userId) async {
    final hiveNutrition = _hiveNutrition!;
    final since = await _syncQueue.getCursor(_nutritionKey);
    final cloudMeals = await _firestoreSync.getMeals(userId, since: since);
    if (cloudMeals.isNotEmpty) {
      final locals = {
        for (final m in await hiveNutrition.getAllMeals()) m.id: m,
      };
      for (final cloud in cloudMeals) {
        if (cloud.deletedAt != null) {
          await hiveNutrition.deleteMealEntry(cloud.id);
          AppLogger.debug('📥 Deleted meal ${cloud.id} (tombstone)');
          continue;
        }
        final local = locals[cloud.id];
        if (local == null || _isAfter(_mealClock(cloud), _mealClock(local))) {
          await hiveNutrition.saveMealEntry(cloud);
          AppLogger.debug('📥 Pulled meal ${cloud.id}');
        }
      }
    }
    await _advanceCursor(_nutritionKey);
  }

  Future<void> _pullBodyEntries(String userId) async {
    final hiveBody = _hiveBody!;
    final since = await _syncQueue.getCursor(_bodyProgressKey);
    final cloudEntries =
        await _firestoreSync.getBodyEntries(userId, since: since);
    if (cloudEntries.isNotEmpty) {
      final locals = {
        for (final e in await hiveBody.getAllBodyEntries()) e.id: e,
      };
      for (final cloud in cloudEntries) {
        if (cloud.deletedAt != null) {
          await hiveBody.deleteBodyEntry(cloud.id);
          AppLogger.debug('📥 Deleted body entry ${cloud.id} (tombstone)');
          continue;
        }
        final local = locals[cloud.id];
        if (local == null || _isAfter(_bodyClock(cloud), _bodyClock(local))) {
          await hiveBody.saveBodyEntry(cloud);
          AppLogger.debug('📥 Pulled body entry ${cloud.id}');
        }
      }
    }
    await _advanceCursor(_bodyProgressKey);
  }

  Future<void> _pullNutritionTargets(String userId) async {
    final hiveNutrition = _hiveNutrition!;
    final cloud = await _firestoreSync.getNutritionTargets(userId);
    if (cloud == null) return;
    final local = await hiveNutrition.getNutritionTargets();
    if (local == null || _isAfter(_parse(cloud.updatedAt), _parse(local.updatedAt))) {
      await hiveNutrition.saveNutritionTargets(cloud);
      AppLogger.debug('📥 Pulled nutrition targets');
    }
  }

  // ---------------------------------------------------------------------------
  // LWW clocks (Phase 1/2 fields; legacy rows fall back to record date)
  // ---------------------------------------------------------------------------

  DateTime _workoutClock(WorkoutModel w) =>
      _parse(w.updatedAt) ?? _parse(w.date) ?? _epoch;

  DateTime _mealClock(MealModel m) =>
      _parse(m.updatedAt) ?? _parse(m.timestamp) ?? _epoch;

  DateTime _bodyClock(BodyEntryModel e) =>
      _parse(e.updatedAt) ?? _parse(e.date) ?? _epoch;

  static final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(0);

  DateTime? _parse(String? iso) =>
      iso == null ? null : DateTime.tryParse(iso);

  bool _isAfter(DateTime? a, DateTime? b) => (a ?? _epoch).isAfter(b ?? _epoch);

  Future<void> _advanceCursor(String key) async {
    await _syncQueue.setCursor(
      key,
      DateTime.now().subtract(_cursorSafetyMargin),
    );
  }

  // ---------------------------------------------------------------------------
  // Status
  // ---------------------------------------------------------------------------

  /// Emit current sync status
  Future<void> _emitStatus() async {
    if (_syncStatusController.isClosed) return;
    final pendingCount = await _syncQueue.getPendingCount();
    final failedCount = await _syncQueue.getFailedCount();
    if (_syncStatusController.isClosed) return;

    final status = SyncStatusEntity(
      isSyncing: _isSyncing,
      lastSyncTime: _lastSyncTime,
      pendingActions: pendingCount,
      failedActions: failedCount,
    );

    if (!_syncStatusController.isClosed) {
      _syncStatusController.add(status);
    }
  }

  /// Get current sync status
  Future<SyncStatusEntity> getCurrentStatus() async {
    final pendingCount = await _syncQueue.getPendingCount();
    final failedCount = await _syncQueue.getFailedCount();

    return SyncStatusEntity(
      isSyncing: _isSyncing,
      lastSyncTime: _lastSyncTime,
      pendingActions: pendingCount,
      failedActions: failedCount,
    );
  }

  /// Retry failed actions
  Future<void> retryFailedActions(String userId) async {
    final pendingActions = await _syncQueue.getPendingActions();
    final failedActions = pendingActions.where((a) => a.status == SyncStatus.failed);

    for (final action in failedActions) {
      await _syncQueue.updateActionStatus(action.id, SyncStatus.pending);
    }

    await syncAll(userId: userId);
  }
}
