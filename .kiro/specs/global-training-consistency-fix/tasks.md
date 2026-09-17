# Implementation Plan

- [ ] 1. Write bug condition exploration tests
  - **Property 1: Bug Condition** - Hardcoded Training Values Override User Configuration
  - **CRITICAL**: These tests MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: These tests encode the expected behavior - they will validate the fix when they pass after implementation
  - **GOAL**: Surface counterexamples that demonstrate hardcoded values (4 or 5) are being used instead of user's `workoutDaysPerWeek`
  - **Scoped PBT Approach**: For deterministic bugs, scope the property to concrete failing cases to ensure reproducibility
  
  - [x] 1.1 Test home screen null profile fallback
    - Create scenario where UserProfile is null
    - Verify home screen uses hardcoded fallback value 4 instead of handling null appropriately
    - Expected counterexample: "2 more to hit your goal" when should show loading state or profile prompt
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test FAILS (confirms hardcoded fallback exists)
    - Document counterexample found
    - _Requirements: 1.1, 2.1_
  
  - [x] 1.2 Test analytics screen hardcoded divisor
    - Create UserProfile with `workoutDaysPerWeek = 3`
    - Complete 2 workouts this week
    - Verify analytics screen calculates consistency as `(2 / 5) * 100 = 40%` instead of `(2 / 3) * 100 = 67%`
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test FAILS (confirms hardcoded divisor 5 is used)
    - Document counterexample: consistency shows 40% instead of expected 67%
    - _Requirements: 1.2, 2.2_
  
  - [x] 1.3 Test analytics provider hardcoded divisor
    - Create UserProfile with `workoutDaysPerWeek = 6`
    - Complete 4 workouts this week
    - Verify analytics provider calculates consistency as `(4 / 5) * 100 = 80%` instead of `(4 / 6) * 100 = 67%`
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test FAILS (confirms hardcoded divisor 5 is used)
    - Document counterexample: consistency shows 80% instead of expected 67%
    - _Requirements: 1.3, 2.3_
  
  - [x] 1.4 Test analytics repository hardcoded multiplier
    - Create UserProfile with `workoutDaysPerWeek = 3`
    - Complete 9 workouts over 4 weeks
    - Verify analytics repository calculates adherence as `9 / (4 * 5) = 45%` instead of `9 / (4 * 3) = 75%`
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test FAILS (confirms hardcoded multiplier 5 is used)
    - Document counterexample: adherence shows 45% instead of expected 75%
    - _Requirements: 1.4, 2.4_
  
  - [x] 1.5 Test edge case with workoutDaysPerWeek = 6
    - Create UserProfile with `workoutDaysPerWeek = 6`
    - Complete 5 workouts this week
    - Verify system shows targets based on 4 or 5 instead of 6
    - Run test on UNFIXED code
    - **EXPECTED OUTCOME**: Test FAILS (confirms hardcoded values override user config)
    - Document counterexample found
    - _Requirements: 1.6, 2.6_

- [ ] 2. Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Non-Consistency Functionality Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-consistency features
  - Write property-based tests capturing observed behavior patterns
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (confirms baseline behavior to preserve)
  
  - [x] 2.1 Observe and test workout counting preservation
    - Observe: Workout history displays all completed workouts correctly on unfixed code
    - Write property-based test: for all workout histories, display shows correct count and details
    - Verify test passes on UNFIXED code
    - _Requirements: 3.6_
  
  - [x] 2.2 Observe and test profile saving preservation
    - Observe: During onboarding, `workoutDaysPerWeek` is saved correctly to UserProfile on unfixed code
    - Write property-based test: for all valid `workoutDaysPerWeek` values (1-7), profile saves and retrieves correctly
    - Verify test passes on UNFIXED code
    - _Requirements: 3.4, 3.5_
  
  - [x] 2.3 Observe and test weekly activity ring display preservation
    - Observe: Weekly activity ring shows correct progress percentage when profile has valid `workoutDaysPerWeek` on unfixed code
    - Write property-based test: for all valid profiles with workouts, ring displays correct percentage
    - Verify test passes on UNFIXED code
    - _Requirements: 3.1, 3.2_
  
  - [x] 2.4 Observe and test analytics non-consistency calculations preservation
    - Observe: Strength progression and weight tracking calculations work correctly on unfixed code
    - Write property-based test: for all workout data, strength and weight metrics calculate correctly
    - Verify test passes on UNFIXED code
    - _Requirements: 3.8, 3.9_
  
  - [x] 2.5 Observe and test empty state preservation
    - Observe: Users with no workout history see appropriate empty states on unfixed code
    - Write property-based test: for all users with zero workouts, empty states display correctly
    - Verify test passes on UNFIXED code
    - _Requirements: 3.10_
  
  - [x] 2.6 Observe and test refresh functionality preservation
    - Observe: Home screen refresh reloads data from UserProfile and workout history correctly on unfixed code
    - Write property-based test: for all refresh actions, data reloads correctly
    - Verify test passes on UNFIXED code
    - _Requirements: 3.7_

- [ ] 3. Fix for global training consistency bug

  - [x] 3.1 Update analytics screen to use user's workoutDaysPerWeek
    - Modify `_calculateWeeklyConsistency` in `lib/features/analytics/presentation/screens/analytics_screen.dart`
    - Add `UserProfile?` parameter to the function
    - Replace hardcoded divisor `(thisWeekWorkouts / 5)` with `(thisWeekWorkouts / (profile?.workoutDaysPerWeek ?? 1))`
    - Update call site to pass profile from `profileAsync`
    - _Bug_Condition: isBugCondition(calculation) where calculation.location == "analytics_screen" AND calculation.divisor == 5_
    - _Expected_Behavior: result.divisor == userProfile.workoutDaysPerWeek AND result.percentage == (actualWorkouts / userProfile.workoutDaysPerWeek) * 100_
    - _Preservation: Workout counting, profile saving, UI display, and all non-consistency calculations remain unchanged_
    - _Requirements: 1.2, 2.2, 2.5, 3.1, 3.2, 3.3_

  - [x] 3.2 Update analytics provider to use user's workoutDaysPerWeek
    - Modify `_calculateWeeklyConsistency` in `lib/features/analytics/presentation/providers/analytics_provider.dart`
    - Add `UserProfile?` parameter to the function
    - Replace hardcoded divisor `(thisWeekWorkouts / 5)` with `(thisWeekWorkouts / (profile?.workoutDaysPerWeek ?? 1))`
    - Modify `analyticsStatsProvider` to watch `userProfileProvider` and pass profile to calculation
    - _Bug_Condition: isBugCondition(calculation) where calculation.location == "analytics_provider" AND calculation.divisor == 5_
    - _Expected_Behavior: result.divisor == userProfile.workoutDaysPerWeek AND result.percentage == (actualWorkouts / userProfile.workoutDaysPerWeek) * 100_
    - _Preservation: Provider state management and data flow remain unchanged_
    - _Requirements: 1.3, 2.3, 2.5, 3.1, 3.2, 3.3_

  - [x] 3.3 Update analytics repository to use user's workoutDaysPerWeek
    - Add `required UserProfile? userProfile` parameter to `getConsistencyMetrics` in `lib/features/analytics/data/repositories/analytics_repository_impl.dart`
    - Replace hardcoded multiplier `targetWorkouts = totalWeeks * 5` with `targetWorkouts = totalWeeks * (userProfile?.workoutDaysPerWeek ?? 1)`
    - Replace hardcoded divisor in WeeklyConsistency `workoutsPlanned: 5` with `workoutsPlanned: userProfile?.workoutDaysPerWeek ?? 1`
    - Replace hardcoded divisor in adherence `(weekWorkouts.length / 5)` with `(weekWorkouts.length / (userProfile?.workoutDaysPerWeek ?? 1))`
    - Update `AnalyticsRepository` interface to include the new parameter
    - Update all call sites to pass UserProfile
    - _Bug_Condition: isBugCondition(calculation) where calculation.location == "analytics_repository" AND calculation.multiplier == 5_
    - _Expected_Behavior: result.multiplier == userProfile.workoutDaysPerWeek AND adherence == totalWorkouts / (totalWeeks * userProfile.workoutDaysPerWeek)_
    - _Preservation: Strength progression, weight tracking, and other analytics calculations remain unchanged_
    - _Requirements: 1.4, 2.4, 2.5, 3.8, 3.9_

  - [x] 3.4 Update home screen to handle null profile gracefully
    - Modify `_WeeklyActivitySection` in `lib/features/workout/presentation/screens/home_screen.dart`
    - Remove hardcoded fallback `target: profile?.workoutDaysPerWeek ?? 4`
    - Add null handling at higher level: wrap section in conditional that checks if profile is null
    - Show appropriate message or loading state when profile is null instead of defaulting to 4
    - Alternative: Use `?? 1` with clear UI indication that profile setup is needed
    - _Bug_Condition: isBugCondition(calculation) where calculation.location == "home_screen" AND calculation.divisor == 4 AND calculation.source == "hardcoded_fallback"_
    - _Expected_Behavior: When profile is null, show loading state or prompt to complete profile; when profile exists, use userProfile.workoutDaysPerWeek_
    - _Preservation: Weekly activity ring display and animation remain unchanged when profile is valid_
    - _Requirements: 1.1, 2.1, 2.5, 3.1, 3.2, 3.7_

  - [x] 3.5 Verify bug condition exploration tests now pass
    - **Property 1: Expected Behavior** - User Configuration Respected
    - **IMPORTANT**: Re-run the SAME tests from task 1 - do NOT write new tests
    - The tests from task 1 encode the expected behavior
    - When these tests pass, it confirms the expected behavior is satisfied
    - Run all bug condition exploration tests from step 1 (tasks 1.1-1.5)
    - **EXPECTED OUTCOME**: All tests PASS (confirms bug is fixed)
    - Verify home screen handles null profile gracefully (test 1.1)
    - Verify analytics screen uses user's workoutDaysPerWeek (test 1.2)
    - Verify analytics provider uses user's workoutDaysPerWeek (test 1.3)
    - Verify analytics repository uses user's workoutDaysPerWeek (test 1.4)
    - Verify edge cases with different workoutDaysPerWeek values work correctly (test 1.5)
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6_

  - [x] 3.6 Verify preservation tests still pass
    - **Property 2: Preservation** - Non-Consistency Functionality Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 2 - do NOT write new tests
    - Run all preservation property tests from step 2 (tasks 2.1-2.6)
    - **EXPECTED OUTCOME**: All tests PASS (confirms no regressions)
    - Verify workout counting preservation (test 2.1)
    - Verify profile saving preservation (test 2.2)
    - Verify weekly activity ring display preservation (test 2.3)
    - Verify analytics non-consistency calculations preservation (test 2.4)
    - Verify empty state preservation (test 2.5)
    - Verify refresh functionality preservation (test 2.6)
    - Confirm all tests still pass after fix (no regressions)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10_

- [x] 4. Checkpoint - Ensure all tests pass
  - Run full test suite including bug condition and preservation tests
  - Verify all consistency calculations use user's workoutDaysPerWeek
  - Verify no regressions in non-consistency functionality
  - Test edge cases: null profile, workoutDaysPerWeek values 1-7, zero workouts
  - Ensure all requirements (1.1-1.6, 2.1-2.6, 3.1-3.10) are satisfied
  - Ask the user if questions arise
