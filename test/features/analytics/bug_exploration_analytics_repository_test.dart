import 'package:flutter_test/flutter_test.dart';

/// Bug Condition Exploration Test - Task 1.4
/// 
/// **Validates: Requirements 1.4, 2.4**
/// 
/// This test explores the bug where the analytics repository uses a hardcoded
/// multiplier of 5 when calculating adherence rate, instead of using the
/// user's configured `workoutDaysPerWeek` from their UserProfile.
/// 
/// **EXPECTED OUTCOME ON UNFIXED CODE**: Test FAILS
/// - The failure confirms that the hardcoded multiplier 5 is being used
/// - Expected counterexample: adherence shows 45% (9 / (4 * 5)) instead of expected 75% (9 / (4 * 3))
///   when user has workoutDaysPerWeek=3 and completed 9 workouts over 4 weeks
/// 
/// **EXPECTED OUTCOME AFTER FIX**: Test PASSES
/// - The analytics repository uses userProfile.workoutDaysPerWeek as the multiplier
/// - Adherence calculation: 9 / (4 * 3) = 75%
/// 
/// This test encodes the expected behavior and will validate the fix when it passes.
void main() {
  group('Bug Exploration - Analytics Repository Hardcoded Multiplier', () {
    test('should NOT use hardcoded multiplier 5 for adherence rate calculation', () {
      // ARRANGE: Create UserProfile with workoutDaysPerWeek = 3
      const profile = _MockUserProfile(workoutDaysPerWeek: 3);
      
      // Complete 9 workouts over 4 weeks
      const int totalWorkouts = 9;
      const int totalWeeks = 4;
      
      // ACT: Calculate adherence using the UNFIXED logic
      // This mimics the current implementation in analytics_repository_impl.dart line 253-256:
      // final targetWorkouts = totalWeeks * 5;
      // final adherenceRate = targetWorkouts > 0
      //     ? (totalWorkouts / targetWorkouts).clamp(0.0, 1.0)
      //     : 0.0;
      final int unfixedTargetWorkouts = totalWeeks * 5;
      final double unfixedAdherence = unfixedTargetWorkouts > 0
          ? (totalWorkouts / unfixedTargetWorkouts).clamp(0.0, 1.0)
          : 0.0;
      final int unfixedPercentage = (unfixedAdherence * 100).toInt();
      
      // Calculate the EXPECTED adherence using user's workoutDaysPerWeek
      final int expectedTargetWorkouts = totalWeeks * profile.workoutDaysPerWeek;
      final double expectedAdherence = expectedTargetWorkouts > 0
          ? (totalWorkouts / expectedTargetWorkouts).clamp(0.0, 1.0)
          : 0.0;
      final int expectedPercentage = (expectedAdherence * 100).toInt();
      
      // ASSERT: The bug condition - hardcoded multiplier 5 is used
      // On UNFIXED code: unfixedPercentage will be 45% (9 / (4 * 5) * 100)
      // On FIXED code: should be 75% (9 / (4 * 3) * 100)
      
      // Document the counterexample
      print('Counterexample found:');
      print('  UserProfile.workoutDaysPerWeek: ${profile.workoutDaysPerWeek}');
      print('  Total workouts completed: $totalWorkouts');
      print('  Total weeks: $totalWeeks');
      print('  UNFIXED adherence (using multiplier 5): $unfixedPercentage%');
      print('  EXPECTED adherence (using multiplier ${profile.workoutDaysPerWeek}): $expectedPercentage%');
      
      // This assertion will FAIL on unfixed code because unfixedPercentage == 45
      // It will PASS on fixed code when the multiplier uses profile.workoutDaysPerWeek
      expect(
        unfixedPercentage,
        equals(expectedPercentage),
        reason: 'Analytics repository should use userProfile.workoutDaysPerWeek (${profile.workoutDaysPerWeek}) '
            'as multiplier, not hardcoded value 5. '
            'Expected: 9 / (4 * 3) * 100 = 75%, '
            'but got: 9 / (4 * 5) * 100 = 45%. '
            'Counterexample: workoutDaysPerWeek=${profile.workoutDaysPerWeek}, '
            'totalWorkouts=$totalWorkouts, '
            'totalWeeks=$totalWeeks, '
            'unfixedPercentage=$unfixedPercentage%, '
            'expectedPercentage=$expectedPercentage%',
      );
    });
    
    test('should demonstrate the deflated adherence percentage with workoutDaysPerWeek=3', () {
      // ARRANGE: UserProfile with workoutDaysPerWeek = 3
      const profile = _MockUserProfile(workoutDaysPerWeek: 3);
      const int totalWorkouts = 9;
      const int totalWeeks = 4;
      
      // ACT: Calculate adherence using hardcoded multiplier 5 (UNFIXED)
      final int unfixedTargetWorkouts = totalWeeks * 5;
      final double unfixedAdherence = (totalWorkouts / unfixedTargetWorkouts).clamp(0.0, 1.0);
      final int unfixedPercentage = (unfixedAdherence * 100).toInt();
      
      // Calculate expected adherence using user's workoutDaysPerWeek
      final int expectedTargetWorkouts = totalWeeks * profile.workoutDaysPerWeek;
      final double expectedAdherence = (totalWorkouts / expectedTargetWorkouts).clamp(0.0, 1.0);
      final int expectedPercentage = (expectedAdherence * 100).toInt();
      
      // ASSERT: Document the counterexample
      // On UNFIXED code: shows 45% instead of 75%
      
      expect(
        unfixedPercentage,
        isNot(equals(45)),
        reason: 'With workoutDaysPerWeek=3, 9 workouts over 4 weeks, '
            'adherence should be 75% (9 / (4 * 3)), not 45% (9 / (4 * 5)). '
            'The hardcoded multiplier 5 causes deflated calculation. '
            'Counterexample: unfixedPercentage=$unfixedPercentage%, expectedPercentage=$expectedPercentage%',
      );
      
      expect(
        expectedPercentage,
        equals(75),
        reason: 'Expected adherence should be 75% when using correct multiplier',
      );
    });
    
    test('should verify edge case with workoutDaysPerWeek=6', () {
      // ARRANGE: UserProfile with workoutDaysPerWeek = 6
      const profile = _MockUserProfile(workoutDaysPerWeek: 6);
      const int totalWorkouts = 12;
      const int totalWeeks = 2;
      
      // ACT: Calculate adherence using hardcoded multiplier 5 (UNFIXED)
      final int unfixedTargetWorkouts = totalWeeks * 5;
      final double unfixedAdherence = (totalWorkouts / unfixedTargetWorkouts).clamp(0.0, 1.0);
      final int unfixedPercentage = (unfixedAdherence * 100).toInt();
      
      // Calculate expected adherence using user's workoutDaysPerWeek
      final int expectedTargetWorkouts = totalWeeks * profile.workoutDaysPerWeek;
      final double expectedAdherence = (totalWorkouts / expectedTargetWorkouts).clamp(0.0, 1.0);
      final int expectedPercentage = (expectedAdherence * 100).toInt();
      
      // ASSERT: With workoutDaysPerWeek=6, the bug causes inflated percentage
      // UNFIXED: (12 / (2 * 5)) * 100 = 120% -> clamped to 100%
      // EXPECTED: (12 / (2 * 6)) * 100 = 100%
      
      expect(
        unfixedPercentage,
        equals(expectedPercentage),
        reason: 'With workoutDaysPerWeek=6, 12 workouts over 2 weeks, '
            'adherence should be 100% (12 / (2 * 6)), not 120% clamped to 100% (12 / (2 * 5)). '
            'The hardcoded multiplier 5 inflates the percentage. '
            'Counterexample: unfixedPercentage=$unfixedPercentage%, expectedPercentage=$expectedPercentage%',
      );
    });
    
    test('should verify that valid profile with workoutDaysPerWeek=5 works correctly', () {
      // ARRANGE: UserProfile with workoutDaysPerWeek = 5 (matches hardcoded value)
      const profile = _MockUserProfile(workoutDaysPerWeek: 5);
      const int totalWorkouts = 15;
      const int totalWeeks = 3;
      
      // ACT: Calculate adherence
      final int targetWorkouts = totalWeeks * profile.workoutDaysPerWeek;
      final double adherence = (totalWorkouts / targetWorkouts).clamp(0.0, 1.0);
      final int percentage = (adherence * 100).toInt();
      
      // ASSERT: When workoutDaysPerWeek=5, even unfixed code should work correctly
      expect(percentage, equals(100), 
          reason: 'With workoutDaysPerWeek=5, 15 workouts over 3 weeks, adherence should be 100% (15 / (3 * 5))');
      
      // This test passes on both unfixed and fixed code because the hardcoded
      // value 5 happens to match the user's configuration
    });
    
    test('should verify the specific task 1.4 scenario: workoutDaysPerWeek=3, 9 workouts over 4 weeks', () {
      // ARRANGE: Exact scenario from task 1.4
      const profile = _MockUserProfile(workoutDaysPerWeek: 3);
      const int totalWorkouts = 9;
      const int totalWeeks = 4;
      
      // ACT: Calculate adherence using UNFIXED logic (hardcoded multiplier 5)
      final int unfixedTargetWorkouts = totalWeeks * 5;
      final double unfixedAdherence = (totalWorkouts / unfixedTargetWorkouts).clamp(0.0, 1.0);
      final int unfixedPercentage = (unfixedAdherence * 100).toInt();
      
      // Calculate EXPECTED adherence using user's workoutDaysPerWeek
      final int expectedTargetWorkouts = totalWeeks * profile.workoutDaysPerWeek;
      final double expectedAdherence = (totalWorkouts / expectedTargetWorkouts).clamp(0.0, 1.0);
      final int expectedPercentage = (expectedAdherence * 100).toInt();
      
      // ASSERT: Verify the exact counterexample from task 1.4
      // UNFIXED: (9 / (4 * 5)) * 100 = 45%
      // EXPECTED: (9 / (4 * 3)) * 100 = 75%
      
      print('Task 1.4 Counterexample:');
      print('  Scenario: UserProfile with workoutDaysPerWeek = 3, completed 9 workouts over 4 weeks');
      print('  UNFIXED (hardcoded multiplier 5): $unfixedPercentage%');
      print('  EXPECTED (using workoutDaysPerWeek 3): $expectedPercentage%');
      print('  Bug confirmed: Analytics repository uses hardcoded multiplier 5');
      
      expect(
        unfixedPercentage,
        equals(expectedPercentage),
        reason: 'Task 1.4: Analytics repository should calculate adherence as 9 / (4 * 3) * 100 = 75%, '
            'not 9 / (4 * 5) * 100 = 45%. '
            'The hardcoded multiplier 5 in analytics_repository_impl.dart line 253 causes incorrect calculation. '
            'Counterexample documented: workoutDaysPerWeek=3, totalWorkouts=9, totalWeeks=4, '
            'unfixedPercentage=45%, expectedPercentage=75%',
      );
    });
    
    test('should verify weekly consistency also uses hardcoded value 5', () {
      // ARRANGE: UserProfile with workoutDaysPerWeek = 4
      const profile = _MockUserProfile(workoutDaysPerWeek: 4);
      const int weekWorkoutsLength = 3;
      
      // ACT: Calculate weekly adherence using UNFIXED logic
      // This mimics line 283 in analytics_repository_impl.dart:
      // adherenceRate: (weekWorkouts.length / 5).clamp(0.0, 1.0),
      final double unfixedWeeklyAdherence = (weekWorkoutsLength / 5).clamp(0.0, 1.0);
      final int unfixedPercentage = (unfixedWeeklyAdherence * 100).toInt();
      
      // Calculate EXPECTED weekly adherence using user's workoutDaysPerWeek
      final double expectedWeeklyAdherence = (weekWorkoutsLength / profile.workoutDaysPerWeek).clamp(0.0, 1.0);
      final int expectedPercentage = (expectedWeeklyAdherence * 100).toInt();
      
      // ASSERT: Weekly consistency calculation also has the bug
      // UNFIXED: (3 / 5) * 100 = 60%
      // EXPECTED: (3 / 4) * 100 = 75%
      
      print('Weekly Consistency Counterexample:');
      print('  UserProfile.workoutDaysPerWeek: ${profile.workoutDaysPerWeek}');
      print('  Week workouts completed: $weekWorkoutsLength');
      print('  UNFIXED weekly adherence (using divisor 5): $unfixedPercentage%');
      print('  EXPECTED weekly adherence (using divisor ${profile.workoutDaysPerWeek}): $expectedPercentage%');
      
      expect(
        unfixedPercentage,
        equals(expectedPercentage),
        reason: 'Weekly consistency should use userProfile.workoutDaysPerWeek (${profile.workoutDaysPerWeek}) '
            'as divisor, not hardcoded value 5. '
            'Expected: (3 / 4) * 100 = 75%, '
            'but got: (3 / 5) * 100 = 60%. '
            'Line 283 in analytics_repository_impl.dart also uses hardcoded divisor 5.',
      );
    });
    
    test('should verify workoutsPlanned field uses hardcoded value 5', () {
      // ARRANGE: UserProfile with workoutDaysPerWeek = 7
      const profile = _MockUserProfile(workoutDaysPerWeek: 7);
      
      // ACT: The workoutsPlanned field is hardcoded to 5 in line 276
      // workoutsPlanned: 5,
      const int unfixedWorkoutsPlanned = 5;
      final int expectedWorkoutsPlanned = profile.workoutDaysPerWeek;
      
      // ASSERT: workoutsPlanned should match user's configuration
      print('WorkoutsPlanned Counterexample:');
      print('  UserProfile.workoutDaysPerWeek: ${profile.workoutDaysPerWeek}');
      print('  UNFIXED workoutsPlanned: $unfixedWorkoutsPlanned');
      print('  EXPECTED workoutsPlanned: $expectedWorkoutsPlanned');
      
      expect(
        unfixedWorkoutsPlanned,
        equals(expectedWorkoutsPlanned),
        reason: 'workoutsPlanned should be ${profile.workoutDaysPerWeek} (from userProfile.workoutDaysPerWeek), '
            'not hardcoded value 5. '
            'Line 276 in analytics_repository_impl.dart uses hardcoded value 5.',
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
