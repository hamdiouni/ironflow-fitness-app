# Developer Guide: Adding Logging to New Features

This guide walks you through adding comprehensive debug logging to new features in IronFlow. Follow these steps to ensure consistent, useful logging throughout the codebase.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Step-by-Step Guide](#step-by-step-guide)
3. [Feature-Specific Guidelines](#feature-specific-guidelines)
4. [Testing Your Logging](#testing-your-logging)
5. [Common Scenarios](#common-scenarios)
6. [Checklist](#checklist)

---

## Quick Start

### Basic Template

```dart
import 'package:flutter/foundation.dart'; // For kDebugMode

Future<void> yourOperation() async {
  try {
    if (kDebugMode) {
      print('📊 [YourFeature] Starting operation...');
    }
    
    // Your operation logic here
    final result = await doSomething();
    
    if (kDebugMode) {
      print('✅ [YourFeature] Operation completed successfully');
      print('🔍 [YourFeature] Result details: $result');
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('❌ [YourFeature] Operation failed: $e');
      print('🔍 [YourFeature] Stack trace: $stackTrace');
    }
    rethrow;
  }
}
```

### Key Points

1. **Always wrap in `kDebugMode`** - Logging only runs in debug builds
2. **Use consistent feature names** - Enclosed in square brackets `[Feature]`
3. **Use appropriate emojis** - ✅ success, ❌ error, ⚠️ warning, 📊 info, 🔍 debug
4. **Include context** - IDs, counts, timestamps, etc.
5. **Log errors with stack traces** - Always include full error details

---

## Step-by-Step Guide

### Step 1: Choose Your Feature Name

Pick a clear, concise feature name that will be used consistently across all files in your feature.

**Examples:**
- `[Workout]` - Workout tracking
- `[Nutrition]` - Nutrition tracking
- `[Auth]` - Authentication
- `[Analytics]` - Analytics and reporting
- `[Settings]` - App settings

**Guidelines:**
- Use PascalCase or single words
- Keep it short (1-2 words max)
- Make it searchable and filterable
- Be consistent across all files in the feature

### Step 2: Identify Operations to Log

Identify all operations that should be logged:

**Must Log:**
- ✅ Data persistence (save, update, delete)
- ✅ State changes
- ✅ API calls or external operations
- ✅ User-initiated actions
- ✅ Error conditions

**Should Log:**
- 📊 Operation start/end
- 📊 Data queries
- 📊 Initialization
- 📊 Configuration changes

**Optional:**
- 🔍 Detailed data values
- 🔍 Intermediate calculations
- 🔍 Performance metrics

### Step 3: Add Logging to Each Operation

For each operation, follow this pattern:

```dart
Future<void> operation() async {
  try {
    // 1. Log operation start
    if (kDebugMode) {
      print('📊 [Feature] Starting operation...');
    }
    
    // 2. Log input parameters (if relevant)
    if (kDebugMode) {
      print('🔍 [Feature] Input: $param1, $param2');
    }
    
    // 3. Execute operation
    final result = await doSomething();
    
    // 4. Log success
    if (kDebugMode) {
      print('✅ [Feature] Operation completed successfully');
    }
    
    // 5. Log result details (if relevant)
    if (kDebugMode) {
      print('🔍 [Feature] Result: ${result.summary}');
    }
    
    return result;
  } catch (e, stackTrace) {
    // 6. Log error with full details
    if (kDebugMode) {
      print('❌ [Feature] Operation failed: $e');
      print('🔍 [Feature] Stack trace: $stackTrace');
    }
    rethrow;
  }
}
```

### Step 4: Add State Change Logging

For StateNotifiers or state management:

```dart
class YourNotifier extends StateNotifier<YourState> {
  void updateState(NewState newState) {
    if (kDebugMode) {
      print('📊 [Feature] State changing...');
      print('🔍 [Feature] Old state: $state');
    }
    
    state = newState;
    
    if (kDebugMode) {
      print('✅ [Feature] State updated');
      print('🔍 [Feature] New state: $state');
    }
  }
}
```

### Step 5: Add Hive Operation Logging

For data persistence with Hive:

```dart
Future<void> saveData(DataModel data) async {
  try {
    if (kDebugMode) {
      print('📊 [FeatureData] Saving data...');
      print('🔍 [FeatureData] ID: ${data.id}, Type: ${data.type}');
    }
    
    // Check box state
    if (!_box.isOpen) {
      if (kDebugMode) {
        print('⚠️ [FeatureData] Box is not open');
      }
      throw Exception('Box not open');
    }
    
    // Save data
    await _box.put(data.id, data.toJson());
    
    if (kDebugMode) {
      print('✅ [FeatureData] Data saved successfully');
      print('🔍 [FeatureData] Summary: ${data.summary}');
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('❌ [FeatureData] Failed to save data: $e');
      print('🔍 [FeatureData] Stack trace: $stackTrace');
    }
    rethrow;
  }
}
```

### Step 6: Test Your Logging

1. Run the app in debug mode
2. Trigger your feature's operations
3. Check console output for:
   - ✅ All operations are logged
   - ✅ Log format is consistent
   - ✅ Emojis are correct
   - ✅ Feature name is consistent
   - ✅ Errors include stack traces
   - ✅ No sensitive data is logged

---

## Feature-Specific Guidelines

### Data Sources (Hive)

**Feature Name Pattern**: `[FeatureData]` (e.g., `[WorkoutData]`, `[NutritionData]`)

**What to Log:**
- Box open state checks
- Save operations with IDs
- Query operations with parameters
- Delete operations with IDs
- Data counts and summaries

**Example:**
```dart
class HiveYourFeatureDataSource {
  Future<void> save(YourModel model) async {
    try {
      if (kDebugMode) {
        print('📊 [YourFeatureData] Saving model...');
        print('🔍 [YourFeatureData] ID: ${model.id}');
      }
      
      if (!_box.isOpen) {
        if (kDebugMode) {
          print('⚠️ [YourFeatureData] Box is not open');
        }
        throw Exception('Box not open');
      }
      
      await _box.put(model.id, model.toJson());
      
      if (kDebugMode) {
        print('✅ [YourFeatureData] Model saved successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [YourFeatureData] Failed to save: $e');
        print('🔍 [YourFeatureData] Stack trace: $stackTrace');
      }
      rethrow;
    }
  }
}
```

### State Providers (Riverpod)

**Feature Name Pattern**: `[Feature]` (e.g., `[Workout]`, `[Nutrition]`)

**What to Log:**
- State initialization
- State changes with before/after values
- User actions
- Operation results
- Error conditions

**Example:**
```dart
class YourNotifier extends StateNotifier<YourState> {
  Future<void> performAction() async {
    try {
      if (kDebugMode) {
        print('📊 [YourFeature] Performing action...');
      }
      
      // Check current state
      final current = state;
      if (current is! ValidState) {
        if (kDebugMode) {
          print('⚠️ [YourFeature] Invalid state for action');
        }
        return;
      }
      
      // Perform action
      final result = await _useCase.execute();
      
      if (kDebugMode) {
        print('✅ [YourFeature] Action completed');
        print('🔍 [YourFeature] Result: $result');
      }
      
      // Update state
      state = YourState.success(result);
      
      if (kDebugMode) {
        print('✅ [YourFeature] State updated to success');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [YourFeature] Action failed: $e');
        print('🔍 [YourFeature] Stack trace: $stackTrace');
      }
      rethrow;
    }
  }
}
```

### Use Cases

**Feature Name Pattern**: `[Feature]` (same as provider)

**What to Log:**
- Use case execution start
- Business logic steps
- Validation results
- Calculation results
- Success/failure

**Example:**
```dart
class YourUseCase {
  Future<Result> call(Input input) async {
    try {
      if (kDebugMode) {
        print('📊 [YourFeature] Executing use case...');
        print('🔍 [YourFeature] Input: $input');
      }
      
      // Validate input
      if (!_validate(input)) {
        if (kDebugMode) {
          print('⚠️ [YourFeature] Input validation failed');
        }
        throw ValidationException('Invalid input');
      }
      
      // Execute business logic
      final result = await _execute(input);
      
      if (kDebugMode) {
        print('✅ [YourFeature] Use case completed');
        print('🔍 [YourFeature] Result: $result');
      }
      
      return result;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [YourFeature] Use case failed: $e');
        print('🔍 [YourFeature] Stack trace: $stackTrace');
      }
      rethrow;
    }
  }
}
```

### UI Screens

**Feature Name Pattern**: `[Feature]` (same as provider)

**What to Log:**
- User interactions (button presses, form submissions)
- Navigation events
- Data loading
- Error displays

**Example:**
```dart
class YourScreen extends ConsumerWidget {
  void _onButtonPressed(WidgetRef ref) {
    if (kDebugMode) {
      print('📊 [YourFeature] Button pressed');
    }
    
    try {
      ref.read(yourProvider.notifier).performAction();
      
      if (kDebugMode) {
        print('✅ [YourFeature] Action triggered successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [YourFeature] Failed to trigger action: $e');
      }
    }
  }
}
```

---

## Testing Your Logging

### Manual Testing Checklist

1. **Run in Debug Mode**
   ```bash
   flutter run
   ```

2. **Trigger All Operations**
   - Test happy path (success scenarios)
   - Test error paths (failure scenarios)
   - Test edge cases (empty data, null values, etc.)

3. **Verify Console Output**
   - [ ] All operations are logged
   - [ ] Format is consistent: `[Emoji] [Feature] Message`
   - [ ] Feature name is consistent across files
   - [ ] Emojis match log levels
   - [ ] Success operations show ✅
   - [ ] Errors show ❌ with stack traces
   - [ ] Warnings show ⚠️
   - [ ] Info shows 📊
   - [ ] Debug details show 🔍

4. **Check for Issues**
   - [ ] No sensitive data (passwords, tokens, etc.)
   - [ ] No excessive logging (too verbose)
   - [ ] No missing logging (critical operations)
   - [ ] All logs wrapped in `kDebugMode`

### Automated Testing

Add tests to verify logging doesn't break functionality:

```dart
test('operation completes successfully with logging', () async {
  // Arrange
  final dataSource = YourDataSource();
  final model = YourModel(id: 'test-id');
  
  // Act
  await dataSource.save(model);
  
  // Assert
  final saved = await dataSource.get('test-id');
  expect(saved, isNotNull);
  expect(saved!.id, 'test-id');
});
```

### Release Build Verification

Verify logging is removed in release builds:

```bash
flutter build apk --release
```

Then check that:
- [ ] No console output in release build
- [ ] App performance is not affected
- [ ] No logging-related crashes

---

## Common Scenarios

### Scenario 1: Adding Logging to Existing Feature

**Steps:**
1. Identify the feature name used in existing files
2. Add logging to new operations using the same feature name
3. Follow existing patterns in the feature
4. Test to ensure consistency

**Example:**
```dart
// Existing code in workout_providers.dart uses [Workout]
// New code should also use [Workout]

Future<void> newWorkoutOperation() async {
  if (kDebugMode) {
    print('📊 [Workout] Starting new operation...');
  }
  // ... operation logic ...
}
```

### Scenario 2: Creating New Feature Module

**Steps:**
1. Choose a feature name (e.g., `[Analytics]`)
2. Use it consistently across all files:
   - Data sources: `[AnalyticsData]`
   - Providers: `[Analytics]`
   - Use cases: `[Analytics]`
   - Screens: `[Analytics]`
3. Document the feature name in this guide

### Scenario 3: Logging Complex Workflows

**Pattern:**
```dart
Future<void> complexWorkflow() async {
  try {
    if (kDebugMode) {
      print('📊 [Feature] Starting complex workflow...');
    }
    
    // Step 1
    if (kDebugMode) {
      print('📊 [Feature] Step 1: Loading data...');
    }
    final data = await loadData();
    if (kDebugMode) {
      print('✅ [Feature] Data loaded');
      print('🔍 [Feature] Count: ${data.length}');
    }
    
    // Step 2
    if (kDebugMode) {
      print('📊 [Feature] Step 2: Processing...');
    }
    final processed = await process(data);
    if (kDebugMode) {
      print('✅ [Feature] Processing complete');
    }
    
    // Step 3
    if (kDebugMode) {
      print('📊 [Feature] Step 3: Saving results...');
    }
    await save(processed);
    if (kDebugMode) {
      print('✅ [Feature] Results saved');
    }
    
    if (kDebugMode) {
      print('✅ [Feature] Complex workflow completed');
    }
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('❌ [Feature] Workflow failed: $e');
      print('🔍 [Feature] Stack trace: $stackTrace');
    }
    rethrow;
  }
}
```

### Scenario 4: Logging with Sensitive Data

**Never log:**
- Passwords
- API tokens
- Full email addresses
- Payment information
- Personal health data

**Safe to log:**
- IDs (workout IDs, meal IDs, etc.)
- Counts and summaries
- Timestamps
- Operation names
- Sanitized emails (domain only)

**Example:**
```dart
// BAD - Logs password
if (kDebugMode) {
  print('🔍 [Auth] Email: $email, Password: $password');
}

// GOOD - No sensitive data
if (kDebugMode) {
  print('📊 [Auth] Attempting sign in...');
  print('🔍 [Auth] Email domain: ${email.split('@').last}');
}
```

---

## Checklist

Use this checklist when adding logging to a new feature:

### Planning
- [ ] Chosen consistent feature name
- [ ] Identified all operations to log
- [ ] Reviewed existing patterns in similar features

### Implementation
- [ ] Added logging to all data persistence operations
- [ ] Added logging to all state changes
- [ ] Added logging to all user actions
- [ ] Added logging to all error paths
- [ ] Wrapped all logging in `kDebugMode`
- [ ] Used consistent feature name across all files
- [ ] Used appropriate emojis for each log level
- [ ] Included relevant context (IDs, counts, etc.)
- [ ] Added stack traces to all error logs

### Security
- [ ] No passwords logged
- [ ] No API tokens logged
- [ ] No sensitive user data logged
- [ ] Email addresses sanitized (if logged)

### Testing
- [ ] Tested happy path - all operations logged
- [ ] Tested error paths - errors logged with details
- [ ] Verified log format consistency
- [ ] Verified feature name consistency
- [ ] Verified no excessive logging
- [ ] Tested release build - no logging present

### Documentation
- [ ] Added feature name to this guide
- [ ] Documented any special patterns used
- [ ] Updated related documentation if needed

---

## Quick Reference

### Log Level Decision Tree

```
Is it an error?
├─ Yes → ❌ ERROR with stack trace
└─ No
   ├─ Is it a potential issue?
   │  └─ Yes → ⚠️ WARNING
   └─ No
      ├─ Is it operation start/end?
      │  └─ Yes → 📊 INFO
      └─ No
         ├─ Is it detailed data?
         │  └─ Yes → 🔍 DEBUG
         └─ Is it successful completion?
            └─ Yes → ✅ SUCCESS
```

### Common Patterns Quick Reference

| Operation | Pattern |
|-----------|---------|
| Simple operation | `📊 Starting → ✅ Completed` |
| With details | `📊 Starting → 🔍 Details → ✅ Completed` |
| With error | `📊 Starting → ❌ Failed + 🔍 Stack trace` |
| State change | `📊 Changing → 🔍 Old/New → ✅ Updated` |
| Hive operation | `📊 Operation → Check box → ✅ Success` |
| Multi-step | `📊 Step 1 → ✅ Done → 📊 Step 2 → ✅ Done` |

---

## Related Documentation

- [Main Logging Documentation](./LOGGING.md) - Overview and console output examples
- [Logging Patterns](./LOGGING_PATTERNS.md) - Detailed pattern reference
- [Design Document](../.kiro/specs/debug-logging-system/design.md) - Technical design
- [Requirements](../.kiro/specs/debug-logging-system/requirements.md) - Full requirements

---

## Getting Help

If you have questions about logging:

1. Check the [Logging Patterns](./LOGGING_PATTERNS.md) document for examples
2. Look at existing implementations in similar features
3. Review the [Design Document](../.kiro/specs/debug-logging-system/design.md)
4. Ask the team for guidance

## Contributing

When you add logging to a new feature:

1. Follow this guide
2. Use existing patterns
3. Test thoroughly
4. Update documentation if needed
5. Submit for code review

---

**Remember**: Good logging makes debugging faster, development smoother, and the codebase more maintainable. Take the time to add comprehensive logging to all new features!
