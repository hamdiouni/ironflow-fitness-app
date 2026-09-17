import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/entities.dart';

/// Nutrition issue detected by analysis
class NutritionIssue {
  final String type; // 'deficiency', 'excess', 'timing'
  final String nutrient;
  final String severity; // 'low', 'moderate', 'high'
  final String description;
  final List<String> suggestedFoods;
  final String reasoning;

  NutritionIssue({
    required this.type,
    required this.nutrient,
    required this.severity,
    required this.description,
    required this.suggestedFoods,
    required this.reasoning,
  });
}

/// Use case for analyzing nutrition and providing coaching suggestions
///
/// Analyzes last 7 days of nutrition logs to:
/// - Detect nutrient deficiencies
/// - Identify high sugar/sodium intake
/// - Suggest specific foods to fix issues
/// - Recommend meal timing
///
/// **Validates: Requirements 7.4**
class AnalyzeNutritionUseCase {
  final NutritionRepository _nutritionRepository;

  AnalyzeNutritionUseCase({
    required NutritionRepository nutritionRepository,
  }) : _nutritionRepository = nutritionRepository;

  /// Analyze nutrition and return issues with suggestions
  Future<List<NutritionIssue>> execute() async {
    final issues = <NutritionIssue>[];

    // Get last 7 days of nutrition data
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final nutritionHistory = await _nutritionRepository.getNutritionHistory(
      sevenDaysAgo,
      DateTime.now(),
    );

    if (nutritionHistory.isEmpty) {
      return issues;
    }

    // Get nutrition targets
    final targets = await _nutritionRepository.getNutritionTargets();
    if (targets == null) {
      return issues;
    }

    // Calculate averages
    final avgCalories = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalCalories,
    ) / nutritionHistory.length;

    final avgProtein = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalProtein,
    ) / nutritionHistory.length;

    final avgCarbs = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalCarbs,
    ) / nutritionHistory.length;

    final avgFats = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalFats,
    ) / nutritionHistory.length;

    final avgFiber = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalFiber,
    ) / nutritionHistory.length;

    final avgSugar = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalSugar,
    ) / nutritionHistory.length;

    final avgSodium = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalSodium,
    ) / nutritionHistory.length;

    final avgVitaminA = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalVitaminA,
    ) / nutritionHistory.length;

    final avgVitaminC = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalVitaminC,
    ) / nutritionHistory.length;

    final avgVitaminD = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalVitaminD,
    ) / nutritionHistory.length;

    final avgCalcium = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalCalcium,
    ) / nutritionHistory.length;

    final avgIron = nutritionHistory.fold<double>(
      0,
      (sum, day) => sum + day.totalIron,
    ) / nutritionHistory.length;

    // 1. Check for macro deficiencies (< 80% of target)
    if (avgProtein < targets.macros.protein * 0.8) {
      final deficit = targets.macros.protein - avgProtein;
      issues.add(NutritionIssue(
        type: 'deficiency',
        nutrient: 'Protein',
        severity: _calculateSeverity(avgProtein / targets.macros.protein),
        description: 'You\'re averaging ${avgProtein.toStringAsFixed(0)}g protein/day, '
            '${deficit.toStringAsFixed(0)}g below your target',
        suggestedFoods: [
          'Chicken breast (31g per 100g)',
          'Greek yogurt (10g per 100g)',
          'Eggs (13g per 100g)',
          'Whey protein (80g per 100g)',
          'Salmon (25g per 100g)',
        ],
        reasoning: 'Protein is essential for muscle recovery and growth',
      ));
    }

    // 2. Check for fiber deficiency (< 80% of target)
    if (avgFiber < targets.micros.fiber * 0.8) {
      final deficit = targets.micros.fiber - avgFiber;
      issues.add(NutritionIssue(
        type: 'deficiency',
        nutrient: 'Fiber',
        severity: _calculateSeverity(avgFiber / targets.micros.fiber),
        description: 'You\'re averaging ${avgFiber.toStringAsFixed(0)}g fiber/day, '
            '${deficit.toStringAsFixed(0)}g below your target',
        suggestedFoods: [
          'Oats (10g per 100g)',
          'Broccoli (2.6g per 100g)',
          'Black beans (16g per 100g)',
          'Chia seeds (34g per 100g)',
          'Raspberries (6.5g per 100g)',
        ],
        reasoning: 'Fiber aids digestion and helps maintain stable blood sugar',
      ));
    }

    // 3. Check for high sugar (> 50g/day)
    if (avgSugar > 50) {
      issues.add(NutritionIssue(
        type: 'excess',
        nutrient: 'Sugar',
        severity: avgSugar > 75 ? 'high' : 'moderate',
        description: 'You\'re averaging ${avgSugar.toStringAsFixed(0)}g sugar/day, '
            'which is above the recommended 50g limit',
        suggestedFoods: [
          'Replace sugary drinks with water',
          'Choose whole fruits over fruit juice',
          'Limit processed snacks',
          'Use natural sweeteners like stevia',
        ],
        reasoning: 'High sugar intake can lead to energy crashes and fat gain',
      ));
    }

    // 4. Check for high sodium (> 2300mg/day)
    if (avgSodium > 2300) {
      issues.add(NutritionIssue(
        type: 'excess',
        nutrient: 'Sodium',
        severity: avgSodium > 3000 ? 'high' : 'moderate',
        description: 'You\'re averaging ${avgSodium.toStringAsFixed(0)}mg sodium/day, '
            'which is above the recommended 2300mg limit',
        suggestedFoods: [
          'Reduce processed foods',
          'Cook at home more often',
          'Use herbs and spices instead of salt',
          'Choose low-sodium alternatives',
        ],
        reasoning: 'High sodium can increase blood pressure and water retention',
      ));
    }

    // 5. Check for vitamin deficiencies
    if (avgVitaminA < targets.vitamins.vitaminA * 0.8) {
      issues.add(NutritionIssue(
        type: 'deficiency',
        nutrient: 'Vitamin A',
        severity: _calculateSeverity(avgVitaminA / targets.vitamins.vitaminA),
        description: 'Your vitamin A intake is below target',
        suggestedFoods: [
          'Sweet potatoes (709 mcg per 100g)',
          'Carrots (835 mcg per 100g)',
          'Spinach (469 mcg per 100g)',
          'Kale (241 mcg per 100g)',
        ],
        reasoning: 'Vitamin A supports vision, immune function, and skin health',
      ));
    }

    if (avgVitaminC < targets.vitamins.vitaminC * 0.8) {
      issues.add(NutritionIssue(
        type: 'deficiency',
        nutrient: 'Vitamin C',
        severity: _calculateSeverity(avgVitaminC / targets.vitamins.vitaminC),
        description: 'Your vitamin C intake is below target',
        suggestedFoods: [
          'Oranges (53 mg per 100g)',
          'Bell peppers (128 mg per 100g)',
          'Strawberries (59 mg per 100g)',
          'Broccoli (89 mg per 100g)',
        ],
        reasoning: 'Vitamin C supports immune function and collagen production',
      ));
    }

    if (avgVitaminD < targets.vitamins.vitaminD * 0.8) {
      issues.add(NutritionIssue(
        type: 'deficiency',
        nutrient: 'Vitamin D',
        severity: _calculateSeverity(avgVitaminD / targets.vitamins.vitaminD),
        description: 'Your vitamin D intake is below target',
        suggestedFoods: [
          'Salmon (11 mcg per 100g)',
          'Egg yolks (2 mcg per 100g)',
          'Fortified milk (1.3 mcg per 100g)',
          'Mushrooms (0.2 mcg per 100g)',
          'Consider a supplement',
        ],
        reasoning: 'Vitamin D supports bone health and immune function',
      ));
    }

    // 6. Check for mineral deficiencies
    if (avgCalcium < targets.minerals.calcium * 0.8) {
      issues.add(NutritionIssue(
        type: 'deficiency',
        nutrient: 'Calcium',
        severity: _calculateSeverity(avgCalcium / targets.minerals.calcium),
        description: 'Your calcium intake is below target',
        suggestedFoods: [
          'Milk (125 mg per 100g)',
          'Greek yogurt (110 mg per 100g)',
          'Cheese (700 mg per 100g)',
          'Sardines (382 mg per 100g)',
          'Kale (150 mg per 100g)',
        ],
        reasoning: 'Calcium is essential for bone health and muscle function',
      ));
    }

    if (avgIron < targets.minerals.iron * 0.8) {
      issues.add(NutritionIssue(
        type: 'deficiency',
        nutrient: 'Iron',
        severity: _calculateSeverity(avgIron / targets.minerals.iron),
        description: 'Your iron intake is below target',
        suggestedFoods: [
          'Red meat (2.6 mg per 100g)',
          'Spinach (2.7 mg per 100g)',
          'Lentils (3.3 mg per 100g)',
          'Tofu (5.4 mg per 100g)',
        ],
        reasoning: 'Iron is essential for oxygen transport and energy production',
      ));
    }

    // 7. Meal timing recommendations
    if (nutritionHistory.isNotEmpty) {
      issues.add(NutritionIssue(
        type: 'timing',
        nutrient: 'Meal Timing',
        severity: 'low',
        description: 'Optimize your meal timing for better performance',
        suggestedFoods: [
          'Pre-workout: Carbs + small protein (1-2 hours before)',
          'Post-workout: Protein + carbs (within 2 hours)',
          'Evening: Moderate carbs to support recovery',
        ],
        reasoning: 'Proper meal timing can enhance performance and recovery',
      ));
    }

    return issues;
  }

  String _calculateSeverity(double ratio) {
    if (ratio < 0.5) {
      return 'high';
    } else if (ratio < 0.8) {
      return 'moderate';
    } else {
      return 'low';
    }
  }
}
