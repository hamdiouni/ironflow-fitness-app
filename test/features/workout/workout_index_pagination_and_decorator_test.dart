import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/core/utils/hive_manager.dart';
import 'package:progression_tracker/features/sync/data/datasources/firestore_sync_datasource.dart';
import 'package:progression_tracker/features/sync/data/datasources/hive_sync_queue_datasource.dart';
import 'package:progression_tracker/features/sync/data/services/sync_service.dart';
import 'package:progression_tracker/features/sync/domain/entities/sync_action.dart';
import 'package:progression_tracker/features/workout/data/datasources/hive_active_program_datasource.dart';
import 'package:progression_tracker/features/workout/data/datasources/hive_workout_data_source.dart';
import 'package:progression_tracker/features/workout/data/models/workout_model.dart';
import 'package:progression_tracker/features/workout/data/repositories/synced_workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';

class _OfflineConnectivity implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      const [ConnectivityResult.none];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value(const [ConnectivityResult.none]);
}

class _NoOpFirestoreSync extends Fake implements FirestoreSyncDataSource {}

class _RecordingSyncService extends SyncService {
  _RecordingSyncService({required super.hiveWorkouts})
      : super(
          syncQueue: HiveSyncQueueDataSourceImpl(),
          firestoreSync: _NoOpFirestoreSync(),
          hivePrograms: HiveActiveProgramDataSource(),
          connectivity: _OfflineConnectivity(),
          enableInitialPush: false,
        );

  final List<({SyncActionType type, String dataId})> queued = [];

  @override
  Future<void> queueAction({
    required SyncActionType type,
    required SyncDataType dataType,
    required String dataId,
    required Map<String, dynamic> data,
  }) async {
    queued.add((type: type, dataId: dataId));
  }
}

class _FakeDelegateWorkoutRepository implements WorkoutRepository {
  final Map<String, Workout> workouts = {};
  int getAllCalls = 0;
  int paginatedCalls = 0;
  int countCalls = 0;
  int historyCalls = 0;
  int rangeCalls = 0;

  @override
  Future<void> saveWorkout(Workout workout) async {
    workouts[workout.id] = workout;
  }

  @override
  Future<List<Workout>> getAllWorkouts() async {
    getAllCalls++;
    return workouts.values.toList();
  }

  @override
  Future<List<Workout>> getWorkoutsPaginated({
    int offset = 0,
    int limit = 20,
  }) async {
    paginatedCalls++;
    return workouts.values.skip(offset).take(limit).toList();
  }

  @override
  Future<int> getWorkoutCount() async {
    countCalls++;
    return workouts.length;
  }

  @override
  Future<List<Exercise>> getExerciseHistory(String exerciseName, int limit) async {
    historyCalls++;
    return const [];
  }

  @override
  Future<List<Workout>> getWorkoutsByDateRange(DateTime start, DateTime end) async {
    rangeCalls++;
    return const [];
  }

  @override
  Future<void> deleteWorkout(String id) async {
    workouts.remove(id);
  }
}

void main() {
  late Directory tempDir;
  late Box<Map> workoutsBox;
  late HiveWorkoutDataSource dataSource;

  WorkoutModel sampleModel(String id, DateTime date, {String? userId}) {
    return WorkoutModel(
      id: id,
      date: date.toIso8601String(),
      exercises: const [],
      durationSeconds: 1800,
      totalVolume: 500,
      userId: userId,
    );
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('workout_index_dec_test_');
    Hive.init(tempDir.path);
    workoutsBox = await Hive.openBox<Map>('workouts');
  });

  setUp(() async {
    await workoutsBox.clear();
    dataSource = HiveWorkoutDataSource();
  });

  tearDownAll(() async {
    await Hive.close();
    HiveManager.resetForTest();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('HiveWorkoutDataSource maintains __workout_time_index__ and excludes index from count and O(page) slices', () async {
    final w1 = sampleModel('w1', DateTime(2026, 1, 10), userId: 'alice');
    final w2 = sampleModel('w2', DateTime(2026, 1, 12), userId: 'alice');
    final w3 = sampleModel('w3', DateTime(2026, 1, 11), userId: 'bob');
    await dataSource.saveWorkout(w1);
    await dataSource.saveWorkout(w2);
    await dataSource.saveWorkout(w3);

    expect(workoutsBox.containsKey(HiveWorkoutDataSource.indexKey), isTrue);
    expect(await dataSource.getWorkoutCount(), 3);
    expect((await dataSource.getWorkoutById('w2'))?.id, 'w2');

    // Inject corrupt record outside target page: getAllWorkouts & getWorkoutsPaginated survive
    await workoutsBox.put('corrupt_oldest', {
      'id': 'corrupt_oldest',
      'date': 12345, // invalid String type for date
      'exercises': 'bad',
    });

    final page1 = await dataSource.getWorkoutsPaginated(offset: 0, limit: 2);
    expect(page1.map((w) => w.id), ['w2', 'w3']);

    // Delete rebuilds/updates index cleanly
    await dataSource.deleteWorkout('w2');
    final all = await dataSource.getAllWorkouts();
    expect(all.map((w) => w.id), ['w3', 'w1']);
  });

  test('SyncedWorkoutRepository acts as pure Decorator forwarding queries and queueing sync only for valid writes', () async {
    final delegate = _FakeDelegateWorkoutRepository();
    final syncService = _RecordingSyncService(hiveWorkouts: dataSource);
    addTearDown(syncService.dispose);

    final repo = SyncedWorkoutRepository(
      delegate: delegate,
      syncService: syncService,
      userId: 'alice',
    );

    final wAlice = Workout(
      id: 'w_a',
      date: DateTime(2026, 2, 1),
      exercises: const [],
      duration: const Duration(minutes: 30),
      totalVolume: 100,
      userId: 'alice',
    );
    await repo.saveWorkout(wAlice);
    expect(delegate.workouts.containsKey('w_a'), isTrue);
    expect(syncService.queued, [(type: SyncActionType.create, dataId: 'w_a')]);

    // Foreign workout is blocked without queueing sync
    final wBob = wAlice.copyWith(id: 'w_b', userId: 'bob');
    await repo.saveWorkout(wBob);
    expect(delegate.workouts.containsKey('w_b'), isFalse);
    expect(syncService.queued, hasLength(1));

    await repo.getAllWorkouts();
    await repo.getWorkoutsPaginated(offset: 0, limit: 10);
    await repo.getWorkoutCount();
    await repo.getExerciseHistory('Bench Press', 5);
    await repo.getWorkoutsByDateRange(DateTime(2026), DateTime(2027));

    expect(delegate.getAllCalls, 1);
    expect(delegate.paginatedCalls, 1);
    expect(delegate.countCalls, 1);
    expect(delegate.historyCalls, 1);
    expect(delegate.rangeCalls, 1);

    await repo.deleteWorkout('w_a');
    expect(delegate.workouts.containsKey('w_a'), isFalse);
    expect(syncService.queued.last, (type: SyncActionType.delete, dataId: 'w_a'));
  });
}
