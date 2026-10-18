import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/nutrition/data/models/meal_model.dart';
import 'package:progression_tracker/features/nutrition/data/verified_foods_data.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';

void main() {
  group('Meal Snapshot Stability and Provenance', () {
    test('Logged meal captures and freezes macros and micros from FoodItem', () {
      final salmon = verifiedFoodsList.firstWhere((f) => f.id == 'usda_salmon_atlantic_wild_raw');
      const double grams = 150.0;
      final macrosMap = salmon.macrosForGrams(grams);
      final microsObj = salmon.microsForGrams(grams);

      final meal = Meal.create(
        name: 'Wild Atlantic Salmon (150g)',
        macros: MealMacros(
          calories: macrosMap.calories,
          protein: macrosMap.protein,
          carbs: macrosMap.carbs,
          fats: macrosMap.fat,
        ),
        micros: MealMicros(
          fiber: microsObj?.fiberGrams ?? 0.0,
          sugar: microsObj?.sugarGrams ?? 0.0,
          sodium: microsObj?.sodiumMg ?? 0.0,
          potassium: microsObj?.potassiumMg ?? 0.0,
        ),
        vitamins: MealVitamins(
          vitaminA: 0.0,
          vitaminB: 0.0,
          vitaminC: 0.0,
          vitaminD: microsObj?.vitaminDMcg ?? 0.0,
          vitaminE: 0.0,
        ),
        minerals: MealMinerals(
          calcium: microsObj?.calciumMg ?? 0.0,
          iron: microsObj?.ironMg ?? 0.0,
          magnesium: 0.0,
          zinc: 0.0,
        ),
      );

      // Verify the frozen values match wild salmon at 150g (142 kcal/100g, 19.8g P, 6.3g F, 490mg K, 11mcg Vit D)
      expect(meal.macros.calories, closeTo(142.0 * 1.5, 0.01));
      expect(meal.macros.protein, closeTo(19.8 * 1.5, 0.01));
      expect(meal.macros.fats, closeTo(6.3 * 1.5, 0.01));
      expect(meal.micros.potassium, closeTo(490.0 * 1.5, 0.01));
      expect(meal.vitamins.vitaminD, closeTo(11.0 * 1.5, 0.01));

      // Convert to Hive data layer model
      final model = MealModel.fromEntity(meal);
      final modelJson = model.toJson();

      // Simulate Hive serialization/deserialization cycle
      final serializedJsonStr = jsonEncode(modelJson);
      final deserializedJson = jsonDecode(serializedJsonStr) as Map<String, dynamic>;
      final restoredModel = MealModel.fromJson(deserializedJson);
      final restoredMeal = restoredModel.toEntity();

      // Verify exact snapshot preservation
      expect(restoredMeal.id, equals(meal.id));
      expect(restoredMeal.name, equals(meal.name));
      expect(restoredMeal.macros.calories, equals(meal.macros.calories));
      expect(restoredMeal.macros.protein, equals(meal.macros.protein));
      expect(restoredMeal.macros.fats, equals(meal.macros.fats));
      expect(restoredMeal.micros.potassium, equals(meal.micros.potassium));
      expect(restoredMeal.vitamins.vitaminD, equals(meal.vitamins.vitaminD));
    });

    test('Historical meal is immutable even if original food dataset changes', () {
      // Create a meal referencing an original baseline
      final initialMeal = Meal(
        id: 'frozen-meal-uuid-1234',
        name: 'Whey Protein (30g)',
        macros: const MealMacros(calories: 120, protein: 24, carbs: 3, fats: 1.5),
        micros: const MealMicros(fiber: 0, sugar: 1.5, sodium: 140, potassium: 160),
        vitamins: const MealVitamins(vitaminA: 0, vitaminB: 0, vitaminC: 0, vitaminD: 0, vitaminE: 0),
        minerals: const MealMinerals(calcium: 130, iron: 0.5, magnesium: 20, zinc: 0),
        timestamp: DateTime(2026, 10, 18, 12, 0, 0),
      );

      final model = MealModel.fromEntity(initialMeal);
      final serialized = jsonEncode(model.toJson());

      // Even if someone creates an altered food object in memory...
      final alteredFood = FoodItem(
        id: 'usda_whey_isolate',
        name: 'Whey Protein Isolate 90%',
        category: FoodCategory.dairy,
        caloriesPer100g: 9999.0, // altered
        proteinPer100g: 0.0,     // altered
        carbsPer100g: 0.0,
        fatPer100g: 0.0,
        imageUrl: 'https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=500&q=80',
        servingUnit: 'scoop',
        servingWeightGrams: 30.0,
        budgetTier: BudgetLevel.medium,
      );
      expect(alteredFood.caloriesPer100g, equals(9999.0));

      // The historical logged meal remains strictly unchanged
      final restored = MealModel.fromJson(jsonDecode(serialized) as Map<String, dynamic>).toEntity();
      expect(restored.macros.calories, equals(120.0));
      expect(restored.macros.protein, equals(24.0));
      expect(restored.micros.sodium, equals(140.0));
      expect(restored.minerals.calcium, equals(130.0));
    });
  });
}
