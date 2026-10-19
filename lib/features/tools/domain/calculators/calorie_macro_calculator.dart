import '../../../onboarding/domain/entities/user_profile.dart' show BiologicalSex, FitnessGoal;

enum ActivityLevel {
  sedentary(1.2, 'Sedentary', 'Desk job, little to no exercise'),
  light(1.375, 'Lightly Active', 'Exercise 1–2 days/week'),
  moderate(1.55, 'Moderately Active', 'Exercise 3–4 days/week'),
  heavy(1.725, 'Very Active', 'Intense exercise 5–6 days/week'),
  veryHeavy(1.9, 'Extremely Active', 'Physical job & daily training');

  final double multiplier;
  final String title;
  final String description;

  const ActivityLevel(this.multiplier, this.title, this.description);
}

class CalorieMacroResult {
  final double bmr;
  final double tdee;
  final double targetCalories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatsGrams;
  final double proteinCalories;
  final double carbsCalories;
  final double fatsCalories;
  final bool isFloorApplied;
  final bool isUnderweightGuardApplied;
  final bool isMinorGuardApplied;

  const CalorieMacroResult({
    required this.bmr,
    required this.tdee,
    required this.targetCalories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
    required this.proteinCalories,
    required this.carbsCalories,
    required this.fatsCalories,
    required this.isFloorApplied,
    required this.isUnderweightGuardApplied,
    required this.isMinorGuardApplied,
  });

  String get plainEnglishSummary {
    final cal = targetCalories.toInt();
    final p = proteinGrams.toInt();
    final c = carbsGrams.toInt();
    final f = fatsGrams.toInt();

    final buffer = StringBuffer('Target: $cal kcal/day ($p g protein, $c g carbs, $f g fat).');
    if (isFloorApplied) {
      buffer.write(' Safety floor applied to prevent unhealthy caloric restriction.');
    } else if (isUnderweightGuardApplied) {
      buffer.write(' Deficit disabled: BMI indicates underweight status.');
    } else if (isMinorGuardApplied) {
      buffer.write(' Deficit disabled: Full maintenance calories recommended under age 18.');
    }
    return buffer.toString();
  }
}

class CalorieMacroCalculator {
  /// Calculates BMR using the scientifically validated Mifflin-St Jeor formula.
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required BiologicalSex sex,
  }) {
    final base = 10.0 * weightKg + 6.25 * heightCm - 5.0 * age;
    return switch (sex) {
      BiologicalSex.male => base + 5.0,
      BiologicalSex.female => base - 161.0,
      BiologicalSex.preferNotToSay => base - 78.0,
    };
  }

  /// Calculates TDEE from BMR and Activity Level.
  static double calculateTDEE({
    required double bmr,
    required ActivityLevel activityLevel,
  }) {
    return bmr * activityLevel.multiplier;
  }

  /// Calculates complete daily calorie target and macronutrient distribution with strict safety guards.
  static CalorieMacroResult calculate({
    required double weightKg,
    required double heightCm,
    required int age,
    required BiologicalSex sex,
    required ActivityLevel activityLevel,
    required FitnessGoal goal,
  }) {
    final bmr = calculateBMR(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      sex: sex,
    );
    final tdee = calculateTDEE(bmr: bmr, activityLevel: activityLevel);

    final heightM = heightCm / 100.0;
    final bmi = heightM > 0 ? (weightKg / (heightM * heightM)) : 22.0;

    double targetCalories = switch (goal) {
      FitnessGoal.loseWeight => tdee - 500.0,
      FitnessGoal.gainMuscle => tdee + 300.0,
      FitnessGoal.maintain => tdee,
    };

    bool isUnderweightGuard = false;
    bool isMinorGuard = false;
    bool isFloorApplied = false;

    // Guard 1: Underweight (< 18.5 BMI) - no deficit permitted
    if (bmi < 18.5 && goal == FitnessGoal.loseWeight) {
      targetCalories = tdee;
      isUnderweightGuard = true;
    }

    // Guard 2: Minors (< 18 years) - no deficit permitted
    if (age < 18 && goal == FitnessGoal.loseWeight) {
      targetCalories = tdee;
      isMinorGuard = true;
    }

    // Guard 3: Absolute calorie floors (1500 for male, 1200 for female/neutral)
    final floor = sex == BiologicalSex.male ? 1500.0 : 1200.0;
    if (targetCalories < floor) {
      targetCalories = floor;
      isFloorApplied = true;
    }

    // Sports nutrition macro distribution
    final proteinMultiplier = switch (goal) {
      FitnessGoal.gainMuscle => 2.0,
      FitnessGoal.loseWeight => 2.0, // High protein to preserve lean mass during deficit
      FitnessGoal.maintain => 1.6,
    };

    final proteinGrams = weightKg * proteinMultiplier;
    final proteinCalories = proteinGrams * 4.0;

    // Fat: 25% of daily calories
    final fatsCalories = targetCalories * 0.25;
    final fatsGrams = fatsCalories / 9.0;

    // Carbs: remaining calories
    final remainingCalories = targetCalories - proteinCalories - fatsCalories;
    final carbsCalories = remainingCalories > 0 ? remainingCalories : 0.0;
    final carbsGrams = carbsCalories / 4.0;

    return CalorieMacroResult(
      bmr: (bmr * 10).round() / 10.0,
      tdee: (tdee * 10).round() / 10.0,
      targetCalories: (targetCalories * 10).round() / 10.0,
      proteinGrams: (proteinGrams * 10).round() / 10.0,
      carbsGrams: (carbsGrams * 10).round() / 10.0,
      fatsGrams: (fatsGrams * 10).round() / 10.0,
      proteinCalories: (proteinCalories * 10).round() / 10.0,
      carbsCalories: (carbsCalories * 10).round() / 10.0,
      fatsCalories: (fatsCalories * 10).round() / 10.0,
      isFloorApplied: isFloorApplied,
      isUnderweightGuardApplied: isUnderweightGuard,
      isMinorGuardApplied: isMinorGuard,
    );
  }
}
