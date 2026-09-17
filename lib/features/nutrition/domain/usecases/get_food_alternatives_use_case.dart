import '../entities/food_item_full.dart';
import '../repositories/food_repository.dart';

/// Data model for food alternative with quality score
class FoodAlternative {
  final FoodItemFull food;
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

/// Use case for finding foods with similar macros
/// Finds alternative foods that match the target food's macros within 10% tolerance
class GetFoodAlternativesUseCase {
  final FoodRepository repository;

  // Tolerance for macro matching (10%)
  static const double macroTolerance = 0.10;

  // Minimum number of alternatives to return
  static const int minAlternatives = 3;

  // Maximum number of alternatives to return
  static const int maxAlternatives = 5;

  GetFoodAlternativesUseCase(this.repository);

  /// Get food alternatives for a given food
  /// Returns at least 3 alternatives (if available) sorted by quality score
  /// Excludes the original food from results
  Future<List<FoodAlternative>> getAlternatives(
    FoodItemFull targetFood, {
    int minResults = minAlternatives,
    int maxResults = maxAlternatives,
  }) async {
    // Get all foods from repository
    final allFoods = await repository.getAllFoods();

    // Filter out the original food
    final candidates = allFoods.where((f) => f.id != targetFood.id).toList();

    // Calculate quality scores for each candidate
    final alternatives = <FoodAlternative>[];
    for (final candidate in candidates) {
      final qualityScore = _calculateQualityScore(targetFood, candidate);

      // Only include foods with quality score > 0 (within tolerance)
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

    // Sort by quality score (highest first)
    alternatives.sort((a, b) => b.qualityScore.compareTo(a.qualityScore));

    // Return top results, ensuring at least minResults if available
    final resultCount = alternatives.length < minResults
        ? alternatives.length
        : (alternatives.length < maxResults ? alternatives.length : maxResults);

    return alternatives.take(resultCount).toList();
  }

  /// Calculate overall quality score for a food alternative
  /// Returns 0-100 where 100 is a perfect match
  /// Returns 0 if any macro is outside tolerance
  double _calculateQualityScore(
    FoodItemFull targetFood,
    FoodItemFull candidateFood,
  ) {
    final macroMatches = _calculateMacroMatches(targetFood, candidateFood);

    // Check if all macros are within tolerance
    for (final match in macroMatches.values) {
      if (match <= -101) {
        // Outside tolerance
        return 0;
      }
    }

    // Calculate average match quality
    // Convert match percentages to quality scores
    // Perfect match (0% difference) = 100
    // At tolerance limit (±10% difference) = 0
    final qualityScores = macroMatches.values.map((match) {
      // match ranges from -100 (at -10% tolerance limit) to +100 (at +10% tolerance limit)
      // We want: 0% difference = 100, ±10% difference = 0
      // So: quality = 100 - abs(match)
      return 100 - match.abs();
    }).toList();

    if (qualityScores.isEmpty) {
      return 0;
    }

    // Return average quality score
    return qualityScores.reduce((a, b) => a + b) / qualityScores.length;
  }

  /// Calculate macro match percentages for each macro
  /// Returns map of macro name -> match percentage
  /// Positive values indicate within tolerance, negative indicates outside
  Map<String, double> _calculateMacroMatches(
    FoodItemFull targetFood,
    FoodItemFull candidateFood,
  ) {
    final targetMacros = targetFood.macros;
    final candidateMacros = candidateFood.macros;

    final matches = <String, double>{};

    // Calculate percentage difference for each macro
    // Using formula: (candidate - target) / target * 100
    // Negative values mean candidate is lower, positive means higher

    // Calories
    matches['calories'] = _calculatePercentageDifference(
      targetMacros.calories,
      candidateMacros.calories,
    );

    // Protein
    matches['protein'] = _calculatePercentageDifference(
      targetMacros.protein,
      candidateMacros.protein,
    );

    // Carbs
    matches['carbs'] = _calculatePercentageDifference(
      targetMacros.carbs,
      candidateMacros.carbs,
    );

    // Fats
    matches['fats'] = _calculatePercentageDifference(
      targetMacros.fats,
      candidateMacros.fats,
    );

    return matches;
  }

  /// Calculate percentage difference between target and candidate
  /// Returns value between -100 and 100
  /// 0 = perfect match
  /// Negative = candidate is lower
  /// Positive = candidate is higher
  /// Returns -101 if outside tolerance (>10% difference)
  double _calculatePercentageDifference(double target, double candidate) {
    // Handle zero target values
    if (target == 0) {
      // If target is 0, candidate should also be close to 0
      if (candidate == 0) {
        return 0; // Perfect match
      }
      // If target is 0 but candidate is not, it's outside tolerance
      return -101;
    }

    final percentageDiff = ((candidate - target) / target) * 100;

    // Check if within tolerance (±10%)
    if (percentageDiff.abs() > macroTolerance * 100) {
      return -101; // Outside tolerance
    }

    // Return the percentage difference, clamped to -100 to 100 range
    return percentageDiff.clamp(-100.0, 100.0);
  }
}
