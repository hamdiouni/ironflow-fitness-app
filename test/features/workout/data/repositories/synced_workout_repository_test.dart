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
import 'package:progression_tracker/features/workout/data/models/exercise_model.dart';
import 'package:progression_tracker/features/workout/data/models/workout_model.dart';
import 'package:progression_tracker/features/workout/data/repositories/synced_workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';

class _QueuedAction {
  const _QueuedAction({
    required this.type,
    required this.dataType,
    required this.dataId,
    required this.data,
  });

  final SyncActionType type;
  final SyncDataType dataType;
  final String dataId;
  final Map<String, dynamic> data;
}

class _OfflineConnectivity implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return <ConnectivityResult>[ConnectivityResult.none];
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged {
    return Stream<List<ConnectivityResult>>.value(
      <ConnectivityResult>[ConnectivityResult.none],
    );
  }
}

class _NoOpFirestoreSyncDataSource implements FirestoreSyncDataSource {
  @override
  Future<void> syncWorkout(String userId, WorkoutModel workout) async {}

  @override
  Future<List<WorkoutModel>> getWorkouts(
    String userId, {
    DateTime? since,
  }) async {
    return <WorkoutModel>[];
  }

  @override
  Future<void> deleteWorkout(String userId, String workoutId) async {}

  @override
  Future<void> syncActiveProgram(
    String userId,
    ActiveProgramModel program,
  ) async {}

  @override
  Future<ActiveProgramModel?> getActiveProgram(
    String userId, {
    DateTime? since,
  }) async {
    return null;
  }

  @override
  Future<void> deleteProgram(String userId, String programId) async {}

  @override
  Future<void> syncMeal(String userId, MealModel meal) async {}

  @override
  Future<List<MealModel>> getMeals(String userId, {DateTime? since}) async {
    return <MealModel>[];
  }

  @override
  Future<void> deleteMeal(String userId, String mealId) async {}

  @override
  Future<void> syncBodyEntry(String userId, BodyEntryModel entry) async {}

  @override
  Future<List<BodyEntryModel>> getBodyEntries(
    String userId, {
    DateTime? since,
  }) async {
    return <BodyEntryModel>[];
  }

  @override
  Future<void> deleteBodyEntry(String userId, String entryId) async {}

  @override
  Future<void> syncNutritionTargets(
    String userId,
    NutritionTargetsModel targets,
  ) async {}

  @override
  Future<NutritionTargetsModel?> getNutritionTargets(String userId) async {
    return null;
  }
}

/// Records the two calls [SyncedWorkoutRepository] makes into the concrete
/// sync engine, without running pushes, pulls, or the initial-push scan.
class _RecordingSyncService extends SyncService {
  _RecordingSyncService({required HiveWorkoutDataSource hiveWorkouts})
      : super(
          syncQueue: HiveSyncQueueDataSourceImpl(),
          firestoreSync: _NoOpFirestoreSyncDataSource(),
          hiveWorkouts: hiveWorkouts,
          hivePrograms: HiveActiveProgramDataSource(),
          connectivity: _OfflineConnectivity(),
          enableInitialPush: false,
        );

  final List<_QueuedAction> queuedActions = <_QueuedAction>[];
  final List<String?> syncAllCalls = <String?>[];

  @override
  Future<void> queueAction({
    required SyncActionType type,
    required SyncDataType dataType,
    required String dataId,
    required Map<String, dynamic> data,
  }) async {
    queuedActions.add(
      _QueuedAction(
        type: type,
        dataType: dataType,
        dataId: dataId,
        data: Map<String, dynamic>.from(data),
      ),
    );
  }

  @override
  Future<void> syncAll({String? userId}) async {
    syncAllCalls.add(userId);
  }
}

void main() {
  late Directory tempDir;
  late Box<Map> workoutsBox;
  late HiveWorkoutDataSource dataSource;
  late _RecordingSyncService syncService;
  late SyncedWorkoutRepository repository;

  Workout workout({
    required String id,
    required DateTime date,
    String? userId,
  }) {
    return Workout(
      id: id,
      date: date,
      exercises: const [],
      duration: const Duration(minutes: 45),
      totalVolume: 1000,
      userId: userId,
    );
  }

  WorkoutModel model({
    required String id,
    required DateTime date,
    String? userId = 'Alice',
    List<ExerciseModel> exercises = const <ExerciseModel>[],
  }) {
    return WorkoutModel(
      id: id,
      date: date.toIso8601String(),
      exercises: exercises,
      durationSeconds: 2700,
      totalVolume: 1000,
      userId: userId,
      updatedAt: '2026-01-01T00:00:00.000',
    );
  }

  Future<void> seed(List<WorkoutModel> workouts) async {
    for (final item in workouts) {
      await dataSource.saveWorkout(item);
    }
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('synced_workout_repo_');
    Hive.init(tempDir.path);
    workoutsBox = await Hive.openBox<Map>('workouts');
  });

  setUp(() async {
    await workoutsBox.clear();
    dataSource = HiveWorkoutDataSource();
    syncService = _RecordingSyncService(hiveWorkouts: dataSource);
    repository = SyncedWorkoutRepository(
      hiveDataSource: dataSource,
      syncService: syncService,
      userId: 'Alice',
    );
  });

  tearDown(() {
    syncService.dispose();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('save stamps owner and updatedAt, queues a create, and requests sync',
      () async {
    expect(repository.userId, 'Alice');

    final before = DateTime.now().subtract(const Duration(seconds: 1));
    await repository.saveWorkout(
      workout(id: 'w-1', date: DateTime(2026, 1, 2, 10)),
    );
    final after = DateTime.now().add(const Duration(seconds: 1));

    final stored = await dataSource.getAllWorkouts();
    expect(stored, hasLength(1));
    expect(stored.single.userId, 'Alice');
    expect(stored.single.updatedAt, isNotNull);
    final updatedAt = DateTime.parse(stored.single.updatedAt!);
    expect(updatedAt.isBefore(before), isFalse);
    expect(updatedAt.isAfter(after), isFalse);

    expect(syncService.queuedActions, hasLength(1));
    final action = syncService.queuedActions.single;
    expect(action.type, SyncActionType.create);
    expect(action.dataType, SyncDataType.workout);
    expect(action.dataId, 'w-1');
    expect(action.data['id'], 'w-1');
    expect(action.data['userId'], 'Alice');
    expect(action.data['updatedAt'], stored.single.updatedAt);
    expect(syncService.syncAllCalls, <String?>['Alice']);
  });

  test('save preserves an explicitly supplied owner', () async {
    await repository.saveWorkout(
      workout(
        id: 'w-owned',
        date: DateTime(2026, 1, 2, 10),
        userId: 'Alice',
      ),
    );

    final stored = await dataSource.getAllWorkouts();
    expect(stored.single.userId, 'Alice');
    expect(syncService.queuedActions.single.data['userId'], 'Alice');
  });

  test('reads return sorted entities and apply range, page, and history rules',
      () async {
    await seed(<WorkoutModel>[
      model(id: 'day-1', date: DateTime(2026, 1, 1, 10)),
      model(
        id: 'day-2',
        date: DateTime(2026, 1, 2, 10),
        exercises: const <ExerciseModel>[
          ExerciseModel(
            id: 'bench-old',
            name: 'bench press',
            type: 'strength',
            sets: [],
          ),
        ],
      ),
      model(
        id: 'day-3',
        date: DateTime(2026, 1, 3, 10),
        exercises: const <ExerciseModel>[
          ExerciseModel(
            id: 'bench-new',
            name: 'Bench Press',
            type: 'strength',
            sets: [],
            exerciseDefinitionId: 'chest_001',
          ),
        ],
      ),
      model(id: 'day-4', date: DateTime(2026, 1, 4, 10)),
    ]);

    final all = await repository.getAllWorkouts();
    final ranged = await repository.getWorkoutsByDateRange(
      DateTime(2026, 1, 1, 10),
      DateTime(2026, 1, 4, 10),
    );
    final page = await repository.getWorkoutsPaginated(offset: 1, limit: 2);
    final byName = await repository.getExerciseHistory('BENCH PRESS', 1);
    final byDefinitionId =
        await repository.getExerciseHistory('chest_001', 10);

    expect(
      all.map((item) => item.id),
      <String>['day-4', 'day-3', 'day-2', 'day-1'],
    );
    expect(ranged.map((item) => item.id), <String>['day-3', 'day-2']);
    expect(page.map((item) => item.id), <String>['day-3', 'day-2']);
    expect(await repository.getWorkoutCount(), 4);
    expect(byName.map((item) => item.id), <String>['bench-new']);
    expect(byDefinitionId.map((item) => item.id), <String>['bench-new']);
    expect(syncService.queuedActions, isEmpty);
    expect(syncService.syncAllCalls, isEmpty);
  });

  test('delete removes locally, queues a delete, and requests sync', () async {
    await seed(<WorkoutModel>[
      model(id: 'keep', date: DateTime(2026, 1, 1, 10)),
      model(id: 'delete', date: DateTime(2026, 1, 2, 10)),
    ]);

    await repository.deleteWorkout('delete');

    final stored = await dataSource.getAllWorkouts();
    expect(stored.map((item) => item.id), <String>['keep']);

    expect(syncService.queuedActions, hasLength(1));
    final action = syncService.queuedActions.single;
    expect(action.type, SyncActionType.delete);
    expect(action.dataType, SyncDataType.workout);
    expect(action.dataId, 'delete');
    expect(action.data, <String, dynamic>{
      'id': 'delete',
      'userId': 'Alice',
    });
    expect(syncService.syncAllCalls, <String?>['Alice']);
  });

  test('reads count and pagination exclude foreign workouts', () async {
    await seed(<WorkoutModel>[
      model(id: 'Alice', date: DateTime(2026, 1, 4, 10)),
      model(id: 'legacy', date: DateTime(2026, 1, 3, 10), userId: null),
      model(
        id: 'guest',
        date: DateTime(2026, 1, 2, 10),
        userId: 'local-user',
      ),
      model(id: 'bob', date: DateTime(2026, 1, 5, 10), userId: 'bob'),
    ]);

    final workouts = await repository.getAllWorkouts();
    final page = await repository.getWorkoutsPaginated(offset: 1, limit: 1);

    expect(
      workouts.map((item) => item.id),
      <String>['Alice', 'legacy', 'guest'],
    );
    expect(page.map((item) => item.id), <String>['legacy']);
    expect(await repository.getWorkoutCount(), 3);
  });

  test('foreign save and delete are refused without sync side effects',
      () async {
    await seed(<WorkoutModel>[
      model(id: 'bob', date: DateTime(2026, 1, 5, 10), userId: 'bob'),
    ]);

    await repository.saveWorkout(
      workout(id: 'new-bob', date: DateTime(2026, 1, 6, 10), userId: 'bob'),
    );
    await repository.saveWorkout(
      workout(id: 'bob', date: DateTime(2026, 1, 7, 10)),
    );
    await repository.deleteWorkout('bob');

    final stored = await dataSource.getAllWorkouts();
    expect(stored, hasLength(1));
    expect(stored.single.id, 'bob');
    expect(stored.single.userId, 'bob');
    expect(stored.single.date, DateTime(2026, 1, 5, 10).toIso8601String());
    expect(syncService.queuedActions, isEmpty);
    expect(syncService.syncAllCalls, isEmpty);
  });
}
