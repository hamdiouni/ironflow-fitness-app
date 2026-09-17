import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/food_item_full.dart';
import '../../domain/entities/meal.dart';
import '../../domain/entities/nutrition_targets.dart';

part 'nutrition_state.freezed.dart';

/// Unified nutrition state - Single Source of Truth
/// 
/// This state contains ALL nutrition-related data:
/// - All foods (preloaded + custom)
/// - Today's meals
/// - Daily targets
/// - Loading/error states
/// 
/// All computed properties (totals, remaining) are calculated on-demand
/// to ensure consistency and avoid stale data.
@freezed
class NutritionState with _$NutritionState {
  const factory NutritionState({
    /// All preloaded foods from database
    @Default([]) List<FoodItemFull> allFoods,
    
    /// User-created custom foods
    @Default([]) List<FoodItemFull> customFoods,
    
    /// Today's logged meals
    @Default([]) List<Meal> todayMeals,
    
    /// Current date being viewed
    required DateTime currentDate,
    
    /// Daily nutrition targets (calories, macros)
    NutritionTargets? targets,
    
    /// Loading state
    @Default(false) bool isLoading,
    
    /// Error message (null if no error)
    String? error,
  }) = _NutritionState;
  
  const NutritionState._();
  
  // ---------------------------------------------------------------------------
  // Computed Properties (Totals)
  // ---------------------------------------------------------------------------
  
  /// Total calories consumed today
  double get totalCalories => todayMeals.fold(0.0, (sum, m) => sum + m.calories);
  
  /// Total protein consumed today (grams)
  double get totalProtein => todayMeals.fold(0.0, (sum, m) => sum + m.protein);
  
  /// Total carbs consumed today (grams)
  double get totalCarbs => todayMeals.fold(0.0, (sum, m) => sum + m.carbs);
  
  /// Total fats consumed today (grams)
  double get totalFats => todayMeals.fold(0.0, (sum, m) => sum + m.fats);
  
  // ---------------------------------------------------------------------------
  // Computed Properties (Remaining)
  // ---------------------------------------------------------------------------
  
  /// Remaining calories (target - consumed)
  double get remainingCalories {
    final target = targets?.macros.calories ?? 2000;
    return target - totalCalories;
  }
  
  /// Remaining protein (target - consumed)
  double get remainingProtein {
    final target = targets?.macros.protein ?? 150;
    return target - totalProtein;
  }
  
  /// Remaining carbs (target - consumed)
  double get remainingCarbs {
    final target = targets?.macros.carbs ?? 200;
    return target - totalCarbs;
  }
  
  /// Remaining fats (target - consumed)
  double get remainingFats {
    final target = targets?.macros.fats ?? 60;
    return target - totalFats;
  }
  
  // ---------------------------------------------------------------------------
  // Computed Properties (Combined Lists)
  // ---------------------------------------------------------------------------
  
  /// All searchable foods (preloaded + custom)
  /// This is the list used for food search
  List<FoodItemFull> get searchableFoods => [...allFoods, ...customFoods];
  
  /// Number of meals logged today
  int get mealCount => todayMeals.length;
  
  /// Whether any meals have been logged today
  bool get hasMeals => todayMeals.isNotEmpty;
  
  /// Whether custom foods exist
  bool get hasCustomFoods => customFoods.isNotEmpty;
  
  // ---------------------------------------------------------------------------
  // Computed Properties (Progress)
  // ---------------------------------------------------------------------------
  
  /// Calorie progress (0.0 to 1.0+)
  double get calorieProgress {
    final target = targets?.macros.calories ?? 2000;
    if (target == 0) return 0.0;
    return (totalCalories / target).clamp(0.0, 2.0);
  }
  
  /// Protein progress (0.0 to 1.0+)
  double get proteinProgress {
    final target = targets?.macros.protein ?? 150;
    if (target == 0) return 0.0;
    return (totalProtein / target).clamp(0.0, 2.0);
  }
  
  /// Carbs progress (0.0 to 1.0+)
  double get carbsProgress {
    final target = targets?.macros.carbs ?? 200;
    if (target == 0) return 0.0;
    return (totalCarbs / target).clamp(0.0, 2.0);
  }
  
  /// Fats progress (0.0 to 1.0+)
  double get fatsProgress {
    final target = targets?.macros.fats ?? 60;
    if (target == 0) return 0.0;
    return (totalFats / target).clamp(0.0, 2.0);
  }
  
  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------
  
  /// Check if a food ID exists in custom foods
  bool hasCustomFood(String id) {
    return customFoods.any((f) => f.id == id);
  }
  
  /// Check if a meal ID exists in today's meals
  bool hasMeal(String id) {
    return todayMeals.any((m) => m.id == id);
  }
  
  /// Get a custom food by ID
  FoodItemFull? getCustomFood(String id) {
    try {
      return customFoods.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }
  
  /// Get a meal by ID
  Meal? getMeal(String id) {
    try {
      return todayMeals.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
