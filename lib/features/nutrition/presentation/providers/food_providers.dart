import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/catalog/catalog_search_index.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/repositories/food_repository.dart';
import '../../domain/services/food_catalog.dart';
import '../../domain/usecases/search_food_use_case.dart';
import 'food_repository_provider.dart';

import '../../../onboarding/domain/entities/user_profile.dart' show BudgetLevel;

class FoodSearchState {
  const FoodSearchState({
    this.query = '',
    this.category,
    this.budgetTier,
  });
  final String query;
  final FoodCategory? category;
  final BudgetLevel? budgetTier;

  FoodSearchState copyWith({
    String? query,
    FoodCategory? category,
    BudgetLevel? budgetTier,
    bool clearCategory = false,
    bool clearBudget = false,
  }) {
    return FoodSearchState(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
      budgetTier: clearBudget ? null : (budgetTier ?? this.budgetTier),
    );
  }
}

class FoodSearchNotifier extends Notifier<FoodSearchState> {
  @override
  FoodSearchState build() => const FoodSearchState();

  void setQuery(String q) => state = state.copyWith(query: q);
  void setCategory(FoodCategory? c) => state = c == null
      ? state.copyWith(clearCategory: true)
      : state.copyWith(category: c);
  void setBudget(BudgetLevel? b) => state = b == null
      ? state.copyWith(clearBudget: true)
      : state.copyWith(budgetTier: b);
}

final foodSearchProvider =
    NotifierProvider<FoodSearchNotifier, FoodSearchState>(
  FoodSearchNotifier.new,
);

/// Lazy background-isolate loader + search index for the bundled food catalog.
final foodsCatalogIndexProvider =
    FutureProvider<CatalogSearchIndex<FoodItem>>((ref) async {
  if (FoodCatalog.isLoaded) {
    return CatalogSearchIndex.buildSync<FoodItem>(
      items: FoodCatalog.foods,
      idOf: (f) => f.id,
      searchableTextOf: (f) =>
          '${f.name} ${f.category.name} ${f.tags.join(" ")}',
    );
  }
  final loaded = await LazyJsonCatalogLoader.loadFoodsCatalog();
  FoodCatalog.setLoadedFoods(
    loaded.index.all,
    verifiedCount: loaded.verifiedCount,
  );
  return loaded.index;
});

final filteredFoodProvider = Provider<List<FoodItem>>((ref) {
  final s = ref.watch(foodSearchProvider);
  final catalogAsync = ref.watch(foodsCatalogIndexProvider);
  final index = catalogAsync.valueOrNull;
  if (index == null) {
    if (FoodCatalog.isLoaded) {
      return SearchFoodUseCase()(
        query: s.query,
        category: s.category,
        budgetTier: s.budgetTier,
      );
    }
    return const [];
  }
  List<FoodItem> results =
      s.query.trim().isEmpty ? index.all : index.search(s.query);
  if (s.category != null) {
    results = results.where((f) => f.category == s.category).toList();
  }
  if (s.budgetTier != null) {
    results = results.where((f) => f.budgetTier == s.budgetTier).toList();
  }
  return results;
});

/// Custom Foods Notifier for managing user-created foods
class CustomFoodsNotifier extends Notifier<AsyncValue<List<FoodItem>>> {
  CustomFoodsNotifier([this._injectedRepository]);

  final FoodRepository? _injectedRepository;

  late FoodRepository _repository;
  bool _disposed = false;

  @override
  AsyncValue<List<FoodItem>> build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
    });
    _repository = _injectedRepository ?? ref.watch(foodRepositoryProvider);
    _loadCustomFoods();
    return const AsyncValue.loading();
  }

  /// Load custom foods from repository
  Future<void> _loadCustomFoods() async {
    try {
      if (kDebugMode) {
        AppLogger.debug('📊 [CustomFoods] Loading custom foods...');
      }
      
      final foods = await _repository.getCustomFoods();
      if (_disposed) return;
      
      if (kDebugMode) {
        AppLogger.debug('✅ [CustomFoods] Loaded ${foods.length} custom foods');
      }
      
      state = AsyncValue.data(foods);
    } catch (e, stackTrace) {
      if (_disposed) return;
      if (kDebugMode) {
        AppLogger.debug('❌ [CustomFoods] Failed to load custom foods: $e');
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Add a new custom food
  Future<void> addCustomFood(FoodItem food) async {
    try {
      if (kDebugMode) {
        AppLogger.debug('📊 [CustomFoods] Adding custom food: ${food.name}');
      }
      
      // Save to repository
      await _repository.saveCustomFood(food);
      
      if (kDebugMode) {
        AppLogger.debug('✅ [CustomFoods] Custom food saved to repository');
      }
      
      // Update state immediately
      state.whenData((currentFoods) {
        final updatedFoods = [...currentFoods, food];
        
        if (kDebugMode) {
          AppLogger.debug('✅ [CustomFoods] State updated with new food');
          AppLogger.debug('🔍 [CustomFoods] Total custom foods: ${updatedFoods.length}');
        }
        
        state = AsyncValue.data(updatedFoods);
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        AppLogger.debug('❌ [CustomFoods] Failed to add custom food: $e');
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Delete a custom food
  Future<void> deleteCustomFood(String id) async {
    try {
      if (kDebugMode) {
        AppLogger.debug('📊 [CustomFoods] Deleting custom food: $id');
      }
      
      // Delete from repository
      await _repository.deleteCustomFood(id);
      
      if (kDebugMode) {
        AppLogger.debug('✅ [CustomFoods] Custom food deleted from repository');
      }
      
      // Update state immediately
      state.whenData((currentFoods) {
        final updatedFoods = currentFoods.where((f) => f.id != id).toList();
        
        if (kDebugMode) {
          AppLogger.debug('✅ [CustomFoods] State updated after deletion');
          AppLogger.debug('🔍 [CustomFoods] Remaining custom foods: ${updatedFoods.length}');
        }
        
        state = AsyncValue.data(updatedFoods);
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        AppLogger.debug('❌ [CustomFoods] Failed to delete custom food: $e');
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh custom foods from repository
  Future<void> refresh() async {
    await _loadCustomFoods();
  }
}

/// Provider for custom foods with instant updates
final customFoodsProvider =
    NotifierProvider<CustomFoodsNotifier, AsyncValue<List<FoodItem>>>(
  CustomFoodsNotifier.new,
);

// The food repository provider lives in food_repository_provider.dart
// (Phase 3, F-10) — there used to be three same-named definitions.

/// State for food upload
class FoodUploadState {
  const FoodUploadState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.uploadedCount = 0,
    this.totalCount = 0,
  });

  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final int uploadedCount;
  final int totalCount;

  FoodUploadState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    int? uploadedCount,
    int? totalCount,
  }) {
    return FoodUploadState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      uploadedCount: uploadedCount ?? this.uploadedCount,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
