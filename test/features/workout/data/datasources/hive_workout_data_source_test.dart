import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/workout/data/datasources/hive_workout_data_source.dart';
import 'package:progression_tracker/features/workout/data/models/workout_model.dart';

void main() {
  late Directory tempDir;
  late Box<Map> workoutsBox;
  late HiveWorkoutDataSource dataSource;

  WorkoutModel workout({required String id, required DateTime date}) {
    return WorkoutModel(
      id: id,
      date: date.toIso8601String(),
      exercises: const [],
      durationSeconds: 2700,
      totalVolume: 1000,
      userId: 'Alice',
      updatedAt: '2026-01-01T00:00:00.000',
    );
  }

  Future<void> letStreamSubscribe() {
    return Future<void>.delayed(const Duration(milliseconds: 10));
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_workout_stream_');
    Hive.init(tempDir.path);
    workoutsBox = await Hive.openBox<Map>('workouts');
  });

  setUp(() async {
    await workoutsBox.clear();
    dataSource = HiveWorkoutDataSource();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('watchAllWorkouts starts with the current sorted snapshot', () async {
    await dataSource.saveWorkout(
      workout(id: 'day-1', date: DateTime(2026, 1, 1, 10)),
    );
    await dataSource.saveWorkout(
      workout(id: 'day-3', date: DateTime(2026, 1, 3, 10)),
    );

    final snapshot = await dataSource.watchAllWorkouts().first;

    expect(snapshot.map((item) => item.id), <String>['day-3', 'day-1']);
  });

  test('watchAllWorkouts emits a fresh sorted snapshot after writes',
      () async {
    final snapshotsFuture = dataSource.watchAllWorkouts().take(4).toList();
    await letStreamSubscribe();

    await dataSource.saveWorkout(
      workout(id: 'day-1', date: DateTime(2026, 1, 1, 10)),
    );
    await letStreamSubscribe();
    await dataSource.saveWorkout(
      workout(id: 'day-3', date: DateTime(2026, 1, 3, 10)),
    );
    await letStreamSubscribe();
    await dataSource.deleteWorkout('day-1');

    final snapshots = await snapshotsFuture.timeout(
      const Duration(seconds: 5),
    );

    expect(
      snapshots.map(
        (snapshot) => snapshot.map((item) => item.id).toList(growable: false),
      ),
      <List<String>>[
        <String>[],
        <String>['day-1'],
        <String>['day-3', 'day-1'],
        <String>['day-3'],
      ],
    );
  });
}
