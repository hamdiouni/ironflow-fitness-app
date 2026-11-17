import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';
import '../../domain/entities/food_item.dart';

/// Paginated Firestore food result carrying the cursor document for subsequent pages.
class FoodPageResult {
  const FoodPageResult({
    required this.items,
    required this.lastDocument,
    required this.hasMore,
  });

  final List<FoodItem> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;
}

/// Firestore datasource for food items.
/// Handles uploading and retrieving bounded pages of foods from Firestore.
class FirestoreFoodDatasource {
  FirestoreFoodDatasource(this._firestore);

  final FirebaseFirestore _firestore;

  static const int defaultPageSize = 50;
  static const int maxBatchQueryLimit = 200;

  /// Upload all foods to Firestore.
  ///
  /// IDs are preserved EXACTLY (Phase 2, F-14): `Meal.foodItemId`s
  /// reference these catalog IDs. Duplicate IDs fail loudly.
  Future<void> uploadFoods(List<FoodItem> foods) async {
    final seen = <String>{};
    final duplicates = <String>{};
    for (final food in foods) {
      if (!seen.add(food.id)) duplicates.add(food.id);
    }
    if (duplicates.isNotEmpty) {
      throw StateError(
        'Food catalog contains duplicate IDs $duplicates; '
        'fix the source catalog instead of rewriting IDs on upload.',
      );
    }

    final foodsCollection = _firestore.collection('foods');
    // Firestore batches are capped at 500 operations; chunk at 400.
    for (var start = 0; start < foods.length; start += 400) {
      final batch = _firestore.batch();
      for (final food in foods.skip(start).take(400)) {
        batch.set(foodsCollection.doc(food.id), foodToMap(food));
      }
      await batch.commit();
    }
  }

  /// Fetches a bounded cursor-paginated slice of foods ordered by name.
  Future<FoodPageResult> getFoodsPage({
    int limit = defaultPageSize,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    final safeLimit = limit.clamp(1, maxBatchQueryLimit);
    Query<Map<String, dynamic>> query = _firestore
        .collection('foods')
        .orderBy('name')
        .limit(safeLimit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final items = <FoodItem>[];
    for (final doc in snapshot.docs) {
      final parsed = mapToFoodSafe(doc.data(), doc.id);
      if (parsed != null) items.add(parsed);
    }

    return FoodPageResult(
      items: items,
      lastDocument: snapshot.docs.isEmpty ? null : snapshot.docs.last,
      hasMore: snapshot.docs.length >= safeLimit,
    );
  }

  /// Get bounded foods from Firestore.
  Future<List<FoodItem>> getAllFoods({int limit = maxBatchQueryLimit}) async {
    final safeLimit = limit.clamp(1, maxBatchQueryLimit);
    final snapshot = await _firestore
        .collection('foods')
        .orderBy('name')
        .limit(safeLimit)
        .get();
    return snapshot.docs
        .map((doc) => mapToFoodSafe(doc.data(), doc.id))
        .whereType<FoodItem>()
        .toList();
  }

  /// Get foods by category (bounded).
  Future<List<FoodItem>> getFoodsByCategory(
    String category, {
    int limit = 100,
  }) async {
    final safeLimit = limit.clamp(1, maxBatchQueryLimit);
    final snapshot = await _firestore
        .collection('foods')
        .where('category', isEqualTo: category)
        .limit(safeLimit)
        .get();
    return snapshot.docs
        .map((doc) => mapToFoodSafe(doc.data(), doc.id))
        .whereType<FoodItem>()
        .toList();
  }

  /// Search foods by name prefix (bounded).
  Future<List<FoodItem>> searchFoods(
    String query, {
    int limit = defaultPageSize,
  }) async {
    final safeLimit = limit.clamp(1, maxBatchQueryLimit);
    final snapshot = await _firestore
        .collection('foods')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .limit(safeLimit)
        .get();
    return snapshot.docs
        .map((doc) => mapToFoodSafe(doc.data(), doc.id))
        .whereType<FoodItem>()
        .toList();
  }

  /// Get a single food by ID.
  Future<FoodItem?> getFoodById(String id) async {
    final doc = await _firestore.collection('foods').doc(id).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return mapToFoodSafe(data, id);
  }

  /// Get foods by dietary tags (bounded).
  Future<List<FoodItem>> getFoodsByTags(
    List<String> tags, {
    int limit = 100,
  }) async {
    if (tags.isEmpty) return getAllFoods(limit: limit);
    final safeLimit = limit.clamp(1, maxBatchQueryLimit);
    final snapshot = await _firestore
        .collection('foods')
        .where('dietaryTags', arrayContainsAny: tags)
        .limit(safeLimit)
        .get();
    return snapshot.docs
        .map((doc) => mapToFoodSafe(doc.data(), doc.id))
        .whereType<FoodItem>()
        .toList();
  }

  /// Convert [FoodItem] to Firestore document map.
  Map<String, dynamic> foodToMap(FoodItem food) {
    final micros = food.microsPer100g;
    return {
      'id': food.id,
      'name': food.name,
      'category': food.categoryName,
      'macros': {
        'caloriesPer100g': food.caloriesPer100g,
        'proteinPer100g': food.proteinPer100g,
        'carbsPer100g': food.carbsPer100g,
        'fatsPer100g': food.fatPer100g,
      },
      'micros': {
        'fiberPer100g': micros?.fiberGrams ?? 0.0,
        'sugarPer100g': micros?.sugarGrams ?? 0.0,
        'sodiumPer100g': micros?.sodiumMg ?? 0.0,
        'potassiumPer100g': micros?.potassiumMg ?? 0.0,
      },
      'vitamins': {
        'aPer100g': micros?.vitaminAMcg ?? 0.0,
        'bPer100g': micros?.vitaminBMg ?? 0.0,
        'cPer100g': micros?.vitaminCMg ?? 0.0,
        'dPer100g': micros?.vitaminDMcg ?? 0.0,
        'ePer100g': micros?.vitaminEMg ?? 0.0,
      },
      'minerals': {
        'calciumPer100g': micros?.calciumMg ?? 0.0,
        'ironPer100g': micros?.ironMg ?? 0.0,
        'magnesiumPer100g': micros?.magnesiumMg ?? 0.0,
        'zincPer100g': micros?.zincMg ?? 0.0,
      },
      'imageUrl': food.imageUrl,
      'dietaryTags': food.tags,
      'servingUnit': food.servingUnit,
      'servingWeightGrams': food.servingWeightGrams,
      'servingDescription': food.servingDescription,
      'budgetTier': food.budgetTier.name,
      if (food.fdcId != null) 'fdcId': food.fdcId,
      'source': food.source,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Null-safe parser for Firestore food maps. Returns `null` (and logs) when
  /// essential fields (`name`, numeric macro map/values) are missing or malformed.
  FoodItem? mapToFoodSafe(Map<String, dynamic>? data, String id) {
    if (data == null) return null;
    final nameRaw = data['name'];
    if (nameRaw is! String || nameRaw.trim().isEmpty) {
      AppLogger.debug('⚠️ [FirestoreFood] Skipping food "$id": missing name');
      return null;
    }

    final hasNestedMacros = data['macros'] is Map &&
        ((data['macros'] as Map)['caloriesPer100g'] is num ||
            (data['macros'] as Map)['calories'] is num);
    final hasFlatMacros = data['caloriesPer100g'] is num;
    if (!hasNestedMacros && !hasFlatMacros) {
      AppLogger.debug('⚠️ [FirestoreFood] Skipping food "$id": missing macros');
      return null;
    }

    try {
      return FoodItem.fromAnyJson(<String, dynamic>{...data, 'id': id});
    } catch (e) {
      AppLogger.debug('⚠️ [FirestoreFood] Skipping malformed food "$id": $e');
      return null;
    }
  }

  /// Parses Firestore map using null-safe rules. Throws [FormatException] only
  /// when essential fields are malformed for direct non-null callers.
  FoodItem mapToFood(Map<String, dynamic> data, String id) {
    final parsed = mapToFoodSafe(data, id);
    if (parsed == null) {
      throw FormatException('Malformed Firestore food document "$id"');
    }
    return parsed;
  }
}
