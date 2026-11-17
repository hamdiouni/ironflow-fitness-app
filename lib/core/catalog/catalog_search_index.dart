import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../features/nutrition/domain/entities/food_item.dart';
import '../../features/workout/domain/entities/exercise_definition.dart';

/// Immutable inverted token & prefix search index built off-main-thread via
/// `compute` (`Isolate` on native VM, microtask on Web) for Wave 3.4.
class CatalogSearchIndex<T> {
  CatalogSearchIndex._({
    required List<T> items,
    required Map<String, T> byId,
    required Map<String, List<int>> prefixToIndices,
  })  : _items = List<T>.unmodifiable(items),
        _byId = Map<String, T>.unmodifiable(byId),
        _prefixToIndices = prefixToIndices;

  final List<T> _items;
  final Map<String, T> _byId;
  final Map<String, List<int>> _prefixToIndices;

  List<T> get all => _items;
  int get length => _items.length;

  T? getById(String id) => _byId[id];

  /// Tokenizes [text] into lowercase alphanumeric word tokens.
  static List<String> tokenize(String text) {
    return text
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((t) => t.isNotEmpty)
        .toList();
  }

  /// Builds a [CatalogSearchIndex] synchronously.
  static CatalogSearchIndex<T> buildSync<T>({
    required List<T> items,
    required String Function(T item) idOf,
    required String Function(T item) searchableTextOf,
  }) {
    final byId = <String, T>{};
    final prefixSets = <String, Set<int>>{};

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      byId[idOf(item)] = item;
      final tokens = tokenize(searchableTextOf(item));
      for (final token in tokens) {
        final maxPrefix = token.length > 12 ? 12 : token.length;
        for (var len = 1; len <= maxPrefix; len++) {
          final prefix = token.substring(0, len);
          (prefixSets[prefix] ??= <int>{}).add(i);
        }
        if (token.length > 12) {
          (prefixSets[token] ??= <int>{}).add(i);
        }
      }
    }

    final prefixToIndices = <String, List<int>>{
      for (final entry in prefixSets.entries)
        entry.key: List<int>.unmodifiable(entry.value.toList()..sort()),
    };

    return CatalogSearchIndex<T>._(
      items: items,
      byId: byId,
      prefixToIndices: prefixToIndices,
    );
  }

  /// Searches items matching ALL query tokens via sorted index intersection.
  List<T> search(String query) {
    final tokens = tokenize(query);
    if (tokens.isEmpty) return _items;

    List<int>? intersected;
    for (final token in tokens) {
      final matches = _prefixToIndices[token];
      if (matches == null || matches.isEmpty) {
        return const [];
      }
      if (intersected == null) {
        intersected = matches;
      } else {
        intersected = _intersectSorted(intersected, matches);
        if (intersected.isEmpty) return const [];
      }
    }

    if (intersected == null || intersected.isEmpty) return const [];
    return [for (final idx in intersected) _items[idx]];
  }

  static List<int> _intersectSorted(List<int> a, List<int> b) {
    final out = <int>[];
    var i = 0;
    var j = 0;
    while (i < a.length && j < b.length) {
      final va = a[i];
      final vb = b[j];
      if (va == vb) {
        out.add(va);
        i++;
        j++;
      } else if (va < vb) {
        i++;
      } else {
        j++;
      }
    }
    return out;
  }
}

/// Lazy JSON asset loader + isolate index builder for Exercise and Food catalogs.
class LazyJsonCatalogLoader {
  const LazyJsonCatalogLoader._();

  static const String exercisesAssetPath = 'assets/data/exercises_catalog.json';
  static const String foodsAssetPath = 'assets/data/foods_catalog.json';

  static CatalogSearchIndex<ExerciseDefinition> _parseAndIndexExercises(
    String rawJson,
  ) {
    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    final list = (decoded['exercises'] as List<dynamic>? ?? const [])
        .map((e) => ExerciseDefinition.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return CatalogSearchIndex.buildSync<ExerciseDefinition>(
      items: list,
      idOf: (e) => e.id,
      searchableTextOf: (e) =>
          '${e.name} ${e.subMuscle} ${e.muscleGroup.name} ${e.equipment.name} ${e.primaryRegions.join(" ")}',
    );
  }

  static ({CatalogSearchIndex<FoodItem> index, int verifiedCount})
      parseFoodsCatalogSync(String rawJson) {
    final decoded = jsonDecode(rawJson);
    final rawList = decoded is Map<String, dynamic>
        ? (decoded['foods'] as List<dynamic>? ?? const [])
        : (decoded as List<dynamic>);
    final verifiedCount = decoded is Map<String, dynamic>
        ? ((decoded['verifiedCount'] as int?) ?? 82)
        : rawList.length;
    final list = rawList
        .map((f) => FoodItem.fromAnyJson(Map<String, dynamic>.from(f as Map)))
        .toList();
    final index = CatalogSearchIndex.buildSync<FoodItem>(
      items: list,
      idOf: (f) => f.id,
      searchableTextOf: (f) =>
          '${f.name} ${f.category.name} ${f.tags.join(" ")}',
    );
    return (index: index, verifiedCount: verifiedCount);
  }

  static CatalogSearchIndex<FoodItem> _parseAndIndexFoods(String rawJson) =>
      parseFoodsCatalogSync(rawJson).index;

  /// Lazily loads `assets/data/exercises_catalog.json` and builds the search
  /// index in a background isolate via [compute].
  static Future<CatalogSearchIndex<ExerciseDefinition>> loadExercisesIndex({
    AssetBundle? bundle,
  }) async {
    final raw = await (bundle ?? rootBundle).loadString(exercisesAssetPath);
    return compute(_parseAndIndexExercises, raw);
  }

  /// Lazily loads `assets/data/foods_catalog.json` and builds the search
  /// index plus verified count in a background isolate via [compute].
  static Future<({CatalogSearchIndex<FoodItem> index, int verifiedCount})>
      loadFoodsCatalog({AssetBundle? bundle}) async {
    final raw = await (bundle ?? rootBundle).loadString(foodsAssetPath);
    return compute(parseFoodsCatalogSync, raw);
  }

  /// Lazily loads `assets/data/foods_catalog.json` and builds the search
  /// index in a background isolate via [compute].
  static Future<CatalogSearchIndex<FoodItem>> loadFoodsIndex({
    AssetBundle? bundle,
  }) async {
    final raw = await (bundle ?? rootBundle).loadString(foodsAssetPath);
    return compute(_parseAndIndexFoods, raw);
  }
}

