import 'package:flutter/services.dart';

import '../../../../core/catalog/catalog_search_index.dart';
import '../../../onboarding/domain/entities/user_profile.dart' show BudgetLevel;
import '../entities/food_item.dart';

/// Domain-layer food catalog backed by lazy asset JSON loading via
/// [LazyJsonCatalogLoader] (Wave 3.3).
///
/// Replaces the legacy 8 compiled Dart shard files so the 282-food dataset is
/// decoded off the main isolate on demand rather than baked into the main
/// application bundle.
class FoodCatalog {
  const FoodCatalog._();

  static List<FoodItem> _foods = const [];
  static int _verifiedCount = 0;
  static Map<String, FoodItem> _byId = const {};
  static bool _isLoaded = false;
  static Future<List<FoodItem>>? _inFlightLoad;

  /// Whether the catalog JSON has been loaded into memory.
  static bool get isLoaded => _isLoaded;

  /// Lazily loads and indexes `assets/data/foods_catalog.json` via
  /// [LazyJsonCatalogLoader] (single-flight).
  static Future<List<FoodItem>> ensureLoaded({AssetBundle? bundle}) {
    if (_isLoaded && bundle == null) {
      return Future<List<FoodItem>>.value(_foods);
    }
    return _inFlightLoad ??= _loadInternal(bundle: bundle).whenComplete(() {
      _inFlightLoad = null;
    });
  }

  static Future<List<FoodItem>> _loadInternal({AssetBundle? bundle}) async {
    final loaded = await LazyJsonCatalogLoader.loadFoodsCatalog(bundle: bundle);
    setLoadedFoods(loaded.index.all, verifiedCount: loaded.verifiedCount);
    return _foods;
  }

  /// Populates the catalog directly from a parsed JSON string (useful in tests).
  static void loadFromJsonString(String rawJson) {
    final parsed = LazyJsonCatalogLoader.parseFoodsCatalogSync(rawJson);
    setLoadedFoods(parsed.index.all, verifiedCount: parsed.verifiedCount);
  }

  /// Sets the active in-memory food catalog (single-source cache shared with
  /// [foodsCatalogIndexProvider]).
  static void setLoadedFoods(List<FoodItem> foods, {int? verifiedCount}) {
    _foods = List<FoodItem>.unmodifiable(foods);
    _verifiedCount = (verifiedCount ??
            foods.where((f) => f.id.startsWith('usda_')).length)
        .clamp(0, foods.length);
    _byId = Map<String, FoodItem>.unmodifiable({
      for (final f in _foods) f.id: f,
    });
    _isLoaded = true;
  }

  /// Clears cached catalog state (for unit tests).
  static void resetForTest() {
    _foods = const [];
    _verifiedCount = 0;
    _byId = const {};
    _isLoaded = false;
    _inFlightLoad = null;
  }

  /// Authoritative USDA verified foods only.
  static List<FoodItem> get verifiedFoods =>
      _foods.take(_verifiedCount).toList(growable: false);

  /// Supplementary general food items list.
  static List<FoodItem> get supplementaryFoods =>
      _foods.skip(_verifiedCount).toList(growable: false);

  /// Combined deduplicated master food catalog (USDA verified foods prioritized).
  static List<FoodItem> get foods => _foods;

  static int get foodCount => _foods.length;

  static FoodItem? getFoodById(String id) => _byId[id];

  static List<FoodItem> searchByName(String query) {
    if (query.isEmpty) return _foods;
    final lowerQuery = query.toLowerCase().trim();
    return _foods
        .where((food) => food.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  static List<FoodItem> filterByCategory(FoodCategory category) =>
      _foods.where((food) => food.category == category).toList();

  static List<FoodItem> filterByBudget(BudgetLevel budget) =>
      _foods.where((food) => food.budgetTier == budget).toList();

  static List<FoodItem> filterByTags(List<String> tags) {
    if (tags.isEmpty) return _foods;
    return _foods
        .where((food) => tags.every((tag) => food.tags.contains(tag)))
        .toList();
  }

  static List<FoodItem> search({
    String? query,
    FoodCategory? category,
    BudgetLevel? budgetTier,
    List<String>? tags,
  }) {
    var results = _foods;
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
      {for (final food in _foods) food.category}.toList();

  static List<String> getAllTags() =>
      ({for (final food in _foods) ...food.tags}.toList()..sort());

  static Map<FoodCategory, List<FoodItem>> getFoodsByCategory() => {
        for (final category in getAllCategories())
          category: filterByCategory(category),
      };

  static List<FoodItem> getFoodsByTag(String tag) =>
      _foods.where((food) => food.tags.contains(tag)).toList();
}
