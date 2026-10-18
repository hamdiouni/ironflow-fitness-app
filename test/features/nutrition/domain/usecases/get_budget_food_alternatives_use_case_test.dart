import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/nutrition/data/verified_foods_data.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/domain/usecases/get_budget_food_alternatives_use_case.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';

void main() {
  late GetBudgetFoodAlternativesUseCase useCase;

  setUp(() {
    useCase = const GetBudgetFoodAlternativesUseCase();
  });

  group('GetBudgetFoodAlternativesUseCase', () {
    test('returns budget-friendly alternatives for high-cost protein (Wild Salmon)', () {
      final salmon = verifiedFoodsList.firstWhere((f) => f.id == 'usda_salmon_atlantic_wild_raw');
      expect(salmon.budgetTier, equals(BudgetLevel.high));

      final alternatives = useCase.getAlternativesForFood(
        salmon,
        preferredBudget: BudgetLevel.low,
        limit: 4,
      );

      expect(alternatives.isNotEmpty, isTrue);
      // First alternative should be budget-friendly
      expect(alternatives.first.food.budgetTier, equals(BudgetLevel.low));
      // Savings badge should be present
      expect(alternatives.first.savingsBadge, contains('SAVE'));
      // Scaled grams should be > 0 and reasonable
      expect(alternatives.first.scaledGrams, greaterThanOrEqualTo(50.0));
      expect(alternatives.first.scaledGrams, lessThanOrEqualTo(500.0));
      // Protein should match salmon's 19.8g within reasonable margin
      expect(alternatives.first.scaledMacros.protein, closeTo(salmon.proteinPer100g, 8.0));
    });

    test('returns carb alternatives for rolled oats', () {
      final oats = verifiedFoodsList.firstWhere((f) => f.id == 'usda_rolled_oats_dry');
      final alternatives = useCase.getAlternativesForFood(
        oats,
        preferredBudget: BudgetLevel.low,
        limit: 3,
      );

      expect(alternatives.isNotEmpty, isTrue);
      for (final alt in alternatives) {
        // Carbs should be dominant
        expect(alt.scaledMacros.carbs, greaterThan(20.0));
      }
    });

    test('returns alternatives for a logged Meal', () {
      final meal = Meal(
        id: 'meal-uuid-1',
        name: 'Ribeye Steak (200g)',
        macros: const MealMacros(calories: 450, protein: 44, carbs: 0, fats: 30),
        micros: const MealMicros(fiber: 0, sugar: 0, sodium: 120, potassium: 500),
        vitamins: const MealVitamins(vitaminA: 0, vitaminB: 0, vitaminC: 0, vitaminD: 0, vitaminE: 0),
        minerals: const MealMinerals(calcium: 20, iron: 4, magnesium: 30, zinc: 8),
        timestamp: DateTime.now(),
      );

      final alternatives = useCase.getAlternativesForMeal(
        meal,
        preferredBudget: BudgetLevel.low,
        limit: 3,
      );

      expect(alternatives.isNotEmpty, isTrue);
      expect(alternatives.first.food.budgetTier, equals(BudgetLevel.low));
      expect(alternatives.first.scaledMacros.protein, greaterThan(25.0));
      expect(alternatives.first.rationale.isNotEmpty, isTrue);
    });
  });
}
