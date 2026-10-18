import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/nutrition/data/food_database.dart';
import 'package:progression_tracker/features/nutrition/data/verified_foods_data.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';

void main() {
  group('Verified Food Dataset (USDA FoodData Central)', () {
    test('contains at least 80 verified fitness foods', () {
      expect(verifiedFoodsList.length, greaterThanOrEqualTo(80));
    });

    test('all verified foods have unique IDs and valid attributes', () {
      final ids = <String>{};
      for (final food in verifiedFoodsList) {
        expect(ids.contains(food.id), isFalse,
            reason: 'Duplicate food ID found: ${food.id}');
        ids.add(food.id);

        expect(food.name.isNotEmpty, isTrue);
        expect(food.servingUnit.isNotEmpty, isTrue);
        expect(food.servingWeightGrams, greaterThan(0));
        expect(food.servingDescription.isNotEmpty, isTrue);
        expect(food.fdcId, isNotNull);
        expect(int.tryParse(food.fdcId!), isNotNull);
        expect(int.parse(food.fdcId!), greaterThan(0));
        expect(food.caloriesPer100g, greaterThanOrEqualTo(0));
        expect(food.proteinPer100g, greaterThanOrEqualTo(0));
        expect(food.carbsPer100g, greaterThanOrEqualTo(0));
        expect(food.fatPer100g, greaterThanOrEqualTo(0));

        final micros = food.microsPer100g;
        if (micros != null) {
          if (micros.fiberGrams != null) {
            expect(micros.fiberGrams!, greaterThanOrEqualTo(0));
          }
          if (micros.sugarGrams != null) {
            expect(micros.sugarGrams!, greaterThanOrEqualTo(0));
          }
          if (micros.sodiumMg != null) {
            expect(micros.sodiumMg!, greaterThanOrEqualTo(0));
          }
          if (micros.potassiumMg != null) {
            expect(micros.potassiumMg!, greaterThanOrEqualTo(0));
          }
          if (micros.calciumMg != null) {
            expect(micros.calciumMg!, greaterThanOrEqualTo(0));
          }
          if (micros.ironMg != null) {
            expect(micros.ironMg!, greaterThanOrEqualTo(0));
          }
          if (micros.vitaminDMcg != null) {
            expect(micros.vitaminDMcg!, greaterThanOrEqualTo(0));
          }
          if (micros.saturatedFatGrams != null) {
            expect(micros.saturatedFatGrams!, greaterThanOrEqualTo(0));
          }
        }
      }
    });

    test('portion scaling methods calculate accurately', () {
      final chicken = verifiedFoodsList.firstWhere((f) => f.id == 'usda_chicken_breast_raw');
      // Chicken breast per 100g: 120 kcal, 22.5g P, 0.0g C, 2.6g F
      final for100g = chicken.macrosForGrams(100.0);
      expect(for100g.calories, closeTo(120.0, 0.01));
      expect(for100g.protein, closeTo(22.5, 0.01));
      expect(for100g.carbs, closeTo(0.0, 0.01));
      expect(for100g.fat, closeTo(2.6, 0.01));

      // Scaling by grams: 200g
      final for200g = chicken.macrosForGrams(200.0);
      expect(for200g.calories, closeTo(240.0, 0.01));
      expect(for200g.protein, closeTo(45.0, 0.01));

      // Serving weight is 172g
      final for1Serving = chicken.macrosForServings(1.0);
      expect(for1Serving.calories, closeTo(120.0 * 1.72, 0.01));
      expect(for1Serving.protein, closeTo(22.5 * 1.72, 0.01));

      // 2 servings should be exactly 2x 1 serving
      final for2Servings = chicken.macrosForServings(2.0);
      expect(for2Servings.calories, closeTo(for1Serving.calories * 2, 0.01));
      expect(for2Servings.protein, closeTo(for1Serving.protein * 2, 0.01));

      // Micros scaling
      final microsFor200g = chicken.microsForGrams(200.0);
      expect(microsFor200g, isNotNull);
      if (chicken.microsPer100g?.potassiumMg != null) {
        expect(microsFor200g!.potassiumMg,
            closeTo(chicken.microsPer100g!.potassiumMg! * 2, 0.01));
      }
    });

    test('JSON serialization round-trip preserves all fields and micros', () {
      final food = verifiedFoodsList.firstWhere((f) => f.id == 'usda_rolled_oats_dry');
      final json = food.toJson();
      final reconstituted = FoodItem.fromJson(json);

      expect(reconstituted.id, equals(food.id));
      expect(reconstituted.name, equals(food.name));
      expect(reconstituted.servingUnit, equals(food.servingUnit));
      expect(reconstituted.servingWeightGrams, equals(food.servingWeightGrams));
      expect(reconstituted.servingDescription, equals(food.servingDescription));
      expect(reconstituted.budgetTier, equals(food.budgetTier));
      expect(reconstituted.fdcId, equals(food.fdcId));
      expect(reconstituted.caloriesPer100g, equals(food.caloriesPer100g));
      expect(reconstituted.proteinPer100g, equals(food.proteinPer100g));
      expect(reconstituted.carbsPer100g, equals(food.carbsPer100g));
      expect(reconstituted.fatPer100g, equals(food.fatPer100g));

      expect(reconstituted.microsPer100g, isNotNull);
      expect(reconstituted.microsPer100g!.fiberGrams,
          equals(food.microsPer100g!.fiberGrams));
      expect(reconstituted.microsPer100g!.ironMg,
          equals(food.microsPer100g!.ironMg));
      expect(reconstituted.microsPer100g!.potassiumMg,
          equals(food.microsPer100g!.potassiumMg));
    });

    test('assets/data/verified_foods.json exists and is valid', () {
      final file = File('assets/data/verified_foods.json');
      expect(file.existsSync(), isTrue);

      final content = file.readAsStringSync();
      final decoded = jsonDecode(content) as List<dynamic>;
      expect(decoded.length, equals(verifiedFoodsList.length));

      final first = FoodItem.fromJson(decoded.first as Map<String, dynamic>);
      expect(first.id, equals(verifiedFoodsList.first.id));
    });
  });

  group('FoodDatabase and Budget Filtering', () {
    test('food database initializes with verified foods first', () {
      final all = FoodDatabase.foods;
      expect(all.length, greaterThanOrEqualTo(verifiedFoodsList.length));
      expect(all.first.id.startsWith('usda_'), isTrue);
    });

    test('filterByBudget filters accurately for all tiers', () {
      final low = FoodDatabase.filterByBudget(BudgetLevel.low);
      expect(low.isNotEmpty, isTrue);
      for (final f in low) {
        expect(f.budgetTier, equals(BudgetLevel.low));
      }

      final medium = FoodDatabase.filterByBudget(BudgetLevel.medium);
      expect(medium.isNotEmpty, isTrue);
      for (final f in medium) {
        expect(f.budgetTier, equals(BudgetLevel.medium));
      }

      final high = FoodDatabase.filterByBudget(BudgetLevel.high);
      expect(high.isNotEmpty, isTrue);
      for (final f in high) {
        expect(f.budgetTier, equals(BudgetLevel.high));
      }
    });

    test('search filters by query and budget tier simultaneously', () {
      final results = FoodDatabase.search(query: 'chicken', budgetTier: BudgetLevel.low);
      expect(results.isNotEmpty, isTrue);
      for (final f in results) {
        expect(f.budgetTier, equals(BudgetLevel.low));
        expect(f.name.toLowerCase().contains('chicken') ||
            f.category.name.toLowerCase().contains('chicken'), isTrue);
      }
    });
  });
}
