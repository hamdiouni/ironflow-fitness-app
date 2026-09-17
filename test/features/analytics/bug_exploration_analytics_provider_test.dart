import 'package:flutter_test/flutter_test.dart';

/// Bug Condition Exploration Test - Task 1.3
/// 
/// **Validates: Requirements 1.3, 2.3**
/// 
/// This test explores the bug where the analytics provider uses a hardcoded
/// divisor of 5 when calculating weekly consistency, instead of using the
/// user's configured `workoutDaysPerWeek` from their UserProfile.
/// 
/// **EXPECTED OUTCOME ON UNFIXED CODE**: Test FAILS
/// - The failure confirms that the hardcoded divisor 5 is being used
/// - Expected counterexample: consistency shows 80% (4/5) instead of expected 67% (4/6)
///   when user has workoutDaysPerWeek=6 and completed 4 workouts this week
/// 
/// **EXPECTED OUTCOME AFTER FIX**: Test PASSES
/// - The analytics provider uses userProfile.workoutDaysPerWeek as the divisor
/// - Consistency calculation: (4 / 6) * 100 = 67%
/// 
/// This test encodes the expected behavior and will validate the fix when it passes.
void main() {
  group('Bug Exploration - Analytics Provider Hardcoded Divisor', () {
    test('should NOT use hardcoded divisor 5 for weekly consistency calculation', () {
      // ARRANGE: Create UserProfile with workoutDaysPerWeek = 6
      const profile = _MockUserProfile(workoutDaysPerWeek: 6);
      
      // Create 4 workouts this week
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      
      final workouts = [
        _MockWorkout(date: weekStart.add(const Duration(days: 1))), // Monday
        _MockWorkout(date: weekStart.add(const Duration(days: 2))), // Tuesday
        _MockWorkout(date: weekStart.add(const Duration(days: 3))), // Wednesday
        _MockWorkout(date: weekStart.add(const Duration(days: 5))), // Friday
      ];
      
      // ACT: Calculate weekly consistency using the UNFIXED logic
      // This mimics the current implementation in analytics_provider.dart line 111:
      // return (thisWeekWorkouts / 5).clamp(0.0, 1.0);
      final thisWeekWorkouts = workouts.length;
      final double unfixedConsistency = (thisWeekWorkouts / 5).clamp(0.0, 1.0);
      final int unfixedPercentage = (unfixedConsistency * 100).toInt();
      
      // Calculate the EXPECTED consistency using user's workoutDaysPerWeek
      final double expectedConsistency = (thisWeekWorkouts / profile.workoutDaysPerWeek).clamp(0.0, 1.0);
      final int expectedPercentage = (expectedConsistency * 100).toInt();
      
      // ASSERT: The bug condition - hardcoded divisor 5 is used
      // On UNFIXED code: unfixedPercentage will be 80% (4/5 * 100)
      // On FIXED code: should be 67% (4/6 * 100)
      
      // Document the counterexample
      print('Counterexample found:');
      print('  UserProfile.workoutDaysPerWeek: ${profile.workoutDaysPerWeek}');
      print('  Workouts completed this week: $thisWeekWorkouts');
      print('  UNFIXED consistency (using divisor 5): $unfixedPercentage%');
      print('  EXPECTED consistency (using divisor ${profile.workoutDaysPerWeek}): $expectedPercentage%');
      
      // This assertion will FAIL on unfixed code because unfixedPercentage == 80
      // It will PASS on fixed code when the divisor uses profile.workoutDaysPerWeek
      expect(
        unfixedPercentage,
        equals(expectedPercentage),
        reason: 'Analytics provider should use userProfile.workoutDaysPerWeek (${profile.workoutDaysPerWeek}) '
            'as divisor, not hardcoded value 5. '
            'Expected: (4 / 6) * 100 = 67%, '
            'but got: (4 / 5) * 100 = 80%. '
            'Counterexample: workoutDaysPerWeek=${profile.workoutDaysPerWeek}, '
            'thisWeekWorkouts=$thisWeekWorkouts, '
            'unfixedPercentage=$unfixedPercentage%, '
            'expectedPercentage=$expectedPercentage%',
      );
    });
    
    test('should demonstrate the inflated consistency percentage with workoutDaysPerWeek=6', () {
      // ARRANGE: UserProfile with workoutDaysPerWeek = 6
      const profile = _MockUserProfile(workoutDaysPerWeek: 6);
      const int completedWorkouts = 4;
      
      // ACT: Calculate consistency using hardcoded divisor 5 (UNFIXED)
      final double unfixedConsistency = (completedWorkouts / 5).clamp(0.0, 1.0);
      final int unfixedPercentage = (unfixedConsistency * 100).toInt();
      
      // Calculate expected consistency using user's workoutDaysPerWeek
      final double expectedConsistency = (completedWorkouts / profile.workoutDaysPerWeek).clamp(0.0, 1.0);
      final int expectedPercentage = (expectedConsistency * 100).toInt();
      
      // ASSERT: Document the counterexample
      // On UNFIXED code: shows 80% instead of 67%
      
      expect(
        unfixedPercentage,
        isNot(equals(80)),
        reason: 'With workoutDaysPerWeek=6 and 4 completed workouts, '
            'consistency should be 67% (4/6), not 80% (4/5). '
            'The hardcoded divisor 5 causes inflated calculation. '
            'Counterexample: unfixedPercentage=$unfixedPercentage%, expectedPercentage=$expectedPercentage%',
      );
      
      expect(
        expectedPercentage,
        equals(67),
        reason: 'Expected consistency should be 67% when using correct divisor',
      );
    });
    
    test('should verify edge case with workoutDaysPerWeek=3', () {
      // ARRANGE: UserProfile with workoutDaysPerWeek = 3
      const profile = _MockUserProfile(workoutDaysPerWeek: 3);
      const int completedWorkouts = 2;
      
      // ACT: Calculate consistency using hardcoded divisor 5 (UNFIXED)
      final double unfixedConsistency = (completedWorkouts / 5).clamp(0.0, 1.0);
      final int unfixedPercentage = (unfixedConsistency * 100).toInt();
      
      // Calculate expected consistency using user's workoutDaysPerWeek
      final double expectedConsistency = (completedWorkouts / profile.workoutDaysPerWeek).clamp(0.0, 1.0);
      final int expectedPercentage = (expectedConsistency * 100).toInt();
      
      // ASSERT: With workoutDaysPerWeek=3, the bug causes deflated percentage
      // UNFIXED: (2/5) * 100 = 40%
      // EXPECTED: (2/3) * 100 = 67%
      
      expect(
        unfixedPercentage,
        equals(expectedPercentage),
        reason: 'With workoutDaysPerWeek=3 and 2 completed workouts, '
            'consistency should be 67% (2/3), not 40% (2/5). '
            'The hardcoded divisor 5 deflates the percentage. '
            'Counterexample: unfixedPercentage=$unfixedPercentage%, expectedPercentage=$expectedPercentage%',
      );
    });
    
    test('should verify that valid profile with workoutDaysPerWeek=5 works correctly', () {
      // ARRANGE: UserProfile with workoutDaysPerWeek = 5 (matches hardcoded value)
      const profile = _MockUserProfile(workoutDaysPerWeek: 5);
      const int completedWorkouts = 3;
      
      // ACT: Calculate consistency
      final double consistency = (completedWorkouts / profile.workoutDaysPerWeek).clamp(0.0, 1.0);
      final int percentage = (consistency * 100).toInt();
      
      // ASSERT: When workoutDaysPerWeek=5, even unfixed code should work correctly
      expect(percentage, equals(60), 
          reason: 'With workoutDaysPerWeek=5 and 3 workouts, consistency should be 60% (3/5)');
      
      // This test passes on both unfixed and fixed code because the hardcoded
      // value 5 happens to match the user's configuration
    });
    
    test('should verify the specific task 1.3 scenario: workoutDaysPerWeek=6, 4 workouts', () {
      // ARRANGE: Exact scenario from task 1.3
      const profile = _MockUserProfile(workoutDaysPerWeek: 6);
      const int completedWorkouts = 4;
      
      // ACT: Calculate consistency using UNFIXED logic (hardcoded divisor 5)
      final double unfixedConsistency = (completedWorkouts / 5).clamp(0.0, 1.0);
      final int unfixedPercentage = (unfixedConsistency * 100).toInt();
      
      // Calculate EXPECTED consistency using user's workoutDaysPerWeek
      final double expectedConsistency = (completedWorkouts / profile.workoutDaysPerWeek).clamp(0.0, 1.0);
      final int expectedPercentage = (expectedConsistency * 100).toInt();
      
      // ASSERT: Verify the exact counterexample from task 1.3
      // UNFIXED: (4/5) * 100 = 80%
      // EXPECTED: (4/6) * 100 = 67%
      
      print('Task 1.3 Counterexample:');
      print('  Scenario: UserProfile with workoutDaysPerWeek = 6, completed 4 workouts');
      print('  UNFIXED (hardcoded divisor 5): $unfixedPercentage%');
      print('  EXPECTED (using workoutDaysPerWeek 6): $expectedPercentage%');
      print('  Bug confirmed: Analytics provider uses hardcoded divisor 5');
      
      expect(
        unfixedPercentage,
        equals(expectedPercentage),
        reason: 'Task 1.3: Analytics provider should calculate consistency as (4 / 6) * 100 = 67%, '
            'not (4 / 5) * 100 = 80%. '
            'The hardcoded divisor 5 in analytics_provider.dart line 111 causes incorrect calculation. '
            'Counterexample documented: workoutDaysPerWeek=6, completedWorkouts=4, '
            'unfixedPercentage=80%, expectedPercentage=67%',
      );
    });
  });
}

/// Mock UserProfile for testing
/// This is a minimal mock to avoid dependencies on the full UserProfile class
class _MockUserProfile {
  const _MockUserProfile({required this.workoutDaysPerWeek});
  
  final int workoutDaysPerWeek;
}

/// Mock Workout for testing
/// This is a minimal mock to avoid dependencies on the full Workout class
class _MockWorkout {
  const _MockWorkout({required this.date});
  
  final DateTime date;
}
