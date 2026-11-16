import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
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
import '../../domain/entities/sync_action.dart';
import '../../domain/entities/sync_status.dart';
import '../../domain/services/sync_service.dart';
import '../datasources/firestore_sync_datasource.dart';
import '../datasources/hive_sync_queue_datasource.dart';

/// Concrete data-layer synchronization engine implementing [SyncEngine].
class SyncService implements SyncEngine {
  final HiveSyncQueueDataSource _syncQueue;
  final FirestoreSyncDataSource _firestoreSync;
  final HiveWorkoutDataSource _hiveWorkouts;
  final HiveActiveProgramDataSource _hivePrograms;
  final HiveNutritionDatasource? _hiveNutrition;
  final HiveBodyDataSource? _hiveBody;
  final Connectivity _connectivity;

  /// Resolves the currently signed-in user id for internal triggers.
  final String? Function()? currentUserIdProvider;

  final bool _enableInitialPush;

  /// Compile-time default for the cloud sync feature flag.
  static const bool kDefaultCloudSyncEnabled =
      bool.fromEnvironment('ENABLE_CLOUD_SYNC', defaultValue: true);

  bool _syncEnabled;

  @override
  bool get isSyncEnabled => _syncEnabled;

  @override
  void setSyncEnabled(bool enabled) {
    _syncEnabled = enabled;
  }

  final _syncStatusController = StreamController<SyncStatusEntity>.broadcast();

  @override
  Stream<SyncStatusEntity> get syncStatus => _syncStatusController.stream;

  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  Timer? _periodicSyncTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

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
    bool enableInitialPush = true,
    bool syncEnabled = kDefaultCloudSyncEnabled,
  })  : _enableInitialPush = enableInitialPush,
        _syncEnabled = syncEnabled,
        _syncQueue = syncQueue,
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

  @override
  Future<void> initialize() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        syncAll();
      }
    });

    _periodicSyncTimer?.cancel();
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => syncAll(),
    );

    await syncAll();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
    _syncStatusController.close();
  }

  @override
  Future<void> queueAction({
    required SyncActionType type,
    required SyncDataType dataType,
    required String dataId,
    required Map<String, dynamic> data,
  }) async {
    final uid = _resolveUserId() ?? (data['userId'] as String?);
    if (isLocalOnlyUserId(uid)) {
      AppLogger.debug('Local-only user ($uid), skipping sync queue action');
      return;
    }

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

    final connectivityResult = await _connectivity.checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      syncAll();
    }
  }

  @override
  Future<void> syncAll({String? userId}) async {
    if (!_syncEnabled) {
      AppLogger.debug('Cloud sync disabled via feature flag, skipping...');
      return;
    }
    if (_isSyncing) {
      AppLogger.debug('Sync already in progress, skipping...');
      return;
    }
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
      if (isLocalOnlyUserId(uid)) {
        AppLogger.debug('Local-only user ($uid), sync skipped');
        return;
      }

      if (_enableInitialPush) {
        await _enqueueInitialPushIfNeeded(uid);
      }

      await _pushLocalChanges(uid);
      await _pullCloudChanges(uid);
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

  bool _isUnowned(String? owner) =>
      RecordOwnershipRules.isLegacyUnownedOwner(owner);

  bool _isForeign(String? owner, String userId) =>
      !_isUnowned(owner) && owner != userId;

  Future<void> _enqueueInitialPushIfNeeded(String userId) async {
    try {
      if (await _syncQueue.hasCompletedInitialPush(userId)) return;

      final pending = await _syncQueue.getPendingActions();
      final queued = {
        for (final a in pending) '${a.dataType.name}:${a.dataId}',
      };

      var enqueued = 0;
      Future<void> enqueue({
        required SyncActionType type,
        required SyncDataType dataType,
        required String dataId,
        required Map<String, dynamic> data,
      }) async {
        final key = '${dataType.name}:$dataId';
        if (queued.contains(key)) return;
        queued.add(key);
        enqueued++;
        await queueAction(
          type: type,
          dataType: dataType,
          dataId: dataId,
          data: data,
        );
      }

      for (final workout in await _hiveWorkouts.getAllWorkouts()) {
        if (_isForeign(workout.userId, userId)) continue;
        var effective = workout;
        if (_isUnowned(workout.userId)) {
          effective = workout.copyWith(userId: userId);
          await _hiveWorkouts.saveWorkout(effective);
        }
        if (effective.deletedAt != null) {
          await enqueue(
            type: SyncActionType.delete,
            dataType: SyncDataType.workout,
            dataId: effective.id,
            data: {'id': effective.id, 'userId': userId},
          );
        } else {
          await enqueue(
            type: SyncActionType.update,
            dataType: SyncDataType.workout,
            dataId: effective.id,
            data: effective.toJson(),
          );
        }
      }

      final program = await _hivePrograms.loadActiveProgram(userId: userId);
      if (program != null && !_isForeign(program.userId, userId)) {
        var effective = program;
        if (_isUnowned(program.userId)) {
          effective = program.copyWith(userId: userId);
          await _hivePrograms.saveActiveProgram(effective, userId: userId);
        }
        await enqueue(
          type: SyncActionType.update,
          dataType: SyncDataType.program,
          dataId: effective.id,
          data: effective.toJson(),
        );
      }

      final nutrition = _hiveNutrition;
      if (nutrition != null) {
        for (final meal in await nutrition.getAllMeals()) {
          if (_isForeign(meal.userId, userId)) continue;
          var effective = meal;
          if (_isUnowned(meal.userId)) {
            effective = meal.copyWith(userId: userId);
            await nutrition.saveMealEntry(effective);
          }
          if (effective.deletedAt != null) {
            await enqueue(
              type: SyncActionType.delete,
              dataType: SyncDataType.nutrition,
              dataId: effective.id,
              data: {'id': effective.id, 'userId': userId},
            );
          } else {
            await enqueue(
              type: SyncActionType.update,
              dataType: SyncDataType.nutrition,
              dataId: effective.id,
              data: effective.toJson(),
            );
          }
        }

        final targets = await nutrition.getNutritionTargets(userId: userId);
        if (targets != null && !_isForeign(targets.userId, userId)) {
          var effective = targets;
          if (_isUnowned(targets.userId)) {
            effective = NutritionTargetsModel(
              userId: userId,
              macros: targets.macros,
              micros: targets.micros,
              vitamins: targets.vitamins,
              minerals: targets.minerals,
              createdAt: targets.createdAt,
              updatedAt: targets.updatedAt,
            );
            await nutrition.saveNutritionTargets(effective, userId: userId);
          }
          await enqueue(
            type: SyncActionType.update,
            dataType: SyncDataType.nutritionTargets,
            dataId: userId,
            data: effective.toJson(),
          );
        }
      }

      final body = _hiveBody;
      if (body != null) {
        for (final entry in await body.getAllBodyEntries()) {
          if (_isForeign(entry.userId, userId)) continue;
          var effective = entry;
          if (_isUnowned(entry.userId)) {
            effective = entry.copyWith(userId: userId);
            await body.saveBodyEntry(effective);
          }
          if (effective.deletedAt != null) {
            await enqueue(
              type: SyncActionType.delete,
              dataType: SyncDataType.bodyProgress,
              dataId: effective.id,
              data: {'id': effective.id, 'userId': userId},
            );
          } else {
            await enqueue(
              type: SyncActionType.update,
              dataType: SyncDataType.bodyProgress,
              dataId: effective.id,
              data: effective.toJson(),
            );
          }
        }
      }

      await _syncQueue.markInitialPushComplete(userId);
      AppLogger.debug(
        '✅ Initial full push for $userId: enqueued $enqueued record(s)',
      );
    } catch (e) {
      AppLogger.debug('❌ Initial full push scan failed (will retry): $e');
    }
  }

  Future<void> _pushLocalChanges(String userId) async {
    final pendingActions = await _syncQueue.getPendingActions();
    final latestByRecordKey = <String, SyncAction>{};
    final supersededIds = <String>[];

    for (final action in pendingActions) {
      if (action.retryCount >= 3) {
        AppLogger.debug('Action ${action.id} exceeded max retries, skipping');
        continue;
      }

      final owner = action.data['userId'];
      if (owner is String && owner.isNotEmpty && owner != userId) {
        continue;
      }

      final recordKey = '${action.dataType.name}:${action.dataId}';
      final previous = latestByRecordKey[recordKey];
      if (previous != null) {
        supersededIds.add(previous.id);
      }
      latestByRecordKey[recordKey] = action;
    }

    for (final supersededId in supersededIds) {
      await _syncQueue.updateActionStatus(supersededId, SyncStatus.completed);
    }

    for (final action in latestByRecordKey.values) {
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
        AppLogger.debug(
            '✅ Synced ${action.dataType} ${action.type} for ${action.dataId}');
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
        break;
    }
  }

  Future<Map<String, DateTime>> _getUnpushedActionClocks(String userId) async {
    final pendingActions = await _syncQueue.getPendingActions();
    final map = <String, DateTime>{};
    for (final action in pendingActions) {
      final owner = action.data['userId'];
      if (owner is String && owner.isNotEmpty && owner != userId) {
        continue;
      }
      final key = '${action.dataType.name}:${action.dataId}';
      final updatedAtIso = action.data['updatedAt'] as String?;
      final clock = SyncConflictPolicy.parseIso(updatedAtIso) ?? action.timestamp;
      final existing = map[key];
      if (existing == null || clock.isAfter(existing)) {
        map[key] = clock;
      }
    }
    return map;
  }

  Future<void> _pullCloudChanges(String userId) async {
    final unpushedClocks = await _getUnpushedActionClocks(userId);
    await _guardLeg('workouts', () => _pullWorkouts(userId, unpushedClocks));
    await _guardLeg(
        'program', () => _pullActiveProgram(userId, unpushedClocks));
    if (_hiveNutrition != null) {
      await _guardLeg('meals', () => _pullMeals(userId, unpushedClocks));
      await _guardLeg(
        'nutrition targets',
        () => _pullNutritionTargets(userId, unpushedClocks),
      );
    }
    if (_hiveBody != null) {
      await _guardLeg(
        'body entries',
        () => _pullBodyEntries(userId, unpushedClocks),
      );
    }
  }

  Future<void> _guardLeg(String label, Future<void> Function() leg) async {
    try {
      await leg();
    } catch (e) {
      AppLogger.debug('❌ Failed to pull $label: $e');
    }
  }

  Future<void> _pullCollection<T>({
    required String cursorKey,
    required SyncDataType dataType,
    required String label,
    required String userId,
    required Map<String, DateTime> unpushedClocks,
    required Future<List<T>> Function(DateTime? since) fetchCloud,
    required Future<List<T>> Function() loadLocal,
    required Future<void> Function(T item) saveLocal,
    required Future<void> Function(String id) deleteLocal,
    required String Function(T item) idOf,
    required DateTime Function(T item) clockOf,
    required String? Function(T item) deletedAtOf,
    required Map<String, dynamic> Function(T item) toJson,
  }) async {
    final since = await _syncQueue.getCursor(cursorKey, userId: userId);
    final cloudItems = await fetchCloud(since);
    if (cloudItems.isEmpty) return;

    final locals = {
      for (final item in await loadLocal()) idOf(item): item,
    };
    for (final cloud in cloudItems) {
      final id = idOf(cloud);
      final local = locals[id];
      final unpushedClock = unpushedClocks['${dataType.name}:$id'];
      final effectiveLocalClock = SyncConflictPolicy.maxClock(
        local == null ? null : clockOf(local),
        unpushedClock,
      );

      final deletedAt = deletedAtOf(cloud);
      if (deletedAt != null) {
        final tombstoneClock =
            SyncConflictPolicy.parseIso(deletedAt) ?? clockOf(cloud);
        if (effectiveLocalClock == null ||
            !SyncConflictPolicy.isAfter(effectiveLocalClock, tombstoneClock)) {
          await deleteLocal(id);
          AppLogger.debug('📥 Deleted $label $id (tombstone)');
        }
        continue;
      }

      if ((local == null && unpushedClock == null) ||
          (effectiveLocalClock != null &&
              SyncConflictPolicy.shouldAcceptCloud(
                cloudClock: clockOf(cloud),
                localClock: effectiveLocalClock,
                cloudJson: toJson(cloud),
                localJson: local == null ? null : toJson(local),
                hasUnpushedLocalEdit: unpushedClock != null,
              ))) {
        await saveLocal(cloud);
        AppLogger.debug('📥 Pulled $label $id');
      }
    }

    final maxTimestamp = _firestoreSync.getLastServerTimestamp(cursorKey) ??
        cloudItems.map(clockOf).reduce((a, b) => a.isAfter(b) ? a : b);
    await _advanceCursorWithTimestamp(cursorKey, userId, maxTimestamp);
  }

  Future<void> _pullWorkouts(
    String userId,
    Map<String, DateTime> unpushedClocks,
  ) =>
      _pullCollection<WorkoutModel>(
        cursorKey: _workoutsKey,
        dataType: SyncDataType.workout,
        label: 'workout',
        userId: userId,
        unpushedClocks: unpushedClocks,
        fetchCloud: (since) => _firestoreSync.getWorkouts(userId, since: since),
        loadLocal: _hiveWorkouts.getAllWorkouts,
        saveLocal: _hiveWorkouts.saveWorkout,
        deleteLocal: _hiveWorkouts.deleteWorkout,
        idOf: (w) => w.id,
        clockOf: _workoutClock,
        deletedAtOf: (w) => w.deletedAt,
        toJson: (w) => w.toJson(),
      );

  Future<void> _pullActiveProgram(
    String userId,
    Map<String, DateTime> unpushedClocks,
  ) async {
    final since = await _syncQueue.getCursor(_programsKey, userId: userId);
    final cloud = await _firestoreSync.getActiveProgram(userId, since: since);
    if (cloud != null) {
      final local = await _hivePrograms.loadActiveProgram(userId: userId);
      final unpushedClock =
          unpushedClocks['${SyncDataType.program.name}:${cloud.id}'];
      final effectiveLocalClock = SyncConflictPolicy.maxClock(
        SyncConflictPolicy.parseIso(local?.updatedAt),
        unpushedClock,
      );
      if ((local == null && unpushedClock == null) ||
          SyncConflictPolicy.shouldAcceptCloud(
            cloudClock: SyncConflictPolicy.parseIso(cloud.updatedAt),
            localClock: effectiveLocalClock,
            cloudJson: cloud.toJson(),
            localJson: local?.toJson(),
            hasUnpushedLocalEdit: unpushedClock != null,
          )) {
        await _hivePrograms.saveActiveProgram(cloud, userId: userId);
        AppLogger.debug('📥 Pulled active program ${cloud.id}');
      }
      final maxTimestamp = _firestoreSync.getLastServerTimestamp(_programsKey) ??
          SyncConflictPolicy.parseIso(cloud.updatedAt);
      await _advanceCursorWithTimestamp(_programsKey, userId, maxTimestamp);
    }
  }

  Future<void> _pullMeals(
    String userId,
    Map<String, DateTime> unpushedClocks,
  ) =>
      _pullCollection<MealModel>(
        cursorKey: _nutritionKey,
        dataType: SyncDataType.nutrition,
        label: 'meal',
        userId: userId,
        unpushedClocks: unpushedClocks,
        fetchCloud: (since) => _firestoreSync.getMeals(userId, since: since),
        loadLocal: _hiveNutrition!.getAllMeals,
        saveLocal: _hiveNutrition.saveMealEntry,
        deleteLocal: _hiveNutrition.deleteMealEntry,
        idOf: (m) => m.id,
        clockOf: _mealClock,
        deletedAtOf: (m) => m.deletedAt,
        toJson: (m) => m.toJson(),
      );

  Future<void> _pullBodyEntries(
    String userId,
    Map<String, DateTime> unpushedClocks,
  ) =>
      _pullCollection<BodyEntryModel>(
        cursorKey: _bodyProgressKey,
        dataType: SyncDataType.bodyProgress,
        label: 'body entry',
        userId: userId,
        unpushedClocks: unpushedClocks,
        fetchCloud: (since) =>
            _firestoreSync.getBodyEntries(userId, since: since),
        loadLocal: _hiveBody!.getAllBodyEntries,
        saveLocal: _hiveBody.saveBodyEntry,
        deleteLocal: _hiveBody.deleteBodyEntry,
        idOf: (e) => e.id,
        clockOf: _bodyClock,
        deletedAtOf: (e) => e.deletedAt,
        toJson: (e) => e.toJson(),
      );

  Future<void> _pullNutritionTargets(
    String userId,
    Map<String, DateTime> unpushedClocks,
  ) async {
    final hiveNutrition = _hiveNutrition!;
    final cloud = await _firestoreSync.getNutritionTargets(userId);
    if (cloud == null) return;
    final local = await hiveNutrition.getNutritionTargets(userId: userId);
    final unpushedClock =
        unpushedClocks['${SyncDataType.nutritionTargets.name}:$userId'];
    final effectiveLocalClock = SyncConflictPolicy.maxClock(
      SyncConflictPolicy.parseIso(local?.updatedAt),
      unpushedClock,
    );
    if ((local == null && unpushedClock == null) ||
        SyncConflictPolicy.shouldAcceptCloud(
          cloudClock: SyncConflictPolicy.parseIso(cloud.updatedAt),
          localClock: effectiveLocalClock,
          cloudJson: cloud.toJson(),
          localJson: local?.toJson(),
          hasUnpushedLocalEdit: unpushedClock != null,
        )) {
      await hiveNutrition.saveNutritionTargets(cloud, userId: userId);
      AppLogger.debug('📥 Pulled nutrition targets');
    }
  }

  DateTime _workoutClock(WorkoutModel w) =>
      SyncConflictPolicy.parseIso(w.updatedAt) ??
      SyncConflictPolicy.parseIso(w.date) ??
      SyncConflictPolicy.epoch;

  DateTime _mealClock(MealModel m) =>
      SyncConflictPolicy.parseIso(m.updatedAt) ??
      SyncConflictPolicy.parseIso(m.timestamp) ??
      SyncConflictPolicy.epoch;

  DateTime _bodyClock(BodyEntryModel e) =>
      SyncConflictPolicy.parseIso(e.updatedAt) ??
      SyncConflictPolicy.parseIso(e.date) ??
      SyncConflictPolicy.epoch;

  Future<void> _advanceCursorWithTimestamp(
    String key,
    String userId,
    DateTime? timestamp,
  ) async {
    if (timestamp != null) {
      await _syncQueue.setCursor(
        key,
        timestamp,
        userId: userId,
      );
    }
  }

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

  @override
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

  @override
  Future<void> retryFailedActions(String userId) async {
    final pendingActions = await _syncQueue.getPendingActions();
    final failedActions =
        pendingActions.where((a) => a.status == SyncStatus.failed);

    for (final action in failedActions) {
      await _syncQueue.updateActionStatus(
        action.id,
        SyncStatus.pending,
        retryCount: 0,
      );
    }

    await syncAll(userId: userId);
  }
}

