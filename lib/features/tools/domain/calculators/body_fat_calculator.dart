import 'dart:math' as math;
import '../../../onboarding/domain/entities/user_profile.dart' show BiologicalSex;

enum BodyFatCategory {
  essential('Essential Fat', 'Minimum fat required for physical and physiological health'),
  athletes('Athletic', 'Lean, muscular physique typical of competitive athletes'),
  fitness('Fitness', 'Healthy, athletic definition with low body fat'),
  average('Average', 'Healthy general population range'),
  aboveAverage('Above Average', 'Higher fat accumulation; lifestyle modifications beneficial');

  final String title;
  final String description;

  const BodyFatCategory(this.title, this.description);
}

class BodyFatResult {
  final double bodyFatPercentage;
  final double fatMassKg;
  final double leanMassKg;
  final BodyFatCategory category;
  final BiologicalSex sex;

  const BodyFatResult({
    required this.bodyFatPercentage,
    required this.fatMassKg,
    required this.leanMassKg,
    required this.category,
    required this.sex,
  });

  String get plainEnglishSummary =>
      '${bodyFatPercentage.toStringAsFixed(1)}% body fat (${category.title}). '
      'Fat mass: ${fatMassKg.toStringAsFixed(1)} kg • Lean mass: ${leanMassKg.toStringAsFixed(1)} kg.';
}

class BodyFatCalculator {
  static double _log10(double x) => math.log(x) / math.ln10;

  /// Calculates Body Fat % using the US Navy Tape Measure Method.
  static BodyFatResult calculate({
    required double weightKg,
    required double heightCm,
    required double neckCm,
    required double waistCm,
    double? hipCm,
    required BiologicalSex sex,
  }) {
    double bfPercent;

    if (sex == BiologicalSex.female) {
      final validHip = hipCm ?? (waistCm * 1.15); // Sensible fallback if hip omitted
      final diff = waistCm + validHip - neckCm;
      if (diff <= 0 || heightCm <= 0) {
        bfPercent = 22.0;
      } else {
        final denom = 1.29579 - (0.35004 * _log10(diff)) + (0.22100 * _log10(heightCm));
        bfPercent = (495.0 / denom) - 450.0;
      }
    } else {
      // Male / neutral
      final diff = waistCm - neckCm;
      if (diff <= 0 || heightCm <= 0) {
        bfPercent = 15.0;
      } else {
        final denom = 1.0324 - (0.19077 * _log10(diff)) + (0.15456 * _log10(heightCm));
        bfPercent = (495.0 / denom) - 450.0;
      }
    }

    // Clamp to realistic human biology range (3% - 60%)
    bfPercent = bfPercent.clamp(3.0, 60.0);
    bfPercent = (bfPercent * 10).round() / 10.0;

    final fatMass = (weightKg * (bfPercent / 100.0) * 10).round() / 10.0;
    final leanMass = ((weightKg - fatMass) * 10).round() / 10.0;
    final category = _categorize(bfPercent, sex);

    return BodyFatResult(
      bodyFatPercentage: bfPercent,
      fatMassKg: fatMass,
      leanMassKg: leanMass,
      category: category,
      sex: sex,
    );
  }

  static BodyFatCategory _categorize(double bf, BiologicalSex sex) {
    if (sex == BiologicalSex.female) {
      if (bf < 14.0) return BodyFatCategory.essential;
      if (bf <= 20.0) return BodyFatCategory.athletes;
      if (bf <= 24.0) return BodyFatCategory.fitness;
      if (bf <= 31.0) return BodyFatCategory.average;
      return BodyFatCategory.aboveAverage;
    } else {
      // Male & neutral
      if (bf < 6.0) return BodyFatCategory.essential;
      if (bf <= 13.0) return BodyFatCategory.athletes;
      if (bf <= 17.0) return BodyFatCategory.fitness;
      if (bf <= 24.0) return BodyFatCategory.average;
      return BodyFatCategory.aboveAverage;
    }
  }
}
