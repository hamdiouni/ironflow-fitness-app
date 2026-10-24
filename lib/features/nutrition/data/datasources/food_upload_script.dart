import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../food_database.dart';
import '../../domain/entities/food_item_conversion.dart';
import 'firestore_food_datasource.dart';

// Conversion now goes through the canonical
// FoodItem.toFoodItemFull() (food_item_conversion.dart, Phase 3,
// F-15). The previous dynamic converter fabricated vitamins and
// minerals from category stereotypes while ignoring the
// catalog's measured micros.

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
    AppLogger.debug('Starting food upload to Firestore...');
    AppLogger.debug('Total foods to upload: ${FoodDatabase.foodCount}');

    // Convert FoodItem to FoodItemFull
    final fullFoods = FoodDatabase.foods
        .map((food) => food.toFoodItemFull())
        .toList();

    final datasource = FirestoreFoodDatasource(firestore);
    
    // Upload all foods
    await datasource.uploadFoods(fullFoods);
    
    AppLogger.debug('✓ Successfully uploaded ${fullFoods.length} foods to Firestore');
    
    // Verify upload by checking count
    final allFoods = await datasource.getAllFoods();
    AppLogger.debug('✓ Verification: ${allFoods.length} foods found in Firestore');
    
    // Print summary by category
    final byCategory = <String, int>{};
    for (final food in allFoods) {
      byCategory[food.category] = (byCategory[food.category] ?? 0) + 1;
    }
    
    AppLogger.debug('\nFoods by category:');
    byCategory.forEach((category, total) {
      AppLogger.debug('  $category: $total');
    });
    
  } catch (e) {
    AppLogger.debug('✗ Error uploading foods: $e');
    rethrow;
  }
}

/// Verify that all foods are properly uploaded to Firestore.
/// Returns true if all foods are present and valid.
Future<bool> verifyFoodsInFirestore(FirebaseFirestore firestore) async {
  try {
    AppLogger.debug('Verifying foods in Firestore...');
    
    final datasource = FirestoreFoodDatasource(firestore);
    final firestoreFoods = await datasource.getAllFoods();
    final localFoods = FoodDatabase.foods;
    
    AppLogger.debug('Local foods: ${localFoods.length}');
    AppLogger.debug('Firestore foods: ${firestoreFoods.length}');
    
    if (firestoreFoods.length != localFoods.length) {
      AppLogger.debug('✗ Food count mismatch!');
      return false;
    }
    
    // Check that all local foods are in Firestore
    final firestoreIds = firestoreFoods.map((f) => f.id).toSet();
    final localIds = localFoods.map((f) => f.id).toSet();
    
    final missing = localIds.difference(firestoreIds);
    if (missing.isNotEmpty) {
      AppLogger.debug('✗ Missing foods in Firestore: $missing');
      return false;
    }
    
    AppLogger.debug('✓ All foods verified successfully!');
    return true;
  } catch (e) {
    AppLogger.debug('✗ Error verifying foods: $e');
    return false;
  }
}

/// Delete all foods from Firestore (use with caution!).
Future<void> deleteAllFoodsFromFirestore(FirebaseFirestore firestore) async {
  try {
    AppLogger.debug('Deleting all foods from Firestore...');
    
    final batch = firestore.batch();
    final snapshot = await firestore.collection('foods').get();
    
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
    AppLogger.debug('✓ Successfully deleted ${snapshot.docs.length} foods from Firestore');
  } catch (e) {
    AppLogger.debug('✗ Error deleting foods: $e');
    rethrow;
  }
}
