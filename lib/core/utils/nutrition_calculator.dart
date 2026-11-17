import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';

/// Nutrition Calculator - Utility class for calculating nutritional values
/// on canonical [FoodItem] records.
class NutritionCalculator {
  NutritionCalculator._();

  /// Calculate macros for a [FoodItem] based on quantity in grams.
  static FoodMacros calculateMacrosPerQuantity(
    FoodItem food,
    double quantityGrams,
  ) =>
      food.macrosForGrams(quantityGrams);

  /// Calculate micros (including vitamins & minerals) for a [FoodItem] based on
  /// quantity in grams.
  static FoodMicros calculateMicrosPerQuantity(
    FoodItem food,
    double quantityGrams,
  ) =>
      food.microsForGrams(quantityGrams) ?? const FoodMicros();

  /// Calculate daily macro totals from a list of scaled [FoodMacros].
  static FoodMacros calculateDailyMacroTotals(List<FoodMacros> mealMacros) {
    if (mealMacros.isEmpty) {
      return const FoodMacros(
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
        grams: 0,
      );
    }

    var totalCalories = 0.0;
    var totalProtein = 0.0;
    var totalCarbs = 0.0;
    var totalFat = 0.0;
    var totalGrams = 0.0;

    for (final macros in mealMacros) {
      totalCalories += macros.calories;
      totalProtein += macros.protein;
      totalCarbs += macros.carbs;
      totalFat += macros.fat;
      totalGrams += macros.grams;
    }

    return FoodMacros(
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fat: totalFat,
      grams: totalGrams,
    );
  }

  /// Calculate daily micronutrient totals from a list of scaled [FoodMicros].
  static FoodMicros calculateDailyMicroTotals(List<FoodMicros> mealMicros) {
    if (mealMicros.isEmpty) return const FoodMicros();

    double sumField(double? Function(FoodMicros m) pick) => mealMicros.fold(
          0.0,
          (sum, m) => sum + (pick(m) ?? 0.0),
        );

    return FoodMicros(
      fiberGrams: sumField((m) => m.fiberGrams),
      sugarGrams: sumField((m) => m.sugarGrams),
      sodiumMg: sumField((m) => m.sodiumMg),
      potassiumMg: sumField((m) => m.potassiumMg),
      calciumMg: sumField((m) => m.calciumMg),
      ironMg: sumField((m) => m.ironMg),
      vitaminDMcg: sumField((m) => m.vitaminDMcg),
      saturatedFatGrams: sumField((m) => m.saturatedFatGrams),
      vitaminAMcg: sumField((m) => m.vitaminAMcg),
      vitaminBMg: sumField((m) => m.vitaminBMg),
      vitaminCMg: sumField((m) => m.vitaminCMg),
      vitaminEMg: sumField((m) => m.vitaminEMg),
      magnesiumMg: sumField((m) => m.magnesiumMg),
      zincMg: sumField((m) => m.zincMg),
    );
  }

  /// Calculate remaining macros against daily targets.
  static FoodMacros calculateRemainingMacros(
    FoodMacros consumed,
    FoodMacros targets,
  ) {
    return FoodMacros(
      calories: targets.calories - consumed.calories,
      protein: targets.protein - consumed.protein,
      carbs: targets.carbs - consumed.carbs,
      fat: targets.fat - consumed.fat,
      grams: targets.grams - consumed.grams,
    );
  }

  /// Determine color status for a nutrient value.
  static String getNutrientColorStatus(double consumed, double target) {
    if (target <= 0) return 'gray';
    final percentage = (consumed / target) * 100;
    if (percentage >= 75 && percentage <= 125) {
      return 'green';
    } else if ((percentage >= 50 && percentage < 75) ||
        (percentage > 125 && percentage <= 150)) {
      return 'orange';
    } else {
      return 'red';
    }
  }

  static double getPercentageOfTarget(double consumed, double target) {
    if (target <= 0) return 0;
    return (consumed / target) * 100;
  }

  static bool isWithinTargetRange(double consumed, double target) {
    if (target <= 0) return false;
    final percentage = (consumed / target) * 100;
    return percentage >= 75 && percentage <= 125;
  }
}
