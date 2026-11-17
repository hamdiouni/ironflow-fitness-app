import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/core/utils/data_migration.dart';
import 'package:progression_tracker/features/workout/data/exercise_database.dart';
import 'package:progression_tracker/features/workout/domain/services/exercise_alias_resolver.dart';
import 'package:progression_tracker/features/workout/domain/services/exercise_catalog.dart';

void main() {
  group('Wave 3.4 Exercise Deduplication, Alias Map & Migration', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('ironflow_alias_mig_');
      Hive.init(tempDir.path);
      await Hive.openBox<String>('app_settings');
      await Hive.openBox<Map>('workouts');
      await Hive.openBox<Map>('meals');
      await Hive.openBox<Map>('body_entries');
      await Hive.openBox<Map>('active_program');
      await Hive.openBox<Map>('sync_queue');
    });

    tearDownAll(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('confirms real exercise count (150 raw -> 129 unique canonical)', () {
      expect(ExerciseDatabase.legacyRawCount, 150);
      expect(ExerciseCatalog.all.length, 129);
      expect(ExerciseDatabase.all.length, 129);

      final ids = ExerciseCatalog.all.map((e) => e.id).toSet();
      final names = ExerciseCatalog.all
          .map((e) => e.name.trim().toLowerCase())
          .toSet();
      expect(ids.length, 129, reason: 'Zero duplicate exercise IDs');
      expect(names.length, 129, reason: 'Zero duplicate exercise names');

      for (final ex in ExerciseCatalog.all) {
        expect(ex.primaryRegions, isNotEmpty,
            reason: '${ex.id} (${ex.name}) must have Body Map primaryRegions');
        expect(
          ex.animationUrl,
          isNot(contains('dQw4w9WgXcQ')),
          reason: 'Placeholder Rickroll URLs must be stripped',
        );
      }
    });

    test('resolves all retired IDs, colliding (id, name) pairs, and name aliases', () {
      String? byName(String norm) => ExerciseCatalog.getByName(norm)?.id;

      // Retired IDs (back_013 -> back_009 Assisted Pull-Up; fullbody_004 -> specialty_002 Battle Ropes)
      expect(
        ExerciseAliasResolver.resolveCanonicalId(
          storedDefinitionId: 'back_013',
          exerciseName: 'Assisted Pull-Up',
          canonicalIdByName: byName,
        ),
        'back_009',
      );
      expect(
        ExerciseAliasResolver.resolveCanonicalId(
          storedDefinitionId: 'fullbody_004',
          exerciseName: 'Battle Ropes',
          canonicalIdByName: byName,
        ),
        'specialty_002',
      );

      // Colliding (legacyId, name) pairs reassigned to fresh IDs
      expect(
        ExerciseAliasResolver.resolveCanonicalId(
          storedDefinitionId: 'back_010',
          exerciseName: 'Seal Row',
          canonicalIdByName: byName,
        ),
        'back_016',
      );
      expect(
        ExerciseAliasResolver.resolveCanonicalId(
          storedDefinitionId: 'back_010',
          exerciseName: 'Chin-Up',
          canonicalIdByName: byName,
        ),
        'back_010',
      );
      expect(
        ExerciseAliasResolver.resolveCanonicalId(
          storedDefinitionId: 'glutes_008',
          exerciseName: 'Single-Leg Hip Thrust',
          canonicalIdByName: byName,
        ),
        'glutes_013',
      );

      // Swapped duplicate-name IDs
      expect(
        ExerciseAliasResolver.resolveCanonicalId(
          storedDefinitionId: 'abs_006',
          exerciseName: 'Ab Wheel Rollout',
          canonicalIdByName: byName,
        ),
        'abs_007',
      );

      // Name alias ('Elliptical' -> 'Elliptical Machine' -> cardio_006)
      expect(
        ExerciseAliasResolver.resolveCanonicalId(
          storedDefinitionId: 'cardio_009',
          exerciseName: 'Elliptical',
          canonicalIdByName: byName,
        ),
        'cardio_006',
      );
      expect(ExerciseDatabase.getByName('Elliptical')?.id, 'cardio_006');
    });

    test('DataMigration repairs workouts and active programs idempotently on v3 databases', () async {
      final settingsBox = Hive.box<String>('app_settings');
      final workoutsBox = Hive.box<Map>('workouts');
      final programBox = Hive.box<Map>('active_program');

      await settingsBox.clear();
      await workoutsBox.clear();
      await programBox.clear();

      // Simulate an already-upgraded v3 database containing colliding legacy IDs
      await settingsBox.put('schema_version', '3');

      await workoutsBox.put('w1', <String, dynamic>{
        'id': 'w1',
        'userId': 'user_1',
        'date': '2026-10-01T10:00:00.000',
        'exercises': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'ex1',
            'name': 'Seal Row',
            'exerciseDefinitionId': 'back_010', // collided with Chin-Up
            'sets': <Map<String, dynamic>>[
              <String, dynamic>{'reps': 10, 'weight': 60.0},
            ],
          },
          <String, dynamic>{
            'id': 'ex2',
            'name': 'Assisted Pull-Up',
            'exerciseDefinitionId': 'back_013', // retired duplicate of back_009
          },
          <String, dynamic>{
            'id': 'ex3',
            'name': 'Elliptical',
            'exerciseDefinitionId': 'cardio_009', // collided with Stair Climber
          },
        ],
      });

      await programBox.put('active_program_user_1', <String, dynamic>{
        'userId': 'user_1',
        'program': <String, dynamic>{
          'userId': 'user_1',
          'days': <Map<String, dynamic>>[
            <String, dynamic>{
              'exercises': <Map<String, dynamic>>[
                <String, dynamic>{
                  'exerciseName': 'V-Squat',
                  'exerciseDefinitionId': 'legs_015', // collided with Hack Squat
                },
              ],
            },
          ],
        },
      });

      await DataMigration.runIfNeeded(currentUserId: 'user_1');

      final migratedWorkout = workoutsBox.get('w1')!;
      final exList = migratedWorkout['exercises'] as List;
      expect((exList[0] as Map)['exerciseDefinitionId'], 'back_016');
      expect(((exList[0] as Map)['sets'] as List).single['weight'], 60.0);
      expect((exList[1] as Map)['exerciseDefinitionId'], 'back_009');
      expect((exList[2] as Map)['exerciseDefinitionId'], 'cardio_006');
      expect(migratedWorkout['userId'], 'user_1');

      final migratedProgram = programBox.get('active_program_user_1')!;
      final progEx = (((migratedProgram['program'] as Map)['days'] as List)
              .single as Map)['exercises'] as List;
      expect((progEx.single as Map)['exerciseDefinitionId'], 'legs_016');

      // Second run is strictly idempotent (0 records rewritten)
      final updatedAgain = await DataMigration.migrateCanonicalExerciseAliases();
      expect(updatedAgain, 0);
      expect(settingsBox.get('schema_version'), '4');
      expect(settingsBox.get('exercise_alias_migration_version'), '1');
    });
  });
}
