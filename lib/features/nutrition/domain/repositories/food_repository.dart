import '../entities/food_item_full.dart';

/// Repository interface for food data access
/// Defines contract for food operations with caching support
abstract class FoodRepository {
  /// Get all foods
  /// If [forceRefresh] is true, fetches from Firestore and updates cache
  /// Otherwise returns cached foods if available
  Future<List<FoodItemFull>> getAllFoods({bool forceRefresh = false});

  /// Get a single food by ID
  /// Returns from cache if available, otherwise fetches from Firestore
  Future<FoodItemFull?> getFoodById(String id);

  /// Search foods by name
  /// Searches in cache, falls back to Firestore if cache miss
  Future<List<FoodItemFull>> searchFoods(String query);

  /// Get foods by category
  /// Filters cache, falls back to Firestore if cache miss
  Future<List<FoodItemFull>> getFoodsByCategory(String category);

  /// Get foods by dietary tags
  /// Filters cache, falls back to Firestore if cache miss
  Future<List<FoodItemFull>> getFoodsByTags(List<String> tags);

  /// Get all unique categories from cached foods
  Future<List<String>> getAllCategories();

  /// Get all unique dietary tags from cached foods
  Future<List<String>> getAllDietaryTags();

  /// Check if cache is valid and contains foods
  Future<bool> isCacheValid();

  /// Invalidate cache (called when data changes)
  Future<void> invalidateCache();

  /// Clear all cached foods
  Future<void> clearCache();

  /// Get count of cached foods
  Future<int> getCachedFoodCount();

  /// Save a custom food created by the user
  Future<void> saveCustomFood(FoodItemFull food);

  /// Get all custom foods created by the user
  Future<List<FoodItemFull>> getCustomFoods();

  /// Delete a custom food by ID
  Future<void> deleteCustomFood(String id);
}
