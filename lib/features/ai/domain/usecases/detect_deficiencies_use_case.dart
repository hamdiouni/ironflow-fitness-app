import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/food_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/entities.dart';

/// Nutrient deficiency with specific recommendations
class NutrientDeficiency {
  final String nutrient;
  final double currentAverage;
  final double target;
  final double deficitAmount;
  final double deficitPercentage;
  final List<FoodRecommendation> foodRecommendations;
  final List<String> mealIdeas;

  NutrientDeficiency({
    required this.nutrient,
    required this.currentAverage,
    required this.target,
    required this.deficitAmount,
    required this.deficitPercentage,
    required this.foodRecommendations,
    required this.mealIdeas,
  });
}

/// Food recommendation with quantity
class FoodRecommendation {
  final String foodName;
  final double nutrientPer100g;
  final double suggestedQuantity; // in grams
  final String servingDescription;

  FoodRecommendation({
    required this.foodName,
    required this.nutrientPer100g,
    required this.suggestedQuantity,
    required this.servingDescription,
  });
}

/// Use case for detecting nutritional deficiencies and providing specific food recommendations
///
/// Analyzes nutrition logs against targets to:
/// - Calculate average consumption for each nutrient
/// - Identify nutrients below 80% of target
/// - Find foods high in deficient nutrients
/// - Suggest specific quantities and meal ideas
///
/// **Validates: Requirements 7.6**
class DetectDeficienciesUseCase {
  final NutritionRepository _nutritionRepository;
  final FoodRepository _foodRepository;

  DetectDeficienciesUseCase({
    required NutritionRepository nutritionRepository,
    required FoodRepository foodRepository,
  })  : _nutritionRepository = nutritionRepository,
        _foodRepository = foodRepository;

  /// Detect deficiencies and return detailed recommendations
  Future<List<NutrientDeficiency>> execute() async {
    final deficiencies = <NutrientDeficiency>[];

    // Get last 7 days of nutrition data
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final nutritionHistory = await _nutritionRepository.getNutritionHistory(
      sevenDaysAgo,
      DateTime.now(),
    );

    if (nutritionHistory.isEmpty) {
      return deficiencies;
    }

    // Get nutrition targets
    final targets = await _nutritionRepository.getNutritionTargets();
    if (targets == null) {
      return deficiencies;
    }

    // Get food database for recommendations
    final foods = await _foodRepository.getAllFoods();

    // Calculate averages for all nutrients
    final avgProtein = _calculateAverage(
      nutritionHistory,
      (day) => day.totalProtein,
    );
    final avgFiber = _calculateAverage(
      nutritionHistory,
      (day) => day.totalFiber,
    );
    final avgVitaminA = _calculateAverage(
      nutritionHistory,
      (day) => day.totalVitaminA,
    );
    final avgVitaminB = _calculateAverage(
      nutritionHistory,
      (day) => day.totalVitaminB,
    );
    final avgVitaminC = _calculateAverage(
      nutritionHistory,
      (day) => day.totalVitaminC,
    );
    final avgVitaminD = _calculateAverage(
      nutritionHistory,
      (day) => day.totalVitaminD,
    );
    final avgVitaminE = _calculateAverage(
      nutritionHistory,
      (day) => day.totalVitaminE,
    );
    final avgCalcium = _calculateAverage(
      nutritionHistory,
      (day) => day.totalCalcium,
    );
    final avgIron = _calculateAverage(
      nutritionHistory,
      (day) => day.totalIron,
    );
    final avgMagnesium = _calculateAverage(
      nutritionHistory,
      (day) => day.totalMagnesium,
    );
    final avgZinc = _calculateAverage(
      nutritionHistory,
      (day) => day.totalZinc,
    );

    // Check each nutrient for deficiency (< 80% of target)
    
    // Protein
    if (avgProtein < targets.macros.protein * 0.8) {
      deficiencies.add(_createDeficiency(
        nutrient: 'Protein',
        currentAverage: avgProtein,
        target: targets.macros.protein,
        foods: foods,
        nutrientExtractor: (food) => food.macros.protein,
        mealIdeas: [
          'Grilled chicken breast with quinoa',
          'Greek yogurt with berries and nuts',
          'Protein shake with banana',
          'Salmon with sweet potato',
          'Scrambled eggs with whole grain toast',
        ],
      ));
    }

    // Fiber
    if (avgFiber < targets.micros.fiber * 0.8) {
      deficiencies.add(_createDeficiency(
        nutrient: 'Fiber',
        currentAverage: avgFiber,
        target: targets.micros.fiber,
        foods: foods,
        nutrientExtractor: (food) => food.micros.fiber,
        mealIdeas: [
          'Oatmeal with chia seeds and berries',
          'Black bean and vegetable burrito',
          'Broccoli and chickpea stir-fry',
          'Lentil soup with whole grain bread',
          'Apple slices with almond butter',
        ],
      ));
    }

    // Vitamin A
    if (avgVitaminA < targets.vitamins.vitaminA * 0.8) {
      deficiencies.add(_createDeficiency(
        nutrient: 'Vitamin A',
        currentAverage: avgVitaminA,
        target: targets.vitamins.vitaminA,
        foods: foods,
        nutrientExtractor: (food) => food.vitamins.vitaminA,
        mealIdeas: [
          'Roasted sweet potato with butter',
          'Carrot and ginger soup',
          'Spinach and feta omelet',
          'Kale salad with lemon dressing',
          'Butternut squash risotto',
        ],
      ));
    }

    // Vitamin B
    if (avgVitaminB < targets.vitamins.vitaminB * 0.8) {
      deficiencies.add(_createDeficiency(
        nutrient: 'Vitamin B',
        currentAverage: avgVitaminB,
        target: targets.vitamins.vitaminB,
        foods: foods,
        nutrientExtractor: (food) => food.vitamins.vitaminB,
        mealIdeas: [
          'Whole grain cereal with milk',
          'Tuna sandwich on whole wheat',
          'Chicken and brown rice bowl',
          'Fortified nutritional yeast on popcorn',
          'Beef and vegetable stir-fry',
        ],
      ));
    }

    // Vitamin C
    if (avgVitaminC < targets.vitamins.vitaminC * 0.8) {
      deficiencies.add(_createDeficiency(
        nutrient: 'Vitamin C',
        currentAverage: avgVitaminC,
        target: targets.vitamins.vitaminC,
        foods: foods,
        nutrientExtractor: (food) => food.vitamins.vitaminC,
        mealIdeas: [
          'Orange and strawberry smoothie',
          'Bell pepper and hummus snack',
          'Broccoli and lemon pasta',
          'Kiwi and yogurt parfait',
          'Tomato and basil salad',
        ],
      ));
    }

    // Vitamin D
    if (avgVitaminD < targets.vitamins.vitaminD * 0.8) {
      deficiencies.add(_createDeficiency(
        nutrient: 'Vitamin D',
        currentAverage: avgVitaminD,
        target: targets.vitamins.vitaminD,
        foods: foods,
        nutrientExtractor: (food) => food.vitamins.vitaminD,
        mealIdeas: [
          'Grilled salmon with asparagus',
          'Scrambled eggs with mushrooms',
          'Fortified milk with cereal',
          'Tuna salad sandwich',
          'Consider a vitamin D supplement',
        ],
      ));
    }

    // Vitamin E
    if (avgVitaminE < targets.vitamins.vitaminE * 0.8) {
      deficiencies.add(_createDeficiency(
        nutrient: 'Vitamin E',
        currentAverage: avgVitaminE,
        target: targets.vitamins.vitaminE,
        foods: foods,
        nutrientExtractor: (food) => food.vitamins.vitaminE,
        mealIdeas: [
          'Almond butter on whole grain toast',
          'Sunflower seed trail mix',
          'Avocado toast with olive oil',
          'Spinach salad with nuts',
          'Peanut butter smoothie',
        ],
      ));
    }

    // Calcium
    if (avgCalcium < targets.minerals.calcium * 0.8) {
      deficiencies.add(_createDeficiency(
        nutrient: 'Calcium',
        currentAverage: avgCalcium,
        target: targets.minerals.calcium,
        foods: foods,
        nutrientExtractor: (food) => food.minerals.calcium,
        mealIdeas: [
          'Greek yogurt with granola',
          'Cheese and whole grain crackers',
          'Sardines on toast',
          'Kale and white bean soup',
          'Fortified almond milk latte',
        ],
      ));
    }

    // Iron
    if (avgIron < targets.minerals.iron * 0.8) {
      deficiencies.add(_createDeficiency(
        nutrient: 'Iron',
        currentAverage: avgIron,
        target: targets.minerals.iron,
        foods: foods,
        nutrientExtractor: (food) => food.minerals.iron,
        mealIdeas: [
          'Beef stir-fry with spinach',
          'Lentil curry with rice',
          'Tofu scramble with vegetables',
          'Fortified cereal with orange juice',
          'Chickpea and spinach salad',
        ],
      ));
    }

    // Magnesium
    if (avgMagnesium < targets.minerals.magnesium * 0.8) {
      deficiencies.add(_createDeficiency(
        nutrient: 'Magnesium',
        currentAverage: avgMagnesium,
        target: targets.minerals.magnesium,
        foods: foods,
        nutrientExtractor: (food) => food.minerals.magnesium,
        mealIdeas: [
          'Dark chocolate and almond snack',
          'Pumpkin seed trail mix',
          'Black bean and avocado bowl',
          'Spinach and quinoa salad',
          'Banana and peanut butter smoothie',
        ],
      ));
    }

    // Zinc
    if (avgZinc < targets.minerals.zinc * 0.8) {
      deficiencies.add(_createDeficiency(
        nutrient: 'Zinc',
        currentAverage: avgZinc,
        target: targets.minerals.zinc,
        foods: foods,
        nutrientExtractor: (food) => food.minerals.zinc,
        mealIdeas: [
          'Oysters with lemon',
          'Beef and vegetable stew',
          'Pumpkin seed granola',
          'Chickpea and tahini bowl',
          'Cashew and chicken stir-fry',
        ],
      ));
    }

    return deficiencies;
  }

  double _calculateAverage(
    List<DailyNutritionSummary> history,
    double Function(DailyNutritionSummary) extractor,
  ) {
    if (history.isEmpty) return 0;
    return history.fold<double>(0, (sum, day) => sum + extractor(day)) /
        history.length;
  }

  NutrientDeficiency _createDeficiency({
    required String nutrient,
    required double currentAverage,
    required double target,
    required List<FoodItemFull> foods,
    required double Function(FoodItemFull) nutrientExtractor,
    required List<String> mealIdeas,
  }) {
    final deficitAmount = target - currentAverage;
    final deficitPercentage = (currentAverage / target) * 100;

    // Find top 5 foods high in this nutrient
    final sortedFoods = foods.toList()
      ..sort((a, b) => nutrientExtractor(b).compareTo(nutrientExtractor(a)));

    final topFoods = sortedFoods.take(5).where((food) {
      return nutrientExtractor(food) > 0;
    }).toList();

    // Create food recommendations with suggested quantities
    final recommendations = topFoods.map((food) {
      final nutrientPer100g = nutrientExtractor(food);
      // Calculate how much of this food would provide the deficit
      final quantityNeeded = (deficitAmount / nutrientPer100g) * 100;
      // Cap at reasonable serving size (max 300g)
      final suggestedQuantity = quantityNeeded.clamp(50.0, 300.0).toDouble();

      return FoodRecommendation(
        foodName: food.name,
        nutrientPer100g: nutrientPer100g,
        suggestedQuantity: suggestedQuantity,
        servingDescription: _getServingDescription(
          food.name,
          suggestedQuantity,
        ),
      );
    }).toList();

    return NutrientDeficiency(
      nutrient: nutrient,
      currentAverage: currentAverage,
      target: target,
      deficitAmount: deficitAmount,
      deficitPercentage: deficitPercentage,
      foodRecommendations: recommendations,
      mealIdeas: mealIdeas,
    );
  }

  String _getServingDescription(String foodName, double grams) {
    // Provide user-friendly serving descriptions
    if (grams < 100) {
      return '${grams.toStringAsFixed(0)}g (small serving)';
    } else if (grams < 200) {
      return '${grams.toStringAsFixed(0)}g (medium serving)';
    } else {
      return '${grams.toStringAsFixed(0)}g (large serving)';
    }
  }
}
