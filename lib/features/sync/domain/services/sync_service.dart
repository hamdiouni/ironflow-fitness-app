import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import 'dart:async';
import 'dart:convert';
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

  /// Whether the one-time initial full-push scan may run (see
  /// [_enqueueInitialPushIfNeeded]). The app enables this only with real
  /// Firebase auth: the scan *stamps* unowned local history with the
  /// current uid, and doing that under a throwaway mock uid would make
  /// the whole history look foreign-owned once real auth is enabled.
  final bool _enableInitialPush;

  /// Compile-time default for the cloud sync feature flag.
  static const bool kDefaultCloudSyncEnabled =
      bool.fromEnvironment('ENABLE_CLOUD_SYNC', defaultValue: true);

  bool _syncEnabled;

  /// Whether cloud sync push/pull is currently enabled.
  bool get isSyncEnabled => _syncEnabled;

  /// Toggle cloud sync at runtime (e.g. via remote config or user setting).
  void setSyncEnabled(bool enabled) {
    _syncEnabled = enabled;
  }

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
    if (!_syncEnabled) {
      AppLogger.debug('Cloud sync disabled via feature flag, skipping...');
      return;
    }
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

      // Step 0 (Phase 3): first sync for this user on this device —
      // enqueue the full local history so pre-account data reaches the
      // cloud. One-time per user (marker in app_settings); a failed
      // scan leaves no marker and is retried next sync. Disabled under
      // mock auth (see _enableInitialPush) so local history is not
      // bulk-stamped with a throwaway mock uid.
      if (_enableInitialPush) {
        await _enqueueInitialPushIfNeeded(uid);
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
  // Initial full push (Phase 3, deferred from Phase 2 §8.8)
  // ---------------------------------------------------------------------------

  bool _isUnowned(String? owner) =>
      RecordOwnershipRules.isLegacyUnownedOwner(owner);

  bool _isForeign(String? owner, String userId) =>
      !_isUnowned(owner) && owner != userId;

  /// One-time per-user scan: enqueue every local record this user owns
  /// so a history built up before signing in (or before sync existed)
  /// uploads in full. Unowned/guest records are first stamped with the
  /// user's id; other accounts' records on a shared device are skipped.
  /// Already-queued records are not duplicated, and tombstones enqueue
  /// as deletes. Repositories' save-time stamps cover everything
  /// written after this scan, so it only ever needs to run once.
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

      // Workouts
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

      // Active program (stored per user locally)
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

      // Meals + nutrition targets
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

      // Body entries
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
      // No marker is set, so the scan retries on the next sync; the
      // pending-queue dedupe above makes a partial scan safe to redo.
      AppLogger.debug('❌ Initial full push scan failed (will retry): $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Push
  // ---------------------------------------------------------------------------

  /// Push local changes to cloud.
  ///
  /// Coalesces multiple pending actions for the same `(userId, dataType, dataId)`
  /// in FIFO order so only the latest effective snapshot/tombstone is pushed to
  /// Firestore and superseded intermediate edits are marked completed.
  Future<void> _pushLocalChanges(String userId) async {
    final pendingActions = await _syncQueue.getPendingActions();

    // Group eligible actions by (dataType, dataId) in FIFO order to coalesce
    // superseded intermediate writes for the same record.
    final latestByRecordKey = <String, SyncAction>{};
    final supersededIds = <String>[];

    for (final action in pendingActions) {
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
      final clock = _parse(updatedAtIso) ?? action.timestamp;
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
    await _guardLeg('program', () => _pullActiveProgram(userId, unpushedClocks));
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

  Future<void> _pullWorkouts(
    String userId,
    Map<String, DateTime> unpushedClocks,
  ) async {
    final since = await _syncQueue.getCursor(_workoutsKey, userId: userId);
    final cloudWorkouts = await _firestoreSync.getWorkouts(userId, since: since);
    if (cloudWorkouts.isNotEmpty) {
      final locals = {
        for (final w in await _hiveWorkouts.getAllWorkouts()) w.id: w,
      };
      for (final cloud in cloudWorkouts) {
        final local = locals[cloud.id];
        final unpushedClock =
            unpushedClocks['${SyncDataType.workout.name}:${cloud.id}'];
        final effectiveLocalClock = _maxClock(
          local == null ? null : _workoutClock(local),
          unpushedClock,
        );

        if (cloud.deletedAt != null) {
          final tombstoneClock = _parse(cloud.deletedAt) ?? _workoutClock(cloud);
          if (effectiveLocalClock == null ||
              !_isAfter(effectiveLocalClock, tombstoneClock)) {
            await _hiveWorkouts.deleteWorkout(cloud.id);
            AppLogger.debug('📥 Deleted workout ${cloud.id} (tombstone)');
          }
          continue;
        }
        if (local == null && unpushedClock == null) {
          await _hiveWorkouts.saveWorkout(cloud);
          AppLogger.debug('📥 Pulled workout ${cloud.id}');
        } else if (effectiveLocalClock != null &&
            _shouldAcceptCloud(
              cloudClock: _workoutClock(cloud),
              localClock: effectiveLocalClock,
              cloudJson: cloud.toJson(),
              localJson: local?.toJson(),
              hasUnpushedLocalEdit: unpushedClock != null,
            )) {
          await _hiveWorkouts.saveWorkout(cloud);
          AppLogger.debug('📥 Pulled workout ${cloud.id}');
        }
      }
    }
    await _advanceCursor(_workoutsKey, userId);
  }

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
      final effectiveLocalClock = _maxClock(
        _parse(local?.updatedAt),
        unpushedClock,
      );
      if ((local == null && unpushedClock == null) ||
          _shouldAcceptCloud(
            cloudClock: _parse(cloud.updatedAt),
            localClock: effectiveLocalClock,
            cloudJson: cloud.toJson(),
            localJson: local?.toJson(),
            hasUnpushedLocalEdit: unpushedClock != null,
          )) {
        // Full state (day index + completed days) comes with the model;
        // the old pull reconstructed a fresh ActiveProgram at day 0.
        await _hivePrograms.saveActiveProgram(cloud, userId: userId);
        AppLogger.debug('📥 Pulled active program ${cloud.id}');
      }
    }
    await _advanceCursor(_programsKey, userId);
  }

  Future<void> _pullMeals(
    String userId,
    Map<String, DateTime> unpushedClocks,
  ) async {
    final hiveNutrition = _hiveNutrition!;
    final since = await _syncQueue.getCursor(_nutritionKey, userId: userId);
    final cloudMeals = await _firestoreSync.getMeals(userId, since: since);
    if (cloudMeals.isNotEmpty) {
      final locals = {
        for (final m in await hiveNutrition.getAllMeals()) m.id: m,
      };
      for (final cloud in cloudMeals) {
        final local = locals[cloud.id];
        final unpushedClock =
            unpushedClocks['${SyncDataType.nutrition.name}:${cloud.id}'];
        final effectiveLocalClock = _maxClock(
          local == null ? null : _mealClock(local),
          unpushedClock,
        );

        if (cloud.deletedAt != null) {
          final tombstoneClock = _parse(cloud.deletedAt) ?? _mealClock(cloud);
          if (effectiveLocalClock == null ||
              !_isAfter(effectiveLocalClock, tombstoneClock)) {
            await hiveNutrition.deleteMealEntry(cloud.id);
            AppLogger.debug('📥 Deleted meal ${cloud.id} (tombstone)');
          }
          continue;
        }
        if ((local == null && unpushedClock == null) ||
            _shouldAcceptCloud(
              cloudClock: _mealClock(cloud),
              localClock: effectiveLocalClock,
              cloudJson: cloud.toJson(),
              localJson: local?.toJson(),
              hasUnpushedLocalEdit: unpushedClock != null,
            )) {
          await hiveNutrition.saveMealEntry(cloud);
          AppLogger.debug('📥 Pulled meal ${cloud.id}');
        }
      }
    }
    await _advanceCursor(_nutritionKey, userId);
  }

  Future<void> _pullBodyEntries(
    String userId,
    Map<String, DateTime> unpushedClocks,
  ) async {
    final hiveBody = _hiveBody!;
    final since = await _syncQueue.getCursor(_bodyProgressKey, userId: userId);
    final cloudEntries =
        await _firestoreSync.getBodyEntries(userId, since: since);
    if (cloudEntries.isNotEmpty) {
      final locals = {
        for (final e in await hiveBody.getAllBodyEntries()) e.id: e,
      };
      for (final cloud in cloudEntries) {
        final local = locals[cloud.id];
        final unpushedClock =
            unpushedClocks['${SyncDataType.bodyProgress.name}:${cloud.id}'];
        final effectiveLocalClock = _maxClock(
          local == null ? null : _bodyClock(local),
          unpushedClock,
        );

        if (cloud.deletedAt != null) {
          final tombstoneClock = _parse(cloud.deletedAt) ?? _bodyClock(cloud);
          if (effectiveLocalClock == null ||
              !_isAfter(effectiveLocalClock, tombstoneClock)) {
            await hiveBody.deleteBodyEntry(cloud.id);
            AppLogger.debug('📥 Deleted body entry ${cloud.id} (tombstone)');
          }
          continue;
        }
        if ((local == null && unpushedClock == null) ||
            _shouldAcceptCloud(
              cloudClock: _bodyClock(cloud),
              localClock: effectiveLocalClock,
              cloudJson: cloud.toJson(),
              localJson: local?.toJson(),
              hasUnpushedLocalEdit: unpushedClock != null,
            )) {
          await hiveBody.saveBodyEntry(cloud);
          AppLogger.debug('📥 Pulled body entry ${cloud.id}');
        }
      }
    }
    await _advanceCursor(_bodyProgressKey, userId);
  }

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
    final effectiveLocalClock = _maxClock(
      _parse(local?.updatedAt),
      unpushedClock,
    );
    if ((local == null && unpushedClock == null) ||
        _shouldAcceptCloud(
          cloudClock: _parse(cloud.updatedAt),
          localClock: effectiveLocalClock,
          cloudJson: cloud.toJson(),
          localJson: local?.toJson(),
          hasUnpushedLocalEdit: unpushedClock != null,
        )) {
      await hiveNutrition.saveNutritionTargets(cloud, userId: userId);
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

  DateTime? _maxClock(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }

  /// Deterministic Last-Write-Wins (LWW) decision with unpushed local edit
  /// protection and canonical JSON tie-breaking on equal timestamps.
  bool _shouldAcceptCloud({
    required DateTime? cloudClock,
    required DateTime? localClock,
    Map<String, dynamic>? cloudJson,
    Map<String, dynamic>? localJson,
    bool hasUnpushedLocalEdit = false,
  }) {
    final c = cloudClock ?? _epoch;
    final l = localClock ?? _epoch;
    if (c.isAfter(l)) return true;
    if (c.isBefore(l)) return false;

    // Equal timestamps: if local has an unpushed edit waiting in the outbox,
    // never overwrite it with a tie.
    if (hasUnpushedLocalEdit) return false;

    // Deterministic tie-breaker across devices when both records are synced
    // and share the exact same timestamp millisecond.
    if (cloudJson != null && localJson != null) {
      final canonicalCloud = _canonicalizeJson(cloudJson);
      final canonicalLocal = _canonicalizeJson(localJson);
      return canonicalCloud.compareTo(canonicalLocal) > 0;
    }
    return false;
  }

  String _canonicalizeJson(Map<String, dynamic> map) {
    final sortedKeys = map.keys.toList()..sort();
    final ordered = <String, dynamic>{
      for (final k in sortedKeys) k: map[k],
    };
    return jsonEncode(ordered);
  }

  Future<void> _advanceCursor(String key, String userId) async {
    await _syncQueue.setCursor(
      key,
      DateTime.now().subtract(_cursorSafetyMargin),
      userId: userId,
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
