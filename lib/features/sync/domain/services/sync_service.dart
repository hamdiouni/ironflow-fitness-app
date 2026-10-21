import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../body/data/datasources/hive_body_data_source.dart';
import '../../../body/data/models/body_entry_model.dart';
import '../../../nutrition/data/datasources/hive_nutrition_datasource.dart';
import '../../../nutrition/data/models/meal_model.dart';
import '../../../nutrition/data/models/nutrition_targets_model.dart';
import '../../../workout/data/datasources/hive_active_program_datasource.dart';
import '../../../workout/data/datasources/hive_workout_data_source.dart';
import '../../../workout/data/models/active_program_model.dart';
import '../../../workout/data/models/workout_model.dart';
import '../../data/datasources/firestore_sync_datasource.dart';
import '../../data/datasources/hive_sync_queue_datasource.dart';
import '../entities/sync_action.dart';
import '../entities/sync_status.dart';

/// Coordinates offline-first synchronization between Hive and Firestore.
///
/// Records are always written to Hive by their repositories first. This
/// service replays the owner-scoped outbox, then pulls remote updates into the
/// corresponding Hive model stores. `userIdResolver` must return the currently
/// authenticated Firebase UID in production; queue entries are never replayed
/// for a different owner.
class SyncService {
  final HiveSyncQueueDataSource _syncQueue;
  final FirestoreSyncDataSource _firestoreSync;
  final HiveWorkoutDataSource _hiveWorkouts;
  final HiveActiveProgramDataSource _hivePrograms;
  final HiveNutritionDatasource? _hiveNutrition;
  final HiveBodyDataSource? _hiveBody;
  final Connectivity _connectivity;
  final Future<String?> Function()? _userIdResolver;

  final _syncStatusController = StreamController<SyncStatusEntity>.broadcast();
  Stream<SyncStatusEntity> get syncStatus => _syncStatusController.stream;

  bool _isSyncing = false;
  bool _syncRequestedWhileBusy = false;
  String? _queuedSyncUserId;
  bool _isInitialized = false;
  DateTime? _lastSyncTime;
  Timer? _periodicSyncTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  SyncService({
    required HiveSyncQueueDataSource syncQueue,
    required FirestoreSyncDataSource firestoreSync,
    required HiveWorkoutDataSource hiveWorkouts,
    required HiveActiveProgramDataSource hivePrograms,
    HiveNutritionDatasource? hiveNutrition,
    HiveBodyDataSource? hiveBody,
    Future<String?> Function()? userIdResolver,
    Connectivity? connectivity,
  })  : _syncQueue = syncQueue,
        _firestoreSync = firestoreSync,
        _hiveWorkouts = hiveWorkouts,
        _hivePrograms = hivePrograms,
        _hiveNutrition = hiveNutrition,
        _hiveBody = hiveBody,
        _userIdResolver = userIdResolver,
        _connectivity = connectivity ?? Connectivity();

  /// Starts connectivity and periodic sync once for this service instance.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        if (!results.contains(ConnectivityResult.none)) {
          unawaited(syncAll());
        }
      },
    );

    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => unawaited(syncAll()),
    );

    await syncAll();
  }

  /// Releases resources owned by this service.
  void dispose() {
    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = null;
    final subscription = _connectivitySubscription;
    _connectivitySubscription = null;
    if (subscription != null) unawaited(subscription.cancel());
    if (!_syncStatusController.isClosed) {
      unawaited(_syncStatusController.close());
    }
  }

  /// Adds a durable, owner-scoped action to the outbox.
  ///
  /// A `userId` is mandatory on queued data. This prevents an offline action
  /// created by one account from being sent after another account signs in.
  Future<void> queueAction({
    required SyncActionType type,
    required SyncDataType dataType,
    required String dataId,
    required Map<String, dynamic> data,
    bool triggerSync = true,
  }) async {
    final ownerId = data['userId'];
    if (ownerId is! String || ownerId.trim().isEmpty) {
      throw ArgumentError('Queued sync data must include a non-empty userId');
    }

    final action = SyncAction(
      id: const Uuid().v4(),
      type: type,
      dataType: dataType,
      dataId: dataId,
      data: Map<String, dynamic>.from(data),
      timestamp: DateTime.now(),
      status: SyncStatus.pending,
    );

    await _syncQueue.addAction(action);
    unawaited(_emitStatus());

    if (!triggerSync) return;

    final connectivityResult = await _connectivity.checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      unawaited(syncAll(userId: ownerId));
    }
  }

  /// Pushes queued changes and pulls remote changes for one authenticated user.
  /// If [userId] is omitted, the configured resolver is used.
  Future<void> syncAll({String? userId}) async {
    if (_isSyncing) {
      // Do not drop an outbox-triggered sync request that arrives while a
      // previous push/pull cycle is still running.
      _syncRequestedWhileBusy = true;
      if (userId != null) _queuedSyncUserId = userId;
      return;
    }

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return;
    }

    final resolvedUserId = userId ?? await _userIdResolver?.call();
    if (resolvedUserId == null || resolvedUserId.trim().isEmpty) {
      // Guest/demo sessions are local-only; do not make unauthenticated cloud
      // requests or write their local identifiers to Firestore.
      return;
    }

    _isSyncing = true;
    unawaited(_emitStatus());

    try {
      await _pushLocalChanges(resolvedUserId);
      await _pullCloudChanges(resolvedUserId);
      await _syncQueue.clearCompleted();
      _lastSyncTime = DateTime.now();
    } catch (e) {
      // Individual push failures are retained in the outbox. Pull failures
      // leave the last-sync cursor untouched so the next sync retries them.
      print('❌ Sync failed for user $resolvedUserId: $e');
    } finally {
      _isSyncing = false;
      await _emitStatus();

      if (_syncRequestedWhileBusy) {
        final nextUserId = _queuedSyncUserId ?? resolvedUserId;
        _syncRequestedWhileBusy = false;
        _queuedSyncUserId = null;
        unawaited(syncAll(userId: nextUserId));
      }
    }
  }

  Future<void> _pushLocalChanges(String userId) async {
    final pendingActions = await _syncQueue.getPendingActions();

    for (final action in pendingActions) {
      // Older or malformed ownerless actions are intentionally not sent.
      if (action.data['userId'] != userId) continue;
      if (action.retryCount >= 3) continue;

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
        }

        await _syncQueue.updateActionStatus(action.id, SyncStatus.completed);
      } catch (e) {
        await _syncQueue.updateActionStatus(
          action.id,
          SyncStatus.failed,
          error: e.toString(),
        );
        print('❌ Failed to sync ${action.dataType} ${action.dataId}: $e');
      }
    }
  }

  Future<void> _pullCloudChanges(String userId) async {
    final pendingActions = await _syncQueue.getPendingActions();
    final pendingWorkouts = _pendingIds(
      pendingActions,
      userId,
      SyncDataType.workout,
    );
    final pendingPrograms = _pendingIds(
      pendingActions,
      userId,
      SyncDataType.program,
    );
    final pendingMeals = _pendingIds(
      pendingActions,
      userId,
      SyncDataType.nutrition,
    );
    final pendingBodyEntries = _pendingIds(
      pendingActions,
      userId,
      SyncDataType.bodyProgress,
    );

    final workoutLastSync = await _firestoreSync.getLastSyncTime(
      userId,
      'workouts',
    );
    final cloudWorkouts = await _firestoreSync.getWorkouts(
      userId,
      since: workoutLastSync,
    );
    for (final workout in cloudWorkouts) {
      if (!pendingWorkouts.contains(workout.id)) {
        await _hiveWorkouts.saveWorkout(workout);
      }
    }
    final deletedWorkoutIds = await _firestoreSync.getDeletedWorkoutIds(userId);
    for (final id in deletedWorkoutIds) {
      if (!pendingWorkouts.contains(id)) await _hiveWorkouts.deleteWorkout(id);
    }
    await _firestoreSync.updateLastSyncTime(
      userId,
      'workouts',
      DateTime.now(),
    );

    final programLastSync = await _firestoreSync.getLastSyncTime(
      userId,
      'programs',
    );
    final cloudProgram = await _firestoreSync.getActiveProgram(
      userId,
      since: programLastSync,
    );
    if (cloudProgram != null && pendingPrograms.isEmpty) {
      if (cloudProgram.isActive) {
        await _hivePrograms.saveActiveProgram(cloudProgram);
      } else {
        await _hivePrograms.clearActiveProgram();
      }
    }
    await _firestoreSync.updateLastSyncTime(
      userId,
      'programs',
      DateTime.now(),
    );

    if (_hiveNutrition != null) {
      final nutritionLastSync = await _firestoreSync.getLastSyncTime(
        userId,
        'nutrition',
      );
      final cloudMeals = await _firestoreSync.getNutritionLogs(
        userId,
        since: nutritionLastSync,
      );
      for (final json in cloudMeals) {
        final id = json['id'];
        if (id is! String || pendingMeals.contains(id)) continue;
        await _hiveNutrition.saveMealEntry(
          MealModel.fromJson(Map<String, dynamic>.from(json)),
        );
      }
      final deletedMealIds =
          await _firestoreSync.getDeletedNutritionLogIds(userId);
      for (final id in deletedMealIds) {
        if (!pendingMeals.contains(id)) await _hiveNutrition.deleteMealEntry(id);
      }

      if (!pendingMeals.contains('targets')) {
        final targets = await _firestoreSync.getNutritionTargets(userId);
        if (targets != null) {
          await _hiveNutrition.saveNutritionTargets(
            NutritionTargetsModel.fromJson(targets),
          );
        }
      }
      await _firestoreSync.updateLastSyncTime(
        userId,
        'nutrition',
        DateTime.now(),
      );
    }

    if (_hiveBody != null) {
      final bodyLastSync = await _firestoreSync.getLastSyncTime(
        userId,
        'body_progress',
      );
      final cloudEntries = await _firestoreSync.getBodyProgress(
        userId,
        since: bodyLastSync,
      );
      for (final json in cloudEntries) {
        final id = json['id'];
        if (id is! String || pendingBodyEntries.contains(id)) continue;
        await _hiveBody.saveBodyEntry(
          BodyEntryModel.fromJson(Map<String, dynamic>.from(json)),
        );
      }
      final deletedBodyIds =
          await _firestoreSync.getDeletedBodyProgressIds(userId);
      for (final id in deletedBodyIds) {
        if (!pendingBodyEntries.contains(id)) await _hiveBody.deleteBodyEntry(id);
      }
      await _firestoreSync.updateLastSyncTime(
        userId,
        'body_progress',
        DateTime.now(),
      );
    }
  }

  Set<String> _pendingIds(
    List<SyncAction> actions,
    String userId,
    SyncDataType dataType,
  ) =>
      actions
          .where(
            (action) =>
                action.data['userId'] == userId &&
                action.dataType == dataType,
          )
          .map((action) => action.dataId)
          .toSet();

  Future<void> _syncWorkoutAction(String userId, SyncAction action) async {
    switch (action.type) {
      case SyncActionType.create:
      case SyncActionType.update:
        await _firestoreSync.syncWorkout(
          userId,
          WorkoutModel.fromJson(action.data),
        );
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
        await _firestoreSync.syncProgram(
          userId,
          ActiveProgramModel.fromJson(action.data),
        );
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
        if (action.data['_syncKind'] == 'targets') {
          await _firestoreSync.syncNutritionTargets(userId, action.data);
        } else {
          await _firestoreSync.syncNutritionLog(userId, action.data);
        }
        break;
      case SyncActionType.delete:
        await _firestoreSync.deleteNutritionLog(userId, action.dataId);
        break;
    }
  }

  Future<void> _syncBodyProgressAction(String userId, SyncAction action) async {
    switch (action.type) {
      case SyncActionType.create:
      case SyncActionType.update:
        await _firestoreSync.syncBodyProgress(userId, action.data);
        break;
      case SyncActionType.delete:
        await _firestoreSync.deleteBodyProgress(userId, action.dataId);
        break;
    }
  }

  Future<void> _emitStatus() async {
    if (_syncStatusController.isClosed) return;
    final pendingCount = await _syncQueue.getPendingCount();
    final failedCount = await _syncQueue.getFailedCount();
    if (_syncStatusController.isClosed) return;

    _syncStatusController.add(
      SyncStatusEntity(
        isSyncing: _isSyncing,
        lastSyncTime: _lastSyncTime,
        pendingActions: pendingCount,
        failedActions: failedCount,
      ),
    );
  }

  Future<SyncStatusEntity> getCurrentStatus() async {
    return SyncStatusEntity(
      isSyncing: _isSyncing,
      lastSyncTime: _lastSyncTime,
      pendingActions: await _syncQueue.getPendingCount(),
      failedActions: await _syncQueue.getFailedCount(),
    );
  }

  /// Resets the retry counter for failed entries, then retries the active
  /// user's pending actions.
  Future<void> retryFailedActions(String userId) async {
    final actions = await _syncQueue.getPendingActions();
    for (final action in actions) {
      if (action.data['userId'] == userId &&
          action.status == SyncStatus.failed) {
        await _syncQueue.updateActionStatus(
          action.id,
          SyncStatus.pending,
          error: null,
          retryCount: 0,
        );
      }
    }
    await syncAll(userId: userId);
  }
}
