import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';

void main() {
  group('Unified FoodItem JSON & legacy FoodItemFull compatibility', () {
    test('toJson/fromAnyJson copies measured values and keeps unknowns null', () {
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

      final roundTripped = FoodItem.fromAnyJson(item.toJson());

      expect(roundTripped.id, 'salmon');
      expect(roundTripped.category, FoodCategory.protein);
      expect(roundTripped.categoryName, 'protein');
      expect(roundTripped.caloriesPer100g, 208);
      expect(roundTripped.proteinPer100g, 20);
      expect(roundTripped.fatPer100g, 13);
      expect(roundTripped.microsPer100g?.sodiumMg, 59);
      expect(roundTripped.microsPer100g?.potassiumMg, 490);
      expect(roundTripped.microsPer100g?.vitaminDMcg, 11);
      expect(roundTripped.microsPer100g?.calciumMg, 11);
      expect(roundTripped.microsPer100g?.ironMg, 0.9);
      expect(roundTripped.dietaryTags, ['glutenFree']);

      // Unmeasured micros stay null instead of being filled with category guesses.
      expect(roundTripped.microsPer100g?.vitaminAMcg, isNull);
      expect(roundTripped.microsPer100g?.vitaminBMg, isNull);
      expect(roundTripped.microsPer100g?.vitaminCMg, isNull);
      expect(roundTripped.microsPer100g?.vitaminEMg, isNull);
      expect(roundTripped.microsPer100g?.magnesiumMg, isNull);
      expect(roundTripped.microsPer100g?.zincMg, isNull);
    });

    test('fromAnyJson parses legacy nested FoodItemFull Hive/Firestore maps', () {
      final legacyMap = <String, dynamic>{
        'id': 'yogurt',
        'name': 'Greek Yogurt',
        'category': 'Dairy',
        'macros': {'calories': 97, 'protein': 9, 'carbs': 3.9, 'fats': 5},
        'micros': {'fiber': 0, 'sugar': 4, 'sodium': 36, 'potassium': 141},
        'vitamins': {
          'vitaminA': 90,
          'vitaminB': 0.6,
          'vitaminC': 0,
          'vitaminD': 0.1,
          'vitaminE': 0.03,
        },
        'minerals': {'calcium': 110, 'iron': 0.07, 'magnesium': 11, 'zinc': 0.52},
        'imageUrl': '',
        'dietaryTags': ['vegetarian'],
      };

      final item = FoodItem.fromAnyJson(legacyMap);

      expect(item.category, FoodCategory.dairy);
      expect(item.categoryName, 'Dairy');
      expect(item.caloriesPer100g, 97);
      expect(item.proteinPer100g, 9);
      expect(item.tags, ['vegetarian']);
      expect(item.microsPer100g?.sugarGrams, 4);
      expect(item.microsPer100g?.potassiumMg, 141);
      expect(item.microsPer100g?.calciumMg, 110);
      expect(item.microsPer100g?.vitaminDMcg, 0.1);
      expect(item.microsPer100g?.vitaminAMcg, 90);
      expect(item.microsPer100g?.magnesiumMg, 11);
      expect(item.microsPer100g?.zincMg, 0.52);
    });

    test('FoodCategoryX.fromName is case-insensitive with a generic fallback', () {
      expect(FoodCategoryX.fromName(' VEGETABLES '), FoodCategory.vegetables);
      expect(FoodCategoryX.fromName('ready-meal'), FoodCategory.snacks);
      expect(FoodCategoryX.fromName('Custom'), FoodCategory.custom);
    });
  });
}
