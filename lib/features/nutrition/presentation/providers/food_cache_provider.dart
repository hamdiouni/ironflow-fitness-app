import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/datasources/firestore_food_datasource.dart';
import '../../data/datasources/hive_food_datasource.dart';
import '../../data/repositories/food_repository_impl.dart';
import '../../domain/repositories/food_repository.dart';
import '../../domain/usecases/initialize_food_cache_use_case.dart';
import '../../domain/usecases/search_foods_use_case.dart';
import '../../domain/entities/food_item_full.dart';

/// Firestore data source provider
final firestoreFoodDataSourceProvider = Provider((ref) {
  return FirestoreFoodDatasource(FirebaseFirestore.instance);
});

/// Hive data source provider
final hiveFoodDataSourceProvider = Provider((ref) {
  return HiveFoodDataSource();
});

/// Food repository provider
final foodRepositoryProvider = Provider((ref) {
  final firestoreDataSource = ref.watch(firestoreFoodDataSourceProvider);
  final hiveDataSource = ref.watch(hiveFoodDataSourceProvider);

  return FoodRepositoryImpl(
    firestoreDataSource: firestoreDataSource,
    hiveDataSource: hiveDataSource,
  );
});

/// Initialize food cache use case provider
final initializeFoodCacheUseCaseProvider = Provider((ref) {
  final repository = ref.watch(foodRepositoryProvider);
  return InitializeFoodCacheUseCase(repository);
});

/// Search foods use case provider
final searchFoodsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(foodRepositoryProvider);
  return SearchFoodsUseCase(repository);
});

/// Initialize food cache on app startup
final foodCacheInitializationProvider = FutureProvider((ref) async {
  final useCase = ref.watch(initializeFoodCacheUseCaseProvider);
  return useCase();
});

/// Get all cached foods
final allCachedFoodsProvider = FutureProvider((ref) async {
  final repository = ref.watch(foodRepositoryProvider);
  return repository.getAllFoods();
});

/// Alias for allCachedFoodsProvider for convenience
final foodCacheProvider = FutureProvider((ref) async {
  final repository = ref.watch(foodRepositoryProvider);
  return repository.getAllFoods();
});

/// Search foods by query
final searchFoodsProvider = FutureProvider.family<List<FoodItemFull>, String>(
  (ref, query) async {
    final useCase = ref.watch(searchFoodsUseCaseProvider);
    return useCase.searchByName(query);
  },
);

/// Get foods by category
final foodsByCategoryProvider =
    FutureProvider.family<List<FoodItemFull>, String>(
  (ref, category) async {
    final useCase = ref.watch(searchFoodsUseCaseProvider);
    return useCase.getByCategory(category);
  },
);

/// Get foods by dietary tags
final foodsByTagsProvider =
    FutureProvider.family<List<FoodItemFull>, List<String>>(
  (ref, tags) async {
    final useCase = ref.watch(searchFoodsUseCaseProvider);
    return useCase.getByTags(tags);
  },
);

/// Get a single food by ID
final foodByIdProvider = FutureProvider.family<FoodItemFull?, String>(
  (ref, id) async {
    final useCase = ref.watch(searchFoodsUseCaseProvider);
    return useCase.getById(id);
  },
);

/// Get all unique categories
final allCategoriesProvider = FutureProvider((ref) async {
  final useCase = ref.watch(searchFoodsUseCaseProvider);
  return useCase.getAllCategories();
});

/// Get all unique dietary tags
final allDietaryTagsProvider = FutureProvider((ref) async {
  final useCase = ref.watch(searchFoodsUseCaseProvider);
  return useCase.getAllDietaryTags();
});

/// Check if cache is valid
final isFoodCacheValidProvider = FutureProvider((ref) async {
  final repository = ref.watch(foodRepositoryProvider);
  return repository.isCacheValid();
});

/// Get count of cached foods
final cachedFoodCountProvider = FutureProvider((ref) async {
  final repository = ref.watch(foodRepositoryProvider);
  return repository.getCachedFoodCount();
});

/// Invalidate food cache
final invalidateFoodCacheProvider = StateNotifierProvider((ref) {
  return InvalidateFoodCacheNotifier(ref.watch(foodRepositoryProvider));
});

class InvalidateFoodCacheNotifier extends StateNotifier<AsyncValue<void>> {
  final FoodRepository repository;

  InvalidateFoodCacheNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> invalidate() async {
    state = const AsyncValue.loading();
    try {
      await repository.invalidateCache();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clear() async {
    state = const AsyncValue.loading();
    try {
      await repository.clearCache();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
