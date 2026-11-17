import '../entities/food_item.dart';
import '../repositories/food_repository.dart';

/// Use case for searching foods.
class SearchFoodsUseCase {
  final FoodRepository repository;

  SearchFoodsUseCase(this.repository);

  Future<List<FoodItem>> searchByName(String query) async {
    if (query.isEmpty) {
      return repository.getAllFoods();
    }
    return repository.searchFoods(query);
  }

  Future<List<FoodItem>> getByCategory(String category) async {
    return repository.getFoodsByCategory(category);
  }

  Future<List<FoodItem>> getByTags(List<String> tags) async {
    if (tags.isEmpty) {
      return repository.getAllFoods();
    }
    return repository.getFoodsByTags(tags);
  }

  Future<FoodItem?> getById(String id) async {
    return repository.getFoodById(id);
  }

  Future<List<String>> getAllCategories() async {
    return repository.getAllCategories();
  }

  Future<List<String>> getAllDietaryTags() async {
    return repository.getAllDietaryTags();
  }
}
