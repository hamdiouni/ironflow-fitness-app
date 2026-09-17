import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';

/// Unit tests for Insight domain entity
/// 
/// **Task 1.1: Write unit tests for domain entities**
/// **Validates: Requirements 1.1, 3.1**
/// 
/// This test suite verifies:
/// - Insight entity creation and immutability
/// - JSON serialization and deserialization
/// - Enum conversions (InsightContext, InsightPriority)
/// - Edge cases and data integrity
void main() {
  group('Insight Entity', () {
    group('Creation and Properties', () {
      test('should create Insight with all required fields', () {
        // ARRANGE & ACT
        final insight = Insight(
          id: 'insight-1',
          context: InsightContext.home,
          title: 'Great Progress!',
          message: 'You have completed 5 workouts this week.',
          icon: '💪',
          priority: InsightPriority.high,
          generatedAt: DateTime(2024, 1, 15, 10, 30),
          metadata: {'workoutCount': 5},
        );

        // ASSERT
        expect(insight.id, equals('insight-1'));
        expect(insight.context, equals(InsightContext.home));
        expect(insight.title, equals('Great Progress!'));
        expect(insight.message, equals('You have completed 5 workouts this week.'));
        expect(insight.icon, equals('💪'));
        expect(insight.priority, equals(InsightPriority.high));
        expect(insight.generatedAt, equals(DateTime(2024, 1, 15, 10, 30)));
        expect(insight.metadata, equals({'workoutCount': 5}));
      });

      test('should create Insight with empty metadata by default', () {
        // ARRANGE & ACT
        final insight = Insight(
          id: 'insight-2',
          context: InsightContext.workout,
          title: 'Keep Going',
          message: 'Consistency is key.',
          icon: '🔥',
          priority: InsightPriority.medium,
          generatedAt: DateTime(2024, 1, 15),
        );

        // ASSERT
        expect(insight.metadata, equals({}));
      });

      test('should be immutable (freezed)', () {
        // ARRANGE
        final insight = Insight(
          id: 'insight-3',
          context: InsightContext.nutrition,
          title: 'Protein Goal',
          message: 'You need 20g more protein today.',
          icon: '🍗',
          priority: InsightPriority.high,
          generatedAt: DateTime(2024, 1, 15),
        );

        // ACT & ASSERT
        // Freezed creates immutable objects, so we can only create copies
        final updatedInsight = insight.copyWith(title: 'Updated Title');
        
        expect(insight.title, equals('Protein Goal'));
        expect(updatedInsight.title, equals('Updated Title'));
        expect(insight.id, equals(updatedInsight.id)); // Other fields unchanged
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        // ARRANGE
        final insight = Insight(
          id: 'insight-4',
          context: InsightContext.profile,
          title: 'Weight Trend',
          message: 'You lost 2kg this month.',
          icon: '📉',
          priority: InsightPriority.medium,
          generatedAt: DateTime(2024, 1, 15, 12, 0),
          metadata: {'weightChange': -2.0, 'period': 'month'},
        );

        // ACT
        final json = insight.toJson();

        // ASSERT
        expect(json['id'], equals('insight-4'));
        expect(json['context'], equals('profile'));
        expect(json['title'], equals('Weight Trend'));
        expect(json['message'], equals('You lost 2kg this month.'));
        expect(json['icon'], equals('📉'));
        expect(json['priority'], equals('medium'));
        expect(json['generatedAt'], equals('2024-01-15T12:00:00.000'));
        expect(json['metadata'], equals({'weightChange': -2.0, 'period': 'month'}));
      });

      test('should deserialize from JSON correctly', () {
        // ARRANGE
        final json = {
          'id': 'insight-5',
          'context': 'workout',
          'title': 'PR Alert',
          'message': 'New personal record on bench press!',
          'icon': '🏆',
          'priority': 'high',
          'generatedAt': '2024-01-15T14:30:00.000',
          'metadata': {'exercise': 'Bench Press', 'weight': 100.0},
        };

        // ACT
        final insight = Insight.fromJson(json);

        // ASSERT
        expect(insight.id, equals('insight-5'));
        expect(insight.context, equals(InsightContext.workout));
        expect(insight.title, equals('PR Alert'));
        expect(insight.message, equals('New personal record on bench press!'));
        expect(insight.icon, equals('🏆'));
        expect(insight.priority, equals(InsightPriority.high));
        expect(insight.generatedAt, equals(DateTime(2024, 1, 15, 14, 30)));
        expect(insight.metadata, equals({'exercise': 'Bench Press', 'weight': 100.0}));
      });

      test('should handle empty metadata in JSON serialization', () {
        // ARRANGE
        final insight = Insight(
          id: 'insight-6',
          context: InsightContext.home,
          title: 'Welcome',
          message: 'Start your fitness journey today!',
          icon: '👋',
          priority: InsightPriority.low,
          generatedAt: DateTime(2024, 1, 15),
        );

        // ACT
        final json = insight.toJson();
        final deserialized = Insight.fromJson(json);

        // ASSERT
        expect(json['metadata'], equals({}));
        expect(deserialized.metadata, equals({}));
      });

      test('should round-trip through JSON without data loss', () {
        // ARRANGE
        final original = Insight(
          id: 'insight-7',
          context: InsightContext.nutrition,
          title: 'Macro Balance',
          message: 'Your protein intake is 85% of target.',
          icon: '⚖️',
          priority: InsightPriority.medium,
          generatedAt: DateTime(2024, 1, 15, 16, 45, 30),
          metadata: {
            'proteinPercent': 85.0,
            'proteinTarget': 150.0,
            'proteinActual': 127.5,
          },
        );

        // ACT
        final json = original.toJson();
        final deserialized = Insight.fromJson(json);

        // ASSERT
        expect(deserialized.id, equals(original.id));
        expect(deserialized.context, equals(original.context));
        expect(deserialized.title, equals(original.title));
        expect(deserialized.message, equals(original.message));
        expect(deserialized.icon, equals(original.icon));
        expect(deserialized.priority, equals(original.priority));
        expect(deserialized.generatedAt, equals(original.generatedAt));
        expect(deserialized.metadata, equals(original.metadata));
      });
    });

    group('Enum Conversions', () {
      group('InsightContext', () {
        test('should convert all InsightContext values to/from JSON', () {
          // ARRANGE
          final contexts = [
            InsightContext.home,
            InsightContext.workout,
            InsightContext.nutrition,
            InsightContext.profile,
          ];

          final expectedStrings = ['home', 'workout', 'nutrition', 'profile'];

          for (var i = 0; i < contexts.length; i++) {
            // ACT
            final insight = Insight(
              id: 'test-$i',
              context: contexts[i],
              title: 'Test',
              message: 'Test message',
              icon: '✅',
              priority: InsightPriority.low,
              generatedAt: DateTime(2024, 1, 15),
            );

            final json = insight.toJson();
            final deserialized = Insight.fromJson(json);

            // ASSERT
            expect(json['context'], equals(expectedStrings[i]),
                reason: 'Context ${contexts[i]} should serialize to ${expectedStrings[i]}');
            expect(deserialized.context, equals(contexts[i]),
                reason: 'Context string ${expectedStrings[i]} should deserialize to ${contexts[i]}');
          }
        });

        test('should have exactly 4 InsightContext values', () {
          // ACT
          final values = InsightContext.values;

          // ASSERT
          expect(values.length, equals(4),
              reason: 'InsightContext should have exactly 4 values');
          expect(values, contains(InsightContext.home));
          expect(values, contains(InsightContext.workout));
          expect(values, contains(InsightContext.nutrition));
          expect(values, contains(InsightContext.profile));
        });
      });

      group('InsightPriority', () {
        test('should convert all InsightPriority values to/from JSON', () {
          // ARRANGE
          final priorities = [
            InsightPriority.high,
            InsightPriority.medium,
            InsightPriority.low,
          ];

          final expectedStrings = ['high', 'medium', 'low'];

          for (var i = 0; i < priorities.length; i++) {
            // ACT
            final insight = Insight(
              id: 'test-$i',
              context: InsightContext.home,
              title: 'Test',
              message: 'Test message',
              icon: '✅',
              priority: priorities[i],
              generatedAt: DateTime(2024, 1, 15),
            );

            final json = insight.toJson();
            final deserialized = Insight.fromJson(json);

            // ASSERT
            expect(json['priority'], equals(expectedStrings[i]),
                reason: 'Priority ${priorities[i]} should serialize to ${expectedStrings[i]}');
            expect(deserialized.priority, equals(priorities[i]),
                reason: 'Priority string ${expectedStrings[i]} should deserialize to ${priorities[i]}');
          }
        });

        test('should have exactly 3 InsightPriority values', () {
          // ACT
          final values = InsightPriority.values;

          // ASSERT
          expect(values.length, equals(3),
              reason: 'InsightPriority should have exactly 3 values');
          expect(values, contains(InsightPriority.high));
          expect(values, contains(InsightPriority.medium));
          expect(values, contains(InsightPriority.low));
        });

        test('should maintain priority order (high > medium > low)', () {
          // ACT
          final values = InsightPriority.values;

          // ASSERT
          expect(values.indexOf(InsightPriority.high), equals(0),
              reason: 'High priority should be first');
          expect(values.indexOf(InsightPriority.medium), equals(1),
              reason: 'Medium priority should be second');
          expect(values.indexOf(InsightPriority.low), equals(2),
              reason: 'Low priority should be last');
        });
      });
    });

    group('Edge Cases', () {
      test('should handle special characters in strings', () {
        // ARRANGE
        final insight = Insight(
          id: 'insight-special',
          context: InsightContext.home,
          title: 'Test "quotes" and \'apostrophes\'',
          message: 'Line 1\nLine 2\tTabbed',
          icon: '🎉',
          priority: InsightPriority.low,
          generatedAt: DateTime(2024, 1, 15),
          metadata: {'key': 'value with "quotes"'},
        );

        // ACT
        final json = insight.toJson();
        final deserialized = Insight.fromJson(json);

        // ASSERT
        expect(deserialized.title, equals(insight.title));
        expect(deserialized.message, equals(insight.message));
        expect(deserialized.metadata, equals(insight.metadata));
      });

      test('should handle very long strings', () {
        // ARRANGE
        final longMessage = 'A' * 1000; // 1000 character string
        final insight = Insight(
          id: 'insight-long',
          context: InsightContext.workout,
          title: 'Long Message Test',
          message: longMessage,
          icon: '📝',
          priority: InsightPriority.medium,
          generatedAt: DateTime(2024, 1, 15),
        );

        // ACT
        final json = insight.toJson();
        final deserialized = Insight.fromJson(json);

        // ASSERT
        expect(deserialized.message.length, equals(1000));
        expect(deserialized.message, equals(longMessage));
      });

      test('should handle complex nested metadata', () {
        // ARRANGE
        final insight = Insight(
          id: 'insight-nested',
          context: InsightContext.nutrition,
          title: 'Complex Data',
          message: 'Testing nested metadata',
          icon: '🔬',
          priority: InsightPriority.high,
          generatedAt: DateTime(2024, 1, 15),
          metadata: {
            'level1': {
              'level2': {
                'level3': 'deep value',
                'numbers': [1, 2, 3],
              },
              'array': ['a', 'b', 'c'],
            },
            'simple': 'value',
          },
        );

        // ACT
        final json = insight.toJson();
        final deserialized = Insight.fromJson(json);

        // ASSERT
        expect(deserialized.metadata, equals(insight.metadata));
        expect(
          (deserialized.metadata['level1'] as Map)['level2'],
          equals({'level3': 'deep value', 'numbers': [1, 2, 3]}),
        );
      });

      test('should handle various date formats', () {
        // ARRANGE
        final dates = [
          DateTime(2024, 1, 1), // Start of year
          DateTime(2024, 12, 31, 23, 59, 59), // End of year
          DateTime(2024, 6, 15, 12, 30, 45, 123), // With milliseconds
          DateTime.utc(2024, 1, 15), // UTC time
        ];

        for (final date in dates) {
          // ACT
          final insight = Insight(
            id: 'date-test',
            context: InsightContext.home,
            title: 'Date Test',
            message: 'Testing date: $date',
            icon: '📅',
            priority: InsightPriority.low,
            generatedAt: date,
          );

          final json = insight.toJson();
          final deserialized = Insight.fromJson(json);

          // ASSERT
          expect(deserialized.generatedAt, equals(date),
              reason: 'Date $date should round-trip correctly');
        }
      });

      test('should handle empty strings', () {
        // ARRANGE
        final insight = Insight(
          id: '',
          context: InsightContext.home,
          title: '',
          message: '',
          icon: '',
          priority: InsightPriority.low,
          generatedAt: DateTime(2024, 1, 15),
        );

        // ACT
        final json = insight.toJson();
        final deserialized = Insight.fromJson(json);

        // ASSERT
        expect(deserialized.id, equals(''));
        expect(deserialized.title, equals(''));
        expect(deserialized.message, equals(''));
        expect(deserialized.icon, equals(''));
      });
    });

    group('Equality and Comparison', () {
      test('should be equal when all fields match', () {
        // ARRANGE
        final date = DateTime(2024, 1, 15, 10, 30);
        final insight1 = Insight(
          id: 'insight-eq',
          context: InsightContext.home,
          title: 'Test',
          message: 'Test message',
          icon: '✅',
          priority: InsightPriority.high,
          generatedAt: date,
          metadata: {'key': 'value'},
        );

        final insight2 = Insight(
          id: 'insight-eq',
          context: InsightContext.home,
          title: 'Test',
          message: 'Test message',
          icon: '✅',
          priority: InsightPriority.high,
          generatedAt: date,
          metadata: {'key': 'value'},
        );

        // ACT & ASSERT
        expect(insight1, equals(insight2));
        expect(insight1.hashCode, equals(insight2.hashCode));
      });

      test('should not be equal when fields differ', () {
        // ARRANGE
        final date = DateTime(2024, 1, 15, 10, 30);
        final insight1 = Insight(
          id: 'insight-1',
          context: InsightContext.home,
          title: 'Test',
          message: 'Test message',
          icon: '✅',
          priority: InsightPriority.high,
          generatedAt: date,
        );

        final insight2 = Insight(
          id: 'insight-2', // Different ID
          context: InsightContext.home,
          title: 'Test',
          message: 'Test message',
          icon: '✅',
          priority: InsightPriority.high,
          generatedAt: date,
        );

        // ACT & ASSERT
        expect(insight1, isNot(equals(insight2)));
      });
    });
  });
}
