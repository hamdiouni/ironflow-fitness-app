import '../../domain/entities/food_item_full.dart';
import '../../domain/repositories/food_repository.dart';
import '../datasources/firestore_food_datasource.dart';
import '../datasources/hive_food_datasource.dart';
import '../models/food_item_full_model.dart';

/// Concrete implementation of [FoodRepository]
/// Implements offline-first caching with Firestore as source of truth
class FoodRepositoryImpl implements FoodRepository {
  final FirestoreFoodDatasource firestoreDataSource;
  final HiveFoodDataSource hiveDataSource;

  FoodRepositoryImpl({
    required this.firestoreDataSource,
    required this.hiveDataSource,
  });

  /// Get all foods with caching
  /// Returns cached foods if available, otherwise fetches from Firestore
  @override
  Future<List<FoodItemFull>> getAllFoods({bool forceRefresh = false}) async {
    try {
      // If not forcing refresh, try to return cached foods
      if (!forceRefresh) {
        final isCacheValid = await hiveDataSource.isCacheValid();
        if (isCacheValid) {
          return (await hiveDataSource.getCachedFoods())
              .map((m) => m.toEntity())
              .toList();
        }
      }

      // Fetch from Firestore
      final foods = await firestoreDataSource.getAllFoods();

      // Cache the foods locally
      final models = foods.map((f) => FoodItemFullModel.fromEntity(f)).toList();
      await hiveDataSource.cacheFoods(models);

      return foods;
    } catch (e) {
      // If Firestore fails, try to return cached foods
      final isCacheValid = await hiveDataSource.isCacheValid();
      if (isCacheValid) {
        return (await hiveDataSource.getCachedFoods())
            .map((m) => m.toEntity())
            .toList();
      }
      rethrow;
    }
  }

  /// Get a single food by ID with caching
  @override
  Future<FoodItemFull?> getFoodById(String id) async {
    try {
      // Try to get from cache first
      final cachedFood = await hiveDataSource.getCachedFoodById(id);
      if (cachedFood != null) {
        return cachedFood.toEntity();
      }

      // If not in cache, fetch from Firestore
      final food = await firestoreDataSource.getFoodById(id);
      if (food != null) {
        // Cache it
        final model = FoodItemFullModel.fromEntity(food);
        await hiveDataSource.cacheFoods([model]);
      }
      return food;
    } catch (e) {
      // Try to return from cache on error
      final cachedFood = await hiveDataSource.getCachedFoodById(id);
      return cachedFood?.toEntity();
    }
  }

  /// Search foods by name with caching
  @override
  Future<List<FoodItemFull>> searchFoods(String query) async {
    try {
      // Ensure cache is populated
      await getAllFoods();

      // Search in cache
      final results = await hiveDataSource.searchCachedFoods(query);
      return results.map((m) => m.toEntity()).toList();
    } catch (e) {
      // Fallback to Firestore search
      final results = await firestoreDataSource.searchFoods(query);
      return results;
    }
  }

  /// Get foods by category with caching
  @override
  Future<List<FoodItemFull>> getFoodsByCategory(String category) async {
    try {
      // Ensure cache is populated
      await getAllFoods();

      // Filter from cache
      final results = await hiveDataSource.getCachedFoodsByCategory(category);
      return results.map((m) => m.toEntity()).toList();
    } catch (e) {
      // Fallback to Firestore
      final results = await firestoreDataSource.getFoodsByCategory(category);
      return results;
    }
  }

  /// Get foods by dietary tags with caching
  @override
  Future<List<FoodItemFull>> getFoodsByTags(List<String> tags) async {
    try {
      // Ensure cache is populated
      await getAllFoods();

      // Filter from cache
      final results = await hiveDataSource.filterCachedByTags(tags);
      return results.map((m) => m.toEntity()).toList();
    } catch (e) {
      // Fallback to Firestore
      final results = await firestoreDataSource.getFoodsByTags(tags);
      return results;
    }
  }

  /// Get all unique categories from cache
  @override
  Future<List<String>> getAllCategories() async {
    try {
      // Ensure cache is populated
      await getAllFoods();

      return hiveDataSource.getCachedCategories();
    } catch (e) {
      return [];
    }
  }

  /// Get all unique dietary tags from cache
  @override
  Future<List<String>> getAllDietaryTags() async {
    try {
      // Ensure cache is populated
      await getAllFoods();

      return hiveDataSource.getCachedDietaryTags();
    } catch (e) {
      return [];
    }
  }

  /// Check if cache is valid
  @override
  Future<bool> isCacheValid() async {
    return hiveDataSource.isCacheValid();
  }

  /// Invalidate cache (called when data changes)
  @override
  Future<void> invalidateCache() async {
    await hiveDataSource.invalidateCache();
  }

  /// Clear all cached foods
  @override
  Future<void> clearCache() async {
    await hiveDataSource.clearCache();
  }

  /// Get count of cached foods
  @override
  Future<int> getCachedFoodCount() async {
    return hiveDataSource.getCachedFoodCount();
  }

  /// Save a custom food created by the user
  @override
  Future<void> saveCustomFood(FoodItemFull food) async {
    try {
      final model = FoodItemFullModel.fromEntity(food);
      await hiveDataSource.saveCustomFood(model);
    } catch (e) {
      throw Exception('Failed to save custom food: $e');
    }
  }

  /// Get all custom foods created by the user
  @override
  Future<List<FoodItemFull>> getCustomFoods() async {
    try {
      final customFoods = await hiveDataSource.getCustomFoods();
      return customFoods.map((m) => m.toEntity()).toList();
    } catch (e) {
      return [];
    }
  }

  /// Delete a custom food by ID
  @override
  Future<void> deleteCustomFood(String id) async {
    try {
      await hiveDataSource.deleteCustomFood(id);
    } catch (e) {
      throw Exception('Failed to delete custom food: $e');
    }
  }
}
