# Implementation Tasks: IronFlow Product Upgrade

## Phase 1: Critical Bug Fixes (MUST DO FIRST) ✅ COMPLETE

- [x] 1.1 Fix StartWorkoutUseCase to load from active program ✅
  - Modified `lib/features/workout/domain/usecases/start_workout_use_case.dart`
  - Loads active program and current day exercises
  - Converts program exercises to workout exercises
  - Passes suggested sets/reps/rest to workout
  - Throws exception if no active program

- [x] 1.2 Add weight validation (0-500kg range) ✅
  - Created `lib/features/workout/presentation/widgets/weight_input_field.dart`
  - Validates on input change
  - Shows error message if out of range
  - Prevents saving invalid values
  - Supports decimal values

- [x] 1.3 Implement video player widget ✅
  - Verified `lib/features/workout/presentation/widgets/exercise_video_player.dart`
  - Uses video_player package (NOT url_launcher)
  - Autoplay with muted audio
  - Shows loading indicator
  - Fallback to image on error
  - Retry logic (2 second delay)

- [x] 1.4 Add video player to exercise display ✅
  - Modified `lib/features/workout/presentation/screens/active_workout_screen.dart`
  - Replaced thumbnail with video player widget
  - Handles video errors gracefully
  - Added videoUrl() method to ExerciseVideoMap

---

## Phase 2: System Connections (CRITICAL)

- [x] 2.1 Connect onboarding to program generation
  - Modify `lib/features/onboarding/presentation/providers/onboarding_provider.dart`
  - After profile save, generate workout program
  - Save program as active program
  - Generate and save diet plan
  - Navigate to workout screen (not empty state)

- [x] 2.2 Connect workout screen to active program
  - Modify `lib/features/workout/presentation/screens/active_workout_screen.dart`
  - Accept active program as parameter
  - Pass to StartWorkoutUseCase
  - Load exercises from program

- [x] 2.3 Connect nutrition screen to diet plan generation
  - Modify `lib/features/nutrition/presentation/screens/nutrition_screen.dart`
  - Implement "Generate Diet Plan" button callback
  - Generate plan from user profile
  - Save plan to storage
  - Refresh provider to show new plan

- [x] 2.4 Add navigation to pass active program
  - Modify `lib/features/workout/presentation/screens/workout_screen.dart`
  - Pass active program to active workout screen via route extra
  - Update go_router configuration if needed

---

## Phase 3: Complete Partial Implementations

- [x] 3.1 Create program editor screen
  - Create `lib/features/workout/presentation/screens/program_editor_screen.dart`
  - Day selector with horizontal scroll
  - Exercise list with drag-drop reordering
  - Replace exercise dialog
  - Edit parameters dialog
  - Delete exercise option
  - Save changes to active program

- [x] 3.2 Create exercise picker screen
  - Create `lib/features/workout/presentation/screens/exercise_picker_screen.dart`
  - Display exercises grouped by muscle group
  - Filter by muscle group
  - Search functionality
  - Show exercise images
  - Return selected exercise

- [x] 3.3 Create exercise edit card widget
  - Create `lib/features/workout/presentation/widgets/exercise_edit_card.dart`
  - Display exercise name, sets, reps, rest
  - Drag handle for reordering
  - Popup menu with Replace, Edit, Delete options

- [x] 3.4 Add program editor route to router
  - Modify `lib/core/router/app_router.dart`
  - Add /workout/editor route
  - Add /exercise-picker route
  - Wire up navigation

- [x] 3.5 Add edit button to workout screen
  - Modify `lib/features/workout/presentation/screens/workout_screen.dart`
  - Add edit icon button to AppBar
  - Navigate to program editor on tap

---

## Phase 3.5: Critical Prerequisite - Exercise Database Population

- [x] 3.6 Populate exercise database with 100+ exercises
  - Modify `lib/features/workout/data/exercise_database.dart`
  - Add 100+ exercises grouped by muscle group:
    - Chest: Bench Press, Incline Press, Dumbbell Flyes, Cable Crossover, etc.
    - Back: Deadlift, Barbell Rows, Pull-ups, Lat Pulldowns, etc.
    - Legs: Squats, Leg Press, Leg Curls, Leg Extensions, etc.
    - Shoulders: Overhead Press, Lateral Raises, Shrugs, etc.
    - Arms: Barbell Curls, Tricep Dips, Hammer Curls, etc.
    - Abs: Crunches, Planks, Leg Raises, etc.
  - Each exercise must have: name, muscle group, image URL, video URL
  - Ensure all video URLs are valid YouTube embed URLs
  - Test that exercises load without errors

- [x] 3.7 Verify active program provider enhancements
  - Review `lib/features/workout/presentation/providers/workout_providers.dart`
  - Ensure activeProgramProvider watches for changes
  - Ensure provider updates when program is edited
  - Ensure provider persists to Hive storage
  - Test that program changes reflect immediately in UI

---

## Phase 4: Missing Features - Progression & Analytics

- [x] 4.1 Create progression suggestion use case
  - Create `lib/features/workout/domain/usecases/get_progression_suggestion_use_case.dart`
  - Analyze last 3 workouts for exercise
  - Suggest weight increase if easy completion
  - Suggest maintaining weight if struggled
  - Suggest adding reps if completed all sets

- [x] 4.2 Create progression suggestion provider
  - Create provider in `lib/features/workout/presentation/providers/workout_providers.dart`
  - Watch exercise history
  - Call use case to get suggestion
  - Return suggestion or null

- [x] 4.3 Display progression suggestions
  - Modify `lib/features/workout/presentation/screens/active_workout_screen.dart`
  - Show suggestion after workout completion
  - Allow user to accept/dismiss suggestion
  - Update program if accepted

- [x] 4.4 Create analytics screen
  - Create `lib/features/analytics/presentation/screens/analytics_screen.dart`
  - Display total workouts, current streak, weekly consistency
  - Show strength progression chart (line chart)
  - Show volume progression chart (bar chart)
  - Add date range filter

- [x] 4.5 Create analytics provider
  - Create `lib/features/analytics/presentation/providers/analytics_provider.dart`
  - Calculate stats from workout history
  - Prepare data for charts

- [x] 4.6 Add analytics route to router
  - Modify `lib/core/router/app_router.dart`
  - Add /analytics route
  - Add navigation button to main screen

---

## Phase 5: Missing Features - Retention

- [x] 5.1 Create streak tracking system
  - Create `lib/features/retention/domain/entities/streak.dart`
  - Track consecutive days with workouts
  - Reset on missed day
  - Calculate current streak

- [x] 5.2 Create streak provider
  - Create `lib/features/retention/presentation/providers/streak_provider.dart`
  - Watch workout history
  - Calculate current streak
  - Expose streak value

- [x] 5.3 Display streak on dashboard
  - Modify `lib/features/workout/presentation/screens/workout_screen.dart`
  - Show current streak with fire icon
  - Show streak count

- [x] 5.4 Create notification system
  - Create `lib/features/retention/domain/usecases/schedule_workout_reminder_use_case.dart`
  - Use flutter_local_notifications package
  - Schedule daily notification at user-selected time
  - Show notification if no workout logged

- [x] 5.5 Add notification settings
  - Modify onboarding to ask for reminder time
  - Create settings screen for notification preferences
  - Allow user to enable/disable notifications

- [x] 5.6 Create achievement system
  - Create `lib/features/retention/domain/entities/achievement.dart`
  - Define achievements (7 workouts, 30 workouts, 100 workouts, etc.)
  - Create achievement provider
  - Show achievement badge when unlocked

---

## Phase 6: Missing Features - Nutrition

- [x] 6.1 Create meal suggestion use case
  - Create `lib/features/nutrition/domain/usecases/get_meal_suggestions_use_case.dart`
  - Filter meals by macro targets (within 10% tolerance)
  - Return at least 3 alternatives if available
  - Sort by macro match quality

- [x] 6.2 Create meal suggestion provider
  - Create provider in `lib/features/nutrition/presentation/providers/nutrition_providers.dart`
  - Watch diet plan and daily totals
  - Call use case to get suggestions
  - Return suggestions

- [x] 6.3 Create meal suggestion screen
  - Create `lib/features/nutrition/presentation/screens/meal_suggestion_screen.dart`
  - Display suggested meals with macro breakdown
  - Show macro comparison to target
  - Allow user to select meal
  - Return selected meal

- [x] 6.4 Add meal search functionality
  - Modify `lib/features/nutrition/presentation/screens/nutrition_screen.dart`
  - Add search field for foods
  - Filter food database by search term
  - Show results with macro breakdown

- [x] 6.5 Add meal filtering
  - Add filter options: meal type, dietary preference, cuisine
  - Filter food database by selected filters
  - Show filtered results

---

## Phase 7: UX Modernization

- [x] 7.1 Implement dark mode
  - Modify `lib/core/constants/app_theme.dart`
  - Create dark theme using Material 3
  - Create theme provider for toggling
  - Modify `lib/main.dart` to use theme provider

- [x] 7.2 Add dark mode toggle to settings
  - Create settings screen if missing
  - Add dark mode toggle
  - Persist theme preference

- [x] 7.3 Implement smooth animations
  - Modify screen transitions to use smooth animations
  - Add celebration animation for set completion
  - Add smooth animation for macro wheel updates
  - Add smooth animation for history items

- [x] 7.4 Ensure consistent styling
  - Audit all screens for consistent use of theme colors
  - Replace hardcoded colors with theme colors
  - Ensure consistent padding/spacing
  - Ensure consistent button styling

- [x] 7.5 Add loading states
  - Ensure all async operations show loading indicator
  - Show skeleton loaders for lists
  - Show progress indicators for long operations

---

## Phase 8: Validation & Error Handling

- [x] 8.1 Add comprehensive input validation
  - Validate weight (0-500kg)
  - Validate sets (positive integer)
  - Validate reps (positive integer or "X-Y" range)
  - Validate rest seconds (non-negative integer)
  - Validate calories (positive number)
  - Validate macros (positive numbers)

- [x] 8.2 Improve error messages
  - Ensure all error messages are user-friendly
  - Remove technical error details
  - Provide actionable error messages
  - Add retry buttons for recoverable errors

- [x] 8.3 Add offline indicator
  - Show "Offline" indicator when no internet
  - Disable features that require internet
  - Queue operations for sync when online

- [x] 8.4 Add data validation on save
  - Validate all data before saving to storage
  - Prevent saving invalid data
  - Show validation errors to user

---

## Phase 9: Testing & Quality

- [x] 9.1 Create integration test for onboarding flow
  - Test: Complete onboarding → Program generated → Active program saved → Navigate to workout
  - Verify program is loaded on workout screen
  - Verify exercises are displayed

- [x] 9.2 Create integration test for workout flow
  - Test: Start workout → Load exercises → Log sets → Complete workout → Day advanced
  - Verify exercises loaded from active program
  - Verify day advancement logic

- [x] 9.3 Create integration test for nutrition flow
  - Test: Generate diet plan → Display in nutrition screen → Log meal → Macros update
  - Verify diet plan generated
  - Verify macros update within 200ms

- [x] 9.4 Create integration test for program editor
  - Test: Open editor → Replace exercise → Save → Verify active program updated
  - Test: Reorder exercises → Save → Verify order persisted
  - Test: Edit parameters → Save → Verify parameters updated

- [x] 9.5 Create unit tests for use cases
  - Test progression suggestion logic
  - Test streak calculation
  - Test meal suggestion filtering
  - Test analytics calculations

- [x] 9.6 Create widget tests for new screens
  - Test program editor screen
  - Test exercise picker screen
  - Test analytics screen
  - Test meal suggestion screen

- [x] 9.7 Run full test suite
  - Ensure all tests pass
  - Verify test coverage ≥80% for critical paths
  - Fix any failing tests

---

## Phase 10: Performance & Stability

- [x] 10.1 Implement offline sync system
  - Create `lib/features/workout/domain/usecases/sync_offline_data_use_case.dart`
  - Track pending operations (workouts, program edits, diet logs)
  - Queue operations when offline
  - Sync when connection restored
  - Show sync status indicator
  - Handle sync conflicts (last-write-wins strategy)
  - Ensure no data loss during offline periods

- [x] 10.2 Profile app performance
  - Measure screen transition times
  - Measure list scroll performance
  - Measure macro wheel update latency
  - Measure storage query performance

- [x] 10.3 Optimize slow operations
  - Cache frequently accessed data
  - Use efficient queries
  - Lazy load images
  - Optimize animations

- [x] 10.4 Test stability
  - Test app with large workout history (1000+ workouts)
  - Test app with large food database
  - Test app with many programs
  - Verify no crashes or memory leaks

---

## Phase 11: Final Polish

- [x] 11.1 Review all screens for consistency
  - Ensure consistent spacing
  - Ensure consistent colors
  - Ensure consistent typography
  - Ensure consistent interactions

- [x] 11.2 Add helpful hints and tooltips
  - Add tooltips to unclear buttons
  - Add hints to input fields
  - Add onboarding hints for new features

- [x] 11.3 Test on multiple devices
  - Test on phone (small screen)
  - Test on tablet (large screen)
  - Test on different Android versions
  - Test on different iOS versions

- [x] 11.4 Final bug fixes
  - Fix any remaining bugs
  - Fix any UI issues
  - Fix any performance issues

---

## Phase 12: Documentation & Deployment

- [x] 12.1 Update code documentation
  - Add comments to complex logic
  - Update README with new features
  - Document new use cases and providers

- [x] 12.2 Create user documentation
  - Create in-app tutorial for new features
  - Create FAQ for common questions
  - Create troubleshooting guide

- [x] 12.3 Prepare for release
  - Update version number
  - Update app description
  - Update screenshots
  - Prepare release notes

- [x] 12.4 Deploy to app stores
  - Build release APK
  - Build release iOS app
  - Submit to Google Play Store
  - Submit to Apple App Store

---

## Success Criteria

✅ All critical bugs fixed
✅ All systems connected
✅ All partial implementations completed
✅ All missing features implemented
✅ UX modernized (dark mode, animations, consistent styling)
✅ Comprehensive testing (≥80% coverage)
✅ Performance optimized (300ms transitions, 200ms macro updates)
✅ No crashes or data corruption
✅ App feels polished and professional

---

## Estimated Timeline

- Phase 1 (Critical Bugs): 2-3 hours
- Phase 2 (System Connections): 3-4 hours
- Phase 3 (Partial Implementations): 4-5 hours
- Phase 3.5 (Exercise Database & Provider): 1-2 hours
- Phase 4 (Progression & Analytics): 3-4 hours
- Phase 5 (Retention): 2-3 hours
- Phase 6 (Nutrition): 2-3 hours
- Phase 7 (UX Modernization): 2-3 hours
- Phase 8 (Validation): 1-2 hours
- Phase 9 (Testing): 3-4 hours
- Phase 10 (Performance & Offline Sync): 3-4 hours
- Phase 11 (Polish): 2-3 hours
- Phase 12 (Documentation): 1-2 hours

**Total: ~30-42 hours**

