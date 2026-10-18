import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';

void main() {
  group('UserProfile Calculator & Biometric Safety Tests', () {
    test('Known-value test: Male 80kg, 180cm, 30y yields Mifflin-St Jeor BMR 1780 kcal', () {
      const profile = UserProfile(
        goal: FitnessGoal.maintain,
        age: 30,
        weightKg: 80,
        heightCm: 180,
        fitnessLevel: FitnessLevel.intermediate,
        equipment: EquipmentType.gym,
        workoutDaysPerWeek: 4,
        budget: BudgetLevel.medium,
        sex: BiologicalSex.male,
      );

      // BMR = 10 * 80 + 6.25 * 180 - 5 * 30 + 5 = 800 + 1125 - 150 + 5 = 1780
      expect(profile.bmr, equals(1780.0));
    });

    test('Known-value test: Female 60kg, 165cm, 28y yields Mifflin-St Jeor BMR 1330.25 kcal', () {
      const profile = UserProfile(
        goal: FitnessGoal.maintain,
        age: 28,
        weightKg: 60,
        heightCm: 165,
        fitnessLevel: FitnessLevel.beginner,
        equipment: EquipmentType.gym,
        workoutDaysPerWeek: 3,
        budget: BudgetLevel.medium,
        sex: BiologicalSex.female,
      );

      // BMR = 10 * 60 + 6.25 * 165 - 5 * 28 - 161 = 600 + 1031.25 - 140 - 161 = 1330.25
      expect(profile.bmr, equals(1330.25));
    });

    test('Known-value test: Neutral fallback (Prefer not to say) uses midpoint constant (-78)', () {
      const profile = UserProfile(
        goal: FitnessGoal.maintain,
        age: 25,
        weightKg: 70,
        heightCm: 170,
        fitnessLevel: FitnessLevel.beginner,
        equipment: EquipmentType.gym,
        workoutDaysPerWeek: 2,
        budget: BudgetLevel.low,
        sex: BiologicalSex.preferNotToSay,
      );

      // BMR = 10 * 70 + 6.25 * 170 - 5 * 25 - 78 = 700 + 1062.5 - 125 - 78 = 1559.5
      expect(profile.bmr, equals(1559.5));
    });

    test('Activity multiplier mapping by training days per week', () {
      UserProfile makeWithDays(int days) => UserProfile(
            goal: FitnessGoal.maintain,
            age: 25,
            weightKg: 70,
            heightCm: 175,
            fitnessLevel: FitnessLevel.intermediate,
            equipment: EquipmentType.gym,
            workoutDaysPerWeek: days,
            budget: BudgetLevel.medium,
            sex: BiologicalSex.male,
          );

      expect(makeWithDays(2).tdee, equals(makeWithDays(2).bmr * 1.375));
      expect(makeWithDays(3).tdee, equals(makeWithDays(3).bmr * 1.55));
      expect(makeWithDays(4).tdee, equals(makeWithDays(4).bmr * 1.55));
      expect(makeWithDays(5).tdee, equals(makeWithDays(5).bmr * 1.725));
      expect(makeWithDays(6).tdee, equals(makeWithDays(6).bmr * 1.725));
    });

    test('Goal adjustments: Gain muscle (+300) and Maintain (0)', () {
      const base = UserProfile(
        goal: FitnessGoal.maintain,
        age: 25,
        weightKg: 80,
        heightCm: 180,
        fitnessLevel: FitnessLevel.intermediate,
        equipment: EquipmentType.gym,
        workoutDaysPerWeek: 4,
        budget: BudgetLevel.medium,
        sex: BiologicalSex.male,
      );

      final gain = base.copyWith(goal: FitnessGoal.gainMuscle);
      final maintain = base.copyWith(goal: FitnessGoal.maintain);

      expect(gain.dailyCalorieTarget, equals(base.tdee + 300));
      expect(maintain.dailyCalorieTarget, equals(base.tdee));
    });

    test('Safety guard: Calorie floor enforces 1500 kcal for male and 1200 kcal for female', () {
      // Very light, older female on deficit
      const lightFemale = UserProfile(
        goal: FitnessGoal.loseWeight,
        age: 65,
        weightKg: 45,
        heightCm: 145,
        fitnessLevel: FitnessLevel.beginner,
        equipment: EquipmentType.home,
        workoutDaysPerWeek: 2,
        budget: BudgetLevel.low,
        sex: BiologicalSex.female,
      );

      // Unconstrained target would be ~880 kcal, but floor clamps to 1200 kcal
      expect(lightFemale.dailyCalorieTarget, equals(1200.0));

      // Light male on deficit
      const lightMale = UserProfile(
        goal: FitnessGoal.loseWeight,
        age: 60,
        weightKg: 50,
        heightCm: 155,
        fitnessLevel: FitnessLevel.beginner,
        equipment: EquipmentType.home,
        workoutDaysPerWeek: 2,
        budget: BudgetLevel.low,
        sex: BiologicalSex.male,
      );

      // Floor clamps to 1500 kcal
      expect(lightMale.dailyCalorieTarget, equals(1500.0));
    });

    test('Safety guard: Underweight BMI (< 18.5) disables weight loss deficit', () {
      // 45kg at 175cm -> BMI = 14.7 (underweight)
      const underweightProfile = UserProfile(
        goal: FitnessGoal.loseWeight,
        age: 24,
        weightKg: 45,
        heightCm: 175,
        fitnessLevel: FitnessLevel.beginner,
        equipment: EquipmentType.home,
        workoutDaysPerWeek: 3,
        budget: BudgetLevel.medium,
        sex: BiologicalSex.female,
      );

      expect(underweightProfile.bmi, lessThan(18.5));
      // Deficit is prohibited; target remains at maintenance TDEE (clamped to floor if needed)
      expect(underweightProfile.dailyCalorieTarget, equals(underweightProfile.tdee));
    });

    test('Safety guard: Minors under 18 have weight loss deficit clamped to maintenance', () {
      // 16-year-old wanting to lose weight
      const minorProfile = UserProfile(
        goal: FitnessGoal.loseWeight,
        age: 16,
        weightKg: 75,
        heightCm: 175,
        fitnessLevel: FitnessLevel.beginner,
        equipment: EquipmentType.gym,
        workoutDaysPerWeek: 4,
        budget: BudgetLevel.medium,
        sex: BiologicalSex.male,
      );

      expect(minorProfile.dailyCalorieTarget, equals(minorProfile.tdee));
    });

    test('Macronutrient calculations: Protein by goal, Fat 25%, Carbs remainder', () {
      const profile = UserProfile(
        goal: FitnessGoal.gainMuscle,
        age: 25,
        weightKg: 80,
        heightCm: 180,
        fitnessLevel: FitnessLevel.intermediate,
        equipment: EquipmentType.gym,
        workoutDaysPerWeek: 4,
        budget: BudgetLevel.medium,
        sex: BiologicalSex.male,
      );

      // Muscle gain: 2.0g protein / kg = 160g
      expect(profile.dailyProteinTargetGrams, equals(160.0));

      // Fat: 25% of calories / 9
      final expectedFatGrams = (profile.dailyCalorieTarget * 0.25) / 9.0;
      expect(profile.dailyFatTargetGrams, equals(expectedFatGrams));

      // Carbs: (Calories - 160*4 - fat*9) / 4
      final expectedCarbGrams = (profile.dailyCalorieTarget - (160 * 4) - (expectedFatGrams * 9)) / 4.0;
      expect(profile.dailyCarbTargetGrams, closeTo(expectedCarbGrams, 0.01));
    });

    test('Serialization and deserialization preserves all fields including sex', () {
      const original = UserProfile(
        goal: FitnessGoal.loseWeight,
        age: 29,
        weightKg: 84.5,
        heightCm: 182.0,
        fitnessLevel: FitnessLevel.advanced,
        equipment: EquipmentType.gym,
        workoutDaysPerWeek: 5,
        budget: BudgetLevel.high,
        sex: BiologicalSex.male,
      );

      final json = original.toJson();
      final restored = UserProfile.fromJson(json);

      expect(restored.goal, equals(original.goal));
      expect(restored.age, equals(original.age));
      expect(restored.weightKg, equals(original.weightKg));
      expect(restored.heightCm, equals(original.heightCm));
      expect(restored.fitnessLevel, equals(original.fitnessLevel));
      expect(restored.equipment, equals(original.equipment));
      expect(restored.workoutDaysPerWeek, equals(original.workoutDaysPerWeek));
      expect(restored.budget, equals(original.budget));
      expect(restored.sex, equals(original.sex));
    });
  });
}
