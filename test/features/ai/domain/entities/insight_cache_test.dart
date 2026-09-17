import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_cache.dart';

/// Unit tests for InsightCache domain entity
/// 
/// **Task 1.1: Write unit tests for domain entities**
/// **Validates: Requirements 1.1, 3.1**
/// 
/// This test suite verifies:
/// - InsightCache entity creation with various data
/// - JSON serialization and deserialization
/// - Handling of multiple insights
/// - Data timestamp tracking
/// - Edge cases and data integrity
void main() {
  group('InsightCache Entity', () {
    group('Creation and Properties', () {
      test('should create InsightCache with all required fields', () {
        // ARRANGE
        final insights = [
          Insight(
            id: 'insight-1',
            context: InsightContext.home,
            title: 'Great Progress!',
            message: 'You completed 5 workouts this week.',
            icon: '💪',
            priority: InsightPriority.high,
            generatedAt: DateTime(2024, 1, 15, 10, 0),
          ),
          Insight(
            id: 'insight-2',
            context: InsightContext.home,
            title: 'Keep Going',
            message: 'Consistency is key.',
            icon: '🔥',
            priority: InsightPriority.medium,
            generatedAt: DateTime(2024, 1, 15, 10, 0),
          ),
        ];

        final dataTimestamps = {
          'workout': DateTime(2024, 1, 15, 9, 0),
          'nutrition': DateTime(2024, 1, 15, 8, 30),
        };

        // ACT
        final cache = InsightCache(
          context: InsightContext.home,
          insights: insights,
          cachedAt: DateTime(2024, 1, 15, 10, 0),
          dataTimestamps: dataTimestamps,
        );

        // ASSERT
        expect(cache.context, equals(InsightContext.home));
        expect(cache.insights.length, equals(2));
        expect(cache.insights[0].id, equals('insight-1'));
        expect(cache.insights[1].id, equals('insight-2'));
        expect(cache.cachedAt, equals(DateTime(2024, 1, 15, 10, 0)));
        expect(cache.dataTimestamps, equals(dataTimestamps));
      });

      test('should create InsightCache with empty insights list', () {
        // ARRANGE & ACT
        final cache = InsightCache(
          context: InsightContext.workout,
          insights: [],
          cachedAt: DateTime(2024, 1, 15, 10, 0),
          dataTimestamps: {},
        );

        // ASSERT
        expect(cache.insights, isEmpty);
        expect(cache.dataTimestamps, isEmpty);
      });

      test('should create InsightCache with single insight', () {
        // ARRANGE
        final insight = Insight(
          id: 'single-insight',
          context: InsightContext.nutrition,
          title: 'Protein Goal',
          message: 'You need 20g more protein today.',
          icon: '🍗',
          priority: InsightPriority.high,
          generatedAt: DateTime(2024, 1, 15, 10, 0),
        );

        // ACT
        final cache = InsightCache(
          context: InsightContext.nutrition,
          insights: [insight],
          cachedAt: DateTime(2024, 1, 15, 10, 0),
          dataTimestamps: {'nutrition': DateTime(2024, 1, 15, 9, 0)},
        );

        // ASSERT
        expect(cache.insights.length, equals(1));
        expect(cache.insights.first.id, equals('single-insight'));
      });

      test('should create InsightCache with multiple insights (3)', () {
        // ARRANGE
        final insights = List.generate(
          3,
          (i) => Insight(
            id: 'insight-$i',
            context: InsightContext.profile,
            title: 'Insight $i',
            message: 'Message $i',
            icon: '📊',
            priority: InsightPriority.medium,
            generatedAt: DateTime(2024, 1, 15, 10, 0),
          ),
        );

        // ACT
        final cache = InsightCache(
          context: InsightContext.profile,
          insights: insights,
          cachedAt: DateTime(2024, 1, 15, 10, 0),
          dataTimestamps: {'body': DateTime(2024, 1, 15, 9, 0)},
        );

        // ASSERT
        expect(cache.insights.length, equals(3));
        for (var i = 0; i < 3; i++) {
          expect(cache.insights[i].id, equals('insight-$i'));
        }
      });

      test('should be immutable (freezed)', () {
        // ARRANGE
        final cache = InsightCache(
          context: InsightContext.home,
          insights: [],
          cachedAt: DateTime(2024, 1, 15, 10, 0),
          dataTimestamps: {},
        );

        // ACT & ASSERT
        final updatedCache = cache.copyWith(
          cachedAt: DateTime(2024, 1, 15, 11, 0),
        );

        expect(cache.cachedAt, equals(DateTime(2024, 1, 15, 10, 0)));
        expect(updatedCache.cachedAt, equals(DateTime(2024, 1, 15, 11, 0)));
        expect(cache.context, equals(updatedCache.context));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        // ARRANGE
        final insights = [
          Insight(
            id: 'insight-1',
            context: InsightContext.workout,
            title: 'Volume Increase',
            message: 'Your volume increased by 15%.',
            icon: '📈',
            priority: InsightPriority.high,
            generatedAt: DateTime(2024, 1, 15, 10, 0),
            metadata: {'volumeChange': 15.0},
          ),
        ];

        final cache = InsightCache(
          context: InsightContext.workout,
          insights: insights,
          cachedAt: DateTime(2024, 1, 15, 10, 30),
          dataTimestamps: {
            'workout': DateTime(2024, 1, 15, 9, 0),
            'body': DateTime(2024, 1, 14, 20, 0),
          },
        );

        // ACT
        final json = cache.toJson();

        // ASSERT
        expect(json['context'], equals('workout'));
        expect(json['insights'], isA<List>());
        expect((json['insights'] as List).length, equals(1));
        expect(json['cachedAt'], equals('2024-01-15T10:30:00.000'));
        expect(json['dataTimestamps'], isA<Map>());
        expect(
          (json['dataTimestamps'] as Map)['workout'],
          equals('2024-01-15T09:00:00.000'),
        );
      });

      test('should deserialize from JSON correctly', () {
        // ARRANGE
        final json = {
          'context': 'nutrition',
          'insights': [
            {
              'id': 'insight-1',
              'context': 'nutrition',
              'title': 'Macro Balance',
              'message': 'Your protein intake is 85% of target.',
              'icon': '⚖️',
              'priority': 'medium',
              'generatedAt': '2024-01-15T10:00:00.000',
              'metadata': {'proteinPercent': 85.0},
            },
          ],
          'cachedAt': '2024-01-15T10:30:00.000',
          'dataTimestamps': {
            'nutrition': '2024-01-15T09:00:00.000',
          },
        };

        // ACT
        final cache = InsightCache.fromJson(json);

        // ASSERT
        expect(cache.context, equals(InsightContext.nutrition));
        expect(cache.insights.length, equals(1));
        expect(cache.insights.first.id, equals('insight-1'));
        expect(cache.cachedAt, equals(DateTime(2024, 1, 15, 10, 30)));
        expect(
          cache.dataTimestamps['nutrition'],
          equals(DateTime(2024, 1, 15, 9, 0)),
        );
      });

      test('should handle empty insights list in JSON', () {
        // ARRANGE
        final cache = InsightCache(
          context: InsightContext.home,
          insights: [],
          cachedAt: DateTime(2024, 1, 15, 10, 0),
          dataTimestamps: {},
        );

        // ACT
        final json = cache.toJson();
        final deserialized = InsightCache.fromJson(json);

        // ASSERT
        expect(json['insights'], equals([]));
        expect(deserialized.insights, isEmpty);
      });

      test('should handle multiple insights in JSON', () {
        // ARRANGE
        final insights = List.generate(
          3,
          (i) => Insight(
            id: 'insight-$i',
            context: InsightContext.profile,
            title: 'Insight $i',
            message: 'Message $i',
            icon: '📊',
            priority: InsightPriority.values[i % 3],
            generatedAt: DateTime(2024, 1, 15, 10, i),
          ),
        );

        final cache = InsightCache(
          context: InsightContext.profile,
          insights: insights,
          cachedAt: DateTime(2024, 1, 15, 10, 30),
          dataTimestamps: {
            'workout': DateTime(2024, 1, 15, 9, 0),
            'nutrition': DateTime(2024, 1, 15, 8, 30),
            'body': DateTime(2024, 1, 15, 7, 0),
          },
        );

        // ACT
        final json = cache.toJson();
        final deserialized = InsightCache.fromJson(json);

        // ASSERT
        expect(deserialized.insights.length, equals(3));
        for (var i = 0; i < 3; i++) {
          expect(deserialized.insights[i].id, equals('insight-$i'));
          expect(deserialized.insights[i].title, equals('Insight $i'));
        }
      });

      test('should round-trip through JSON without data loss', () {
        // ARRANGE
        final original = InsightCache(
          context: InsightContext.workout,
          insights: [
            Insight(
              id: 'insight-1',
              context: InsightContext.workout,
              title: 'PR Alert',
              message: 'New personal record!',
              icon: '🏆',
              priority: InsightPriority.high,
              generatedAt: DateTime(2024, 1, 15, 10, 0),
              metadata: {'exercise': 'Bench Press', 'weight': 100.0},
            ),
            Insight(
              id: 'insight-2',
              context: InsightContext.workout,
              title: 'Volume Increase',
              message: 'Great progress!',
              icon: '📈',
              priority: InsightPriority.medium,
              generatedAt: DateTime(2024, 1, 15, 10, 0),
            ),
          ],
          cachedAt: DateTime(2024, 1, 15, 10, 30, 45),
          dataTimestamps: {
            'workout': DateTime(2024, 1, 15, 9, 0),
            'body': DateTime(2024, 1, 14, 20, 0),
          },
        );

        // ACT
        final json = original.toJson();
        final deserialized = InsightCache.fromJson(json);

        // ASSERT
        expect(deserialized.context, equals(original.context));
        expect(deserialized.insights.length, equals(original.insights.length));
        expect(deserialized.cachedAt, equals(original.cachedAt));
        expect(deserialized.dataTimestamps, equals(original.dataTimestamps));

        for (var i = 0; i < original.insights.length; i++) {
          expect(deserialized.insights[i].id, equals(original.insights[i].id));
          expect(
            deserialized.insights[i].title,
            equals(original.insights[i].title),
          );
          expect(
            deserialized.insights[i].metadata,
            equals(original.insights[i].metadata),
          );
        }
      });
    });

    group('Data Timestamps', () {
      test('should track multiple data source timestamps', () {
        // ARRANGE
        final dataTimestamps = {
          'workout': DateTime(2024, 1, 15, 9, 0),
          'nutrition': DateTime(2024, 1, 15, 8, 30),
          'body': DateTime(2024, 1, 14, 20, 0),
        };

        // ACT
        final cache = InsightCache(
          context: InsightContext.home,
          insights: [],
          cachedAt: DateTime(2024, 1, 15, 10, 0),
          dataTimestamps: dataTimestamps,
        );

        // ASSERT
        expect(cache.dataTimestamps.length, equals(3));
        expect(
          cache.dataTimestamps['workout'],
          equals(DateTime(2024, 1, 15, 9, 0)),
        );
        expect(
          cache.dataTimestamps['nutrition'],
          equals(DateTime(2024, 1, 15, 8, 30)),
        );
        expect(
          cache.dataTimestamps['body'],
          equals(DateTime(2024, 1, 14, 20, 0)),
        );
      });

      test('should handle empty data timestamps', () {
        // ARRANGE & ACT
        final cache = InsightCache(
          context: InsightContext.workout,
          insights: [],
          cachedAt: DateTime(2024, 1, 15, 10, 0),
          dataTimestamps: {},
        );

        // ASSERT
        expect(cache.dataTimestamps, isEmpty);
      });

      test('should preserve timestamp precision', () {
        // ARRANGE
        final preciseTimestamp = DateTime(2024, 1, 15, 10, 30, 45, 123, 456);
        final dataTimestamps = {
          'workout': preciseTimestamp,
        };

        // ACT
        final cache = InsightCache(
          context: InsightContext.workout,
          insights: [],
          cachedAt: DateTime(2024, 1, 15, 10, 0),
          dataTimestamps: dataTimestamps,
        );

        final json = cache.toJson();
        final deserialized = InsightCache.fromJson(json);

        // ASSERT
        // Note: JSON serialization may lose microsecond precision
        expect(
          deserialized.dataTimestamps['workout']!.millisecondsSinceEpoch,
          equals(preciseTimestamp.millisecondsSinceEpoch),
        );
      });
    });

    group('Context-Specific Caches', () {
      test('should create cache for each InsightContext', () {
        // ARRANGE
        final contexts = [
          InsightContext.home,
          InsightContext.workout,
          InsightContext.nutrition,
          InsightContext.profile,
        ];

        for (final context in contexts) {
          // ACT
          final cache = InsightCache(
            context: context,
            insights: [
              Insight(
                id: 'insight-${context.name}',
                context: context,
                title: 'Test for ${context.name}',
                message: 'Context-specific insight',
                icon: '✅',
                priority: InsightPriority.medium,
                generatedAt: DateTime(2024, 1, 15, 10, 0),
              ),
            ],
            cachedAt: DateTime(2024, 1, 15, 10, 0),
            dataTimestamps: {},
          );

          // ASSERT
          expect(cache.context, equals(context));
          expect(cache.insights.first.context, equals(context));
        }
      });

      test('should allow insights with different contexts in cache', () {
        // ARRANGE
        // This tests that the cache can store insights even if their context
        // doesn't match the cache context (though this shouldn't happen in practice)
        final cache = InsightCache(
          context: InsightContext.home,
          insights: [
            Insight(
              id: 'insight-1',
              context: InsightContext.workout, // Different context
              title: 'Workout Insight',
              message: 'Test',
              icon: '💪',
              priority: InsightPriority.medium,
              generatedAt: DateTime(2024, 1, 15, 10, 0),
            ),
          ],
          cachedAt: DateTime(2024, 1, 15, 10, 0),
          dataTimestamps: {},
        );

        // ACT
        final json = cache.toJson();
        final deserialized = InsightCache.fromJson(json);

        // ASSERT
        expect(deserialized.context, equals(InsightContext.home));
        expect(
          deserialized.insights.first.context,
          equals(InsightContext.workout),
        );
      });
    });

    group('Edge Cases', () {
      test('should handle very old cached timestamps', () {
        // ARRANGE
        final veryOldDate = DateTime(2020, 1, 1);
        final cache = InsightCache(
          context: InsightContext.home,
          insights: [],
          cachedAt: veryOldDate,
          dataTimestamps: {'workout': veryOldDate},
        );

        // ACT
        final json = cache.toJson();
        final deserialized = InsightCache.fromJson(json);

        // ASSERT
        expect(deserialized.cachedAt, equals(veryOldDate));
        expect(deserialized.dataTimestamps['workout'], equals(veryOldDate));
      });

      test('should handle future timestamps', () {
        // ARRANGE
        final futureDate = DateTime(2030, 12, 31);
        final cache = InsightCache(
          context: InsightContext.profile,
          insights: [],
          cachedAt: futureDate,
          dataTimestamps: {'body': futureDate},
        );

        // ACT
        final json = cache.toJson();
        final deserialized = InsightCache.fromJson(json);

        // ASSERT
        expect(deserialized.cachedAt, equals(futureDate));
        expect(deserialized.dataTimestamps['body'], equals(futureDate));
      });

      test('should handle large number of insights', () {
        // ARRANGE
        final manyInsights = List.generate(
          100,
          (i) => Insight(
            id: 'insight-$i',
            context: InsightContext.home,
            title: 'Insight $i',
            message: 'Message $i',
            icon: '📊',
            priority: InsightPriority.values[i % 3],
            generatedAt: DateTime(2024, 1, 15, 10, i % 60),
          ),
        );

        final cache = InsightCache(
          context: InsightContext.home,
          insights: manyInsights,
          cachedAt: DateTime(2024, 1, 15, 10, 0),
          dataTimestamps: {},
        );

        // ACT
        final json = cache.toJson();
        final deserialized = InsightCache.fromJson(json);

        // ASSERT
        expect(deserialized.insights.length, equals(100));
        expect(deserialized.insights.first.id, equals('insight-0'));
        expect(deserialized.insights.last.id, equals('insight-99'));
      });

      test('should handle many data source timestamps', () {
        // ARRANGE
        final manyTimestamps = Map.fromEntries(
          List.generate(
            50,
            (i) => MapEntry(
              'source-$i',
              DateTime(2024, 1, 15, 10, i % 60),
            ),
          ),
        );

        final cache = InsightCache(
          context: InsightContext.home,
          insights: [],
          cachedAt: DateTime(2024, 1, 15, 10, 0),
          dataTimestamps: manyTimestamps,
        );

        // ACT
        final json = cache.toJson();
        final deserialized = InsightCache.fromJson(json);

        // ASSERT
        expect(deserialized.dataTimestamps.length, equals(50));
        expect(deserialized.dataTimestamps.keys, contains('source-0'));
        expect(deserialized.dataTimestamps.keys, contains('source-49'));
      });

      test('should handle insights with complex metadata', () {
        // ARRANGE
        final cache = InsightCache(
          context: InsightContext.nutrition,
          insights: [
            Insight(
              id: 'complex-insight',
              context: InsightContext.nutrition,
              title: 'Complex Data',
              message: 'Testing complex metadata',
              icon: '🔬',
              priority: InsightPriority.high,
              generatedAt: DateTime(2024, 1, 15, 10, 0),
              metadata: {
                'nested': {
                  'level1': {
                    'level2': 'value',
                    'array': [1, 2, 3],
                  },
                },
                'numbers': [1.5, 2.7, 3.9],
                'strings': ['a', 'b', 'c'],
              },
            ),
          ],
          cachedAt: DateTime(2024, 1, 15, 10, 0),
          dataTimestamps: {},
        );

        // ACT
        final json = cache.toJson();
        final deserialized = InsightCache.fromJson(json);

        // ASSERT
        expect(
          deserialized.insights.first.metadata,
          equals(cache.insights.first.metadata),
        );
      });
    });

    group('Equality and Comparison', () {
      test('should be equal when all fields match', () {
        // ARRANGE
        final date = DateTime(2024, 1, 15, 10, 0);
        final insights = [
          Insight(
            id: 'insight-1',
            context: InsightContext.home,
            title: 'Test',
            message: 'Test message',
            icon: '✅',
            priority: InsightPriority.high,
            generatedAt: date,
          ),
        ];

        final cache1 = InsightCache(
          context: InsightContext.home,
          insights: insights,
          cachedAt: date,
          dataTimestamps: {'workout': date},
        );

        final cache2 = InsightCache(
          context: InsightContext.home,
          insights: insights,
          cachedAt: date,
          dataTimestamps: {'workout': date},
        );

        // ACT & ASSERT
        expect(cache1, equals(cache2));
        expect(cache1.hashCode, equals(cache2.hashCode));
      });

      test('should not be equal when fields differ', () {
        // ARRANGE
        final date = DateTime(2024, 1, 15, 10, 0);
        final cache1 = InsightCache(
          context: InsightContext.home,
          insights: [],
          cachedAt: date,
          dataTimestamps: {},
        );

        final cache2 = InsightCache(
          context: InsightContext.workout, // Different context
          insights: [],
          cachedAt: date,
          dataTimestamps: {},
        );

        // ACT & ASSERT
        expect(cache1, isNot(equals(cache2)));
      });
    });
  });
}
