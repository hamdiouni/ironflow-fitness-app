import 'dart:math' as math;

/// Represents an intensity percentage row in the 1RM breakdown.
class OneRepMaxPercentage {
  final int percentage; // e.g. 100, 95, 90, 85, etc.
  final double weight;
  final int estimatedReps;

  const OneRepMaxPercentage({
    required this.percentage,
    required this.weight,
    required this.estimatedReps,
  });

  @override
  String toString() => '$percentage%: ${weight.toStringAsFixed(1)} (~$estimatedReps reps)';
}

/// Result of 1RM calculation with multiple proven formulas and full intensity table.
class OneRepMaxResult {
  final double weightLifted;
  final int reps;
  final double brzycki;
  final double epley;
  final double wathan;
  final double recommended1RM;
  final List<OneRepMaxPercentage> percentageTable;

  const OneRepMaxResult({
    required this.weightLifted,
    required this.reps,
    required this.brzycki,
    required this.epley,
    required this.wathan,
    required this.recommended1RM,
    required this.percentageTable,
  });

  String get plainEnglishSummary =>
      'Based on $reps reps at ${weightLifted.toStringAsFixed(1)}, your estimated 1RM is ${recommended1RM.toStringAsFixed(1)}.';
}

/// Pure domain calculator for One Rep Max (1RM).
class OneRepMaxCalculator {
  static const List<MapEntry<int, int>> _standardPercentages = [
    MapEntry(100, 1),
    MapEntry(95, 2),
    MapEntry(90, 4),
    MapEntry(85, 6),
    MapEntry(80, 8),
    MapEntry(75, 10),
    MapEntry(70, 12),
    MapEntry(65, 15),
    MapEntry(60, 18),
    MapEntry(50, 20),
  ];

  /// Calculates 1RM from lifted weight and reps.
  /// Reps are constrained to [1, 30]. Weight must be > 0.
  static OneRepMaxResult calculate({
    required double weight,
    required int reps,
  }) {
    final validWeight = weight > 0 ? weight : 0.0;
    final validReps = reps.clamp(1, 30);

    if (validWeight == 0.0) {
      return const OneRepMaxResult(
        weightLifted: 0.0,
        reps: 1,
        brzycki: 0.0,
        epley: 0.0,
        wathan: 0.0,
        recommended1RM: 0.0,
        percentageTable: [],
      );
    }

    if (validReps == 1) {
      return OneRepMaxResult(
        weightLifted: validWeight,
        reps: 1,
        brzycki: validWeight,
        epley: validWeight,
        wathan: validWeight,
        recommended1RM: validWeight,
        percentageTable: _buildPercentageTable(validWeight),
      );
    }

    // Brzycki formula: weight * (36 / (37 - reps))
    final brzycki = validWeight * (36.0 / (37.0 - validReps));

    // Epley formula: weight * (1 + reps / 30)
    final epley = validWeight * (1.0 + (validReps / 30.0));

    // Wathan formula: (100 * weight) / (48.8 + 53.8 * exp(-0.075 * reps))
    final wathan = (100.0 * validWeight) /
        (48.8 + (53.8 * math.exp(-0.075 * validReps)));

    // Brzycki is gold standard for <= 10 reps, blended average for higher reps
    final double recommended;
    if (validReps <= 10) {
      recommended = (brzycki * 10).round() / 10.0;
    } else {
      recommended = (((brzycki + epley + wathan) / 3.0) * 10).round() / 10.0;
    }

    return OneRepMaxResult(
      weightLifted: validWeight,
      reps: validReps,
      brzycki: (brzycki * 10).round() / 10.0,
      epley: (epley * 10).round() / 10.0,
      wathan: (wathan * 10).round() / 10.0,
      recommended1RM: recommended,
      percentageTable: _buildPercentageTable(recommended),
    );
  }

  static List<OneRepMaxPercentage> _buildPercentageTable(double oneRepMax) {
    return _standardPercentages.map((entry) {
      final percentage = entry.key;
      final estimatedReps = entry.value;
      final calculatedWeight = ((oneRepMax * (percentage / 100.0)) * 10).round() / 10.0;
      return OneRepMaxPercentage(
        percentage: percentage,
        weight: calculatedWeight,
        estimatedReps: estimatedReps,
      );
    }).toList();
  }
}
