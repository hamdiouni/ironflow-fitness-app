import '../../domain/entities/food_item.dart';
import '../../domain/repositories/food_repository.dart';
import '../datasources/firestore_food_datasource.dart';
import '../datasources/hive_food_datasource.dart';

/// Concrete implementation of [FoodRepository].
/// Implements offline-first caching with Firestore as source of truth.
class FoodRepositoryImpl implements FoodRepository {
  final FirestoreFoodDatasource firestoreDataSource;
  final HiveFoodDataSource hiveDataSource;

  FoodRepositoryImpl({
    required this.firestoreDataSource,
    required this.hiveDataSource,
  });

  /// Get all foods with caching.
  @override
  Future<List<FoodItem>> getAllFoods({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final isCacheValid = await hiveDataSource.isCacheValid();
        if (isCacheValid) {
          return hiveDataSource.getCachedFoods();
        }
      }

      final foods = await firestoreDataSource.getAllFoods();
      await hiveDataSource.cacheFoods(foods);
      return foods;
    } catch (e) {
      final isCacheValid = await hiveDataSource.isCacheValid();
      if (isCacheValid) {
        return hiveDataSource.getCachedFoods();
      }
      rethrow;
    }
  }

  /// Get a single food by ID with caching.
  @override
  Future<FoodItem?> getFoodById(String id) async {
    try {
      final cachedFood = await hiveDataSource.getCachedFoodById(id);
      if (cachedFood != null) {
        return cachedFood;
      }

      final food = await firestoreDataSource.getFoodById(id);
      if (food != null) {
        await hiveDataSource.upsertCachedFood(food);
      }
      return food;
    } catch (_) {
      return hiveDataSource.getCachedFoodById(id);
    }
  }

  /// Search foods by name with caching.
  @override
  Future<List<FoodItem>> searchFoods(String query) async {
    try {
      await getAllFoods();
      return hiveDataSource.searchCachedFoods(query);
    } catch (_) {
      return firestoreDataSource.searchFoods(query);
    }
  }

  /// Get foods by category with caching.
  @override
  Future<List<FoodItem>> getFoodsByCategory(String category) async {
    try {
      await getAllFoods();
      return hiveDataSource.getCachedFoodsByCategory(category);
    } catch (_) {
      return firestoreDataSource.getFoodsByCategory(category);
    }
  }

  /// Get foods by dietary tags with caching.
  @override
  Future<List<FoodItem>> getFoodsByTags(List<String> tags) async {
    try {
      await getAllFoods();
      return hiveDataSource.filterCachedByTags(tags);
    } catch (_) {
      return firestoreDataSource.getFoodsByTags(tags);
    }
  }

  @override
  Future<List<String>> getAllCategories() async {
    try {
      await getAllFoods();
      return hiveDataSource.getCachedCategories();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<String>> getAllDietaryTags() async {
    try {
      await getAllFoods();
      return hiveDataSource.getCachedDietaryTags();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<bool> isCacheValid() => hiveDataSource.isCacheValid();

  @override
  Future<void> invalidateCache() => hiveDataSource.invalidateCache();

  @override
  Future<void> clearCache() => hiveDataSource.clearCache();

  @override
  Future<int> getCachedFoodCount() => hiveDataSource.getCachedFoodCount();

  @override
  Future<void> saveCustomFood(FoodItem food) async {
    try {
      await hiveDataSource.saveCustomFood(food);
    } catch (e) {
      throw Exception('Failed to save custom food: $e');
    }
  }

  @override
  Future<List<FoodItem>> getCustomFoods() async {
    try {
      return await hiveDataSource.getCustomFoods();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> deleteCustomFood(String id) async {
    try {
      await hiveDataSource.deleteCustomFood(id);
    } catch (e) {
      throw Exception('Failed to delete custom food: $e');
    }
  }
}
