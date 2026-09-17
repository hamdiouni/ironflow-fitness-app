import 'package:cloud_firestore/cloud_firestore.dart';
import '../food_database.dart';
import '../../domain/entities/food_item_full.dart';
import 'firestore_food_datasource.dart';

/// Convert FoodItem to FoodItemFull with estimated nutritional values.
/// Uses reasonable defaults for micros, vitamins, and minerals based on food category.
FoodItemFull _convertFoodItemToFull(dynamic foodItem) {
  // Extract values from FoodItem
  final id = foodItem.id as String;
  final name = foodItem.name as String;
  final category = foodItem.category.toString().split('.').last;
  final calories = (foodItem.caloriesPer100g as num).toDouble();
  final protein = (foodItem.proteinPer100g as num).toDouble();
  final carbs = (foodItem.carbsPer100g as num).toDouble();
  final fats = (foodItem.fatPer100g as num).toDouble();
  final imageUrl = foodItem.imageUrl as String;
  final tags = List<String>.from(foodItem.tags as List<dynamic>);

  // Estimate micros based on macros and category
  double fiber = 0;
  double sugar = 0;
  double sodium = 0;
  double potassium = 0;

  // Estimate based on category
  if (category.contains('protein')) {
    fiber = 0;
    sugar = 0;
    sodium = 75;
    potassium = 350;
  } else if (category.contains('carbs')) {
    fiber = 3;
    sugar = 5;
    sodium = 10;
    potassium = 400;
  } else if (category.contains('vegetables')) {
    fiber = 2.5;
    sugar = 2;
    sodium = 50;
    potassium = 300;
  } else if (category.contains('fruits')) {
    fiber = 2;
    sugar = 12;
    sodium = 5;
    potassium = 250;
  } else if (category.contains('dairy')) {
    fiber = 0;
    sugar = 5;
    sodium = 100;
    potassium = 150;
  } else if (category.contains('fats')) {
    fiber = 0;
    sugar = 0;
    sodium = 5;
    potassium = 10;
  } else if (category.contains('snacks')) {
    fiber = 1;
    sugar = 8;
    sodium = 200;
    potassium = 100;
  } else if (category.contains('beverages')) {
    fiber = 0;
    sugar = 10;
    sodium = 20;
    potassium = 50;
  }

  // Estimate vitamins based on category
  double vitaminA = 0;
  double vitaminB = 0;
  double vitaminC = 0;
  double vitaminD = 0;
  double vitaminE = 0;

  if (category.contains('protein')) {
    vitaminA = 0;
    vitaminB = 0.8;
    vitaminC = 0;
    vitaminD = 0.5;
    vitaminE = 0.3;
  } else if (category.contains('vegetables')) {
    vitaminA = 500;
    vitaminB = 0.1;
    vitaminC = 20;
    vitaminD = 0;
    vitaminE = 1;
  } else if (category.contains('fruits')) {
    vitaminA = 50;
    vitaminB = 0.05;
    vitaminC = 30;
    vitaminD = 0;
    vitaminE = 0.5;
  } else if (category.contains('dairy')) {
    vitaminA = 50;
    vitaminB = 0.3;
    vitaminC = 0;
    vitaminD = 1;
    vitaminE = 0.1;
  }

  // Estimate minerals based on category
  double calcium = 0;
  double iron = 0;
  double magnesium = 0;
  double zinc = 0;

  if (category.contains('protein')) {
    calcium = 10;
    iron = 2;
    magnesium = 25;
    zinc = 5;
  } else if (category.contains('dairy')) {
    calcium = 300;
    iron = 0.1;
    magnesium = 15;
    zinc = 0.5;
  } else if (category.contains('vegetables')) {
    calcium = 50;
    iron = 1;
    magnesium = 30;
    zinc = 0.3;
  } else if (category.contains('fruits')) {
    calcium = 20;
    iron = 0.5;
    magnesium = 15;
    zinc = 0.1;
  }

  return FoodItemFull(
    id: id,
    name: name,
    category: category,
    macros: MacrosPer100g(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
    ),
    micros: MicrosPer100g(
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      potassium: potassium,
    ),
    vitamins: VitaminsPer100g(
      vitaminA: vitaminA,
      vitaminB: vitaminB,
      vitaminC: vitaminC,
      vitaminD: vitaminD,
      vitaminE: vitaminE,
    ),
    minerals: MineralsPer100g(
      calcium: calcium,
      iron: iron,
      magnesium: magnesium,
      zinc: zinc,
    ),
    imageUrl: imageUrl,
    dietaryTags: tags,
  );
}

/// Script to upload all foods from the local database to Firestore.
/// 
/// This should be run once during app initialization or via a manual trigger.
/// Usage:
/// ```dart
/// final firestore = FirebaseFirestore.instance;
/// await uploadAllFoodsToFirestore(firestore);
/// ```
Future<void> uploadAllFoodsToFirestore(FirebaseFirestore firestore) async {
  try {
    print('Starting food upload to Firestore...');
    print('Total foods to upload: ${FoodDatabase.foodCount}');

    // Convert FoodItem to FoodItemFull
    final fullFoods = FoodDatabase.foods
        .map((food) => _convertFoodItemToFull(food))
        .toList();

    final datasource = FirestoreFoodDatasource(firestore);
    
    // Upload all foods
    await datasource.uploadFoods(fullFoods);
    
    print('✓ Successfully uploaded ${fullFoods.length} foods to Firestore');
    
    // Verify upload by checking count
    final allFoods = await datasource.getAllFoods();
    print('✓ Verification: ${allFoods.length} foods found in Firestore');
    
    // Print summary by category
    final byCategory = <String, int>{};
    for (final food in allFoods) {
      byCategory[food.category] = (byCategory[food.category] ?? 0) + 1;
    }
    
    print('\nFoods by category:');
    byCategory.forEach((category, count) {
      print('  $category: $count');
    });
    
  } catch (e) {
    print('✗ Error uploading foods: $e');
    rethrow;
  }
}

/// Verify that all foods are properly uploaded to Firestore.
/// Returns true if all foods are present and valid.
Future<bool> verifyFoodsInFirestore(FirebaseFirestore firestore) async {
  try {
    print('Verifying foods in Firestore...');
    
    final datasource = FirestoreFoodDatasource(firestore);
    final firestoreFoods = await datasource.getAllFoods();
    final localFoods = FoodDatabase.foods;
    
    print('Local foods: ${localFoods.length}');
    print('Firestore foods: ${firestoreFoods.length}');
    
    if (firestoreFoods.length != localFoods.length) {
      print('✗ Food count mismatch!');
      return false;
    }
    
    // Check that all local foods are in Firestore
    final firestoreIds = firestoreFoods.map((f) => f.id).toSet();
    final localIds = localFoods.map((f) => f.id).toSet();
    
    final missing = localIds.difference(firestoreIds);
    if (missing.isNotEmpty) {
      print('✗ Missing foods in Firestore: $missing');
      return false;
    }
    
    print('✓ All foods verified successfully!');
    return true;
  } catch (e) {
    print('✗ Error verifying foods: $e');
    return false;
  }
}

/// Delete all foods from Firestore (use with caution!).
Future<void> deleteAllFoodsFromFirestore(FirebaseFirestore firestore) async {
  try {
    print('Deleting all foods from Firestore...');
    
    final batch = firestore.batch();
    final snapshot = await firestore.collection('foods').get();
    
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    print('✓ Successfully deleted ${snapshot.docs.length} foods from Firestore');
  } catch (e) {
    print('✗ Error deleting foods: $e');
    rethrow;
  }
}
