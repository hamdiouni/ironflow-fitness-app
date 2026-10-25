import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/workout/data/datasources/hive_workout_data_source.dart';
import 'package:progression_tracker/features/workout/data/repositories/workout_repository_impl.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_type.dart';
import 'package:progression_tracker/features/workout/domain/entities/set_entry.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';

void main() {
  late Directory tempDir;
  late Box<Map> workoutsBox;
  late WorkoutRepositoryImpl repository;

  Exercise exercise({
    required String id,
    required String name,
    String? exerciseDefinitionId,
  }) {
    return Exercise(
      id: id,
      name: name,
      type: ExerciseType.strength,
      exerciseDefinitionId: exerciseDefinitionId,
      sets: <SetEntry>[
        SetEntry(
          id: '$id-set',
          reps: 8,
          weight: 100,
          timestamp: DateTime(2026, 1, 1, 10),
        ),
      ],
    );
  }

  Workout workout({
    required String id,
    required DateTime date,
    List<Exercise> exercises = const <Exercise>[],
    String? userId,
  }) {
    return Workout(
      id: id,
      date: date,
      exercises: exercises,
      duration: const Duration(minutes: 45),
      totalVolume: 1000,
      userId: userId,
    );
  }

  Future<void> saveAll(List<Workout> workouts) async {
    for (final item in workouts) {
      await repository.saveWorkout(item);
    }
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('workout_repository_');
    Hive.init(tempDir.path);
    workoutsBox = await Hive.openBox<Map>('workouts');
  });

  setUp(() async {
    await workoutsBox.clear();
    repository = WorkoutRepositoryImpl(HiveWorkoutDataSource());
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('save stamps updatedAt and all workouts are newest first', () async {
    final before = DateTime.now().subtract(const Duration(seconds: 1));
    await saveAll(<Workout>[
      workout(id: 'oldest', date: DateTime(2026, 1, 1, 10)),
      workout(id: 'newest', date: DateTime(2026, 1, 3, 10)),
      workout(id: 'middle', date: DateTime(2026, 1, 2, 10)),
    ]);
    final after = DateTime.now().add(const Duration(seconds: 1));

    final workouts = await repository.getAllWorkouts();

    expect(
      workouts.map((item) => item.id),
      <String>['newest', 'middle', 'oldest'],
    );
    expect(await repository.getWorkoutCount(), 3);
    for (final item in workouts) {
      expect(item.updatedAt, isNotNull);
      expect(item.updatedAt!.isBefore(before), isFalse);
      expect(item.updatedAt!.isAfter(after), isFalse);
    }
  });

  test('date range excludes both exact boundaries', () async {
    final start = DateTime(2026, 1, 1, 10);
    final end = DateTime(2026, 1, 3, 10);
    await saveAll(<Workout>[
      workout(id: 'at-start', date: start),
      workout(id: 'inside', date: DateTime(2026, 1, 2, 10)),
      workout(id: 'at-end', date: end),
    ]);

    final workouts = await repository.getWorkoutsByDateRange(start, end);

    expect(workouts.map((item) => item.id), <String>['inside']);
  });

  test('pagination is applied after newest-first sorting', () async {
    await saveAll(<Workout>[
      workout(id: 'day-1', date: DateTime(2026, 1, 1, 10)),
      workout(id: 'day-5', date: DateTime(2026, 1, 5, 10)),
      workout(id: 'day-3', date: DateTime(2026, 1, 3, 10)),
      workout(id: 'day-2', date: DateTime(2026, 1, 2, 10)),
      workout(id: 'day-4', date: DateTime(2026, 1, 4, 10)),
    ]);

    final page = await repository.getWorkoutsPaginated(offset: 1, limit: 2);
    final beyondEnd =
        await repository.getWorkoutsPaginated(offset: 99, limit: 2);

    expect(page.map((item) => item.id), <String>['day-4', 'day-3']);
    expect(beyondEnd, isEmpty);
    expect(await repository.getWorkoutCount(), 5);
  });

  test('exercise history matches names and definition ids with a limit',
      () async {
    await saveAll(<Workout>[
      workout(
        id: 'oldest',
        date: DateTime(2026, 1, 1, 10),
        exercises: <Exercise>[
          exercise(id: 'squat-entry', name: 'Squat'),
        ],
      ),
      workout(
        id: 'middle',
        date: DateTime(2026, 1, 2, 10),
        exercises: <Exercise>[
          exercise(id: 'bench-middle', name: 'bench press'),
        ],
      ),
      workout(
        id: 'newest',
        date: DateTime(2026, 1, 3, 10),
        exercises: <Exercise>[
          exercise(
            id: 'bench-newest',
            name: 'Bench Press',
            exerciseDefinitionId: 'chest_001',
          ),
        ],
      ),
    ]);

    final byName = await repository.getExerciseHistory('BENCH PRESS', 1);
    final byDefinitionId =
        await repository.getExerciseHistory('chest_001', 10);

    expect(byName.map((item) => item.id), <String>['bench-newest']);
    expect(
      byDefinitionId.map((item) => item.id),
      <String>['bench-newest'],
    );
  });

  test('delete removes only the requested workout', () async {
    await saveAll(<Workout>[
      workout(id: 'keep', date: DateTime(2026, 1, 1, 10)),
      workout(id: 'delete', date: DateTime(2026, 1, 2, 10)),
    ]);

    await repository.deleteWorkout('delete');

    final workouts = await repository.getAllWorkouts();
    expect(workouts.map((item) => item.id), <String>['keep']);
    expect(await repository.getWorkoutCount(), 1);
  });

  test('scoped repository excludes and protects foreign workouts', () async {
    await saveAll(<Workout>[
      workout(id: 'Alice', date: DateTime(2026, 1, 4, 10), userId: 'Alice'),
      workout(id: 'legacy', date: DateTime(2026, 1, 3, 10)),
      workout(id: 'guest', date: DateTime(2026, 1, 2, 10), userId: 'local-user'),
      workout(id: 'bob', date: DateTime(2026, 1, 5, 10), userId: 'bob'),
    ]);
    final scopedRepository = WorkoutRepositoryImpl(
      HiveWorkoutDataSource(),
      userId: 'Alice',
    );

    final workouts = await scopedRepository.getAllWorkouts();
    final page =
        await scopedRepository.getWorkoutsPaginated(offset: 1, limit: 1);

    expect(
      workouts.map((item) => item.id),
      <String>['Alice', 'legacy', 'guest'],
    );
    expect(page.map((item) => item.id), <String>['legacy']);
    expect(await scopedRepository.getWorkoutCount(), 3);

    await scopedRepository.deleteWorkout('bob');
    expect(
      (await repository.getAllWorkouts()).map((item) => item.id),
      contains('bob'),
    );

    await scopedRepository.saveWorkout(
      workout(id: 'new-bob', date: DateTime(2026, 1, 6, 10), userId: 'bob'),
    );
    await scopedRepository.saveWorkout(
      workout(id: 'bob', date: DateTime(2026, 1, 7, 10)),
    );
    expect(
      (await repository.getAllWorkouts()).map((item) => item.id),
      isNot(contains('new-bob')),
    );
    final bobWorkout = (await repository.getAllWorkouts())
        .singleWhere((item) => item.id == 'bob');
    expect(bobWorkout.userId, 'bob');
    expect(bobWorkout.date, DateTime(2026, 1, 5, 10));

    await scopedRepository.saveWorkout(
      workout(id: 'guest', date: DateTime(2026, 1, 2, 10), userId: 'local-user'),
    );
    final guestWorkout = (await scopedRepository.getAllWorkouts())
        .singleWhere((item) => item.id == 'guest');
    expect(guestWorkout.userId, 'Alice');
  });
}
