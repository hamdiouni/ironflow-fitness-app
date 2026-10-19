import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/tools/domain/calculators/one_rep_max_calculator.dart';

void main() {
  group('OneRepMaxCalculator Tests', () {
    test('1 rep returns identical weight as 1RM', () {
      final res = OneRepMaxCalculator.calculate(weight: 100.0, reps: 1);

      expect(res.weightLifted, equals(100.0));
      expect(res.reps, equals(1));
      expect(res.brzycki, equals(100.0));
      expect(res.epley, equals(100.0));
      expect(res.wathan, equals(100.0));
      expect(res.recommended1RM, equals(100.0));
      expect(res.percentageTable.first.weight, equals(100.0));
      expect(res.plainEnglishSummary, contains('estimated 1RM is 100.0'));
    });

    test('100 kg for 5 reps gives accurate Brzycki and Epley estimates', () {
      final res = OneRepMaxCalculator.calculate(weight: 100.0, reps: 5);

      // Brzycki: 100 * (36 / 32) = 112.5 kg
      // Epley: 100 * (1 + 5/30) = 116.67 -> 116.7 kg
      expect(res.brzycki, equals(112.5));
      expect(res.epley, equals(116.7));
      expect(res.recommended1RM, equals(112.5)); // <= 10 reps uses Brzycki
      expect(res.percentageTable.length, equals(10));

      // 90% should be ~101.3 kg
      final ninety = res.percentageTable.firstWhere((p) => p.percentage == 90);
      expect(ninety.weight, closeTo(101.3, 0.2));
      expect(ninety.estimatedReps, equals(4));
    });

    test('Edge case: zero weight returns zero result', () {
      final res = OneRepMaxCalculator.calculate(weight: 0.0, reps: 5);
      expect(res.recommended1RM, equals(0.0));
      expect(res.percentageTable, isEmpty);
    });

    test('Reps clamped between 1 and 30', () {
      final resOver = OneRepMaxCalculator.calculate(weight: 60.0, reps: 40);
      expect(resOver.reps, equals(30));

      final resUnder = OneRepMaxCalculator.calculate(weight: 60.0, reps: 0);
      expect(resUnder.reps, equals(1));
    });
  });
}
