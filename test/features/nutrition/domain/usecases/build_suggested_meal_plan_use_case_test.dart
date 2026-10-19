import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/nutrition/domain/usecases/build_suggested_meal_plan_use_case.dart';
import 'package:progression_tracker/features/nutrition/domain/usecases/generate_diet_plan_use_case.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';

void main() {
  group('BuildSuggestedMealPlanUseCase', () {
    const useCase = BuildSuggestedMealPlanUseCase();

    test('generates 3 days of 4 meals matching target calories within ±5% for low budget', () {
      const profile = UserProfile(
        goal: FitnessGoal.loseWeight,
        age: 26,
        weightKg: 80,
        heightCm: 180,
        fitnessLevel: FitnessLevel.intermediate,
        equipment: EquipmentType.gym,
        workoutDaysPerWeek: 4,
        budget: BudgetLevel.low,
        sex: BiologicalSex.male,
      );

      final plan = useCase(profile);
      final targetCalories = profile.dailyCalorieTarget;

      expect(plan.days.length, equals(3));
      expect(plan.name, contains('Budget-Friendly'));

      for (final day in plan.days) {
        expect(day.meals.length, equals(4));

        final totalDayCalories = day.meals.fold<double>(0, (sum, m) => sum + m.calories);
        final totalDayProtein = day.meals.fold<double>(0, (sum, m) => sum + m.proteinG);

        // Daily calories must be within ±5% of target
        final calorieTolerance = targetCalories * 0.05;
        expect(
          totalDayCalories,
          closeTo(targetCalories, calorieTolerance),
          reason: 'Day ${day.dayName} calories ($totalDayCalories) should be within ±5% of $targetCalories',
        );

        // Protein must be within reasonable range of daily target
        expect(totalDayProtein, greaterThanOrEqualTo(plan.proteinG * 0.85));

        for (final meal in day.meals) {
          expect(meal.ingredients.isNotEmpty, isTrue);
          expect(meal.calories, greaterThan(0));
          expect(meal.proteinG, greaterThan(0));
          expect(meal.alternatives.isNotEmpty, isTrue);
          expect(meal.prepTime, isNotNull);

          // Verify toMeal() helper works
          final loggedMeal = meal.toMeal();
          expect(loggedMeal.name, equals(meal.name));
          expect(loggedMeal.macros.calories, equals(meal.calories));
        }
      }
    });

    test('generates accurate plan for medium budget muscle gain', () {
      const profile = UserProfile(
        goal: FitnessGoal.gainMuscle,
        age: 22,
        weightKg: 75,
        heightCm: 178,
        fitnessLevel: FitnessLevel.beginner,
        equipment: EquipmentType.gym,
        workoutDaysPerWeek: 4,
        budget: BudgetLevel.medium,
        sex: BiologicalSex.male,
      );

      final plan = useCase(profile);
      final targetCalories = profile.dailyCalorieTarget;

      expect(plan.name, contains('Standard Muscle Building'));
      for (final day in plan.days) {
        final totalDayCalories = day.meals.fold<double>(0, (sum, m) => sum + m.calories);
        final calorieTolerance = targetCalories * 0.05;
        expect(
          totalDayCalories,
          closeTo(targetCalories, calorieTolerance),
          reason: 'Day ${day.dayName} calories ($totalDayCalories) should match target $targetCalories',
        );
      }
    });

    test('generates accurate plan for high budget maintenance', () {
      const profile = UserProfile(
        goal: FitnessGoal.maintain,
        age: 30,
        weightKg: 65,
        heightCm: 168,
        fitnessLevel: FitnessLevel.advanced,
        equipment: EquipmentType.gym,
        workoutDaysPerWeek: 5,
        budget: BudgetLevel.high,
        sex: BiologicalSex.female,
      );

      final plan = useCase(profile);
      final targetCalories = profile.dailyCalorieTarget;

      expect(plan.name, contains('Premium Maintenance'));
      for (final day in plan.days) {
        final totalDayCalories = day.meals.fold<double>(0, (sum, m) => sum + m.calories);
        final calorieTolerance = targetCalories * 0.05;
        expect(totalDayCalories, closeTo(targetCalories, calorieTolerance));
      }
    });

    test('GenerateDietPlanUseCase delegates seamlessly to BuildSuggestedMealPlanUseCase', () {
      const profile = UserProfile(
        goal: FitnessGoal.gainMuscle,
        age: 25,
        weightKg: 70,
        heightCm: 175,
        fitnessLevel: FitnessLevel.intermediate,
        equipment: EquipmentType.gym,
        workoutDaysPerWeek: 3,
        budget: BudgetLevel.low,
        sex: BiologicalSex.male,
      );

      const legacyUseCase = GenerateDietPlanUseCase();
      final plan = legacyUseCase(profile);

      expect(plan.days.length, equals(3));
      expect(plan.dailyCalories, equals(profile.dailyCalorieTarget));
    });
  });
}
