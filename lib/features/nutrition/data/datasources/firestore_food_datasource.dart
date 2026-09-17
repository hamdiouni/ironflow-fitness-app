import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/food_item_full.dart';

/// Firestore datasource for food items.
/// Handles uploading and retrieving foods from Firestore.
class FirestoreFoodDatasource {
  final FirebaseFirestore _firestore;

  FirestoreFoodDatasource(this._firestore);

  /// Upload all foods to Firestore.
  /// This is typically called once during app initialization or via admin script.
  /// Handles duplicate IDs by appending a counter to make them unique.
  Future<void> uploadFoods(List<FoodItemFull> foods) async {
    final batch = _firestore.batch();
    final foodsCollection = _firestore.collection('foods');
    final idCounts = <String, int>{};

    for (final food in foods) {
      // Handle duplicate IDs by appending a counter
      String uniqueId = food.id;
      if (idCounts.containsKey(food.id)) {
        idCounts[food.id] = idCounts[food.id]! + 1;
        uniqueId = '${food.id}_${idCounts[food.id]}';
      } else {
        idCounts[food.id] = 0;
      }

      final docRef = foodsCollection.doc(uniqueId);
      final data = foodToMap(food);
      // Update the ID in the data to match the unique ID
      data['id'] = uniqueId;
      batch.set(docRef, data);
    }

    await batch.commit();
  }

  /// Get all foods from Firestore.
  Future<List<FoodItemFull>> getAllFoods() async {
    final snapshot = await _firestore.collection('foods').get();
    return snapshot.docs
        .map((doc) => mapToFood(doc.data(), doc.id))
        .toList();
  }

  /// Get foods by category.
  Future<List<FoodItemFull>> getFoodsByCategory(String category) async {
    final snapshot = await _firestore
        .collection('foods')
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs
        .map((doc) => mapToFood(doc.data(), doc.id))
        .toList();
  }

  /// Search foods by name.
  Future<List<FoodItemFull>> searchFoods(String query) async {
    final snapshot = await _firestore
        .collection('foods')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get();
    return snapshot.docs
        .map((doc) => mapToFood(doc.data(), doc.id))
        .toList();
  }

  /// Get a single food by ID.
  Future<FoodItemFull?> getFoodById(String id) async {
    final doc = await _firestore.collection('foods').doc(id).get();
    if (!doc.exists) return null;
    return mapToFood(doc.data()!, id);
  }

  /// Get foods by dietary tags.
  Future<List<FoodItemFull>> getFoodsByTags(List<String> tags) async {
    if (tags.isEmpty) return getAllFoods();
    
    final snapshot = await _firestore
        .collection('foods')
        .where('dietaryTags', arrayContainsAny: tags)
        .get();
    return snapshot.docs
        .map((doc) => mapToFood(doc.data(), doc.id))
        .toList();
  }

  /// Convert FoodItemFull to Firestore map.
  Map<String, dynamic> foodToMap(FoodItemFull food) {
    return {
      'id': food.id,
      'name': food.name,
      'category': food.category,
      'macros': {
        'caloriesPer100g': food.macros.calories,
        'proteinPer100g': food.macros.protein,
        'carbsPer100g': food.macros.carbs,
        'fatsPer100g': food.macros.fats,
      },
      'micros': {
        'fiberPer100g': food.micros.fiber,
        'sugarPer100g': food.micros.sugar,
        'sodiumPer100g': food.micros.sodium,
        'potassiumPer100g': food.micros.potassium,
      },
      'vitamins': {
        'aPer100g': food.vitamins.vitaminA,
        'bPer100g': food.vitamins.vitaminB,
        'cPer100g': food.vitamins.vitaminC,
        'dPer100g': food.vitamins.vitaminD,
        'ePer100g': food.vitamins.vitaminE,
      },
      'minerals': {
        'calciumPer100g': food.minerals.calcium,
        'ironPer100g': food.minerals.iron,
        'magnesiumPer100g': food.minerals.magnesium,
        'zincPer100g': food.minerals.zinc,
      },
      'imageUrl': food.imageUrl,
      'dietaryTags': food.dietaryTags,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Convert Firestore map to FoodItemFull.
  FoodItemFull mapToFood(Map<String, dynamic> data, String id) {
    final macrosData = data['macros'] as Map<String, dynamic>;
    final microsData = data['micros'] as Map<String, dynamic>;
    final vitaminsData = data['vitamins'] as Map<String, dynamic>;
    final mineralsData = data['minerals'] as Map<String, dynamic>;

    return FoodItemFull(
      id: id,
      name: data['name'] as String,
      category: data['category'] as String,
      macros: MacrosPer100g(
        calories: (macrosData['caloriesPer100g'] as num).toDouble(),
        protein: (macrosData['proteinPer100g'] as num).toDouble(),
        carbs: (macrosData['carbsPer100g'] as num).toDouble(),
        fats: (macrosData['fatsPer100g'] as num).toDouble(),
      ),
      micros: MicrosPer100g(
        fiber: (microsData['fiberPer100g'] as num).toDouble(),
        sugar: (microsData['sugarPer100g'] as num).toDouble(),
        sodium: (microsData['sodiumPer100g'] as num).toDouble(),
        potassium: (microsData['potassiumPer100g'] as num).toDouble(),
      ),
      vitamins: VitaminsPer100g(
        vitaminA: (vitaminsData['aPer100g'] as num).toDouble(),
        vitaminB: (vitaminsData['bPer100g'] as num).toDouble(),
        vitaminC: (vitaminsData['cPer100g'] as num).toDouble(),
        vitaminD: (vitaminsData['dPer100g'] as num).toDouble(),
        vitaminE: (vitaminsData['ePer100g'] as num).toDouble(),
      ),
      minerals: MineralsPer100g(
        calcium: (mineralsData['calciumPer100g'] as num).toDouble(),
        iron: (mineralsData['ironPer100g'] as num).toDouble(),
        magnesium: (mineralsData['magnesiumPer100g'] as num).toDouble(),
        zinc: (mineralsData['zincPer100g'] as num).toDouble(),
      ),
      imageUrl: data['imageUrl'] as String,
      dietaryTags: List<String>.from(data['dietaryTags'] as List<dynamic>? ?? []),
    );
  }
}
