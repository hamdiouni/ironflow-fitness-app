import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/ai/domain/services/ai_question_normalizer.dart';

void main() {
  group('Wave 6.1 AiCostEstimator', () {
    test('estimateTokenCount estimates English text with word/char heuristic', () {
      expect(AiCostEstimator.estimateTokenCount(''), equals(0));
      expect(AiCostEstimator.estimateTokenCount('   '), equals(0));
      
      final text = 'How many grams of protein should I consume each day for muscle hypertrophy?';
      final tokens = AiCostEstimator.estimateTokenCount(text);
      expect(tokens, greaterThanOrEqualTo(12));
      expect(tokens, lessThan(35));
    });

    test('calculateCostUsd applies Gemini 2.5 Flash token rates accurately', () {
      // 1,000,000 input tokens = $0.075
      final inputOnly = AiCostEstimator.calculateCostUsd(
        inputTokens: 1000000,
        outputTokens: 0,
      );
      expect(inputOnly, closeTo(0.075, 0.0001));

      // 1,000,000 output tokens = $0.30
      final outputOnly = AiCostEstimator.calculateCostUsd(
        inputTokens: 0,
        outputTokens: 1000000,
      );
      expect(outputOnly, closeTo(0.30, 0.0001));

      // Standard query: 50 input tokens, 200 output tokens
      final standardCost = AiCostEstimator.calculateCostUsd(
        inputTokens: 50,
        outputTokens: 200,
      );
      expect(standardCost, greaterThan(0.0));
      expect(standardCost, lessThan(0.001)); // less than a tenth of a cent
    });

    test('formatCostUsd returns readable strings', () {
      expect(AiCostEstimator.formatCostUsd(0.0), equals('\$0.00'));
      expect(AiCostEstimator.formatCostUsd(0.00005), equals('<\$0.0001'));
      expect(AiCostEstimator.formatCostUsd(0.00125), equals('\$0.0013'));
    });
  });

  group('Wave 6.1 AiQuestionNormalizer & Cache', () {
    late AiQuestionNormalizer normalizer;

    setUp(() {
      normalizer = AiQuestionNormalizer(maxCacheEntries: 5);
    });

    test('normalizes whitespace, punctuation, and casing', () {
      expect(
        normalizer.normalize('   What is Progressive Overload???  '),
        equals('canonical:progressive_overload'),
      );
      expect(
        normalizer.normalize('How much protein should I eat per day?'),
        equals('canonical:protein_intake'),
      );
      expect(
        normalizer.normalize('What is RPE and reps in reserve?'),
        equals('canonical:rpe_guide'),
      );
      expect(
        normalizer.normalize('HOW LONG TO REST BETWEEN SETS!?'),
        equals('canonical:rest_times'),
      );
    });

    test('resolves canonical fitness FAQs without remote network call', () {
      final res = normalizer.resolve('How much protein per day?');
      expect(res.isCanonicalFaq, isTrue);
      expect(res.cachedResponse, isNotNull);
      expect(res.cachedResponse, contains('1.6 to 2.2 grams'));
    });

    test('caches novel queries and respects LRU capacity', () {
      const q1 = 'What is the best exercise for lateral delts?';
      const a1 = 'Dumbbell lateral raises and cable lateral raises with arms in the scapular plane.';

      // Before caching
      final before = normalizer.resolve(q1);
      expect(before.cachedResponse, isNull);

      // Cache it
      normalizer.cacheResponse(q1, a1);
      final after = normalizer.resolve(q1);
      expect(after.isCanonicalFaq, isFalse);
      expect(after.cachedResponse, equals(a1));
      expect(normalizer.cachedEntriesCount, equals(1));

      // Test capacity eviction (max 5)
      for (int i = 0; i < 6; i++) {
        normalizer.cacheResponse('Question $i', 'Answer $i');
      }
      expect(normalizer.cachedEntriesCount, equals(5));
    });

    test('clears cache on demand', () {
      normalizer.cacheResponse('Q1', 'A1');
      expect(normalizer.cachedEntriesCount, equals(1));
      normalizer.clearCache();
      expect(normalizer.cachedEntriesCount, equals(0));
    });
  });
}

