import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/core/utils/data_migration.dart';

void main() {
  late Directory tempDir;
  late Box<String> settingsBox;
  late Box<Map> workoutsBox;
  late Box<Map> mealsBox;
  late Box<Map> bodyEntriesBox;
  late Box<Map> activeProgramBox;
  late Box<Map> syncQueueBox;

  Map<String, dynamic> asMap(Object? value) {
    return Map<String, dynamic>.from(value! as Map);
  }

  Future<void> reset({String? schemaVersion}) async {
    await settingsBox.clear();
    await workoutsBox.clear();
    await mealsBox.clear();
    await bodyEntriesBox.clear();
    await activeProgramBox.clear();
    await syncQueueBox.clear();
    if (schemaVersion != null) {
      await settingsBox.put('schema_version', schemaVersion);
    }
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('data_migration_test_');
    Hive.init(tempDir.path);
    settingsBox = await Hive.openBox<String>('app_settings');
    workoutsBox = await Hive.openBox<Map>('workouts');
    mealsBox = await Hive.openBox<Map>('meals');
    bodyEntriesBox = await Hive.openBox<Map>('body_entries');
    activeProgramBox = await Hive.openBox<Map>('active_program');
    syncQueueBox = await Hive.openBox<Map>('sync_queue');
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('v1 data is backfilled to v3 without overwriting existing owners',
      () async {
    await reset();

    await workoutsBox.put('w-legacy', <String, dynamic>{
      'id': 'w-legacy',
      'date': '2026-01-02T03:04:05.000',
      'exercises': <Map<String, dynamic>>[
        <String, dynamic>{'name': 'Bench Press'},
      ],
    });
    await workoutsBox.put('w-owned', <String, dynamic>{
      'id': 'w-owned',
      'date': '2026-01-03T03:04:05.000',
      'userId': 'bob',
      'updatedAt': '2026-02-01T00:00:00.000',
      'exercises': <Map<String, dynamic>>[],
    });
    await mealsBox.put('m-legacy', <String, dynamic>{
      'id': 'm-legacy',
      'timestamp': '2026-01-02T08:00:00.000',
    });
    await bodyEntriesBox.put('b-legacy', <String, dynamic>{
      'id': 'b-legacy',
      'date': '2026-01-02T07:00:00.000',
    });
    await activeProgramBox.put('ap-legacy', <String, dynamic>{
      'id': 'ap-legacy',
      'program': <String, dynamic>{
        'id': 'p-legacy',
        'days': <Map<String, dynamic>>[
          <String, dynamic>{
            'exercises': <Map<String, dynamic>>[
              <String, dynamic>{'exerciseName': 'Bench Press'},
            ],
          },
        ],
      },
    });
    await syncQueueBox.put('valid-action', <String, dynamic>{
      'dataType': 'workout',
      'dataId': 'w-legacy',
      'status': 'pending',
    });
    await syncQueueBox.put('legacy-operation', <String, dynamic>{
      'operation': 'upload-workout',
    });
    await syncQueueBox.put('missing-status', <String, dynamic>{
      'dataType': 'workout',
      'dataId': 'w-owned',
    });

    await DataMigration.runIfNeeded(currentUserId: 'Alice');

    expect(settingsBox.get('schema_version'), '3');

    final migratedWorkout = asMap(workoutsBox.get('w-legacy'));
    expect(migratedWorkout['userId'], 'Alice');
    expect(migratedWorkout['updatedAt'], migratedWorkout['date']);
    final workoutExercises = migratedWorkout['exercises'] as List;
    final workoutExercise = asMap(workoutExercises.single);
    expect(workoutExercise['exerciseDefinitionId'], 'chest_001');

    final ownedWorkout = asMap(workoutsBox.get('w-owned'));
    expect(ownedWorkout['userId'], 'bob');
    expect(ownedWorkout['updatedAt'], '2026-02-01T00:00:00.000');

    final migratedMeal = asMap(mealsBox.get('m-legacy'));
    expect(migratedMeal['userId'], 'Alice');
    expect(migratedMeal['updatedAt'], migratedMeal['timestamp']);

    final migratedBodyEntry = asMap(bodyEntriesBox.get('b-legacy'));
    expect(migratedBodyEntry['userId'], 'Alice');

    final migratedActiveProgram = asMap(activeProgramBox.get('ap-legacy'));
    expect(migratedActiveProgram['userId'], 'Alice');
    final migratedProgram = asMap(migratedActiveProgram['program']);
    expect(migratedProgram['userId'], 'Alice');
    final programDays = migratedProgram['days'] as List;
    final programDay = asMap(programDays.single);
    final programExercises = programDay['exercises'] as List;
    final programExercise = asMap(programExercises.single);
    expect(programExercise['exerciseDefinitionId'], 'chest_001');

    expect(syncQueueBox.keys.toList(), <dynamic>['valid-action']);

    // A second run at v3 must not restamp records for another account.
    await DataMigration.runIfNeeded(currentUserId: 'bob');
    expect(asMap(workoutsBox.get('w-legacy'))['userId'], 'Alice');
    expect(settingsBox.get('schema_version'), '3');
  });

  test('v2 to v3 only purges legacy sync queue entries', () async {
    await reset(schemaVersion: '2');
    await workoutsBox.put('w-v2', <String, dynamic>{
      'id': 'w-v2',
      'date': '2026-01-02T03:04:05.000',
      'exercises': <Map<String, dynamic>>[],
    });
    await syncQueueBox.put('valid-action', <String, dynamic>{
      'dataType': 'workout',
      'dataId': 'w-v2',
      'status': 'pending',
    });
    await syncQueueBox.put('legacy-operation', <String, dynamic>{
      'operation': 'upload-workout',
    });

    await DataMigration.runIfNeeded(currentUserId: 'Alice');

    final workout = asMap(workoutsBox.get('w-v2'));
    expect(workout.containsKey('userId'), isFalse);
    expect(syncQueueBox.keys.toList(), <dynamic>['valid-action']);
    expect(settingsBox.get('schema_version'), '3');
  });

  test('current schema version is a no-op', () async {
    await reset(schemaVersion: '3');
    await workoutsBox.put('w-current', <String, dynamic>{
      'id': 'w-current',
      'date': '2026-01-02T03:04:05.000',
    });
    await syncQueueBox.put('legacy-operation', <String, dynamic>{
      'operation': 'upload-workout',
    });

    await DataMigration.runIfNeeded(currentUserId: 'Alice');

    expect(asMap(workoutsBox.get('w-current')).containsKey('userId'), isFalse);
    expect(syncQueueBox.containsKey('legacy-operation'), isTrue);
    expect(settingsBox.get('schema_version'), '3');
  });

  test('incomplete records do not prevent the version from advancing',
      () async {
    await reset();
    await workoutsBox.put('bad-workout', <String, dynamic>{
      'id': 'bad-workout',
      'exercises': 'not-a-list',
    });
    await mealsBox.put('bad-meal', <String, dynamic>{'id': 'bad-meal'});
    await bodyEntriesBox.put('bad-body', <String, dynamic>{'id': 'bad-body'});
    await activeProgramBox.put('bad-program', <String, dynamic>{
      'id': 'bad-program',
      'program': 'not-a-map',
    });

    await DataMigration.runIfNeeded();

    expect(settingsBox.get('schema_version'), '3');
    expect(workoutsBox.containsKey('bad-workout'), isTrue);
    expect(mealsBox.containsKey('bad-meal'), isTrue);
    expect(bodyEntriesBox.containsKey('bad-body'), isTrue);
    expect(activeProgramBox.containsKey('bad-program'), isTrue);
  });
}
