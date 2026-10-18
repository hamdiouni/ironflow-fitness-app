import 'package:progression_tracker/features/nutrition/data/food_database.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart' show BudgetLevel;

/// Represents a budget-optimized food alternative with portion scaling and rationale.
class BudgetFoodAlternative {
  const BudgetFoodAlternative({
    required this.food,
    required this.scaledGrams,
    required this.scaledServings,
    required this.scaledMacros,
    required this.scaledMicros,
    required this.savingsBadge,
    required this.rationale,
    required this.similarityScore,
  });

  final FoodItem food;
  final double scaledGrams;
  final double scaledServings;
  final FoodMacros scaledMacros;
  final FoodMicros? scaledMicros;
  final String savingsBadge;
  final String rationale;
  final double similarityScore; // 0.0 to 1.0
}

/// Use case for generating budget-friendly and equi-macro food alternatives
/// from authoritative USDA verified foods.
///
/// Designed to help users meet nutritional targets while reducing grocery expenses
/// in accordance with their onboarding diet budget profile.
class GetBudgetFoodAlternativesUseCase {
  const GetBudgetFoodAlternativesUseCase();

  /// Finds alternatives for a given [FoodItem] prioritizing lower or matching budget tiers.
  List<BudgetFoodAlternative> getAlternativesForFood(
    FoodItem targetFood, {
    BudgetLevel? preferredBudget,
    int limit = 4,
  }) {
    return _findAlternatives(
      targetCalories: targetFood.caloriesPer100g,
      targetProtein: targetFood.proteinPer100g,
      targetCarbs: targetFood.carbsPer100g,
      targetFat: targetFood.fatPer100g,
      sourceFoodId: targetFood.id,
      sourceBudget: targetFood.budgetTier,
      preferredBudget: preferredBudget,
      limit: limit,
    );
  }

  /// Finds alternatives for a logged [Meal] prioritizing budget-friendly staples.
  List<BudgetFoodAlternative> getAlternativesForMeal(
    Meal meal, {
    BudgetLevel? preferredBudget,
    int limit = 4,
  }) {
    return _findAlternatives(
      targetCalories: meal.macros.calories,
      targetProtein: meal.macros.protein,
      targetCarbs: meal.macros.carbs,
      targetFat: meal.macros.fats,
      sourceFoodId: null,
      sourceBudget: null,
      preferredBudget: preferredBudget,
      limit: limit,
    );
  }

  List<BudgetFoodAlternative> _findAlternatives({
    required double targetCalories,
    required double targetProtein,
    required double targetCarbs,
    required double targetFat,
    required String? sourceFoodId,
    required BudgetLevel? sourceBudget,
    required BudgetLevel? preferredBudget,
    required int limit,
  }) {
    if (targetCalories <= 0) return const [];

    final isProteinDominant = (targetProtein * 4.0) / targetCalories >= 0.35 || targetProtein >= 15.0;
    final isCarbDominant = (targetCarbs * 4.0) / targetCalories >= 0.45 || targetCarbs >= 25.0;
    final isFatDominant = (targetFat * 9.0) / targetCalories >= 0.45;

    final allFoods = FoodDatabase.foods;
    final results = <BudgetFoodAlternative>[];

    for (final candidate in allFoods) {
      if (sourceFoodId != null && candidate.id == sourceFoodId) continue;
      if (candidate.caloriesPer100g <= 0) continue;

      // Filter by category relevance
      if (isProteinDominant &&
          candidate.category != FoodCategory.protein &&
          candidate.category != FoodCategory.dairy) {
        continue;
      }
      if (isCarbDominant &&
          candidate.category != FoodCategory.carbs &&
          candidate.category != FoodCategory.fruits &&
          candidate.category != FoodCategory.snacks) {
        continue;
      }

      // Calculate gram scaling to match primary macro or calories
      double gramsToMatch;
      if (isProteinDominant && candidate.proteinPer100g > 0 && targetProtein > 0) {
        gramsToMatch = (targetProtein / candidate.proteinPer100g) * 100.0;
      } else if (isCarbDominant && candidate.carbsPer100g > 0 && targetCarbs > 0) {
        gramsToMatch = (targetCarbs / candidate.carbsPer100g) * 100.0;
      } else {
        gramsToMatch = (targetCalories / candidate.caloriesPer100g) * 100.0;
      }

      // Clamp between 20g and 600g for realistic portion bounds
      if (gramsToMatch < 20.0 || gramsToMatch > 600.0) continue;

      final scaledMacros = candidate.macrosForGrams(gramsToMatch);
      final scaledMicros = candidate.microsForGrams(gramsToMatch);

      // Compute macro distance score
      final proteinDiff = (scaledMacros.protein - targetProtein).abs();
      final caloriesDiff = (scaledMacros.calories - targetCalories).abs();

      // Lower diff is better similarity
      final macroErrorRatio = (proteinDiff / (targetProtein > 0 ? targetProtein : 1.0)) * 0.6 +
          (caloriesDiff / (targetCalories > 0 ? targetCalories : 1.0)) * 0.4;
      final similarityScore = (1.0 - (macroErrorRatio * 0.5)).clamp(0.0, 1.0);

      // Filter out poor matches
      if (similarityScore < 0.35) continue;

      // Calculate budget savings badge and rationale
      final badge = _computeSavingsBadge(candidate.budgetTier, sourceBudget, preferredBudget);
      final rationale = _generateRationale(candidate, isProteinDominant, isCarbDominant, isFatDominant);

      final scaledServings = candidate.servingWeightGrams > 0
          ? double.parse((gramsToMatch / candidate.servingWeightGrams).toStringAsFixed(1))
          : 1.0;

      results.add(
        BudgetFoodAlternative(
          food: candidate,
          scaledGrams: gramsToMatch.roundToDouble(),
          scaledServings: scaledServings,
          scaledMacros: scaledMacros,
          scaledMicros: scaledMicros,
          savingsBadge: badge,
          rationale: rationale,
          similarityScore: similarityScore,
        ),
      );
    }

    // Sort by:
    // 1. Preferred budget matches first
    // 2. Budget tier rank (low < medium < high)
    // 3. Similarity score
    results.sort((a, b) {
      if (preferredBudget != null) {
        final aMatchesPref = a.food.budgetTier == preferredBudget ? 1 : 0;
        final bMatchesPref = b.food.budgetTier == preferredBudget ? 1 : 0;
        if (aMatchesPref != bMatchesPref) return bMatchesPref.compareTo(aMatchesPref);
      }
      if (a.food.budgetTier.index != b.food.budgetTier.index) {
        return a.food.budgetTier.index.compareTo(b.food.budgetTier.index);
      }
      return b.similarityScore.compareTo(a.similarityScore);
    });

    return results.take(limit).toList();
  }

  String _computeSavingsBadge(
    BudgetLevel candidateBudget,
    BudgetLevel? sourceBudget,
    BudgetLevel? preferredBudget,
  ) {
    if (sourceBudget != null) {
      if (sourceBudget == BudgetLevel.high && candidateBudget == BudgetLevel.low) {
        return 'SAVE ~60% COST';
      }
      if (sourceBudget == BudgetLevel.high && candidateBudget == BudgetLevel.medium) {
        return 'SAVE ~35% COST';
      }
      if (sourceBudget == BudgetLevel.medium && candidateBudget == BudgetLevel.low) {
        return 'SAVE ~30% COST';
      }
    }
    if (preferredBudget != null && candidateBudget == preferredBudget) {
      return 'BUDGET MATCH';
    }
    switch (candidateBudget) {
      case BudgetLevel.low:
        return 'BUDGET STAPLE';
      case BudgetLevel.medium:
        return 'BALANCED VALUE';
      case BudgetLevel.high:
        return 'PREMIUM TIER';
    }
  }

  String _generateRationale(
    FoodItem candidate,
    bool isProtein,
    bool isCarbs,
    bool isFat,
  ) {
    if (isProtein) {
      if (candidate.id.contains('egg') || candidate.id.contains('tuna')) {
        return 'Highest biological value complete protein per dollar.';
      }
      if (candidate.id.contains('thigh') || candidate.id.contains('chicken')) {
        return 'Economical poultry staple with bioavailable zinc and iron.';
      }
      if (candidate.id.contains('cottage') || candidate.id.contains('yogurt')) {
        return 'Slow-digesting casein protein with high calcium content.';
      }
      if (candidate.id.contains('beans') || candidate.id.contains('lentils')) {
        return 'Ultra budget-friendly plant protein packed with dietary fiber.';
      }
      return 'Macro-equivalent protein replacement with complete amino acid profile.';
    }
    if (isCarbs) {
      if (candidate.id.contains('oat')) {
        return 'Sustained energy release with cholesterol-lowering beta-glucan.';
      }
      if (candidate.id.contains('rice')) {
        return 'Clean, easily digestible carbohydrate base for glycogen storage.';
      }
      if (candidate.id.contains('potato')) {
        return 'Superior satiety index and high potassium content.';
      }
      return 'Cost-effective complex carbohydrate alternative.';
    }
    return 'Nutrient-dense alternative matching target caloric density.';
  }
}
