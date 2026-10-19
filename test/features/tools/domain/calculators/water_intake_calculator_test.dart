import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/tools/domain/calculators/water_intake_calculator.dart';

void main() {
  group('WaterIntakeCalculator Tests', () {
    test('Standard baseline hydration for 70 kg person with 0 min workout', () {
      final res = WaterIntakeCalculator.calculate(
        weightKg: 70.0,
        workoutMinutes: 0,
        isHotClimate: false,
      );

      // 70 * 35 = 2450 ml = 2.45 -> 2.5 L
      expect(res.baselineMl, equals(2450.0));
      expect(res.workoutBonusMl, equals(0.0));
      expect(res.climateBonusMl, equals(0.0));
      expect(res.totalMl, equals(2450.0));
      expect(res.totalLiters, closeTo(2.5, 0.1));
      // 2450 / 250 = ~10 glasses
      expect(res.glasses, equals(10));
      expect(res.plainEnglishSummary, contains('Daily target: 2.5 L'));
    });

    test('Hydration with 60 min workout and hot climate', () {
      final res = WaterIntakeCalculator.calculate(
        weightKg: 80.0,
        workoutMinutes: 60,
        isHotClimate: true,
      );

      // Baseline: 80 * 35 = 2800 ml
      // Workout: (60 / 30) * 350 = 700 ml
      // Climate: 500 ml
      // Total: 2800 + 700 + 500 = 4000 ml = 4.0 L
      expect(res.baselineMl, equals(2800.0));
      expect(res.workoutBonusMl, equals(700.0));
      expect(res.climateBonusMl, equals(500.0));
      expect(res.totalMl, equals(4000.0));
      expect(res.totalLiters, equals(4.0));
      expect(res.glasses, equals(16));
      expect(res.plainEnglishSummary, contains('0.7 L workout sweat replacement'));
    });
  });
}
