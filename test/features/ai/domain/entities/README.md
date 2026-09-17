# AI Domain Entities Unit Tests

## Overview

This directory contains comprehensive unit tests for the AI domain entities as part of Task 1.1 of the Global AI Coach feature implementation.

**Task:** 1.1 Write unit tests for domain entities  
**Requirements:** 1.1, 3.1  
**Status:** ✅ Completed

## Test Coverage

### 1. Insight Entity Tests (`insight_test.dart`)

**Total Tests:** 20

#### Test Groups:

1. **Creation and Properties** (3 tests)
   - Creating Insight with all required fields
   - Creating Insight with empty metadata by default
   - Immutability verification (freezed)

2. **JSON Serialization** (5 tests)
   - Serialization to JSON
   - Deserialization from JSON
   - Handling empty metadata
   - Round-trip serialization without data loss
   - Complex nested metadata handling

3. **Enum Conversions** (6 tests)
   - **InsightContext enum:**
     - Converting all 4 values (home, workout, nutrition, profile) to/from JSON
     - Verifying exactly 4 enum values exist
   - **InsightPriority enum:**
     - Converting all 3 values (high, medium, low) to/from JSON
     - Verifying exactly 3 enum values exist
     - Verifying priority order (high > medium > low)

4. **Edge Cases** (4 tests)
   - Special characters in strings (quotes, newlines, tabs)
   - Very long strings (1000+ characters)
   - Complex nested metadata structures
   - Various date formats (start/end of year, UTC, with milliseconds)
   - Empty strings

5. **Equality and Comparison** (2 tests)
   - Equality when all fields match
   - Inequality when fields differ

### 2. InsightCache Entity Tests (`insight_cache_test.dart`)

**Total Tests:** 21

#### Test Groups:

1. **Creation and Properties** (5 tests)
   - Creating InsightCache with all required fields
   - Creating with empty insights list
   - Creating with single insight
   - Creating with multiple insights (3)
   - Immutability verification (freezed)

2. **JSON Serialization** (5 tests)
   - Serialization to JSON
   - Deserialization from JSON
   - Handling empty insights list
   - Handling multiple insights
   - Round-trip serialization without data loss

3. **Data Timestamps** (3 tests)
   - Tracking multiple data source timestamps
   - Handling empty data timestamps
   - Preserving timestamp precision

4. **Context-Specific Caches** (2 tests)
   - Creating cache for each InsightContext
   - Allowing insights with different contexts in cache

5. **Edge Cases** (4 tests)
   - Very old cached timestamps (2020)
   - Future timestamps (2030)
   - Large number of insights (100)
   - Many data source timestamps (50)
   - Insights with complex metadata

6. **Equality and Comparison** (2 tests)
   - Equality when all fields match
   - Inequality when fields differ

## Test Statistics

- **Total Tests:** 41
- **Pass Rate:** 100%
- **Coverage Areas:**
  - ✅ Entity creation and immutability
  - ✅ JSON serialization/deserialization
  - ✅ Enum conversions (InsightContext, InsightPriority)
  - ✅ Data integrity and round-trip serialization
  - ✅ Edge cases (empty data, large data, special characters)
  - ✅ Timestamp handling and precision
  - ✅ Equality and comparison

## Key Testing Patterns

### 1. Arrange-Act-Assert (AAA) Pattern
All tests follow the AAA pattern for clarity:
```dart
test('should create Insight with all required fields', () {
  // ARRANGE
  final insight = Insight(...);
  
  // ACT
  final result = insight.toJson();
  
  // ASSERT
  expect(result['id'], equals('insight-1'));
});
```

### 2. Comprehensive Enum Testing
All enum values are tested for:
- Correct serialization to string
- Correct deserialization from string
- Exact count of enum values
- Proper ordering (for priority)

### 3. Round-Trip Serialization
Every entity is tested for:
```dart
original → toJson() → fromJson() → deserialized
expect(deserialized == original)
```

### 4. Edge Case Coverage
Tests include:
- Empty collections
- Large collections (100+ items)
- Special characters and Unicode
- Extreme dates (past and future)
- Complex nested structures

## Running the Tests

### Run all AI entity tests:
```bash
flutter test test/features/ai/domain/entities/
```

### Run specific test file:
```bash
flutter test test/features/ai/domain/entities/insight_test.dart
flutter test test/features/ai/domain/entities/insight_cache_test.dart
```

### Run with coverage:
```bash
flutter test --coverage test/features/ai/domain/entities/
```

## Requirements Validation

### Requirement 1.1: Global Insight Engine
✅ **Validated:** Tests verify that Insight entities can be created with all required fields including context, priority, and metadata for data-driven insights.

### Requirement 3.1: Global AI Provider
✅ **Validated:** Tests verify that InsightCache entities can store and retrieve insights for each context (Home, Workout, Nutrition, Profile) with proper timestamp tracking.

## Next Steps

After Task 1.1 completion, the next tasks are:
- **Task 2:** Define service interfaces
- **Task 3:** Implement AIInsightsEngine core logic
- **Task 3.7:** Write unit tests for AIInsightsEngine

## Notes

- All tests use the `flutter_test` package
- Tests follow the project's existing testing patterns (see `test/features/analytics/`)
- Freezed is used for immutable data classes
- JSON serialization is handled by `json_serializable`
- All entities use proper enum serialization for type safety
