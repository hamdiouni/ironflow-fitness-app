import 'package:hive/hive.dart';
import '../../../../core/utils/hive_manager.dart';
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

/// Hive-based local data source for caching foods
/// Provides persistent local storage for food database with cache invalidation
class HiveFoodDataSource {
  static const String _foodsKey = 'foods_cache';
  static const String _customFoodsKey = 'custom_foods';
  static const String _cacheTimestampKey = 'foods_cache_timestamp';
  static const String _cacheVersionKey = 'foods_cache_version';
  static const int _currentCacheVersion = 1;

  /// Get the foods box from Hive
  Box get _box => HiveManager.getFoodsBox();

  /// Cache all foods locally
  /// Stores foods with timestamp for cache invalidation
  Future<void> cacheFoods(List<FoodItemFullModel> foods) async {
    try {
      // Store foods as JSON list
      final foodsJson = foods.map((f) => f.toJson()).toList();
      await _box.put(_foodsKey, foodsJson);
      
      // Store cache timestamp
      await _box.put(_cacheTimestampKey, DateTime.now().toIso8601String());
      
      // Store cache version
      await _box.put(_cacheVersionKey, _currentCacheVersion);
    } catch (e) {
      throw Exception('Failed to cache foods: $e');
    }
  }

  /// Save a custom food created by the user
  Future<void> saveCustomFood(FoodItemFullModel food) async {
    try {
      // Get existing custom foods
      final customFoods = await getCustomFoods();
      
      // Add new food
      customFoods.add(food);
      
      // Save back to Hive
      final foodsJson = customFoods.map((f) => f.toJson()).toList();
      await _box.put(_customFoodsKey, foodsJson);
    } catch (e) {
      throw Exception('Failed to save custom food: $e');
    }
  }

  /// Get all custom foods created by the user
  Future<List<FoodItemFullModel>> getCustomFoods() async {
    try {
      final foodsJson = _box.get(_customFoodsKey) as List<dynamic>?;
      if (foodsJson == null || foodsJson.isEmpty) {
        return [];
      }

      return foodsJson
          .map((json) => FoodItemFullModel.fromJson(_deepCast(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Delete a custom food by ID
  Future<void> deleteCustomFood(String id) async {
    try {
      final customFoods = await getCustomFoods();
      customFoods.removeWhere((food) => food.id == id);
      
      final foodsJson = customFoods.map((f) => f.toJson()).toList();
      await _box.put(_customFoodsKey, foodsJson);
    } catch (e) {
      throw Exception('Failed to delete custom food: $e');
    }
  }

  /// Get all cached foods (including custom foods)
  /// Returns empty list if cache is empty
  Future<List<FoodItemFullModel>> getCachedFoods() async {
    try {
      final foodsJson = _box.get(_foodsKey) as List<dynamic>?;
      final cachedFoods = foodsJson == null || foodsJson.isEmpty
          ? <FoodItemFullModel>[]
          : foodsJson
              .map((json) => FoodItemFullModel.fromJson(_deepCast(json)))
              .toList();

      // Add custom foods
      final customFoods = await getCustomFoods();
      return [...cachedFoods, ...customFoods];
    } catch (e) {
      throw Exception('Failed to retrieve cached foods: $e');
    }
  }

  /// Get a single cached food by ID
  Future<FoodItemFullModel?> getCachedFoodById(String id) async {
    try {
      final foods = await getCachedFoods();
      return foods.firstWhere(
        (food) => food.id == id,
        orElse: () => throw Exception('Food not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Search cached foods by name (case-insensitive)
  Future<List<FoodItemFullModel>> searchCachedFoods(String query) async {
    try {
      if (query.isEmpty) {
        return getCachedFoods();
      }

      final foods = await getCachedFoods();
      final lowerQuery = query.toLowerCase();
      return foods
          .where((food) => food.name.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      throw Exception('Failed to search cached foods: $e');
    }
  }

  /// Filter cached foods by category
  Future<List<FoodItemFullModel>> filterCachedByCategory(
    String category,
  ) async {
    try {
      final foods = await getCachedFoods();
      return foods.where((food) => food.category == category).toList();
    } catch (e) {
      throw Exception('Failed to filter cached foods by category: $e');
    }
  }

  /// Filter cached foods by dietary tags
  Future<List<FoodItemFullModel>> filterCachedByTags(
    List<String> tags,
  ) async {
    try {
      if (tags.isEmpty) {
        return getCachedFoods();
      }

      final foods = await getCachedFoods();
      return foods
          .where((food) =>
              tags.every((tag) => food.dietaryTags.contains(tag)))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter cached foods by tags: $e');
    }
  }

  /// Check if cache exists and is valid
  /// Returns true if cache has foods
  Future<bool> isCacheValid() async {
    try {
      final foodsJson = _box.get(_foodsKey) as List<dynamic>?;
      final version = _box.get(_cacheVersionKey) as int?;
      
      return foodsJson != null && 
             foodsJson.isNotEmpty && 
             version == _currentCacheVersion;
    } catch (e) {
      return false;
    }
  }

  /// Get cache timestamp
  /// Returns null if cache doesn't exist
  Future<DateTime?> getCacheTimestamp() async {
    try {
      final timestamp = _box.get(_cacheTimestampKey) as String?;
      if (timestamp == null) return null;
      return DateTime.parse(timestamp);
    } catch (e) {
      return null;
    }
  }

  /// Invalidate cache by clearing all food data
  /// Keeps timestamp for reference
  Future<void> invalidateCache() async {
    try {
      await _box.delete(_foodsKey);
      await _box.delete(_cacheVersionKey);
    } catch (e) {
      throw Exception('Failed to invalidate cache: $e');
    }
  }

  /// Clear all cached foods and metadata
  Future<void> clearCache() async {
    try {
      await _box.clear();
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  /// Get count of cached foods
  Future<int> getCachedFoodCount() async {
    try {
      final foods = await getCachedFoods();
      return foods.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get all unique categories from cached foods
  Future<List<String>> getCachedCategories() async {
    try {
      final foods = await getCachedFoods();
      final categories = <String>{};
      for (final food in foods) {
        categories.add(food.category);
      }
      return categories.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get cached categories: $e');
    }
  }

  /// Get all unique dietary tags from cached foods
  Future<List<String>> getCachedDietaryTags() async {
    try {
      final foods = await getCachedFoods();
      final tags = <String>{};
      for (final food in foods) {
        tags.addAll(food.dietaryTags);
      }
      return tags.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get cached dietary tags: $e');
    }
  }

  /// Get foods by category from cache
  Future<List<FoodItemFullModel>> getCachedFoodsByCategory(
    String category,
  ) async {
    try {
      final foods = await getCachedFoods();
      return foods
          .where((food) => food.category == category)
          .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      throw Exception('Failed to get foods by category: $e');
    }
  }

  /// Get foods by dietary tag from cache
  Future<List<FoodItemFullModel>> getCachedFoodsByTag(String tag) async {
    try {
      final foods = await getCachedFoods();
      return foods
          .where((food) => food.dietaryTags.contains(tag))
          .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      throw Exception('Failed to get foods by tag: $e');
    }
  }
}
