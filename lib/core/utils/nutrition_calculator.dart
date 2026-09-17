import 'package:progression_tracker/features/nutrition/domain/entities/food_item_full.dart';

/// Nutrition Calculator - Utility class for calculating nutritional values
///
/// This calculator handles:
/// - Scaling nutritional values from per 100g to per quantity
/// - Aggregating daily totals from multiple meals
/// - Calculating remaining macros against targets
/// - Color coding based on target compliance
///
/// All database values are stored per 100g. This calculator scales them
/// based on the quantity consumed (in grams).
class NutritionCalculator {
  /// Private constructor - use static methods only
  NutritionCalculator._();

  // ============================================================================
  // MACRO CALCULATIONS (per quantity)
  // ============================================================================

  /// Calculate macros for a food item based on quantity in grams
  ///
  /// Takes a food item and quantity in grams, returns scaled macros.
  /// Example: 150g of chicken with 26g protein per 100g = 39g protein
  static MacrosPer100g calculateMacrosPerQuantity(
    FoodItemFull food,
    double quantityGrams,
  ) {
    final factor = quantityGrams / 100.0;
    return MacrosPer100g(
      calories: food.macros.calories * factor,
      protein: food.macros.protein * factor,
      carbs: food.macros.carbs * factor,
      fats: food.macros.fats * factor,
    );
  }

  // ============================================================================
  // MICRO CALCULATIONS (per quantity)
  // ============================================================================

  /// Calculate micros for a food item based on quantity in grams
  ///
  /// Takes a food item and quantity in grams, returns scaled micros.
  /// Includes: fiber, sugar, sodium, potassium
  static MicrosPer100g calculateMicrosPerQuantity(
    FoodItemFull food,
    double quantityGrams,
  ) {
    final factor = quantityGrams / 100.0;
    return MicrosPer100g(
      fiber: food.micros.fiber * factor,
      sugar: food.micros.sugar * factor,
      sodium: food.micros.sodium * factor,
      potassium: food.micros.potassium * factor,
    );
  }

  // ============================================================================
  // VITAMIN CALCULATIONS (per quantity)
  // ============================================================================

  /// Calculate vitamins for a food item based on quantity in grams
  ///
  /// Takes a food item and quantity in grams, returns scaled vitamins.
  /// Includes: A, B, C, D, E
  static VitaminsPer100g calculateVitaminsPerQuantity(
    FoodItemFull food,
    double quantityGrams,
  ) {
    final factor = quantityGrams / 100.0;
    return VitaminsPer100g(
      vitaminA: food.vitamins.vitaminA * factor,
      vitaminB: food.vitamins.vitaminB * factor,
      vitaminC: food.vitamins.vitaminC * factor,
      vitaminD: food.vitamins.vitaminD * factor,
      vitaminE: food.vitamins.vitaminE * factor,
    );
  }

  // ============================================================================
  // MINERAL CALCULATIONS (per quantity)
  // ============================================================================

  /// Calculate minerals for a food item based on quantity in grams
  ///
  /// Takes a food item and quantity in grams, returns scaled minerals.
  /// Includes: calcium, iron, magnesium, zinc
  static MineralsPer100g calculateMineralsPerQuantity(
    FoodItemFull food,
    double quantityGrams,
  ) {
    final factor = quantityGrams / 100.0;
    return MineralsPer100g(
      calcium: food.minerals.calcium * factor,
      iron: food.minerals.iron * factor,
      magnesium: food.minerals.magnesium * factor,
      zinc: food.minerals.zinc * factor,
    );
  }

  // ============================================================================
  // DAILY TOTALS CALCULATION
  // ============================================================================

  /// Calculate daily macro totals from a list of meals
  ///
  /// Aggregates all macros from multiple meals into daily totals.
  /// Returns sum of all calories, protein, carbs, and fats.
  static MacrosPer100g calculateDailyMacroTotals(
    List<MacrosPer100g> mealMacros,
  ) {
    if (mealMacros.isEmpty) {
      return const MacrosPer100g(
        calories: 0,
        protein: 0,
        carbs: 0,
        fats: 0,
      );
    }

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (final macros in mealMacros) {
      totalCalories += macros.calories;
      totalProtein += macros.protein;
      totalCarbs += macros.carbs;
      totalFats += macros.fats;
    }

    return MacrosPer100g(
      calories: totalCalories,
      protein: totalProtein,
      carbs: totalCarbs,
      fats: totalFats,
    );
  }

  /// Calculate daily micro totals from a list of meals
  ///
  /// Aggregates all micros from multiple meals into daily totals.
  static MicrosPer100g calculateDailyMicroTotals(
    List<MicrosPer100g> mealMicros,
  ) {
    if (mealMicros.isEmpty) {
      return const MicrosPer100g(
        fiber: 0,
        sugar: 0,
        sodium: 0,
        potassium: 0,
      );
    }

    double totalFiber = 0;
    double totalSugar = 0;
    double totalSodium = 0;
    double totalPotassium = 0;

    for (final micros in mealMicros) {
      totalFiber += micros.fiber;
      totalSugar += micros.sugar;
      totalSodium += micros.sodium;
      totalPotassium += micros.potassium;
    }

    return MicrosPer100g(
      fiber: totalFiber,
      sugar: totalSugar,
      sodium: totalSodium,
      potassium: totalPotassium,
    );
  }

  /// Calculate daily vitamin totals from a list of meals
  ///
  /// Aggregates all vitamins from multiple meals into daily totals.
  static VitaminsPer100g calculateDailyVitaminTotals(
    List<VitaminsPer100g> mealVitamins,
  ) {
    if (mealVitamins.isEmpty) {
      return const VitaminsPer100g(
        vitaminA: 0,
        vitaminB: 0,
        vitaminC: 0,
        vitaminD: 0,
        vitaminE: 0,
      );
    }

    double totalVitaminA = 0;
    double totalVitaminB = 0;
    double totalVitaminC = 0;
    double totalVitaminD = 0;
    double totalVitaminE = 0;

    for (final vitamins in mealVitamins) {
      totalVitaminA += vitamins.vitaminA;
      totalVitaminB += vitamins.vitaminB;
      totalVitaminC += vitamins.vitaminC;
      totalVitaminD += vitamins.vitaminD;
      totalVitaminE += vitamins.vitaminE;
    }

    return VitaminsPer100g(
      vitaminA: totalVitaminA,
      vitaminB: totalVitaminB,
      vitaminC: totalVitaminC,
      vitaminD: totalVitaminD,
      vitaminE: totalVitaminE,
    );
  }

  /// Calculate daily mineral totals from a list of meals
  ///
  /// Aggregates all minerals from multiple meals into daily totals.
  static MineralsPer100g calculateDailyMineralTotals(
    List<MineralsPer100g> mealMinerals,
  ) {
    if (mealMinerals.isEmpty) {
      return const MineralsPer100g(
        calcium: 0,
        iron: 0,
        magnesium: 0,
        zinc: 0,
      );
    }

    double totalCalcium = 0;
    double totalIron = 0;
    double totalMagnesium = 0;
    double totalZinc = 0;

    for (final minerals in mealMinerals) {
      totalCalcium += minerals.calcium;
      totalIron += minerals.iron;
      totalMagnesium += minerals.magnesium;
      totalZinc += minerals.zinc;
    }

    return MineralsPer100g(
      calcium: totalCalcium,
      iron: totalIron,
      magnesium: totalMagnesium,
      zinc: totalZinc,
    );
  }

  // ============================================================================
  // REMAINING MACROS CALCULATION
  // ============================================================================

  /// Calculate remaining macros against daily targets
  ///
  /// Returns the difference between target and consumed values.
  /// Positive values mean room remaining, negative means exceeded.
  ///
  /// Example:
  /// - Target: 2000 calories
  /// - Consumed: 1500 calories
  /// - Remaining: 500 calories
  static MacrosPer100g calculateRemainingMacros(
    MacrosPer100g consumed,
    MacrosPer100g targets,
  ) {
    return MacrosPer100g(
      calories: targets.calories - consumed.calories,
      protein: targets.protein - consumed.protein,
      carbs: targets.carbs - consumed.carbs,
      fats: targets.fats - consumed.fats,
    );
  }

  /// Calculate remaining micros against daily targets
  ///
  /// Returns the difference between target and consumed values.
  static MicrosPer100g calculateRemainingMicros(
    MicrosPer100g consumed,
    MicrosPer100g targets,
  ) {
    return MicrosPer100g(
      fiber: targets.fiber - consumed.fiber,
      sugar: targets.sugar - consumed.sugar,
      sodium: targets.sodium - consumed.sodium,
      potassium: targets.potassium - consumed.potassium,
    );
  }

  /// Calculate remaining vitamins against daily targets
  ///
  /// Returns the difference between target and consumed values.
  static VitaminsPer100g calculateRemainingVitamins(
    VitaminsPer100g consumed,
    VitaminsPer100g targets,
  ) {
    return VitaminsPer100g(
      vitaminA: targets.vitaminA - consumed.vitaminA,
      vitaminB: targets.vitaminB - consumed.vitaminB,
      vitaminC: targets.vitaminC - consumed.vitaminC,
      vitaminD: targets.vitaminD - consumed.vitaminD,
      vitaminE: targets.vitaminE - consumed.vitaminE,
    );
  }

  /// Calculate remaining minerals against daily targets
  ///
  /// Returns the difference between target and consumed values.
  static MineralsPer100g calculateRemainingMinerals(
    MineralsPer100g consumed,
    MineralsPer100g targets,
  ) {
    return MineralsPer100g(
      calcium: targets.calcium - consumed.calcium,
      iron: targets.iron - consumed.iron,
      magnesium: targets.magnesium - consumed.magnesium,
      zinc: targets.zinc - consumed.zinc,
    );
  }

  // ============================================================================
  // COLOR CODING HELPERS
  // ============================================================================

  /// Determine color status for a nutrient value
  ///
  /// Returns:
  /// - 'green': Within target range (75-125% of target)
  /// - 'orange': Moderate deviation (50-75% or 125-150% of target)
  /// - 'red': Outside acceptable range (<50% or >150% of target)
  ///
  /// Example:
  /// - Target: 100g protein
  /// - Consumed: 85g protein (85% of target) = green
  /// - Consumed: 60g protein (60% of target) = orange
  /// - Consumed: 40g protein (40% of target) = red
  static String getNutrientColorStatus(
    double consumed,
    double target,
  ) {
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

  /// Get percentage of target consumed
  ///
  /// Returns percentage as 0-100+ value.
  /// Example: consumed=50, target=100 returns 50.0
  static double getPercentageOfTarget(double consumed, double target) {
    if (target <= 0) return 0;
    return (consumed / target) * 100;
  }

  /// Check if nutrient is within acceptable range
  ///
  /// Returns true if consumed is between 75-125% of target
  static bool isWithinTargetRange(double consumed, double target) {
    if (target <= 0) return false;
    final percentage = (consumed / target) * 100;
    return percentage >= 75 && percentage <= 125;
  }
}
