import '../entities/food_item.dart';
import '../repositories/food_repository.dart';

/// Data model for food alternative with quality score.
class FoodAlternative {
  final FoodItem food;
  final double qualityScore; // 0-100, higher is better match
  final Map<String, double> macroMatches; // macro name -> match percentage

  FoodAlternative({
    required this.food,
    required this.qualityScore,
    required this.macroMatches,
  });

  @override
  String toString() =>
      'FoodAlternative(${food.name}, score: ${qualityScore.toStringAsFixed(1)})';
}

/// Use case for finding foods with similar macros.
/// Finds alternative foods that match the target food's macros within 10% tolerance.
class GetFoodAlternativesUseCase {
  final FoodRepository repository;

  static const double macroTolerance = 0.10;
  static const int minAlternatives = 3;
  static const int maxAlternatives = 5;

  GetFoodAlternativesUseCase(this.repository);

  /// Get food alternatives for a given food.
  Future<List<FoodAlternative>> getAlternatives(
    FoodItem targetFood, {
    int minResults = minAlternatives,
    int maxResults = maxAlternatives,
  }) async {
    final allFoods = await repository.getAllFoods();
    final candidates = allFoods.where((f) => f.id != targetFood.id).toList();

    final alternatives = <FoodAlternative>[];
    for (final candidate in candidates) {
      final qualityScore = _calculateQualityScore(targetFood, candidate);
      if (qualityScore > 0) {
        alternatives.add(
          FoodAlternative(
            food: candidate,
            qualityScore: qualityScore,
            macroMatches: _calculateMacroMatches(targetFood, candidate),
          ),
        );
      }
    }

    alternatives.sort((a, b) => b.qualityScore.compareTo(a.qualityScore));

    final resultCount = alternatives.length < minResults
        ? alternatives.length
        : (alternatives.length < maxResults ? alternatives.length : maxResults);

    return alternatives.take(resultCount).toList();
  }

  double _calculateQualityScore(
    FoodItem targetFood,
    FoodItem candidateFood,
  ) {
    final macroMatches = _calculateMacroMatches(targetFood, candidateFood);

    for (final match in macroMatches.values) {
      if (match <= -101) return 0;
    }

    final qualityScores =
        macroMatches.values.map((match) => 100 - match.abs()).toList();
    if (qualityScores.isEmpty) return 0;

    return qualityScores.reduce((a, b) => a + b) / qualityScores.length;
  }

  Map<String, double> _calculateMacroMatches(
    FoodItem targetFood,
    FoodItem candidateFood,
  ) {
    final matches = <String, double>{};
    matches['calories'] = _calculatePercentageDifference(
      targetFood.caloriesPer100g,
      candidateFood.caloriesPer100g,
    );
    matches['protein'] = _calculatePercentageDifference(
      targetFood.proteinPer100g,
      candidateFood.proteinPer100g,
    );
    matches['carbs'] = _calculatePercentageDifference(
      targetFood.carbsPer100g,
      candidateFood.carbsPer100g,
    );
    matches['fats'] = _calculatePercentageDifference(
      targetFood.fatPer100g,
      candidateFood.fatPer100g,
    );
    return matches;
  }

  double _calculatePercentageDifference(double target, double candidate) {
    if (target == 0) {
      return candidate == 0 ? 0 : -101;
    }

    final percentageDiff = ((candidate - target) / target) * 100;
    if (percentageDiff.abs() > macroTolerance * 100) {
      return -101;
    }
    return percentageDiff.clamp(-100.0, 100.0);
  }
}
