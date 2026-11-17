import '../entities/food_item.dart';
import '../repositories/food_repository.dart';

/// Use case for getting meal suggestions based on macro targets.
class GetMealSuggestionsUseCase {
  final FoodRepository _repository;

  GetMealSuggestionsUseCase(this._repository);

  Future<List<FoodItem>> call({
    required double targetCalories,
    required double targetProtein,
    required double targetCarbs,
    required double targetFat,
    double tolerance = 0.1,
  }) async {
    final allFoods = await _repository.getAllFoods();
    final suggestions = <FoodItem>[];

    for (final food in allFoods) {
      if (_matchesMacros(
        food,
        targetCalories,
        targetProtein,
        targetCarbs,
        targetFat,
        tolerance,
      )) {
        suggestions.add(food);
      }
    }

    suggestions.sort((a, b) {
      final scoreA = _calculateMacroScore(
        a,
        targetCalories,
        targetProtein,
        targetCarbs,
        targetFat,
      );
      final scoreB = _calculateMacroScore(
        b,
        targetCalories,
        targetProtein,
        targetCarbs,
        targetFat,
      );
      return scoreA.compareTo(scoreB);
    });

    return suggestions.take(3).toList();
  }

  bool _matchesMacros(
    FoodItem food,
    double targetCalories,
    double targetProtein,
    double targetCarbs,
    double targetFat,
    double tolerance,
  ) {
    final calorieRange = targetCalories * tolerance;
    final proteinRange = targetProtein * tolerance;
    final carbsRange = targetCarbs * tolerance;
    final fatRange = targetFat * tolerance;

    return (food.caloriesPer100g >= targetCalories - calorieRange &&
            food.caloriesPer100g <= targetCalories + calorieRange) &&
        (food.proteinPer100g >= targetProtein - proteinRange &&
            food.proteinPer100g <= targetProtein + proteinRange) &&
        (food.carbsPer100g >= targetCarbs - carbsRange &&
            food.carbsPer100g <= targetCarbs + carbsRange) &&
        (food.fatPer100g >= targetFat - fatRange &&
            food.fatPer100g <= targetFat + fatRange);
  }

  double _calculateMacroScore(
    FoodItem food,
    double targetCalories,
    double targetProtein,
    double targetCarbs,
    double targetFat,
  ) {
    final caloriesDiff = (food.caloriesPer100g - targetCalories).abs();
    final proteinDiff = (food.proteinPer100g - targetProtein).abs();
    final carbsDiff = (food.carbsPer100g - targetCarbs).abs();
    final fatDiff = (food.fatPer100g - targetFat).abs();

    return (caloriesDiff * 0.4) +
        (proteinDiff * 0.2) +
        (carbsDiff * 0.2) +
        (fatDiff * 0.2);
  }
}
