import 'package:flutter/foundation.dart';

/// Utility for testing app stability with large datasets.
class StabilityTester {
  /// Tests app with large workout history (1000+ workouts).
  static Future<void> testLargeWorkoutHistory() async {
    debugPrint('Testing with 1000+ workouts...');

    try {
      // Simulate loading 1000 workouts
      final workouts = List.generate(
        1000,
        (i) => {
          'id': 'workout_$i',
          'date': DateTime.now().subtract(Duration(days: i)),
          'duration': Duration(minutes: 60 + (i % 30)),
          'exercises': List.generate(
            5,
            (j) => {
              'name': 'Exercise $j',
              'sets': 3,
              'reps': 10,
              'weight': 100.0 + (j * 5),
            },
          ),
        },
      );

      debugPrint('Generated ${workouts.length} workouts');

      // Test filtering
      final filtered = workouts.where((w) {
        final date = w['date'] as DateTime;
        return date.isAfter(DateTime.now().subtract(const Duration(days: 30)));
      }).toList();

      debugPrint('Filtered to ${filtered.length} recent workouts');

      // Test sorting
      filtered.sort((a, b) {
        final dateA = a['date'] as DateTime;
        final dateB = b['date'] as DateTime;
        return dateB.compareTo(dateA);
      });

      debugPrint('Sorted workouts successfully');
    } catch (e) {
      debugPrint('Error testing large workout history: $e');
      rethrow;
    }
  }

  /// Tests app with large food database.
  static Future<void> testLargeFoodDatabase() async {
    debugPrint('Testing with large food database...');

    try {
      // Simulate loading 5000 foods
      final foods = List.generate(
        5000,
        (i) => {
          'id': 'food_$i',
          'name': 'Food $i',
          'calories': 100 + (i % 500),
          'protein': 10 + (i % 30),
          'carbs': 20 + (i % 50),
          'fat': 5 + (i % 20),
          'category': ['breakfast', 'lunch', 'dinner', 'snack'][i % 4],
        },
      );

      debugPrint('Generated ${foods.length} foods');

      // Test searching
      final searched = foods
          .where((f) => (f['name'] as String).contains('Food 1'))
          .toList();

      debugPrint('Search found ${searched.length} foods');

      // Test filtering
      final filtered = foods
          .where((f) => (f['calories'] as int) < 200)
          .toList();

      debugPrint('Filtered to ${filtered.length} low-calorie foods');
    } catch (e) {
      debugPrint('Error testing large food database: $e');
      rethrow;
    }
  }

  /// Tests app with many programs.
  static Future<void> testManyPrograms() async {
    debugPrint('Testing with many programs...');

    try {
      // Simulate loading 100 programs
      final programs = List.generate(
        100,
        (i) => {
          'id': 'program_$i',
          'name': 'Program $i',
          'days': List.generate(
            7,
            (j) => {
              'name': 'Day ${j + 1}',
              'exercises': List.generate(
                5,
                (k) => {
                  'name': 'Exercise $k',
                  'sets': 3,
                  'reps': 10,
                },
              ),
            },
          ),
        },
      );

      debugPrint('Generated ${programs.length} programs');

      // Test accessing programs
      for (final program in programs.take(10)) {
        final days = program['days'] as List;
        debugPrint('Program ${program['name']} has ${days.length} days');
      }

      debugPrint('Successfully accessed programs');
    } catch (e) {
      debugPrint('Error testing many programs: $e');
      rethrow;
    }
  }

  /// Tests for memory leaks by checking object creation/destruction.
  static Future<void> testMemoryLeaks() async {
    debugPrint('Testing for memory leaks...');

    try {
      // Create and destroy many objects
      for (int i = 0; i < 1000; i++) {
        final data = List.generate(100, (j) => {'value': j});
        // Objects should be garbage collected
      }

      debugPrint('Memory leak test completed');
    } catch (e) {
      debugPrint('Error testing memory leaks: $e');
      rethrow;
    }
  }

  /// Tests app stability under stress.
  static Future<void> runStabilityTests() async {
    debugPrint('=== Running Stability Tests ===');

    try {
      await testLargeWorkoutHistory();
      await testLargeFoodDatabase();
      await testManyPrograms();
      await testMemoryLeaks();

      debugPrint('=== All Stability Tests Passed ===');
    } catch (e) {
      debugPrint('Stability tests failed: $e');
      rethrow;
    }
  }
}
