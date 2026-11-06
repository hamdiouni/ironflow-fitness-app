import '../../onboarding/domain/entities/user_profile.dart' show BudgetLevel;
import '../domain/entities/food_item.dart';
import '../domain/services/food_catalog.dart';

/// Backward-compatible data-layer facade delegating to [FoodCatalog] (Wave 3.4).
class FoodDatabase {
  static List<FoodItem> get foods => FoodCatalog.foods;
  static List<FoodItem> get verifiedFoods => FoodCatalog.verifiedFoods;
  static int get foodCount => FoodCatalog.foodCount;

  static List<FoodItem> searchByName(String query) =>
      FoodCatalog.searchByName(query);

  static List<FoodItem> filterByCategory(FoodCategory category) =>
      FoodCatalog.filterByCategory(category);

  static List<FoodItem> filterByBudget(BudgetLevel budget) =>
      FoodCatalog.filterByBudget(budget);

  static List<FoodItem> filterByTags(List<String> tags) =>
      FoodCatalog.filterByTags(tags);

  static List<FoodItem> search({
    String? query,
    FoodCategory? category,
    BudgetLevel? budgetTier,
    List<String>? tags,
  }) =>
      FoodCatalog.search(
        query: query,
        category: category,
        budgetTier: budgetTier,
        tags: tags,
      );

  static FoodItem? getFoodById(String id) => FoodCatalog.getFoodById(id);

  static List<FoodCategory> getAllCategories() =>
      FoodCatalog.getAllCategories();

  static List<String> getAllTags() => FoodCatalog.getAllTags();

  static Map<FoodCategory, List<FoodItem>> getFoodsByCategory() =>
      FoodCatalog.getFoodsByCategory();

  static List<FoodItem> getFoodsByTag(String tag) =>
      FoodCatalog.getFoodsByTag(tag);
}
