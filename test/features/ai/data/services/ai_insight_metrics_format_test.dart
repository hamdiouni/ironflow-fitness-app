import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/ai/data/services/ai_insight_metrics_calculator.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/services/change_detection_service.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_insight_helpers.dart';

class _FakeChangeDetectionService implements ChangeDetectionService {
  _FakeChangeDetectionService({
    this.workout = false,
    this.nutrition = false,
    this.body = false,
    this.throwError = false,
  });

  final bool workout;
  final bool nutrition;
  final bool body;
  final bool throwError;

  @override
  Future<bool> hasWorkoutDataChanged(DateTime lastGenerated) async {
    if (throwError) throw StateError('boom');
    return workout;
  }

  @override
  Future<bool> hasNutritionDataChanged(DateTime lastGenerated) async {
    if (throwError) throw StateError('boom');
    return nutrition;
  }

  @override
  Future<bool> hasBodyDataChanged(DateTime lastGenerated) async {
    if (throwError) throw StateError('boom');
    return body;
  }

  @override
  Future<DateTime?> getLastDataChange(InsightContext context) async => null;
}

void main() {
  group('AIInsightMetricsCalculator.formatMetricLabel', () {
    test('formats snake_case keys and known abbreviations cleanly', () {
      expect(
        AIInsightMetricsCalculator.formatMetricLabel('workouts_this_week'),
        equals('Workouts this week'),
      );
      expect(
        AIInsightMetricsCalculator.formatMetricLabel('protein_pct'),
        equals('Protein %'),
      );
      expect(
        AIInsightMetricsCalculator.formatMetricLabel('target_kcal'),
        equals('Target kcal'),
      );
      expect(
        AIInsightMetricsCalculator.formatMetricLabel('new_prs'),
        equals('New PRs'),
      );
      expect(
        AIInsightMetricsCalculator.formatMetricLabel('best_pr'),
        equals('Best PR'),
      );
      expect(AIInsightMetricsCalculator.formatMetricLabel(''), equals(''));
    });

    test('GlobalAIInsightHelpers.hasDataChangedForContext covers all contexts and fallback',
        () async {
      final since = DateTime(2026, 1, 1);
      final workoutOnly = _FakeChangeDetectionService(workout: true);
      final nutritionOnly = _FakeChangeDetectionService(nutrition: true);
      final bodyOnly = _FakeChangeDetectionService(body: true);
      final broken = _FakeChangeDetectionService(throwError: true);

      expect(
        await GlobalAIInsightHelpers.hasDataChangedForContext(
          changeDetectionService: workoutOnly,
          context: InsightContext.workout,
          since: since,
        ),
        isTrue,
      );
      expect(
        await GlobalAIInsightHelpers.hasDataChangedForContext(
          changeDetectionService: nutritionOnly,
          context: InsightContext.nutrition,
          since: since,
        ),
        isTrue,
      );
      expect(
        await GlobalAIInsightHelpers.hasDataChangedForContext(
          changeDetectionService: bodyOnly,
          context: InsightContext.profile,
          since: since,
        ),
        isTrue,
      );
      expect(
        await GlobalAIInsightHelpers.hasDataChangedForContext(
          changeDetectionService: broken,
          context: InsightContext.workout,
          since: since,
        ),
        isTrue,
      );
    });
  });
}
