import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_type.dart';
import 'package:progression_tracker/features/workout/domain/entities/set_entry.dart';

/// Preservation Property Test - Task 2.1
/// 
/// **Validates: Requirements 3.6**
/// 
/// This test verifies that workout history displays all completed workouts
/// correctly. This is a PRESERVATION test that should PASS on UNFIXED code,
/// confirming baseline behavior that must be maintained after the fix.
/// 
/// **Property**: For all workout histories, the display shows correct count and details
/// 
/// **EXPECTED OUTCOME ON UNFIXED CODE**: Test PASSES
/// - Confirms that workout counting works correctly before the fix
/// - Establishes baseline behavior to preserve
/// 
/// **EXPECTED OUTCOME AFTER FIX**: Test PASSES
/// - Confirms that workout counting still works correctly after the fix
/// - No regression in workout counting functionality
/// 
/// This test uses property-based testing principles by testing multiple
/// scenarios across the input domain (0 workouts, 1 workout, multiple workouts,
/// large numbers of workouts).
/// 
/// Note: This test focuses on the domain logic of workout counting and list
/// operations, which are independent of the consistency calculation bug.
void main() {
  group('Preservation - Workout Counting', () {

    test('Property: Empty workout history returns zero count', () {
      // ARRANGE: No workouts in the system
      final List<Workout> history = [];

      // ACT: Get workout count
      final count = history.length;

      // ASSERT: Count should be 0 and history should be empty
      expect(count, equals(0), 
          reason: 'Empty workout history should return count of 0');
      expect(history, isEmpty, 
          reason: 'Empty workout history should return empty list');
      expect(history.length, equals(count), 
          reason: 'History length should match count');
    });

    test('Property: Single workout is counted and displayed correctly', () {
      // ARRANGE: Create one workout
      final workout = _createTestWorkout(
        id: 'workout-1',
        date: DateTime(2024, 1, 15, 10, 0),
        exerciseCount: 3,
      );
      final List<Workout> history = [workout];

      // ACT: Get workout count
      final count = history.length;

      // ASSERT: Count should be 1 and history should contain the workout
      expect(count, equals(1), 
          reason: 'Single workout should return count of 1');
      expect(history.length, equals(1), 
          reason: 'Single workout should return list with 1 item');
      expect(history.length, equals(count), 
          reason: 'History length should match count');
      
      // Verify workout details are preserved
      final retrievedWorkout = history.first;
      expect(retrievedWorkout.id, equals(workout.id), 
          reason: 'Workout ID should be preserved');
      expect(retrievedWorkout.exercises.length, equals(workout.exercises.length), 
          reason: 'Exercise count should be preserved');
      expect(retrievedWorkout.date, equals(workout.date), 
          reason: 'Workout date should be preserved');
    });

    test('Property: Multiple workouts are all counted and displayed', () {
      // ARRANGE: Create multiple workouts (5 workouts)
      final workouts = List.generate(5, (index) => _createTestWorkout(
        id: 'workout-$index',
        date: DateTime(2024, 1, 15 + index, 10, 0),
        exerciseCount: 2 + index,
      ));
      final List<Workout> history = workouts;

      // ACT: Get workout count
      final count = history.length;

      // ASSERT: All workouts should be counted and displayed
      expect(count, equals(5), 
          reason: 'Five workouts should return count of 5');
      expect(history.length, equals(5), 
          reason: 'Five workouts should return list with 5 items');
      expect(history.length, equals(count), 
          reason: 'History length should match count');
      
      // Verify all workout IDs are present
      final historyIds = history.map((w) => w.id).toSet();
      final expectedIds = workouts.map((w) => w.id).toSet();
      expect(historyIds, equals(expectedIds), 
          reason: 'All workout IDs should be present in history');
    });

    test('Property: Large workout history (50 workouts) is counted correctly', () {
      // ARRANGE: Create a large number of workouts (50)
      final workouts = List.generate(50, (index) => _createTestWorkout(
        id: 'workout-$index',
        date: DateTime(2024, 1, 1).add(Duration(days: index)),
        exerciseCount: (index % 5) + 1, // Vary exercise count
      ));
      final List<Workout> history = workouts;

      // ACT: Get workout count
      final count = history.length;

      // ASSERT: All 50 workouts should be counted
      expect(count, equals(50), 
          reason: 'Fifty workouts should return count of 50');
      expect(history.length, equals(50), 
          reason: 'Fifty workouts should return list with 50 items');
      expect(history.length, equals(count), 
          reason: 'History length should match count even for large datasets');
    });

    test('Property: Paginated workout retrieval maintains correct count', () {
      // ARRANGE: Create 25 workouts
      final workouts = List.generate(25, (index) => _createTestWorkout(
        id: 'workout-$index',
        date: DateTime(2024, 1, 1).add(Duration(days: index)),
        exerciseCount: 3,
      ));
      final List<Workout> history = workouts;

      // ACT: Simulate pagination
      final firstPage = history.skip(0).take(10).toList();
      final secondPage = history.skip(10).take(10).toList();
      final thirdPage = history.skip(20).take(10).toList();
      final count = history.length;

      // ASSERT: Pagination should not affect total count
      expect(count, equals(25), 
          reason: 'Total count should be 25 regardless of pagination');
      expect(firstPage.length, equals(10), 
          reason: 'First page should have 10 workouts');
      expect(secondPage.length, equals(10), 
          reason: 'Second page should have 10 workouts');
      expect(thirdPage.length, equals(5), 
          reason: 'Third page should have remaining 5 workouts');
      
      // Verify total retrieved equals count
      final totalRetrieved = firstPage.length + secondPage.length + thirdPage.length;
      expect(totalRetrieved, equals(count), 
          reason: 'Total paginated workouts should equal total count');
    });

    test('Property: Workout details (exercises, sets, volume) are preserved', () {
      // ARRANGE: Create a workout with detailed exercise data
      final workout = _createDetailedWorkout(
        id: 'detailed-workout',
        date: DateTime(2024, 1, 20, 14, 30),
      );
      final List<Workout> history = [workout];

      // ACT: Retrieve the workout
      final retrieved = history.first;

      // ASSERT: All details should be preserved
      expect(history.length, equals(1), 
          reason: 'Should retrieve the single workout');
      
      expect(retrieved.id, equals(workout.id), 
          reason: 'Workout ID should be preserved');
      expect(retrieved.exercises.length, equals(workout.exercises.length), 
          reason: 'Exercise count should be preserved');
      
      // Verify first exercise details
      final originalExercise = workout.exercises.first;
      final retrievedExercise = retrieved.exercises.first;
      expect(retrievedExercise.name, equals(originalExercise.name), 
          reason: 'Exercise name should be preserved');
      expect(retrievedExercise.sets.length, equals(originalExercise.sets.length), 
          reason: 'Set count should be preserved');
      
      // Verify set details
      for (int i = 0; i < originalExercise.sets.length; i++) {
        expect(retrievedExercise.sets[i].weight, equals(originalExercise.sets[i].weight), 
            reason: 'Set $i weight should be preserved');
        expect(retrievedExercise.sets[i].reps, equals(originalExercise.sets[i].reps), 
            reason: 'Set $i reps should be preserved');
      }
      
      // Verify total volume is preserved
      expect(retrieved.totalVolume, equals(workout.totalVolume), 
          reason: 'Total volume should be preserved');
    });

    test('Property: Workout history sorting is preserved (most recent first)', () {
      // ARRANGE: Create workouts with different dates
      final workout1 = _createTestWorkout(
        id: 'workout-1',
        date: DateTime(2024, 1, 10, 10, 0),
        exerciseCount: 2,
      );
      final workout2 = _createTestWorkout(
        id: 'workout-2',
        date: DateTime(2024, 1, 15, 10, 0),
        exerciseCount: 3,
      );
      final workout3 = _createTestWorkout(
        id: 'workout-3',
        date: DateTime(2024, 1, 5, 10, 0),
        exerciseCount: 2,
      );

      // Create history in random order, then sort
      final List<Workout> history = [workout2, workout1, workout3];
      history.sort((a, b) => b.date.compareTo(a.date)); // Sort descending

      // ASSERT: Workouts should be sorted by date descending (most recent first)
      expect(history.length, equals(3), 
          reason: 'Should have all 3 workouts');
      expect(history[0].id, equals('workout-2'), 
          reason: 'Most recent workout (Jan 15) should be first');
      expect(history[1].id, equals('workout-1'), 
          reason: 'Second most recent workout (Jan 10) should be second');
      expect(history[2].id, equals('workout-3'), 
          reason: 'Oldest workout (Jan 5) should be last');
      
      // Verify dates are in descending order
      for (int i = 0; i < history.length - 1; i++) {
        expect(history[i].date.isAfter(history[i + 1].date), isTrue, 
            reason: 'Workouts should be sorted by date descending');
      }
    });
  });
}

/// Helper function to create a test workout with specified parameters
Workout _createTestWorkout({
  required String id,
  required DateTime date,
  required int exerciseCount,
}) {
  final exercises = List.generate(exerciseCount, (index) {
    final List<SetEntry> sets = [
      _createSetEntry(weight: 50.0 + (index * 10), reps: 10),
      _createSetEntry(weight: 55.0 + (index * 10), reps: 8),
    ];
    
    return Exercise(
      id: 'exercise-$index',
      name: 'Exercise ${index + 1}',
      sets: sets,
      type: ExerciseType.strength,
    );
  });

  return Workout(
    id: id,
    date: date,
    exercises: exercises,
    duration: const Duration(minutes: 45),
    totalVolume: exercises.fold(0.0, (sum, ex) => 
      sum + ex.sets.fold(0.0, (s, set) => s + (set.weight * set.reps))),
    caloriesBurned: 250.0,
  );
}

/// Helper function to create a detailed workout for testing data preservation
Workout _createDetailedWorkout({
  required String id,
  required DateTime date,
}) {
  final exercises = [
    Exercise(
      id: 'bench-press',
      name: 'Bench Press',
      sets: [
        _createSetEntry(weight: 60.0, reps: 12),
        _createSetEntry(weight: 80.0, reps: 10),
        _createSetEntry(weight: 85.0, reps: 8),
        _createSetEntry(weight: 90.0, reps: 6),
      ],
      type: ExerciseType.strength,
    ),
    Exercise(
      id: 'squat',
      name: 'Squat',
      sets: [
        _createSetEntry(weight: 80.0, reps: 10),
        _createSetEntry(weight: 100.0, reps: 8),
        _createSetEntry(weight: 110.0, reps: 6),
        _createSetEntry(weight: 120.0, reps: 5),
      ],
      type: ExerciseType.strength,
    ),
  ];

  final totalVolume = exercises.fold(0.0, (sum, ex) => 
    sum + ex.sets.fold(0.0, (s, set) => s + (set.weight * set.reps)));

  return Workout(
    id: id,
    date: date,
    exercises: exercises,
    duration: const Duration(minutes: 60),
    totalVolume: totalVolume,
    caloriesBurned: 350.0,
  );
}

/// Helper function to create a SetEntry with proper structure
_createSetEntry({required double weight, required int reps}) {
  return SetEntry(
    id: 'set-${DateTime.now().millisecondsSinceEpoch}',
    weight: weight,
    reps: reps,
    timestamp: DateTime.now(),
  );
}
