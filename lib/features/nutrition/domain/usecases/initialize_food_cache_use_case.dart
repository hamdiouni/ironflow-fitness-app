import '../repositories/food_repository.dart';

/// Use case for initializing the food cache on app startup
/// Ensures foods are cached locally for offline access
class InitializeFoodCacheUseCase {
  final FoodRepository repository;

  InitializeFoodCacheUseCase(this.repository);

  /// Execute the use case
  /// Loads all foods from Firestore and caches them locally
  /// Returns the count of cached foods
  Future<int> call() async {
    try {
      // Check if cache is already valid
      final isCacheValid = await repository.isCacheValid();
      if (isCacheValid) {
        return repository.getCachedFoodCount();
      }

      // Load all foods (will be cached automatically)
      await repository.getAllFoods(forceRefresh: true);

      // Return count of cached foods
      return repository.getCachedFoodCount();
    } catch (e) {
      throw Exception('Failed to initialize food cache: $e');
    }
  }
}
