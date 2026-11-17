import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/firestore_food_datasource.dart';
import 'package:progression_tracker/features/nutrition/domain/services/food_catalog.dart';

/// Developer seed utility to upload the bundled food catalog JSON to Firestore.
///
/// Located outside `lib/` under `tool/seed/` (Wave 3.3) so admin scripts are
/// never bundled in shipping client artifacts.
Future<void> uploadAllFoodsToFirestore(FirebaseFirestore firestore) async {
  try {
    await FoodCatalog.ensureLoaded();
    AppLogger.debug('Starting food upload to Firestore...');
    AppLogger.debug('Total foods to upload: ${FoodCatalog.foodCount}');

    final foods = FoodCatalog.foods;
    final datasource = FirestoreFoodDatasource(firestore);
    await datasource.uploadFoods(foods);

    AppLogger.debug('✓ Successfully uploaded ${foods.length} foods to Firestore');

    final allFoods = await datasource.getAllFoods();
    AppLogger.debug('✓ Verification: ${allFoods.length} foods found in Firestore');

    final byCategory = <String, int>{};
    for (final food in allFoods) {
      byCategory[food.categoryName] = (byCategory[food.categoryName] ?? 0) + 1;
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

/// Verifies all local catalog foods are present in Firestore.
Future<bool> verifyFoodsInFirestore(FirebaseFirestore firestore) async {
  try {
    await FoodCatalog.ensureLoaded();
    AppLogger.debug('Verifying foods in Firestore...');

    final datasource = FirestoreFoodDatasource(firestore);
    final firestoreFoods = await datasource.getAllFoods();
    final localFoods = FoodCatalog.foods;

    AppLogger.debug('Local foods: ${localFoods.length}');
    AppLogger.debug('Firestore foods: ${firestoreFoods.length}');

    if (firestoreFoods.length != localFoods.length) {
      AppLogger.debug('✗ Food count mismatch!');
      return false;
    }

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

/// Deletes all foods from Firestore (admin script only).
Future<void> deleteAllFoodsFromFirestore(FirebaseFirestore firestore) async {
  try {
    AppLogger.debug('Deleting all foods from Firestore...');
    final batch = firestore.batch();
    final snapshot = await firestore.collection('foods').get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    AppLogger.debug(
      '✓ Successfully deleted ${snapshot.docs.length} foods from Firestore',
    );
  } catch (e) {
    AppLogger.debug('✗ Error deleting foods: $e');
    rethrow;
  }
}
