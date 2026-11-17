import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/nutrition_targets.dart';
import '../../domain/repositories/food_repository.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../../../../shared/presentation/services/app_haptics.dart';
import 'food_repository_provider.dart';
import 'nutrition_providers.dart' show nutritionRepositoryProvider;
import 'nutrition_state.dart';

/// Unified Nutrition Notifier - Single Source of Truth
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
class NutritionNotifier extends Notifier<NutritionState> {
  NutritionNotifier([
    this._injectedNutritionRepository,
    this._injectedFoodRepository,
  ]);

  final NutritionRepository? _injectedNutritionRepository;
  final FoodRepository? _injectedFoodRepository;

  late NutritionRepository _nutritionRepository;
  late FoodRepository _foodRepository;
  bool _disposed = false;

  @override
  NutritionState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
    });
    _nutritionRepository =
        _injectedNutritionRepository ?? ref.watch(nutritionRepositoryProvider);
    _foodRepository =
        _injectedFoodRepository ?? ref.watch(foodRepositoryProvider);
    final initialDate = _today();
    _initialize(emitLoading: false, targetDate: initialDate);
    return NutritionState(currentDate: initialDate, isLoading: true);
  }
  
  /// Get today's date with time zeroed out
  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  
  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------
  
  /// Initialize: Load all data in parallel
  Future<void> _initialize({bool emitLoading = true, DateTime? targetDate}) async {
    if (emitLoading && !_disposed) {
      state = state.copyWith(isLoading: true, error: null);
    }
    final dateToLoad = targetDate ?? state.currentDate;
    
    try {
      if (kDebugMode) {
        AppLogger.debug('📊 [Nutrition] Initializing nutrition state...');
      }
      
      // Load all data in parallel for better performance
      final results = await Future.wait([
        _foodRepository.getAllFoods(),
        _foodRepository.getCustomFoods(),
        _nutritionRepository.getMealsByDate(dateToLoad),
        _nutritionRepository.getNutritionTargets(),
      ]);
      if (_disposed) return;
      
      final allFoods = results[0] as List<FoodItem>;
      final customFoods = results[1] as List<FoodItem>;
      final todayMeals = results[2] as List<Meal>;
      final targets = results[3] as NutritionTargets?;
      
      if (kDebugMode) {
        AppLogger.debug('✅ [Nutrition] Initialization complete');
        AppLogger.debug('🔍 [Nutrition] Loaded ${allFoods.length} foods, ${customFoods.length} custom foods, ${todayMeals.length} meals');
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
        AppLogger.debug('❌ [Nutrition] Initialization failed: $e');
        AppLogger.debug('🔍 [Nutrition] Stack trace: $stackTrace');
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
        AppLogger.debug('📊 [Nutrition] Adding meal: ${meal.name}');
        AppLogger.debug('🔍 [Nutrition] Macros - Calories: ${meal.calories}, Protein: ${meal.protein}g, Carbs: ${meal.carbs}g, Fats: ${meal.fats}g');
      }
      
      // 1. Save to repository (offline-first)
      await _nutritionRepository.saveMealEntry(meal);
      
      if (kDebugMode) {
        AppLogger.debug('✅ [Nutrition] Meal saved to repository');
      }
      
      final prevProtein = state.totalProtein;
      final prevCalories = state.totalCalories;
      final prevCarbs = state.totalCarbs;
      final prevFats = state.totalFats;
      final targets = state.targets;

      // 2. Update state IMMEDIATELY (immutable - create new list)
      state = state.copyWith(
        todayMeals: [...state.todayMeals, meal],
        error: null,
      );
      
      // Check for macro milestones achieved on this meal addition
      if (targets != null) {
        final macros = targets.macros;
        if (prevProtein < macros.protein && state.totalProtein >= macros.protein) {
          AppHaptics.shared.milestoneReached(milestoneId: 'protein', date: state.currentDate);
        }
        if (prevCalories < macros.calories && state.totalCalories >= macros.calories) {
          AppHaptics.shared.milestoneReached(milestoneId: 'calories', date: state.currentDate);
        }
        if (prevCarbs < macros.carbs && state.totalCarbs >= macros.carbs) {
          AppHaptics.shared.milestoneReached(milestoneId: 'carbs', date: state.currentDate);
        }
        if (prevFats < macros.fats && state.totalFats >= macros.fats) {
          AppHaptics.shared.milestoneReached(milestoneId: 'fats', date: state.currentDate);
        }
      }
      
      if (kDebugMode) {
        AppLogger.debug('✅ [Nutrition] State updated with new meal');
        AppLogger.debug('🔍 [Nutrition] Total meals: ${state.todayMeals.length}');
        AppLogger.debug('🔍 [Nutrition] Total calories: ${state.totalCalories}');
      }
      
      // Totals recalculate automatically via computed properties
      // UI rebuilds automatically via ref.watch
    } catch (e, stackTrace) {
      if (kDebugMode) {
        AppLogger.debug('❌ [Nutrition] Failed to add meal: $e');
        AppLogger.debug('🔍 [Nutrition] Stack trace: $stackTrace');
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
        AppLogger.debug('📊 [Nutrition] Deleting meal: $mealId');
      }
      
      // 1. Delete from repository
      await _nutritionRepository.deleteMealEntry(mealId);
      
      if (kDebugMode) {
        AppLogger.debug('✅ [Nutrition] Meal deleted from repository');
      }
      
      // 2. Update state IMMEDIATELY (immutable - create new list)
      state = state.copyWith(
        todayMeals: state.todayMeals.where((m) => m.id != mealId).toList(),
        error: null,
      );
      
      if (kDebugMode) {
        AppLogger.debug('✅ [Nutrition] State updated after deletion');
        AppLogger.debug('🔍 [Nutrition] Remaining meals: ${state.todayMeals.length}');
        AppLogger.debug('🔍 [Nutrition] Total calories: ${state.totalCalories}');
      }
      
      // Totals recalculate automatically via computed properties
      // UI rebuilds automatically via ref.watch
    } catch (e, stackTrace) {
      if (kDebugMode) {
        AppLogger.debug('❌ [Nutrition] Failed to delete meal: $e');
        AppLogger.debug('🔍 [Nutrition] Stack trace: $stackTrace');
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
  Future<void> addCustomFood(FoodItem food) async {
    try {
      if (kDebugMode) {
        AppLogger.debug('📊 [Nutrition] Adding custom food: ${food.name}');
        AppLogger.debug('🔍 [Nutrition] Macros - Calories: ${food.caloriesPer100g}, Protein: ${food.proteinPer100g}g, Carbs: ${food.carbsPer100g}g, Fats: ${food.fatPer100g}g');
      }
      
      // 1. Validate
      if (food.name.trim().isEmpty) {
        throw Exception('Food name cannot be empty');
      }
      
      if (food.caloriesPer100g < 0 || food.proteinPer100g < 0 || 
          food.carbsPer100g < 0 || food.fatPer100g < 0) {
        throw Exception('Macros must be positive numbers');
      }
      
      // 2. Save to repository
      await _foodRepository.saveCustomFood(food);
      
      if (kDebugMode) {
        AppLogger.debug('✅ [Nutrition] Custom food saved to repository');
      }
      
      // 3. Update state IMMEDIATELY (immutable - create new list)
      state = state.copyWith(
        customFoods: [...state.customFoods, food],
        error: null,
      );
      
      if (kDebugMode) {
        AppLogger.debug('✅ [Nutrition] State updated with new custom food');
        AppLogger.debug('🔍 [Nutrition] Total custom foods: ${state.customFoods.length}');
        AppLogger.debug('🔍 [Nutrition] Total searchable foods: ${state.searchableFoods.length}');
      }
      
      // Food now appears in searchableFoods automatically
      // UI rebuilds automatically via ref.watch
    } catch (e, stackTrace) {
      if (kDebugMode) {
        AppLogger.debug('❌ [Nutrition] Failed to add custom food: $e');
        AppLogger.debug('🔍 [Nutrition] Stack trace: $stackTrace');
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
        AppLogger.debug('📊 [Nutrition] Deleting custom food: $id');
      }
      
      // 1. Delete from repository
      await _foodRepository.deleteCustomFood(id);
      
      if (kDebugMode) {
        AppLogger.debug('✅ [Nutrition] Custom food deleted from repository');
      }
      
      // 2. Update state IMMEDIATELY (immutable - create new list)
      state = state.copyWith(
        customFoods: state.customFoods.where((f) => f.id != id).toList(),
        error: null,
      );
      
      if (kDebugMode) {
        AppLogger.debug('✅ [Nutrition] State updated after deletion');
        AppLogger.debug('🔍 [Nutrition] Remaining custom foods: ${state.customFoods.length}');
      }
      
      // Food disappears from searchableFoods automatically
      // UI rebuilds automatically via ref.watch
    } catch (e, stackTrace) {
      if (kDebugMode) {
        AppLogger.debug('❌ [Nutrition] Failed to delete custom food: $e');
        AppLogger.debug('🔍 [Nutrition] Stack trace: $stackTrace');
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
  List<FoodItem> searchFoods(String query) {
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
  List<FoodItem> filterByCategory(String? category) {
    if (category == null || category.isEmpty) {
      return state.searchableFoods;
    }
    
    final lowerCategory = category.toLowerCase();
    return state.searchableFoods
        .where(
          (f) =>
              f.categoryName.toLowerCase() == lowerCategory ||
              f.category.name == lowerCategory,
        )
        .toList();
  }
  
  /// Search and filter foods (local, instant)
  /// 
  /// Combines search query and category filter
  /// Returns results immediately (no async)
  List<FoodItem> searchAndFilter({
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
          .where(
            (f) =>
                f.categoryName.toLowerCase() == lowerCategory ||
                f.category.name == lowerCategory,
          )
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
        AppLogger.debug('📊 [Nutrition] Changing date to: ${normalizedDate.toIso8601String().split('T')[0]}');
      }
      
      // Load meals for new date
      final meals = await _nutritionRepository.getMealsByDate(normalizedDate);
      
      if (kDebugMode) {
        AppLogger.debug('✅ [Nutrition] Loaded ${meals.length} meals for new date');
      }
      
      state = state.copyWith(
        todayMeals: meals,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        AppLogger.debug('❌ [Nutrition] Failed to change date: $e');
        AppLogger.debug('🔍 [Nutrition] Stack trace: $stackTrace');
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
        AppLogger.debug('📊 [Nutrition] Updating nutrition targets');
        AppLogger.debug('🔍 [Nutrition] Calories: ${targets.macros.calories}, Protein: ${targets.macros.protein}g, Carbs: ${targets.macros.carbs}g, Fats: ${targets.macros.fats}g');
      }
      
      // Save to repository
      await _nutritionRepository.saveNutritionTargets(targets);
      
      if (kDebugMode) {
        AppLogger.debug('✅ [Nutrition] Targets saved to repository');
      }
      
      // Update state immediately
      state = state.copyWith(
        targets: targets,
        error: null,
      );
      
      if (kDebugMode) {
        AppLogger.debug('✅ [Nutrition] State updated with new targets');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        AppLogger.debug('❌ [Nutrition] Failed to update targets: $e');
        AppLogger.debug('🔍 [Nutrition] Stack trace: $stackTrace');
      }
      
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

final nutritionNotifierProvider =
    NotifierProvider<NutritionNotifier, NutritionState>(NutritionNotifier.new);
