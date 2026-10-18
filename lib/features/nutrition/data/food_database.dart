import '../../onboarding/domain/entities/user_profile.dart' show BudgetLevel;
import '../domain/entities/food_item.dart';
import 'foods_list.dart';
import 'verified_foods_data.dart';

/// Central catalog for food items, prioritizing authoritative USDA FoodData Central
/// verified records with complete provenance, exact macros/micros, and budget tiers.
class FoodDatabase {
  /// Master food catalog. Verified USDA foods are placed first, followed by
  /// supplementary legacy foods without ID collisions.
  static final List<FoodItem> foods = _buildCombinedFoods();

  static List<FoodItem> _buildCombinedFoods() {
    final verifiedIds = verifiedFoodsList.map((f) => f.id).toSet();
    final verifiedNames =
        verifiedFoodsList.map((f) => f.name.toLowerCase()).toSet();
    final uniqueLegacy = foodsList.where((f) {
      return !verifiedIds.contains(f.id) &&
          !verifiedNames.contains(f.name.toLowerCase());
    }).toList();
    return [...verifiedFoodsList, ...uniqueLegacy];
  }

  /// Authoritative USDA FoodData Central verified foods only.
  static List<FoodItem> get verifiedFoods => verifiedFoodsList;

  /// Search foods by name (case-insensitive)
  static List<FoodItem> searchByName(String query) {
    if (query.isEmpty) return foods;
    final lowerQuery = query.toLowerCase().trim();
    return foods
        .where((food) => food.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Filter foods by category
  static List<FoodItem> filterByCategory(FoodCategory category) {
    return foods.where((food) => food.category == category).toList();
  }

  /// Filter foods by budget level (matching onboarding profile)
  static List<FoodItem> filterByBudget(BudgetLevel budget) {
    return foods.where((food) => food.budgetTier == budget).toList();
  }

  /// Filter foods by dietary tags
  static List<FoodItem> filterByTags(List<String> tags) {
    if (tags.isEmpty) return foods;
    return foods
        .where((food) => tags.every((tag) => food.tags.contains(tag)))
        .toList();
  }

  /// Search and filter combined with optional category, budget tier, and tags
  static List<FoodItem> search({
    String? query,
    FoodCategory? category,
    BudgetLevel? budgetTier,
    List<String>? tags,
  }) {
    var results = foods;

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      results = results
          .where((food) => food.name.toLowerCase().contains(q))
          .toList();
    }

    if (category != null) {
      results = results.where((food) => food.category == category).toList();
    }

    if (budgetTier != null) {
      results = results.where((food) => food.budgetTier == budgetTier).toList();
    }

    if (tags != null && tags.isNotEmpty) {
      results = results
          .where((food) => tags.every((tag) => food.tags.contains(tag)))
          .toList();
    }

    return results;
  }

  /// Get food by ID
  static FoodItem? getFoodById(String id) {
    try {
      return foods.firstWhere((food) => food.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get all unique categories
  static List<FoodCategory> getAllCategories() {
    final categories = <FoodCategory>{};
    for (final food in foods) {
      categories.add(food.category);
    }
    return categories.toList();
  }

  /// Get all unique tags
  static List<String> getAllTags() {
    final tags = <String>{};
    for (final food in foods) {
      tags.addAll(food.tags);
    }
    return tags.toList()..sort();
  }

  /// Get foods grouped by category
  static Map<FoodCategory, List<FoodItem>> getFoodsByCategory() {
    final map = <FoodCategory, List<FoodItem>>{};
    for (final category in getAllCategories()) {
      map[category] = filterByCategory(category);
    }
    return map;
  }

  /// Total count of available foods
  static int get foodCount => foods.length;

  /// Get foods for a specific tag
  static List<FoodItem> getFoodsByTag(String tag) {
    return foods.where((food) => food.tags.contains(tag)).toList();
  }
}