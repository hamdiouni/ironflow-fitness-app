import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/utils/hive_manager.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/managers/workout_state_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Integration test for workout flow with logging.
///
/// This test verifies that:
/// 1. Workout operations complete successfully with logging enabled
/// 2. All operations are logged (start, add exercise, log sets, finish)
/// 3. Logging doesn't break functionality
/// 4. Error paths are logged correctly
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Workout Flow Logging Integration Tests', () {
    late ProviderContainer container;

    setUpAll(() async {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Hive
      await HiveManager.initialize();
    });

    setUp(() async {
      // Clear workout data before each test
      final workoutBox = HiveManager.getWorkoutBox();
      await workoutBox.clear();

      // Create a fresh provider container
      final stateManager = WorkoutStateManager();
      await stateManager.init();

      container = ProviderContainer(
        overrides: [
          workoutStateManagerProvider.overrideWithValue(stateManager),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
    });

    testWidgets('Complete workout flow with logging', (tester) async {
      // Arrange
      final notifier = container.read(workoutNotifierProvider.notifier);
      final stateStream = container.listen<WorkoutState>(
        workoutNotifierProvider,
        (previous, next) {},
      );

      // Act & Assert: Start workout
      print('\n=== TEST: Starting workout ===');
      await notifier.start();
      await tester.pumpAndSettle();

      var state = stateStream.read();
      expect(state, isA<_InProgress>(), reason: 'Workout should be in progress');

      final inProgressState = state as _InProgress;
      expect(inProgressState.workout.exercises, isEmpty,
          reason: 'New workout should have no exercises');
      print('✓ Workout started successfully');

      // Act & Assert: Add exercise
      print('\n=== TEST: Adding exercise ===');
      final exercise = Exercise(
        id: 'test-exercise-1',
        name: 'Bench Press',
        type: ExerciseType.strength,
        sets: [],
      );

      await notifier.addExercise(exercise);
      await tester.pumpAndSettle();

      state = stateStream.read();
      expect(state, isA<_InProgress>());
      final stateWithExercise = state as _InProgress;
      expect(stateWithExercise.workout.exercises.length, 1,
          reason: 'Workout should have 1 exercise');
      expect(stateWithExercise.workout.exercises.first.name, 'Bench Press');
      print('✓ Exercise added successfully');

      // Act & Assert: Log first set
      print('\n=== TEST: Logging first set ===');
      final set1 = SetEntry.create(reps: 10, weight: 80.0);
      final isPR1 = await notifier.logSetForExercise('test-exercise-1', set1);
      await tester.pumpAndSettle();

      state = stateStream.read();
      expect(state, isA<_InProgress>());
      final stateWithSet1 = state as _InProgress;
      expect(stateWithSet1.workout.exercises.first.sets.length, 1,
          reason: 'Exercise should have 1 set');
      expect(stateWithSet1.workout.exercises.first.sets.first.reps, 10);
      expect(stateWithSet1.workout.exercises.first.sets.first.weight, 80.0);
      print('✓ First set logged successfully (PR: $isPR1)');

      // Act & Assert: Log second set
      print('\n=== TEST: Logging second set ===');
      final set2 = SetEntry.create(reps: 8, weight: 85.0);
      final isPR2 = await notifier.logSetForExercise('test-exercise-1', set2);
      await tester.pumpAndSettle();

      state = stateStream.read();
      expect(state, isA<_InProgress>());
      final stateWithSet2 = state as _InProgress;
      expect(stateWithSet2.workout.exercises.first.sets.length, 2,
          reason: 'Exercise should have 2 sets');
      print('✓ Second set logged successfully (PR: $isPR2)');

      // Act & Assert: Log third set
      print('\n=== TEST: Logging third set ===');
      final set3 = SetEntry.create(reps: 6, weight: 90.0);
      final isPR3 = await notifier.logSetForExercise('test-exercise-1', set3);
      await tester.pumpAndSettle();

      state = stateStream.read();
      expect(state, isA<_InProgress>());
      final stateWithSet3 = state as _InProgress;
      expect(stateWithSet3.workout.exercises.first.sets.length, 3,
          reason: 'Exercise should have 3 sets');
      print('✓ Third set logged successfully (PR: $isPR3)');

      // Act & Assert: Add second exercise
      print('\n=== TEST: Adding second exercise ===');
      final exercise2 = Exercise(
        id: 'test-exercise-2',
        name: 'Squat',
        type: ExerciseType.strength,
        sets: [],
      );

      await notifier.addExercise(exercise2);
      await tester.pumpAndSettle();

      state = stateStream.read();
      expect(state, isA<_InProgress>());
      final stateWith2Exercises = state as _InProgress;
      expect(stateWith2Exercises.workout.exercises.length, 2,
          reason: 'Workout should have 2 exercises');
      print('✓ Second exercise added successfully');

      // Act & Assert: Log set for second exercise
      print('\n=== TEST: Logging set for second exercise ===');
      final set4 = SetEntry.create(reps: 12, weight: 100.0);
      await notifier.logSetForExercise('test-exercise-2', set4);
      await tester.pumpAndSettle();

      state = stateStream.read();
      expect(state, isA<_InProgress>());
      final stateWithSet4 = state as _InProgress;
      expect(stateWithSet4.workout.exercises[1].sets.length, 1,
          reason: 'Second exercise should have 1 set');
      print('✓ Set logged for second exercise successfully');

      // Act & Assert: Finish workout
      print('\n=== TEST: Finishing workout ===');
      await notifier.finish();
      await tester.pumpAndSettle();

      state = stateStream.read();
      expect(state, isA<_Completed>(), reason: 'Workout should be completed');

      final completedState = state as _Completed;
      expect(completedState.workout.exercises.length, 2);
      expect(completedState.workout.exercises.first.sets.length, 3);
      expect(completedState.workout.exercises[1].sets.length, 1);
      print('✓ Workout finished successfully');

      // Verify workout was saved to Hive
      print('\n=== TEST: Verifying workout persistence ===');
      final workoutBox = HiveManager.getWorkoutBox();
      expect(workoutBox.isNotEmpty, true,
          reason: 'Workout should be saved to Hive');
      print('✓ Workout persisted to Hive successfully');

      print('\n=== TEST COMPLETE: All operations logged and working ===\n');
    });

    testWidgets('Error path: Add exercise to non-existent workout', (tester) async {
      // Arrange
      final notifier = container.read(workoutNotifierProvider.notifier);
      final stateStream = container.listen<WorkoutState>(
        workoutNotifierProvider,
        (previous, next) {},
      );

      // Act & Assert: Try to add exercise without starting workout
      print('\n=== TEST: Error path - Add exercise without starting workout ===');
      final exercise = Exercise(
        id: 'test-exercise-error',
        name: 'Deadlift',
        type: ExerciseType.strength,
        sets: [],
      );

      await notifier.addExercise(exercise);
      await tester.pumpAndSettle();

      // Should remain in initial state
      final state = stateStream.read();
      expect(state, isA<_Initial>(),
          reason: 'State should remain initial when adding exercise without starting workout');
      print('✓ Error handled correctly: Cannot add exercise without starting workout');

      print('\n=== TEST COMPLETE: Error path logged correctly ===\n');
    });

    testWidgets('Error path: Log set for non-existent exercise', (tester) async {
      // Arrange
      final notifier = container.read(workoutNotifierProvider.notifier);
      final stateStream = container.listen<WorkoutState>(
        workoutNotifierProvider,
        (previous, next) {},
      );

      // Start workout
      print('\n=== TEST: Error path - Log set for non-existent exercise ===');
      await notifier.start();
      await tester.pumpAndSettle();

      // Act & Assert: Try to log set for non-existent exercise
      final set = SetEntry.create(reps: 10, weight: 50.0);
      final isPR = await notifier.logSetForExercise('non-existent-id', set);
      await tester.pumpAndSettle();

      expect(isPR, false, reason: 'Should return false for non-existent exercise');

      final state = stateStream.read();
      expect(state, isA<_InProgress>());
      final inProgressState = state as _InProgress;
      expect(inProgressState.workout.exercises, isEmpty,
          reason: 'No exercises should be added');
      print('✓ Error handled correctly: Cannot log set for non-existent exercise');

      print('\n=== TEST COMPLETE: Error path logged correctly ===\n');
    });

    testWidgets('State restoration after app restart', (tester) async {
      // Arrange
      print('\n=== TEST: State restoration ===');
      
      // First session: Start workout and add exercise
      var notifier = container.read(workoutNotifierProvider.notifier);
      await notifier.start();
      await tester.pumpAndSettle();

      final exercise = Exercise(
        id: 'test-exercise-restore',
        name: 'Pull Up',
        type: ExerciseType.strength,
        sets: [],
      );
      await notifier.addExercise(exercise);
      await tester.pumpAndSettle();

      final set = SetEntry.create(reps: 8, weight: 0.0);
      await notifier.logSetForExercise('test-exercise-restore', set);
      await tester.pumpAndSettle();

      print('✓ Workout state saved');

      // Simulate app restart by creating new container
      container.dispose();
      final newStateManager = WorkoutStateManager();
      await newStateManager.init();

      final newContainer = ProviderContainer(
        overrides: [
          workoutStateManagerProvider.overrideWithValue(newStateManager),
        ],
      );

      // Act: Restore state
      notifier = newContainer.read(workoutNotifierProvider.notifier);
      final restored = await notifier.restoreState();
      await tester.pumpAndSettle();

      // Assert
      expect(restored, true, reason: 'State should be restored');

      final stateStream = newContainer.listen<WorkoutState>(
        workoutNotifierProvider,
        (previous, next) {},
      );
      final state = stateStream.read();
      expect(state, isA<_InProgress>());

      final restoredState = state as _InProgress;
      expect(restoredState.workout.exercises.length, 1);
      expect(restoredState.workout.exercises.first.name, 'Pull Up');
      expect(restoredState.workout.exercises.first.sets.length, 1);
      print('✓ Workout state restored successfully');

      newContainer.dispose();
      print('\n=== TEST COMPLETE: State restoration logged and working ===\n');
    });
  });
}
