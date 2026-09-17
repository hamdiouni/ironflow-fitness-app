# Integration Tests for Debug Logging System

This directory contains integration tests that verify the debug logging system works correctly and doesn't break application functionality.

## Test Files

### 1. workout_flow_logging_test.dart
Tests the complete workout flow with logging enabled:
- Start workout session
- Add exercises to workout
- Log sets for exercises
- Finish workout
- State restoration after app restart
- Error handling (add exercise without starting workout, log set for non-existent exercise)

**Verifies:**
- All workout operations complete successfully with logging
- Logging doesn't break workout functionality
- State persistence works correctly
- Error paths are logged appropriately

### 2. nutrition_flow_logging_test.dart
Tests the complete nutrition flow with logging enabled:
- Save and retrieve nutrition targets
- Save multiple meals (breakfast, lunch, dinner)
- Get meals by date
- Get specific meal by ID
- Delete meals
- Clear all nutrition data

**Verifies:**
- All nutrition operations complete successfully with logging
- Logging doesn't break nutrition functionality
- Data persistence works correctly
- Error paths are logged appropriately (empty database, missing targets)

### 3. theme_flow_logging_test.dart
Tests the complete theme flow with logging enabled:
- Load initial theme
- Toggle theme between dark and light
- Set theme directly
- Theme persistence across app restarts
- Multiple theme toggles
- Get theme data

**Verifies:**
- All theme operations complete successfully with logging
- Logging doesn't break theme functionality
- Theme persistence works correctly
- Default theme is applied when no saved theme exists

## Running the Tests

### Run all integration tests:
```bash
flutter test integration_test/
```

### Run a specific test file:
```bash
flutter test integration_test/workout_flow_logging_test.dart
flutter test integration_test/nutrition_flow_logging_test.dart
flutter test integration_test/theme_flow_logging_test.dart
```

### Run on a specific device:
```bash
flutter test integration_test/ -d windows
flutter test integration_test/ -d chrome
flutter test integration_test/ -d edge
```

### Run with verbose output:
```bash
flutter test integration_test/ --verbose
```

## Test Structure

Each test file follows this structure:

1. **Setup**: Initialize Firebase and Hive
2. **Test Cases**: Execute operations and verify results
3. **Assertions**: Verify operations complete successfully
4. **Logging Verification**: Console output shows all operations are logged
5. **Teardown**: Clean up test data

## Expected Console Output

When running these tests, you should see structured log output like:

```
📊 [Workout] Starting new workout session...
✅ [Workout] Workout created successfully
🔍 [Workout] Workout ID: abc-123, Start time: 2024-01-15 10:30:00
✅ [Workout] State updated to inProgress
📊 [Workout] Saving workout state to Hive...
✅ [Workout] Workout state saved to Hive
```

This confirms that:
- ✅ Operations complete successfully
- 📊 Operations are tracked
- 🔍 Detailed data is logged
- ❌ Errors are caught and logged
- ⚠️ Warnings are displayed

## Success Criteria

All tests pass if:
1. ✅ All operations complete without errors
2. ✅ Logging doesn't break functionality
3. ✅ Data persists correctly to Hive
4. ✅ Error paths are handled gracefully
5. ✅ Console shows structured log output

## Troubleshooting

### Tests fail with "Box not open" error
- Ensure HiveManager.initialize() is called in setUpAll()
- Check that Hive boxes are opened before use

### Tests fail with Firebase errors
- Ensure Firebase is initialized in setUpAll()
- Check that firebase_options.dart exists

### Tests timeout
- Increase timeout value in test configuration
- Check for blocking operations in the code

## Notes

- These tests verify that logging is **non-intrusive** - it should not affect application behavior
- All logging is wrapped in print statements for console output
- Tests use real Hive storage (not mocked) to verify persistence
- Tests clean up data in setUp() to ensure isolation
