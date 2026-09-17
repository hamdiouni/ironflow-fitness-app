# Global Training Consistency Bugfix Design

## Overview

This bugfix addresses hardcoded fallback values that override the user's configured `workoutDaysPerWeek` from their UserProfile. The bug manifests in three locations: the home screen (using `?? 4`), the analytics screen (dividing by hardcoded `5`), and the analytics repository (multiplying by hardcoded `5`). The fix ensures all consistency calculations use the user's actual training configuration as the single source of truth, while gracefully handling null profile cases without defaulting to arbitrary values.

The fix is minimal and targeted: pass UserProfile data to components that need it, remove hardcoded fallbacks, and handle null cases appropriately. No architectural changes are required—only data flow adjustments.

## Glossary

- **Bug_Condition (C)**: The condition that triggers the bug - when consistency calculations use hardcoded values (4 or 5) instead of the user's configured `workoutDaysPerWeek`
- **Property (P)**: The desired behavior - all consistency calculations SHALL use `userProfile.workoutDaysPerWeek` as the source of truth
- **Preservation**: Existing functionality that must remain unchanged - workout counting, profile saving, UI display, and all non-consistency calculations
- **workoutDaysPerWeek**: The integer property in UserProfile (range 1-7) representing the user's weekly training target
- **Weekly Consistency**: Calculated as `actualWorkouts / workoutDaysPerWeek`, displayed as a percentage
- **Adherence Rate**: Calculated as `totalWorkouts / (totalWeeks * workoutDaysPerWeek)`, clamped to [0.0, 1.0]
- **Weekly Target**: The denominator in consistency calculations, should always be `workoutDaysPerWeek`

## Bug Details

### Bug Condition

The bug manifests when consistency calculations are performed using hardcoded values instead of the user's configured `workoutDaysPerWeek`. The affected components either use a fallback default (`?? 4` in home screen) or a hardcoded divisor/multiplier (`5` in analytics screen and repository).

**Formal Specification:**
```
FUNCTION isBugCondition(calculation)
  INPUT: calculation of type ConsistencyCalculation
  OUTPUT: boolean
  
  RETURN (calculation.location == "home_screen" AND calculation.divisor == 4 AND calculation.source == "hardcoded_fallback")
         OR (calculation.location == "analytics_screen" AND calculation.divisor == 5 AND calculation.source == "hardcoded_literal")
         OR (calculation.location == "analytics_repository" AND calculation.multiplier == 5 AND calculation.source == "hardcoded_literal")
         OR (calculation.divisor != userProfile.workoutDaysPerWeek)
END FUNCTION
```

### Examples

- **Home Screen**: User sets `workoutDaysPerWeek = 3`, completes 2 workouts. Home screen shows "1 more to hit your goal" (correct), but if profile is null, it shows "2 more to hit your goal" (incorrect, assumes 4).
- **Analytics Screen**: User sets `workoutDaysPerWeek = 6`, completes 4 workouts this week. Analytics screen shows `(4 / 5) * 100 = 80%` consistency (incorrect), should show `(4 / 6) * 100 = 67%`.
- **Analytics Repository**: User sets `workoutDaysPerWeek = 3`, completes 9 workouts over 4 weeks. Repository calculates adherence as `9 / (4 * 5) = 45%` (incorrect), should calculate `9 / (4 * 3) = 75%`.
- **Edge Case**: User has not completed onboarding (profile is null). System should show loading state or prompt to complete profile, not assume a default value.

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Workout counting and history display must continue to work exactly as before
- Profile saving during onboarding must remain unchanged
- Weekly activity ring display and animation must remain unchanged
- Strength progression, weight tracking, and other analytics calculations must remain unchanged
- Empty state handling for users with no workout history must remain unchanged
- Refresh functionality for home screen and analytics must remain unchanged

**Scope:**
All inputs that do NOT involve consistency calculations (weekly target, adherence rate, weekly consistency percentage) should be completely unaffected by this fix. This includes:
- Workout creation and logging
- Exercise tracking and volume calculations
- Profile management and updates
- Navigation and UI interactions
- Nutrition tracking and calculations

## Hypothesized Root Cause

Based on the bug description and code analysis, the root causes are:

1. **Missing Data Flow**: The analytics screen and repository do not have access to UserProfile data, so they cannot use `workoutDaysPerWeek` even if they wanted to. The data flow stops at the workout history level.

2. **Defensive Programming Gone Wrong**: The home screen uses `?? 4` as a defensive fallback for null profiles, but this creates inconsistency. The correct approach is to handle null cases explicitly (loading state, error message, or prompt to complete onboarding).

3. **Hardcoded Assumptions**: The analytics screen and repository assume a "standard" 5-day training week, which is a common fitness industry assumption but not appropriate for a personalized app.

4. **Lack of Single Source of Truth**: Each component makes its own assumption about weekly targets instead of deriving it from the UserProfile entity.

## Correctness Properties

Property 1: Bug Condition - Consistency Calculations Use User Configuration

_For any_ consistency calculation where the user has a valid UserProfile with `workoutDaysPerWeek` defined, the fixed code SHALL use `userProfile.workoutDaysPerWeek` as the divisor or multiplier, producing accurate consistency percentages and adherence rates that reflect the user's actual training plan.

**Validates: Requirements 2.2, 2.3, 2.4, 2.5, 2.6**

Property 2: Preservation - Non-Consistency Functionality

_For any_ functionality that is NOT a consistency calculation (workout counting, profile saving, strength progression, weight tracking, UI display, navigation), the fixed code SHALL produce exactly the same behavior as the original code, preserving all existing functionality.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10**

## Fix Implementation

### Changes Required

Assuming our root cause analysis is correct:

**File**: `lib/features/analytics/presentation/screens/analytics_screen.dart`

**Function**: `_calculateWeeklyConsistency`

**Specific Changes**:
1. **Add UserProfile Parameter**: Modify `_calculateWeeklyConsistency` to accept a `UserProfile?` parameter
2. **Replace Hardcoded Divisor**: Change `(thisWeekWorkouts / 5)` to `(thisWeekWorkouts / (profile?.workoutDaysPerWeek ?? 1))`
3. **Update Call Site**: Pass the profile from `profileAsync` to the calculation function
4. **Handle Null Profile**: Use `?? 1` to avoid division by zero, but this should never occur in practice since the UI should handle null profiles at a higher level

**File**: `lib/features/analytics/presentation/providers/analytics_provider.dart`

**Function**: `_calculateWeeklyConsistency`

**Specific Changes**:
1. **Add UserProfile Parameter**: Modify `_calculateWeeklyConsistency` to accept a `UserProfile?` parameter
2. **Replace Hardcoded Divisor**: Change `(thisWeekWorkouts / 5)` to `(thisWeekWorkouts / (profile?.workoutDaysPerWeek ?? 1))`
3. **Update Provider**: Modify `analyticsStatsProvider` to watch `userProfileProvider` and pass profile to calculation
4. **Handle Null Profile**: Use `?? 1` to avoid division by zero

**File**: `lib/features/analytics/data/repositories/analytics_repository_impl.dart`

**Function**: `getConsistencyMetrics`

**Specific Changes**:
1. **Add UserProfile Parameter**: Add a `required UserProfile? userProfile` parameter to the method signature
2. **Replace Hardcoded Multiplier**: Change `targetWorkouts = totalWeeks * 5` to `targetWorkouts = totalWeeks * (userProfile?.workoutDaysPerWeek ?? 1)`
3. **Replace Hardcoded Divisor in WeeklyConsistency**: Change `workoutsPlanned: 5` to `workoutsPlanned: userProfile?.workoutDaysPerWeek ?? 1`
4. **Replace Hardcoded Divisor in Adherence**: Change `(weekWorkouts.length / 5)` to `(weekWorkouts.length / (userProfile?.workoutDaysPerWeek ?? 1))`
5. **Update Interface**: Update the `AnalyticsRepository` interface to include the new parameter
6. **Update Call Sites**: Update all call sites to pass the UserProfile

**File**: `lib/features/workout/presentation/screens/home_screen.dart`

**Function**: `_WeeklyActivitySection` widget

**Specific Changes**:
1. **Remove Hardcoded Fallback**: Change `target: profile?.workoutDaysPerWeek ?? 4` to `target: profile?.workoutDaysPerWeek ?? 1`
2. **Add Null Handling at Higher Level**: Wrap the `_WeeklyActivitySection` in a conditional that checks if profile is null and shows an appropriate message or loading state
3. **Alternative Approach**: Instead of using `?? 1`, consider showing a different UI when profile is null (e.g., "Complete your profile to set a weekly goal")

**File**: `lib/features/workout/presentation/providers/home_screen_provider.dart`

**Function**: `_loadData` method

**Specific Changes**:
1. **No Changes Required**: This provider already loads the profile and passes `weeklyTarget` correctly. The issue is in the home screen widget, not the provider.

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bug on unfixed code, then verify the fix works correctly and preserves existing behavior.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Confirm or refute the root cause analysis. If we refute, we will need to re-hypothesize.

**Test Plan**: Write tests that create UserProfiles with different `workoutDaysPerWeek` values (3, 4, 5, 6) and workout histories, then call the consistency calculation functions. Run these tests on the UNFIXED code to observe failures and confirm the hardcoded values are being used.

**Test Cases**:
1. **Home Screen Null Profile Test**: Create a scenario where profile is null, verify that home screen uses 4 as fallback (will fail on unfixed code by showing incorrect target)
2. **Analytics Screen Hardcoded 5 Test**: Create profile with `workoutDaysPerWeek = 3`, complete 2 workouts, verify analytics screen shows `(2 / 5) = 40%` instead of `(2 / 3) = 67%` (will fail on unfixed code)
3. **Analytics Repository Adherence Test**: Create profile with `workoutDaysPerWeek = 6`, complete 12 workouts over 2 weeks, verify adherence is calculated as `12 / (2 * 5) = 120%` instead of `12 / (2 * 6) = 100%` (will fail on unfixed code)
4. **Edge Case Zero Workouts Test**: Create profile with `workoutDaysPerWeek = 4`, complete 0 workouts, verify consistency is 0% (may pass on unfixed code, but validates edge case handling)

**Expected Counterexamples**:
- Consistency percentages do not match expected values when `workoutDaysPerWeek != 5`
- Adherence rates are inflated or deflated depending on whether user's target is below or above 5
- Home screen shows incorrect "X more to hit your goal" message when profile is null

### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed function produces the expected behavior.

**Pseudocode:**
```
FOR ALL calculation WHERE isBugCondition(calculation) DO
  result := calculateConsistency_fixed(workouts, userProfile)
  ASSERT result.divisor == userProfile.workoutDaysPerWeek
  ASSERT result.percentage == (actualWorkouts / userProfile.workoutDaysPerWeek) * 100
END FOR
```

**Test Cases**:
1. **Home Screen with Profile**: Create profile with `workoutDaysPerWeek = 3`, complete 2 workouts, verify home screen shows "1 more to hit your goal"
2. **Analytics Screen with Profile**: Create profile with `workoutDaysPerWeek = 6`, complete 4 workouts, verify analytics screen shows `(4 / 6) * 100 = 67%` consistency
3. **Analytics Repository Adherence**: Create profile with `workoutDaysPerWeek = 3`, complete 9 workouts over 4 weeks, verify adherence is `9 / (4 * 3) = 75%`
4. **All Values 1-7**: Test with `workoutDaysPerWeek` values from 1 to 7, verify calculations are correct for each

### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL functionality WHERE NOT isConsistencyCalculation(functionality) DO
  ASSERT originalBehavior(functionality) == fixedBehavior(functionality)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all non-consistency inputs

**Test Plan**: Observe behavior on UNFIXED code first for non-consistency features, then write property-based tests capturing that behavior.

**Test Cases**:
1. **Workout Counting Preservation**: Verify that workout history display shows the same workouts before and after fix
2. **Profile Saving Preservation**: Verify that saving a profile during onboarding works identically before and after fix
3. **Strength Progression Preservation**: Verify that strength progression calculations in analytics repository are unchanged
4. **Weight Tracking Preservation**: Verify that weight tracking calculations in analytics repository are unchanged
5. **UI Display Preservation**: Verify that weekly activity ring, summary cards, and other UI elements display correctly
6. **Empty State Preservation**: Verify that users with no workout history see the same empty states before and after fix

### Unit Tests

- Test `_calculateWeeklyConsistency` with various `workoutDaysPerWeek` values (1-7)
- Test `getConsistencyMetrics` with various profiles and workout histories
- Test home screen weekly activity section with different profile states (null, valid, edge cases)
- Test edge cases: zero workouts, null profile, `workoutDaysPerWeek = 1`, `workoutDaysPerWeek = 7`

### Property-Based Tests

- Generate random UserProfiles with `workoutDaysPerWeek` in range [1, 7]
- Generate random workout histories with varying lengths and dates
- Verify that consistency calculations always use `userProfile.workoutDaysPerWeek` as divisor/multiplier
- Verify that adherence rate is always in range [0.0, 1.0]
- Verify that weekly consistency percentage is always in range [0, 100]

### Integration Tests

- Test full user flow: complete onboarding with `workoutDaysPerWeek = 3`, log 2 workouts, verify home screen and analytics screen show correct consistency
- Test profile update flow: change `workoutDaysPerWeek` from 4 to 6, verify all screens update calculations
- Test null profile handling: clear profile data, verify home screen shows appropriate message instead of defaulting to 4
