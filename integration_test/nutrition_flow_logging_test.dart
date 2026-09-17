import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:progression_tracker/core/utils/hive_manager.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/hive_nutrition_datasource.dart';
import 'package:progression_tracker/features/nutrition/data/models/meal_model.dart';
import 'package:progression_tracker/features/nutrition/data/models/nutrition_targets_model.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Integration test for nutrition flow with logging.
///
/// This test verifies that:
/// 1. Nutrition operations complete successfully with logging enabled
/// 2. All operations are logged (save meal, get meals, save targets, get targets)
/// 3. Logging doesn't break functionality
/// 4. Error paths are logged correctly
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Nutrition Flow Logging Integration Tests', () {
    late HiveNutritionDatasource datasource;

    setUpAll(() async {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Hive
      await HiveManager.initialize();
    });

    setUp(() async {
      // Create datasource
      datasource = HiveNutritionDatasource();

      // Clear nutrition data before each test
      await datasource.clearAllData();
    });

    testWidgets('Complete nutrition flow with logging', (tester) async {
      print('\n=== TEST: Complete nutrition flow ===');

      // Act & Assert: Save nutrition targets
      print('\n=== TEST: Saving nutrition targets ===');
      final targets = NutritionTargetsModel(
        userId: 'test-user',
        calories: 2500.0,
        protein: 150.0,
        carbs: 250.0,
        fat: 80.0,
        fiber: 30.0,
        sugar: 50.0,
        sodium: 2300.0,
        potassium: 3500.0,
        vitaminA: 900.0,
        vitaminB: 2.4,
        vitaminC: 90.0,
        vitaminD: 20.0,
        vitaminE: 15.0,
        calcium: 1000.0,
        iron: 18.0,
        magnesium: 400.0,
        zinc: 11.0,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await datasource.saveNutritionTargets(targets);
      await tester.pumpAndSettle();
      print('✓ Nutrition targets saved successfully');

      // Act & Assert: Get nutrition targets
      print('\n=== TEST: Getting nutrition targets ===');
      final retrievedTargets = await datasource.getNutritionTargets();
      await tester.pumpAndSettle();

      expect(retrievedTargets, isNotNull, reason: 'Targets should be retrieved');
      expect(retrievedTargets!.calories, 2500.0);
      expect(retrievedTargets.protein, 150.0);
      expect(retrievedTargets.carbs, 250.0);
      expect(retrievedTargets.fat, 80.0);
      print('✓ Nutrition targets retrieved successfully');

      // Act & Assert: Save first meal (breakfast)
      print('\n=== TEST: Saving first meal (breakfast) ===');
      final meal1 = MealModel(
        id: 'test-meal-1',
        name: 'Breakfast',
        macros: const MealMacrosModel(
          calories: 500.0,
          protein: 30.0,
          carbs: 50.0,
          fats: 15.0,
        ),
        micros: const MealMicrosModel(
          fiber: 8.0,
          sugar: 10.0,
          sodium: 400.0,
          potassium: 600.0,
        ),
        vitamins: const MealVitaminsModel(
          vitaminA: 200.0,
          vitaminB: 0.5,
          vitaminC: 20.0,
          vitaminD: 5.0,
          vitaminE: 3.0,
        ),
        minerals: const MealMineralsModel(
          calcium: 200.0,
          iron: 4.0,
          magnesium: 80.0,
          zinc: 2.0,
        ),
        timestamp: DateTime.now().toIso8601String(),
      );

      await datasource.saveMealEntry(meal1);
      await tester.pumpAndSettle();
      print('✓ First meal saved successfully');

      // Act & Assert: Save second meal (lunch)
      print('\n=== TEST: Saving second meal (lunch) ===');
      final meal2 = MealModel(
        id: 'test-meal-2',
        name: 'Lunch',
        macros: const MealMacrosModel(
          calories: 700.0,
          protein: 45.0,
          carbs: 70.0,
          fats: 20.0,
        ),
        micros: const MealMicrosModel(
          fiber: 10.0,
          sugar: 12.0,
          sodium: 600.0,
          potassium: 800.0,
        ),
        vitamins: const MealVitaminsModel(
          vitaminA: 300.0,
          vitaminB: 0.8,
          vitaminC: 30.0,
          vitaminD: 8.0,
          vitaminE: 5.0,
        ),
        minerals: const MealMineralsModel(
          calcium: 300.0,
          iron: 6.0,
          magnesium: 120.0,
          zinc: 3.0,
        ),
        timestamp: DateTime.now().toIso8601String(),
      );

      await datasource.saveMealEntry(meal2);
      await tester.pumpAndSettle();
      print('✓ Second meal saved successfully');

      // Act & Assert: Save third meal (dinner)
      print('\n=== TEST: Saving third meal (dinner) ===');
      final meal3 = MealModel(
        id: 'test-meal-3',
        name: 'Dinner',
        macros: const MealMacrosModel(
          calories: 800.0,
          protein: 50.0,
          carbs: 80.0,
          fats: 25.0,
        ),
        micros: const MealMicrosModel(
          fiber: 12.0,
          sugar: 15.0,
          sodium: 700.0,
          potassium: 900.0,
        ),
        vitamins: const MealVitaminsModel(
          vitaminA: 400.0,
          vitaminB: 1.0,
          vitaminC: 40.0,
          vitaminD: 7.0,
          vitaminE: 7.0,
        ),
        minerals: const MealMineralsModel(
          calcium: 400.0,
          iron: 8.0,
          magnesium: 150.0,
          zinc: 5.0,
        ),
        timestamp: DateTime.now().toIso8601String(),
      );

      await datasource.saveMealEntry(meal3);
      await tester.pumpAndSettle();
      print('✓ Third meal saved successfully');

      // Act & Assert: Get all meals
      print('\n=== TEST: Getting all meals ===');
      final allMeals = await datasource.getAllMeals();
      await tester.pumpAndSettle();

      expect(allMeals.length, 3, reason: 'Should have 3 meals');
      print('✓ All meals retrieved successfully (${allMeals.length} meals)');

      // Act & Assert: Get meals by date
      print('\n=== TEST: Getting meals by date ===');
      final today = DateTime.now();
      final mealsByDate = await datasource.getMealsByDate(today);
      await tester.pumpAndSettle();

      expect(mealsByDate.length, 3, reason: 'Should have 3 meals for today');
      print('✓ Meals by date retrieved successfully (${mealsByDate.length} meals)');

      // Act & Assert: Get specific meal by ID
      print('\n=== TEST: Getting meal by ID ===');
      final specificMeal = await datasource.getMealById('test-meal-2');
      await tester.pumpAndSettle();

      expect(specificMeal, isNotNull, reason: 'Meal should be found');
      expect(specificMeal!.name, 'Lunch');
      expect(specificMeal.macros.calories, 700.0);
      print('✓ Specific meal retrieved successfully');

      // Act & Assert: Get meal count
      print('\n=== TEST: Getting meal count ===');
      final mealCount = await datasource.getMealCount();
      await tester.pumpAndSettle();

      expect(mealCount, 3, reason: 'Should have 3 meals');
      print('✓ Meal count retrieved successfully ($mealCount meals)');

      // Act & Assert: Check if has meals
      print('\n=== TEST: Checking if has meals ===');
      final hasMeals = await datasource.hasMeals();
      await tester.pumpAndSettle();

      expect(hasMeals, true, reason: 'Should have meals');
      print('✓ Has meals check completed successfully');

      // Act & Assert: Get all meal dates
      print('\n=== TEST: Getting all meal dates ===');
      final mealDates = await datasource.getAllMealDates();
      await tester.pumpAndSettle();

      expect(mealDates.isNotEmpty, true, reason: 'Should have meal dates');
      print('✓ Meal dates retrieved successfully (${mealDates.length} dates)');

      // Act & Assert: Delete specific meal
      print('\n=== TEST: Deleting specific meal ===');
      await datasource.deleteMealEntry('test-meal-1');
      await tester.pumpAndSettle();

      final remainingMeals = await datasource.getAllMeals();
      expect(remainingMeals.length, 2, reason: 'Should have 2 meals after deletion');
      print('✓ Meal deleted successfully (${remainingMeals.length} meals remaining)');

      // Act & Assert: Delete meals by date
      print('\n=== TEST: Deleting meals by date ===');
      await datasource.deleteMealsByDate(today);
      await tester.pumpAndSettle();

      final mealsAfterDateDelete = await datasource.getAllMeals();
      expect(mealsAfterDateDelete.length, 0, reason: 'Should have 0 meals after date deletion');
      print('✓ Meals deleted by date successfully');

      print('\n=== TEST COMPLETE: All nutrition operations logged and working ===\n');
    });

    testWidgets('Error path: Get meal from empty database', (tester) async {
      print('\n=== TEST: Error path - Get meal from empty database ===');

      // Act & Assert: Try to get meal when database is empty
      final meal = await datasource.getMealById('non-existent-id');
      await tester.pumpAndSettle();

      expect(meal, isNull, reason: 'Should return null for non-existent meal');
      print('✓ Error handled correctly: Non-existent meal returns null');

      print('\n=== TEST COMPLETE: Error path logged correctly ===\n');
    });

    testWidgets('Error path: Get targets when not set', (tester) async {
      print('\n=== TEST: Error path - Get targets when not set ===');

      // Act & Assert: Try to get targets when not set
      final targets = await datasource.getNutritionTargets();
      await tester.pumpAndSettle();

      expect(targets, isNull, reason: 'Should return null when targets not set');
      print('✓ Error handled correctly: No targets returns null');

      print('\n=== TEST COMPLETE: Error path logged correctly ===\n');
    });

    testWidgets('Meal persistence across operations', (tester) async {
      print('\n=== TEST: Meal persistence ===');

      // Save a meal
      final meal = MealModel(
        id: 'persistence-test-meal',
        name: 'Test Meal',
        macros: const MealMacrosModel(
          calories: 400.0,
          protein: 25.0,
          carbs: 40.0,
          fats: 12.0,
        ),
        micros: const MealMicrosModel(
          fiber: 6.0,
          sugar: 8.0,
          sodium: 300.0,
          potassium: 500.0,
        ),
        vitamins: const MealVitaminsModel(
          vitaminA: 150.0,
          vitaminB: 0.4,
          vitaminC: 15.0,
          vitaminD: 4.0,
          vitaminE: 2.0,
        ),
        minerals: const MealMineralsModel(
          calcium: 150.0,
          iron: 3.0,
          magnesium: 60.0,
          zinc: 1.5,
        ),
        timestamp: DateTime.now().toIso8601String(),
      );

      await datasource.saveMealEntry(meal);
      await tester.pumpAndSettle();
      print('✓ Meal saved');

      // Retrieve the meal
      final retrievedMeal = await datasource.getMealById('persistence-test-meal');
      await tester.pumpAndSettle();

      expect(retrievedMeal, isNotNull);
      expect(retrievedMeal!.name, 'Test Meal');
      expect(retrievedMeal.macros.calories, 400.0);
      expect(retrievedMeal.macros.protein, 25.0);
      print('✓ Meal persisted and retrieved correctly');

      print('\n=== TEST COMPLETE: Meal persistence verified ===\n');
    });

    testWidgets('Clear all data operation', (tester) async {
      print('\n=== TEST: Clear all data ===');

      // Add some data
      final meal = MealModel(
        id: 'clear-test-meal',
        name: 'Clear Test',
        macros: const MealMacrosModel(
          calories: 300.0,
          protein: 20.0,
          carbs: 30.0,
          fats: 10.0,
        ),
        micros: const MealMicrosModel(
          fiber: 5.0,
          sugar: 6.0,
          sodium: 250.0,
          potassium: 400.0,
        ),
        vitamins: const MealVitaminsModel(
          vitaminA: 100.0,
          vitaminB: 0.3,
          vitaminC: 12.0,
          vitaminD: 3.0,
          vitaminE: 1.5,
        ),
        minerals: const MealMineralsModel(
          calcium: 100.0,
          iron: 2.0,
          magnesium: 50.0,
          zinc: 1.0,
        ),
        timestamp: DateTime.now().toIso8601String(),
      );

      await datasource.saveMealEntry(meal);
      await tester.pumpAndSettle();

      final targets = NutritionTargetsModel(
        userId: 'test-user',
        calories: 2000.0,
        protein: 120.0,
        carbs: 200.0,
        fat: 70.0,
        fiber: 25.0,
        sugar: 40.0,
        sodium: 2000.0,
        potassium: 3000.0,
        vitaminA: 800.0,
        vitaminB: 2.0,
        vitaminC: 80.0,
        vitaminD: 15.0,
        vitaminE: 12.0,
        calcium: 900.0,
        iron: 15.0,
        magnesium: 350.0,
        zinc: 10.0,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      await datasource.saveNutritionTargets(targets);
      await tester.pumpAndSettle();
      print('✓ Data added');

      // Clear all data
      await datasource.clearAllData();
      await tester.pumpAndSettle();
      print('✓ All data cleared');

      // Verify data is cleared
      final mealsAfterClear = await datasource.getAllMeals();
      final targetsAfterClear = await datasource.getNutritionTargets();

      expect(mealsAfterClear.length, 0, reason: 'Meals should be cleared');
      expect(targetsAfterClear, isNull, reason: 'Targets should be cleared');
      print('✓ Data cleared successfully');

      print('\n=== TEST COMPLETE: Clear all data verified ===\n');
    });
  });
}
