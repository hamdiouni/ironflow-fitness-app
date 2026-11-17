import 'package:hive/hive.dart';
import '../../../../core/utils/hive_json_utils.dart';
import '../../../../core/utils/hive_manager.dart';
import '../models/food_item_full_model.dart';

/// Hive data source for storing and retrieving FoodItemFull entities
class HiveFoodItemFullDataSource {
  static const String boxName = HiveManager.foodItemsFullBox;

  Future<Box<Map>> get _box => HiveManager.ensureFoodItemsFullBox();

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
        .map((json) => FoodItemFullModel.fromJson(deepCastMap(json)))
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
    return FoodItemFullModel.fromJson(deepCastMap(json));
  }

  /// Search food items by name
  Future<List<FoodItemFullModel>> searchFoodItems(String query) async {
    final box = await _box;
    final lowerQuery = query.toLowerCase();
    final foodItems = box.values
        .map((json) => FoodItemFullModel.fromJson(deepCastMap(json)))
        .where((item) => item.name.toLowerCase().contains(lowerQuery))
        .toList();

    foodItems.sort((a, b) => a.name.compareTo(b.name));
    return foodItems;
  }

  /// Filter food items by category
  Future<List<FoodItemFullModel>> filterByCategory(String category) async {
    final box = await _box;
    final foodItems = box.values
        .map((json) => FoodItemFullModel.fromJson(deepCastMap(json)))
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
        .map((json) => FoodItemFullModel.fromJson(deepCastMap(json)))
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
