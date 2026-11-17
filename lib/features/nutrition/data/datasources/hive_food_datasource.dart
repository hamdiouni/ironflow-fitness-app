import 'package:hive/hive.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/hive_json_utils.dart';
import '../../../../core/utils/hive_manager.dart';
import '../../../../core/utils/record_ownership.dart';
import '../../domain/entities/food_item.dart';

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

  List<FoodItem> _decodeFoodList(List<dynamic>? rawList) {
    if (rawList == null || rawList.isEmpty) return <FoodItem>[];
    final parsed = <FoodItem>[];
    for (final entry in rawList) {
      if (entry is! Map) continue;
      try {
        parsed.add(FoodItem.fromAnyJson(deepCastMap(entry)));
      } catch (e) {
        AppLogger.debug('⚠️ [HiveFood] Skipping corrupt stored food entry: $e');
      }
    }
    return parsed;
  }

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

  /// Cache all foods locally.
  Future<void> cacheFoods(List<FoodItem> foods) async {
    try {
      final box = await _catalogBox;
      final foodsJson = foods.map((f) => f.toJson()).toList();
      await box.put(_foodsKey, foodsJson);
      await box.put(_cacheTimestampKey, DateTime.now().toIso8601String());
      await box.put(_cacheVersionKey, _currentCacheVersion);
    } catch (e) {
      throw Exception('Failed to cache foods: $e');
    }
  }

  /// Upsert a single food item into the shared foods cache without overwriting
  /// other cached foods.
  Future<void> upsertCachedFood(FoodItem food) async {
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

  /// Save a custom food created by the user.
  Future<void> saveCustomFood(FoodItem food) async {
    try {
      final customFoods = await getCustomFoods();
      customFoods.add(food);
      final customBox = await _customFoodsBox;
      final foodsJson = customFoods.map((f) => f.toJson()).toList();
      await customBox.put(_scopedCustomFoodsKey, foodsJson);
    } catch (e) {
      throw Exception('Failed to save custom food: $e');
    }
  }

  /// Get all custom foods created by the user.
  Future<List<FoodItem>> getCustomFoods() async {
    try {
      final foodsJson = await _customFoodsJson();
      return _decodeFoodList(foodsJson);
    } catch (_) {
      return [];
    }
  }

  /// Delete a custom food by ID.
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

  /// Get all cached foods (including custom foods).
  Future<List<FoodItem>> getCachedFoods() async {
    try {
      final box = await _catalogBox;
      final foodsJson = box.get(_foodsKey) as List<dynamic>?;
      final cachedFoods = _decodeFoodList(foodsJson);
      final customFoods = await getCustomFoods();
      return [...cachedFoods, ...customFoods];
    } catch (e) {
      throw Exception('Failed to retrieve cached foods: $e');
    }
  }

  /// Get a single cached food by ID.
  Future<FoodItem?> getCachedFoodById(String id) async {
    try {
      final foods = await getCachedFoods();
      for (final food in foods) {
        if (food.id == id) return food;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Search cached foods by name (case-insensitive).
  Future<List<FoodItem>> searchCachedFoods(String query) async {
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

  /// Filter cached foods by category.
  Future<List<FoodItem>> filterCachedByCategory(String category) async {
    try {
      final foods = await getCachedFoods();
      final lowerCat = category.toLowerCase();
      return foods
          .where(
            (food) =>
                food.categoryName.toLowerCase() == lowerCat ||
                food.category.name == lowerCat,
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to filter cached foods by category: $e');
    }
  }

  /// Filter cached foods by dietary tags.
  Future<List<FoodItem>> filterCachedByTags(List<String> tags) async {
    try {
      if (tags.isEmpty) {
        return getCachedFoods();
      }
      final foods = await getCachedFoods();
      return foods
          .where((food) => tags.every((tag) => food.tags.contains(tag)))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter cached foods by tags: $e');
    }
  }

  /// Check if cache exists and is valid.
  Future<bool> isCacheValid() async {
    try {
      final box = await _catalogBox;
      final foodsJson = box.get(_foodsKey) as List<dynamic>?;
      final version = box.get(_cacheVersionKey) as int?;
      return foodsJson != null &&
          foodsJson.isNotEmpty &&
          version == _currentCacheVersion;
    } catch (_) {
      return false;
    }
  }

  /// Get cache timestamp.
  Future<DateTime?> getCacheTimestamp() async {
    try {
      final box = await _catalogBox;
      final timestamp = box.get(_cacheTimestampKey) as String?;
      if (timestamp == null) return null;
      return DateTime.parse(timestamp);
    } catch (_) {
      return null;
    }
  }

  /// Invalidate cache by clearing all food data.
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

  /// Get count of cached foods.
  Future<int> getCachedFoodCount() async {
    try {
      final foods = await getCachedFoods();
      return foods.length;
    } catch (_) {
      return 0;
    }
  }

  /// Get all unique categories from cached foods.
  Future<List<String>> getCachedCategories() async {
    try {
      final foods = await getCachedFoods();
      final categories = <String>{};
      for (final food in foods) {
        categories.add(food.categoryName);
      }
      return categories.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get cached categories: $e');
    }
  }

  /// Get all unique dietary tags from cached foods.
  Future<List<String>> getCachedDietaryTags() async {
    try {
      final foods = await getCachedFoods();
      final tags = <String>{};
      for (final food in foods) {
        tags.addAll(food.tags);
      }
      return tags.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get cached dietary tags: $e');
    }
  }

  /// Get foods by category from cache sorted by name.
  Future<List<FoodItem>> getCachedFoodsByCategory(String category) async {
    try {
      final foods = await filterCachedByCategory(category);
      return foods..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      throw Exception('Failed to get foods by category: $e');
    }
  }

  /// Get foods by dietary tag from cache sorted by name.
  Future<List<FoodItem>> getCachedFoodsByTag(String tag) async {
    try {
      final foods = await getCachedFoods();
      return foods.where((food) => food.tags.contains(tag)).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      throw Exception('Failed to get foods by tag: $e');
    }
  }
}
