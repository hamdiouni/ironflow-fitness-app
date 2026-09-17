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
  });

  final FitnessGoal goal;
  final int age;
  final double weightKg;
  final double heightCm;
  final FitnessLevel fitnessLevel;
  final EquipmentType equipment;
  final int workoutDaysPerWeek;
  final BudgetLevel budget;

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  /// Basal Metabolic Rate (BMR) - calories burned at rest
  /// Using Mifflin-St Jeor equation (simplified for male average)
  double get bmr => 10 * weightKg + 6.25 * heightCm - 5 * age + 5;

  /// Total Daily Energy Expenditure (TDEE) - BMR + activity
  double get tdee => bmr * _activityMultiplier;

  /// Estimated daily calorie target based on goal and body stats.
  double get dailyCalorieTarget {
    return switch (goal) {
      FitnessGoal.loseWeight => tdee - 500,
      FitnessGoal.gainMuscle => tdee + 300,
      FitnessGoal.maintain => tdee,
    };
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
      );
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
