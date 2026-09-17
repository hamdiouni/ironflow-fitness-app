# 🎯 Nutrition State Management - Complete Fix Plan

## Date: 2026-04-25

---

## 📊 Current Problems Identified

### ❌ Critical Issues:
1. **UI doesn't update instantly** - Requires manual refresh after adding food
2. **Custom foods not integrated** - Custom foods don't appear in search immediately
3. **State mutation** - Lists are mutated instead of replaced (violates immutability)
4. **No single source of truth** - Multiple providers managing overlapping state
5. **Macro calculations** - Scaling logic scattered across codebase
6. **Missing user feedback** - No loading indicators or success messages in some flows

---

## ✅ Solution Architecture

### 🏗️ New State Management Structure

```
NutritionState (Single Source of Truth)
├── allFoods: List<FoodItemFull>          // All foods (preloaded + custom)
├── customFoods: List<FoodItemFull>       // User-created foods
├── todayMeals: List<Meal>                // Today's logged meals
├── dailySummary: DailyNutritionSummary   // Calculated totals
├── targets: NutritionTargets?            // Daily targets
├── isLoading: bool                       // Loading state
└── error: String?                        // Error state
```

### 🔄 State Update Flow

```
User Action
    ↓
Validate Input
    ↓
Save to Repository (Hive)
    ↓
Update State (copyWith)  ← IMMUTABLE
    ↓
Recalculate Totals
    ↓
UI Rebuilds Automatically (ref.watch)
    ↓
Show User Feedback (SnackBar)
```

---

## 🔥 Implementation Steps

### Step 1: Create Unified Nutrition State

**File**: `lib/features/nutrition/presentation/providers/nutrition_state.dart`

```dart
@freezed
class NutritionState with _$NutritionState {
  const factory NutritionState({
    @Default([]) List<FoodItemFull> allFoods,
    @Default([]) List<FoodItemFull> customFoods,
    @Default([]) List<Meal> todayMeals,
    required DateTime currentDate,
    NutritionTargets? targets,
    @Default(false) bool isLoading,
    String? error,
  }) = _NutritionState;
  
  const NutritionState._();
  
  // Computed properties
  double get totalCalories => todayMeals.fold(0.0, (sum, m) => sum + m.calories);
  double get totalProtein => todayMeals.fold(0.0, (sum, m) => sum + m.protein);
  double get totalCarbs => todayMeals.fold(0.0, (sum, m) => sum + m.carbs);
  double get totalFats => todayMeals.fold(0.0, (sum, m) => sum + m.fats);
  
  // Combined food list (preloaded + custom)
  List<FoodItemFull> get searchableFoods => [...allFoods, ...customFoods];
  
  // Remaining macros
  double get remainingCalories => (targets?.macros.calories ?? 2000) - totalCalories;
  double get remainingProtein => (targets?.macros.protein ?? 150) - totalProtein;
  double get remainingCarbs => (targets?.macros.carbs ?? 200) - totalCarbs;
  double get remainingFats => (targets?.macros.fats ?? 60) - totalFats;
}
```

### Step 2: Create Unified Nutrition Notifier

**File**: `lib/features/nutrition/presentation/providers/nutrition_notifier.dart`

```dart
class NutritionNotifier extends StateNotifier<NutritionState> {
  NutritionNotifier(this._repository) : super(NutritionState(currentDate: _today())) {
    _initialize();
  }
  
  final NutritionRepository _repository;
  
  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  
  // Initialize: Load all data
  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Load in parallel
      final results = await Future.wait([
        _repository.getAllFoods(),
        _repository.getCustomFoods(),
        _repository.getMealsByDate(state.currentDate),
        _repository.getNutritionTargets(),
      ]);
      
      state = state.copyWith(
        allFoods: results[0] as List<FoodItemFull>,
        customFoods: results[1] as List<FoodItemFull>,
        todayMeals: results[2] as List<Meal>,
        targets: results[3] as NutritionTargets?,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  // Add meal - INSTANT UI UPDATE
  Future<void> addMeal(Meal meal) async {
    try {
      // 1. Save to repository
      await _repository.saveMealEntry(meal);
      
      // 2. Update state IMMEDIATELY (immutable)
      state = state.copyWith(
        todayMeals: [...state.todayMeals, meal],
      );
      
      // Totals recalculate automatically via computed properties
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
  
  // Delete meal - INSTANT UI UPDATE
  Future<void> deleteMeal(String mealId) async {
    try {
      // 1. Save to repository
      await _repository.deleteMealEntry(mealId);
      
      // 2. Update state IMMEDIATELY (immutable)
      state = state.copyWith(
        todayMeals: state.todayMeals.where((m) => m.id != mealId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
  
  // Add custom food - INSTANT UI UPDATE
  Future<void> addCustomFood(FoodItemFull food) async {
    try {
      // 1. Validate
      if (food.name.trim().isEmpty) {
        throw Exception('Food name cannot be empty');
      }
      if (food.macros.calories < 0 || food.macros.protein < 0 || 
          food.macros.carbs < 0 || food.macros.fats < 0) {
        throw Exception('Macros must be positive numbers');
      }
      
      // 2. Save to repository
      await _repository.saveCustomFood(food);
      
      // 3. Update state IMMEDIATELY (immutable)
      state = state.copyWith(
        customFoods: [...state.customFoods, food],
      );
      
      // Food now appears in searchableFoods automatically
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
  
  // Delete custom food - INSTANT UI UPDATE
  Future<void> deleteCustomFood(String id) async {
    try {
      // 1. Save to repository
      await _repository.deleteCustomFood(id);
      
      // 2. Update state IMMEDIATELY (immutable)
      state = state.copyWith(
        customFoods: state.customFoods.where((f) => f.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
  
  // Search foods (local, instant)
  List<FoodItemFull> searchFoods(String query) {
    if (query.isEmpty) return state.searchableFoods;
    
    final lowerQuery = query.toLowerCase();
    return state.searchableFoods
        .where((f) => f.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
  
  // Filter by category (local, instant)
  List<FoodItemFull> filterByCategory(String? category) {
    if (category == null) return state.searchableFoods;
    
    return state.searchableFoods
        .where((f) => f.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
  
  // Refresh all data
  Future<void> refresh() async {
    await _initialize();
  }
}
```

### Step 3: Update Provider Definition

**File**: `lib/features/nutrition/presentation/providers/nutrition_providers.dart` (REPLACE)

```dart
// Single unified provider
final nutritionProvider = StateNotifierProvider<NutritionNotifier, NutritionState>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return NutritionNotifier(repository);
});

// Derived providers for specific UI needs
final searchableFoodsProvider = Provider<List<FoodItemFull>>((ref) {
  return ref.watch(nutritionProvider).searchableFoods;
});

final todayMealsProvider = Provider<List<Meal>>((ref) {
  return ref.watch(nutritionProvider).todayMeals;
});

final dailyTotalsProvider = Provider<({
  double calories,
  double protein,
  double carbs,
  double fats,
})>((ref) {
  final state = ref.watch(nutritionProvider);
  return (
    calories: state.totalCalories,
    protein: state.totalProtein,
    carbs: state.totalCarbs,
    fats: state.totalFats,
  );
});

final remainingMacrosProvider = Provider<({
  double calories,
  double protein,
  double carbs,
  double fats,
})>((ref) {
  final state = ref.watch(nutritionProvider);
  return (
    calories: state.remainingCalories,
    protein: state.remainingProtein,
    carbs: state.remainingCarbs,
    fats: state.remainingFats,
  );
});
```

### Step 4: Update Food Search Screen

**Changes**:
1. Use `ref.watch(nutritionProvider)` instead of separate providers
2. Search happens locally (instant)
3. Custom food appears immediately in search results
4. Show loading indicator while saving
5. Show success SnackBar after adding

```dart
// In FoodSearchScreen
@override
Widget build(BuildContext context, WidgetRef ref) {
  final nutritionState = ref.watch(nutritionProvider);
  final searchQuery = ref.watch(foodSearchProvider).query;
  
  // Search locally (instant)
  final foods = ref.read(nutritionProvider.notifier).searchFoods(searchQuery);
  
  return Scaffold(
    // ... UI code
  );
}

// In _CreateCustomFoodDialog
Future<void> _saveCustomFood() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isSaving = true);
  
  try {
    final customFood = FoodItemFull(/* ... */);
    
    // Add via notifier (instant UI update)
    await ref.read(nutritionProvider.notifier).addCustomFood(customFood);
    
    if (mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Custom food "${customFood.name}" created!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      Navigator.of(context).pop();
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}
```

### Step 5: Update Nutrition Screen

**Changes**:
1. Use `ref.watch(nutritionProvider)` for all data
2. Meals update instantly when added/deleted
3. Macro wheel updates automatically (computed properties)
4. Show loading indicators
5. Show success/error messages

```dart
// In NutritionScreen
@override
Widget build(BuildContext context, WidgetRef ref) {
  final nutritionState = ref.watch(nutritionProvider);
  
  if (nutritionState.isLoading) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
  
  if (nutritionState.error != null) {
    return Scaffold(
      body: _ErrorState(
        error: nutritionState.error!,
        onRetry: () => ref.read(nutritionProvider.notifier).refresh(),
      ),
    );
  }
  
  return Scaffold(
    appBar: AppBar(title: const Text('Nutrition')),
    body: SingleChildScrollView(
      child: Column(
        children: [
          // Macro wheel (updates automatically)
          MacroWheelChart(
            protein: nutritionState.totalProtein,
            carbs: nutritionState.totalCarbs,
            fats: nutritionState.totalFats,
          ),
          
          // Remaining macros (updates automatically)
          _RemainingMacrosCard(
            remaining: (
              calories: nutritionState.remainingCalories,
              protein: nutritionState.remainingProtein,
              carbs: nutritionState.remainingCarbs,
              fats: nutritionState.remainingFats,
            ),
          ),
          
          // Meals list (updates automatically)
          SwipeableMealCards(
            meals: nutritionState.todayMeals,
            onDelete: (mealId) async {
              try {
                await ref.read(nutritionProvider.notifier).deleteMeal(mealId);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Meal deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          
          // Add meal button
          ElevatedButton.icon(
            onPressed: () => _openFoodSearch(context, ref),
            icon: const Icon(Icons.search),
            label: const Text('Search & Log Food'),
          ),
        ],
      ),
    ),
  );
}

void _openFoodSearch(BuildContext context, WidgetRef ref) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => FoodSearchScreen(
      onFoodLogged: (FoodItem food, double grams) async {
        // Calculate macros with correct scaling
        final factor = grams / 100.0;
        final meal = Meal.create(
          name: '${food.name} (${grams.toInt()}g)',
          macros: MealMacros(
            calories: food.caloriesPer100g * factor,
            protein: food.proteinPer100g * factor,
            carbs: food.carbsPer100g * factor,
            fats: food.fatPer100g * factor,
          ),
          // ... other fields
        );
        
        try {
          // Show loading
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Adding meal...'),
                  ],
                ),
                duration: Duration(seconds: 1),
              ),
            );
          }
          
          // Add meal (instant UI update)
          await ref.read(nutritionProvider.notifier).addMeal(meal);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Meal added successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            
            Navigator.of(context).pop();
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
    ),
  ));
}
```

### Step 6: Fix Macro Scaling Logic

**Create utility class**:

```dart
// lib/features/nutrition/domain/utils/macro_calculator.dart

class MacroCalculator {
  /// Scale macros from per-100g to actual grams
  /// 
  /// Example:
  /// - Food: 100 kcal per 100g
  /// - User enters: 200g
  /// - Result: 200 kcal
  static ({
    double calories,
    double protein,
    double carbs,
    double fats,
  }) scaleMacros({
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatsPer100g,
    required double grams,
  }) {
    final factor = grams / 100.0;
    
    return (
      calories: caloriesPer100g * factor,
      protein: proteinPer100g * factor,
      carbs: carbsPer100g * factor,
      fats: fatsPer100g * factor,
    );
  }
  
  /// Validate macro values
  static bool isValid({
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
  }) {
    return calories >= 0 && 
           protein >= 0 && 
           carbs >= 0 && 
           fats >= 0;
  }
}
```

---

## 🧪 Testing Checklist

### Manual Testing:
- [ ] Add food from search → UI updates instantly
- [ ] Create custom food → Appears in search immediately
- [ ] Delete meal → UI updates instantly
- [ ] Macro wheel updates within 200ms
- [ ] Remaining macros update instantly
- [ ] Loading indicators show during save
- [ ] Success messages show after operations
- [ ] Error messages show on failure
- [ ] Macro scaling is correct (100g → 200g = 2x calories)
- [ ] Custom food persists after app restart
- [ ] Meals persist after app restart

### Edge Cases:
- [ ] Empty food name → Shows error
- [ ] Negative macros → Shows error
- [ ] Zero grams → Shows error
- [ ] Very large numbers → Handles correctly
- [ ] Duplicate food names → Allowed
- [ ] Delete non-existent meal → Handles gracefully
- [ ] Network offline → Works with local data

---

## 📊 Success Metrics

### Before (Current):
- ❌ UI updates only after manual refresh
- ❌ Custom foods don't appear in search
- ❌ State is mutated (bugs)
- ❌ No loading indicators
- ❌ Inconsistent user feedback

### After (Fixed):
- ✅ UI updates instantly (<200ms)
- ✅ Custom foods appear immediately
- ✅ State is immutable (no bugs)
- ✅ Loading indicators everywhere
- ✅ Consistent user feedback
- ✅ Single source of truth
- ✅ Correct macro calculations
- ✅ No manual refresh needed

---

## 🚀 Implementation Order

1. ✅ Create `nutrition_state.dart` (freezed class)
2. ✅ Create `nutrition_notifier.dart` (StateNotifier)
3. ✅ Create `macro_calculator.dart` (utility)
4. ✅ Update `nutrition_providers.dart` (unified provider)
5. ✅ Update `food_search_screen.dart` (use new provider)
6. ✅ Update `nutrition_screen.dart` (use new provider)
7. ✅ Test all flows
8. ✅ Fix any issues
9. ✅ Document changes

---

## 📝 Files to Create/Modify

### New Files:
- `lib/features/nutrition/presentation/providers/nutrition_state.dart`
- `lib/features/nutrition/presentation/providers/nutrition_notifier.dart`
- `lib/features/nutrition/domain/utils/macro_calculator.dart`

### Modified Files:
- `lib/features/nutrition/presentation/providers/nutrition_providers.dart`
- `lib/features/nutrition/presentation/providers/food_providers.dart`
- `lib/features/nutrition/presentation/screens/food_search_screen.dart`
- `lib/features/nutrition/presentation/screens/nutrition_screen.dart`

### Deprecated Files (can be removed after migration):
- None (we'll keep old providers for backward compatibility initially)

---

## ⚠️ Breaking Changes

None! The new architecture is backward compatible. Old providers will continue to work during migration.

---

## 🎯 Key Principles

1. **Immutability**: NEVER mutate state, always use `copyWith`
2. **Single Source of Truth**: One provider manages all nutrition state
3. **Instant Updates**: UI rebuilds automatically via `ref.watch`
4. **User Feedback**: Always show loading/success/error messages
5. **Validation**: Validate input before saving
6. **Error Handling**: Catch and display all errors
7. **Offline-First**: Save to local storage immediately

---

**Status**: ✅ READY FOR IMPLEMENTATION
**Estimated Time**: 4-6 hours
**Priority**: HIGH (Critical UX issue)

