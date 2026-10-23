import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firestore_food_datasource.dart';
import '../../data/datasources/hive_food_datasource.dart';
import '../../data/datasources/hive_nutrition_datasource.dart';
import '../../data/models/meal_model.dart';
import '../../data/repositories/food_repository_impl.dart';
import '../../data/repositories/nutrition_repository_impl.dart';
import '../../../sync/domain/entities/sync_action.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
import '../../../ai/presentation/providers/global_ai_provider.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../domain/entities/daily_nutrition_summary.dart';
import '../../domain/entities/food_item_full.dart';
import '../../domain/entities/meal.dart';
import '../../domain/repositories/food_repository.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../../domain/usecases/get_food_alternatives_use_case.dart';
import '../../domain/usecases/get_meal_suggestions_use_case.dart';
import '../../../../core/providers/analytics_provider.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  final hiveDataSource = HiveNutritionDatasource();
  // Was hardcoded to 'test-user' for every account (DATABASE_AND_SYNC_AUDIT
  // F-01). Watching the auth user id rebuilds the repository when the
  // signed-in user changes; 'local-user' covers the logged-out/guest path.
  final userId =
      ref.watch(authNotifierProvider.select((s) => s.user?.id)) ?? 'local-user';
  // Phase 2: cloud writes go through the single outbox instead of the
  // repository's old direct dual-write to users/{uid}/nutrition.
  final syncService = ref.watch(syncServiceProvider);
  return NutritionRepositoryImpl(
    hiveDataSource: hiveDataSource,
    userId: userId,
    onMealSaved: (meal) => syncService.queueAction(
      type: SyncActionType.update,
      dataType: SyncDataType.nutrition,
      dataId: meal.id,
      data: MealModel.fromEntity(meal).toJson(),
    ),
    onMealDeleted: (mealId) => syncService.queueAction(
      type: SyncActionType.delete,
      dataType: SyncDataType.nutrition,
      dataId: mealId,
      data: {'id': mealId, 'userId': userId},
    ),
    onTargetsSaved: (targets) => syncService.queueAction(
      type: SyncActionType.update,
      dataType: SyncDataType.nutritionTargets,
      dataId: userId,
      data: targets.toJson(),
    ),
  );
});

// ---------------------------------------------------------------------------
// Food repository provider
// ---------------------------------------------------------------------------

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  // Was `nutritionRepositoryProvider as FoodRepository` — NutritionRepositoryImpl
  // does not implement FoodRepository, so this threw a CastError at runtime
  // (DATABASE_AND_SYNC_AUDIT F-10). Provide the real implementation.
  return FoodRepositoryImpl(
    firestoreDataSource: FirestoreFoodDatasource(FirebaseFirestore.instance),
    hiveDataSource: HiveFoodDataSource(),
  );
});

// ---------------------------------------------------------------------------
// Use case providers
// ---------------------------------------------------------------------------

final getMealSuggestionsUseCaseProvider =
    Provider<GetMealSuggestionsUseCase>((ref) {
  final repository = ref.watch(foodRepositoryProvider);
  return GetMealSuggestionsUseCase(repository);
});

final getFoodAlternativesUseCaseProvider =
    Provider<GetFoodAlternativesUseCase>((ref) {
  final repository = ref.watch(foodRepositoryProvider);
  return GetFoodAlternativesUseCase(repository);
});

// ---------------------------------------------------------------------------
// Daily nutrition summary provider (StateNotifier for instant updates)
// ---------------------------------------------------------------------------

/// State notifier for managing daily nutrition summary with instant UI updates.
/// 
/// This notifier ensures that when meals are added or deleted, the UI updates
/// immediately without requiring manual refresh.
class DailyNutritionNotifier extends StateNotifier<AsyncValue<DailyNutritionSummary>> {
  DailyNutritionNotifier(this._repository, this._date, this._ref) : super(const AsyncValue.loading()) {
    _loadSummary();
  }

  final NutritionRepository _repository;
  final DateTime _date;
  final Ref _ref;

  /// Load the daily nutrition summary from repository
  Future<void> _loadSummary() async {
    try {
      if (kDebugMode) {
        AppLogger.debug('📊 [Nutrition] Fetching daily nutrition summary...');
        AppLogger.debug('🔍 [Nutrition] Date: ${_date.toIso8601String().split('T')[0]}');
      }
      
      final summary = await _repository.getDailyNutrition(_date);
      
      if (kDebugMode) {
        AppLogger.debug('✅ [Nutrition] Daily nutrition summary retrieved successfully');
        AppLogger.debug('🔍 [Nutrition] Total calories: ${summary.totalCalories}, Meals: ${summary.meals.length}');
      }
      
      state = AsyncValue.data(summary);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        AppLogger.debug('❌ [Nutrition] Failed to fetch daily nutrition summary: $e');
        AppLogger.debug('🔍 [Nutrition] Stack trace: $stackTrace');
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Add a meal and update state immediately
  Future<void> addMeal(Meal meal) async {
    try {
      if (kDebugMode) {
        AppLogger.debug('📊 [Nutrition] Adding meal: ${meal.name}');
      }
      
      // Save to repository
      await _repository.saveMealEntry(meal);
      
      if (kDebugMode) {
        AppLogger.debug('✅ [Nutrition] Meal saved to repository');
      }
      
      // Update state immediately by creating new summary with added meal
      state.whenData((currentSummary) {
        final updatedMeals = [...currentSummary.meals, meal];
        final updatedSummary = DailyNutritionSummary(
          date: currentSummary.date,
          meals: updatedMeals,
          target: currentSummary.target,
        );
        
        if (kDebugMode) {
          AppLogger.debug('✅ [Nutrition] State updated with new meal');
          AppLogger.debug('🔍 [Nutrition] Total meals: ${updatedMeals.length}');
        }
        
        state = AsyncValue.data(updatedSummary);
      });
      _ref.invalidate(recentFoodsProvider);

      // Notify Global AI so nutrition insights refresh now, not at next
      // app launch. onMealLogged previously had zero callers
      // (DATABASE_AND_SYNC_AUDIT F-06). Fire-and-forget: failures must not
      // block or fail meal logging.
      try {
        _ref.read(globalAIProvider.notifier).onMealLogged();
      } catch (e) {
        if (kDebugMode) {
          AppLogger.debug('⚠️ [Nutrition] AI meal notification skipped: $e');
        }
      }

      // Track meal logged event
      try {
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.logMealLogged(
          mealType: 'meal', // Generic meal type since Meal entity doesn't have this property
          calories: meal.macros.calories.toInt(),
          protein: meal.macros.protein,
          carbs: meal.macros.carbs,
          fat: meal.macros.fats,
        );
        if (kDebugMode) {
          AppLogger.debug('📊 [Analytics] Meal logged event tracked');
        }
      } catch (e) {
        if (kDebugMode) {
          AppLogger.debug('⚠️ [Analytics] Failed to log meal event: $e');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        AppLogger.debug('❌ [Nutrition] Failed to add meal: $e');
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Delete a meal and update state immediately
  Future<void> deleteMeal(String mealId) async {
    try {
      if (kDebugMode) {
        AppLogger.debug('📊 [Nutrition] Deleting meal: $mealId');
      }
      
      // Delete from repository
      await _repository.deleteMealEntry(mealId);
      
      if (kDebugMode) {
        AppLogger.debug('✅ [Nutrition] Meal deleted from repository');
      }
      
      // Update state immediately by removing the meal
      state.whenData((currentSummary) {
        final updatedMeals = currentSummary.meals.where((m) => m.id != mealId).toList();
        final updatedSummary = DailyNutritionSummary(
          date: currentSummary.date,
          meals: updatedMeals,
          target: currentSummary.target,
        );
        
        if (kDebugMode) {
          AppLogger.debug('✅ [Nutrition] State updated after deletion');
          AppLogger.debug('🔍 [Nutrition] Remaining meals: ${updatedMeals.length}');
        }
        
        state = AsyncValue.data(updatedSummary);
      });
      _ref.invalidate(recentFoodsProvider);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        AppLogger.debug('❌ [Nutrition] Failed to delete meal: $e');
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Refresh the summary from repository
  Future<void> refresh() async {
    await _loadSummary();
  }
}

/// Provides the daily nutrition summary for a specific date with instant updates.
final dailyNutritionSummaryProvider = StateNotifierProvider.family<
    DailyNutritionNotifier,
    AsyncValue<DailyNutritionSummary>,
    DateTime>((ref, date) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return DailyNutritionNotifier(repository, date, ref);
});

// ---------------------------------------------------------------------------
// Recent foods provider (derived from existing logs, no new storage)
// ---------------------------------------------------------------------------

/// Provides top distinct recent meal entries derived from existing nutrition history.
///
/// Top distinct entries are deduplicated by meal name, sorted most recent first.
/// Validates: Batch 5 - Fuel quick-add.
final recentFoodsProvider = FutureProvider<List<Meal>>((ref) async {
  final repository = ref.watch(nutritionRepositoryProvider);
  try {
    // 1. Fetch recent nutrition history summaries (up to 14 days)
    final summaries = await repository.getNutritionHistoryPaginated(
      offset: 0,
      limit: 14,
    );

    // 2. Also fetch today's summary to include any meals logged today
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todaySummary = await repository.getDailyNutrition(today);

    // 3. Aggregate all meals
    final allMeals = <Meal>[
      ...todaySummary.meals,
      for (final summary in summaries) ...summary.meals,
    ];

    // 4. Sort descending by timestamp
    allMeals.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // 5. Deduplicate distinct names (case-insensitive)
    final seenNames = <String>{};
    final distinctRecent = <Meal>[];
    for (final meal in allMeals) {
      final normalized = meal.name.trim().toLowerCase();
      if (normalized.isNotEmpty && !seenNames.contains(normalized)) {
        seenNames.add(normalized);
        distinctRecent.add(meal);
        if (distinctRecent.length >= 8) break;
      }
    }

    return distinctRecent;
  } catch (e) {
    if (kDebugMode) {
      AppLogger.debug('⚠️ [Nutrition] Error fetching recent foods: $e');
    }
    return <Meal>[];
  }
});

// ---------------------------------------------------------------------------
// Meal suggestions provider
// ---------------------------------------------------------------------------

/// Provides meal suggestions based on macro targets.
///
/// Parameters:
/// - targetCalories: Target calories for the meal
/// - targetProtein: Target protein in grams
/// - targetCarbs: Target carbs in grams
/// - targetFat: Target fat in grams
final mealSuggestionsProvider = FutureProvider.family<
    List<FoodItemFull>,
    ({
      double targetCalories,
      double targetProtein,
      double targetCarbs,
      double targetFat,
    })>((ref, params) async {
  try {
    AppLogger.debug('📊 [Nutrition] Calculating meal suggestions...');
    AppLogger.debug('🔍 [Nutrition] Target - Calories: ${params.targetCalories}, Protein: ${params.targetProtein}g, Carbs: ${params.targetCarbs}g, Fat: ${params.targetFat}g');
    
    final useCase = ref.watch(getMealSuggestionsUseCaseProvider);
    final suggestions = await useCase(
      targetCalories: params.targetCalories,
      targetProtein: params.targetProtein,
      targetCarbs: params.targetCarbs,
      targetFat: params.targetFat,
    );
    
    AppLogger.debug('✅ [Nutrition] Meal suggestions calculated successfully');
    AppLogger.debug('🔍 [Nutrition] Found ${suggestions.length} suggestions');
    
    return suggestions;
  } catch (e, stackTrace) {
    AppLogger.debug('❌ [Nutrition] Failed to calculate meal suggestions: $e');
    AppLogger.debug('🔍 [Nutrition] Stack trace: $stackTrace');
    rethrow;
  }
});

// ---------------------------------------------------------------------------
// Food search provider
// ---------------------------------------------------------------------------

/// Provides filtered foods based on search query.
final foodSearchProvider =
    FutureProvider.family<List<FoodItemFull>, String>((ref, query) async {
  try {
    AppLogger.debug('📊 [Nutrition] Searching for foods...');
    AppLogger.debug('🔍 [Nutrition] Query: "$query"');
    
    final repository = ref.watch(foodRepositoryProvider);
    final List<FoodItemFull> results;
    
    if (query.isEmpty) {
      AppLogger.debug('📊 [Nutrition] Empty query, fetching all foods...');
      results = await repository.getAllFoods();
    } else {
      results = await repository.searchFoods(query);
    }
    
    AppLogger.debug('✅ [Nutrition] Food search completed successfully');
    AppLogger.debug('🔍 [Nutrition] Found ${results.length} foods');
    
    return results;
  } catch (e, stackTrace) {
    AppLogger.debug('❌ [Nutrition] Failed to search foods: $e');
    AppLogger.debug('🔍 [Nutrition] Stack trace: $stackTrace');
    rethrow;
  }
});

// ---------------------------------------------------------------------------
// Food filter provider
// ---------------------------------------------------------------------------

enum MealType { breakfast, lunch, dinner, snack }

enum DietaryPreference { vegetarian, vegan, glutenFree, dairyFree }

/// Provides filtered foods based on meal type and dietary preferences.
final foodFilterProvider = FutureProvider.family<
    List<FoodItemFull>,
    ({
      MealType? mealType,
      List<DietaryPreference> dietaryPreferences,
    })>((ref, params) async {
  try {
    AppLogger.debug('📊 [Nutrition] Filtering foods...');
    AppLogger.debug('🔍 [Nutrition] Meal type: ${params.mealType}, Dietary preferences: ${params.dietaryPreferences.length}');
    
    final repository = ref.watch(foodRepositoryProvider);
    final allFoods = await repository.getAllFoods();
    
    AppLogger.debug('📊 [Nutrition] Applying filters to ${allFoods.length} foods...');

    final filtered = allFoods.where((food) {
      // Filter by meal type if specified
      if (params.mealType != null) {
        final mealTypeStr = params.mealType.toString().split('.').last;
        if (food.category.toLowerCase() != mealTypeStr.toLowerCase()) {
          return false;
        }
      }

      // Filter by dietary preferences
      for (final pref in params.dietaryPreferences) {
        final prefStr = pref.toString().split('.').last;
        if (!food.dietaryTags.contains(prefStr)) {
          return false;
        }
      }

      return true;
    }).toList();
    
    AppLogger.debug('✅ [Nutrition] Food filtering completed successfully');
    AppLogger.debug('🔍 [Nutrition] Filtered to ${filtered.length} foods');

    return filtered;
  } catch (e, stackTrace) {
    AppLogger.debug('❌ [Nutrition] Failed to filter foods: $e');
    AppLogger.debug('🔍 [Nutrition] Stack trace: $stackTrace');
    rethrow;
  }
});

// ---------------------------------------------------------------------------
// Food alternatives provider
// ---------------------------------------------------------------------------

/// Provides food alternatives for a given food.
/// Returns alternatives with similar macros (within 10% tolerance).
///
/// **Validates: Requirements 3.3**
final foodAlternativesProvider = FutureProvider.family<
    List<FoodAlternative>,
    FoodItemFull>((ref, targetFood) async {
  try {
    AppLogger.debug('📊 [Nutrition] Finding food alternatives...');
    AppLogger.debug('🔍 [Nutrition] Target food: ${targetFood.name}');
    AppLogger.debug('🔍 [Nutrition] Target macros - Calories: ${targetFood.macros.calories}, Protein: ${targetFood.macros.protein}g, Carbs: ${targetFood.macros.carbs}g, Fat: ${targetFood.macros.fats}g');
    
    final useCase = ref.watch(getFoodAlternativesUseCaseProvider);
    final alternatives = await useCase.getAlternatives(targetFood);
    
    AppLogger.debug('✅ [Nutrition] Food alternatives found successfully');
    AppLogger.debug('🔍 [Nutrition] Found ${alternatives.length} alternatives');
    
    return alternatives;
  } catch (e, stackTrace) {
    AppLogger.debug('❌ [Nutrition] Failed to find food alternatives: $e');
    AppLogger.debug('🔍 [Nutrition] Stack trace: $stackTrace');
    rethrow;
  }
});
