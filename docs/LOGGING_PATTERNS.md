# Logging Patterns Reference

This document provides a comprehensive reference of logging patterns used throughout the IronFlow codebase. Use these patterns as templates when adding logging to new features.

## Table of Contents

1. [Basic Operation Logging](#basic-operation-logging)
2. [Hive Operations](#hive-operations)
3. [State Management](#state-management)
4. [Error Handling](#error-handling)
5. [Data Persistence](#data-persistence)
6. [Async Operations](#async-operations)
7. [Complex Workflows](#complex-workflows)

---

## Basic Operation Logging

### Simple Operation

**Pattern**: Log start → Execute → Log success

```dart
Future<void> simpleOperation() async {
  print('📊 [Feature] Starting operation...');
  
  // Execute operation
  final result = await doSomething();
  
  print('✅ [Feature] Operation completed successfully');
}
```

**Example from codebase** (`hive_manager.dart`):
```dart
static Future<void> initialize() async {
  print('📊 [Hive] Initializing Hive...');
  await Hive.initFlutter();
  print('✅ [Hive] Hive initialized successfully');
}
```

---

### Operation with Details

**Pattern**: Log start → Log details → Execute → Log success → Log result details

```dart
Future<void> operationWithDetails(String id, String type) async {
  print('📊 [Feature] Starting operation...');
  print('🔍 [Feature] ID: $id, Type: $type');
  
  final result = await doSomething(id, type);
  
  print('✅ [Feature] Operation completed successfully');
  print('🔍 [Feature] Result: ${result.summary}');
}
```

**Example from codebase** (`workout_providers.dart`):
```dart
Future<void> start() async {
  print('📊 [Workout] Starting new workout session...');
  
  final workout = await _startWorkout();
  final startTime = DateTime.now();
  
  print('✅ [Workout] Workout created successfully');
  print('🔍 [Workout] Workout ID: ${workout.id}, Start time: $startTime');
  
  state = WorkoutState.inProgress(workout, startTime);
  print('✅ [Workout] State updated to inProgress');
}
```

---

## Hive Operations

### Box Opening

**Pattern**: Log opening → Open box → Log success

```dart
Future<void> openBox(String boxName) async {
  print('📊 [Hive] Opening box: $boxName...');
  await Hive.openBox<Map>(boxName);
  print('✅ [Hive] Box opened: $boxName');
}
```

**Example from codebase** (`hive_manager.dart`):
```dart
for (final boxName in boxes) {
  print('📊 [Hive] Opening box: $boxName...');
  await Hive.openBox<Map>(boxName);
  print('✅ [Hive] Box opened: $boxName');
}
```

---

### Box State Check

**Pattern**: Check box state → Log warning if not open → Proceed or throw

```dart
Future<void> saveData(String key, dynamic value) async {
  print('📊 [Feature] Saving data...');
  
  if (!_box.isOpen) {
    print('⚠️ [Feature] Box is not open');
    throw Exception('Box not open');
  }
  
  await _box.put(key, value);
  print('✅ [Feature] Data saved successfully');
}
```

**Example from codebase** (`hive_nutrition_datasource.dart`):
```dart
Future<void> saveMealEntry(MealModel meal) async {
  print('📊 [NutritionData] Saving meal entry...');
  print('🔍 [NutritionData] Meal ID: ${meal.id}, Type: ${meal.type}');
  
  if (!_mealsBox.isOpen) {
    print('⚠️ [NutritionData] Meals box is not open');
    throw Exception('Meals box not open');
  }
  
  await _mealsBox.put(meal.id, meal.toJson());
  print('✅ [NutritionData] Meal saved successfully');
}
```

---

### Box Read Operation

**Pattern**: Log read → Check box → Read data → Log result

```dart
Future<T?> getData(String key) async {
  print('📊 [Feature] Reading data...');
  print('🔍 [Feature] Key: $key');
  
  if (!_box.isOpen) {
    print('⚠️ [Feature] Box is not open');
    throw Exception('Box not open');
  }
  
  final data = _box.get(key);
  
  if (data == null) {
    print('⚠️ [Feature] Data not found');
    return null;
  }
  
  print('✅ [Feature] Data retrieved successfully');
  return data;
}
```

**Example from codebase** (`hive_nutrition_datasource.dart`):
```dart
Future<MealModel?> getMealById(String mealId) async {
  print('📊 [NutritionData] Getting meal by ID...');
  print('🔍 [NutritionData] Meal ID: $mealId');
  
  if (!_mealsBox.isOpen) {
    print('⚠️ [NutritionData] Meals box is not open');
    throw Exception('Meals box not open');
  }
  
  final json = _mealsBox.get(mealId);
  
  if (json == null) {
    print('⚠️ [NutritionData] Meal not found');
    return null;
  }
  
  final meal = MealModel.fromJson(_deepCast(json));
  print('✅ [NutritionData] Meal retrieved successfully');
  print('🔍 [NutritionData] Type: ${meal.type}, Calories: ${meal.totalCalories}');
  
  return meal;
}
```

---

## State Management

### State Change

**Pattern**: Log state change → Update state → Log new state

```dart
void updateState(NewState newState) {
  print('📊 [Feature] State changing...');
  print('🔍 [Feature] Old state: $state');
  
  state = newState;
  
  print('✅ [Feature] State updated');
  print('🔍 [Feature] New state: $state');
}
```

**Example from codebase** (`workout_providers.dart`):
```dart
state = WorkoutState.inProgress(workout, startTime);
print('✅ [Workout] State updated to inProgress');
```

---

### State Restoration

**Pattern**: Log restoration → Restore state → Log result

```dart
Future<bool> restoreState() async {
  print('📊 [Feature] Restoring state...');
  
  final saved = await _loadSavedState();
  
  if (saved != null) {
    print('✅ [Feature] State restored successfully');
    print('🔍 [Feature] Details: ${saved.summary}');
    state = saved;
    return true;
  } else {
    print('📊 [Feature] No saved state found');
    return false;
  }
}
```

**Example from codebase** (`workout_providers.dart`):
```dart
Future<bool> restoreState() async {
  print('📊 [Workout] Restoring workout state...');
  
  await _stateManager.init();
  print('✅ [Workout] State manager initialized');
  
  final saved = await _stateManager.restoreState();
  if (saved != null) {
    print('✅ [Workout] Workout state restored from Hive');
    print('🔍 [Workout] Workout ID: ${saved.workout.id}, Start time: ${saved.startTime}');
    print('🔍 [Workout] Exercises: ${saved.workout.exercises.length}');
    
    state = WorkoutState.inProgress(saved.workout, saved.startTime);
    print('✅ [Workout] State updated to inProgress');
    return true;
  } else {
    print('📊 [Workout] No saved workout state found');
    return false;
  }
}
```

---

## Error Handling

### Try-Catch with Logging

**Pattern**: Log start → Try operation → Log success OR catch → Log error → Rethrow

```dart
Future<void> operationWithErrorHandling() async {
  try {
    print('📊 [Feature] Starting operation...');
    
    await doSomething();
    
    print('✅ [Feature] Operation completed successfully');
  } catch (e, stackTrace) {
    print('❌ [Feature] Operation failed: $e');
    print('🔍 [Feature] Stack trace: $stackTrace');
    rethrow;
  }
}
```

**Example from codebase** (`hive_manager.dart`):
```dart
static Future<void> initialize() async {
  try {
    print('📊 [Hive] Initializing Hive...');
    await Hive.initFlutter();
    print('✅ [Hive] Hive initialized successfully');
    
    // ... box opening logic ...
    
    print('✅ [Hive] All boxes opened successfully');
  } catch (e, stackTrace) {
    print('❌ [Hive] Failed to initialize: $e');
    print('🔍 [Hive] Stack trace: $stackTrace');
    throw Exception('Failed to initialize Hive: $e');
  }
}
```

---

### Conditional Error Logging

**Pattern**: Check condition → Log warning → Handle gracefully

```dart
Future<void> conditionalOperation() async {
  print('📊 [Feature] Starting operation...');
  
  if (!isReady) {
    print('⚠️ [Feature] Not ready, skipping operation');
    return;
  }
  
  await doSomething();
  print('✅ [Feature] Operation completed');
}
```

**Example from codebase** (`workout_providers.dart`):
```dart
Future<void> addExercise(Exercise exercise) async {
  print('📊 [Workout] Adding exercise to workout...');
  
  final current = state;
  if (current is! _InProgress) {
    print('⚠️ [Workout] Cannot add exercise: workout not in progress');
    return;
  }
  
  // ... rest of logic ...
}
```

---

## Data Persistence

### Save Operation

**Pattern**: Log save → Log data details → Save → Log success → Log summary

```dart
Future<void> saveData(DataModel data) async {
  print('📊 [Feature] Saving data...');
  print('🔍 [Feature] ID: ${data.id}, Type: ${data.type}');
  
  await _repository.save(data);
  
  print('✅ [Feature] Data saved successfully');
  print('🔍 [Feature] Summary: ${data.summary}');
}
```

**Example from codebase** (`hive_nutrition_datasource.dart`):
```dart
Future<void> saveMealEntry(MealModel meal) async {
  print('📊 [NutritionData] Saving meal entry...');
  print('🔍 [NutritionData] Meal ID: ${meal.id}, Type: ${meal.type}');
  
  if (!_mealsBox.isOpen) {
    print('⚠️ [NutritionData] Meals box is not open');
    throw Exception('Meals box not open');
  }
  
  await _mealsBox.put(meal.id, meal.toJson());
  
  print('✅ [NutritionData] Meal saved successfully');
  print('🔍 [NutritionData] Total calories: ${meal.totalCalories}, Items: ${meal.items.length}');
}
```

---

### Query Operation

**Pattern**: Log query → Log parameters → Execute → Log results

```dart
Future<List<T>> queryData(DateTime date) async {
  print('📊 [Feature] Querying data...');
  print('🔍 [Feature] Date: ${date.toIso8601String()}');
  
  final results = await _repository.query(date);
  
  print('✅ [Feature] Query completed successfully');
  print('🔍 [Feature] Found ${results.length} items');
  
  return results;
}
```

**Example from codebase** (`hive_nutrition_datasource.dart`):
```dart
Future<List<MealModel>> getMealsByDate(DateTime date) async {
  print('📊 [NutritionData] Getting meals by date...');
  print('🔍 [NutritionData] Date: ${date.year}-${date.month}-${date.day}');
  
  if (!_mealsBox.isOpen) {
    print('⚠️ [NutritionData] Meals box is not open');
    throw Exception('Meals box not open');
  }
  
  final meals = _mealsBox.values
      .map((json) => MealModel.fromJson(_deepCast(json)))
      .where((meal) {
        final mealDate = DateTime.parse(meal.timestamp);
        return mealDate.year == date.year &&
            mealDate.month == date.month &&
            mealDate.day == date.day;
      })
      .toList();
  
  print('✅ [NutritionData] Meals retrieved successfully');
  print('🔍 [NutritionData] Found ${meals.length} meals for date');
  
  return meals;
}
```

---

### Delete Operation

**Pattern**: Log delete → Log target → Delete → Log success

```dart
Future<void> deleteData(String id) async {
  print('📊 [Feature] Deleting data...');
  print('🔍 [Feature] ID: $id');
  
  await _repository.delete(id);
  
  print('✅ [Feature] Data deleted successfully');
}
```

**Example from codebase** (`hive_nutrition_datasource.dart`):
```dart
Future<void> deleteMealEntry(String mealId) async {
  print('📊 [NutritionData] Deleting meal entry...');
  print('🔍 [NutritionData] Meal ID: $mealId');
  
  if (!_mealsBox.isOpen) {
    print('⚠️ [NutritionData] Meals box is not open');
    throw Exception('Meals box not open');
  }
  
  await _mealsBox.delete(mealId);
  
  print('✅ [NutritionData] Meal deleted successfully');
}
```

---

## Async Operations

### Sequential Operations

**Pattern**: Log each step → Execute → Log completion

```dart
Future<void> sequentialOperations() async {
  print('📊 [Feature] Starting multi-step operation...');
  
  print('📊 [Feature] Step 1: Loading data...');
  final data = await loadData();
  print('✅ [Feature] Data loaded');
  
  print('📊 [Feature] Step 2: Processing data...');
  final processed = await processData(data);
  print('✅ [Feature] Data processed');
  
  print('📊 [Feature] Step 3: Saving results...');
  await saveResults(processed);
  print('✅ [Feature] Results saved');
  
  print('✅ [Feature] Multi-step operation completed');
}
```

**Example from codebase** (`workout_providers.dart`):
```dart
Future<void> finish() async {
  print('📊 [Workout] Finishing workout...');
  
  final current = state;
  if (current is! _InProgress) {
    print('⚠️ [Workout] Cannot finish: workout not in progress');
    return;
  }

  final duration = DateTime.now().difference(current.startTime);
  print('🔍 [Workout] Workout duration: ${duration.inMinutes} minutes');
  
  print('📊 [Workout] Saving workout to repository...');
  await _saveWorkout(current.workout, duration);
  print('✅ [Workout] Workout saved successfully');
  
  print('📊 [Workout] Clearing active workout state...');
  await _stateManager.clearState();
  print('✅ [Workout] Active state cleared from Hive');
  
  state = WorkoutState.completed(current.workout);
  print('✅ [Workout] State updated to completed');
}
```

---

### Parallel Operations

**Pattern**: Log start → Execute in parallel → Log completion

```dart
Future<void> parallelOperations() async {
  print('📊 [Feature] Starting parallel operations...');
  
  await Future.wait([
    operation1(),
    operation2(),
    operation3(),
  ]);
  
  print('✅ [Feature] All parallel operations completed');
}
```

**Example from codebase** (`hive_manager.dart`):
```dart
static Future<void> clearAll() async {
  try {
    print('📊 [Hive] Clearing all boxes...');
    
    for (final boxName in boxNames) {
      print('📊 [Hive] Clearing box: $boxName...');
    }
    
    await Future.wait([
      Hive.box(_workoutBox).clear(),
      Hive.box(_nutritionBox).clear(),
      // ... more boxes ...
    ]);
    
    print('✅ [Hive] All boxes cleared successfully');
  } catch (e, stackTrace) {
    print('❌ [Hive] Failed to clear boxes: $e');
    print('🔍 [Hive] Stack trace: $stackTrace');
    throw Exception('Failed to clear Hive boxes: $e');
  }
}
```

---

## Complex Workflows

### Multi-Entity Operation

**Pattern**: Log workflow → Log each entity → Log relationships → Log completion

```dart
Future<void> complexWorkflow() async {
  print('📊 [Feature] Starting complex workflow...');
  
  print('📊 [Feature] Creating parent entity...');
  final parent = await createParent();
  print('✅ [Feature] Parent created');
  print('🔍 [Feature] Parent ID: ${parent.id}');
  
  print('📊 [Feature] Creating child entities...');
  for (final childData in childrenData) {
    final child = await createChild(childData);
    print('✅ [Feature] Child created: ${child.id}');
  }
  print('🔍 [Feature] Total children: ${childrenData.length}');
  
  print('📊 [Feature] Linking entities...');
  await linkEntities(parent, children);
  print('✅ [Feature] Entities linked');
  
  print('✅ [Feature] Complex workflow completed');
}
```

**Example from codebase** (`workout_providers.dart`):
```dart
Future<bool> logSetForExercise(String exerciseId, SetEntry set) async {
  print('📊 [Workout] Logging set for exercise...');
  print('🔍 [Workout] Exercise ID: $exerciseId');
  print('🔍 [Workout] Reps: ${set.reps}, Weight: ${set.weight}kg');
  
  final current = state;
  if (current is! _InProgress) {
    print('⚠️ [Workout] Cannot log set: workout not in progress');
    return false;
  }

  final workout = current.workout;
  final exerciseIndex = workout.exercises.indexWhere((e) => e.id == exerciseId);
  
  if (exerciseIndex == -1) {
    print('⚠️ [Workout] Exercise not found in workout');
    return false;
  }

  final exercise = workout.exercises[exerciseIndex];
  print('🔍 [Workout] Exercise name: ${exercise.name}');

  final updatedExercise = await _logSet(exercise, set);
  print('✅ [Workout] Set logged successfully');
  print('🔍 [Workout] Total sets for exercise: ${updatedExercise.sets.length}');

  final isPR = await _detectPR(exercise.name, set);
  if (isPR) {
    print('✅ [Workout] New PR detected!');
    print('🔍 [Workout] PR: ${set.reps} reps @ ${set.weight}kg');
  } else {
    print('📊 [Workout] No PR detected');
  }

  // ... state update and persistence ...
  
  return isPR;
}
```

---

## Anti-Patterns (What NOT to Do)

### ❌ Don't Log Sensitive Data

```dart
// BAD - Logs password
print('🔍 [Auth] Password: $password');

// GOOD - Never log passwords
print('📊 [Auth] Attempting sign in...');
```

### ❌ Don't Log Without Context

```dart
// BAD - No feature name or context
print('Saving...');

// GOOD - Clear feature and operation
print('📊 [Workout] Saving workout to repository...');
```

### ❌ Don't Use Inconsistent Emojis

```dart
// BAD - Wrong emoji for error
print('✅ [Feature] Operation failed');

// GOOD - Correct emoji for error
print('❌ [Feature] Operation failed: $error');
```

### ❌ Don't Skip Error Logging

```dart
// BAD - Silent failure
try {
  await operation();
} catch (e) {
  // No logging
}

// GOOD - Log all errors
try {
  await operation();
} catch (e, stackTrace) {
  print('❌ [Feature] Operation failed: $e');
  print('🔍 [Feature] Stack trace: $stackTrace');
  rethrow;
}
```

### ❌ Don't Log in Production

```dart
// BAD - Always logs
print('📊 [Feature] Operation...');

// GOOD - Only in debug mode
if (kDebugMode) {
  print('📊 [Feature] Operation...');
}
```

---

## Quick Reference

| Pattern | When to Use | Example |
|---------|-------------|---------|
| Start-End | Simple operations | `📊 Starting... → ✅ Completed` |
| Start-Details-End | Operations with data | `📊 Starting... → 🔍 Details → ✅ Completed` |
| Try-Catch | Error-prone operations | `try { ... } catch { ❌ Failed }` |
| State Check | Before state operations | `if (!ready) { ⚠️ Warning }` |
| Multi-Step | Sequential operations | `📊 Step 1 → ✅ Done → 📊 Step 2` |
| Query-Result | Data queries | `📊 Querying → ✅ Found X items` |

---

## Related Documentation

- [Main Logging Documentation](./LOGGING.md)
- [Developer Guide](./LOGGING_DEVELOPER_GUIDE.md)
- [Design Document](../.kiro/specs/debug-logging-system/design.md)
