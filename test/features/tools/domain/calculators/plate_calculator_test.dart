import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/tools/domain/calculators/plate_calculator.dart';

void main() {
  group('PlateCalculator Tests', () {
    test('Empty bar when target <= bar weight', () {
      final res = PlateCalculator.calculate(
        targetWeight: 20.0,
        barWeight: 20.0,
        unit: PlateUnit.kg,
      );

      expect(res.weightPerSide, equals(0.0));
      expect(res.platesPerSide, isEmpty);
      expect(res.totalLoadedWeight, equals(20.0));
      expect(res.isExactMatch, isTrue);
      expect(res.plainEnglishSummary, contains('Empty bar'));
    });

    test('Standard 60 kg bench press (20kg bar + 20kg per side)', () {
      final res = PlateCalculator.calculate(
        targetWeight: 60.0,
        barWeight: 20.0,
        unit: PlateUnit.kg,
      );

      expect(res.weightPerSide, equals(20.0));
      expect(res.platesPerSide, equals([const PlateCount(weight: 20.0, count: 1)]));
      expect(res.totalLoadedWeight, equals(60.0));
      expect(res.isExactMatch, isTrue);
      expect(res.flatPlatesList, equals([20.0]));
      expect(res.plainEnglishSummary, contains('1× 20.0 kg'));
    });

    test('100 kg squat with multiple plates per side (20kg bar + 40kg per side)', () {
      final res = PlateCalculator.calculate(
        targetWeight: 100.0,
        barWeight: 20.0,
        unit: PlateUnit.kg,
      );

      // 40 kg per side = 1x 25kg + 1x 15kg
      expect(res.weightPerSide, equals(40.0));
      expect(res.platesPerSide, equals([
        const PlateCount(weight: 25.0, count: 1),
        const PlateCount(weight: 15.0, count: 1),
      ]));
      expect(res.totalLoadedWeight, equals(100.0));
      expect(res.flatPlatesList, equals([25.0, 15.0]));
    });

    test('Remainder calculation when target cannot be evenly matched', () {
      final res = PlateCalculator.calculate(
        targetWeight: 61.0, // With 1.25 smallest plate, can reach 60 + 2.5 = 62.5 or 60.0
        barWeight: 20.0,
        unit: PlateUnit.kg,
      );

      // (61 - 20) / 2 = 20.5 per side.
      // 20.5 per side = 1x 20kg. Remainder per side = 0.5kg (total remainder 1.0kg)
      expect(res.weightPerSide, equals(20.0));
      expect(res.totalLoadedWeight, equals(60.0));
      expect(res.remainder, equals(1.0));
      expect(res.isExactMatch, isFalse);
      expect(res.plainEnglishSummary, contains('1.0 kg under target'));
    });

    test('LB plates calculation (225 lb squat with 45 lb bar)', () {
      final res = PlateCalculator.calculate(
        targetWeight: 225.0,
        barWeight: 45.0,
        unit: PlateUnit.lb,
      );

      // (225 - 45) / 2 = 90 lb per side = 2x 45 lb plates
      expect(res.weightPerSide, equals(90.0));
      expect(res.platesPerSide, equals([const PlateCount(weight: 45.0, count: 2)]));
      expect(res.totalLoadedWeight, equals(225.0));
      expect(res.flatPlatesList, equals([45.0, 45.0]));
      expect(res.isExactMatch, isTrue);
    });
  });
}
