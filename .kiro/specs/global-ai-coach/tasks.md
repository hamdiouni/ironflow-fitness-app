# Implementation Plan: Global AI Coach

## Overview

This implementation plan breaks down the Global AI Coach feature into actionable coding tasks following the 6-phase approach from the design document. The feature transforms the AI module from chat-only to a comprehensive coaching system that provides data-driven insights across all main screens (Home, Workout, Nutrition, Profile).

**Key Implementation Principles:**
- Build incrementally from domain layer to UI
- Test each component before moving to the next
- Leverage existing Flutter/Riverpod architecture
- Maintain local-first processing for privacy
- Implement multi-layer caching for performance

## Tasks

### Phase 1: Foundation (Domain Layer)

- [x] 1. Create domain entities and enums
  - Create `lib/features/ai/domain/entities/insight.dart` with Insight entity using freezed
  - Create `lib/features/ai/domain/entities/insight_cache.dart` with InsightCache entity
  - Create `lib/features/ai/domain/entities/insight_generation_context.dart`
  - Define InsightContext enum (home, workout, nutrition, profile)
  - Define InsightPriority enum (high, medium, low)
  - _Requirements: 1.1, 1.4, 3.1, 3.3_

- [x] 1.1 Write unit tests for domain entities
  - Test Insight entity serialization/deserialization
  - Test InsightCache entity with various data
  - Test enum conversions
  - _Requirements: 1.1, 3.1_

- [x] 2. Define service interfaces
  - Create `lib/features/ai/domain/services/ai_insights_engine.dart` interface
  - Create `lib/features/ai/domain/services/insight_cache_service.dart` interface
  - Create `lib/features/ai/domain/services/change_detection_service.dart` interface
  - Define all method signatures with documentation
  - _Requirements: 1.1, 3.2, 4.4, 11.2_

- [x] 3. Implement AIInsightsEngine core logic
  - [x] 3.1 Create AIInsightsEngineImpl class
    - Implement generateInsights method with context-specific logic
    - Implement data fetching from workout, nutrition, and body repositories
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 14.1, 14.2, 14.3, 14.4_

  - [x] 3.2 Implement workout analysis methods
    - Implement calculateVolume (sum of reps × weight)
    - Implement detectProgressiveOverload (compare first half vs second half volume)
    - Implement detectPR (compare current vs historical max)
    - Implement muscle group balance analysis
    - _Requirements: 1.6, 1.7, 1.8, 7.2, 7.3, 7.4, 7.5_

  - [x] 3.3 Implement nutrition analysis methods
    - Implement calculateProteinDeficit (target - actual)
    - Implement macro adherence calculation
    - Implement calorie tracking accuracy analysis
    - _Requirements: 2.3, 2.4, 2.5, 8.2, 8.3, 8.4, 8.6_

  - [x] 3.4 Implement body metrics analysis methods
    - Implement analyzeWeightTrend (30-day trend analysis)
    - Implement goal alignment checking
    - _Requirements: 9.2, 9.5, 9.6, 9.7_

  - [x] 3.5 Implement insight prioritization and formatting
    - Implement insight selection logic (2-3 most important)
    - Implement formatting with specific numbers and action plans
    - Implement insight rotation for equal priority items
    - _Requirements: 2.1, 2.2, 2.6, 2.7, 14.6, 14.7, 14.8_

  - [x] 3.6 Implement generateQuickFeedback method
    - Detect PR achievements
    - Detect volume records (10%+ increase)
    - Detect consistency milestones
    - Format celebratory feedback
    - _Requirements: 10.3, 10.4, 10.5, 10.8_

- [x] 3.7 Write unit tests for AIInsightsEngine
  - Test volume calculation with various workout structures
  - Test progressive overload detection with increasing/decreasing patterns
  - Test protein deficit calculation with different targets
  - Test weight trend analysis with various patterns
  - Test insight prioritization logic
  - Test edge cases (empty data, single data point, extreme values)
  - _Requirements: 1.6, 1.7, 1.8, 2.3, 2.4, 2.5, 2.6_

- [x] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

### Phase 2: Data Layer

- [x] 5. Create Hive models and adapters
  - [x] 5.1 Create InsightModel Hive adapter
    - Create `lib/features/ai/data/models/insight_model.dart`
    - Add @HiveType annotation with typeId: 11
    - Implement toDomain() and fromDomain() conversion methods
    - _Requirements: 11.3, 15.3_

  - [x] 5.2 Create InsightCacheModel Hive adapter
    - Create `lib/features/ai/data/models/insight_cache_model.dart`
    - Add @HiveType annotation with typeId: 10
    - Implement toDomain() and fromDomain() conversion methods
    - Store timestamps as milliseconds since epoch
    - _Requirements: 11.3, 15.3_

  - [x] 5.3 Generate Hive adapters
    - Run `flutter pub run build_runner build --delete-conflicting-outputs`
    - Verify generated adapter files
    - _Requirements: 11.3_

- [x] 5.4 Write unit tests for Hive models
  - Test InsightModel serialization/deserialization
  - Test InsightCacheModel serialization/deserialization
  - Test conversion to/from domain entities
  - _Requirements: 11.3_

- [x] 6. Implement InsightCacheService
  - [x] 6.1 Create InsightCacheServiceImpl
    - Create `lib/features/ai/data/services/insight_cache_service_impl.dart`
    - Implement init() method to open Hive box
    - Implement getCachedInsights() method
    - Implement cacheInsights() method
    - Implement invalidateCache() method
    - Implement clearAll() method
    - Implement isCacheStale() method (1 hour TTL)
    - _Requirements: 3.6, 4.7, 11.2, 11.3, 11.4_

  - [x] 6.2 Add error handling for cache operations
    - Wrap Hive operations in try-catch blocks
    - Log errors without failing operations
    - Return null on cache read failures
    - _Requirements: 13.1, 13.4_

- [x] 6.3 Write unit tests for InsightCacheService
  - Test cache save and retrieve operations
  - Test cache invalidation
  - Test stale cache detection (1 hour TTL)
  - Test cache expiration logic
  - Test error handling for Hive failures
  - _Requirements: 11.3, 11.4, 13.4_

- [x] 7. Implement ChangeDetectionService
  - [x] 7.1 Create ChangeDetectionServiceImpl
    - Create `lib/features/ai/data/services/change_detection_service_impl.dart`
    - Implement hasWorkoutDataChanged() method
    - Implement hasNutritionDataChanged() method
    - Implement hasBodyDataChanged() method
    - Implement getLastDataChange() method
    - Track last known timestamps in memory
    - _Requirements: 4.4, 4.5, 11.5_

  - [x] 7.2 Optimize timestamp comparison logic
    - Fetch only latest record from each repository
    - Compare timestamps efficiently
    - Update internal timestamp cache
    - _Requirements: 11.5, 11.6_

- [x] 7.3 Write unit tests for ChangeDetectionService
  - Test change detection with modified data
  - Test change detection with unchanged data
  - Test timestamp comparison logic
  - Test handling of missing timestamps
  - _Requirements: 4.4, 4.5_

- [x] 8. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

### Phase 3: State Management

- [x] 9. Create GlobalAIState and GlobalAINotifier
  - [x] 9.1 Create GlobalAIState entity
    - Create `lib/features/ai/presentation/providers/global_ai_state.dart`
    - Define state with freezed (insights map, lastUpdated map, isLoading map, errors map, quickFeedback)
    - _Requirements: 3.1, 3.2, 3.3_

  - [x] 9.2 Create GlobalAINotifier class
    - Create `lib/features/ai/presentation/providers/global_ai_provider.dart`
    - Extend StateNotifier<GlobalAIState>
    - Inject AIInsightsEngine, InsightCacheService, ChangeDetectionService
    - Inject workout, nutrition, and body repositories
    - _Requirements: 3.1, 3.2, 3.5_

  - [x] 9.3 Implement init() method
    - Open Hive box for insight cache
    - Restore cached insights to state
    - Set up data change listeners
    - _Requirements: 3.6, 4.7, 4.8_

- [x] 10. Implement insight retrieval with caching
  - [x] 10.1 Implement getInsights() method
    - Check memory cache first
    - Check Hive cache if memory miss
    - Use change detection to determine if regeneration needed
    - Generate fresh insights if cache stale or data changed
    - Update cache after generation
    - Handle errors with fallback to cached insights
    - _Requirements: 3.2, 3.6, 4.4, 4.5, 11.2, 11.4, 13.5_

  - [x] 10.2 Implement refreshInsights() method
    - Force regeneration regardless of cache state
    - Update loading state during generation
    - Update cache after generation
    - _Requirements: 3.5_

  - [x] 10.3 Add timeout handling
    - Set 5-second timeout for insight generation
    - Return cached insights on timeout
    - Return fallback insights if no cache available
    - _Requirements: 11.1, 13.5_

- [x] 11. Implement event listeners for data changes
  - [x] 11.1 Implement onWorkoutCompleted() method
    - Schedule refresh for Home and Workout contexts
    - Generate quick feedback
    - Update quickFeedback state
    - _Requirements: 3.7, 4.1, 10.1, 10.2_

  - [x] 11.2 Implement onMealLogged() method
    - Schedule refresh for Home and Nutrition contexts
    - _Requirements: 3.8, 4.2_

  - [x] 11.3 Implement onBodyWeightRecorded() method
    - Schedule refresh for Home and Profile contexts
    - _Requirements: 3.9, 4.3_

  - [x] 11.4 Implement dismissQuickFeedback() method
    - Clear quickFeedback from state
    - _Requirements: 10.7_

- [x] 12. Implement batching logic
  - [x] 12.1 Add debouncing for multiple changes
    - Create Timer to batch changes within 5 seconds
    - Track pending contexts in a Set
    - Cancel existing timer on new change
    - Refresh all pending contexts in parallel after timer expires
    - _Requirements: 4.6_

  - [x] 12.2 Optimize parallel refresh
    - Use Future.wait for parallel context refresh
    - Reuse common data queries across contexts
    - _Requirements: 11.7_

- [x] 12.3 Write unit tests for GlobalAIProvider
  - Test insight retrieval with cache hit
  - Test insight retrieval with cache miss
  - Test batching logic (multiple changes within 5 seconds)
  - Test event listeners (workout completion, meal logged, body weight recorded)
  - Test error handling and fallback logic
  - Test timeout handling
  - _Requirements: 3.2, 3.5, 3.7, 3.8, 3.9, 4.1, 4.2, 4.3, 4.6, 13.5_

- [x] 13. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

### Phase 4: UI Components

- [x] 14. Create InsightWidget with all states
  - [x] 14.1 Create base InsightWidget structure
    - Create `lib/features/ai/presentation/widgets/insight_widget.dart`
    - Accept InsightContext parameter
    - Watch globalAIProvider for insights, loading, and error states
    - _Requirements: 5.1, 5.2, 5.3_

  - [x] 14.2 Implement loading state
    - Show shimmer effect in glassmorphic card
    - Display loading indicator
    - _Requirements: 5.3_

  - [x] 14.3 Implement error state
    - Show error icon and message
    - Add retry button that calls refreshInsights()
    - _Requirements: 5.4, 13.1, 13.2_

  - [x] 14.4 Implement empty state
    - Show lightbulb icon
    - Display onboarding message encouraging data entry
    - _Requirements: 1.5, 5.4, 13.3_

  - [x] 14.5 Implement insights list display
    - Display 2-3 insights in a column
    - Show icon, title, and message for each insight
    - Use appropriate icons based on context (💪 workouts, 🍽️ nutrition, etc.)
    - _Requirements: 5.1, 5.5_

  - [x] 14.6 Add tap navigation to AI chat
    - Make entire card tappable
    - Navigate to AI chat screen with pre-populated context
    - Pass tapped insight metadata to chat
    - _Requirements: 5.6, 12.1, 12.3_

- [x] 15. Implement glassmorphic design and animations
  - [x] 15.1 Create GlassmorphicCard widget
    - Implement frosted glass effect with BackdropFilter
    - Add subtle border and shadow
    - Match app's design system
    - _Requirements: 5.8_

  - [x] 15.2 Add fade and slide animations
    - Animate InsightWidget entry with FadeTransition and SlideTransition
    - Use AnimatedSwitcher for state transitions
    - _Requirements: 5.7_

- [x] 15.3 Write widget tests for InsightWidget
  - Test loading state display
  - Test error state display with retry button
  - Test empty state display
  - Test insights list display
  - Test tap navigation to AI chat
  - Test animation behavior
  - _Requirements: 5.3, 5.4, 5.6, 5.7, 13.1, 13.2_

- [x] 16. Create QuickFeedbackBottomSheet
  - [x] 16.1 Create base bottom sheet structure
    - Create `lib/features/ai/presentation/widgets/quick_feedback_bottom_sheet.dart`
    - Accept Insight parameter for quick feedback
    - Implement dismissible behavior (swipe down, tap outside)
    - _Requirements: 10.1, 10.7_

  - [x] 16.2 Implement feedback content display
    - Display insight icon, title, and message
    - Highlight PR achievements with special styling
    - Highlight volume records with celebration emojis
    - Highlight consistency milestones
    - _Requirements: 10.3, 10.4, 10.5, 10.8_

  - [x] 16.3 Add CTA button
    - Add "View Detailed Insights" button
    - Navigate to AI chat screen on tap
    - Pass quick feedback context to chat
    - _Requirements: 10.6, 12.3_

  - [x] 16.4 Add auto-dismiss logic
    - Show bottom sheet within 1 second of workout completion
    - Auto-dismiss after 10 seconds if not interacted with
    - _Requirements: 10.2_

- [x] 16.5 Write widget tests for QuickFeedbackBottomSheet
  - Test display of PR achievements
  - Test display of volume records
  - Test display of consistency milestones
  - Test dismiss behavior (swipe down, tap outside)
  - Test CTA button navigation
  - _Requirements: 10.3, 10.4, 10.5, 10.6, 10.7_

- [x] 17. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

### Phase 5: Screen Integration

- [x] 18. Integrate InsightWidget into Home screen
  - [x] 18.1 Add InsightWidget to Home screen layout
    - Open `lib/features/home/presentation/screens/home_screen.dart`
    - Add InsightWidget below weekly activity section
    - Pass InsightContext.home parameter
    - _Requirements: 6.1_

  - [x] 18.2 Verify Home-specific insights
    - Test overall consistency analysis
    - Test most important action identification
    - Test workout frequency analysis (last 7 days)
    - Test nutrition tracking consistency (last 7 days)
    - Test 3+ days without workout reminder
    - _Requirements: 6.2, 6.3, 6.4, 6.5, 6.6, 6.7, 14.1_

- [x] 19. Integrate InsightWidget into Workout screen
  - [x] 19.1 Add InsightWidget to Workout screen layout
    - Open `lib/features/workout/presentation/screens/workout_history_screen.dart`
    - Add InsightWidget at top of workout history list
    - Pass InsightContext.workout parameter
    - _Requirements: 7.1_

  - [x] 19.2 Verify Workout-specific insights
    - Test volume trend analysis (last 30 days)
    - Test progressive overload pattern detection
    - Test muscle group balance analysis
    - Test 7+ days without muscle group recommendation
    - Test PR achievement display
    - Test decreasing volume recovery suggestions
    - _Requirements: 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 14.2_

- [x] 20. Integrate InsightWidget into Nutrition screen
  - [x] 20.1 Add InsightWidget to Nutrition screen layout
    - Open `lib/features/nutrition/presentation/screens/nutrition_screen.dart`
    - Add InsightWidget above daily meal list
    - Pass InsightContext.nutrition parameter
    - _Requirements: 8.1_

  - [x] 20.2 Verify Nutrition-specific insights
    - Test average daily macro targets adherence
    - Test protein intake percentage calculation
    - Test protein deficit food recommendations (below 80%)
    - Test calorie tracking accuracy display
    - Test calorie deviation recommendations (200+ kcal)
    - Test macro balance analysis
    - _Requirements: 8.2, 8.3, 8.4, 8.5, 8.6, 8.7, 14.3_

- [x] 21. Integrate InsightWidget into Profile screen
  - [x] 21.1 Add InsightWidget to Profile screen layout
    - Open `lib/features/profile/presentation/screens/profile_screen.dart`
    - Add InsightWidget in statistics section
    - Pass InsightContext.profile parameter
    - _Requirements: 9.1_

  - [x] 21.2 Verify Profile-specific insights
    - Test body weight trend analysis (last 30 days)
    - Test total workouts calculation (last 30 days)
    - Test current vs 30 days ago performance comparison
    - Test weight change direction and magnitude display
    - Test goal alignment positive reinforcement
    - Test goal conflict adjustment suggestions
    - _Requirements: 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 14.4_

- [x] 22. Implement quick feedback trigger on workout completion
  - [x] 22.1 Add workout completion listener
    - Open workout completion flow (likely in workout provider)
    - Call globalAIProvider.onWorkoutCompleted() after workout saved
    - _Requirements: 4.1, 10.1_

  - [x] 22.2 Show QuickFeedbackBottomSheet
    - Watch globalAIProvider.quickFeedback state
    - Show QuickFeedbackBottomSheet when quickFeedback is not null
    - Ensure bottom sheet appears within 1 second
    - _Requirements: 10.1, 10.2_

  - [x] 22.3 Handle quick feedback dismissal
    - Call globalAIProvider.dismissQuickFeedback() on dismiss
    - Clear quickFeedback state
    - _Requirements: 10.7_

- [x] 22.4 Write integration tests for screen integrations
  - Test InsightWidget rendering on Home screen
  - Test InsightWidget rendering on Workout screen
  - Test InsightWidget rendering on Nutrition screen
  - Test InsightWidget rendering on Profile screen
  - Test navigation to AI chat from InsightWidget
  - Test quick feedback display after workout completion
  - _Requirements: 6.1, 7.1, 8.1, 9.1, 10.1, 12.1_

- [x] 23. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

### Phase 6: Polish and Optimization

- [x] 24. Performance profiling and optimization
  - [x] 24.1 Profile insight generation performance
    - Use Flutter DevTools to measure generation time for each context
    - Verify generation completes within 500ms
    - Test with large datasets (100+ workouts, 30+ days nutrition)
    - _Requirements: 11.1_

  - [x] 24.2 Profile cache performance
    - Measure cache read/write times
    - Verify cache retrieval is faster than generation
    - Test cache size limits
    - _Requirements: 11.2, 11.3_

  - [x] 24.3 Profile change detection performance
    - Measure change detection time
    - Verify detection completes within 100ms
    - Optimize timestamp queries if needed
    - _Requirements: 11.5_

  - [x] 24.4 Optimize database queries
    - Ensure date range limiting is working correctly
    - Verify parallel data fetching
    - Add indexes if needed for performance
    - _Requirements: 11.6, 11.7_

- [x] 25. Error handling refinement
  - [x] 25.1 Review all error paths
    - Verify all try-catch blocks are in place
    - Ensure errors are logged for debugging
    - Test error recovery with cached insights
    - _Requirements: 13.1, 13.4, 13.5_

  - [x] 25.2 Test error scenarios
    - Test insight generation failure
    - Test cache read/write failure
    - Test data fetch failure
    - Test timeout scenarios
    - Verify app never crashes due to insight errors
    - _Requirements: 13.1, 13.2, 13.3, 13.5, 13.6, 13.7_

  - [x] 25.3 Improve error messages
    - Make error messages user-friendly
    - Provide actionable guidance in error states
    - _Requirements: 13.1, 13.2, 13.3_

- [x] 26. Cache tuning
  - [x] 26.1 Adjust TTL if needed
    - Review 1-hour TTL based on user feedback
    - Consider different TTLs for different contexts
    - _Requirements: 11.4_

  - [x] 26.2 Implement cache size limits
    - Monitor cache size growth
    - Implement LRU eviction if cache grows too large
    - _Requirements: 11.3_

  - [x] 26.3 Test cache persistence
    - Verify cache survives app restarts
    - Test cache restoration on app launch
    - Verify stale cache detection on launch
    - _Requirements: 4.7, 4.8_

- [x] 27. UI polish and animations
  - [x] 27.1 Refine glassmorphic design
    - Adjust blur intensity and opacity
    - Ensure design matches app theme
    - Test in light and dark modes
    - _Requirements: 5.8_

  - [x] 27.2 Polish animations
    - Smooth fade and slide transitions
    - Add micro-interactions (button press, card tap)
    - Ensure animations don't feel sluggish
    - _Requirements: 5.7_

  - [x] 27.3 Accessibility improvements
    - Add semantic labels for screen readers
    - Ensure sufficient color contrast
    - Test with TalkBack/VoiceOver
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 28. Documentation
  - [x] 28.1 Add code documentation
    - Document all public methods with dartdoc comments
    - Add usage examples in comments
    - Document complex algorithms (volume calculation, trend analysis)
    - _Requirements: All_

  - [x] 28.2 Create developer guide
    - Document how to add new insight types
    - Document how to modify insight prioritization
    - Document caching strategy and tuning
    - _Requirements: All_

  - [x] 28.3 Update user-facing documentation
    - Document Global AI Coach feature for users
    - Explain how insights are generated
    - Explain data privacy (local processing)
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6_

- [x] 29. Final checkpoint - Ensure all tests pass
  - Run full test suite (unit, widget, integration)
  - Verify all acceptance criteria are met
  - Perform manual testing on all screens
  - Test with various data scenarios (empty, sparse, rich)
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation at the end of each phase
- The implementation follows a bottom-up approach: domain → data → state → UI
- All data processing happens locally on-device for privacy
- Multi-layer caching (memory + Hive) ensures optimal performance
- Change detection prevents unnecessary insight regeneration
- Batching logic prevents excessive updates when multiple data changes occur
- Quick feedback system provides immediate post-workout motivation
- InsightWidget is reusable across all screens with context-specific insights
- Error handling ensures the app remains usable even when insights fail to generate

## Testing Strategy

- **Unit Tests**: Test core logic (volume calculation, trend analysis, caching, change detection)
- **Widget Tests**: Test UI components (InsightWidget states, QuickFeedbackBottomSheet)
- **Integration Tests**: Test end-to-end flows (data change → insight update → UI display)
- **Performance Tests**: Verify generation time (<500ms), cache performance, change detection speed
- **Error Scenario Tests**: Test all error paths and fallback mechanisms

## Success Criteria

- Insights generate within 500ms for any context
- Cache hit rate > 80% for typical usage patterns
- No UI blocking during insight generation
- Graceful error handling with fallback to cached insights
- All screens display contextually relevant insights
- Quick feedback appears within 1 second of workout completion
- All data processing happens locally (no external API calls)
- App remains responsive even with large datasets (100+ workouts)
