# Requirements Document: IronFlow Product Upgrade - Complete System Integration

## Executive Summary

IronFlow has excellent architecture but is 40% incomplete with critical system disconnections. This upgrade transforms it from a scaffolded app into a competitive fitness product by:

1. **Fixing critical bugs** that break core workflows
2. **Connecting all systems** so features work together seamlessly
3. **Completing partial implementations** (video player, program editor, diet generation)
4. **Adding missing features** (analytics, retention, adaptive suggestions)
5. **Modernizing UX** (dark mode, animations, consistent styling)

**Target Outcome:** A fully functional, user-ready fitness app that guides users from onboarding through consistent workout tracking with intelligent suggestions and progress analytics.

---

## Part 1: Critical Bug Fixes

### Requirement 1: Fix Workout Start Flow

**User Story:** As a user, when I press "Start Workout", I want my program's exercises to load automatically, not an empty list.

#### Acceptance Criteria

1. WHEN user taps "Start Workout" on a program day, THE system SHALL load exercises from the active program's current day
2. THE loaded exercises SHALL include name, sets, reps, and rest seconds from the program
3. WHEN no active program exists, THE system SHALL show "No Program" message instead of empty workout
4. THE workout session SHALL be pre-populated with program exercises, not requiring manual entry
5. WHEN user completes the workout, THE system SHALL mark the day as complete in the active program

**Root Cause:** `StartWorkoutUseCase` creates empty workout with no exercises. It never queries the active program.

**Fix Location:** `lib/features/workout/domain/usecases/start_workout_use_case.dart`

---

### Requirement 2: Fix Weight Validation (20kg vs 200kg)

**User Story:** As a user, I want the app to prevent me from accidentally entering 200kg when I meant 20kg.

#### Acceptance Criteria

1. WHEN user enters weight in any field, THE system SHALL validate range 0-500kg
2. IF weight is outside range, THE system SHALL display error message "Weight must be 0-500kg"
3. THE system SHALL NOT allow saving invalid weight values
4. WHEN user enters weight, THE system SHALL show real-time validation feedback
5. THE weight SHALL be stored as double (not int) to preserve decimal values like 22.5kg

**Root Cause:** No UI-level validation on weight input fields. Backend correctly uses double, but frontend accepts any value.

**Fix Location:** `lib/features/workout/presentation/widgets/number_field.dart` (create if missing)

---

### Requirement 3: Fix Video System Integration

**User Story:** As a user, I want to watch exercise videos directly in the app with proper playback controls.

#### Acceptance Criteria

1. WHEN user views an exercise, THE system SHALL display a video thumbnail
2. WHEN user taps the thumbnail, THE system SHALL open a video player
3. THE video player SHALL support play/pause, fullscreen, and volume controls
4. IF video fails to load, THE system SHALL display fallback image with error message
5. THE system SHALL NOT use url_launcher for video playback (use video_player package)
6. WHEN video loads, THE system SHALL show loading indicator
7. THE video player SHALL autoplay with muted audio by default

**Root Cause:** Video map exists (50+ exercises mapped) but no video player widget. Thumbnails show but don't open player.

**Fix Location:** Create `lib/features/workout/presentation/widgets/exercise_video_player.dart`

---

## Part 2: System Connections

### Requirement 4: Connect Onboarding → Program Generation → Active Program

**User Story:** As a user, after I complete onboarding, I want my program to be automatically generated and ready to use.

#### Acceptance Criteria

1. WHEN user completes onboarding, THE system SHALL save user profile
2. IMMEDIATELY AFTER profile save, THE system SHALL generate a workout program based on profile
3. THE generated program SHALL be saved as the ACTIVE PROGRAM
4. WHEN program is saved, THE system SHALL generate a diet plan
5. WHEN both are ready, THE system SHALL navigate to workout screen (not empty state)
6. THE workout screen SHALL display the first day of the generated program
7. IF generation fails, THE system SHALL show error message and allow retry

**Root Cause:** Onboarding saves profile but never calls program generation. User sees "No Active Program" after signup.

**Fix Location:** `lib/features/onboarding/presentation/providers/onboarding_provider.dart`

---

### Requirement 5: Connect Workout Screen → Active Program → Exercises

**User Story:** As a user, I want the workout screen to always show my current program day with all exercises ready to log.

#### Acceptance Criteria

1. WHEN workout screen loads, THE system SHALL fetch the active program
2. THE system SHALL display the current day name and focus area
3. THE system SHALL show all exercises for the current day with sets/reps/rest
4. WHEN user taps "Start Workout", THE system SHALL pass the current day exercises to the workout session
5. THE system SHALL show week view with current day highlighted
6. WHEN user manually selects a different day, THE system SHALL update current day index
7. WHEN user completes a workout, THE system SHALL advance to next workout day (skipping rest days)

**Root Cause:** Workout screen watches active program but doesn't pass it to active workout screen. Active workout screen creates empty workout.

**Fix Location:** `lib/features/workout/presentation/screens/active_workout_screen.dart`

---

### Requirement 6: Connect Nutrition Screen → Diet Plan Generation

**User Story:** As a user, I want to generate a personalized diet plan that shows my daily targets and suggested meals.

#### Acceptance Criteria

1. WHEN nutrition screen loads, THE system SHALL check if diet plan exists
2. IF diet plan exists, THE system SHALL display personalized targets (calories, protein, carbs, fats)
3. IF no diet plan exists, THE system SHALL show "Generate Diet Plan" button
4. WHEN user taps "Generate Diet Plan", THE system SHALL create plan based on user profile
5. THE generated plan SHALL include daily targets and suggested meals
6. WHEN plan is generated, THE system SHALL display it immediately
7. THE system SHALL persist diet plan to local storage

**Root Cause:** "Generate Diet Plan" button has empty callback. Diet plan generation exists but is never called.

**Fix Location:** `lib/features/nutrition/presentation/screens/nutrition_screen.dart`

---

## Part 3: Complete Partial Implementations

### Requirement 7: Implement Program Editor Screen

**User Story:** As a user, I want to edit my program by replacing exercises, changing sets/reps, and reordering exercises.

#### Acceptance Criteria

1. WHEN user taps edit button on workout screen, THE system SHALL navigate to program editor
2. THE editor SHALL display all days of the program with exercises
3. WHEN user selects a day, THE system SHALL show exercises for that day
4. FOR each exercise, THE system SHALL provide options: Replace, Edit Parameters, Delete, Reorder
5. WHEN user replaces an exercise, THE system SHALL show exercise picker filtered by muscle group
6. WHEN user edits parameters, THE system SHALL validate sets (positive int), reps (int or "X-Y"), rest (non-negative int)
7. WHEN user reorders exercises, THE system SHALL use drag-drop interface
8. WHEN user saves changes, THE system SHALL update the active program and persist to storage

**Root Cause:** Edit button exists but screen doesn't. Route is defined but implementation is missing.

**Fix Location:** Create `lib/features/workout/presentation/screens/program_editor_screen.dart`

---

### Requirement 8: Implement Exercise Picker

**User Story:** As a user, I want to replace exercises with alternatives from the same muscle group.

#### Acceptance Criteria

1. WHEN user taps "Replace Exercise", THE system SHALL show exercise picker
2. THE picker SHALL display exercises grouped by muscle group
3. THE picker SHALL filter to show only exercises from the same muscle group as original
4. WHEN user selects an exercise, THE system SHALL replace it while preserving sets/reps/rest
5. THE picker SHALL show exercise images and descriptions
6. THE system SHALL support search to find exercises quickly

**Root Cause:** Exercise database exists (68 exercises) but no picker UI. Program editor needs this to replace exercises.

**Fix Location:** Create `lib/features/workout/presentation/screens/exercise_picker_screen.dart`

---

### Requirement 9: Implement Progression Suggestion System

**User Story:** As a user, I want intelligent suggestions on when to increase weight or reps based on my performance.

#### Acceptance Criteria

1. WHEN user completes a workout, THE system SHALL analyze performance vs program targets
2. IF user completed all sets with good form, THE system SHALL suggest weight increase (2.5-5%)
3. IF user struggled on last sets, THE system SHALL suggest maintaining weight
4. IF user easily exceeded targets, THE system SHALL suggest adding 1-2 reps
5. THE suggestions SHALL appear on dashboard after workout
6. WHEN user accepts suggestion, THE system SHALL update the program
7. THE system SHALL track suggestion history for analytics

**Root Cause:** Provider watches `progressionSuggestionProvider` but logic is missing. Use case doesn't exist.

**Fix Location:** Create `lib/features/workout/domain/usecases/get_progression_suggestion_use_case.dart`

---

## Part 4: Missing Features

### Requirement 10: Implement Progress Analytics

**User Story:** As a user, I want to see my progress over time with charts showing strength gains and consistency.

#### Acceptance Criteria

1. WHEN user opens analytics screen, THE system SHALL display:
   - Total workouts completed
   - Current streak (consecutive days with workout)
   - Weekly consistency (% of planned workouts completed)
   - Strength progression (weight increase per exercise over time)
   - Volume progression (total reps × weight over time)

2. THE system SHALL show graphs for:
   - Strength progression (line chart: exercise → weight over time)
   - Volume progression (bar chart: weekly volume)
   - Consistency (calendar heatmap: workout days)

3. WHEN user selects an exercise, THE system SHALL show detailed progression for that exercise

4. THE system SHALL allow filtering by date range (1 week, 1 month, 3 months, all time)

**Root Cause:** Workout history is saved but no analytics screen exists. No aggregation logic.

**Fix Location:** Create `lib/features/analytics/presentation/screens/analytics_screen.dart`

---

### Requirement 11: Implement Retention Features

**User Story:** As a user, I want reminders to work out and to see my streak to stay motivated.

#### Acceptance Criteria

1. WHEN user completes onboarding, THE system SHALL ask for workout reminder time
2. THE system SHALL send daily notification at selected time if no workout logged
3. WHEN user completes a workout, THE system SHALL increment streak counter
4. WHEN user misses a day, THE system SHALL reset streak
5. THE system SHALL display current streak on dashboard
6. WHEN user reaches milestones (7, 30, 100 workouts), THE system SHALL show achievement badge
7. THE system SHALL allow user to share streak on social media

**Root Cause:** No notification system. No streak tracking. No achievement system.

**Fix Location:** Create `lib/features/retention/` with notification and streak providers

---

### Requirement 12: Implement Adaptive Meal Suggestions

**User Story:** As a user, I want meal suggestions based on my macro targets and preferences.

#### Acceptance Criteria

1. WHEN user opens nutrition screen, THE system SHALL suggest meals for each meal type
2. THE suggestions SHALL match user's macro targets (within 10% tolerance)
3. WHEN user has logged meals, THE system SHALL suggest alternatives with similar macros
4. WHEN user searches for food, THE system SHALL show results with macro breakdown
5. THE system SHALL allow filtering by:
   - Meal type (breakfast, lunch, dinner, snack)
   - Dietary preference (vegetarian, vegan, keto, etc.)
   - Cuisine type
6. WHEN user logs a meal, THE system SHALL update remaining macros in real-time

**Root Cause:** Food database exists (80 foods) but no suggestion logic. No filtering UI.

**Fix Location:** Create `lib/features/nutrition/presentation/screens/meal_suggestion_screen.dart`

---

## Part 5: UX Modernization

### Requirement 13: Implement Dark Mode

**User Story:** As a user, I want to use the app in dark mode to reduce eye strain.

#### Acceptance Criteria

1. THE app SHALL support both light and dark themes
2. WHEN user enables dark mode in settings, THE system SHALL apply dark theme to all screens
3. THE dark theme SHALL use appropriate colors for readability
4. WHEN user toggles dark mode, THE system SHALL persist preference
5. THE system SHALL respect system dark mode preference on app launch

**Root Cause:** Material 3 theme is set up but no dark mode implementation.

**Fix Location:** `lib/core/constants/app_theme.dart`

---

### Requirement 14: Implement Smooth Animations

**User Story:** As a user, I want smooth transitions and animations that make the app feel polished.

#### Acceptance Criteria

1. WHEN user navigates between screens, THE system SHALL show smooth page transition
2. WHEN user completes a set, THE system SHALL show celebration animation
3. WHEN macro wheel updates, THE system SHALL animate smoothly to new values
4. WHEN user scrolls history, THE system SHALL animate items in smoothly
5. ALL animations SHALL complete within 300ms for responsiveness

**Root Cause:** Some animations exist but are inconsistent. No global animation strategy.

**Fix Location:** `lib/shared/animations/` (enhance existing)

---

### Requirement 15: Implement Consistent Styling

**User Story:** As a user, I want the app to feel cohesive with consistent design language.

#### Acceptance Criteria

1. ALL screens SHALL use theme colors from `AppTheme`
2. ALL cards SHALL use consistent padding and border radius
3. ALL buttons SHALL use consistent styling
4. ALL text SHALL use theme typography
5. ALL input fields SHALL use consistent styling
6. WHEN user interacts with elements, THE system SHALL show consistent feedback

**Root Cause:** Some screens use hardcoded colors. Inconsistent use of theme.

**Fix Location:** `lib/core/constants/app_theme.dart` and all screens

---

## Part 6: Validation & Reliability

### Requirement 16: Comprehensive Input Validation

**User Story:** As a user, I want the app to prevent invalid data entry and show clear error messages.

#### Acceptance Criteria

1. WHEN user enters weight, THE system SHALL validate 0-500kg range
2. WHEN user enters sets, THE system SHALL validate positive integer
3. WHEN user enters reps, THE system SHALL validate positive integer or "X-Y" range
4. WHEN user enters rest seconds, THE system SHALL validate non-negative integer
5. WHEN user enters calories, THE system SHALL validate positive number
6. WHEN user enters macros, THE system SHALL validate positive numbers
7. IF validation fails, THE system SHALL show inline error message
8. THE system SHALL prevent saving invalid data

**Root Cause:** Validation exists in domain layer but not enforced in UI.

**Fix Location:** All input widgets in presentation layer

---

### Requirement 17: Error Handling & Recovery

**User Story:** As a user, I want clear error messages and the ability to recover from failures.

#### Acceptance Criteria

1. WHEN operation fails, THE system SHALL show user-friendly error message
2. THE system SHALL NOT show technical error details to user
3. WHEN network error occurs, THE system SHALL show "Offline" indicator
4. WHEN storage error occurs, THE system SHALL show "Data Save Failed" with retry button
5. WHEN user taps retry, THE system SHALL attempt operation again
6. THE system SHALL log errors for debugging

**Root Cause:** Error handling exists but messages are sometimes technical.

**Fix Location:** `lib/core/utils/error_handler.dart` (enhance)

---

## Part 7: Performance & Stability

### Requirement 18: Performance Optimization

**User Story:** As a user, I want the app to be fast and responsive.

#### Acceptance Criteria

1. WHEN user navigates between screens, THE transition SHALL complete within 300ms
2. WHEN user scrolls lists, THE scroll SHALL be smooth (60fps)
3. WHEN user logs a meal, THE macro wheel SHALL update within 200ms
4. WHEN user completes workout, THE active program update SHALL persist within 500ms
5. THE app SHALL use efficient storage queries (no N+1 queries)
6. THE app SHALL cache images to reduce network requests

**Root Cause:** No performance monitoring. Some operations may be slow.

**Fix Location:** All screens and providers

---

## Part 8: Testing & Quality

### Requirement 19: Comprehensive Testing

**User Story:** As a developer, I want confidence that all features work correctly.

#### Acceptance Criteria

1. ALL critical user flows SHALL have integration tests:
   - Onboarding → Program generation → Workout
   - Workout start → Exercise logging → Completion
   - Nutrition → Meal logging → Macro update
   - Program editor → Exercise replacement → Save

2. ALL use cases SHALL have unit tests

3. ALL widgets SHALL have widget tests

4. ALL property-based tests SHALL validate correctness properties

5. Test coverage SHALL be ≥80% for critical paths

**Root Cause:** Some integration tests exist but not for all critical flows.

**Fix Location:** `test/` directory

---

## Summary of Changes

| Area | Status | Impact |
|------|--------|--------|
| Workout Start Bug | 🔴 Critical | Blocks core workflow |
| Weight Validation | 🔴 Critical | Data integrity |
| Video System | 🔴 Critical | Feature incomplete |
| Onboarding Connection | 🔴 Critical | User flow broken |
| Program Editor | 🟠 High | Feature missing |
| Progression Suggestions | 🟠 High | Engagement |
| Analytics | 🟠 High | Retention |
| Retention Features | 🟠 High | User retention |
| Dark Mode | 🟡 Medium | UX polish |
| Animations | 🟡 Medium | UX polish |
| Consistent Styling | 🟡 Medium | UX polish |
| Input Validation | 🟡 Medium | Data quality |

---

## Success Criteria

The upgrade is complete when:

1. ✅ All critical bugs are fixed
2. ✅ All systems are connected (onboarding → program → workout → nutrition)
3. ✅ User can complete full workflow: onboard → generate program → start workout → log sets → see progression
4. ✅ Program editor works (replace, reorder, edit exercises)
5. ✅ Analytics screen shows progress
6. ✅ Retention features work (reminders, streaks)
7. ✅ App feels modern (dark mode, smooth animations, consistent styling)
8. ✅ All critical paths have integration tests
9. ✅ No crashes or data corruption
10. ✅ Performance is smooth (300ms transitions, 200ms macro updates)

---

## Timeline Estimate

- **Critical Bugs**: 2-3 hours
- **System Connections**: 3-4 hours
- **Partial Implementations**: 4-5 hours
- **Missing Features**: 6-8 hours
- **UX Modernization**: 3-4 hours
- **Testing & Polish**: 2-3 hours

**Total**: ~20-27 hours of focused development

