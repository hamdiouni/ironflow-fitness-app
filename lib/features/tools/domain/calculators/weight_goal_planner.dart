/// Pure domain calculator for realistic weight loss / gain planning and timelines.
class WeightGoalPlanResult {
  final double currentWeightKg;
  final double targetWeightKg;
  final double weightDifferenceKg;
  final double weeklyRateKg;
  final double estimatedWeeks;
  final int estimatedDays;
  final DateTime targetDate;
  final double dailyCalorieAdjustment; // e.g. -550 kcal/day for 0.5 kg/wk
  final bool isWeightLoss;
  final bool isMaintaining;
  final String? safetyWarning;

  const WeightGoalPlanResult({
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.weightDifferenceKg,
    required this.weeklyRateKg,
    required this.estimatedWeeks,
    required this.estimatedDays,
    required this.targetDate,
    required this.dailyCalorieAdjustment,
    required this.isWeightLoss,
    required this.isMaintaining,
    this.safetyWarning,
  });

  String get plainEnglishSummary {
    if (isMaintaining) {
      return 'You are at your target weight (${currentWeightKg.toStringAsFixed(1)} kg). Focus on maintenance nutrition.';
    }

    final diff = weightDifferenceKg.toStringAsFixed(1);
    final rate = weeklyRateKg.toStringAsFixed(2);
    final weeks = estimatedWeeks.toStringAsFixed(1);
    final action = isWeightLoss ? 'lose' : 'gain';
    final calAction = isWeightLoss ? 'deficit' : 'surplus';
    final cal = dailyCalorieAdjustment.abs().toInt();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${months[targetDate.month - 1]} ${targetDate.day}, ${targetDate.year}';

    return 'To $action $diff kg at $rate kg/week, you will reach your goal in ~$weeks weeks (around $dateStr). '
        'Estimated daily $calAction: ~$cal kcal.';
  }
}

class WeightGoalPlanner {
  /// 1 kg of adipose body mass is biochemically equivalent to ~7,700 kcal.
  static const double kcalPerKg = 7700.0;

  /// Default safe rate: 0.5 kg (1.1 lbs) per week
  static const double defaultWeeklyRateKg = 0.5;

  static WeightGoalPlanResult plan({
    required double currentWeightKg,
    required double targetWeightKg,
    double weeklyRateKg = defaultWeeklyRateKg,
    DateTime? startDate,
  }) {
    final start = startDate ?? DateTime.now();
    final diff = (targetWeightKg - currentWeightKg).abs();

    if (diff < 0.1) {
      return WeightGoalPlanResult(
        currentWeightKg: currentWeightKg,
        targetWeightKg: targetWeightKg,
        weightDifferenceKg: 0.0,
        weeklyRateKg: 0.0,
        estimatedWeeks: 0.0,
        estimatedDays: 0,
        targetDate: start,
        dailyCalorieAdjustment: 0.0,
        isWeightLoss: false,
        isMaintaining: true,
        safetyWarning: null,
      );
    }

    final effectiveRate = weeklyRateKg.clamp(0.1, 2.0);
    final isLoss = targetWeightKg < currentWeightKg;

    final estimatedWeeks = diff / effectiveRate;
    final estimatedDays = (estimatedWeeks * 7.0).round();
    final targetDate = start.add(Duration(days: estimatedDays));

    // Daily deficit or surplus
    final dailyKcal = (effectiveRate * kcalPerKg) / 7.0;
    final signedDailyKcal = isLoss ? -dailyKcal : dailyKcal;

    String? warning;
    if (effectiveRate > 1.0) {
      warning = 'Warning: A rate above 1.0 kg/week is aggressive and risks muscle loss and metabolic slowdown.';
    }

    return WeightGoalPlanResult(
      currentWeightKg: (currentWeightKg * 10).round() / 10.0,
      targetWeightKg: (targetWeightKg * 10).round() / 10.0,
      weightDifferenceKg: (diff * 10).round() / 10.0,
      weeklyRateKg: (effectiveRate * 100).round() / 100.0,
      estimatedWeeks: (estimatedWeeks * 10).round() / 10.0,
      estimatedDays: estimatedDays,
      targetDate: targetDate,
      dailyCalorieAdjustment: (signedDailyKcal * 10).round() / 10.0,
      isWeightLoss: isLoss,
      isMaintaining: false,
      safetyWarning: warning,
    );
  }
}
