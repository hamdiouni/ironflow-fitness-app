import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/usecases/get_daily_nutrition_summary_use_case.dart';
import 'package:progression_tracker/features/nutrition/domain/utils/macro_calculator.dart';

class InMemoryNutritionRepoForSummary implements NutritionRepository {
  final List<Meal> meals = [];
  NutritionTargets? targets;

  @override
  Future<List<Meal>> getMealsByDate(DateTime date) async {
    return meals
        .where(
          (m) =>
              m.timestamp.year == date.year &&
              m.timestamp.month == date.month &&
              m.timestamp.day == date.day,
        )
        .toList();
  }

  @override
  Future<NutritionTargets?> getNutritionTargets() async => targets;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Wave 2.1 — Nutrition Math, MacroCalculator & DailySummary Characterization', () {
    test('MacroCalculator scales per-100g macros, computes 4P+4C+9F calories, percentages, remaining, progress, rounding, and tolerance', () {
      final scaled = MacroCalculator.scaleMacros(
        caloriesPer100g: 165,
        proteinPer100g: 31,
        carbsPer100g: 0,
        fatsPer100g: 3.6,
        grams: 250,
      );
      expect(scaled.calories, closeTo(412.5, 0.001));
      expect(scaled.protein, closeTo(77.5, 0.001));
      expect(scaled.fats, closeTo(9.0, 0.001));

      expect(
        MacroCalculator.scaleSingleMacro(valuePer100g: 25, grams: 150),
        37.5,
      );
      expect(
        MacroCalculator.calculatePer100g(actualValue: 30, actualGrams: 150),
        20.0,
      );
      expect(
        MacroCalculator.calculatePer100g(actualValue: 30, actualGrams: 0),
        0.0,
      );

      // Validation
      expect(
        MacroCalculator.isValid(
          calories: 500,
          protein: 40,
          carbs: 50,
          fats: 15,
        ),
        isTrue,
      );
      expect(
        MacroCalculator.isValid(
          calories: -1,
          protein: 40,
          carbs: 50,
          fats: 15,
        ),
        isFalse,
      );
      expect(MacroCalculator.isValidSingleMacro(double.nan), isFalse);
      expect(MacroCalculator.isValidSingleMacro(double.infinity), isFalse);

      // Calories from macros: 50*4 + 100*4 + 20*9 = 200 + 400 + 180 = 780 kcal
      final kcal = MacroCalculator.calculateCaloriesFromMacros(
        protein: 50,
        carbs: 100,
        fats: 20,
      );
      expect(kcal, 780.0);

      final pct = MacroCalculator.calculateMacroPercentages(
        protein: 50,
        carbs: 100,
        fats: 20,
      );
      expect(pct.proteinPercent + pct.carbsPercent + pct.fatsPercent, closeTo(100.0, 0.01));

      final zeroPct = MacroCalculator.calculateMacroPercentages(
        protein: 0,
        carbs: 0,
        fats: 0,
      );
      expect(zeroPct.proteinPercent, 0.0);

      // Remaining & progress
      final rem = MacroCalculator.calculateRemaining(
        targetCalories: 2400,
        targetProtein: 180,
        targetCarbs: 250,
        targetFats: 70,
        consumedCalories: 1200,
        consumedProtein: 90,
        consumedCarbs: 125,
        consumedFats: 35,
      );
      expect(rem.calories, 1200);
      expect(rem.protein, 90);

      final prog = MacroCalculator.calculateProgress(
        targetCalories: 2400,
        targetProtein: 180,
        targetCarbs: 250,
        targetFats: 70,
        consumedCalories: 1200,
        consumedProtein: 90,
        consumedCarbs: 125,
        consumedFats: 35,
      );
      expect(prog.calories, 0.5);
      expect(prog.protein, 0.5);

      // Rounding & tolerance
      final rounded = MacroCalculator.roundMacros(
        calories: 412.56,
        protein: 31.24,
        carbs: 10.05,
        fats: 8.99,
        decimalPlaces: 1,
      );
      expect(rounded.calories, 412.6);
      expect(rounded.protein, 31.2);
      expect(MacroCalculator.roundSingleMacro(12.345, decimalPlaces: 2), 12.35);

      expect(
        MacroCalculator.areAllMacrosWithinTolerance(
          targetCalories: 2000,
          targetProtein: 150,
          targetCarbs: 200,
          targetFats: 65,
          actualCalories: 2050,
          actualProtein: 145,
          actualCarbs: 210,
          actualFats: 62,
          tolerance: 0.10,
        ),
        isTrue,
      );
    });

    test('GetDailyNutritionSummaryUseCase and NutritionTargets compute remaining macros and completion status', () async {
      final repo = InMemoryNutritionRepoForSummary();
      final day = DateTime.utc(2026, 4, 15, 13, 0);

      repo.targets = NutritionTargets(
        userId: 'u1',
        macros: const MacroTargets(
          calories: 2000,
          protein: 160,
          carbs: 200,
          fats: 60,
        ),
        micros: const MicroTargets(
          fiber: 30,
          sugar: 40,
          sodium: 2300,
          potassium: 3500,
        ),
        vitamins: const VitaminTargets(
          vitaminA: 900,
          vitaminB: 2.4,
          vitaminC: 90,
          vitaminD: 20,
          vitaminE: 15,
        ),
        minerals: const MineralTargets(
          calcium: 1000,
          iron: 18,
          magnesium: 400,
          zinc: 11,
        ),
        createdAt: day,
        updatedAt: day,
      );

      repo.meals.add(
        Meal(
          id: 'm1',
          name: 'Chicken & Rice Bowl',
          macros: const MealMacros(
            calories: 1800,
            protein: 150,
            carbs: 180,
            fats: 52,
          ),
          micros: const MealMicros(
            fiber: 25,
            sugar: 10,
            sodium: 1800,
            potassium: 3000,
          ),
          vitamins: const MealVitamins(
            vitaminA: 800,
            vitaminB: 2.0,
            vitaminC: 85,
            vitaminD: 15,
            vitaminE: 12,
          ),
          minerals: const MealMinerals(
            calcium: 900,
            iron: 15,
            magnesium: 350,
            zinc: 10,
          ),
          timestamp: day,
          userId: 'u1',
        ),
      );

      final useCase = GetDailyNutritionSummaryUseCase(repo);
      final summary = await useCase(day);

      expect(summary.totalCalories, 1800);
      expect(summary.totalProtein, 150);
      expect(summary.totalFiber, 25);
      expect(summary.totalVitaminC, 85);
      expect(summary.totalCalcium, 900);

      final targets = repo.targets!;
      expect(targets.isValid, isTrue);
      final consumed = MacroTargets(
        calories: summary.totalCalories,
        protein: summary.totalProtein,
        carbs: summary.totalCarbs,
        fats: summary.totalFats,
      );
      expect(targets.getRemainingMacros(consumed).calories, 200);
      expect(targets.getMacroCompletionPercentage(consumed), 90.0);
      expect(
        targets.getStatusForPercentage(90.0),
        NutritionStatus.good,
      );
      expect(
        targets.getStatusForPercentage(60.0),
        NutritionStatus.moderate,
      );
      expect(
        targets.getStatusForPercentage(30.0),
        NutritionStatus.poor,
      );
    });
  });
}

