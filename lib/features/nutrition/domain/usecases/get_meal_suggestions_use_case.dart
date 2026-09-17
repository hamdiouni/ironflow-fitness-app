import '../entities/food_item_full.dart';
import '../repositories/food_repository.dart';

/// Use case for getting meal suggestions based on macro targets.
///
/// Filters meals by macro targets (within 10% tolerance) and returns
/// at least 3 alternatives if available, sorted by macro match quality.
class GetMealSuggestionsUseCase {
  final FoodRepository _repository;

  GetMealSuggestionsUseCase(this._repository);

  /// Gets meal suggestions for the given macro targets.
  ///
  /// [targetCalories] - Target calories for the meal
  /// [targetProtein] - Target protein in grams
  /// [targetCarbs] - Target carbs in grams
  /// [targetFat] - Target fat in grams
  /// [tolerance] - Tolerance percentage (default 10%)
  ///
  /// Returns list of meals sorted by macro match quality.
  Future<List<FoodItemFull>> call({
    required double targetCalories,
    required double targetProtein,
    required double targetCarbs,
    required double targetFat,
    double tolerance = 0.1,
  }) async {
    // Get all foods from repository
    final allFoods = await _repository.getAllFoods();

    // Filter by macro targets with tolerance
    final suggestions = <FoodItemFull>[];

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

    // Sort by macro match quality (closest to target)
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

    // Return at least 3 alternatives if available
    return suggestions.take(3).toList();
  }

  /// Checks if a food matches the macro targets within tolerance.
  bool _matchesMacros(
    FoodItemFull food,
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

    return (food.macros.calories >= targetCalories - calorieRange &&
            food.macros.calories <= targetCalories + calorieRange) &&
        (food.macros.protein >= targetProtein - proteinRange &&
            food.macros.protein <= targetProtein + proteinRange) &&
        (food.macros.carbs >= targetCarbs - carbsRange &&
            food.macros.carbs <= targetCarbs + carbsRange) &&
        (food.macros.fats >= targetFat - fatRange && food.macros.fats <= targetFat + fatRange);
  }

  /// Calculates a score for how well a food matches the macro targets.
  ///
  /// Lower score = better match
  double _calculateMacroScore(
    FoodItemFull food,
    double targetCalories,
    double targetProtein,
    double targetCarbs,
    double targetFat,
  ) {
    final caloriesDiff = (food.macros.calories - targetCalories).abs();
    final proteinDiff = (food.macros.protein - targetProtein).abs();
    final carbsDiff = (food.macros.carbs - targetCarbs).abs();
    final fatDiff = (food.macros.fats - targetFat).abs();

    // Weighted score (calories weighted more heavily)
    return (caloriesDiff * 0.4) +
        (proteinDiff * 0.2) +
        (carbsDiff * 0.2) +
        (fatDiff * 0.2);
  }
}
