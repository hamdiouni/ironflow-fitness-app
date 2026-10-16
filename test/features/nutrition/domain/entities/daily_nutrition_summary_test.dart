import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';

void main() {
  group('DailyNutritionSummary calculations', () {
    final meal1 = Meal(
      id: 'meal_1',
      name: 'Breakfast',
      timestamp: DateTime(2026, 10, 16, 8, 0),
      macros: const MealMacros(calories: 500, protein: 30, carbs: 60, fats: 15),
      micros: const MealMicros(fiber: 8, sugar: 12, sodium: 400, potassium: 500),
      vitamins: const MealVitamins(vitaminA: 100, vitaminB: 1.2, vitaminC: 45, vitaminD: 5, vitaminE: 4),
      minerals: const MealMinerals(calcium: 200, iron: 4, magnesium: 80, zinc: 3),
    );

    final meal2 = Meal(
      id: 'meal_2',
      name: 'Lunch',
      timestamp: DateTime(2026, 10, 16, 13, 0),
      macros: const MealMacros(calories: 700, protein: 50, carbs: 80, fats: 20),
      micros: const MealMicros(fiber: 10, sugar: 6, sodium: 600, potassium: 700),
      vitamins: const MealVitamins(vitaminA: 150, vitaminB: 1.8, vitaminC: 30, vitaminD: 10, vitaminE: 6),
      minerals: const MealMinerals(calcium: 300, iron: 6, magnesium: 120, zinc: 5),
    );

    final targets = NutritionTargets(
      userId: 'test_user',
      macros: const MacroTargets(calories: 2000, protein: 150, carbs: 220, fats: 60),
      micros: const MicroTargets(fiber: 30, sugar: 50, sodium: 2300, potassium: 3500),
      vitamins: const VitaminTargets(vitaminA: 900, vitaminB: 2.4, vitaminC: 90, vitaminD: 20, vitaminE: 15),
      minerals: const MineralTargets(calcium: 1000, iron: 18, magnesium: 400, zinc: 11),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    test('sums macros correctly across meals', () {
      final summary = DailyNutritionSummary(
        date: DateTime(2026, 10, 16),
        meals: [meal1, meal2],
        target: targets,
      );

      expect(summary.totalCalories, 1200);
      expect(summary.totalProtein, 80);
      expect(summary.totalCarbs, 140);
      expect(summary.totalFats, 35);
    });

    test('sums micros, vitamins, and minerals correctly', () {
      final summary = DailyNutritionSummary(
        date: DateTime(2026, 10, 16),
        meals: [meal1, meal2],
        target: targets,
      );

      expect(summary.totalFiber, 18);
      expect(summary.totalSugar, 18);
      expect(summary.totalSodium, 1000);
      expect(summary.totalPotassium, 1200);

      expect(summary.totalVitaminA, 250);
      expect(summary.totalVitaminB, closeTo(3.0, 0.001));
      expect(summary.totalVitaminC, 75);
      expect(summary.totalVitaminD, 15);
      expect(summary.totalVitaminE, 10);

      expect(summary.totalCalcium, 500);
      expect(summary.totalIron, 10);
      expect(summary.totalMagnesium, 200);
      expect(summary.totalZinc, 8);
    });

    test('returns zero remaining macros when target is null', () {
      final summary = DailyNutritionSummary(
        date: DateTime(2026, 10, 16),
        meals: [meal1],
        target: null,
      );

      expect(summary.remainingMacros.protein, 0);
      expect(summary.remainingMacros.carbs, 0);
      expect(summary.remainingMacros.fats, 0);
    });

    test('calculates remaining macros with target and clamps to zero if exceeded', () {
      final summary = DailyNutritionSummary(
        date: DateTime(2026, 10, 16),
        meals: [meal1, meal2],
        target: targets,
      );

      final remaining = summary.remainingMacros;
      expect(remaining.protein, 150 - 80); // 70
      expect(remaining.carbs, 220 - 140); // 80
      expect(remaining.fats, 60 - 35); // 25

      // When meals exceed target, remaining must clamp to 0
      final heavyMeal = Meal(
        id: 'heavy',
        name: 'Feast',
        timestamp: DateTime(2026, 10, 16, 19, 0),
        macros: const MealMacros(calories: 3000, protein: 200, carbs: 400, fats: 100),
        micros: const MealMicros(fiber: 50, sugar: 80, sodium: 4000, potassium: 5000),
        vitamins: const MealVitamins(vitaminA: 1000, vitaminB: 10, vitaminC: 200, vitaminD: 50, vitaminE: 40),
        minerals: const MealMinerals(calcium: 2000, iron: 40, magnesium: 800, zinc: 30),
      );

      final exceededSummary = DailyNutritionSummary(
        date: DateTime(2026, 10, 16),
        meals: [heavyMeal],
        target: targets,
      );

      expect(exceededSummary.remainingMacros.protein, 0);
      expect(exceededSummary.remainingMacros.carbs, 0);
      expect(exceededSummary.remainingMacros.fats, 0);
    });

    test('validates NutritionTargets status and completion percentages', () {
      expect(targets.isValid, isTrue);

      const consumed = MacroTargets(calories: 1800, protein: 135, carbs: 200, fats: 55);
      expect(targets.getMacroCompletionPercentage(consumed), 90.0);
      expect(targets.getStatusForPercentage(90.0), NutritionStatus.good);
      expect(targets.getStatusForPercentage(60.0), NutritionStatus.moderate);
      expect(targets.getStatusForPercentage(30.0), NutritionStatus.poor);
    });
  });
}
