import '../domain/entities/food_item.dart';
import 'foods_list.dart';

class FoodDatabase {
  /// Comprehensive food database with 200+ foods
  /// Each food includes macros per 100g
  /// All values are per 100g and should be scaled by quantity when logging meals
  static final List<FoodItem> foods = foodsList;

  /// Search foods by name (case-insensitive)
  static List<FoodItem> searchByName(String query) {
    if (query.isEmpty) return foods;
    final lowerQuery = query.toLowerCase();
    return foods
        .where((food) => food.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Filter foods by category
  static List<FoodItem> filterByCategory(FoodCategory category) {
    return foods.where((food) => food.category == category).toList();
  }

  /// Filter foods by dietary tags
  static List<FoodItem> filterByTags(List<String> tags) {
    if (tags.isEmpty) return foods;
    return foods
        .where((food) => tags.every((tag) => food.tags.contains(tag)))
        .toList();
  }

  /// Search and filter combined
  static List<FoodItem> search({
    String? query,
    FoodCategory? category,
    List<String>? tags,
  }) {
    var results = foods;

    if (query != null && query.isNotEmpty) {
      results = searchByName(query);
    }

    if (category != null) {
      results = results.where((food) => food.category == category).toList();
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
    } catch (e) {
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

  /// Get foods by category
  static Map<FoodCategory, List<FoodItem>> getFoodsByCategory() {
    final map = <FoodCategory, List<FoodItem>>{};
    for (final category in getAllCategories()) {
      map[category] = filterByCategory(category);
    }
    return map;
  }

  /// Get count of foods
  static int get foodCount => foods.length;

  /// Get foods for a specific tag
  static List<FoodItem> getFoodsByTag(String tag) {
    return foods.where((food) => food.tags.contains(tag)).toList();
  }
}