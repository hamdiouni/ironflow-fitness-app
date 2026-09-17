# Implementation Plan: Connect Existing Systems in IronFlow

## Overview

This implementation plan integrates IronFlow's existing workout program generation and diet plan systems into the actual user workflow. The feature introduces the Active Program concept as the single source of truth for workout sessions, connects diet plans to the nutrition screen, fixes the video player implementation, and enables program customization through editing.

The implementation follows Clean Architecture with bottom-up development: Domain entities → Use cases → Data layer → State management → UI components → Integration.

## Tasks

- [x] 1. Domain layer - Active Program entities
  - [x] 1.1 Create ActiveProgram entity with Freezed
    - Implement ActiveProgram entity (id, program, currentDayIndex, isActive, lastWorkoutDate, completedDays)
    - Add computed properties: currentDay, isRestDay, nextWorkoutDayIndex, weekCompletionPercentage
    - Implement completeCurrentDay() method with day advancement logic
    - Implement updateProgram() method for editing
    - _Requirements: 1.1, 8.6, 9.4, 19.2, 19.4_

  - [x] 1.2 Write property test for workout day advancement
    - **Property 7: Workout Day Advancement**
    - **Validates: Requirements 8.6**

  - [x] 1.3 Write property test for week completion percentage
    - **Property 10: Week Completion Percentage Calculation**
    - **Validates: Requirements 19.4**

  - [x] 1.4 Create DietPlanState entity with Freezed
    - Implement DietPlanState entity (plan, mealSwaps, lastUpdated)
    - Implement getMealsForDay() method with swap application
    - Implement swapMeal() method for meal replacement
    - _Requirements: 6.2, 6.5, 15.4_

  - [x] 1.5 Write unit tests for DietPlanState methods
    - Test getMealsForDay returns meals with swaps applied
    - Test swapMeal updates mealSwaps map correctly
    - _Requirements: 6.5, 15.4_

- [x] 2. Domain layer - Repository interfaces and use cases
  - [x] 2.1 Define ActiveProgramRepository interface
    - Create interface with methods: saveActiveProgram, loadActiveProgram, clearActiveProgram, updateActiveProgram
    - _Requirements: 7.2, 10.1_

  - [x] 2.2 Define DietPlanRepository interface
    - Create interface with methods: saveDietPlan, loadDietPlan, clearDietPlan
    - _Requirements: 6.1_

  - [x] 2.3 Implement core active program use cases
    - Create SetActiveProgramUseCase
    - Create UpdateActiveProgramUseCase
    - Create GetCurrentDayUseCase
    - Create CompleteWorkoutDayUseCase
    - Create ClearActiveProgramUseCase
    - _Requirements: 1.2, 7.2, 7.4, 8.1, 8.6_

  - [x] 2.4 Implement program editing use cases
    - Create ReplaceExerciseUseCase with parameter preservation
    - Create ReorderExercisesUseCase with structure preservation
    - Create UpdateExerciseParametersUseCase with validation
    - _Requirements: 3.2, 3.4, 3.5, 11.1, 11.4_

  - [x] 2.5 Write property test for exercise replacement
    - **Property 9: Exercise Replacement Parameter Preservation**
    - **Validates: Requirements 11.4**

  - [x] 2.6 Write property test for exercise reordering
    - **Property 2: Exercise Reordering Preservation**
    - **Validates: Requirements 3.6**

  - [x] 2.7 Implement diet plan use cases
    - Create SaveDietPlanUseCase
    - Create SwapDietMealUseCase
    - _Requirements: 6.1, 15.1_

  - [x] 2.8 Write property test for meal alternative macro similarity
    - **Property 5: Meal Alternative Macro Similarity**
    - **Validates: Requirements 6.7, 15.2**

- [x] 3. Domain layer - Validation
  - [x] 3.1 Create ProgramExerciseValidator
    - Implement validation for sets (positive integers)
    - Implement validation for reps (positive integers or "X-Y" range format)
    - Implement validation for restSeconds (non-negative integers)
    - Create custom exceptions for validation failures
    - _Requirements: 3.8, 16.1, 16.2, 16.3_

  - [x] 3.2 Write property test for exercise parameter validation
    - **Property 3: Exercise Parameter Validation**
    - **Validates: Requirements 3.8, 16.1, 16.2, 16.3**

- [x] 4. Data layer - Models with JSON serialization
  - [x] 4.1 Create ActiveProgramModel with Freezed and json_serializable
    - Implement ActiveProgramModel with fromJson/toJson
    - Implement fromEntity/toEntity converters
    - Handle DateTime serialization as ISO 8601 strings
    - Handle completedDays map serialization (int keys as strings)
    - _Requirements: 10.1, 10.2_

  - [x] 4.2 Create WorkoutProgramModel with Freezed and json_serializable
    - Implement WorkoutProgramModel with fromJson/toJson
    - Implement fromEntity/toEntity converters
    - Create ProgramDayModel with fromJson/toJson
    - Create ProgramExerciseModel with fromJson/toJson
    - _Requirements: 10.1, 10.2_

  - [x] 4.3 Create DietPlanStateModel with Freezed and json_serializable
    - Implement DietPlanStateModel with fromJson/toJson
    - Implement fromEntity/toEntity converters
    - Handle mealSwaps map serialization
    - _Requirements: 6.1, 10.1_

  - [x] 4.4 Write property test for program exercise transformation
    - **Property 6: Program Exercise Transformation**
    - **Validates: Requirements 8.2**

  - [x] 4.5 Run code generation for models
    - Execute `dart run build_runner build --delete-conflicting-outputs`
    - Verify all .freezed.dart and .g.dart files generated
    - _Requirements: 10.1_

- [x] 5. Data layer - Hive storage implementation
  - [x] 5.1 Create HiveActiveProgramDataSource
    - Implement saveActiveProgram method
    - Implement loadActiveProgram method
    - Implement clearActiveProgram method
    - Use box name 'active_program' with key 'current_active_program'
    - _Requirements: 7.2, 10.1, 10.3_

  - [x] 5.2 Create HiveDietPlanDataSource
    - Implement saveDietPlan method
    - Implement loadDietPlan method
    - Implement clearDietPlan method
    - Use box name 'diet_plan' with key 'current_diet_plan'
    - _Requirements: 6.1, 10.1_

  - [x] 5.3 Implement repository implementations
    - Create ActiveProgramRepositoryImpl
    - Create DietPlanRepositoryImpl
    - Add error handling for storage exceptions
    - _Requirements: 7.2, 10.1_

  - [x] 5.4 Write integration tests for storage persistence
    - Test save → load → verify round-trip for ActiveProgram
    - Test save → load → verify round-trip for DietPlanState
    - Test clear operations
    - _Requirements: 10.1, 10.3_

- [x] 6. Checkpoint - Ensure domain and data layers pass tests
  - Ensure all tests pass, ask the user if questions arise.

- [x] 7. State management - Riverpod providers
  - [x] 7.1 Create repository providers
    - Implement activeProgramRepositoryProvider
    - Implement dietPlanRepositoryProvider
    - _Requirements: 7.1, 9.1_

  - [x] 7.2 Create use case providers
    - Implement setActiveProgramUseCaseProvider
    - Implement updateActiveProgramUseCaseProvider
    - Implement getCurrentDayUseCaseProvider
    - Implement completeWorkoutDayUseCaseProvider
    - Implement clearActiveProgramUseCaseProvider
    - Implement replaceExerciseUseCaseProvider
    - Implement reorderExercisesUseCaseProvider
    - Implement updateExerciseParametersUseCaseProvider
    - Implement saveDietPlanUseCaseProvider
    - Implement swapDietMealUseCaseProvider
    - _Requirements: 7.2, 9.2_

  - [x] 7.3 Create ActiveProgramNotifier with StateNotifier
    - Implement state as AsyncValue<ActiveProgram?>
    - Implement _loadActiveProgram method
    - Implement setActiveProgram method
    - Implement updateProgram method
    - Implement clearProgram method
    - Implement getCurrentDay method
    - Implement completeCurrentDay method
    - Implement setCurrentDayIndex method
    - Implement refresh method
    - _Requirements: 7.1, 7.3, 7.4, 7.5, 7.7, 7.8_

  - [x] 7.4 Create activeProgramProvider StateNotifierProvider
    - Wire ActiveProgramNotifier with repository and use case dependencies
    - _Requirements: 7.1, 7.4_

  - [x] 7.5 Create helper providers
    - Implement dietPlanProvider (FutureProvider)
    - Implement currentDayExercisesProvider (Provider)
    - Implement hasActiveProgramProvider (Provider)
    - _Requirements: 7.5, 7.6, 9.3_

- [x] 8. UI components - Video player
  - [x] 8.1 Create ExerciseVideoPlayer widget
    - Use video_player package (NOT url_launcher)
    - Implement video loading with VideoPlayerController.networkUrl
    - Implement autoplay with muted audio (volume = 0)
    - Implement looping playback
    - Display loading indicator while buffering
    - _Requirements: 4.1, 4.2, 4.3, 20.1_

  - [x] 8.2 Add video player controls
    - Implement mute/unmute toggle button
    - Implement tap-to-fullscreen functionality
    - Implement fullscreen exit on tap
    - Display volume icon indicating muted state
    - _Requirements: 4.4, 4.5, 20.2, 20.3, 20.4_

  - [x] 8.3 Add video player error handling
    - Implement error catching for video loading failures
    - Display fallback image when video fails
    - Display "Video unavailable" error message
    - Implement retry logic (1 retry after 2 second delay)
    - Log errors to console
    - _Requirements: 4.6, 14.1, 14.2, 14.3, 14.5, 14.6_

  - [x] 8.4 Write widget tests for video player
    - Test loading state displays CircularProgressIndicator
    - Test error state displays fallback image and message
    - Test mute toggle changes volume
    - Test tap triggers fullscreen navigation
    - _Requirements: 4.1, 4.3, 4.4, 14.2_

- [x] 9. UI components - Program editor
  - [x] 9.1 Create ProgramEditorScreen scaffold
    - Implement AppBar with title and save button
    - Implement day selector with horizontal scrollable chips
    - Handle day selection state
    - _Requirements: 3.1_

  - [x] 9.2 Create ExerciseEditCard widget
    - Display exercise name, sets, reps, rest seconds
    - Add drag handle icon for reordering
    - Implement PopupMenuButton with Replace, Edit, Delete options
    - _Requirements: 3.2_

  - [x] 9.3 Implement drag-drop reordering
    - Use ReorderableListView.builder for exercise list
    - Implement onReorder callback calling reorderExercisesUseCase
    - Refresh activeProgramProvider after reorder
    - _Requirements: 3.5, 3.6_

  - [x] 9.4 Implement replace exercise dialog
    - Show AlertDialog with exercise name input (placeholder for full picker)
    - Call replaceExerciseUseCase with new exercise name
    - Refresh activeProgramProvider after replacement
    - _Requirements: 3.3, 11.1, 11.3, 11.4, 11.5_

  - [x] 9.5 Implement edit parameters dialog
    - Show AlertDialog with TextFields for sets, reps, rest seconds
    - Call updateExerciseParametersUseCase with new values
    - Refresh activeProgramProvider after update
    - _Requirements: 3.4, 16.1, 16.2, 16.3_

  - [x] 9.6 Add validation to edit dialog
    - Validate sets as positive integer
    - Validate reps as positive integer or "X-Y" range
    - Validate rest seconds as non-negative integer
    - Display error messages for invalid inputs
    - Prevent save when validation fails
    - _Requirements: 3.8, 16.1, 16.2, 16.3, 16.4, 16.6_

  - [x] 9.7 Write widget tests for program editor
    - Test day selector switches days correctly
    - Test exercise list displays exercises
    - Test drag-drop triggers reorder
    - Test replace dialog updates exercise
    - Test edit dialog updates parameters
    - Test validation prevents invalid saves
    - _Requirements: 3.1, 3.2, 3.5, 16.4_

- [x] 10. UI screens - Workout screen modifications
  - [x] 10.1 Create empty state for no active program
    - Display "No Active Program" message with icon
    - Add "Generate Program" button navigating to program selection
    - _Requirements: 1.6, 17.4_

  - [x] 10.2 Create active program header
    - Display program name and description
    - Display week completion progress bar
    - Display completion percentage text
    - _Requirements: 17.1, 17.2, 17.3, 19.4, 19.5_

  - [x] 10.3 Create week view with day chips
    - Display horizontal scrollable list of program days
    - Highlight current day with primary color
    - Show checkmark icon on completed days
    - Show rest icon on rest days
    - Handle tap to change current day
    - _Requirements: 9.1, 9.2, 9.3, 9.5, 19.1_

  - [x] 10.4 Create current day content display
    - Display day name and focus
    - Show rest day message and icon for rest days
    - Display exercise list using ProgramExerciseCard
    - Add "Start Workout" button (disabled on rest days)
    - Navigate to active workout screen on button tap
    - _Requirements: 8.1, 8.3, 9.6_

  - [x] 10.5 Create ProgramExerciseCard widget
    - Display exercise name as title
    - Display sets, reps, rest seconds as info chips with icons
    - Display optional notes in italic gray text
    - _Requirements: 8.3_

  - [x] 10.6 Add program editor navigation
    - Add edit icon button to AppBar
    - Navigate to /workout/editor on tap
    - _Requirements: 3.1_

  - [x] 10.7 Write widget tests for workout screen
    - Test empty state displays when no active program
    - Test active program header displays program info
    - Test week view displays all days correctly
    - Test current day highlights correctly
    - Test rest day displays rest message
    - Test workout day displays exercises
    - _Requirements: 1.6, 8.1, 9.1, 9.5, 17.1_

- [x] 11. UI screens - Nutrition screen modifications
  - [x] 11.1 Create default targets display
    - Display "Daily Targets" header
    - Show default values: 2000 kcal, 150g protein, 200g carbs, 60g fats
    - Add "Generate Diet Plan" button
    - _Requirements: 18.5_

  - [x] 11.2 Create diet plan targets display
    - Display diet plan name with edit button
    - Show daily calories and macro targets from diet plan
    - Use macro target widget with value and unit
    - _Requirements: 6.2, 18.1, 18.2, 18.6_

  - [x] 11.3 Modify daily summary to use diet plan provider
    - Watch dietPlanProvider for targets
    - Fall back to default targets if no diet plan
    - Display macro wheel chart with current totals
    - _Requirements: 6.3, 18.3_

  - [x] 11.4 Create remaining macros display
    - Calculate remaining = target - consumed for each macro
    - Display linear progress bars for protein, carbs, fats
    - Change color to red when remaining is negative
    - Update within 200ms of meal changes
    - _Requirements: 6.6, 12.3, 12.4, 18.4_

  - [x] 11.5 Add meal swap functionality (placeholder)
    - Add "Swap Meal" option to meal cards
    - Show dialog with alternative meal selection (placeholder)
    - Call swapDietMealUseCase when alternative selected
    - Recalculate daily totals after swap
    - _Requirements: 6.5, 15.1, 15.3, 15.5_

  - [x] 11.6 Write property test for meal quantity macro scaling
    - **Property 4: Meal Quantity Macro Scaling**
    - **Validates: Requirements 6.6**

  - [x] 11.7 Write widget tests for nutrition screen
    - Test default targets display when no diet plan
    - Test diet plan targets display when plan exists
    - Test remaining macros update correctly
    - Test remaining macros turn red when negative
    - _Requirements: 6.2, 6.3, 12.3, 18.5_

- [x] 12. Navigation and routing updates
  - [x] 12.1 Add new routes to go_router
    - Add /workout/editor route for ProgramEditorScreen
    - Add /workout/program-selection route for ProgramSelectionScreen (placeholder)
    - Update existing routes as needed
    - _Requirements: 3.1, 13.4_

  - [x] 12.2 Write integration test for navigation
    - Test navigation from workout screen to editor
    - Test navigation from empty state to program selection
    - _Requirements: 3.1, 13.4_

- [x] 13. Onboarding integration
  - [x] 13.1 Modify OnboardingScreen completion flow
    - After saving user profile, show loading dialog
    - Call generateWorkoutProgramUseCase with profile
    - Call activeProgramProvider.setActiveProgram with generated program
    - Call generateDietPlanUseCase with profile
    - Call saveDietPlanUseCase with generated diet plan
    - Close loading dialog on completion
    - Navigate to /workout on success
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 6.1_

  - [x] 13.2 Add error handling to onboarding completion
    - Catch exceptions during program generation
    - Display error SnackBar with error message
    - Close loading dialog on error
    - _Requirements: 5.5_

  - [x] 13.3 Write integration test for onboarding flow
    - Test complete onboarding → generate program → save active program → navigate to workout
    - Test complete onboarding → generate diet plan → save diet plan
    - Test error handling displays SnackBar
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 14. Active workout screen integration
  - [x] 14.1 Modify ActiveWorkoutScreen to use active program
    - Load exercises from currentDayExercisesProvider instead of fallback
    - Display program exercise parameters (sets, reps, rest) as suggestions
    - Highlight when user completes suggested sets
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [x] 14.2 Add workout completion logic
    - When user finishes workout, call completeWorkoutDayUseCase
    - Update last_workout_date in active program
    - Mark current day as complete in completedDays map
    - Advance to next workout day (skipping rest days)
    - _Requirements: 8.6, 8.7, 10.5, 19.2, 19.3_

  - [x] 14.3 Write integration test for workout session
    - Test start workout → load exercises from active program → log sets → complete workout → verify day advancement
    - _Requirements: 8.1, 8.2, 8.6_

- [x] 15. Program completion and regeneration
  - [x] 15.1 Add program completion detection
    - Detect when user completes final day of program
    - Display "Program Complete" dialog with options
    - Offer "Restart Program" and "Generate New Program" buttons
    - _Requirements: 13.1, 13.2_

  - [x] 15.2 Implement restart program functionality
    - Reset current_day_index to 0
    - Clear completedDays map
    - Keep same program
    - _Requirements: 13.7_

  - [x] 15.3 Implement generate new program functionality
    - Navigate to program selection screen
    - Allow user to choose new split type
    - Generate new program with selected split
    - Replace active program with new program
    - Reset current_day_index to 0
    - _Requirements: 13.3, 13.4, 13.5, 13.6, 13.7_

- [ ] 16. Program selection screen (placeholder)
  - [x] 16.1 Create ProgramSelectionScreen scaffold
    - Display three split type options: Full Body, Upper-Lower, Push-Pull-Legs
    - Show descriptions and day counts for each split
    - Add selection buttons for each split
    - _Requirements: 2.1, 2.2_

  - [x] 16.2 Implement split selection logic
    - Call generateWorkoutProgramUseCase with selected split
    - Call activeProgramProvider.setActiveProgram with generated program
    - Navigate back to workout screen
    - _Requirements: 2.3, 2.4, 2.5, 2.6_

  - [x] 16.3 Write property test for program generation structure
    - **Property 1: Program Generation Structure Matching**
    - **Validates: Requirements 2.3**

- [ ] 17. Error handling and validation
  - [x] 17.1 Create custom exception classes
    - Create ActiveProgramException
    - Create ProgramValidationException
    - Create DietPlanException
    - _Requirements: Error handling_

  - [x] 17.2 Add error handling to repositories
    - Catch storage exceptions in ActiveProgramRepositoryImpl
    - Catch storage exceptions in DietPlanRepositoryImpl
    - Wrap in domain exceptions with user-friendly messages
    - _Requirements: Error handling_

  - [x] 17.3 Add error handling to UI screens
    - Display SnackBar for storage errors
    - Display inline errors for validation failures
    - Prevent invalid data from being saved
    - _Requirements: 16.4, 16.6_

- [x] 18. Checkpoint - Ensure all integration tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 19. Exercise picker with muscle group filtering (future enhancement)
  - [ ] 19.1 Create exercise database with muscle group tags
    - Define exercise list with primary muscle groups
    - Store in local JSON or Hive
    - _Requirements: 11.2_

  - [ ] 19.2 Create ExercisePickerScreen
    - Display searchable exercise list
    - Filter by muscle group parameter
    - Return selected exercise name
    - _Requirements: 3.3, 11.2_

  - [ ] 19.3 Write property test for muscle group filtering
    - **Property 8: Exercise Picker Muscle Group Filtering**
    - **Validates: Requirements 11.2**

  - [ ] 19.4 Integrate exercise picker into program editor
    - Replace text input dialog with ExercisePickerScreen navigation
    - Pass current exercise muscle group as filter
    - Use returned exercise name for replacement
    - _Requirements: 3.3, 11.2, 11.3_

- [ ] 20. Meal alternative suggestions (future enhancement)
  - [ ] 20.1 Create meal database with macro profiles
    - Define meal list with calories, protein, carbs, fats
    - Store in local JSON or Hive
    - _Requirements: 15.2_

  - [ ] 20.2 Implement meal alternative filtering logic
    - Filter meals within 10% macro tolerance
    - Return at least 3 alternatives if available
    - _Requirements: 15.2, 15.3_

  - [ ] 20.3 Create MealAlternativesScreen
    - Display alternative meal cards with macro breakdown
    - Show macro comparison to original meal
    - Return selected alternative
    - _Requirements: 15.1, 15.4_

  - [ ] 20.4 Integrate meal alternatives into nutrition screen
    - Replace placeholder swap dialog with MealAlternativesScreen navigation
    - Pass original meal for filtering
    - Use returned meal for swap
    - _Requirements: 15.1, 15.4, 15.5_

- [x] 21. Final integration and polish
  - [x] 21.1 Verify active program persistence
    - Test app restart loads active program correctly
    - Test current day index persists
    - Test completed days persist
    - _Requirements: 10.1, 10.3, 10.4, 10.6_

  - [x] 21.2 Verify diet plan persistence
    - Test app restart loads diet plan correctly
    - Test meal swaps persist
    - _Requirements: 6.1, 15.6_

  - [x] 21.3 Verify video player functionality
    - Test autoplay muted on load
    - Test fullscreen toggle
    - Test error fallback
    - Test retry logic
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 14.1, 14.4, 14.6_

  - [x] 21.4 Verify macro wheel updates within 200ms
    - Test meal logging triggers macro wheel update
    - Test meal deletion triggers macro wheel update
    - Test meal swap triggers macro wheel update
    - Measure update latency
    - _Requirements: 6.6, 12.3, 12.4, 12.5_

  - [x] 21.5 Verify program editor validation
    - Test invalid sets rejected
    - Test invalid reps rejected
    - Test invalid rest seconds rejected
    - Test error messages displayed
    - Test save prevented when invalid
    - _Requirements: 16.1, 16.2, 16.3, 16.4, 16.5, 16.6_

  - [x] 21.6 Code cleanup and documentation
    - Add code comments for complex logic
    - Ensure all public APIs have documentation
    - Remove debug code and console logs
    - _Requirements: Code quality_

- [x] 22. Final checkpoint - Ensure all tests pass
  - Run full test suite (property tests, unit tests, integration tests, widget tests)
  - Verify all critical user flows work end-to-end
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional testing tasks and can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- Property-based tests validate universal correctness properties across all valid inputs
- Unit tests validate specific examples and edge cases
- Integration tests validate workflows, storage, and navigation
- Widget tests validate UI components and screens
- The implementation follows Clean Architecture with strict layer separation
- All features work offline-first using Hive local storage
- Riverpod is used for state management with immutable Freezed data classes
- The video player uses video_player package exclusively (NOT url_launcher)
- Exercise picker and meal alternatives are marked as future enhancements (tasks 19-20)
- Core functionality (tasks 1-18) provides complete integration of existing systems
