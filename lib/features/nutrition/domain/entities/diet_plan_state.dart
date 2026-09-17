import 'package:freezed_annotation/freezed_annotation.dart';
import 'diet_plan.dart';

part 'diet_plan_state.freezed.dart';

/// Represents the active diet plan with customizations (meal swaps).
@freezed
class DietPlanState with _$DietPlanState {
  const factory DietPlanState({
    required DietPlan plan,
    @Default({}) Map<String, DietMeal> mealSwaps, // mealId -> swapped meal
    DateTime? lastUpdated,
  }) = _DietPlanState;

  const DietPlanState._();

  /// Get meals for a specific day with swaps applied.
  /// mealId format: '${dayName}_${meal.mealType.name}'
  List<DietMeal> getMealsForDay(String dayName) {
    final day = plan.days.firstWhere(
      (d) => d.dayName == dayName,
      orElse: () => plan.days.first,
    );

    return day.meals.map((meal) {
      final mealId = '${dayName}_${meal.mealType.name}';
      return mealSwaps[mealId] ?? meal;
    }).toList();
  }

  /// Swap a meal with an alternative and return updated state.
  /// mealId format: '${dayName}_${mealType.name}'
  DietPlanState swapMeal(String dayName, MealType mealType, DietMeal newMeal) {
    final mealId = '${dayName}_${mealType.name}';
    final updatedSwaps = Map<String, DietMeal>.from(mealSwaps);
    updatedSwaps[mealId] = newMeal;

    return copyWith(
      mealSwaps: updatedSwaps,
      lastUpdated: DateTime.now(),
    );
  }
}
