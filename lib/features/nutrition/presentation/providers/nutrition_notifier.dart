import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/food_item_full.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/nutrition_targets.dart';
import '../../domain/repositories/food_repository.dart';
import '../../domain/repositories/nutrition_repository.dart';
import 'nutrition_state.dart';

/// Unified Nutrition State Notifier - Single Source of Truth
/// 
/// This notifier manages ALL nutrition state:
/// - Loading all foods (preloaded + custom)
/// - Adding/deleting meals
/// - Adding/deleting custom foods
/// - Calculating totals and remaining macros
/// 
/// Key Principles:
/// 1. IMMUTABILITY: Never mutate state, always use copyWith
/// 2. INSTANT UPDATES: UI rebuilds automatically via ref.watch
/// 3. SINGLE SOURCE OF TRUTH: All nutrition data in one place
/// 4. OFFLINE-FIRST: Save to local storage immediately
class NutritionNotifier extends StateNotifier<NutritionState> {
  NutritionNotifier(
    this._nutritionRepository,
    this._foodRepository,
  ) : super(NutritionState(currentDate: _today())) {
    _initialize();
  }
  
  final NutritionRepository _nutritionRepository;
  final FoodRepository _foodRepository;
  
  /// Get today's date with time zeroed out
  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  
  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------
  
  /// Initialize: Load all data in parallel
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      if (kDebugMode) {
        print('📊 [Nutrition] Initializing nutrition state...');
      }
      
      // Load all data in parallel for better performance
      final results = await Future.wait([
        _foodRepository.getAllFoods(),
        _foodRepository.getCustomFoods(),
        _nutritionRepository.getMealsByDate(state.currentDate),
        _nutritionRepository.getNutritionTargets(),
      ]);
      
      final allFoods = results[0] as List<FoodItemFull>;
      final customFoods = results[1] as List<FoodItemFull>;
      final todayMeals = results[2] as List<Meal>;
      final targets = results[3] as NutritionTargets?;
      
      if (kDebugMode) {
        print('✅ [Nutrition] Initialization complete');
        print('🔍 [Nutrition] Loaded ${allFoods.length} foods, ${customFoods.length} custom foods, ${todayMeals.length} meals');
      }
      
      state = state.copyWith(
        allFoods: allFoods,
        customFoods: customFoods,
        todayMeals: todayMeals,
        targets: targets,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [Nutrition] Initialization failed: $e');
        print('🔍 [Nutrition] Stack trace: $stackTrace');
      }
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  // ---------------------------------------------------------------------------
  // Meal Operations
  // ---------------------------------------------------------------------------
  
  /// Add a meal - INSTANT UI UPDATE
  /// 
  /// Flow:
  /// 1. Validate meal
  /// 2. Save to repository (Hive)
  /// 3. Update state immediately (immutable)
  /// 4. UI rebuilds automatically
  /// 5. Totals recalculate via computed properties
  Future<void> addMeal(Meal meal) async {
    try {
      if (kDebugMode) {
        print('📊 [Nutrition] Adding meal: ${meal.name}');
        print('🔍 [Nutrition] Macros - Calories: ${meal.calories}, Protein: ${meal.protein}g, Carbs: ${meal.carbs}g, Fats: ${meal.fats}g');
      }
      
      // 1. Save to repository (offline-first)
      await _nutritionRepository.saveMealEntry(meal);
      
      if (kDebugMode) {
        print('✅ [Nutrition] Meal saved to repository');
      }
      
      // 2. Update state IMMEDIATELY (immutable - create new list)
      state = state.copyWith(
        todayMeals: [...state.todayMeals, meal],
        error: null,
      );
      
      if (kDebugMode) {
        print('✅ [Nutrition] State updated with new meal');
        print('🔍 [Nutrition] Total meals: ${state.todayMeals.length}');
        print('🔍 [Nutrition] Total calories: ${state.totalCalories}');
      }
      
      // Totals recalculate automatically via computed properties
      // UI rebuilds automatically via ref.watch
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [Nutrition] Failed to add meal: $e');
        print('🔍 [Nutrition] Stack trace: $stackTrace');
      }
      
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
  
  /// Delete a meal - INSTANT UI UPDATE
  /// 
  /// Flow:
  /// 1. Delete from repository (Hive)
  /// 2. Update state immediately (immutable)
  /// 3. UI rebuilds automatically
  /// 4. Totals recalculate via computed properties
  Future<void> deleteMeal(String mealId) async {
    try {
      if (kDebugMode) {
        print('📊 [Nutrition] Deleting meal: $mealId');
      }
      
      // 1. Delete from repository
      await _nutritionRepository.deleteMealEntry(mealId);
      
      if (kDebugMode) {
        print('✅ [Nutrition] Meal deleted from repository');
      }
      
      // 2. Update state IMMEDIATELY (immutable - create new list)
      state = state.copyWith(
        todayMeals: state.todayMeals.where((m) => m.id != mealId).toList(),
        error: null,
      );
      
      if (kDebugMode) {
        print('✅ [Nutrition] State updated after deletion');
        print('🔍 [Nutrition] Remaining meals: ${state.todayMeals.length}');
        print('🔍 [Nutrition] Total calories: ${state.totalCalories}');
      }
      
      // Totals recalculate automatically via computed properties
      // UI rebuilds automatically via ref.watch
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [Nutrition] Failed to delete meal: $e');
        print('🔍 [Nutrition] Stack trace: $stackTrace');
      }
      
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
  
  // ---------------------------------------------------------------------------
  // Custom Food Operations
  // ---------------------------------------------------------------------------
  
  /// Add a custom food - INSTANT UI UPDATE
  /// 
  /// Flow:
  /// 1. Validate input
  /// 2. Save to repository (Hive)
  /// 3. Update state immediately (immutable)
  /// 4. Food appears in search instantly
  Future<void> addCustomFood(FoodItemFull food) async {
    try {
      if (kDebugMode) {
        print('📊 [Nutrition] Adding custom food: ${food.name}');
        print('🔍 [Nutrition] Macros - Calories: ${food.macros.calories}, Protein: ${food.macros.protein}g, Carbs: ${food.macros.carbs}g, Fats: ${food.macros.fats}g');
      }
      
      // 1. Validate
      if (food.name.trim().isEmpty) {
        throw Exception('Food name cannot be empty');
      }
      
      if (food.macros.calories < 0 || food.macros.protein < 0 || 
          food.macros.carbs < 0 || food.macros.fats < 0) {
        throw Exception('Macros must be positive numbers');
      }
      
      // 2. Save to repository
      await _foodRepository.saveCustomFood(food);
      
      if (kDebugMode) {
        print('✅ [Nutrition] Custom food saved to repository');
      }
      
      // 3. Update state IMMEDIATELY (immutable - create new list)
      state = state.copyWith(
        customFoods: [...state.customFoods, food],
        error: null,
      );
      
      if (kDebugMode) {
        print('✅ [Nutrition] State updated with new custom food');
        print('🔍 [Nutrition] Total custom foods: ${state.customFoods.length}');
        print('🔍 [Nutrition] Total searchable foods: ${state.searchableFoods.length}');
      }
      
      // Food now appears in searchableFoods automatically
      // UI rebuilds automatically via ref.watch
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [Nutrition] Failed to add custom food: $e');
        print('🔍 [Nutrition] Stack trace: $stackTrace');
      }
      
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
  
  /// Delete a custom food - INSTANT UI UPDATE
  /// 
  /// Flow:
  /// 1. Delete from repository (Hive)
  /// 2. Update state immediately (immutable)
  /// 3. Food disappears from search instantly
  Future<void> deleteCustomFood(String id) async {
    try {
      if (kDebugMode) {
        print('📊 [Nutrition] Deleting custom food: $id');
      }
      
      // 1. Delete from repository
      await _foodRepository.deleteCustomFood(id);
      
      if (kDebugMode) {
        print('✅ [Nutrition] Custom food deleted from repository');
      }
      
      // 2. Update state IMMEDIATELY (immutable - create new list)
      state = state.copyWith(
        customFoods: state.customFoods.where((f) => f.id != id).toList(),
        error: null,
      );
      
      if (kDebugMode) {
        print('✅ [Nutrition] State updated after deletion');
        print('🔍 [Nutrition] Remaining custom foods: ${state.customFoods.length}');
      }
      
      // Food disappears from searchableFoods automatically
      // UI rebuilds automatically via ref.watch
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [Nutrition] Failed to delete custom food: $e');
        print('🔍 [Nutrition] Stack trace: $stackTrace');
      }
      
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
  
  // ---------------------------------------------------------------------------
  // Search & Filter Operations (Local, Instant)
  // ---------------------------------------------------------------------------
  
  /// Search foods by name (local, instant)
  /// 
  /// Searches in both preloaded and custom foods
  /// Returns results immediately (no async)
  List<FoodItemFull> searchFoods(String query) {
    if (query.isEmpty) {
      return state.searchableFoods;
    }
    
    final lowerQuery = query.toLowerCase();
    return state.searchableFoods
        .where((f) => f.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
  
  /// Filter foods by category (local, instant)
  /// 
  /// Returns results immediately (no async)
  List<FoodItemFull> filterByCategory(String? category) {
    if (category == null || category.isEmpty) {
      return state.searchableFoods;
    }
    
    final lowerCategory = category.toLowerCase();
    return state.searchableFoods
        .where((f) => f.category.toLowerCase() == lowerCategory)
        .toList();
  }
  
  /// Search and filter foods (local, instant)
  /// 
  /// Combines search query and category filter
  /// Returns results immediately (no async)
  List<FoodItemFull> searchAndFilter({
    String? query,
    String? category,
  }) {
    var results = state.searchableFoods;
    
    // Apply search query
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      results = results
          .where((f) => f.name.toLowerCase().contains(lowerQuery))
          .toList();
    }
    
    // Apply category filter
    if (category != null && category.isNotEmpty) {
      final lowerCategory = category.toLowerCase();
      results = results
          .where((f) => f.category.toLowerCase() == lowerCategory)
          .toList();
    }
    
    return results;
  }
  
  // ---------------------------------------------------------------------------
  // Refresh Operations
  // ---------------------------------------------------------------------------
  
  /// Refresh all data from repository
  Future<void> refresh() async {
    await _initialize();
  }
  
  /// Change current date and reload meals
  Future<void> changeDate(DateTime newDate) async {
    final normalizedDate = DateTime(newDate.year, newDate.month, newDate.day);
    
    if (normalizedDate == state.currentDate) {
      return; // Already on this date
    }
    
    state = state.copyWith(
      currentDate: normalizedDate,
      isLoading: true,
      error: null,
    );
    
    try {
      if (kDebugMode) {
        print('📊 [Nutrition] Changing date to: ${normalizedDate.toIso8601String().split('T')[0]}');
      }
      
      // Load meals for new date
      final meals = await _nutritionRepository.getMealsByDate(normalizedDate);
      
      if (kDebugMode) {
        print('✅ [Nutrition] Loaded ${meals.length} meals for new date');
      }
      
      state = state.copyWith(
        todayMeals: meals,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [Nutrition] Failed to change date: $e');
        print('🔍 [Nutrition] Stack trace: $stackTrace');
      }
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  // ---------------------------------------------------------------------------
  // Targets Operations
  // ---------------------------------------------------------------------------
  
  /// Update nutrition targets
  Future<void> updateTargets(NutritionTargets targets) async {
    try {
      if (kDebugMode) {
        print('📊 [Nutrition] Updating nutrition targets');
        print('🔍 [Nutrition] Calories: ${targets.macros.calories}, Protein: ${targets.macros.protein}g, Carbs: ${targets.macros.carbs}g, Fats: ${targets.macros.fats}g');
      }
      
      // Save to repository
      await _nutritionRepository.saveNutritionTargets(targets);
      
      if (kDebugMode) {
        print('✅ [Nutrition] Targets saved to repository');
      }
      
      // Update state immediately
      state = state.copyWith(
        targets: targets,
        error: null,
      );
      
      if (kDebugMode) {
        print('✅ [Nutrition] State updated with new targets');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [Nutrition] Failed to update targets: $e');
        print('🔍 [Nutrition] Stack trace: $stackTrace');
      }
      
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}
