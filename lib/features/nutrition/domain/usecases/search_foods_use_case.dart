import '../entities/food_item_full.dart';
import '../repositories/food_repository.dart';

/// Use case for searching foods
/// Searches cached foods by name, category, or dietary tags
class SearchFoodsUseCase {
  final FoodRepository repository;

  SearchFoodsUseCase(this.repository);

  /// Search foods by name
  Future<List<FoodItemFull>> searchByName(String query) async {
    if (query.isEmpty) {
      return repository.getAllFoods();
    }
    return repository.searchFoods(query);
  }

  /// Get foods by category
  Future<List<FoodItemFull>> getByCategory(String category) async {
    return repository.getFoodsByCategory(category);
  }

  /// Get foods by dietary tags
  Future<List<FoodItemFull>> getByTags(List<String> tags) async {
    if (tags.isEmpty) {
      return repository.getAllFoods();
    }
    return repository.getFoodsByTags(tags);
  }

  /// Get a single food by ID
  Future<FoodItemFull?> getById(String id) async {
    return repository.getFoodById(id);
  }

  /// Get all unique categories
  Future<List<String>> getAllCategories() async {
    return repository.getAllCategories();
  }

  /// Get all unique dietary tags
  Future<List<String>> getAllDietaryTags() async {
    return repository.getAllDietaryTags();
  }
}
