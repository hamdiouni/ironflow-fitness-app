import '../../../onboarding/domain/entities/user_profile.dart' show BudgetLevel;
import '../entities/food_item.dart';
import 'supplementary_foods_part1.dart';
import 'supplementary_foods_part2.dart';
import 'supplementary_foods_part3.dart';
import 'supplementary_foods_part4.dart';
import 'verified_foods_part1.dart';
import 'verified_foods_part2.dart';
import 'verified_foods_part3.dart';
import 'verified_foods_part4.dart';

/// Authoritative USDA FoodData Central verified foods list.
const List<FoodItem> kVerifiedFoodsList = [
  ...kVerifiedFoodsPart1,
  ...kVerifiedFoodsPart2,
  ...kVerifiedFoodsPart3,
  ...kVerifiedFoodsPart4,
];

/// Domain-level alias matching legacy `verifiedFoodsList`.
const List<FoodItem> verifiedFoodsList = kVerifiedFoodsList;

/// Supplementary general food items list.
const List<FoodItem> kSupplementaryFoodsList = [
  ...kSupplementaryFoodsPart1,
  ...kSupplementaryFoodsPart2,
  ...kSupplementaryFoodsPart3,
  ...kSupplementaryFoodsPart4,
];

/// Domain-layer food catalog and deduplicated lookup service (Wave 3.4).
class FoodCatalog {
  const FoodCatalog._();

  /// Authoritative USDA verified foods only.
  static List<FoodItem> get verifiedFoods => kVerifiedFoodsList;

  /// Supplementary legacy foods list.
  static List<FoodItem> get supplementaryFoods => kSupplementaryFoodsList;

  /// Combined deduplicated master food catalog (USDA verified foods prioritized).
  static final List<FoodItem> foods = _buildCombinedFoods();

  static List<FoodItem> _buildCombinedFoods() {
    final verifiedIds = kVerifiedFoodsList.map((f) => f.id).toSet();
    final verifiedNames =
        kVerifiedFoodsList.map((f) => f.name.toLowerCase()).toSet();
    final uniqueLegacy = kSupplementaryFoodsList.where((f) {
      return !verifiedIds.contains(f.id) &&
          !verifiedNames.contains(f.name.toLowerCase());
    }).toList();
    return [...kVerifiedFoodsList, ...uniqueLegacy];
  }

  static final Map<String, FoodItem> _byId = {
    for (final f in foods) f.id: f,
  };

  static int get foodCount => foods.length;

  static FoodItem? getFoodById(String id) => _byId[id];

  static List<FoodItem> searchByName(String query) {
    if (query.isEmpty) return foods;
    final lowerQuery = query.toLowerCase().trim();
    return foods
        .where((food) => food.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  static List<FoodItem> filterByCategory(FoodCategory category) =>
      foods.where((food) => food.category == category).toList();

  static List<FoodItem> filterByBudget(BudgetLevel budget) =>
      foods.where((food) => food.budgetTier == budget).toList();

  static List<FoodItem> filterByTags(List<String> tags) {
    if (tags.isEmpty) return foods;
    return foods
        .where((food) => tags.every((tag) => food.tags.contains(tag)))
        .toList();
  }

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

  static List<FoodCategory> getAllCategories() =>
      {for (final food in foods) food.category}.toList();

  static List<String> getAllTags() =>
      ({for (final food in foods) ...food.tags}.toList()..sort());

  static Map<FoodCategory, List<FoodItem>> getFoodsByCategory() => {
        for (final category in getAllCategories())
          category: filterByCategory(category),
      };

  static List<FoodItem> getFoodsByTag(String tag) =>
      foods.where((food) => food.tags.contains(tag)).toList();
}
