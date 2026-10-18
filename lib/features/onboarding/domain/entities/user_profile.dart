/// User profile entity storing onboarding data and preferences.
class UserProfile {
  const UserProfile({
    required this.goal,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.fitnessLevel,
    required this.equipment,
    required this.workoutDaysPerWeek,
    required this.budget,
    this.sex = BiologicalSex.preferNotToSay,
  });

  final FitnessGoal goal;
  final int age;
  final double weightKg;
  final double heightCm;
  final FitnessLevel fitnessLevel;
  final EquipmentType equipment;
  final int workoutDaysPerWeek;
  final BudgetLevel budget;
  final BiologicalSex sex;

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  /// Basal Metabolic Rate (BMR) - calories burned at rest
  /// Using Mifflin-St Jeor equation:
  /// - Male: 10 * weightKg + 6.25 * heightCm - 5 * age + 5
  /// - Female: 10 * weightKg + 6.25 * heightCm - 5 * age - 161
  /// - Prefer not to say: 10 * weightKg + 6.25 * heightCm - 5 * age - 78 (neutral average)
  double get bmr {
    final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
    return switch (sex) {
      BiologicalSex.male => base + 5,
      BiologicalSex.female => base - 161,
      BiologicalSex.preferNotToSay => base - 78,
    };
  }

  /// Total Daily Energy Expenditure (TDEE) - BMR + activity
  double get tdee => bmr * _activityMultiplier;

  /// Sensible calorie floor: 1500 kcal for male, 1200 kcal for female / neutral
  double get calorieFloor => sex == BiologicalSex.male ? 1500.0 : 1200.0;

  /// Estimated daily calorie target based on goal and body stats with safety guards.
  /// Safety rules:
  /// 1. Calorie floor: Never recommend below 1500 kcal (male) or 1200 kcal (female/neutral).
  /// 2. Underweight BMI (< 18.5): No weight loss deficit allowed (minimum is TDEE / maintenance).
  /// 3. Minors (< 18): No weight loss deficit allowed (set to TDEE / maintenance).
  double get dailyCalorieTarget {
    double target = switch (goal) {
      FitnessGoal.loseWeight => tdee - 500,
      FitnessGoal.gainMuscle => tdee + 300,
      FitnessGoal.maintain => tdee,
    };

    // Safety guard 1: Underweight check (BMI < 18.5)
    if (bmi < 18.5 && goal == FitnessGoal.loseWeight) {
      target = tdee;
    }

    // Safety guard 2: Minors check (age < 18)
    if (age < 18 && goal == FitnessGoal.loseWeight) {
      target = tdee;
    }

    // Safety guard 3: Enforce sensible calorie floor
    if (target < calorieFloor) {
      target = calorieFloor;
    }

    return target;
  }

  /// Daily protein target in grams (sports nutrition standard)
  double get dailyProteinTargetGrams {
    final multiplier = switch (goal) {
      FitnessGoal.gainMuscle => 2.0,
      FitnessGoal.loseWeight => 1.8,
      FitnessGoal.maintain => 1.5,
    };
    return weightKg * multiplier;
  }

  /// Daily fat target in grams (25% of daily calories)
  double get dailyFatTargetGrams => (dailyCalorieTarget * 0.25) / 9.0;

  /// Daily carbs target in grams (fills remaining calorie allowance)
  double get dailyCarbTargetGrams {
    final remainingCalories = dailyCalorieTarget - (dailyProteinTargetGrams * 4.0) - (dailyFatTargetGrams * 9.0);
    return remainingCalories > 0 ? (remainingCalories / 4.0) : 0.0;
  }

  double get _activityMultiplier => switch (workoutDaysPerWeek) {
        <= 2 => 1.375,
        <= 4 => 1.55,
        _ => 1.725,
      };

  UserProfile copyWith({
    FitnessGoal? goal,
    int? age,
    double? weightKg,
    double? heightCm,
    FitnessLevel? fitnessLevel,
    EquipmentType? equipment,
    int? workoutDaysPerWeek,
    BudgetLevel? budget,
    BiologicalSex? sex,
  }) {
    return UserProfile(
      goal: goal ?? this.goal,
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      equipment: equipment ?? this.equipment,
      workoutDaysPerWeek: workoutDaysPerWeek ?? this.workoutDaysPerWeek,
      budget: budget ?? this.budget,
      sex: sex ?? this.sex,
    );
  }

  Map<String, dynamic> toJson() => {
        'goal': goal.name,
        'age': age,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'fitnessLevel': fitnessLevel.name,
        'equipment': equipment.name,
        'workoutDaysPerWeek': workoutDaysPerWeek,
        'budget': budget.name,
        'sex': sex.name,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        goal: FitnessGoal.values.byName(json['goal'] as String),
        age: json['age'] as int,
        weightKg: (json['weightKg'] as num).toDouble(),
        heightCm: (json['heightCm'] as num).toDouble(),
        fitnessLevel: FitnessLevel.values.byName(json['fitnessLevel'] as String),
        equipment: EquipmentType.values.byName(json['equipment'] as String),
        workoutDaysPerWeek: json['workoutDaysPerWeek'] as int,
        budget: BudgetLevel.values.byName(json['budget'] as String),
        sex: json['sex'] != null
            ? BiologicalSex.values.byName(json['sex'] as String)
            : BiologicalSex.preferNotToSay,
      );
}

enum BiologicalSex { male, female, preferNotToSay }

extension BiologicalSexX on BiologicalSex {
  String get displayName => switch (this) {
        BiologicalSex.male => 'Male',
        BiologicalSex.female => 'Female',
        BiologicalSex.preferNotToSay => 'Prefer not to say',
      };

  String get shortLabel => switch (this) {
        BiologicalSex.male => 'M',
        BiologicalSex.female => 'F',
        BiologicalSex.preferNotToSay => '–',
      };
}

enum FitnessGoal { loseWeight, gainMuscle, maintain }

enum FitnessLevel { beginner, intermediate, advanced }

enum EquipmentType { gym, home }

enum BudgetLevel { low, medium, high }

extension FitnessGoalX on FitnessGoal {
  String get displayName => switch (this) {
        FitnessGoal.loseWeight => 'Lose Weight',
        FitnessGoal.gainMuscle => 'Gain Muscle',
        FitnessGoal.maintain => 'Maintain',
      };

  String get emoji => switch (this) {
        FitnessGoal.loseWeight => '🔥',
        FitnessGoal.gainMuscle => '💪',
        FitnessGoal.maintain => '⚖️',
      };

  String get description => switch (this) {
        FitnessGoal.loseWeight => 'Burn fat and get lean',
        FitnessGoal.gainMuscle => 'Build strength and size',
        FitnessGoal.maintain => 'Stay fit and healthy',
      };
}

extension FitnessLevelX on FitnessLevel {
  String get displayName => switch (this) {
        FitnessLevel.beginner => 'Beginner',
        FitnessLevel.intermediate => 'Intermediate',
        FitnessLevel.advanced => 'Advanced',
      };

  String get description => switch (this) {
        FitnessLevel.beginner => 'Less than 1 year of training',
        FitnessLevel.intermediate => '1–3 years of training',
        FitnessLevel.advanced => '3+ years of training',
      };
}

extension EquipmentTypeX on EquipmentType {
  String get displayName => switch (this) {
        EquipmentType.gym => 'Full Gym',
        EquipmentType.home => 'Home / Dumbbells',
      };

  String get description => switch (this) {
        EquipmentType.gym => 'Access to barbells, machines, cables',
        EquipmentType.home => 'Dumbbells, bodyweight, bands',
      };
}

extension BudgetLevelX on BudgetLevel {
  String get displayName => switch (this) {
        BudgetLevel.low => 'Low Budget',
        BudgetLevel.medium => 'Medium Budget',
        BudgetLevel.high => 'High Budget',
      };

  String get description => switch (this) {
        BudgetLevel.low => 'Simple, affordable meals',
        BudgetLevel.medium => 'Balanced variety',
        BudgetLevel.high => 'Premium foods & supplements',
      };
}
