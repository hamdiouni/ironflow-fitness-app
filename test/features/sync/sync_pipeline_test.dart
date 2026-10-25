import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/body/data/models/body_entry_model.dart';
import 'package:progression_tracker/features/nutrition/data/models/meal_model.dart';
import 'package:progression_tracker/features/nutrition/data/models/nutrition_targets_model.dart';
import 'package:progression_tracker/features/sync/data/datasources/firestore_sync_datasource.dart';
import 'package:progression_tracker/features/sync/data/datasources/hive_sync_queue_datasource.dart';
import 'package:progression_tracker/features/sync/domain/entities/sync_action.dart';
import 'package:progression_tracker/features/sync/domain/services/sync_service.dart';
import 'package:progression_tracker/features/workout/data/datasources/hive_active_program_datasource.dart';
import 'package:progression_tracker/features/workout/data/datasources/hive_workout_data_source.dart';
import 'package:progression_tracker/features/workout/data/models/active_program_model.dart';
import 'package:progression_tracker/features/workout/data/models/workout_model.dart';
import 'package:progression_tracker/features/workout/data/models/workout_program_model.dart';
import 'package:progression_tracker/features/workout/data/repositories/synced_workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';

// NOTE (Phase 2): the former `SyncRepositoryImpl` group tested the legacy
// `SyncOperation` pipeline (SyncQueueManager + syncBatch), which was
// deleted when the app consolidated on this single SyncService/outbox.
// See docs/architecture/DATABASE_AND_SYNC_AUDIT.md §12.

class FakeConnectivity implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value([ConnectivityResult.wifi]);
}

class FakeFirestoreSyncDataSource implements FirestoreSyncDataSource {
  final List<WorkoutModel> syncedWorkouts = [];
  final List<String> deletedWorkoutIds = [];
  final List<ActiveProgramModel> syncedPrograms = [];
  final List<MealModel> syncedMeals = [];
  final List<BodyEntryModel> syncedBodyEntries = [];
  ActiveProgramModel? activeProgramToReturn;
  NutritionTargetsModel? nutritionTargetsToReturn;
  DateTime? recordedSinceFilter;

  // Workouts -----------------------------------------------------------------

  @override
  Future<void> syncWorkout(String userId, WorkoutModel workout) async {
    syncedWorkouts.add(workout);
  }

  @override
  Future<List<WorkoutModel>> getWorkouts(String userId, {DateTime? since}) async {
    return syncedWorkouts;
  }

  @override
  Future<void> deleteWorkout(String userId, String workoutId) async {
    deletedWorkoutIds.add(workoutId);
    // Model real tombstone semantics: the doc stays, marked deleted, so
    // subsequent pulls propagate the deletion instead of resurrecting it.
    final idx = syncedWorkouts.indexWhere((w) => w.id == workoutId);
    if (idx != -1) {
      syncedWorkouts[idx] = syncedWorkouts[idx].copyWith(
        deletedAt: DateTime.now().toIso8601String(),
      );
    }
  }

  // Programs -----------------------------------------------------------------

  @override
  Future<void> syncActiveProgram(String userId, ActiveProgramModel program) async {
    syncedPrograms.add(program);
  }

  @override
  Future<ActiveProgramModel?> getActiveProgram(String userId, {DateTime? since}) async {
    recordedSinceFilter = since;
    return activeProgramToReturn;
  }

  @override
  Future<void> deleteProgram(String userId, String programId) async {}

  // Meals --------------------------------------------------------------------

  @override
  Future<void> syncMeal(String userId, MealModel meal) async {
    syncedMeals.add(meal);
  }

  @override
  Future<List<MealModel>> getMeals(String userId, {DateTime? since}) async =>
      syncedMeals;

  @override
  Future<void> deleteMeal(String userId, String mealId) async {}

  // Body entries ---------------------------------------------------------------

  @override
  Future<void> syncBodyEntry(String userId, BodyEntryModel entry) async {
    syncedBodyEntries.add(entry);
  }

  @override
  Future<List<BodyEntryModel>> getBodyEntries(String userId, {DateTime? since}) async =>
      syncedBodyEntries;

  @override
  Future<void> deleteBodyEntry(String userId, String entryId) async {}

  // Targets --------------------------------------------------------------------

  @override
  Future<void> syncNutritionTargets(
    String userId,
    NutritionTargetsModel targets,
  ) async {
    nutritionTargetsToReturn = targets;
  }

  @override
  Future<NutritionTargetsModel?> getNutritionTargets(String userId) async =>
      nutritionTargetsToReturn;
}

class FakeHiveSyncQueueDataSource implements HiveSyncQueueDataSource {
  final List<SyncAction> actions = [];
  final Map<String, DateTime> cursors = {};
  final Set<String> initialPushDone = {};

  @override
  Future<void> addAction(SyncAction action) async {
    actions.add(action);
  }

  @override
  Future<List<SyncAction>> getPendingActions() async {
    return actions.where((a) => a.status == SyncStatus.pending).toList();
  }

  @override
  Future<void> updateActionStatus(String id, SyncStatus status, {String? error}) async {
    final idx = actions.indexWhere((a) => a.id == id);
    if (idx != -1) {
      actions[idx] = actions[idx].copyWith(status: status, error: error);
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

  @override
  Future<DateTime?> getCursor(
    String dataType, {
    required String userId,
  }) async =>
      cursors['$userId:$dataType'];

  @override
  Future<void> setCursor(
    String dataType,
    DateTime time, {
    required String userId,
  }) async {
    cursors['$userId:$dataType'] = time;
  }

  @override
  Future<bool> hasCompletedInitialPush(String userId) async =>
      initialPushDone.contains(userId);

  @override
  Future<void> markInitialPushComplete(String userId) async {
    initialPushDone.add(userId);
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
  Stream<List<WorkoutModel>> watchAllWorkouts() async* {
    yield await getAllWorkouts();
  }

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
  Future<ActiveProgramModel?> loadActiveProgram({String? userId}) async =>
      current;

  @override
  Future<void> saveActiveProgram(
    ActiveProgramModel program, {
    String? userId,
  }) async {
    current = program;
  }

  @override
  Future<void> clearActiveProgram({String? userId}) async {
    current = null;
  }

  @override
  Future<void> archiveCurrentProgram({String? userId}) async {
    // No-op for sync pipeline test
  }

  @override
  Future<ActiveProgramModel?> restoreArchivedProgram({String? userId}) async =>
      null;

  @override
  Future<bool> hasArchivedProgram({String? userId}) async => false;

  @override
  Stream<ActiveProgramModel?> watchActiveProgram({String? userId}) async* {
    yield await loadActiveProgram(userId: userId);
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

  group('SyncService with program filtering', () {
    test('passes the per-device program cursor to getActiveProgram and keeps progress', () async {
      final fakeQueue = FakeHiveSyncQueueDataSource();
      final fakeFirestore = FakeFirestoreSyncDataSource();
      final fakeWorkouts = FakeHiveWorkoutDataSource();
      final fakePrograms = FakeHiveActiveProgramDataSource();

      final lastSyncDate = DateTime(2026, 4, 10);
      // Phase 2: cursors are per-device (queue data source), not cloud metadata.
      fakeQueue.cursors['user_123:programs'] = lastSyncDate;
      fakeFirestore.activeProgramToReturn = const ActiveProgramModel(
        id: 'ap1',
        program: WorkoutProgramModel(
          id: 'prog1',
          name: 'Hypertrophy 4-Day',
          description: 'Test program',
          durationWeeks: 8,
          difficulty: 'intermediate',
          days: [],
        ),
        currentDayIndex: 2,
        isActive: true,
        updatedAt: '2026-04-11T00:00:00.000',
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
      // Full state pulled: program AND progress (old pull reset to day 0)
      expect(fakePrograms.current?.program.id, 'prog1');
      expect(fakePrograms.current?.currentDayIndex, 2);
      service.dispose();
    });
  });

  group('SyncService initial full push', () {
    test('stamps and uploads owned/guest history once, skipping foreign records', () async {
      final fakeQueue = FakeHiveSyncQueueDataSource();
      final fakeFirestore = FakeFirestoreSyncDataSource();
      final fakeWorkouts = FakeHiveWorkoutDataSource();
      final fakePrograms = FakeHiveActiveProgramDataSource();

      WorkoutModel workout(
        String id, {
        String? userId,
        String? deletedAt,
      }) {
        return WorkoutModel(
          id: id,
          date: '2026-04-01T12:00:00.000',
          exercises: const [],
          durationSeconds: 1800,
          totalVolume: 1000,
          userId: userId,
          updatedAt: '2026-04-01T12:30:00.000',
          deletedAt: deletedAt,
        );
      }

      final ownedWorkout = workout('Alice', userId: 'Alice');
      fakeWorkouts.storage.addAll({
        'guest': workout('guest'),
        'Alice': ownedWorkout,
        'foreign': workout('foreign', userId: 'bob'),
        'deleted': workout(
          'deleted',
          deletedAt: '2026-04-02T12:00:00.000',
        ),
      });
      fakePrograms.current = const ActiveProgramModel(
        id: 'active-1',
        program: WorkoutProgramModel(
          id: 'program-1',
          name: 'Starter Program',
          description: 'Test program',
          durationWeeks: 4,
          difficulty: 'beginner',
          days: [],
        ),
        currentDayIndex: 1,
        isActive: true,
        updatedAt: '2026-04-01T12:30:00.000',
      );

      // A matching pending action must suppress a duplicate initial-push
      // action for the same workout.
      await fakeQueue.addAction(
        SyncAction(
          id: 'already-queued-owned',
          type: SyncActionType.update,
          dataType: SyncDataType.workout,
          dataId: ownedWorkout.id,
          data: ownedWorkout.toJson(),
          timestamp: DateTime(2026, 4, 1),
          status: SyncStatus.pending,
        ),
      );

      final service = SyncService(
        syncQueue: fakeQueue,
        firestoreSync: fakeFirestore,
        hiveWorkouts: fakeWorkouts,
        hivePrograms: fakePrograms,
        connectivity: FakeConnectivity(),
      );

      await service.syncAll(userId: 'Alice');

      expect(fakeQueue.initialPushDone, contains('Alice'));
      expect(fakeWorkouts.storage['guest']?.userId, 'Alice');
      expect(fakeWorkouts.storage['deleted']?.userId, 'Alice');
      expect(fakeWorkouts.storage['foreign']?.userId, 'bob');
      expect(fakePrograms.current?.userId, 'Alice');

      expect(fakeFirestore.syncedWorkouts, hasLength(2));
      expect(
        fakeFirestore.syncedWorkouts.map((w) => w.id),
        containsAll(<String>['guest', 'Alice']),
      );
      expect(
        fakeFirestore.syncedWorkouts.map((w) => w.id),
        isNot(contains('foreign')),
      );
      expect(fakeFirestore.deletedWorkoutIds, ['deleted']);
      expect(fakeFirestore.syncedPrograms, hasLength(1));
      expect(fakeFirestore.syncedPrograms.single.userId, 'Alice');

      await service.syncAll(userId: 'Alice');

      // The per-user marker makes the scan one-time; a second sync does
      // not re-upload the same history.
      expect(fakeFirestore.syncedWorkouts, hasLength(2));
      expect(fakeFirestore.deletedWorkoutIds, ['deleted']);
      expect(fakeFirestore.syncedPrograms, hasLength(1));

      service.dispose();
    });

    test('disabled scan neither stamps nor uploads local history', () async {
      final fakeQueue = FakeHiveSyncQueueDataSource();
      final fakeFirestore = FakeFirestoreSyncDataSource();
      final fakeWorkouts = FakeHiveWorkoutDataSource();
      final fakePrograms = FakeHiveActiveProgramDataSource();

      fakeWorkouts.storage['guest'] = const WorkoutModel(
        id: 'guest',
        date: '2026-04-01T12:00:00.000',
        exercises: [],
        durationSeconds: 1800,
        totalVolume: 1000,
      );

      // enableInitialPush:false is how the app runs under mock auth:
      // local history must not be bulk-stamped with a throwaway uid.
      final service = SyncService(
        syncQueue: fakeQueue,
        firestoreSync: fakeFirestore,
        hiveWorkouts: fakeWorkouts,
        hivePrograms: fakePrograms,
        connectivity: FakeConnectivity(),
        enableInitialPush: false,
      );

      await service.syncAll(userId: 'user_mock');

      expect(fakeQueue.initialPushDone, isEmpty);
      expect(fakeWorkouts.storage['guest']?.userId, isNull);
      expect(fakeFirestore.syncedWorkouts, isEmpty);

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
