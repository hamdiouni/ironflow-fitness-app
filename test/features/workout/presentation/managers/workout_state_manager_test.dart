import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/presentation/managers/workout_state_manager.dart';

void main() {
  late Directory tempDir;
  late WorkoutStateManager manager;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('workout_state_test_');
    Hive.init(tempDir.path);
    manager = WorkoutStateManager();
    await manager.init();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('WorkoutStateManager', () {
    final testWorkout = Workout(
      id: 'w_test_1',
      date: DateTime(2026, 10, 16, 9, 30),
      duration: const Duration(minutes: 45),
      totalVolume: 3500.0,
      caloriesBurned: 280.0,
      exercises: [
        Exercise(
          id: 'ex_1',
          name: 'Bench Press',
          type: ExerciseType.strength,
          sets: [
            SetEntry(
              id: 'set_1',
              reps: 10,
              weight: 80.0,
              rpe: 8,
              timestamp: DateTime(2026, 10, 16, 9, 35),
            ),
          ],
        ),
      ],
    );

    test('initial state has no saved workout', () async {
      expect(manager.hasSavedState, isFalse);
      final restored = await manager.restoreState();
      expect(restored, isNull);
    });

    test('saveState persists workout and restoreState accurately retrieves it', () async {
      final startTime = DateTime(2026, 10, 16, 9, 30);
      await manager.saveState(testWorkout, startTime);

      expect(manager.hasSavedState, isTrue);

      final restored = await manager.restoreState();
      expect(restored, isNotNull);
      expect(restored!.workout.id, testWorkout.id);
      expect(restored.workout.totalVolume, 3500.0);
      expect(restored.workout.exercises.length, 1);
      expect(restored.workout.exercises.first.name, 'Bench Press');
      expect(restored.workout.exercises.first.sets.first.weight, 80.0);
      expect(restored.startTime, startTime);
    });

    test('clearState removes saved state completely', () async {
      final startTime = DateTime(2026, 10, 16, 9, 30);
      await manager.saveState(testWorkout, startTime);
      expect(manager.hasSavedState, isTrue);

      await manager.clearState();
      expect(manager.hasSavedState, isFalse);
      final restored = await manager.restoreState();
      expect(restored, isNull);
    });

    test('recovers gracefully from corrupted JSON state', () async {
      final box = Hive.box<dynamic>('active_workout_state');
      await box.put('current_workout', 'INVALID_NOT_JSON');
      await box.put('start_time', DateTime.now().toIso8601String());

      expect(manager.hasSavedState, isTrue);
      final restored = await manager.restoreState();
      expect(restored, isNull);
      expect(manager.hasSavedState, isFalse); // Corrupted state cleared
    });

    test('saveRestTimer, getRestTimer, and clearRestTimer work as expected', () async {
      expect(manager.getRestTimer(), isNull);

      final target = DateTime(2026, 10, 18, 20, 0, 0);
      await manager.saveRestTimer(target, 90);

      final restored = manager.getRestTimer();
      expect(restored, isNotNull);
      expect(restored!.targetEndTime, target);
      expect(restored.totalSeconds, 90);

      await manager.clearRestTimer();
      expect(manager.getRestTimer(), isNull);
    });
  });
}
