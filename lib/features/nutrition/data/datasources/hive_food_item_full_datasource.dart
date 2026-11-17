import 'package:hive/hive.dart';
import '../../../../core/utils/hive_json_utils.dart';
import '../../../../core/utils/hive_manager.dart';
import '../../domain/entities/food_item.dart';

/// Hive data source for storing and retrieving [FoodItem] records inside the
/// encrypted `food_items_full` box (preserving backward compatibility with legacy
/// `FoodItemFullModel` Hive entries via [FoodItem.fromAnyJson]).
class HiveFoodItemFullDataSource {
  static const String boxName = HiveManager.foodItemsFullBox;

  Future<Box<Map>> get _box => HiveManager.ensureFoodItemsFullBox();

  Future<void> saveFoodItem(FoodItem foodItem) async {
    final box = await _box;
    await box.put(foodItem.id, foodItem.toJson());
  }

  Future<void> saveFoodItems(List<FoodItem> foodItems) async {
    final box = await _box;
    for (final foodItem in foodItems) {
      await box.put(foodItem.id, foodItem.toJson());
    }
  }

  Future<List<FoodItem>> getAllFoodItems() async {
    final box = await _box;
    final foodItems = box.values
        .map((json) => FoodItem.fromAnyJson(deepCastMap(json)))
        .toList();
    foodItems.sort((a, b) => a.name.compareTo(b.name));
    return foodItems;
  }

  Future<FoodItem?> getFoodItemById(String id) async {
    final box = await _box;
    final json = box.get(id);
    if (json == null) return null;
    return FoodItem.fromAnyJson(deepCastMap(json));
  }

  Future<List<FoodItem>> searchFoodItems(String query) async {
    final box = await _box;
    final lowerQuery = query.toLowerCase();
    final foodItems = box.values
        .map((json) => FoodItem.fromAnyJson(deepCastMap(json)))
        .where((item) => item.name.toLowerCase().contains(lowerQuery))
        .toList();
    foodItems.sort((a, b) => a.name.compareTo(b.name));
    return foodItems;
  }

  Future<List<FoodItem>> filterByCategory(String category) async {
    final box = await _box;
    final lowerCat = category.toLowerCase();
    final foodItems = box.values
        .map((json) => FoodItem.fromAnyJson(deepCastMap(json)))
        .where(
          (item) =>
              item.categoryName.toLowerCase() == lowerCat ||
              item.category.name == lowerCat,
        )
        .toList();
    foodItems.sort((a, b) => a.name.compareTo(b.name));
    return foodItems;
  }

  Future<List<FoodItem>> filterByDietaryTags(List<String> tags) async {
    final box = await _box;
    final foodItems = box.values
        .map((json) => FoodItem.fromAnyJson(deepCastMap(json)))
        .where((item) => tags.every((tag) => item.tags.contains(tag)))
        .toList();
    foodItems.sort((a, b) => a.name.compareTo(b.name));
    return foodItems;
  }

  Future<void> deleteFoodItem(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<void> clearAllFoodItems() async {
    final box = await _box;
    await box.clear();
  }
}
