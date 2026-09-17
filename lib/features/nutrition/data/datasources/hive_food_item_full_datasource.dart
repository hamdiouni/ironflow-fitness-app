import 'package:hive/hive.dart';
import '../models/food_item_full_model.dart';

/// Recursively casts a [Map<dynamic, dynamic>] (as returned by Hive) to
/// [Map<String, dynamic>] so that json_serializable can deserialize it.
Map<String, dynamic> _deepCast(Map<dynamic, dynamic> map) {
  return map.map((key, value) {
    if (value is Map) {
      return MapEntry(key.toString(), _deepCast(value));
    } else if (value is List) {
      return MapEntry(key.toString(), _deepCastList(value));
    }
    return MapEntry(key.toString(), value);
  });
}

List<dynamic> _deepCastList(List<dynamic> list) {
  return list.map((item) {
    if (item is Map) return _deepCast(item);
    if (item is List) return _deepCastList(item);
    return item;
  }).toList();
}

/// Hive data source for storing and retrieving FoodItemFull entities
class HiveFoodItemFullDataSource {
  static const String boxName = 'food_items_full';

  Future<Box<Map>> get _box async => await Hive.openBox<Map>(boxName);

  /// Save a food item to local storage
  Future<void> saveFoodItem(FoodItemFullModel foodItem) async {
    final box = await _box;
    await box.put(foodItem.id, foodItem.toJson());
  }

  /// Save multiple food items to local storage
  Future<void> saveFoodItems(List<FoodItemFullModel> foodItems) async {
    final box = await _box;
    for (final foodItem in foodItems) {
      await box.put(foodItem.id, foodItem.toJson());
    }
  }

  /// Get all food items from local storage
  Future<List<FoodItemFullModel>> getAllFoodItems() async {
    final box = await _box;
    final foodItems = box.values
        .map((json) => FoodItemFullModel.fromJson(_deepCast(json)))
        .toList();

    // Sort by name
    foodItems.sort((a, b) => a.name.compareTo(b.name));
    return foodItems;
  }

  /// Get a food item by ID
  Future<FoodItemFullModel?> getFoodItemById(String id) async {
    final box = await _box;
    final json = box.get(id);
    if (json == null) return null;
    return FoodItemFullModel.fromJson(_deepCast(json));
  }

  /// Search food items by name
  Future<List<FoodItemFullModel>> searchFoodItems(String query) async {
    final box = await _box;
    final lowerQuery = query.toLowerCase();
    final foodItems = box.values
        .map((json) => FoodItemFullModel.fromJson(_deepCast(json)))
        .where((item) => item.name.toLowerCase().contains(lowerQuery))
        .toList();

    foodItems.sort((a, b) => a.name.compareTo(b.name));
    return foodItems;
  }

  /// Filter food items by category
  Future<List<FoodItemFullModel>> filterByCategory(String category) async {
    final box = await _box;
    final foodItems = box.values
        .map((json) => FoodItemFullModel.fromJson(_deepCast(json)))
        .where((item) => item.category == category)
        .toList();

    foodItems.sort((a, b) => a.name.compareTo(b.name));
    return foodItems;
  }

  /// Filter food items by dietary tags
  Future<List<FoodItemFullModel>> filterByDietaryTags(
    List<String> tags,
  ) async {
    final box = await _box;
    final foodItems = box.values
        .map((json) => FoodItemFullModel.fromJson(_deepCast(json)))
        .where((item) => tags.every((tag) => item.dietaryTags.contains(tag)))
        .toList();

    foodItems.sort((a, b) => a.name.compareTo(b.name));
    return foodItems;
  }

  /// Delete a food item from local storage
  Future<void> deleteFoodItem(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  /// Clear all food items from local storage
  Future<void> clearAllFoodItems() async {
    final box = await _box;
    await box.clear();
  }

  /// Get count of food items in local storage
  Future<int> getFoodItemCount() async {
    final box = await _box;
    return box.length;
  }
}
