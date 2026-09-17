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
import '../../../workout/data/models/program_model.dart';

/// Core sync service that manages data synchronization between Hive and Firestore
class SyncService {
  final HiveSyncQueueDataSource _syncQueue;
  final FirestoreSyncDataSource _firestoreSync;
  final HiveWorkoutDataSource _hiveWorkouts;
  final HiveActiveProgramDataSource _hivePrograms;
  final Connectivity _connectivity;

  final _syncStatusController = StreamController<SyncStatusEntity>.broadcast();
  Stream<SyncStatusEntity> get syncStatus => _syncStatusController.stream;

  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  Timer? _periodicSyncTimer;

  SyncService({
    required HiveSyncQueueDataSource syncQueue,
    required FirestoreSyncDataSource firestoreSync,
    required HiveWorkoutDataSource hiveWorkouts,
    required HiveActiveProgramDataSource hivePrograms,
    Connectivity? connectivity,
  })  : _syncQueue = syncQueue,
        _firestoreSync = firestoreSync,
        _hiveWorkouts = hiveWorkouts,
        _hivePrograms = hivePrograms,
        _connectivity = connectivity ?? Connectivity();

  /// Initialize sync service
  Future<void> initialize() async {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
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
    if (connectivityResult != ConnectivityResult.none) {
      syncAll();
    }
  }

  /// Sync all pending actions and pull latest data from cloud
  Future<void> syncAll({String? userId}) async {
    if (_isSyncing) {
      print('Sync already in progress, skipping...');
      return;
    }

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      print('No internet connection, sync skipped');
      return;
    }

    if (userId == null) {
      print('No user ID provided, sync skipped');
      return;
    }

    _isSyncing = true;
    _emitStatus();

    try {
      // Step 1: Push local changes to cloud
      await _pushLocalChanges(userId);

      // Step 2: Pull cloud changes to local
      await _pullCloudChanges(userId);

      // Step 3: Clean up completed actions
      await _syncQueue.clearCompleted();

      _lastSyncTime = DateTime.now();
      print('✅ Sync completed successfully');
    } catch (e) {
      print('❌ Sync failed: $e');
    } finally {
      _isSyncing = false;
      _emitStatus();
    }
  }

  /// Push local changes to cloud
  Future<void> _pushLocalChanges(String userId) async {
    final pendingActions = await _syncQueue.getPendingActions();

    for (final action in pendingActions) {
      // Skip if too many retries
      if (action.retryCount >= 3) {
        print('Action ${action.id} exceeded max retries, skipping');
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
        }

        await _syncQueue.updateActionStatus(action.id, SyncStatus.completed);
        print('✅ Synced ${action.dataType} ${action.type} for ${action.dataId}');
      } catch (e) {
        await _syncQueue.updateActionStatus(
          action.id,
          SyncStatus.failed,
          error: e.toString(),
        );
        print('❌ Failed to sync ${action.dataType} ${action.type}: $e');
      }
    }
  }

  /// Pull cloud changes to local
  Future<void> _pullCloudChanges(String userId) async {
    try {
      // Get last sync time for each data type
      final workoutLastSync = await _firestoreSync.getLastSyncTime(userId, 'workouts');
      final programLastSync = await _firestoreSync.getLastSyncTime(userId, 'programs');

      // Pull workouts
      final cloudWorkouts = await _firestoreSync.getWorkouts(userId, since: workoutLastSync);
      for (final workout in cloudWorkouts) {
        // Check if local version exists
        final localWorkouts = await _hiveWorkouts.getAllWorkouts();
        final localWorkout = localWorkouts.where((w) => w.id == workout.id).firstOrNull;

        // Conflict resolution: latest update wins
        if (localWorkout == null) {
          // New workout from cloud, save locally
          await _hiveWorkouts.saveWorkout(workout);
          print('📥 Pulled new workout ${workout.id}');
        } else {
          // Compare timestamps (simplified - in production, use proper timestamp fields)
          final cloudDate = DateTime.parse(workout.date);
          final localDate = DateTime.parse(localWorkout.date);

          if (cloudDate.isAfter(localDate)) {
            // Cloud version is newer, update local
            await _hiveWorkouts.saveWorkout(workout);
            print('📥 Updated workout ${workout.id} from cloud');
          }
        }
      }

      // Pull active program
      final cloudProgram = await _firestoreSync.getActiveProgram(userId);
      if (cloudProgram != null) {
        final localProgram = await _hivePrograms.loadActiveProgram();

        if (localProgram == null) {
          // New program from cloud
          await _hivePrograms.saveActiveProgram(cloudProgram);
          print('📥 Pulled new program ${cloudProgram.id}');
        } else {
          // Compare timestamps (simplified)
          // In production, add updatedAt field to ProgramModel
          await _hivePrograms.saveActiveProgram(cloudProgram);
          print('📥 Updated program ${cloudProgram.id} from cloud');
        }
      }

      // Update last sync times
      await _firestoreSync.updateLastSyncTime(userId, 'workouts', DateTime.now());
      await _firestoreSync.updateLastSyncTime(userId, 'programs', DateTime.now());
    } catch (e) {
      print('❌ Failed to pull cloud changes: $e');
      rethrow;
    }
  }

  /// Sync workout action
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

  /// Sync program action
  Future<void> _syncProgramAction(String userId, SyncAction action) async {
    switch (action.type) {
      case SyncActionType.create:
      case SyncActionType.update:
        final program = ProgramModel.fromJson(action.data);
        await _firestoreSync.syncProgram(userId, program);
        break;
      case SyncActionType.delete:
        await _firestoreSync.deleteProgram(userId, action.dataId);
        break;
    }
  }

  /// Sync nutrition action
  Future<void> _syncNutritionAction(String userId, SyncAction action) async {
    switch (action.type) {
      case SyncActionType.create:
      case SyncActionType.update:
        await _firestoreSync.syncNutritionLog(userId, action.data);
        break;
      case SyncActionType.delete:
        // Implement nutrition delete if needed
        break;
    }
  }

  /// Sync body progress action
  Future<void> _syncBodyProgressAction(String userId, SyncAction action) async {
    switch (action.type) {
      case SyncActionType.create:
      case SyncActionType.update:
        await _firestoreSync.syncBodyProgress(userId, action.data);
        break;
      case SyncActionType.delete:
        // Implement body progress delete if needed
        break;
    }
  }

  /// Emit current sync status
  Future<void> _emitStatus() async {
    final pendingCount = await _syncQueue.getPendingCount();
    final failedCount = await _syncQueue.getFailedCount();

    final status = SyncStatusEntity(
      isSyncing: _isSyncing,
      lastSyncTime: _lastSyncTime,
      pendingActions: pendingCount,
      failedActions: failedCount,
    );

    _syncStatusController.add(status);
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
