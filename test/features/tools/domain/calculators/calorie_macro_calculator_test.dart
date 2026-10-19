import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/tools/domain/calculators/calorie_macro_calculator.dart';

void main() {
  group('CalorieMacroCalculator Tests', () {
    test('Standard male calculation (80kg, 180cm, 30y, moderate activity)', () {
      // BMR: 10*80 + 6.25*180 - 5*30 + 5 = 800 + 1125 - 150 + 5 = 1780.0
      // TDEE: 1780 * 1.55 = 2759.0
      // Maintain goal = 2759.0 kcal
      final res = CalorieMacroCalculator.calculate(
        weightKg: 80.0,
        heightCm: 180.0,
        age: 30,
        sex: BiologicalSex.male,
        activityLevel: ActivityLevel.moderate,
        goal: FitnessGoal.maintain,
      );

      expect(res.bmr, equals(1780.0));
      expect(res.tdee, equals(2759.0));
      expect(res.targetCalories, equals(2759.0));
      expect(res.isFloorApplied, isFalse);

      // Protein: 80 * 1.6 = 128 g (512 kcal)
      expect(res.proteinGrams, equals(128.0));
      // Fat: 25% of 2759 = 689.75 / 9 = ~76.6 g
      expect(res.fatsGrams, closeTo(76.6, 0.2));
      // Carbs: (2759 - 512 - 689.75) / 4 = 1557.25 / 4 = ~389.3 g
      expect(res.carbsGrams, closeTo(389.3, 0.5));
    });

    test('Male safety floor enforced at 1500 kcal', () {
      // Small male on severe deficit that would theoretically produce < 1500
      final res = CalorieMacroCalculator.calculate(
        weightKg: 50.0,
        heightCm: 155.0,
        age: 65,
        sex: BiologicalSex.male,
        activityLevel: ActivityLevel.sedentary, // TDEE: ~1373
        goal: FitnessGoal.loseWeight,
      );

      expect(res.targetCalories, equals(1500.0));
      expect(res.isFloorApplied, isTrue);
      expect(res.plainEnglishSummary, contains('Safety floor applied'));
    });

    test('Female safety floor enforced at 1200 kcal', () {
      final res = CalorieMacroCalculator.calculate(
        weightKg: 45.0,
        heightCm: 150.0,
        age: 60,
        sex: BiologicalSex.female,
        activityLevel: ActivityLevel.sedentary,
        goal: FitnessGoal.loseWeight,
      );

      expect(res.targetCalories, equals(1200.0));
      expect(res.isFloorApplied, isTrue);
    });

    test('Underweight BMI (< 18.5) disables deficit', () {
      // 48 kg at 175 cm yields BMI ~ 15.7 (severely underweight)
      final res = CalorieMacroCalculator.calculate(
        weightKg: 48.0,
        heightCm: 175.0,
        age: 22,
        sex: BiologicalSex.female,
        activityLevel: ActivityLevel.light,
        goal: FitnessGoal.loseWeight,
      );

      // Deficit must not be applied; target calories should equal maintenance (TDEE) or floor
      expect(res.isUnderweightGuardApplied, isTrue);
      expect(res.targetCalories, equals(res.tdee));
    });

    test('Minor guard (age < 18) disables deficit', () {
      final res = CalorieMacroCalculator.calculate(
        weightKg: 70.0,
        heightCm: 175.0,
        age: 16,
        sex: BiologicalSex.male,
        activityLevel: ActivityLevel.moderate,
        goal: FitnessGoal.loseWeight,
      );

      expect(res.isMinorGuardApplied, isTrue);
      expect(res.targetCalories, equals(res.tdee));
      expect(res.plainEnglishSummary, contains('recommended under age 18'));
    });
  });
}
