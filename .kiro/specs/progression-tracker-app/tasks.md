# Implementation Plan: Progression Tracker Fitness App

## Overview

This implementation plan breaks down the Progression Tracker fitness app into discrete coding tasks following Clean Architecture principles. The app will be built with Flutter using Riverpod for state management, Hive for offline storage, and a comprehensive testing strategy including 24 property-based tests.

The implementation follows a bottom-up approach: Core infrastructure → Domain layer → Data layer → Presentation layer → Integration and testing.

## Tasks

- [x] 1. Project setup and infrastructure
  - Initialize Flutter project with required dependencies
  - Set up folder structure following Clean Architecture (core, shared, features)
  - Configure build_runner for code generation (freezed, json_serializable)
  - Create core constants, theme configuration, and custom exception classes
  - _Requirements: 8.1, 8.6, 13.1, 13.3_

- [x] 2. Core layer implementation
  - [x] 2.1 Create custom exception classes
    - Implement AppException base class
    - Create domain exceptions (InvalidRepsException, InvalidWeightException, InvalidRPEException, InvalidMacroException, EntityNotFoundException)
    - Create data exceptions (StorageException, SerializationException)
    - _Requirements: 15.4_

  - [x] 2.2 Implement theme system
    - Create dark theme with neon accent colors
    - Define glassmorphism card styles with transparency and blur
    - Configure rounded corners (16-24px radius) for buttons and cards
    - _Requirements: 13.1, 13.2, 13.3_

  - [x] 2.3 Create utility classes and extensions
    - UUID generation utilities
    - Date formatting helpers
    - Validation utilities
    - _Requirements: 7.5_

- [x] 3. Workout module - Domain layer
  - [x] 3.1 Create domain entities with Freezed
    - Implement Workout entity (id, date, exercises, duration, totalVolume)
    - Implement Exercise entity (id, name, type, sets)
    - Implement SetEntry entity with validation (id, reps, weight, rpe, timestamp)
    - Implement ExerciseType enum
    - _Requirements: 18.1, 18.2, 18.3, 18.6_

  - [x] 3.2 Write property test for domain entities
    - **Property 1: Entity Creation Completeness**
    - **Validates: Requirements 1.1**

  - [x] 3.3 Write unit tests for SetEntry validation
    - Test InvalidWeightException for negative weight
    - Test InvalidRepsException for zero/negative reps
    - Test InvalidRPEException for RPE outside 1-10 range
    - Test valid set entry creation
    - _Requirements: 18.6_

  - [x] 3.4 Define repository interfaces
    - Create WorkoutRepository interface with methods: saveWorkout, getAllWorkouts, getWorkoutsByDateRange, getExerciseHistory, deleteWorkout
    - _Requirements: 8.2_

  - [x] 3.5 Implement workout use cases
    - Create StartWorkoutUseCase
    - Create AddExerciseToWorkoutUseCase
    - Create LogSetUseCase
    - Create CalculateWorkoutVolumeUseCase
    - Create SaveWorkoutUseCase
    - Create GetWorkoutHistoryUseCase
    - _Requirements: 1.1, 1.2, 1.3, 1.5, 4.1, 4.5, 8.3_

  - [x] 3.6 Write property test for exercise addition
    - **Property 2: Exercise Addition Preservation**
    - **Validates: Requirements 1.2**

  - [x] 3.7 Write property test for set logging
    - **Property 3: Set Logging Preservation**
    - **Validates: Requirements 1.3**

  - [x] 3.8 Write property test for volume calculation
    - **Property 9: Training Volume Calculation**
    - **Validates: Requirements 4.5**

  - [x] 3.9 Implement progression engine entities and use cases
    - Create ProgressionSuggestion entity (suggestedWeight, suggestedReps, isStagnant, message)
    - Implement GetProgressionSuggestionUseCase with stagnation detection logic
    - Implement DetectPersonalRecordUseCase
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [x] 3.10 Write property test for progression suggestions
    - **Property 6: Progression Suggestion Calculation**
    - **Validates: Requirements 2.2, 2.3**

  - [x] 3.11 Write unit tests for PR detection
    - Test PR detection when new volume exceeds previous best
    - Test no PR when volume equals previous best
    - Test first-time exercise as PR
    - _Requirements: 2.4_

- [x] 4. Workout module - Data layer
  - [x] 4.1 Create data models with JSON serialization
    - Implement WorkoutModel with fromJson/toJson and fromEntity/toEntity converters
    - Implement ExerciseModel with fromJson/toJson and fromEntity/toEntity converters
    - Implement SetEntryModel with fromJson/toJson and fromEntity/toEntity converters
    - _Requirements: 14.1, 14.2, 14.3_

  - [x] 4.2 Write property test for JSON serialization
    - **Property 15: JSON Serialization Completeness**
    - **Validates: Requirements 14.3**

  - [x] 4.3 Write property test for JSON deserialization error handling
    - **Property 16: JSON Deserialization Error Handling**
    - **Validates: Requirements 14.4**

  - [x] 4.4 Write property test for serialization round-trip
    - **Property 17: Serialization Round-Trip**
    - **Validates: Requirements 14.5**

  - [x] 4.5 Implement Hive data source
    - Create HiveWorkoutDataSource with saveWorkout, getAllWorkouts, deleteWorkout methods
    - Initialize Hive box for workouts
    - _Requirements: 7.1, 7.2_

  - [x] 4.6 Implement repository with resilience
    - Create WorkoutRepositoryImpl implementing WorkoutRepository
    - Implement ResilientWorkoutRepository with retry logic (max 1 retry)
    - Implement getExerciseHistory with filtering and limiting
    - Implement getWorkoutsByDateRange with date filtering
    - _Requirements: 7.4, 8.5, 15.2_

  - [x] 4.7 Write property test for workout persistence
    - **Property 4: Workout Persistence Round-Trip**
    - **Validates: Requirements 1.5, 17.6**

  - [x] 4.8 Write property test for exercise history retrieval
    - **Property 5: Exercise History Retrieval Limit**
    - **Validates: Requirements 2.1**

  - [x] 4.9 Write property test for workout history sorting
    - **Property 8: Workout History Sorting**
    - **Validates: Requirements 4.1**

  - [x] 4.10 Write integration tests for storage resilience
    - Test retry once on storage failure
    - Test StorageException after max retries
    - _Requirements: 15.2_

- [x] 5. Checkpoint - Ensure workout module tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Body module - Domain layer
  - [x] 6.1 Create domain entities
    - Implement BodyEntry entity (id, date, weight, measurements, photoPath)
    - Implement MeasurementType enum (chest, waist, hips, arms, legs)
    - Implement WeightDataPoint entity (date, weight)
    - Add validation for positive weight values
    - _Requirements: 18.5, 18.6_

  - [x] 6.2 Define repository interface
    - Create BodyRepository interface with methods: saveBodyEntry, getAllBodyEntries, getBodyEntriesByDateRange, deleteBodyEntry
    - _Requirements: 8.2_

  - [x] 6.3 Implement body tracking use cases
    - Create SaveBodyEntryUseCase
    - Create GetBodyHistoryUseCase
    - Create GetWeightTrendUseCase
    - _Requirements: 5.1, 5.4_

  - [x] 6.4 Write property test for body measurement persistence
    - **Property 10: Body Measurement Persistence**
    - **Validates: Requirements 5.2**

- [x] 7. Body module - Data layer
  - [x] 7.1 Create data models with JSON serialization
    - Implement BodyEntryModel with fromJson/toJson and fromEntity/toEntity converters
    - Handle measurements map serialization
    - Handle optional photoPath field
    - _Requirements: 14.1, 14.2_

  - [x] 7.2 Implement Hive data source
    - Create HiveBodyDataSource with saveBodyEntry, getAllBodyEntries, deleteBodyEntry methods
    - Initialize Hive box for body entries
    - _Requirements: 7.1, 7.2_

  - [x] 7.3 Implement repository
    - Create BodyRepositoryImpl implementing BodyRepository
    - Implement getBodyEntriesByDateRange with date filtering
    - _Requirements: 7.4, 8.5_

- [x] 8. Nutrition module - Domain layer
  - [x] 8.1 Create domain entities
    - Implement Meal entity (id, name, calories, protein, carbs, fats, timestamp)
    - Implement MacroTarget entity (protein, carbs, fats) with totalCalories getter
    - Implement DailyNutritionSummary entity with calculated totals and remaining macros
    - Implement MealSuggestion entity (name, protein, carbs, fats, category)
    - Implement MealCategory enum (highProtein, highCarb, balanced)
    - Add validation for non-negative macro values
    - _Requirements: 18.4, 18.7, 6.1_

  - [x] 8.2 Write property test for validation enforcement
    - **Property 21: Validation Enforcement**
    - **Validates: Requirements 18.6, 18.7**

  - [x] 8.3 Write property test for macro estimation consistency
    - **Property 12: Macro Estimation Consistency**
    - **Validates: Requirements 6.2**

  - [x] 8.4 Define repository interface
    - Create NutritionRepository interface with methods: saveMeal, getMealsByDate, getMealsByDateRange, deleteMeal, saveMacroTarget, getMacroTarget
    - _Requirements: 8.2_

  - [x] 8.5 Implement nutrition use cases
    - Create SaveMealUseCase
    - Create GetDailyNutritionSummaryUseCase with totals calculation
    - Create GetMealSuggestionsUseCase with rule-based suggestions
    - _Requirements: 6.1, 6.4, 20.1, 20.2, 20.3_

  - [x] 8.6 Write property test for daily nutrition totals
    - **Property 11: Daily Nutrition Totals Calculation**
    - **Validates: Requirements 6.4**

  - [x] 8.7 Write property test for remaining macro calculation
    - **Property 22: Remaining Macro Calculation**
    - **Validates: Requirements 20.1**

  - [x] 8.8 Write property test for meal suggestion budget compliance
    - **Property 23: Meal Suggestion Budget Compliance**
    - **Validates: Requirements 20.2**

  - [x] 8.9 Write property test for meal suggestion categorization
    - **Property 24: Meal Suggestion Categorization**
    - **Validates: Requirements 20.3**

- [x] 9. Nutrition module - Data layer
  - [x] 9.1 Create data models with JSON serialization
    - Implement MealModel with fromJson/toJson and fromEntity/toEntity converters
    - Implement MacroTargetModel with fromJson/toJson and fromEntity/toEntity converters
    - _Requirements: 14.1, 14.2_

  - [x] 9.2 Implement Hive data source
    - Create HiveNutritionDataSource with saveMeal, getMealsByDate, deleteMeal, saveMacroTarget, getMacroTarget methods
    - Initialize Hive boxes for meals and macro targets
    - _Requirements: 7.1, 7.2_

  - [x] 9.3 Implement repository
    - Create NutritionRepositoryImpl implementing NutritionRepository
    - Implement getMealsByDate with date filtering
    - Implement getMealsByDateRange with date range filtering
    - _Requirements: 7.4, 8.5_

- [x] 10. Checkpoint - Ensure all domain and data layers pass tests
  - Ensure all tests pass, ask the user if questions arise.

- [x] 11. State management - Riverpod providers
  - [x] 11.1 Create workout providers
    - Implement workoutRepositoryProvider
    - Implement use case providers (startWorkout, saveWorkout, calculateVolume, progressionSuggestion, detectPR)
    - Create WorkoutState with Freezed (initial, inProgress, completed)
    - Implement WorkoutNotifier with start, addExercise, logSet, finish, reset methods
    - Implement workoutNotifierProvider
    - Implement workoutHistoryProvider (FutureProvider)
    - Implement progressionSuggestionProvider (FutureProvider.family)
    - _Requirements: 9.1, 9.2, 9.3, 17.1, 17.2, 17.3, 17.4, 17.5_

  - [x] 11.2 Create rest timer state
    - Create RestTimerState with Freezed (idle, running, completed)
    - Implement RestTimerNotifier with start, skip, extend methods
    - Use Timer.periodic with 100ms updates
    - Implement restTimerProvider
    - _Requirements: 3.1, 3.2, 3.4, 3.5_

  - [x] 11.3 Write property test for rest timer state transitions
    - **Property 7: Rest Timer State Transitions**
    - **Validates: Requirements 3.4**

  - [x] 11.4 Create body tracking providers
    - Implement bodyRepositoryProvider
    - Implement bodyHistoryProvider (FutureProvider)
    - Implement weightTrendProvider (FutureProvider.family with DateRange)
    - _Requirements: 9.1, 9.2, 9.3_

  - [x] 11.5 Create nutrition providers
    - Implement nutritionRepositoryProvider
    - Implement dailyNutritionSummaryProvider (FutureProvider.family with DateTime)
    - Implement mealSuggestionsProvider (FutureProvider.family with MacroTarget)
    - _Requirements: 9.1, 9.2, 9.3_

- [x] 12. Shared animation components
  - [x] 12.1 Create set completion animation
    - Implement SetCompletionAnimation widget with flutter_animate
    - Use scale and fadeOut animations (200ms + 300ms delay)
    - Trigger onComplete callback
    - _Requirements: 1.4, 10.2, 10.3, 10.6_

  - [x] 12.2 Create PR celebration animation
    - Implement PRCelebrationAnimation widget with Lottie
    - Load celebration.json asset
    - Display within 200ms of PR detection
    - _Requirements: 2.4, 10.6_

  - [x] 12.3 Create rest timer circular animation
    - Implement RestTimerCircular widget consuming restTimerProvider
    - Display CircularProgressIndicator with progress value
    - Show remaining seconds text
    - Update color based on progress (green > 50%, orange ≤ 50%)
    - _Requirements: 3.2, 10.2_

  - [x] 12.4 Create workout summary card
    - Implement WorkoutSummaryCard widget with animated container
    - Display total sets, volume, duration, and PR count
    - Use fadeIn and scale animations (300ms)
    - _Requirements: 4.4, 10.2, 10.6_

  - [x] 12.5 Create macro wheel chart
    - Implement MacroWheelChart widget using fl_chart PieChart
    - Display protein, carbs, fats distribution with percentages
    - Use scale and fadeIn animations (300ms)
    - _Requirements: 6.3, 13.6_

  - [x] 12.6 Create weight trend graph
    - Implement WeightTrendGraph widget using fl_chart LineChart
    - Display curved line with dots and below-bar gradient
    - Use fadeIn and slideY animations (300-400ms)
    - _Requirements: 5.4, 5.6, 13.6_

  - [x] 12.7 Create swipeable meal cards
    - Implement SwipeableMealCards widget with ListView.builder and Dismissible
    - Implement MealCard widget with glassmorphism styling
    - Add staggered fadeIn and slideX animations (50ms delay per item)
    - _Requirements: 6.6, 10.2_

- [x] 13. Navigation and routing
  - [x] 13.1 Configure go_router
    - Create routerProvider with GoRouter configuration
    - Define routes: /home, /workout, /workout/active, /workout/history, /workout/exercise/:name, /progress, /nutrition, /profile
    - Set initialLocation to /home
    - _Requirements: 12.1, 12.5_

  - [x] 13.2 Create main app with bottom navigation
    - Implement MainApp widget with MaterialApp.router
    - Create MainScaffold with BottomNavigationBar (5 tabs)
    - Handle tab selection and navigation
    - _Requirements: 12.2, 12.3_

  - [x] 13.3 Write property test for navigation state preservation
    - **Property 14: Navigation State Preservation**
    - **Validates: Requirements 12.4**

- [x] 14. Workout module - Presentation layer
  - [x] 14.1 Create home screen
    - Implement HomeScreen with "Start Workout" button
    - Display recent workout summary
    - Navigate to workout screen on button tap
    - _Requirements: 17.1_

  - [x] 14.2 Create exercise selection screen
    - Implement ExerciseSelectionScreen with searchable exercise list
    - Use debounced search field (300ms debounce)
    - Display exercise cards with tap handlers
    - _Requirements: 17.2, 16.5_

  - [x] 14.3 Write property test for input debouncing
    - **Property 20: Input Debouncing**
    - **Validates: Requirements 16.5**

  - [x] 14.4 Create active workout screen
    - Implement ActiveWorkoutScreen consuming workoutNotifierProvider
    - Display exercise cards with previous performance
    - Show progression suggestions using progressionSuggestionProvider
    - Add input fields for reps and weight
    - Implement "Log Set" button with <100ms feedback
    - Trigger SetCompletionAnimation on set completion
    - Auto-start rest timer after set
    - Display RestTimerCircular widget
    - Enable "Finish Workout" button when sets completed
    - _Requirements: 17.2, 17.3, 17.4, 11.2_

  - [x] 14.5 Create workout summary screen
    - Implement WorkoutSummaryScreen with WorkoutSummaryCard
    - Display PRCelebrationAnimation if PRs achieved
    - Auto-navigate to home after 3 seconds or user tap
    - _Requirements: 17.5, 17.8_

  - [x] 14.6 Create workout history screen
    - Implement WorkoutHistoryScreen consuming workoutHistoryProvider
    - Use ListView.builder for lazy loading
    - Display workout list items with date, volume, duration
    - _Requirements: 4.1, 16.1_

  - [x] 14.7 Create exercise detail screen
    - Implement ExerciseDetailScreen with performance graph
    - Display weight and reps progression over time
    - Use animated graph transitions
    - _Requirements: 4.2, 4.3_

  - [x] 14.8 Implement workout state persistence
    - Create WorkoutStateManager for saving/restoring active workout state
    - Save state after each set to prevent data loss
    - Restore state on app launch
    - Clear state after workout completion
    - _Requirements: 17.6_

- [x] 15. Body module - Presentation layer
  - [x] 15.1 Create progress screen
    - Implement ProgressScreen with tabs for weight and measurements
    - Display WeightTrendGraph consuming weightTrendProvider
    - Add "Log Weight" button with input dialog
    - Add "Log Measurements" button with input form
    - _Requirements: 5.1, 5.2, 5.4_

  - [x] 15.2 Create progress photo comparison
    - Implement before-after comparison slider with swipe gesture
    - Display progress photos with date metadata
    - _Requirements: 5.3, 5.5_

- [x] 16. Nutrition module - Presentation layer
  - [x] 16.1 Create nutrition screen
    - Implement NutritionScreen consuming dailyNutritionSummaryProvider
    - Display MacroWheelChart with current day totals
    - Show remaining macros
    - Display SwipeableMealCards with logged meals
    - Add "Log Meal" button with input form
    - Update macro wheel within 200ms of meal changes
    - _Requirements: 6.1, 6.3, 6.5, 6.6_

  - [x] 16.2 Create meal suggestions view
    - Implement MealSuggestionsView consuming mealSuggestionsProvider
    - Display swipeable suggestion cards with macro breakdown
    - Filter suggestions based on remaining macro budget
    - _Requirements: 20.1, 20.2, 20.3, 20.4, 20.5_

- [x] 17. Performance optimization implementation
  - [x] 17.1 Implement lazy loading for workout history
    - Optimize ListView.builder to handle 1000+ workouts
    - Use const widgets where possible
    - _Requirements: 16.1, 11.3_

  - [x] 17.2 Implement chart data sampling
    - Create ChartDataSampler utility class
    - Sample data points to max 100 when displaying graphs
    - Use in WeightTrendGraph and exercise performance graphs
    - _Requirements: 16.2_

  - [x] 17.3 Write property test for chart data sampling
    - **Property 18: Chart Data Sampling Distribution**
    - **Validates: Requirements 16.2**

  - [x] 17.3 Implement computation caching
    - Create CachedVolumeCalculator for workout volume
    - Cache macro totals in nutrition summary
    - Implement cache invalidation on data changes
    - _Requirements: 16.4_

  - [x] 17.4 Write property test for computation caching
    - **Property 19: Computation Caching Consistency**
    - **Validates: Requirements 16.4**

  - [x] 17.5 Optimize animation performance
    - Ensure all animations maintain 60 FPS
    - Use lightweight animations (flutter_animate)
    - Test on mid-range devices
    - _Requirements: 16.3_

- [x] 18. Error handling implementation
  - [x] 18.1 Create error handler utility
    - Implement ErrorHandler class with handleError method
    - Map exceptions to user-friendly messages
    - Display error dialogs with appropriate actions
    - _Requirements: 15.1, 15.3_

  - [x] 18.2 Add error handling to all screens
    - Wrap async operations in try-catch blocks
    - Call ErrorHandler.handleError on exceptions
    - Display error feedback within 200ms
    - _Requirements: 15.1_

- [x] 19. Checkpoint - Ensure all presentation layer tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 20. Integration testing
  - [x] 20.1 Write workout flow integration test
    - Test complete workout flow: start → add exercise → log set → finish
    - Verify set completion animation appears
    - Verify rest timer starts and can be skipped
    - Verify workout summary displays
    - _Requirements: 17.1, 17.2, 17.3, 17.4, 17.5_

  - [x] 20.2 Write navigation integration test
    - Test tab switching preserves state
    - Test deep linking to specific screens
    - _Requirements: 12.3, 12.4, 12.5_

  - [x] 20.3 Write performance integration test
    - Test visual feedback appears within 100ms
    - Test handling 1000+ workouts with lazy loading
    - _Requirements: 11.2, 16.1_

  - [x] 20.4 Write storage integration test
    - Test retry logic on storage failure
    - Test StorageException after max retries
    - _Requirements: 15.2_

- [x] 21. Widget testing
  - [x] 21.1 Write animation component widget tests
    - Test RestTimerCircular displays countdown
    - Test MacroWheelChart renders with correct proportions
    - Test SetCompletionAnimation triggers onComplete callback
    - _Requirements: 10.2, 10.3_

  - [x] 21.2 Write screen widget tests
    - Test HomeScreen renders and navigates correctly
    - Test ActiveWorkoutScreen displays exercise cards
    - Test NutritionScreen displays macro wheel
    - _Requirements: 11.1, 11.2_

- [x] 22. Property-based test arbitraries
  - [x] 22.1 Create custom arbitraries for domain entities
    - Implement exerciseArbitrary generator
    - Implement setEntryArbitrary generator
    - Implement workoutArbitrary generator
    - Implement bodyEntryArbitrary generator
    - Implement mealArbitrary generator
    - _Requirements: Testing infrastructure_

  - [x] 22.2 Write property test for UUID uniqueness
    - **Property 13: UUID Generation Uniqueness**
    - **Validates: Requirements 7.5**

- [x] 23. Final integration and polish
  - [x] 23.1 Add Lottie celebration animation asset
    - Create or download celebration.json Lottie file
    - Add to assets folder and update pubspec.yaml
    - _Requirements: 10.6_

  - [x] 23.2 Verify all performance requirements
    - Test <100ms visual feedback for all actions
    - Test 60 FPS animations on mid-range devices
    - Test max 3 taps per primary action
    - _Requirements: 11.1, 11.2, 16.3_

  - [x] 23.3 Verify offline-first functionality
    - Test app launches without network
    - Test all features work without network
    - Test data persists across app restarts
    - _Requirements: 7.1, 7.2, 7.3_

  - [x] 23.4 Code cleanup and documentation
    - Add code comments for complex logic
    - Ensure all public APIs have documentation
    - Remove debug code and console logs
    - _Requirements: 8.1_

- [x] 24. Final checkpoint - Ensure all tests pass
  - Run full test suite (property tests, unit tests, integration tests, widget tests)
  - Verify 80%+ code coverage
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional testing tasks and can be skipped for faster MVP delivery
- Each task references specific requirements for traceability
- Property-based tests validate universal correctness properties across all valid inputs
- Unit tests validate specific examples and edge cases
- Integration tests validate workflows, storage, and performance
- Widget tests validate UI components and animations
- The implementation follows Clean Architecture with strict layer separation
- All features work offline-first using Hive local storage
- Riverpod is used for state management with immutable Freezed data classes
- Performance targets: <100ms feedback, 60 FPS animations, max 3 taps per action
