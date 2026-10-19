/// Pure domain calculator for personalized daily hydration intake.
class WaterTargetResult {
  final double totalMl;
  final double totalLiters;
  final int glasses; // 250 ml standard glasses
  final double baselineMl;
  final double workoutBonusMl;
  final double climateBonusMl;

  const WaterTargetResult({
    required this.totalMl,
    required this.totalLiters,
    required this.glasses,
    required this.baselineMl,
    required this.workoutBonusMl,
    required this.climateBonusMl,
  });

  String get plainEnglishSummary =>
      'Daily target: ${totalLiters.toStringAsFixed(1)} L (approx. $glasses glasses of water). '
      '${workoutBonusMl > 0 ? "Includes ${(workoutBonusMl / 1000).toStringAsFixed(1)} L workout sweat replacement." : ""}';
}

class WaterIntakeCalculator {
  /// Baseline hydration: 35 ml per kg of body mass
  static const double baselineMlPerKg = 35.0;

  /// Standard workout hydration: ~350 ml per 30 min of training
  static const double mlPer30MinWorkout = 350.0;

  /// Standard glass size in milliliters
  static const double standardGlassMl = 250.0;

  /// Hot climate / high perspiration bonus
  static const double hotClimateBonusMl = 500.0;

  static WaterTargetResult calculate({
    required double weightKg,
    int workoutMinutes = 45,
    bool isHotClimate = false,
  }) {
    final validWeight = weightKg > 0 ? weightKg : 70.0;
    final validMinutes = workoutMinutes.clamp(0, 240);

    final baseline = validWeight * baselineMlPerKg;
    final workoutBonus = (validMinutes / 30.0) * mlPer30MinWorkout;
    final climateBonus = isHotClimate ? hotClimateBonusMl : 0.0;

    final total = baseline + workoutBonus + climateBonus;
    final liters = total / 1000.0;
    final glasses = (total / standardGlassMl).round();

    return WaterTargetResult(
      totalMl: (total * 10).round() / 10.0,
      totalLiters: (liters * 10).round() / 10.0,
      glasses: glasses,
      baselineMl: (baseline * 10).round() / 10.0,
      workoutBonusMl: (workoutBonus * 10).round() / 10.0,
      climateBonusMl: climateBonus,
    );
  }
}
