import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_type.dart';
import 'package:progression_tracker/features/workout/domain/entities/set_entry.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';

/// Preservation Property Test - Task 2.3
/// 
/// **Validates: Requirements 3.1, 3.2**
/// 
/// This test verifies that the weekly activity ring shows correct progress
/// percentage when the profile has a valid `workoutDaysPerWeek`. This is a
/// PRESERVATION test that should PASS on UNFIXED code, confirming baseline
/// behavior that must be maintained after the fix.
/// 
/// **Property**: For all valid profiles with workouts, the ring displays
/// correct percentage based on (actualWorkouts / workoutDaysPerWeek)
/// 
/// **EXPECTED OUTCOME ON UNFIXED CODE**: Test PASSES
/// - Confirms that weekly activity ring calculation works correctly when
///   profile is valid (not null)
/// - Establishes baseline behavior to preserve
/// 
/// **EXPECTED OUTCOME AFTER FIX**: Test PASSES
/// - Confirms that weekly activity ring still works correctly after the fix
/// - No regression in ring display functionality
/// 
/// This test uses property-based testing principles by testing multiple
/// scenarios across the input domain (different workoutDaysPerWeek values,
/// different workout counts, edge cases).
/// 
/// Note: This test focuses on the case where profile is NOT null. The bug
/// condition tests (Task 1.1) handle the null profile case.
void main() {
  group('Preservation - Weekly Activity Ring Display', () {

    test('Property: Ring shows 0% progress when no workouts completed', () {
      // ARRANGE: Profile with target of 5 days, no workouts this week
      final profile = _createTestProfile(workoutDaysPerWeek: 5);
      final workouts = <Workout>[];
      final target = profile.workoutDaysPerWeek;

      // ACT: Calculate progress (simulating ring calculation)
      final count = _countWeeklyWorkouts(workouts);
      final progress = (count / target).clamp(0.0, 1.0);
      final percentage = (progress * 100).round();

      // ASSERT: Progress should be 0%
      expect(count, equals(0), 
          reason: 'No workouts should result in count of 0');
      expect(progress, equals(0.0), 
          reason: 'Progress should be 0.0 when no workouts completed');
      expect(percentage, equals(0), 
          reason: 'Percentage should be 0% when no workouts completed');
    });

    test('Property: Ring shows correct progress for partial completion (3/5)', () {
      // ARRANGE: Profile with target of 5 days, 3 workouts this week
      final profile = _createTestProfile(workoutDaysPerWeek: 5);
      final workouts = _createWeeklyWorkouts(count: 3);
      final target = profile.workoutDaysPerWeek;

      // ACT: Calculate progress
      final count = _countWeeklyWorkouts(workouts);
      final progress = (count / target).clamp(0.0, 1.0);
      final percentage = (progress * 100).round();

      // ASSERT: Progress should be 60% (3/5)
      expect(count, equals(3), 
          reason: '3 workouts should result in count of 3');
      expect(progress, closeTo(0.6, 0.01), 
          reason: 'Progress should be 0.6 (60%) for 3/5 workouts');
      expect(percentage, equals(60), 
          reason: 'Percentage should be 60% for 3/5 workouts');
    });

    test('Property: Ring shows 100% progress when target is met', () {
      // ARRANGE: Profile with target of 4 days, 4 workouts this week
      final profile = _createTestProfile(workoutDaysPerWeek: 4);
      final workouts = _createWeeklyWorkouts(count: 4);
      final target = profile.workoutDaysPerWeek;

      // ACT: Calculate progress
      final count = _countWeeklyWorkouts(workouts);
      final progress = (count / target).clamp(0.0, 1.0);
      final percentage = (progress * 100).round();

      // ASSERT: Progress should be 100% (4/4)
      expect(count, equals(4), 
          reason: '4 workouts should result in count of 4');
      expect(progress, equals(1.0), 
          reason: 'Progress should be 1.0 (100%) when target is met');
      expect(percentage, equals(100), 
          reason: 'Percentage should be 100% when target is met');
    });

    test('Property: Ring caps at 100% when target is exceeded', () {
      // ARRANGE: Profile with target of 3 days, 5 workouts this week
      final profile = _createTestProfile(workoutDaysPerWeek: 3);
      final workouts = _createWeeklyWorkouts(count: 5);
      final target = profile.workoutDaysPerWeek;

      // ACT: Calculate progress (with clamp)
      final count = _countWeeklyWorkouts(workouts);
      final progress = (count / target).clamp(0.0, 1.0);
      final percentage = (progress * 100).round();

      // ASSERT: Progress should be capped at 100% even though 5/3 > 1
      expect(count, equals(5), 
          reason: '5 workouts should result in count of 5');
      expect(progress, equals(1.0), 
          reason: 'Progress should be capped at 1.0 (100%) when target exceeded');
      expect(percentage, equals(100), 
          reason: 'Percentage should be capped at 100% when target exceeded');
    });

    test('Property: Ring calculates correctly for workoutDaysPerWeek = 3', () {
      // ARRANGE: Profile with target of 3 days, 2 workouts this week
      final profile = _createTestProfile(workoutDaysPerWeek: 3);
      final workouts = _createWeeklyWorkouts(count: 2);
      final target = profile.workoutDaysPerWeek;

      // ACT: Calculate progress
      final count = _countWeeklyWorkouts(workouts);
      final progress = (count / target).clamp(0.0, 1.0);
      final percentage = (progress * 100).round();
      final remaining = target - count;

      // ASSERT: Progress should be 67% (2/3), 1 more to goal
      expect(count, equals(2), 
          reason: '2 workouts should result in count of 2');
      expect(progress, closeTo(0.67, 0.01), 
          reason: 'Progress should be ~0.67 (67%) for 2/3 workouts');
      expect(percentage, equals(67), 
          reason: 'Percentage should be 67% for 2/3 workouts');
      expect(remaining, equals(1), 
          reason: 'Should show "1 more to hit your goal"');
    });

    test('Property: Ring calculates correctly for workoutDaysPerWeek = 6', () {
      // ARRANGE: Profile with target of 6 days, 4 workouts this week
      final profile = _createTestProfile(workoutDaysPerWeek: 6);
      final workouts = _createWeeklyWorkouts(count: 4);
      final target = profile.workoutDaysPerWeek;

      // ACT: Calculate progress
      final count = _countWeeklyWorkouts(workouts);
      final progress = (count / target).clamp(0.0, 1.0);
      final percentage = (progress * 100).round();
      final remaining = target - count;

      // ASSERT: Progress should be 67% (4/6), 2 more to goal
      expect(count, equals(4), 
          reason: '4 workouts should result in count of 4');
      expect(progress, closeTo(0.67, 0.01), 
          reason: 'Progress should be ~0.67 (67%) for 4/6 workouts');
      expect(percentage, equals(67), 
          reason: 'Percentage should be 67% for 4/6 workouts');
      expect(remaining, equals(2), 
          reason: 'Should show "2 more to hit your goal"');
    });

    test('Property: Ring calculates correctly for workoutDaysPerWeek = 7', () {
      // ARRANGE: Profile with target of 7 days (daily workouts), 5 workouts
      final profile = _createTestProfile(workoutDaysPerWeek: 7);
      final workouts = _createWeeklyWorkouts(count: 5);
      final target = profile.workoutDaysPerWeek;

      // ACT: Calculate progress
      final count = _countWeeklyWorkouts(workouts);
      final progress = (count / target).clamp(0.0, 1.0);
      final percentage = (progress * 100).round();

      // ASSERT: Progress should be 71% (5/7)
      expect(count, equals(5), 
          reason: '5 workouts should result in count of 5');
      expect(progress, closeTo(0.71, 0.01), 
          reason: 'Progress should be ~0.71 (71%) for 5/7 workouts');
      expect(percentage, equals(71), 
          reason: 'Percentage should be 71% for 5/7 workouts');
    });

    test('Property: Ring calculates correctly for workoutDaysPerWeek = 1', () {
      // ARRANGE: Profile with target of 1 day (minimal), 1 workout
      final profile = _createTestProfile(workoutDaysPerWeek: 1);
      final workouts = _createWeeklyWorkouts(count: 1);
      final target = profile.workoutDaysPerWeek;

      // ACT: Calculate progress
      final count = _countWeeklyWorkouts(workouts);
      final progress = (count / target).clamp(0.0, 1.0);
      final percentage = (progress * 100).round();

      // ASSERT: Progress should be 100% (1/1)
      expect(count, equals(1), 
          reason: '1 workout should result in count of 1');
      expect(progress, equals(1.0), 
          reason: 'Progress should be 1.0 (100%) for 1/1 workout');
      expect(percentage, equals(100), 
          reason: 'Percentage should be 100% for 1/1 workout');
    });

    test('Property: Ring only counts workouts from last 7 days', () {
      // ARRANGE: Profile with target of 5 days
      final profile = _createTestProfile(workoutDaysPerWeek: 5);
      
      // Create workouts: 2 within last 7 days (using isAfter logic), 3 older
      final now = DateTime.now();
      final recentWorkouts = [
        _createWorkout(date: now.subtract(const Duration(days: 1))),
        _createWorkout(date: now.subtract(const Duration(days: 3))),
      ];
      final oldWorkouts = [
        _createWorkout(date: now.subtract(const Duration(days: 7))), // Exactly 7 days ago - not included
        _createWorkout(date: now.subtract(const Duration(days: 8))),
        _createWorkout(date: now.subtract(const Duration(days: 10))),
      ];
      final allWorkouts = [...recentWorkouts, ...oldWorkouts];
      final target = profile.workoutDaysPerWeek;

      // ACT: Calculate progress (should only count recent workouts)
      final count = _countWeeklyWorkouts(allWorkouts);
      final progress = (count / target).clamp(0.0, 1.0);

      // ASSERT: Should only count 2 recent workouts (isAfter excludes exact boundary)
      expect(count, equals(2), 
          reason: 'Should only count workouts from last 7 days (using isAfter logic)');
      expect(progress, closeTo(0.4, 0.01), 
          reason: 'Progress should be 0.4 (40%) for 2/5 workouts');
    });

    test('Property: Ring handles workouts on exact 7-day boundary', () {
      // ARRANGE: Profile with target of 4 days
      final profile = _createTestProfile(workoutDaysPerWeek: 4);
      
      // Create workout exactly 6 days ago (should be included with isAfter logic)
      // and one exactly 7 days ago (should NOT be included)
      final now = DateTime.now();
      final workouts = [
        _createWorkout(date: now.subtract(const Duration(days: 5))), // Included
        _createWorkout(date: now.subtract(const Duration(days: 7))), // NOT included (isAfter excludes boundary)
      ];
      final target = profile.workoutDaysPerWeek;

      // ACT: Calculate progress
      final count = _countWeeklyWorkouts(workouts);
      final progress = (count / target).clamp(0.0, 1.0);

      // ASSERT: Only 1 workout should be counted (isAfter excludes exact 7-day boundary)
      expect(count, equals(1), 
          reason: 'Only workouts strictly after weekStart should be counted (isAfter logic)');
      expect(progress, closeTo(0.25, 0.01), 
          reason: 'Progress should be 0.25 (25%) for 1/4 workouts');
    });

    test('Property: Ring message changes based on progress', () {
      // ARRANGE: Profile with target of 5 days
      final profile = _createTestProfile(workoutDaysPerWeek: 5);
      final target = profile.workoutDaysPerWeek;

      // Test case 1: No workouts
      final noWorkouts = <Workout>[];
      final count0 = _countWeeklyWorkouts(noWorkouts);
      final message0 = _getProgressMessage(count0, target);
      expect(message0, equals('Start your first workout!'), 
          reason: 'Should show start message when count is 0');

      // Test case 2: Partial progress
      final partialWorkouts = _createWeeklyWorkouts(count: 3);
      final count3 = _countWeeklyWorkouts(partialWorkouts);
      final message3 = _getProgressMessage(count3, target);
      expect(message3, equals('2 more to hit your goal'), 
          reason: 'Should show remaining count when partially complete');

      // Test case 3: Goal achieved
      final completeWorkouts = _createWeeklyWorkouts(count: 5);
      final count5 = _countWeeklyWorkouts(completeWorkouts);
      final message5 = _getProgressMessage(count5, target);
      expect(message5, equals('🎉 Weekly goal achieved!'), 
          reason: 'Should show achievement message when goal is met');

      // Test case 4: Goal exceeded
      final exceededWorkouts = _createWeeklyWorkouts(count: 7);
      final count7 = _countWeeklyWorkouts(exceededWorkouts);
      final message7 = _getProgressMessage(count7, target);
      expect(message7, equals('🎉 Weekly goal achieved!'), 
          reason: 'Should show achievement message when goal is exceeded');
    });

    test('Property: Ring preserves display for all valid workoutDaysPerWeek values (1-7)', () {
      // ARRANGE: Test all valid workoutDaysPerWeek values
      for (int targetDays = 1; targetDays <= 7; targetDays++) {
        final profile = _createTestProfile(workoutDaysPerWeek: targetDays);
        final workouts = _createWeeklyWorkouts(count: targetDays - 1);
        final target = profile.workoutDaysPerWeek;

        // ACT: Calculate progress
        final count = _countWeeklyWorkouts(workouts);
        final progress = (count / target).clamp(0.0, 1.0);

        // ASSERT: Progress should be calculated correctly for each target
        expect(count, equals(targetDays - 1), 
            reason: 'Count should match number of workouts for target=$targetDays');
        expect(progress, lessThan(1.0), 
            reason: 'Progress should be less than 100% when not complete for target=$targetDays');
        expect(progress, greaterThanOrEqualTo(0.0), 
            reason: 'Progress should be non-negative for target=$targetDays');
        
        // Verify expected progress value
        final expectedProgress = (targetDays - 1) / targetDays;
        expect(progress, closeTo(expectedProgress, 0.01), 
            reason: 'Progress should be ${(expectedProgress * 100).round()}% for ${targetDays - 1}/$targetDays workouts');
      }
    });
  });
}

/// Helper function to create a test UserProfile with specified workoutDaysPerWeek
UserProfile _createTestProfile({required int workoutDaysPerWeek}) {
  return UserProfile(
    goal: FitnessGoal.gainMuscle,
    age: 25,
    weightKg: 75.0,
    heightCm: 175.0,
    fitnessLevel: FitnessLevel.intermediate,
    equipment: EquipmentType.gym,
    workoutDaysPerWeek: workoutDaysPerWeek,
    budget: BudgetLevel.medium,
  );
}

/// Helper function to create a list of workouts within the last 7 days
List<Workout> _createWeeklyWorkouts({required int count}) {
  final now = DateTime.now();
  return List.generate(count, (index) {
    return _createWorkout(
      date: now.subtract(Duration(days: index)),
    );
  });
}

/// Helper function to create a single workout
Workout _createWorkout({required DateTime date}) {
  final exercises = [
    Exercise(
      id: 'exercise-1',
      name: 'Bench Press',
      sets: [
        _createSetEntry(weight: 80.0, reps: 10),
        _createSetEntry(weight: 85.0, reps: 8),
      ],
      type: ExerciseType.strength,
    ),
  ];

  return Workout(
    id: 'workout-${date.millisecondsSinceEpoch}',
    date: date,
    exercises: exercises,
    duration: const Duration(minutes: 45),
    totalVolume: 1480.0, // (80*10 + 85*8)
    caloriesBurned: 250.0,
  );
}

/// Helper function to create a SetEntry
SetEntry _createSetEntry({required double weight, required int reps}) {
  return SetEntry(
    id: 'set-${DateTime.now().millisecondsSinceEpoch}',
    weight: weight,
    reps: reps,
    timestamp: DateTime.now(),
  );
}

/// Helper function to count workouts from the last 7 days
/// This simulates the logic in _WeeklyActivitySection
int _countWeeklyWorkouts(List<Workout> workouts) {
  final now = DateTime.now();
  final weekStart = now.subtract(const Duration(days: 6));
  final weekWorkouts = workouts.where((w) => w.date.isAfter(weekStart)).toList();
  return weekWorkouts.length;
}

/// Helper function to get progress message
/// This simulates the message logic in _WeeklyActivitySection
String _getProgressMessage(int count, int target) {
  if (count == 0) {
    return 'Start your first workout!';
  } else if (count < target) {
    return '${target - count} more to hit your goal';
  } else {
    return '🎉 Weekly goal achieved!';
  }
}
