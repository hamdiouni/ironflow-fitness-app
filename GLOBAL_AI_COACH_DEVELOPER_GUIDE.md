# Global AI Coach - Developer Guide

## Overview

The Global AI Coach is a comprehensive coaching system that provides data-driven insights across all main screens (Home, Workout, Nutrition, Profile). This guide explains the architecture, how to extend the system, and best practices for maintenance.

## Architecture

### Layer Structure

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │InsightWidget │  │QuickFeedback │  │GlobalAIState │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────┐
│                      Domain Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Insight    │  │InsightCache  │  │AIInsights    │  │
│  │   Entity     │  │   Entity     │  │   Engine     │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────┐
│                       Data Layer                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │InsightCache  │  │ChangeDetect  │  │AIInsights    │  │
│  │   Service    │  │   Service    │  │EngineImpl    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Key Components

#### 1. **AIInsightsEngine** (`lib/features/ai/domain/services/ai_insights_engine.dart`)
- **Purpose**: Core insight generation logic
- **Responsibilities**:
  - Analyze workout, nutrition, and body data
  - Generate context-specific insights
  - Calculate metrics (volume, trends, adherence)
  - Prioritize and format insights

#### 2. **GlobalAIProvider** (`lib/features/ai/presentation/providers/global_ai_provider.dart`)
- **Purpose**: State management for insights across all contexts
- **Responsibilities**:
  - Coordinate insight generation and caching
  - Listen to data change events
  - Manage quick feedback state
  - Implement batching logic (5-second debounce)

#### 3. **InsightCacheService** (`lib/features/ai/data/services/insight_cache_service_impl.dart`)
- **Purpose**: Multi-layer caching (memory + Hive)
- **Responsibilities**:
  - Cache insights to Hive storage
  - Check cache staleness (1-hour TTL)
  - Invalidate cache on data changes

#### 4. **ChangeDetectionService** (`lib/features/ai/data/services/change_detection_service_impl.dart`)
- **Purpose**: Detect when underlying data has changed
- **Responsibilities**:
  - Track last data change timestamps
  - Avoid unnecessary insight regeneration
  - Optimize performance

## Adding New Insight Types

### Step 1: Define the Analysis Method

Add your analysis method to `AIInsightsEngineImpl`:

```dart
/// Analyze [your metric] over the analysis period
///
/// **Requirements:**
/// - [Requirement ID]: [Description]
double analyzeYourMetric(List<Workout> workouts) {
  // Your analysis logic here
  return result;
}
```

### Step 2: Generate Insights in Context Method

Add insight generation to the appropriate context method (`_generateHomeInsights`, `_generateWorkoutInsights`, etc.):

```dart
// In _generateWorkoutInsights or other context method
final yourMetric = analyzeYourMetric(workouts);

if (yourMetric > threshold) {
  allInsights.add(createHighPriorityInsight(
    context: InsightContext.workout,
    title: '🎯 Your Insight Title',
    analysis: 'Your metric is $yourMetric.',
    numbers: {'your_metric': yourMetric},
    actionPlan: 'Actionable recommendation for the user.',
    icon: '🎯',
    metadata: {'type': 'your_insight_type', 'metric': yourMetric},
  ));
}
```

### Step 3: Test Your Insight

Add unit tests in `test/features/ai/domain/services/ai_insights_engine_test.dart`:

```dart
test('analyzeYourMetric calculates correctly', () {
  // Arrange
  final workouts = [/* test data */];
  
  // Act
  final result = engine.analyzeYourMetric(workouts);
  
  // Assert
  expect(result, expectedValue);
});
```

## Modifying Insight Prioritization

### Current Priority Levels

1. **High Priority** (Red/Urgent):
   - Workout reminders (3+ days without training)
   - Protein deficit (below 80%)
   - Calorie deviation (200+ kcal)
   - PR achievements
   - Volume records

2. **Medium Priority** (Yellow/Important):
   - Nutrition tracking consistency
   - Muscle group balance
   - Deload suggestions
   - Macro adherence

3. **Low Priority** (Green/Informational):
   - General summaries
   - Workout counts
   - Weight stability

### Changing Priority Logic

Edit the `prioritizeInsights` method in `AIInsightsEngineImpl`:

```dart
List<Insight> prioritizeInsights(List<Insight> allInsights, {int maxInsights = 3}) {
  // Sort by priority (high > medium > low)
  final sortedInsights = List<Insight>.from(allInsights)
    ..sort((a, b) {
      final priorityOrder = {
        InsightPriority.high: 3,
        InsightPriority.medium: 2,
        InsightPriority.low: 1,
      };
      return priorityOrder[b.priority]!.compareTo(priorityOrder[a.priority]!);
    });
  
  // Take top insights
  return sortedInsights.take(maxInsights).toList();
}
```

### Adjusting Max Insights Per Screen

Change the `maxInsights` parameter in context methods:

```dart
return prioritizeInsights(allInsights, maxInsights: 4); // Show 4 instead of 3
```

## Caching Strategy

### Multi-Layer Cache

1. **Memory Cache** (State):
   - Fastest access
   - Lost on app restart
   - Checked first

2. **Hive Cache** (Persistent):
   - Survives app restarts
   - 1-hour TTL
   - Checked if memory miss

### Cache Flow

```
User requests insights
        │
        ▼
Check memory cache ──Yes──> Return cached insights
        │ No
        ▼
Check Hive cache ──Yes──> Restore to memory & return
        │ No
        ▼
Check data changed? ──No──> Return cached insights
        │ Yes
        ▼
Generate fresh insights
        │
        ▼
Update memory & Hive cache
        │
        ▼
Return fresh insights
```

### Tuning Cache TTL

Edit `InsightCacheServiceImpl.isCacheStale()`:

```dart
bool isCacheStale(InsightCache cache) {
  final cacheAge = DateTime.now().difference(cache.cachedAt);
  return cacheAge.inHours >= 2; // Change from 1 to 2 hours
}
```

### Context-Specific TTL

```dart
bool isCacheStale(InsightCache cache) {
  final cacheAge = DateTime.now().difference(cache.cachedAt);
  
  // Different TTLs per context
  switch (cache.context) {
    case InsightContext.home:
      return cacheAge.inMinutes >= 30; // 30 minutes for home
    case InsightContext.workout:
      return cacheAge.inHours >= 2; // 2 hours for workout
    default:
      return cacheAge.inHours >= 1; // 1 hour default
  }
}
```

## Batching Logic

### How It Works

When multiple data changes occur within 5 seconds, they are batched into a single refresh operation:

```dart
void _scheduleBatchedRefresh(List<InsightContext> contexts) {
  // 1. Add contexts to pending set
  _pendingContexts.addAll(contexts);
  
  // 2. Cancel existing timer
  _batchTimer?.cancel();
  
  // 3. Start new 5-second timer
  _batchTimer = Timer(const Duration(seconds: 5), () async {
    // 4. Refresh all pending contexts in parallel
    final contextsToRefresh = List<InsightContext>.from(_pendingContexts);
    _pendingContexts.clear();
    
    // Invalidate caches and refresh
    await _invalidateContextCaches(contextsToRefresh);
  });
}
```

### Adjusting Batch Window

Change the timer duration in `GlobalAINotifier._scheduleBatchedRefresh()`:

```dart
_batchTimer = Timer(const Duration(seconds: 10), () async {
  // Batch window increased to 10 seconds
  ...
});
```

## Performance Optimization

### Current Optimizations

1. **Context-Specific Data Fetching**:
   - Only fetch data sources needed for each context
   - Reduces unnecessary database queries

2. **Parallel Data Fetching**:
   - Use `Future.wait()` to fetch multiple data sources simultaneously
   - Reduces total fetch time

3. **Performance Timing**:
   - Logs generation time for each context
   - Warns if generation exceeds 500ms target

### Adding Performance Metrics

```dart
final stopwatch = Stopwatch()..start();

// Your operation here

stopwatch.stop();
print('⏱️ [YourOperation] took ${stopwatch.elapsedMilliseconds}ms');
```

## Event Listeners

### Workout Completion

```dart
// In workout provider after saving workout
await ref.read(globalAIProvider.notifier).onWorkoutCompleted(workout);
```

### Meal Logged

```dart
// In nutrition provider after logging meal
await ref.read(globalAIProvider.notifier).onMealLogged();
```

### Body Weight Recorded

```dart
// In body provider after recording weight
await ref.read(globalAIProvider.notifier).onBodyWeightRecorded();
```

## Quick Feedback System

### How It Works

1. User completes workout
2. `onWorkoutCompleted()` is called
3. Quick feedback is generated asynchronously
4. `quickFeedback` state is updated
5. `QuickFeedbackBottomSheet` displays automatically
6. Auto-dismisses after 10 seconds

### Customizing Quick Feedback

Edit `AIInsightsEngineImpl.generateQuickFeedback()`:

```dart
@override
Future<Insight> generateQuickFeedback(
  Workout completedWorkout,
  List<Workout> history,
) async {
  // Detect achievements
  final hasPR = detectPR([completedWorkout, ...history]);
  final hasVolumeRecord = _detectVolumeRecord(completedWorkout, history);
  
  // Prioritize and create feedback
  if (hasPR) {
    return _createPRFeedback(...);
  } else if (hasVolumeRecord) {
    return _createVolumeRecordFeedback(...);
  }
  // Add your custom feedback type here
  else {
    return _createGeneralEncouragementFeedback(...);
  }
}
```

## Testing

### Unit Tests

Run unit tests for core logic:

```bash
flutter test test/features/ai/domain/
flutter test test/features/ai/data/
```

### Widget Tests

Run widget tests for UI components:

```bash
flutter test test/features/ai/presentation/
```

### Integration Tests

Run integration tests for end-to-end flows:

```bash
flutter test test/features/ai/integration/
```

## Troubleshooting

### Insights Not Updating

1. Check if data change events are being triggered
2. Verify cache invalidation is working
3. Check change detection service timestamps
4. Look for errors in logs (search for `[GlobalAI]`)

### Slow Insight Generation

1. Check performance logs for timing breakdown
2. Verify parallel data fetching is working
3. Check if database queries are optimized
4. Consider reducing data range (e.g., 30 days → 14 days)

### Cache Not Persisting

1. Verify Hive box is initialized (`init()` called)
2. Check Hive box name is correct
3. Verify cache model serialization is working
4. Check for Hive write errors in logs

### Quick Feedback Not Showing

1. Verify `onWorkoutCompleted()` is being called
2. Check `quickFeedback` state is being set
3. Verify bottom sheet is watching the correct state
4. Check for navigation conflicts

## Best Practices

### 1. Always Use Try-Catch

```dart
try {
  // Your operation
} catch (e, stackTrace) {
  print('❌ [YourFeature] Error: $e');
  print('🔍 [YourFeature] Stack trace: $stackTrace');
  // Handle gracefully - don't rethrow unless necessary
}
```

### 2. Log Important Operations

```dart
print('📊 [YourFeature] Starting operation...');
// Operation
print('✅ [YourFeature] Operation completed successfully');
```

### 3. Use Specific Numbers in Insights

```dart
// ❌ Bad
'Your volume is increasing.'

// ✅ Good
'Your volume increased by 15% (from 2,500kg to 2,875kg).'
```

### 4. Provide Actionable Recommendations

```dart
// ❌ Bad
'Your protein intake is low.'

// ✅ Good
'Your protein intake is 65g/day (80% of target). Add 2 eggs or 100g chicken breast to close the gap.'
```

### 5. Test with Various Data Scenarios

- Empty data (new user)
- Sparse data (1-2 workouts)
- Rich data (30+ workouts)
- Edge cases (extreme values, missing fields)

## Future Enhancements

### Potential Additions

1. **Machine Learning Integration**:
   - Predict future performance
   - Personalize recommendations based on user patterns

2. **Goal-Specific Insights**:
   - Tailor insights to user goals (muscle gain, fat loss, strength)
   - Adjust priorities based on goal type

3. **Social Features**:
   - Compare progress with friends
   - Share achievements

4. **Advanced Analytics**:
   - Periodization tracking
   - Fatigue management
   - Injury risk prediction

5. **Integration with Wearables**:
   - Heart rate variability
   - Sleep quality
   - Recovery metrics

## Support

For questions or issues:
1. Check this guide first
2. Review the design document (`.kiro/specs/global-ai-coach/design.md`)
3. Check the requirements document (`.kiro/specs/global-ai-coach/requirements.md`)
4. Review existing tests for examples
5. Check logs for error messages

---

**Last Updated**: 2026-04-28
**Version**: 1.0.0
**Author**: IronFlow Development Team
