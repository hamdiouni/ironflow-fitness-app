import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/tools/domain/calculators/weight_goal_planner.dart';

void main() {
  group('WeightGoalPlanner Tests', () {
    test('Maintenance when current weight equals target weight', () {
      final res = WeightGoalPlanner.plan(
        currentWeightKg: 80.0,
        targetWeightKg: 80.0,
      );

      expect(res.isMaintaining, isTrue);
      expect(res.weightDifferenceKg, equals(0.0));
      expect(res.estimatedWeeks, equals(0.0));
      expect(res.dailyCalorieAdjustment, equals(0.0));
      expect(res.plainEnglishSummary, contains('maintenance nutrition'));
    });

    test('Weight loss calculation (85kg to 80kg at 0.5kg/week)', () {
      final start = DateTime(2026, 1, 1);
      final res = WeightGoalPlanner.plan(
        currentWeightKg: 85.0,
        targetWeightKg: 80.0,
        weeklyRateKg: 0.5,
        startDate: start,
      );

      expect(res.isWeightLoss, isTrue);
      expect(res.weightDifferenceKg, equals(5.0));
      expect(res.estimatedWeeks, equals(10.0));
      expect(res.estimatedDays, equals(70));
      expect(res.targetDate, equals(start.add(const Duration(days: 70))));
      // 0.5 * 7700 / 7 = 550 kcal deficit/day
      expect(res.dailyCalorieAdjustment, equals(-550.0));
      expect(res.safetyWarning, isNull);
      expect(res.plainEnglishSummary, contains('lose 5.0 kg at 0.50 kg/week'));
      expect(res.plainEnglishSummary, contains('~10.0 weeks'));
      expect(res.plainEnglishSummary, contains('~550 kcal'));
    });

    test('Weight gain calculation (70kg to 75kg at 0.25kg/week)', () {
      final start = DateTime(2026, 1, 1);
      final res = WeightGoalPlanner.plan(
        currentWeightKg: 70.0,
        targetWeightKg: 75.0,
        weeklyRateKg: 0.25,
        startDate: start,
      );

      expect(res.isWeightLoss, isFalse);
      expect(res.weightDifferenceKg, equals(5.0));
      expect(res.estimatedWeeks, equals(20.0));
      // 0.25 * 7700 / 7 = 275 kcal surplus/day
      expect(res.dailyCalorieAdjustment, equals(275.0));
      expect(res.plainEnglishSummary, contains('gain 5.0 kg'));
      expect(res.plainEnglishSummary, contains('~275 kcal'));
    });

    test('Aggressive rate (> 1.0 kg/week) triggers safety warning', () {
      final res = WeightGoalPlanner.plan(
        currentWeightKg: 100.0,
        targetWeightKg: 80.0,
        weeklyRateKg: 1.5,
      );

      expect(res.safetyWarning, isNotNull);
      expect(res.safetyWarning, contains('Warning: A rate above 1.0 kg/week is aggressive'));
    });
  });
}
