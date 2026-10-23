import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item_conversion.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item_full.dart';

void main() {
  group('FoodItem conversion', () {
    test('toFoodItemFull copies measured values and zeroes only unknowns', () {
      const item = FoodItem(
        id: 'salmon',
        name: 'Salmon',
        category: FoodCategory.protein,
        caloriesPer100g: 208,
        proteinPer100g: 20,
        carbsPer100g: 0,
        fatPer100g: 13,
        imageUrl: 'https://example.com/salmon.png',
        tags: ['glutenFree'],
        microsPer100g: FoodMicros(
          fiberGrams: 0,
          sugarGrams: 0,
          sodiumMg: 59,
          potassiumMg: 490,
          calciumMg: 11,
          ironMg: 0.9,
          vitaminDMcg: 11,
          saturatedFatGrams: 3.1,
        ),
      );

      final full = item.toFoodItemFull();

      expect(full.id, 'salmon');
      expect(full.category, 'protein');
      expect(full.macros.calories, 208);
      expect(full.macros.protein, 20);
      expect(full.macros.fats, 13);
      expect(full.micros.sodium, 59);
      expect(full.micros.potassium, 490);
      expect(full.vitamins.vitaminD, 11);
      expect(full.minerals.calcium, 11);
      expect(full.minerals.iron, 0.9);
      expect(full.dietaryTags, ['glutenFree']);

      // The catalog does not measure these. They must remain unknown
      // (zero in the non-nullable Full shape), not category stereotypes.
      expect(full.vitamins.vitaminA, 0);
      expect(full.vitamins.vitaminB, 0);
      expect(full.vitamins.vitaminC, 0);
      expect(full.vitamins.vitaminE, 0);
      expect(full.minerals.magnesium, 0);
      expect(full.minerals.zinc, 0);
    });

    test('toFoodItem maps all nutrients FoodItem can represent', () {
      const full = FoodItemFull(
        id: 'yogurt',
        name: 'Greek Yogurt',
        category: 'Dairy',
        macros: MacrosPer100g(
          calories: 97,
          protein: 9,
          carbs: 3.9,
          fats: 5,
        ),
        micros: MicrosPer100g(
          fiber: 0,
          sugar: 4,
          sodium: 36,
          potassium: 141,
        ),
        vitamins: VitaminsPer100g(
          vitaminA: 90,
          vitaminB: 0.6,
          vitaminC: 0,
          vitaminD: 0.1,
          vitaminE: 0.03,
        ),
        minerals: MineralsPer100g(
          calcium: 110,
          iron: 0.07,
          magnesium: 11,
          zinc: 0.52,
        ),
        imageUrl: '',
        dietaryTags: ['vegetarian'],
      );

      final item = full.toFoodItem();

      expect(item.category, FoodCategory.dairy);
      expect(item.caloriesPer100g, 97);
      expect(item.proteinPer100g, 9);
      expect(item.tags, ['vegetarian']);
      expect(item.microsPer100g?.sugarGrams, 4);
      expect(item.microsPer100g?.potassiumMg, 141);
      expect(item.microsPer100g?.calciumMg, 110);
      expect(item.microsPer100g?.vitaminDMcg, 0.1);
    });

    test('foodCategoryFromName is case-insensitive with a generic fallback',
        () {
      expect(foodCategoryFromName(' VEGETABLES '), FoodCategory.vegetables);
      expect(foodCategoryFromName('ready-meal'), FoodCategory.snacks);
    });
  });
}
