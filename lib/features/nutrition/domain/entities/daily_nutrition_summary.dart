import 'package:freezed_annotation/freezed_annotation.dart';
import 'macro_target.dart';
import 'meal.dart';
import 'nutrition_targets.dart';

part 'daily_nutrition_summary.freezed.dart';

/// Aggregated nutrition data for a single calendar day.
///
/// Computed getters sum the corresponding values across all [meals].
/// Supports complete nutritional tracking including macros, micros, vitamins, and minerals.
///
/// [remaining] returns how much of each macro is still available before hitting the daily target.
/// Values are clamped to zero so they never go negative.
@freezed
class DailyNutritionSummary with _$DailyNutritionSummary {
  const DailyNutritionSummary._();

  const factory DailyNutritionSummary({
    required DateTime date,
    required List<Meal> meals,
    required NutritionTargets? target,
  }) = _DailyNutritionSummary;

  // Macro totals
  double get totalCalories =>
      meals.fold(0, (sum, meal) => sum + meal.macros.calories);
  double get totalProtein =>
      meals.fold(0, (sum, meal) => sum + meal.macros.protein);
  double get totalCarbs =>
      meals.fold(0, (sum, meal) => sum + meal.macros.carbs);
  double get totalFats =>
      meals.fold(0, (sum, meal) => sum + meal.macros.fats);

  // Micro totals
  double get totalFiber =>
      meals.fold(0, (sum, meal) => sum + meal.micros.fiber);
  double get totalSugar =>
      meals.fold(0, (sum, meal) => sum + meal.micros.sugar);
  double get totalSodium =>
      meals.fold(0, (sum, meal) => sum + meal.micros.sodium);
  double get totalPotassium =>
      meals.fold(0, (sum, meal) => sum + meal.micros.potassium);

  // Vitamin totals
  double get totalVitaminA =>
      meals.fold(0, (sum, meal) => sum + meal.vitamins.vitaminA);
  double get totalVitaminB =>
      meals.fold(0, (sum, meal) => sum + meal.vitamins.vitaminB);
  double get totalVitaminC =>
      meals.fold(0, (sum, meal) => sum + meal.vitamins.vitaminC);
  double get totalVitaminD =>
      meals.fold(0, (sum, meal) => sum + meal.vitamins.vitaminD);
  double get totalVitaminE =>
      meals.fold(0, (sum, meal) => sum + meal.vitamins.vitaminE);

  // Mineral totals
  double get totalCalcium =>
      meals.fold(0, (sum, meal) => sum + meal.minerals.calcium);
  double get totalIron =>
      meals.fold(0, (sum, meal) => sum + meal.minerals.iron);
  double get totalMagnesium =>
      meals.fold(0, (sum, meal) => sum + meal.minerals.magnesium);
  double get totalZinc =>
      meals.fold(0, (sum, meal) => sum + meal.minerals.zinc);

  /// Get remaining macros before hitting daily target
  MacroTarget get remainingMacros {
    if (target == null) {
      return const MacroTarget(protein: 0, carbs: 0, fats: 0);
    }
    return MacroTarget(
      protein: (target!.macros.protein - totalProtein).clamp(0, double.infinity),
      carbs: (target!.macros.carbs - totalCarbs).clamp(0, double.infinity),
      fats: (target!.macros.fats - totalFats).clamp(0, double.infinity),
    );
  }
}
