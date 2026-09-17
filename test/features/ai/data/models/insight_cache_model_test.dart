import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/ai/data/models/insight_cache_model.dart';
import 'package:progression_tracker/features/ai/data/models/insight_model.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_cache.dart';

/// Unit tests for InsightCacheModel
///
/// **Task 5.4: Write unit tests for Hive models**
/// **Validates: Requirements 11.3**
///
/// This test suite verifies:
/// - InsightCacheModel serialization/deserialization
/// - Conversion to/from domain entities
/// - JSON round-trip without data loss
/// - Timestamp handling (milliseconds since epoch)
/// - Complex nested data structures
void main() {
  group('InsightCacheModel', () {
    late InsightCache domainCache;
    late InsightCacheModel model;
    late Map<String, dynamic> json;
    late List<Insight> insights;

    setUp(() {
      insights = [
        Insight(
          id: 'insight-1',
          context: InsightContext.workout,
          title: 'Great Volume!',
          message: 'You increased volume by 10%',
          icon: '💪',
          priority: InsightPriority.high,
          generatedAt: DateTime(2024, 1, 15, 10, 0),
          metadata: {'volume_increase': 10.0},
        ),
        Insight(
          id: 'insight-2',
          context: InsightContext.workout,
          title: 'New PR!',
          message: 'You hit a new personal record',
          icon: '🏆',
          priority: InsightPriority.high,
          generatedAt: DateTime(2024, 1, 15, 10, 5),
          metadata: {'exercise': 'Bench Press', 'weight': 120.0},
        ),
      ];

      domainCache = InsightCache(
        context: InsightContext.workout,
        insights: insights,
        cachedAt: DateTime(2024, 1, 15, 10, 30),
        dataTimestamps: {
          'workouts': DateTime(2024, 1, 15, 9, 45),
          'nutrition': DateTime(2024, 1, 15, 8, 30),
          'body': DateTime(2024, 1, 14, 20, 15),
        },
      );

      model = InsightCacheModel(
        context: 'workout',
        insights: insights.map((i) => InsightModel.fromDomain(i)).toList(),
        cachedAtMillis: DateTime(2024, 1, 15, 10, 30).millisecondsSinceEpoch,
        dataTimestampsMillis: {
          'workouts': DateTime(2024, 1, 15, 9, 45).millisecondsSinceEpoch,
          'nutrition': DateTime(2024, 1, 15, 8, 30).millisecondsSinceEpoch,
          'body': DateTime(2024, 1, 14, 20, 15).millisecondsSinceEpoch,
        },
      );

      json = {
        'context': 'workout',
        'insights': insights.map((i) => InsightModel.fromDomain(i).toJson()).toList(),
        'cachedAtMillis': DateTime(2024, 1, 15, 10, 30).millisecondsSinceEpoch,
        'dataTimestampsMillis': {
          'workouts': DateTime(2024, 1, 15, 9, 45).millisecondsSinceEpoch,
          'nutrition': DateTime(2024, 1, 15, 8, 30).millisecondsSinceEpoch,
          'body': DateTime(2024, 1, 14, 20, 15).millisecondsSinceEpoch,
        },
      };
    });

    group('Domain Conversion', () {
      test('should create InsightCacheModel from domain entity', () {
        // ACT
        final result = InsightCacheModel.fromDomain(domainCache);

        // ASSERT
        expect(result.context, equals('workout'));
        expect(result.insights.length, equals(2));
        expect(result.insights[0].id, equals('insight-1'));
        expect(result.insights[1].id, equals('insight-2'));
        expect(result.cachedAtMillis, equals(DateTime(2024, 1, 15, 10, 30).millisecondsSinceEpoch));
        expect(result.dataTimestampsMillis.length, equals(3));
        expect(result.dataTimestampsMillis['workouts'], equals(DateTime(2024, 1, 15, 9, 45).millisecondsSinceEpoch));
      });

      test('should convert to domain entity', () {
        // ACT
        final result = model.toDomain();

        // ASSERT
        expect(result.context, equals(InsightContext.workout));
        expect(result.insights.length, equals(2));
        expect(result.insights[0].id, equals('insight-1'));
        expect(result.insights[1].id, equals('insight-2'));
        expect(result.cachedAt, equals(DateTime(2024, 1, 15, 10, 30)));
        expect(result.dataTimestamps.length, equals(3));
        expect(result.dataTimestamps['workouts'], equals(DateTime(2024, 1, 15, 9, 45)));
      });

      test('should round-trip through domain conversion without data loss', () {
        // ACT
        final converted = InsightCacheModel.fromDomain(domainCache).toDomain();

        // ASSERT
        expect(converted.context, equals(domainCache.context));
        expect(converted.insights.length, equals(domainCache.insights.length));
        expect(converted.cachedAt, equals(domainCache.cachedAt));
        expect(converted.dataTimestamps, equals(domainCache.dataTimestamps));
        
        // Check individual insights
        for (int i = 0; i < converted.insights.length; i++) {
          expect(converted.insights[i].id, equals(domainCache.insights[i].id));
          expect(converted.insights[i].title, equals(domainCache.insights[i].title));
          expect(converted.insights[i].context, equals(domainCache.insights[i].context));
        }
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        // ACT
        final result = model.toJson();

        // ASSERT
        expect(result['context'], equals('workout'));
        expect(result['insights'], isA<List>());
        expect(result['insights'].length, equals(2));
        expect(result['cachedAtMillis'], equals(DateTime(2024, 1, 15, 10, 30).millisecondsSinceEpoch));
        expect(result['dataTimestampsMillis'], isA<Map<String, dynamic>>());
        expect(result['dataTimestampsMillis']['workouts'], isA<int>());
      });

      test('should deserialize from JSON correctly', () {
        // ACT
        final result = InsightCacheModel.fromJson(json);

        // ASSERT
        expect(result.context, equals('workout'));
        expect(result.insights.length, equals(2));
        expect(result.insights[0].id, equals('insight-1'));
        expect(result.cachedAtMillis, equals(DateTime(2024, 1, 15, 10, 30).millisecondsSinceEpoch));
        expect(result.dataTimestampsMillis['workouts'], equals(DateTime(2024, 1, 15, 9, 45).millisecondsSinceEpoch));
      });

      test('should round-trip through JSON without data loss', () {
        // ACT
        final serialized = model.toJson();
        final deserialized = InsightCacheModel.fromJson(serialized);

        // ASSERT
        expect(deserialized.context, equals(model.context));
        expect(deserialized.insights.length, equals(model.insights.length));
        expect(deserialized.cachedAtMillis, equals(model.cachedAtMillis));
        expect(deserialized.dataTimestampsMillis, equals(model.dataTimestampsMillis));
      });
    });

    group('Context Handling', () {
      test('should handle all InsightContext values', () {
        for (final context in InsightContext.values) {
          // ARRANGE
          final testCache = InsightCache(
            context: context,
            insights: [],
            cachedAt: DateTime.now(),
            dataTimestamps: {},
          );

          // ACT
          final model = InsightCacheModel.fromDomain(testCache);
          final converted = model.toDomain();

          // ASSERT
          expect(converted.context, equals(context));
        }
      });
    });

    group('Timestamp Handling', () {
      test('should convert timestamps to milliseconds correctly', () {
        // ARRANGE
        final testDate = DateTime(2024, 6, 15, 14, 30, 45, 123);
        final expectedMillis = testDate.millisecondsSinceEpoch;

        final testCache = InsightCache(
          context: InsightContext.home,
          insights: [],
          cachedAt: testDate,
          dataTimestamps: {'test': testDate},
        );

        // ACT
        final model = InsightCacheModel.fromDomain(testCache);

        // ASSERT
        expect(model.cachedAtMillis, equals(expectedMillis));
        expect(model.dataTimestampsMillis['test'], equals(expectedMillis));
      });

      test('should convert milliseconds to timestamps correctly', () {
        // ARRANGE
        final testMillis = DateTime(2024, 6, 15, 14, 30, 45, 123).millisecondsSinceEpoch;
        final expectedDate = DateTime.fromMillisecondsSinceEpoch(testMillis);

        final testModel = InsightCacheModel(
          context: 'home',
          insights: [],
          cachedAtMillis: testMillis,
          dataTimestampsMillis: {'test': testMillis},
        );

        // ACT
        final domain = testModel.toDomain();

        // ASSERT
        expect(domain.cachedAt, equals(expectedDate));
        expect(domain.dataTimestamps['test'], equals(expectedDate));
      });

      test('should handle very old and future timestamps', () {
        // ARRANGE
        final veryOldDate = DateTime(1970, 1, 1);
        final futureDate = DateTime(2100, 12, 31);

        final testCache = InsightCache(
          context: InsightContext.profile,
          insights: [],
          cachedAt: veryOldDate,
          dataTimestamps: {
            'old': veryOldDate,
            'future': futureDate,
          },
        );

        // ACT
        final model = InsightCacheModel.fromDomain(testCache);
        final converted = model.toDomain();

        // ASSERT
        expect(converted.cachedAt, equals(veryOldDate));
        expect(converted.dataTimestamps['old'], equals(veryOldDate));
        expect(converted.dataTimestamps['future'], equals(futureDate));
      });
    });

    group('Edge Cases', () {
      test('should handle empty insights list', () {
        // ARRANGE
        final emptyCache = InsightCache(
          context: InsightContext.nutrition,
          insights: [],
          cachedAt: DateTime.now(),
          dataTimestamps: {},
        );

        // ACT
        final model = InsightCacheModel.fromDomain(emptyCache);
        final converted = model.toDomain();

        // ASSERT
        expect(converted.insights, isEmpty);
        expect(converted.dataTimestamps, isEmpty);
      });

      test('should handle large number of insights', () {
        // ARRANGE
        final manyInsights = List.generate(100, (index) => Insight(
          id: 'insight-$index',
          context: InsightContext.home,
          title: 'Insight $index',
          message: 'Message $index',
          icon: '🔥',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now().add(Duration(minutes: index)),
          metadata: {'index': index},
        ));

        final largeCache = InsightCache(
          context: InsightContext.home,
          insights: manyInsights,
          cachedAt: DateTime.now(),
          dataTimestamps: {},
        );

        // ACT
        final model = InsightCacheModel.fromDomain(largeCache);
        final converted = model.toDomain();

        // ASSERT
        expect(converted.insights.length, equals(100));
        expect(converted.insights[50].id, equals('insight-50'));
        expect(converted.insights[99].metadata['index'], equals(99));
      });

      test('should handle many data source timestamps', () {
        // ARRANGE
        final manyTimestamps = Map.fromEntries(
          List.generate(50, (index) => MapEntry(
            'source_$index',
            DateTime.now().subtract(Duration(hours: index)),
          )),
        );

        final timestampCache = InsightCache(
          context: InsightContext.workout,
          insights: [],
          cachedAt: DateTime.now(),
          dataTimestamps: manyTimestamps,
        );

        // ACT
        final model = InsightCacheModel.fromDomain(timestampCache);
        final converted = model.toDomain();

        // ASSERT
        expect(converted.dataTimestamps.length, equals(50));
        expect(converted.dataTimestamps.keys, contains('source_25'));
      });

      test('should handle insights with complex metadata', () {
        // ARRANGE
        final complexInsight = Insight(
          id: 'complex',
          context: InsightContext.nutrition,
          title: 'Complex Insight',
          message: 'Complex message',
          icon: '🧠',
          priority: InsightPriority.low,
          generatedAt: DateTime.now(),
          metadata: {
            'nested_map': {
              'level_2': {
                'level_3': 'deep_value',
                'numbers': [1, 2, 3.14],
              },
            },
            'boolean_flag': true,
            'null_value': null,
          },
        );

        final complexCache = InsightCache(
          context: InsightContext.nutrition,
          insights: [complexInsight],
          cachedAt: DateTime.now(),
          dataTimestamps: {},
        );

        // ACT
        final model = InsightCacheModel.fromDomain(complexCache);
        final converted = model.toDomain();

        // ASSERT
        final convertedInsight = converted.insights.first;
        expect(convertedInsight.metadata['nested_map']['level_2']['level_3'], equals('deep_value'));
        expect(convertedInsight.metadata['boolean_flag'], isTrue);
        expect(convertedInsight.metadata['null_value'], isNull);
      });
    });

    group('Equality and Immutability', () {
      test('should be equal when all fields match', () {
        // ARRANGE
        final model1 = InsightCacheModel.fromDomain(domainCache);
        final model2 = InsightCacheModel.fromDomain(domainCache);

        // ASSERT
        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal when fields differ', () {
        // ARRANGE
        final model1 = InsightCacheModel.fromDomain(domainCache);
        final model2 = model1.copyWith(context: 'nutrition');

        // ASSERT
        expect(model1, isNot(equals(model2)));
      });

      test('should be immutable (freezed)', () {
        // ARRANGE
        final originalModel = InsightCacheModel.fromDomain(domainCache);

        // ACT
        final modifiedModel = originalModel.copyWith(context: 'nutrition');

        // ASSERT
        expect(originalModel.context, equals('workout'));
        expect(modifiedModel.context, equals('nutrition'));
        expect(originalModel, isNot(equals(modifiedModel)));
      });
    });
  });
}