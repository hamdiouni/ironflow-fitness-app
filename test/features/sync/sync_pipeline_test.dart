import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/core/models/sync_operation.dart';
import 'package:progression_tracker/features/sync/data/datasources/firestore_sync_datasource.dart';
import 'package:progression_tracker/features/sync/data/datasources/hive_sync_queue_datasource.dart';
import 'package:progression_tracker/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:progression_tracker/features/sync/domain/entities/sync_action.dart';
import 'package:progression_tracker/features/sync/domain/services/sync_service.dart';
import 'package:progression_tracker/features/sync/domain/usecases/sync_pending_operations_use_case.dart';
import 'package:progression_tracker/features/workout/data/datasources/hive_active_program_datasource.dart';
import 'package:progression_tracker/features/workout/data/datasources/hive_workout_data_source.dart';
import 'package:progression_tracker/features/workout/data/models/active_program_model.dart';
import 'package:progression_tracker/features/workout/data/models/workout_model.dart';
import 'package:progression_tracker/features/workout/data/models/workout_program_model.dart';
import 'package:progression_tracker/features/workout/data/repositories/synced_workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';

class FakeConnectivity implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value([ConnectivityResult.wifi]);
}

class FakeFirestoreSyncDataSource implements FirestoreSyncDataSource {
  final List<SyncOperation> syncedBatches = [];
  final List<WorkoutModel> syncedWorkouts = [];
  final List<String> deletedWorkoutIds = [];
  final List<ActiveProgramModel> syncedPrograms = [];
  DateTime? lastWorkoutSync;
  DateTime? lastProgramSync;
  ActiveProgramModel? activeProgramToReturn;
  DateTime? recordedSinceFilter;

  @override
  Future<void> syncBatch(List<SyncOperation> operations) async {
    syncedBatches.addAll(operations);
  }

  @override
  Future<void> syncWorkout(String userId, WorkoutModel workout) async {
    syncedWorkouts.add(workout);
  }

  @override
  Future<List<WorkoutModel>> getWorkouts(String userId, {DateTime? since}) async {
    return syncedWorkouts;
  }

  @override
  Future<List<String>> getDeletedWorkoutIds(String userId) async => [];

  @override
  Future<void> deleteWorkout(String userId, String workoutId) async {
    deletedWorkoutIds.add(workoutId);
  }

  @override
  Future<void> syncProgram(String userId, ActiveProgramModel program) async {
    syncedPrograms.add(program);
  }

  @override
  Future<ActiveProgramModel?> getActiveProgram(String userId, {DateTime? since}) async {
    recordedSinceFilter = since;
    return activeProgramToReturn;
  }

  @override
  Future<void> deleteProgram(String userId, String programId) async {}

  @override
  Future<void> syncNutritionLog(String userId, Map<String, dynamic> log) async {}

  @override
  Future<List<Map<String, dynamic>>> getNutritionLogs(String userId, {DateTime? since}) async => [];

  @override
  Future<List<String>> getDeletedNutritionLogIds(String userId) async => [];

  @override
  Future<void> deleteNutritionLog(String userId, String mealId) async {}

  @override
  Future<void> syncNutritionTargets(String userId, Map<String, dynamic> targets) async {}

  @override
  Future<Map<String, dynamic>?> getNutritionTargets(String userId) async => null;

  @override
  Future<void> syncBodyProgress(String userId, Map<String, dynamic> progress) async {}

  @override
  Future<List<Map<String, dynamic>>> getBodyProgress(String userId, {DateTime? since}) async => [];

  @override
  Future<List<String>> getDeletedBodyProgressIds(String userId) async => [];

  @override
  Future<void> deleteBodyProgress(String userId, String entryId) async {}

  @override
  Future<DateTime?> getLastSyncTime(String userId, String dataType) async {
    if (dataType == 'workouts') return lastWorkoutSync;
    if (dataType == 'programs') return lastProgramSync;
    return null;
  }

  @override
  Future<void> updateLastSyncTime(String userId, String dataType, DateTime time) async {
    if (dataType == 'workouts') lastWorkoutSync = time;
    if (dataType == 'programs') lastProgramSync = time;
  }
}

class FakeHiveSyncQueueDataSource implements HiveSyncQueueDataSource {
  final List<SyncAction> actions = [];

  @override
  Future<void> addAction(SyncAction action) async {
    actions.add(action);
  }

  @override
  Future<List<SyncAction>> getPendingActions() async {
    return actions
        .where((a) =>
            a.status == SyncStatus.pending ||
            a.status == SyncStatus.syncing ||
            a.status == SyncStatus.failed)
        .toList();
  }

  @override
  Future<void> updateActionStatus(
    String id,
    SyncStatus status, {
    String? error,
    int? retryCount,
  }) async {
    final idx = actions.indexWhere((a) => a.id == id);
    if (idx != -1) {
      actions[idx] = actions[idx].copyWith(
        status: status,
        error: error,
        retryCount: retryCount ?? actions[idx].retryCount,
      );
    }
  }

  @override
  Future<void> deleteAction(String id) async {
    actions.removeWhere((a) => a.id == id);
  }

  @override
  Future<void> clearCompleted() async {
    actions.removeWhere((a) => a.status == SyncStatus.completed);
  }

  @override
  Future<int> getPendingCount() async {
    return actions.where((a) => a.status == SyncStatus.pending).length;
  }

  @override
  Future<int> getFailedCount() async {
    return actions.where((a) => a.status == SyncStatus.failed).length;
  }

  Future<void> clearAll() async {
    actions.clear();
  }
}

class FakeHiveWorkoutDataSource implements HiveWorkoutDataSource {
  final Map<String, WorkoutModel> storage = {};

  @override
  Future<void> saveWorkout(WorkoutModel workout) async {
    storage[workout.id] = workout;
  }

  @override
  Future<List<WorkoutModel>> getAllWorkouts() async => storage.values.toList();

  @override
  Future<void> deleteWorkout(String id) async {
    storage.remove(id);
  }

  @override
  Future<int> getWorkoutCount() async => storage.length;

  @override
  Future<List<WorkoutModel>> getWorkoutsPaginated({int offset = 0, int limit = 20}) async =>
      storage.values.skip(offset).take(limit).toList();
}

class FakeHiveActiveProgramDataSource implements HiveActiveProgramDataSource {
  ActiveProgramModel? current;

  @override
  Future<ActiveProgramModel?> loadActiveProgram() async => current;

  @override
  Future<void> saveActiveProgram(ActiveProgramModel program) async {
    current = program;
  }

  @override
  Future<void> clearActiveProgram() async {
    current = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sync_pipeline_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('SyncRepositoryImpl', () {
    test('syncBatch forwards operations to Firestore dataSource', () async {
      final fakeDataSource = FakeFirestoreSyncDataSource();
      final useCase = SyncPendingOperationsUseCase(fakeDataSource);
      final repo = SyncRepositoryImpl(dataSource: fakeDataSource, syncUseCase: useCase);

      expect(repo.dataSource, fakeDataSource);

      final List<SyncOperation> ops = [
        SyncOperation(
          id: 'op1',
          type: SyncOperationType.create,
          collection: 'workouts',
          documentId: 'w1',
          data: {'name': 'Legs'},
          createdAt: DateTime.now(),
          retryCount: 0,
        ),
      ];

      await repo.syncBatch(ops);
      expect(fakeDataSource.syncedBatches.length, 1);
      expect(fakeDataSource.syncedBatches.first.id, 'op1');
    });
  });

  group('SyncService with program filtering', () {
    test('passes programLastSync to getActiveProgram during cloud pull', () async {
      final fakeQueue = FakeHiveSyncQueueDataSource();
      final fakeFirestore = FakeFirestoreSyncDataSource();
      final fakeWorkouts = FakeHiveWorkoutDataSource();
      final fakePrograms = FakeHiveActiveProgramDataSource();

      final lastSyncDate = DateTime(2026, 4, 10);
      fakeFirestore.lastProgramSync = lastSyncDate;
      fakeFirestore.activeProgramToReturn = const ActiveProgramModel(
        id: 'prog1',
        program: WorkoutProgramModel(
          id: 'prog1',
          name: 'Hypertrophy 4-Day',
          description: 'Test program',
          durationWeeks: 8,
          difficulty: 'intermediate',
          days: [],
        ),
        currentDayIndex: 0,
        isActive: true,
      );

      final service = SyncService(
        syncQueue: fakeQueue,
        firestoreSync: fakeFirestore,
        hiveWorkouts: fakeWorkouts,
        hivePrograms: fakePrograms,
        connectivity: FakeConnectivity(),
      );

      await service.syncAll(userId: 'user_123');

      // Check program filter was passed
      expect(fakeFirestore.recordedSinceFilter, lastSyncDate);
      expect(fakePrograms.current?.id, 'prog1');
      service.dispose();
    });
  });

  group('SyncedWorkoutRepository', () {
    test('saveWorkout and deleteWorkout include userId and queue actions', () async {
      final fakeQueue = FakeHiveSyncQueueDataSource();
      final fakeFirestore = FakeFirestoreSyncDataSource();
      final fakeWorkouts = FakeHiveWorkoutDataSource();
      final fakePrograms = FakeHiveActiveProgramDataSource();

      final service = SyncService(
        syncQueue: fakeQueue,
        firestoreSync: fakeFirestore,
        hiveWorkouts: fakeWorkouts,
        hivePrograms: fakePrograms,
        connectivity: FakeConnectivity(),
      );

      final repo = SyncedWorkoutRepository(
        hiveDataSource: fakeWorkouts,
        syncService: service,
        userId: 'user_abc',
      );

      expect(repo.userId, 'user_abc');

      final workout = Workout(
        id: 'w_test_1',
        date: DateTime.now(),
        exercises: const [],
        duration: const Duration(minutes: 45),
        totalVolume: 12500.0,
      );

      await repo.saveWorkout(workout);

      // Local storage has it
      expect(fakeWorkouts.storage.containsKey('w_test_1'), isTrue);

      // Queued action has userId
      expect(fakeQueue.actions.length, 1);
      expect(fakeQueue.actions.first.data['userId'], 'user_abc');

      await repo.deleteWorkout('w_test_1');
      expect(fakeWorkouts.storage.containsKey('w_test_1'), isFalse);
      expect(fakeQueue.actions.length, 2);
      expect(fakeQueue.actions.last.data['userId'], 'user_abc');

      await Future.delayed(const Duration(milliseconds: 50));
      service.dispose();
    });
  });
}
