import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/firestore_nutrition_datasource.dart';
import '../../data/datasources/hive_nutrition_datasource.dart';
import '../../data/repositories/nutrition_repository_impl.dart';
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
  final firestoreDataSource = FirestoreNutritionDatasource(FirebaseFirestore.instance);
  final hiveDataSource = HiveNutritionDatasource();
  // TODO: Get userId from auth provider
  const userId = 'test-user';
  return NutritionRepositoryImpl(
    firestoreDataSource: firestoreDataSource,
    hiveDataSource: hiveDataSource,
    userId: userId,
  );
});

// ---------------------------------------------------------------------------
// Food repository provider
// ---------------------------------------------------------------------------

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return repository as FoodRepository;
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
        print('📊 [Nutrition] Fetching daily nutrition summary...');
        print('🔍 [Nutrition] Date: ${_date.toIso8601String().split('T')[0]}');
      }
      
      final summary = await _repository.getDailyNutrition(_date);
      
      if (kDebugMode) {
        print('✅ [Nutrition] Daily nutrition summary retrieved successfully');
        print('🔍 [Nutrition] Total calories: ${summary.totalCalories}, Meals: ${summary.meals.length}');
      }
      
      state = AsyncValue.data(summary);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [Nutrition] Failed to fetch daily nutrition summary: $e');
        print('🔍 [Nutrition] Stack trace: $stackTrace');
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Add a meal and update state immediately
  Future<void> addMeal(Meal meal) async {
    try {
      if (kDebugMode) {
        print('📊 [Nutrition] Adding meal: ${meal.name}');
      }
      
      // Save to repository
      await _repository.saveMealEntry(meal);
      
      if (kDebugMode) {
        print('✅ [Nutrition] Meal saved to repository');
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
          print('✅ [Nutrition] State updated with new meal');
          print('🔍 [Nutrition] Total meals: ${updatedMeals.length}');
        }
        
        state = AsyncValue.data(updatedSummary);
      });
      
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
          print('📊 [Analytics] Meal logged event tracked');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [Analytics] Failed to log meal event: $e');
        }
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [Nutrition] Failed to add meal: $e');
      }
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Delete a meal and update state immediately
  Future<void> deleteMeal(String mealId) async {
    try {
      if (kDebugMode) {
        print('📊 [Nutrition] Deleting meal: $mealId');
      }
      
      // Delete from repository
      await _repository.deleteMealEntry(mealId);
      
      if (kDebugMode) {
        print('✅ [Nutrition] Meal deleted from repository');
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
          print('✅ [Nutrition] State updated after deletion');
          print('🔍 [Nutrition] Remaining meals: ${updatedMeals.length}');
        }
        
        state = AsyncValue.data(updatedSummary);
      });
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [Nutrition] Failed to delete meal: $e');
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
    print('📊 [Nutrition] Calculating meal suggestions...');
    print('🔍 [Nutrition] Target - Calories: ${params.targetCalories}, Protein: ${params.targetProtein}g, Carbs: ${params.targetCarbs}g, Fat: ${params.targetFat}g');
    
    final useCase = ref.watch(getMealSuggestionsUseCaseProvider);
    final suggestions = await useCase(
      targetCalories: params.targetCalories,
      targetProtein: params.targetProtein,
      targetCarbs: params.targetCarbs,
      targetFat: params.targetFat,
    );
    
    print('✅ [Nutrition] Meal suggestions calculated successfully');
    print('🔍 [Nutrition] Found ${suggestions.length} suggestions');
    
    return suggestions;
  } catch (e, stackTrace) {
    print('❌ [Nutrition] Failed to calculate meal suggestions: $e');
    print('🔍 [Nutrition] Stack trace: $stackTrace');
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
    print('📊 [Nutrition] Searching for foods...');
    print('🔍 [Nutrition] Query: "$query"');
    
    final repository = ref.watch(foodRepositoryProvider);
    final List<FoodItemFull> results;
    
    if (query.isEmpty) {
      print('📊 [Nutrition] Empty query, fetching all foods...');
      results = await repository.getAllFoods();
    } else {
      results = await repository.searchFoods(query);
    }
    
    print('✅ [Nutrition] Food search completed successfully');
    print('🔍 [Nutrition] Found ${results.length} foods');
    
    return results;
  } catch (e, stackTrace) {
    print('❌ [Nutrition] Failed to search foods: $e');
    print('🔍 [Nutrition] Stack trace: $stackTrace');
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
    print('📊 [Nutrition] Filtering foods...');
    print('🔍 [Nutrition] Meal type: ${params.mealType}, Dietary preferences: ${params.dietaryPreferences.length}');
    
    final repository = ref.watch(foodRepositoryProvider);
    final allFoods = await repository.getAllFoods();
    
    print('📊 [Nutrition] Applying filters to ${allFoods.length} foods...');

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
    
    print('✅ [Nutrition] Food filtering completed successfully');
    print('🔍 [Nutrition] Filtered to ${filtered.length} foods');

    return filtered;
  } catch (e, stackTrace) {
    print('❌ [Nutrition] Failed to filter foods: $e');
    print('🔍 [Nutrition] Stack trace: $stackTrace');
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
    print('📊 [Nutrition] Finding food alternatives...');
    print('🔍 [Nutrition] Target food: ${targetFood.name}');
    print('🔍 [Nutrition] Target macros - Calories: ${targetFood.macros.calories}, Protein: ${targetFood.macros.protein}g, Carbs: ${targetFood.macros.carbs}g, Fat: ${targetFood.macros.fats}g');
    
    final useCase = ref.watch(getFoodAlternativesUseCaseProvider);
    final alternatives = await useCase.getAlternatives(targetFood);
    
    print('✅ [Nutrition] Food alternatives found successfully');
    print('🔍 [Nutrition] Found ${alternatives.length} alternatives');
    
    return alternatives;
  } catch (e, stackTrace) {
    print('❌ [Nutrition] Failed to find food alternatives: $e');
    print('🔍 [Nutrition] Stack trace: $stackTrace');
    rethrow;
  }
});
