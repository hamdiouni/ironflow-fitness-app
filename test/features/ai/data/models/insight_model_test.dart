import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/ai/data/models/insight_model.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';

/// Unit tests for InsightModel
///
/// **Task 5.4: Write unit tests for Hive models**
/// **Validates: Requirements 11.3**
///
/// This test suite verifies:
/// - InsightModel serialization/deserialization
/// - Conversion to/from domain entities
/// - JSON round-trip without data loss
/// - Hive field mappings and type conversions
void main() {
  group('InsightModel', () {
    late Insight domainInsight;
    late InsightModel model;
    late Map<String, dynamic> json;

    setUp(() {
      domainInsight = Insight(
        id: 'insight-123',
        context: InsightContext.workout,
        title: 'Great Progress!',
        message: 'You increased your volume by 15% this week. Keep pushing!',
        icon: '💪',
        priority: InsightPriority.high,
        generatedAt: DateTime(2024, 1, 15, 10, 30),
        metadata: {
          'volume_increase': 15.0,
          'previous_volume': 2500.0,
          'current_volume': 2875.0,
        },
      );

      model = InsightModel(
        id: 'insight-123',
        context: 1, // InsightContext.workout.index
        title: 'Great Progress!',
        message: 'You increased your volume by 15% this week. Keep pushing!',
        icon: '💪',
        priority: 0, // InsightPriority.high.index
        generatedAtMillis: DateTime(2024, 1, 15, 10, 30).millisecondsSinceEpoch,
        metadata: {
          'volume_increase': 15.0,
          'previous_volume': 2500.0,
          'current_volume': 2875.0,
        },
      );

      json = {
        'id': 'insight-123',
        'context': 1,
        'title': 'Great Progress!',
        'message': 'You increased your volume by 15% this week. Keep pushing!',
        'icon': '💪',
        'priority': 0,
        'generatedAtMillis': DateTime(2024, 1, 15, 10, 30).millisecondsSinceEpoch,
        'metadata': {
          'volume_increase': 15.0,
          'previous_volume': 2500.0,
          'current_volume': 2875.0,
        },
      };
    });

    group('Domain Conversion', () {
      test('should create InsightModel from domain entity', () {
        // ACT
        final result = InsightModel.fromDomain(domainInsight);

        // ASSERT
        expect(result.id, equals('insight-123'));
        expect(result.context, equals(1)); // InsightContext.workout.index
        expect(result.title, equals('Great Progress!'));
        expect(result.message, contains('15%'));
        expect(result.icon, equals('💪'));
        expect(result.priority, equals(0)); // InsightPriority.high.index
        expect(result.generatedAtMillis, equals(DateTime(2024, 1, 15, 10, 30).millisecondsSinceEpoch));
        expect(result.metadata['volume_increase'], equals(15.0));
      });

      test('should convert to domain entity', () {
        // ACT
        final result = model.toDomain();

        // ASSERT
        expect(result.id, equals('insight-123'));
        expect(result.context, equals(InsightContext.workout));
        expect(result.title, equals('Great Progress!'));
        expect(result.message, contains('15%'));
        expect(result.icon, equals('💪'));
        expect(result.priority, equals(InsightPriority.high));
        expect(result.generatedAt, equals(DateTime(2024, 1, 15, 10, 30)));
        expect(result.metadata['volume_increase'], equals(15.0));
      });

      test('should round-trip through domain conversion without data loss', () {
        // ACT
        final converted = InsightModel.fromDomain(domainInsight).toDomain();

        // ASSERT
        expect(converted.id, equals(domainInsight.id));
        expect(converted.context, equals(domainInsight.context));
        expect(converted.title, equals(domainInsight.title));
        expect(converted.message, equals(domainInsight.message));
        expect(converted.icon, equals(domainInsight.icon));
        expect(converted.priority, equals(domainInsight.priority));
        expect(converted.generatedAt, equals(domainInsight.generatedAt));
        expect(converted.metadata, equals(domainInsight.metadata));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        // ACT
        final result = model.toJson();

        // ASSERT
        expect(result['id'], equals('insight-123'));
        expect(result['context'], equals(1));
        expect(result['title'], equals('Great Progress!'));
        expect(result['message'], contains('15%'));
        expect(result['icon'], equals('💪'));
        expect(result['priority'], equals(0));
        expect(result['generatedAtMillis'], equals(DateTime(2024, 1, 15, 10, 30).millisecondsSinceEpoch));
        expect(result['metadata'], isA<Map<String, dynamic>>());
        expect(result['metadata']['volume_increase'], equals(15.0));
      });

      test('should deserialize from JSON correctly', () {
        // ACT
        final result = InsightModel.fromJson(json);

        // ASSERT
        expect(result.id, equals('insight-123'));
        expect(result.context, equals(1));
        expect(result.title, equals('Great Progress!'));
        expect(result.message, contains('15%'));
        expect(result.icon, equals('💪'));
        expect(result.priority, equals(0));
        expect(result.generatedAtMillis, equals(DateTime(2024, 1, 15, 10, 30).millisecondsSinceEpoch));
        expect(result.metadata['volume_increase'], equals(15.0));
      });

      test('should round-trip through JSON without data loss', () {
        // ACT
        final serialized = model.toJson();
        final deserialized = InsightModel.fromJson(serialized);

        // ASSERT
        expect(deserialized.id, equals(model.id));
        expect(deserialized.context, equals(model.context));
        expect(deserialized.title, equals(model.title));
        expect(deserialized.message, equals(model.message));
        expect(deserialized.icon, equals(model.icon));
        expect(deserialized.priority, equals(model.priority));
        expect(deserialized.generatedAtMillis, equals(model.generatedAtMillis));
        expect(deserialized.metadata, equals(model.metadata));
      });
    });

    group('Enum Conversions', () {
      test('should handle all InsightContext values', () {
        for (final context in InsightContext.values) {
          // ARRANGE
          final testInsight = Insight(
            id: 'test',
            context: context,
            title: 'Test',
            message: 'Test message',
            icon: '🔥',
            priority: InsightPriority.medium,
            generatedAt: DateTime.now(),
            metadata: {},
          );

          // ACT
          final model = InsightModel.fromDomain(testInsight);
          final converted = model.toDomain();

          // ASSERT
          expect(converted.context, equals(context));
        }
      });

      test('should handle all InsightPriority values', () {
        for (final priority in InsightPriority.values) {
          // ARRANGE
          final testInsight = Insight(
            id: 'test',
            context: InsightContext.home,
            title: 'Test',
            message: 'Test message',
            icon: '🔥',
            priority: priority,
            generatedAt: DateTime.now(),
            metadata: {},
          );

          // ACT
          final model = InsightModel.fromDomain(testInsight);
          final converted = model.toDomain();

          // ASSERT
          expect(converted.priority, equals(priority));
        }
      });
    });

    group('Edge Cases', () {
      test('should handle empty metadata', () {
        // ARRANGE
        final insightWithEmptyMetadata = Insight(
          id: 'test',
          context: InsightContext.home,
          title: 'Test',
          message: 'Test message',
          icon: '🔥',
          priority: InsightPriority.low,
          generatedAt: DateTime.now(),
          metadata: {},
        );

        // ACT
        final model = InsightModel.fromDomain(insightWithEmptyMetadata);
        final converted = model.toDomain();

        // ASSERT
        expect(converted.metadata, isEmpty);
      });

      test('should handle complex metadata', () {
        // ARRANGE
        final complexMetadata = {
          'string_value': 'test',
          'int_value': 42,
          'double_value': 3.14,
          'bool_value': true,
          'list_value': [1, 2, 3],
          'map_value': {'nested': 'data'},
        };

        final insightWithComplexMetadata = Insight(
          id: 'test',
          context: InsightContext.nutrition,
          title: 'Test',
          message: 'Test message',
          icon: '🍎',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now(),
          metadata: complexMetadata,
        );

        // ACT
        final model = InsightModel.fromDomain(insightWithComplexMetadata);
        final converted = model.toDomain();

        // ASSERT
        expect(converted.metadata, equals(complexMetadata));
      });

      test('should handle special characters in strings', () {
        // ARRANGE
        final specialCharInsight = Insight(
          id: 'test-🎯',
          context: InsightContext.profile,
          title: 'Special Chars: éñ中文🎉',
          message: 'Message with "quotes" and \'apostrophes\' and newlines\n\ttabs',
          icon: '🌟',
          priority: InsightPriority.high,
          generatedAt: DateTime.now(),
          metadata: {'special': 'éñ中文🎉'},
        );

        // ACT
        final model = InsightModel.fromDomain(specialCharInsight);
        final converted = model.toDomain();

        // ASSERT
        expect(converted.id, equals('test-🎯'));
        expect(converted.title, equals('Special Chars: éñ中文🎉'));
        expect(converted.message, contains('quotes'));
        expect(converted.icon, equals('🌟'));
        expect(converted.metadata['special'], equals('éñ中文🎉'));
      });

      test('should handle very old and future timestamps', () {
        // ARRANGE
        final veryOldDate = DateTime(1970, 1, 1);
        final futureDate = DateTime(2100, 12, 31);

        // ACT & ASSERT - Very old date
        final oldInsight = Insight(
          id: 'old',
          context: InsightContext.home,
          title: 'Old',
          message: 'Old message',
          icon: '⏰',
          priority: InsightPriority.low,
          generatedAt: veryOldDate,
          metadata: {},
        );

        final oldModel = InsightModel.fromDomain(oldInsight);
        final oldConverted = oldModel.toDomain();
        expect(oldConverted.generatedAt, equals(veryOldDate));

        // ACT & ASSERT - Future date
        final futureInsight = Insight(
          id: 'future',
          context: InsightContext.home,
          title: 'Future',
          message: 'Future message',
          icon: '🚀',
          priority: InsightPriority.low,
          generatedAt: futureDate,
          metadata: {},
        );

        final futureModel = InsightModel.fromDomain(futureInsight);
        final futureConverted = futureModel.toDomain();
        expect(futureConverted.generatedAt, equals(futureDate));
      });
    });

    group('Equality and Immutability', () {
      test('should be equal when all fields match', () {
        // ARRANGE
        final model1 = InsightModel.fromDomain(domainInsight);
        final model2 = InsightModel.fromDomain(domainInsight);

        // ASSERT
        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal when fields differ', () {
        // ARRANGE
        final model1 = InsightModel.fromDomain(domainInsight);
        final model2 = model1.copyWith(title: 'Different Title');

        // ASSERT
        expect(model1, isNot(equals(model2)));
      });

      test('should be immutable (freezed)', () {
        // ARRANGE
        final originalModel = InsightModel.fromDomain(domainInsight);

        // ACT
        final modifiedModel = originalModel.copyWith(title: 'New Title');

        // ASSERT
        expect(originalModel.title, equals('Great Progress!'));
        expect(modifiedModel.title, equals('New Title'));
        expect(originalModel, isNot(equals(modifiedModel)));
      });
    });
  });
}