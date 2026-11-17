import 'package:hive/hive.dart';
import '../../../../core/utils/hive_json_utils.dart';
import '../../../../core/utils/hive_manager.dart';
import '../../../../core/utils/record_ownership.dart';
import '../models/food_item_full_model.dart';

/// Hive-based local data source for caching foods and storing user custom foods.
///
/// - Shared catalog cache remains in `foods`.
/// - Personal custom foods live in the dedicated encrypted `custom_foods` box,
///   with one-time adoption from legacy `foods` entries when present.
class HiveFoodDataSource {
  static const String _foodsKey = 'foods_cache';
  static const String _customFoodsKey = 'custom_foods';
  static const String _cacheTimestampKey = 'foods_cache_timestamp';
  static const String _cacheVersionKey = 'foods_cache_version';
  static const int _currentCacheVersion = 1;

  /// Account that owns custom foods read/written by this instance.
  ///
  /// The shared catalog cache remains device-global, but custom foods
  /// are personal records and use `custom_foods_<userId>`. Existing
  /// direct constructions without a user keep using the legacy key.
  final String? userId;

  HiveFoodDataSource({this.userId});

  String? get _scopeUserId =>
      RecordOwnershipRules.storageScope(userId);

  String get _scopedCustomFoodsKey {
    final scopeUserId = _scopeUserId;
    return scopeUserId == null
        ? _customFoodsKey
        : '${_customFoodsKey}_$scopeUserId';
  }

  /// Shared catalog cache box (`foods`).
  Future<Box<dynamic>> get _catalogBox => HiveManager.ensureFoodsBox();

  /// Dedicated encrypted box for user custom foods (`custom_foods`).
  Future<Box<dynamic>> get _customFoodsBox => HiveManager.ensureCustomFoodsBox();

  Future<List<dynamic>?> _customFoodsJson() async {
    final customBox = await _customFoodsBox;
    final scopedKey = _scopedCustomFoodsKey;
    final scopedJson = customBox.get(scopedKey) as List<dynamic>?;
    if (scopedJson != null || scopedKey == _customFoodsKey) {
      if (scopedJson == null && scopedKey == _customFoodsKey) {
        if (Hive.isBoxOpen(HiveManager.foodsBox) ||
            await Hive.boxExists(HiveManager.foodsBox)) {
          final catalogBox = await _catalogBox;
          final legacyGlobal = catalogBox.get(_customFoodsKey) as List<dynamic>?;
          if (legacyGlobal != null) {
            await customBox.put(_customFoodsKey, legacyGlobal);
            await catalogBox.delete(_customFoodsKey);
            return legacyGlobal;
          }
        }
      }
      return scopedJson;
    }

    // One-time adoption of pre-scoping custom foods, only when no
    // account-scoped custom-food list exists yet. Custom food records
    // carry no owner field, so once scoped lists exist the legacy list
    // cannot be safely attributed to the requesting account.
    final hasScopedInCustom = customBox.keys.any(
      (key) => key.toString().startsWith('${_customFoodsKey}_'),
    );
    if (hasScopedInCustom) return null;

    var legacyJson = customBox.get(_customFoodsKey) as List<dynamic>?;
    if (legacyJson != null) {
      await customBox.put(scopedKey, legacyJson);
      await customBox.delete(_customFoodsKey);
      return legacyJson;
    }

    // Fallback adoption from legacy entries stored inside `foods` prior to v4.
    if (Hive.isBoxOpen(HiveManager.foodsBox) ||
        await Hive.boxExists(HiveManager.foodsBox)) {
      final catalogBox = await _catalogBox;
      final scopedLegacy = catalogBox.get(scopedKey) as List<dynamic>?;
      if (scopedLegacy != null) {
        await customBox.put(scopedKey, scopedLegacy);
        await catalogBox.delete(scopedKey);
        return scopedLegacy;
      }

      final hasScopedInFoods = catalogBox.keys.any(
        (key) => key.toString().startsWith('${_customFoodsKey}_'),
      );
      if (hasScopedInFoods) return null;

      legacyJson = catalogBox.get(_customFoodsKey) as List<dynamic>?;
      if (legacyJson != null) {
        await customBox.put(scopedKey, legacyJson);
        await catalogBox.delete(_customFoodsKey);
        return legacyJson;
      }
    }

    return null;
  }

  /// Cache all foods locally
  /// Stores foods with timestamp for cache invalidation
  Future<void> cacheFoods(List<FoodItemFullModel> foods) async {
    try {
      final box = await _catalogBox;
      // Store foods as JSON list
      final foodsJson = foods.map((f) => f.toJson()).toList();
      await box.put(_foodsKey, foodsJson);
      
      // Store cache timestamp
      await box.put(_cacheTimestampKey, DateTime.now().toIso8601String());
      
      // Store cache version
      await box.put(_cacheVersionKey, _currentCacheVersion);
    } catch (e) {
      throw Exception('Failed to cache foods: $e');
    }
  }

  /// Upsert a single food item into the shared foods cache without overwriting
  /// other cached foods.
  Future<void> upsertCachedFood(FoodItemFullModel food) async {
    try {
      final box = await _catalogBox;
      final rawList = box.get(_foodsKey) as List<dynamic>?;
      final currentList = rawList != null
          ? List<dynamic>.from(rawList)
          : <dynamic>[];

      final foodJson = food.toJson();
      final existingIndex = currentList.indexWhere(
        (item) => item is Map && item['id'] == food.id,
      );

      if (existingIndex >= 0) {
        currentList[existingIndex] = foodJson;
      } else {
        currentList.add(foodJson);
      }

      await box.put(_foodsKey, currentList);
      await box.put(_cacheTimestampKey, DateTime.now().toIso8601String());
      await box.put(_cacheVersionKey, _currentCacheVersion);
    } catch (e) {
      throw Exception('Failed to upsert cached food: $e');
    }
  }

  /// Save a custom food created by the user
  Future<void> saveCustomFood(FoodItemFullModel food) async {
    try {
      // Get existing custom foods
      final customFoods = await getCustomFoods();
      
      // Add new food
      customFoods.add(food);
      
      // Save back to dedicated encrypted custom_foods box
      final customBox = await _customFoodsBox;
      final foodsJson = customFoods.map((f) => f.toJson()).toList();
      await customBox.put(_scopedCustomFoodsKey, foodsJson);
    } catch (e) {
      throw Exception('Failed to save custom food: $e');
    }
  }

  /// Get all custom foods created by the user
  Future<List<FoodItemFullModel>> getCustomFoods() async {
    try {
      final foodsJson = await _customFoodsJson();
      if (foodsJson == null || foodsJson.isEmpty) {
        return [];
      }

      return foodsJson
          .map((json) => FoodItemFullModel.fromJson(deepCastMap(json)))
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
      
      final customBox = await _customFoodsBox;
      final foodsJson = customFoods.map((f) => f.toJson()).toList();
      await customBox.put(_scopedCustomFoodsKey, foodsJson);
    } catch (e) {
      throw Exception('Failed to delete custom food: $e');
    }
  }

  /// Get all cached foods (including custom foods)
  /// Returns empty list if cache is empty
  Future<List<FoodItemFullModel>> getCachedFoods() async {
    try {
      final box = await _catalogBox;
      final foodsJson = box.get(_foodsKey) as List<dynamic>?;
      final cachedFoods = foodsJson == null || foodsJson.isEmpty
          ? <FoodItemFullModel>[]
          : foodsJson
              .map((json) => FoodItemFullModel.fromJson(deepCastMap(json)))
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
      final box = await _catalogBox;
      final foodsJson = box.get(_foodsKey) as List<dynamic>?;
      final version = box.get(_cacheVersionKey) as int?;
      
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
      final box = await _catalogBox;
      final timestamp = box.get(_cacheTimestampKey) as String?;
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
      final box = await _catalogBox;
      await box.delete(_foodsKey);
      await box.delete(_cacheVersionKey);
    } catch (e) {
      throw Exception('Failed to invalidate cache: $e');
    }
  }

  /// Clear the shared catalog cache and this instance's custom foods.
  ///
  /// Other accounts' scoped custom-food lists are left untouched.
  Future<void> clearCache() async {
    try {
      final catalogBox = await _catalogBox;
      await catalogBox.delete(_foodsKey);
      await catalogBox.delete(_cacheTimestampKey);
      await catalogBox.delete(_cacheVersionKey);

      final customBox = await _customFoodsBox;
      await customBox.delete(_scopedCustomFoodsKey);
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
