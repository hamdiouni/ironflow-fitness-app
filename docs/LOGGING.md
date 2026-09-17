# Debug Logging System Documentation

## Overview

IronFlow uses a comprehensive emoji-based debug logging system to track operations, identify errors, and monitor data flow throughout the application. The logging system provides visual clarity through emoji prefixes and consistent formatting, making it easy to scan console output and quickly identify issues during development.

## Log Levels

The logging system uses five distinct log levels, each with a unique emoji prefix for visual identification:

| Level | Emoji | Purpose | Example Use Case |
|-------|-------|---------|------------------|
| **SUCCESS** | ✅ | Successful operations | Workout saved, theme loaded, meal created |
| **ERROR** | ❌ | Failed operations | Database error, network failure, validation error |
| **WARNING** | ⚠️ | Potential issues | Box not open, missing data, deprecated usage |
| **INFO** | 📊 | General information | Operation start, state changes, data flow |
| **DEBUG** | 🔍 | Detailed debugging | Variable values, IDs, counts, timestamps |

## Log Format

All logs follow a consistent format for easy parsing and filtering:

```
[Emoji] [FeatureName] Level: Message
```

**Examples:**
```
✅ [Hive] Box opened: workouts
❌ [Workout] Failed to start workout: Box not initialized
⚠️ [Nutrition] Meals box is not open
📊 [Theme] Loading theme from Hive...
🔍 [Workout] Workout ID: abc-123, Start time: 2024-01-15 10:30:00
```

## Feature Names

Feature names are standardized across the codebase for consistent filtering:

| Feature Name | Module | Files |
|--------------|--------|-------|
| `[Hive]` | Core infrastructure | `hive_manager.dart` |
| `[Theme]` | Theme management | `theme_provider.dart` |
| `[Workout]` | Workout tracking | `workout_providers.dart`, `active_workout_screen.dart` |
| `[WorkoutData]` | Workout persistence | `hive_workout_data_source.dart` |
| `[NutritionData]` | Nutrition persistence | `hive_nutrition_datasource.dart` |
| `[Nutrition]` | Nutrition tracking | `nutrition_providers.dart` |
| `[Auth]` | Authentication | `auth_provider.dart` |
| `[Body]` | Body measurements | `hive_body_data_source.dart` |
| `[Export]` | Data export | `export_workouts_use_case.dart` |

## Console Output Examples

### Successful Workout Flow

```
📊 [Hive] Initializing Hive...
✅ [Hive] Hive initialized successfully
📊 [Hive] Opening box: workouts...
✅ [Hive] Box opened: workouts
📊 [Hive] Opening box: nutrition...
✅ [Hive] Box opened: nutrition
✅ [Hive] All boxes opened successfully

📊 [Workout] Starting new workout session...
✅ [Workout] Workout created successfully
🔍 [Workout] Workout ID: 550e8400-e29b-41d4-a716-446655440000, Start time: 2024-01-15 10:30:00
✅ [Workout] State updated to inProgress
✅ [Workout] Workout state saved to Hive

📊 [Workout] Adding exercise to workout...
🔍 [Workout] Exercise name: Bench Press, Type: strength
✅ [Workout] Exercise added successfully
🔍 [Workout] Exercise ID: 660e8400-e29b-41d4-a716-446655440001
🔍 [Workout] Total exercises: 1
✅ [Workout] State updated with new exercise
✅ [Workout] Workout state saved to Hive

📊 [Workout] Logging set for exercise...
🔍 [Workout] Exercise ID: 660e8400-e29b-41d4-a716-446655440001
🔍 [Workout] Reps: 8, Weight: 80.0kg
🔍 [Workout] Exercise name: Bench Press
✅ [Workout] Set logged successfully
🔍 [Workout] Total sets for exercise: 1
✅ [Workout] New PR detected!
🔍 [Workout] PR: 8 reps @ 80.0kg
✅ [Workout] State updated with new set
✅ [Workout] Workout state saved to Hive

📊 [Workout] Finishing workout...
🔍 [Workout] Workout duration: 45 minutes
🔍 [Workout] Total exercises: 1
📊 [Workout] Saving workout to repository...
✅ [Workout] Workout saved successfully
📊 [Workout] Clearing active workout state...
✅ [Workout] Active state cleared from Hive
✅ [Workout] State updated to completed
✅ [Workout] Workout history refresh triggered
```

### Error Scenario

```
📊 [Nutrition] Saving meal entry...
🔍 [Nutrition] Meal ID: meal-123, Type: breakfast
⚠️ [Nutrition] Meals box is not open
❌ [Nutrition] Failed to save meal: Exception: Meals box not open
🔍 [Nutrition] Stack trace:
#0      HiveNutritionDatasource.saveMealEntry (package:ironflow/features/nutrition/data/datasources/hive_nutrition_datasource.dart:45:9)
#1      NutritionRepositoryImpl.saveMeal (package:ironflow/features/nutrition/data/repositories/nutrition_repository_impl.dart:23:5)
<asynchronous suspension>
```

### Theme Toggle Flow

```
📊 [Theme] Loading theme from Hive...
🔍 [Theme] Theme box is open: true
✅ [Theme] Theme loaded: dark

📊 [Theme] Toggling theme...
🔍 [Theme] Current theme: ThemeMode.dark
📊 [Theme] Saving theme to Hive...
✅ [Theme] Theme saved to Hive
✅ [Theme] Theme changed to: ThemeMode.light
```

### Nutrition Tracking Flow

```
📊 [NutritionData] Saving meal entry...
🔍 [NutritionData] Meal ID: meal-456, Type: lunch
✅ [NutritionData] Meal saved successfully
🔍 [NutritionData] Total calories: 650, Items: 4

📊 [NutritionData] Getting meals by date...
🔍 [NutritionData] Date: 2024-1-15
✅ [NutritionData] Meals retrieved successfully
🔍 [NutritionData] Found 3 meals for date

📊 [NutritionData] Saving nutrition targets...
🔍 [NutritionData] Calories: 2500, Protein: 180g
✅ [NutritionData] Nutrition targets saved successfully
🔍 [NutritionData] Carbs: 250g, Fat: 80g
```

## Filtering Logs

### By Feature
Use your IDE's search/filter functionality to filter by feature name:

- Filter for `[Workout]` to see all workout-related logs
- Filter for `[Hive]` to see all database operations
- Filter for `[Nutrition]` to see all nutrition-related logs

### By Log Level
Filter by emoji to see specific log levels:

- Filter for `✅` to see only successful operations
- Filter for `❌` to see only errors
- Filter for `⚠️` to see only warnings
- Filter for `🔍` to see detailed debug information

### By Operation
Search for specific operations:

- Search for "Starting" to see operation initiations
- Search for "saved successfully" to see persistence operations
- Search for "Stack trace" to find error details

## Visual Scanning Tips

1. **Quick Health Check**: Scan for ❌ (errors) and ⚠️ (warnings) to identify issues
2. **Operation Flow**: Follow 📊 (info) logs to trace operation sequences
3. **Data Verification**: Check 🔍 (debug) logs to verify data values
4. **Success Confirmation**: Look for ✅ (success) logs to confirm operations completed

## Performance Considerations

### Debug Mode Only
All logging is wrapped in `kDebugMode` checks and only runs in debug builds:

```dart
if (kDebugMode) {
  print('📊 [Feature] Operation starting...');
}
```

### Production Builds
- Logging is completely removed in release builds
- Zero performance overhead in production
- No sensitive data exposure risk

### Overhead
- Logging adds < 5ms per operation in debug mode
- No blocking I/O operations
- Minimal memory footprint
- No impact on UI responsiveness

## Security & Privacy

### What We Log
- ✅ Operation names and types
- ✅ IDs (workout IDs, meal IDs, exercise IDs)
- ✅ Counts and summaries
- ✅ Timestamps
- ✅ Box states and operation results

### What We DON'T Log
- ❌ Passwords
- ❌ API tokens
- ❌ Full email addresses (sanitized to show only domain)
- ❌ Sensitive user data
- ❌ Payment information

### Data Sanitization
When logging user-related data, sensitive information is sanitized:

```dart
// Email sanitization
'user@example.com' → 'u***@example.com'

// User ID redaction
'550e8400-e29b-41d4-a716-446655440000' → '550e...0000'
```

## Troubleshooting with Logs

### Common Issues

#### 1. Box Not Open Error
```
⚠️ [Nutrition] Meals box is not open
❌ [Nutrition] Failed to save meal: Exception: Meals box not open
```

**Solution**: Ensure `HiveManager.initialize()` is called before accessing boxes.

#### 2. State Not Persisting
```
📊 [Workout] Saving workout state to Hive...
❌ [Workout] Failed to save state: Box not initialized
```

**Solution**: Check that the appropriate box is opened in `HiveManager.initialize()`.

#### 3. Missing Data
```
📊 [NutritionData] Getting meal by ID...
🔍 [NutritionData] Meal ID: meal-123
⚠️ [NutritionData] Meal not found
```

**Solution**: Verify the meal was saved successfully by checking earlier logs for save operations.

#### 4. Unexpected State Changes
```
📊 [Workout] State changing...
🔍 [Workout] Old state: WorkoutState.initial
🔍 [Workout] New state: WorkoutState.completed
⚠️ [Workout] State type changed unexpectedly
```

**Solution**: Review the operation flow to identify where the state transition occurred.

## Best Practices

### When to Use Each Log Level

**SUCCESS (✅)**
- Use when an operation completes successfully
- Confirms expected behavior
- Example: "Workout saved successfully"

**ERROR (❌)**
- Use when an operation fails
- Always include exception details
- Always include stack trace
- Example: "Failed to save workout: Box not initialized"

**WARNING (⚠️)**
- Use for potential issues that don't prevent operation
- Use for deprecated features
- Use for missing optional data
- Example: "Box not open, attempting to open"

**INFO (📊)**
- Use at the start of operations
- Use for state changes
- Use for important milestones
- Example: "Starting new workout session..."

**DEBUG (🔍)**
- Use for detailed data values
- Use for IDs and timestamps
- Use for counts and summaries
- Example: "Workout ID: abc-123, Duration: 45 minutes"

### Logging Patterns

**Operation Start-End Pattern**
```dart
print('📊 [Feature] Starting operation...');
try {
  // ... operation logic ...
  print('✅ [Feature] Operation completed successfully');
} catch (e, stackTrace) {
  print('❌ [Feature] Operation failed: $e');
  print('🔍 [Feature] Stack trace: $stackTrace');
  rethrow;
}
```

**Data Logging Pattern**
```dart
print('📊 [Feature] Saving data...');
print('🔍 [Feature] ID: $id, Type: $type');
await saveOperation();
print('✅ [Feature] Data saved successfully');
print('🔍 [Feature] Additional details: $details');
```

**State Change Pattern**
```dart
print('📊 [Feature] State changing...');
print('🔍 [Feature] Old state: $oldState');
state = newState;
print('✅ [Feature] State updated to: $newState');
```

## Integration with Development Workflow

### During Development
1. Run app in debug mode
2. Monitor console output for operation flow
3. Use logs to verify feature implementation
4. Check for warnings and errors

### During Testing
1. Review logs for unexpected warnings
2. Verify all operations are logged
3. Check error handling paths
4. Confirm data flow is correct

### During Debugging
1. Filter logs by feature name
2. Trace operation sequences
3. Identify error sources
4. Verify data values

### Before Release
1. Verify no sensitive data in logs
2. Confirm all logs are wrapped in `kDebugMode`
3. Test that release builds have no logging
4. Review security considerations

## Related Documentation

- [Developer Guide](./LOGGING_DEVELOPER_GUIDE.md) - How to add logging to new features
- [Logging Patterns](./LOGGING_PATTERNS.md) - Common logging patterns and examples
- [Requirements](../.kiro/specs/debug-logging-system/requirements.md) - Full requirements specification
- [Design](../.kiro/specs/debug-logging-system/design.md) - Technical design document
