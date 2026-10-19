import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/tools/domain/calculators/body_fat_calculator.dart';

void main() {
  group('BodyFatCalculator Tests', () {
    test('Standard male calculation (80kg, 180cm, neck 38cm, waist 85cm)', () {
      final res = BodyFatCalculator.calculate(
        weightKg: 80.0,
        heightCm: 180.0,
        neckCm: 38.0,
        waistCm: 85.0,
        sex: BiologicalSex.male,
      );

      // waist - neck = 47. Expected US Navy BF ~ 16-17% (Fitness category)
      expect(res.bodyFatPercentage, inInclusiveRange(14.0, 18.0));
      expect(res.category, equals(BodyFatCategory.fitness));
      expect(res.fatMassKg + res.leanMassKg, closeTo(80.0, 0.2));
      expect(res.plainEnglishSummary, contains('Fitness'));
    });

    test('Standard female calculation (60kg, 165cm, neck 32cm, waist 70cm, hip 95cm)', () {
      final res = BodyFatCalculator.calculate(
        weightKg: 60.0,
        heightCm: 165.0,
        neckCm: 32.0,
        waistCm: 70.0,
        hipCm: 95.0,
        sex: BiologicalSex.female,
      );

      // waist + hip - neck = 133. Expected US Navy BF ~ 24-27% (Average / Fitness)
      expect(res.bodyFatPercentage, inInclusiveRange(22.0, 28.0));
      expect(res.fatMassKg + res.leanMassKg, closeTo(60.0, 0.2));
    });

    test('Clamps extreme values safely within biological human limits (3% - 60%)', () {
      final resExtreme = BodyFatCalculator.calculate(
        weightKg: 90.0,
        heightCm: 180.0,
        neckCm: 50.0,
        waistCm: 51.0, // waist ~ neck
        sex: BiologicalSex.male,
      );

      expect(resExtreme.bodyFatPercentage, greaterThanOrEqualTo(3.0));
      expect(resExtreme.bodyFatPercentage, lessThanOrEqualTo(60.0));
    });
  });
}
