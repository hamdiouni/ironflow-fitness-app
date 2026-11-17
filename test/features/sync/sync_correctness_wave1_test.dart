import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import 'package:progression_tracker/features/body/data/datasources/hive_body_data_source.dart';
import 'package:progression_tracker/features/body/data/models/body_entry_model.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/hive_nutrition_datasource.dart';
import 'package:progression_tracker/features/nutrition/data/models/meal_model.dart';
import 'package:progression_tracker/features/nutrition/data/models/nutrition_targets_model.dart';
import 'package:progression_tracker/features/sync/data/datasources/firestore_sync_datasource.dart';
import 'package:progression_tracker/features/sync/data/datasources/hive_sync_queue_datasource.dart';
import 'package:progression_tracker/features/sync/domain/entities/sync_action.dart';
import 'package:progression_tracker/features/sync/data/services/sync_service.dart';
import 'package:progression_tracker/features/workout/data/datasources/hive_active_program_datasource.dart';
import 'package:progression_tracker/features/workout/data/datasources/hive_workout_data_source.dart';
import 'package:progression_tracker/features/workout/data/models/active_program_model.dart';
import 'package:progression_tracker/features/workout/data/models/workout_model.dart';
import 'package:progression_tracker/features/workout/data/repositories/active_program_repository_impl.dart';
import 'package:progression_tracker/features/workout/domain/entities/active_program.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout_program.dart';

class ControllableConnectivity implements Connectivity {
  List<ConnectivityResult> current = [ConnectivityResult.wifi];
  final StreamController<List<ConnectivityResult>> controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => current;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      controller.stream;

  void setOnline(bool online) {
    current = online ? [ConnectivityResult.wifi] : [ConnectivityResult.none];
    controller.add(current);
  }

  void dispose() {
    controller.close();
  }
}

/// Shared in-memory Firestore cloud state for two-device convergence testing.
class SharedCloudFirestore implements FirestoreSyncDataSource {
  final Map<String, WorkoutModel> workouts = {};
  final Map<String, ActiveProgramModel> activePrograms = {};
  final Map<String, MealModel> meals = {};
  final Map<String, BodyEntryModel> bodyEntries = {};
  final Map<String, NutritionTargetsModel> nutritionTargets = {};

  final Set<String> failWorkoutIdsOnPush = {};
  bool failMealsPull = false;
  int workoutPushCallCount = 0;
  final Map<String, DateTime> lastServerTimestamps = {};

  @override
  DateTime? getLastServerTimestamp(String collection) =>
      lastServerTimestamps[collection];

  @override
  Future<void> syncWorkout(String userId, WorkoutModel workout) async {
    workoutPushCallCount++;
    if (failWorkoutIdsOnPush.contains(workout.id)) {
      throw Exception('Simulated Firestore write failure for ${workout.id}');
    }
    workouts[workout.id] = workout.copyWith(userId: userId);
  }

  @override
  Future<List<WorkoutModel>> getWorkouts(
    String userId, {
    DateTime? since,
  }) async {
    return workouts.values.where((w) => w.userId == userId).toList();
  }

  @override
  Future<void> deleteWorkout(String userId, String workoutId) async {
    workoutPushCallCount++;
    if (failWorkoutIdsOnPush.contains(workoutId)) {
      throw Exception('Simulated Firestore delete failure for $workoutId');
    }
    final existing = workouts[workoutId];
    final deletedAtIso = DateTime.now().toUtc().toIso8601String();
    if (existing != null) {
      workouts[workoutId] = existing.copyWith(
        deletedAt: deletedAtIso,
        updatedAt: deletedAtIso,
      );
    } else {
      workouts[workoutId] = WorkoutModel(
        id: workoutId,
        date: deletedAtIso,
        exercises: const [],
        durationSeconds: 0,
        totalVolume: 0,
        userId: userId,
        updatedAt: deletedAtIso,
        deletedAt: deletedAtIso,
      );
    }
  }

  @override
  Future<void> syncActiveProgram(
    String userId,
    ActiveProgramModel program,
  ) async {
    activePrograms[userId] = program.copyWith(userId: userId);
  }

  @override
  Future<ActiveProgramModel?> getActiveProgram(
    String userId, {
    DateTime? since,
  }) async {
    return activePrograms[userId];
  }

  @override
  Future<void> deleteProgram(String userId, String programId) async {
    activePrograms.remove(userId);
  }

  @override
  Future<void> syncMeal(String userId, MealModel meal) async {
    meals[meal.id] = meal.copyWith(userId: userId);
  }

  @override
  Future<List<MealModel>> getMeals(String userId, {DateTime? since}) async {
    if (failMealsPull) {
      throw Exception('Simulated Firestore meals pull error');
    }
    return meals.values.where((m) => m.userId == userId).toList();
  }

  @override
  Future<void> deleteMeal(String userId, String mealId) async {
    final existing = meals[mealId];
    final deletedAtIso = DateTime.now().toUtc().toIso8601String();
    if (existing != null) {
      meals[mealId] = existing.copyWith(
        deletedAt: deletedAtIso,
        updatedAt: deletedAtIso,
      );
    }
  }

  @override
  Future<void> syncBodyEntry(String userId, BodyEntryModel entry) async {
    bodyEntries[entry.id] = entry.copyWith(userId: userId);
  }

  @override
  Future<List<BodyEntryModel>> getBodyEntries(
    String userId, {
    DateTime? since,
  }) async {
    return bodyEntries.values.where((b) => b.userId == userId).toList();
  }

  @override
  Future<void> deleteBodyEntry(String userId, String entryId) async {
    final existing = bodyEntries[entryId];
    final deletedAtIso = DateTime.now().toUtc().toIso8601String();
    if (existing != null) {
      bodyEntries[entryId] = existing.copyWith(
        deletedAt: deletedAtIso,
        updatedAt: deletedAtIso,
      );
    }
  }

  @override
  Future<void> syncNutritionTargets(
    String userId,
    NutritionTargetsModel targets,
  ) async {
    nutritionTargets[userId] = targets;
  }

  @override
  Future<NutritionTargetsModel?> getNutritionTargets(String userId) async {
    return nutritionTargets[userId];
  }
}

class InMemorySyncQueue implements HiveSyncQueueDataSource {
  final List<SyncAction> actions = [];
  final Map<String, DateTime> cursors = {};
  final Set<String> initialPushDone = {};

  @override
  Future<void> addAction(SyncAction action) async {
    actions.add(action);
  }

  @override
  Future<List<SyncAction>> getPendingActions() async {
    return actions
        .where(
          (a) =>
              a.status == SyncStatus.pending || a.status == SyncStatus.failed,
        )
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
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
      final current = actions[idx];
      actions[idx] = current.copyWith(
        status: status,
        error: error,
        retryCount: retryCount ??
            (status == SyncStatus.failed
                ? current.retryCount + 1
                : current.retryCount),
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
  Future<int> getPendingCount() async =>
      actions.where((a) => a.status == SyncStatus.pending).length;

  @override
  Future<int> getFailedCount() async =>
      actions.where((a) => a.status == SyncStatus.failed).length;

  @override
  Future<DateTime?> getCursor(String dataType, {required String userId}) async =>
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
}

class InMemoryWorkoutStore implements HiveWorkoutDataSource {
  final Map<String, WorkoutModel> storage = {};

  @override
  Future<WorkoutModel?> getWorkoutById(String id) async => storage[id];

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
  Future<int> getWorkoutCount({String? userId}) async => storage.length;

  @override
  Future<List<WorkoutModel>> getWorkoutsPaginated({
    int offset = 0,
    int limit = 20,
    String? userId,
  }) async =>
      storage.values.skip(offset).take(limit).toList();
}

class InMemoryProgramStore implements HiveActiveProgramDataSource {
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
  Future<void> archiveCurrentProgram({String? userId}) async {}

  @override
  Future<ActiveProgramModel?> restoreArchivedProgram({String? userId}) async =>
      null;

  @override
  Future<bool> hasArchivedProgram({String? userId}) async => false;

  @override
  Stream<ActiveProgramModel?> watchActiveProgram({String? userId}) async* {
    yield current;
  }
}

class InMemoryBodyStore implements HiveBodyDataSource {
  final Map<String, BodyEntryModel> storage = {};

  @override
  Future<void> saveBodyEntry(BodyEntryModel entry) async {
    storage[entry.id] = entry;
  }

  @override
  Future<List<BodyEntryModel>> getAllBodyEntries() async =>
      storage.values.toList();

  @override
  Future<void> deleteBodyEntry(String id) async {
    storage.remove(id);
  }

  @override
  Stream<List<BodyEntryModel>> watchAllBodyEntries() async* {
    yield await getAllBodyEntries();
  }
}

class InMemoryNutritionStore implements HiveNutritionDatasource {
  final Map<String, MealModel> meals = {};
  NutritionTargetsModel? targets;

  @override
  Future<void> saveMealEntry(MealModel meal) async {
    meals[meal.id] = meal;
  }

  @override
  Future<List<MealModel>> getAllMeals() async => meals.values.toList();

  @override
  Future<void> deleteMealEntry(String id) async {
    meals.remove(id);
  }

  @override
  Future<NutritionTargetsModel?> getNutritionTargets({String? userId}) async =>
      targets;

  @override
  Future<void> saveNutritionTargets(
    NutritionTargetsModel newTargets, {
    String? userId,
  }) async {
    targets = newTargets;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

WorkoutModel _makeWorkout({
  required String id,
  required String userId,
  required double volume,
  required String updatedAt,
  String? deletedAt,
}) {
  return WorkoutModel(
    id: id,
    date: '2026-04-15T10:00:00.000Z',
    exercises: const [],
    durationSeconds: 2400,
    totalVolume: volume,
    userId: userId,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sync_wave1_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('Wave 1 Step 9 — Sync Characterization & Multi-Device Correctness', () {
    test('characterization: offline queue holds actions until online, then pushes and clears', () async {
      final connectivity = ControllableConnectivity()..setOnline(false);
      final cloud = SharedCloudFirestore();
      final queue = InMemorySyncQueue()..initialPushDone.add('u1');
      final workouts = InMemoryWorkoutStore();
      final programs = InMemoryProgramStore();

      final service = SyncService(
        syncQueue: queue,
        firestoreSync: cloud,
        hiveWorkouts: workouts,
        hivePrograms: programs,
        connectivity: connectivity,
        currentUserIdProvider: () => 'u1',
      );

      final w1 = _makeWorkout(
        id: 'w1',
        userId: 'u1',
        volume: 5000,
        updatedAt: '2026-04-15T10:05:00.000Z',
      );
      await workouts.saveWorkout(w1);
      await service.queueAction(
        type: SyncActionType.create,
        dataType: SyncDataType.workout,
        dataId: w1.id,
        data: w1.toJson(),
      );

      // Still offline -> pending in queue, not in cloud
      expect(await queue.getPendingCount(), 1);
      expect(cloud.workouts, isEmpty);

      // Regain connectivity -> syncs to cloud and clears completed action
      connectivity.setOnline(true);
      await service.syncAll(userId: 'u1');

      expect(await queue.getPendingCount(), 0);
      expect(cloud.workouts['w1']?.totalVolume, 5000);

      service.dispose();
      connectivity.dispose();
    });

    test('characterization: retry policy increments retryCount and skips after 3 failures', () async {
      final connectivity = ControllableConnectivity()..setOnline(true);
      final cloud = SharedCloudFirestore()..failWorkoutIdsOnPush.add('w_fail');
      final queue = InMemorySyncQueue()..initialPushDone.add('u1');
      final workouts = InMemoryWorkoutStore();
      final programs = InMemoryProgramStore();

      final service = SyncService(
        syncQueue: queue,
        firestoreSync: cloud,
        hiveWorkouts: workouts,
        hivePrograms: programs,
        connectivity: connectivity,
        currentUserIdProvider: () => 'u1',
      );

      final wFail = _makeWorkout(
        id: 'w_fail',
        userId: 'u1',
        volume: 3000,
        updatedAt: '2026-04-15T10:00:00.000Z',
      );
      await queue.addAction(
        SyncAction(
          id: 'act_fail',
          type: SyncActionType.create,
          dataType: SyncDataType.workout,
          dataId: 'w_fail',
          data: wFail.toJson(),
          timestamp: DateTime.utc(2026, 4, 15, 10),
          status: SyncStatus.pending,
        ),
      );

      await service.syncAll(userId: 'u1'); // attempt 1 -> retryCount = 1
      await service.syncAll(userId: 'u1'); // attempt 2 -> retryCount = 2
      await service.syncAll(userId: 'u1'); // attempt 3 -> retryCount = 3
      expect(cloud.workoutPushCallCount, 3);
      expect(queue.actions.single.retryCount, 3);

      // Attempt 4 is skipped because retryCount >= 3
      await service.syncAll(userId: 'u1');
      expect(cloud.workoutPushCallCount, 3);

      service.dispose();
      connectivity.dispose();
    });

    test('idempotent outbox coalescing: multiple offline edits for same record push only latest state', () async {
      final connectivity = ControllableConnectivity()..setOnline(false);
      final cloud = SharedCloudFirestore();
      final queue = InMemorySyncQueue()..initialPushDone.add('u1');
      final workouts = InMemoryWorkoutStore();
      final programs = InMemoryProgramStore();

      final service = SyncService(
        syncQueue: queue,
        firestoreSync: cloud,
        hiveWorkouts: workouts,
        hivePrograms: programs,
        connectivity: connectivity,
        currentUserIdProvider: () => 'u1',
      );

      final v1 = _makeWorkout(
        id: 'w_coalesce',
        userId: 'u1',
        volume: 1000,
        updatedAt: '2026-04-15T10:01:00.000Z',
      );
      final v2 = _makeWorkout(
        id: 'w_coalesce',
        userId: 'u1',
        volume: 2000,
        updatedAt: '2026-04-15T10:02:00.000Z',
      );
      final v3 = _makeWorkout(
        id: 'w_coalesce',
        userId: 'u1',
        volume: 3500,
        updatedAt: '2026-04-15T10:03:00.000Z',
      );

      await workouts.saveWorkout(v3);
      await queue.addAction(
        SyncAction(
          id: 'a1',
          type: SyncActionType.create,
          dataType: SyncDataType.workout,
          dataId: 'w_coalesce',
          data: v1.toJson(),
          timestamp: DateTime.utc(2026, 4, 15, 10, 1),
          status: SyncStatus.pending,
        ),
      );
      await queue.addAction(
        SyncAction(
          id: 'a2',
          type: SyncActionType.update,
          dataType: SyncDataType.workout,
          dataId: 'w_coalesce',
          data: v2.toJson(),
          timestamp: DateTime.utc(2026, 4, 15, 10, 2),
          status: SyncStatus.pending,
        ),
      );
      await queue.addAction(
        SyncAction(
          id: 'a3',
          type: SyncActionType.update,
          dataType: SyncDataType.workout,
          dataId: 'w_coalesce',
          data: v3.toJson(),
          timestamp: DateTime.utc(2026, 4, 15, 10, 3),
          status: SyncStatus.pending,
        ),
      );

      connectivity.setOnline(true);
      await service.syncAll(userId: 'u1');

      // Only 1 network call was needed, and the cloud has v3 (volume 3500)
      expect(cloud.workoutPushCallCount, 1);
      expect(cloud.workouts['w_coalesce']?.totalVolume, 3500);
      expect(queue.actions, isEmpty);

      service.dispose();
      connectivity.dispose();
    });

    test('partial failure & unpushed edit protection: failed push is not overwritten by stale cloud pull', () async {
      final connectivity = ControllableConnectivity()..setOnline(true);
      final cloud = SharedCloudFirestore();
      final queue = InMemorySyncQueue()..initialPushDone.add('u1');
      final workouts = InMemoryWorkoutStore();
      final programs = InMemoryProgramStore();
      final body = InMemoryBodyStore();
      final nutrition = InMemoryNutritionStore();

      // Cloud has an older version of w_protected (volume 1000 at 10:00)
      cloud.workouts['w_protected'] = _makeWorkout(
        id: 'w_protected',
        userId: 'u1',
        volume: 1000,
        updatedAt: '2026-04-15T10:00:00.000Z',
      );
      // Cloud also has a body entry that should pull cleanly even if meals pull fails
      cloud.bodyEntries['b1'] = const BodyEntryModel(
        id: 'b1',
        date: '2026-04-15T10:00:00.000Z',
        weight: 81.5,
        measurements: {},
        userId: 'u1',
        updatedAt: '2026-04-15T10:05:00.000Z',
      );
      cloud.failMealsPull = true;

      // Local has a newer edit of w_protected (volume 9000 at 10:10), plus a second workout w_ok
      final localEdited = _makeWorkout(
        id: 'w_protected',
        userId: 'u1',
        volume: 9000,
        updatedAt: '2026-04-15T10:10:00.000Z',
      );
      final localOk = _makeWorkout(
        id: 'w_ok',
        userId: 'u1',
        volume: 4200,
        updatedAt: '2026-04-15T10:11:00.000Z',
      );
      await workouts.saveWorkout(localEdited);
      await workouts.saveWorkout(localOk);

      await queue.addAction(
        SyncAction(
          id: 'act_prot',
          type: SyncActionType.update,
          dataType: SyncDataType.workout,
          dataId: 'w_protected',
          data: localEdited.toJson(),
          timestamp: DateTime.utc(2026, 4, 15, 10, 10),
          status: SyncStatus.pending,
        ),
      );
      await queue.addAction(
        SyncAction(
          id: 'act_ok',
          type: SyncActionType.create,
          dataType: SyncDataType.workout,
          dataId: 'w_ok',
          data: localOk.toJson(),
          timestamp: DateTime.utc(2026, 4, 15, 10, 11),
          status: SyncStatus.pending,
        ),
      );

      // Simulate transient push failure ONLY for w_protected
      cloud.failWorkoutIdsOnPush.add('w_protected');

      final service = SyncService(
        syncQueue: queue,
        firestoreSync: cloud,
        hiveWorkouts: workouts,
        hivePrograms: programs,
        hiveNutrition: nutrition,
        hiveBody: body,
        connectivity: connectivity,
        currentUserIdProvider: () => 'u1',
      );

      await service.syncAll(userId: 'u1');

      // 1. w_ok succeeded and reached cloud despite w_protected failing
      expect(cloud.workouts['w_ok']?.totalVolume, 4200);
      // 2. w_protected in local store was NOT overwritten by cloud's older volume=1000
      expect(workouts.storage['w_protected']?.totalVolume, 9000);
      // 3. Body entry pulled cleanly despite meals leg failing
      expect(body.storage['b1']?.weight, 81.5);
      expect(queue.cursors.containsKey('u1:body_progress'), isTrue);
      expect(queue.cursors.containsKey('u1:nutrition'), isFalse);

      // Now clear the transient push failure and retry
      cloud.failWorkoutIdsOnPush.clear();
      await service.retryFailedActions('u1');
      expect(cloud.workouts['w_protected']?.totalVolume, 9000);

      service.dispose();
      connectivity.dispose();
    });

    test('two-device convergence: LWW, equal-timestamp tie-breaker, and tombstone propagation', () async {
      final cloud = SharedCloudFirestore();

      // Device A setup
      final connA = ControllableConnectivity()..setOnline(true);
      final queueA = InMemorySyncQueue()..initialPushDone.add('u1');
      final workoutsA = InMemoryWorkoutStore();
      final programsA = InMemoryProgramStore();
      final deviceA = SyncService(
        syncQueue: queueA,
        firestoreSync: cloud,
        hiveWorkouts: workoutsA,
        hivePrograms: programsA,
        connectivity: connA,
        currentUserIdProvider: () => 'u1',
      );

      // Device B setup
      final connB = ControllableConnectivity()..setOnline(true);
      final queueB = InMemorySyncQueue()..initialPushDone.add('u1');
      final workoutsB = InMemoryWorkoutStore();
      final programsB = InMemoryProgramStore();
      final deviceB = SyncService(
        syncQueue: queueB,
        firestoreSync: cloud,
        hiveWorkouts: workoutsB,
        hivePrograms: programsB,
        connectivity: connB,
        currentUserIdProvider: () => 'u1',
      );

      // Step 1: Device A creates w_shared (t = 10:00) and w_to_delete (t = 10:00)
      final wSharedA = _makeWorkout(
        id: 'w_shared',
        userId: 'u1',
        volume: 1000,
        updatedAt: '2026-04-15T10:00:00.000Z',
      );
      final wToDelete = _makeWorkout(
        id: 'w_to_delete',
        userId: 'u1',
        volume: 2000,
        updatedAt: '2026-04-15T10:00:00.000Z',
      );
      await workoutsA.saveWorkout(wSharedA);
      await workoutsA.saveWorkout(wToDelete);
      await queueA.addAction(
        SyncAction(
          id: 'a_init_1',
          type: SyncActionType.create,
          dataType: SyncDataType.workout,
          dataId: 'w_shared',
          data: wSharedA.toJson(),
          timestamp: DateTime.utc(2026, 4, 15, 10),
          status: SyncStatus.pending,
        ),
      );
      await queueA.addAction(
        SyncAction(
          id: 'a_init_2',
          type: SyncActionType.create,
          dataType: SyncDataType.workout,
          dataId: 'w_to_delete',
          data: wToDelete.toJson(),
          timestamp: DateTime.utc(2026, 4, 15, 10),
          status: SyncStatus.pending,
        ),
      );

      await deviceA.syncAll(userId: 'u1');
      await deviceB.syncAll(userId: 'u1');

      // Both devices now have w_shared (1000) and w_to_delete (2000)
      expect(workoutsB.storage['w_shared']?.totalVolume, 1000);
      expect(workoutsB.storage['w_to_delete']?.totalVolume, 2000);

      // Step 2: Equal-timestamp tie-breaking test!
      // Both Device A and Device B have a record w_tie with the EXACT same updatedAt
      const tieTimestamp = '2026-04-15T11:00:00.000Z';
      final wTieOnA = _makeWorkout(
        id: 'w_tie',
        userId: 'u1',
        volume: 5100,
        updatedAt: tieTimestamp,
      );
      final wTieOnB = _makeWorkout(
        id: 'w_tie',
        userId: 'u1',
        volume: 8900,
        updatedAt: tieTimestamp,
      );
      await workoutsA.saveWorkout(wTieOnA);
      await workoutsB.saveWorkout(wTieOnB);

      // Put wTieOnB in cloud, pull on A, and put winning version in cloud, pull on B
      cloud.workouts['w_tie'] = wTieOnB;
      await deviceA.syncAll(userId: 'u1');
      // On A, wTieOnB (8900) vs wTieOnA (5100) at identical timestamp:
      // canonical JSON of volume 8900 > 5100, so both A and B converge to 8900!
      expect(workoutsA.storage['w_tie']?.totalVolume, 8900);
      expect(workoutsB.storage['w_tie']?.totalVolume, 8900);

      // Step 3: Device B updates w_shared to 7500 (t = 12:00) and deletes w_to_delete
      final wSharedBNewer = _makeWorkout(
        id: 'w_shared',
        userId: 'u1',
        volume: 7500,
        updatedAt: '2026-04-15T12:00:00.000Z',
      );
      await workoutsB.saveWorkout(wSharedBNewer);
      await workoutsB.deleteWorkout('w_to_delete');
      await queueB.addAction(
        SyncAction(
          id: 'b_upd',
          type: SyncActionType.update,
          dataType: SyncDataType.workout,
          dataId: 'w_shared',
          data: wSharedBNewer.toJson(),
          timestamp: DateTime.utc(2026, 4, 15, 12),
          status: SyncStatus.pending,
        ),
      );
      await queueB.addAction(
        SyncAction(
          id: 'b_del',
          type: SyncActionType.delete,
          dataType: SyncDataType.workout,
          dataId: 'w_to_delete',
          data: {'id': 'w_to_delete', 'userId': 'u1'},
          timestamp: DateTime.utc(2026, 4, 15, 12),
          status: SyncStatus.pending,
        ),
      );

      await deviceB.syncAll(userId: 'u1');
      await deviceA.syncAll(userId: 'u1');

      // Device A and Device B have converged identically!
      expect(workoutsA.storage['w_shared']?.totalVolume, 7500);
      expect(workoutsB.storage['w_shared']?.totalVolume, 7500);
      expect(workoutsA.storage.containsKey('w_to_delete'), isFalse);
      expect(workoutsB.storage.containsKey('w_to_delete'), isFalse);

      deviceA.dispose();
      deviceB.dispose();
      connA.dispose();
      connB.dispose();
    });

    test('feature flag: disabling sync skips network push/pull while retaining queued actions', () async {
      final connectivity = ControllableConnectivity()..setOnline(true);
      final cloud = SharedCloudFirestore();
      final queue = InMemorySyncQueue()..initialPushDone.add('u1');
      final workouts = InMemoryWorkoutStore();
      final programs = InMemoryProgramStore();

      final service = SyncService(
        syncQueue: queue,
        firestoreSync: cloud,
        hiveWorkouts: workouts,
        hivePrograms: programs,
        connectivity: connectivity,
        currentUserIdProvider: () => 'u1',
        syncEnabled: false,
      );

      expect(service.isSyncEnabled, isFalse);

      final w1 = _makeWorkout(
        id: 'w_flagged',
        userId: 'u1',
        volume: 6000,
        updatedAt: '2026-04-15T10:00:00.000Z',
      );
      await workouts.saveWorkout(w1);
      await service.queueAction(
        type: SyncActionType.create,
        dataType: SyncDataType.workout,
        dataId: 'w_flagged',
        data: w1.toJson(),
      );

      await service.syncAll(userId: 'u1');
      expect(cloud.workouts, isEmpty);
      expect(await queue.getPendingCount(), 1);

      // Re-enable sync at runtime -> queued action flushes to cloud
      service.setSyncEnabled(true);
      await service.syncAll(userId: 'u1');
      expect(cloud.workouts['w_flagged']?.totalVolume, 6000);
      expect(await queue.getPendingCount(), 0);

      service.dispose();
      connectivity.dispose();
    });

    test('retryFailedActions resets retryCount to 0 so failed actions push on manual retry (Wave 1.7a)', () async {
      final connectivity = ControllableConnectivity()..setOnline(true);
      final cloud = SharedCloudFirestore()..failWorkoutIdsOnPush.add('w_retry');
      final queue = InMemorySyncQueue()..initialPushDone.add('u1');
      final workouts = InMemoryWorkoutStore();
      final programs = InMemoryProgramStore();

      final service = SyncService(
        syncQueue: queue,
        firestoreSync: cloud,
        hiveWorkouts: workouts,
        hivePrograms: programs,
        connectivity: connectivity,
        currentUserIdProvider: () => 'u1',
      );

      final w = _makeWorkout(
        id: 'w_retry',
        userId: 'u1',
        volume: 3000,
        updatedAt: '2026-04-15T10:00:00.000Z',
      );
      await queue.addAction(
        SyncAction(
          id: 'a_retry',
          type: SyncActionType.update,
          dataType: SyncDataType.workout,
          dataId: 'w_retry',
          data: w.toJson(),
          timestamp: DateTime.utc(2026, 4, 15, 10),
          status: SyncStatus.failed,
          retryCount: 3,
        ),
      );

      // Ordinary syncAll skips exhausted actions (retryCount >= 3)
      await service.syncAll(userId: 'u1');
      expect(cloud.workouts.containsKey('w_retry'), isFalse);

      // Cloud recovers and user calls retryFailedActions -> retryCount resets and pushes
      cloud.failWorkoutIdsOnPush.clear();
      await service.retryFailedActions('u1');
      expect(cloud.workouts['w_retry']?.totalVolume, 3000);
      expect(await queue.getFailedCount(), 0);
      expect(await queue.getPendingCount(), 0);

      service.dispose();
      connectivity.dispose();
    });

    test('pull advances cursor to max server syncedAt watermark instead of device clock (Wave 1.7c)', () async {
      final connectivity = ControllableConnectivity()..setOnline(true);
      final cloud = SharedCloudFirestore();
      final serverWatermark = DateTime.utc(2025, 1, 2, 3, 4, 5);
      cloud.workouts['w_server'] = _makeWorkout(
        id: 'w_server',
        userId: 'u1',
        volume: 1200,
        updatedAt: '2025-01-01T00:00:00.000Z',
      );
      cloud.lastServerTimestamps['workouts'] = serverWatermark;

      final queue = InMemorySyncQueue()..initialPushDone.add('u1');
      final workouts = InMemoryWorkoutStore();
      final programs = InMemoryProgramStore();

      final service = SyncService(
        syncQueue: queue,
        firestoreSync: cloud,
        hiveWorkouts: workouts,
        hivePrograms: programs,
        connectivity: connectivity,
        currentUserIdProvider: () => 'u1',
      );

      await service.syncAll(userId: 'u1');
      expect(
        await queue.getCursor('workouts', userId: 'u1'),
        equals(serverWatermark),
      );

      service.dispose();
      connectivity.dispose();
    });

    test('clearActiveProgram clears local state and invokes remote deletion hook (Wave 1.7d)', () async {
      final programs = InMemoryProgramStore();
      final clearedPrograms = <ActiveProgram>[];
      final repo = ActiveProgramRepositoryImpl(
        programs,
        userId: 'u1',
        onProgramCleared: (program) async => clearedPrograms.add(program),
      );

      final program = ActiveProgram(
        id: 'prog_42',
        program: const WorkoutProgram(
          id: 'prog_42',
          name: 'Upper/Lower',
          description: '4-day split',
          days: <ProgramDay>[],
          durationWeeks: 8,
          difficulty: 'intermediate',
          userId: 'u1',
        ),
        currentDayIndex: 0,
        isActive: true,
        userId: 'u1',
      );
      await repo.saveActiveProgram(program);
      expect(await repo.loadActiveProgram(), isNotNull);

      await repo.clearActiveProgram();
      expect(await repo.loadActiveProgram(), isNull);
      expect(clearedPrograms.map((p) => p.id), <String>['prog_42']);
    });

    test('SyncService no-ops queueAction and syncAll for local-only guest and demo IDs (Wave 1.5)', () async {
      final connectivity = ControllableConnectivity()..setOnline(true);
      final cloud = SharedCloudFirestore();
      final queue = InMemorySyncQueue();
      final workouts = InMemoryWorkoutStore();
      final programs = InMemoryProgramStore();

      for (final localUid in [kLocalGuestUserId, kLocalDemoUserId]) {
        final service = SyncService(
          syncQueue: queue,
          firestoreSync: cloud,
          hiveWorkouts: workouts,
          hivePrograms: programs,
          connectivity: connectivity,
          currentUserIdProvider: () => localUid,
        );

        await service.queueAction(
          type: SyncActionType.update,
          dataType: SyncDataType.workout,
          dataId: 'w_local',
          data: _makeWorkout(
            id: 'w_local',
            userId: localUid,
            volume: 500,
            updatedAt: '2026-04-15T10:00:00.000Z',
          ).toJson(),
        );
        await service.syncAll(userId: localUid);

        expect(queue.actions, isEmpty);
        expect(cloud.workoutPushCallCount, 0);
        service.dispose();
      }
      connectivity.dispose();
    });
  });
}
