import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/workout/data/exercise_database.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_definition.dart';

void main() {
  group('ExerciseDatabase Library Audit & Queries', () {
    test('all exercises have unique IDs, unique names, and mandatory fields', () {
      final exercises = ExerciseDatabase.all;
      expect(ExerciseDatabase.legacyRawCount, 150);
      expect(exercises.length, 129);

      final ids = exercises.map((e) => e.id).toSet();
      final names = exercises.map((e) => e.name.toLowerCase()).toSet();
      expect(ids.length, exercises.length, reason: 'Duplicate IDs detected');
      expect(names.length, exercises.length, reason: 'Duplicate names detected');

      for (final ex in exercises) {
        expect(ex.id.trim().isNotEmpty, isTrue, reason: 'Empty ID');
        expect(ex.name.trim().isNotEmpty, isTrue, reason: 'Empty name for ${ex.id}');
        expect(ex.subMuscle.trim().isNotEmpty, isTrue, reason: 'Empty subMuscle for ${ex.id}');
        expect(ex.instructions.trim().isNotEmpty, isTrue, reason: 'Empty instructions for ${ex.id}');
        expect(ex.primaryMuscles.isNotEmpty, isTrue, reason: 'Empty primaryMuscles for ${ex.id}');
        expect(ex.primaryRegions.isNotEmpty, isTrue, reason: 'Empty primaryRegions for ${ex.id}');
      }
    });

    test('alias map resolves retired duplicate IDs and colliding ID+name pairs', () {
      // Retired duplicate IDs resolve to canonical IDs
      expect(ExerciseDatabase.getById('back_013')?.id, 'back_009');
      expect(ExerciseDatabase.getById('back_014')?.id, 'back_010');
      expect(ExerciseDatabase.getById('shoulders_010')?.id, 'shoulders_008');
      expect(ExerciseDatabase.getById('fullbody_003')?.id, 'specialty_001');
      expect(ExerciseDatabase.getById('fullbody_004')?.id, 'specialty_002');

      // Colliding legacy IDs disambiguate when exerciseName is supplied
      expect(
        ExerciseDatabase.getById('back_010', exerciseName: 'Chin-Up')?.id,
        'back_010',
      );
      expect(
        ExerciseDatabase.getById('back_010', exerciseName: 'Seal Row')?.id,
        'back_016',
      );
      expect(
        ExerciseDatabase.getById('glutes_004', exerciseName: 'Smith Machine Hip Thrust')?.id,
        'glutes_009',
      );

      // Name alias resolution
      expect(ExerciseDatabase.getByName('Elliptical')?.id, 'cardio_006');
      expect(ExerciseDatabase.getByName('Elliptical')?.name, 'Elliptical Machine');
    });

    test('getById returns matching exercise definition or null', () {
      final bench = ExerciseDatabase.getById('chest_001');
      expect(bench, isNotNull);
      expect(bench!.name, 'Bench Press');
      expect(bench.muscleGroup, MuscleGroup.chest);

      final notFound = ExerciseDatabase.getById('non_existent_id');
      expect(notFound, isNull);
    });

    test('getByName matches case-insensitively and handles whitespace', () {
      final squat1 = ExerciseDatabase.getByName('Squat');
      final squat2 = ExerciseDatabase.getByName('  squat  ');
      final squat3 = ExerciseDatabase.getByName('SQUAT');

      expect(squat1, isNotNull);
      expect(squat2, isNotNull);
      expect(squat3, isNotNull);
      expect(squat1!.id, squat2!.id);

      final unknown = ExerciseDatabase.getByName('Zero Gravity Hover Lift');
      expect(unknown, isNull);
    });

    test('getByMuscleGroup filters exercises by primary and secondary targets', () {
      final chestExercises = ExerciseDatabase.getByMuscleGroup(MuscleGroup.chest);
      expect(chestExercises.isNotEmpty, isTrue);
      for (final ex in chestExercises) {
        final matches = ex.muscleGroup == MuscleGroup.chest ||
            ex.primaryMuscles.contains(MuscleGroup.chest);
        expect(matches, isTrue);
      }
    });

    test('getByEquipment filters exercises accurately', () {
      final barbells = ExerciseDatabase.getByEquipment(Equipment.barbell);
      expect(barbells.isNotEmpty, isTrue);
      for (final ex in barbells) {
        expect(ex.equipment, Equipment.barbell);
      }
    });

    test('search filters across name, subMuscle, and muscle group', () {
      final curls = ExerciseDatabase.search('curl');
      expect(curls.isNotEmpty, isTrue);
      for (final ex in curls) {
        final text = '${ex.name} ${ex.subMuscle} ${ex.muscleGroup.name}'.toLowerCase();
        expect(text.contains('curl'), isTrue);
      }

      final emptyQuery = ExerciseDatabase.search('');
      expect(emptyQuery.length, ExerciseDatabase.all.length);
    });
  });
}
