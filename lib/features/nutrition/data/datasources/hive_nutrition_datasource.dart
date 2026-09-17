import 'package:hive/hive.dart';
import '../models/meal_model.dart';
import '../models/nutrition_targets_model.dart';

/// Recursively casts a [Map<dynamic, dynamic>] (as returned by Hive) to
/// [Map<String, dynamic>] so that json_serializable can deserialize it.
Map<String, dynamic> _deepCast(Map<dynamic, dynamic> map) {
  return map.map((key, value) {
    if (value is Map) {
      return MapEntry(key.toString(), _deepCast(value));
    } else if (value is List) {
      return MapEntry(key.toString(), _deepCastList(value));
    }
    return MapEntry(key.toString(), value);
  });
}

List<dynamic> _deepCastList(List<dynamic> list) {
  return list.map((item) {
    if (item is Map) return _deepCast(item);
    if (item is List) return _deepCastList(item);
    return item;
  }).toList();
}

/// Hive datasource for local nutrition data storage.
///
/// Provides offline-first caching for:
/// - Meal entries
/// - Nutrition targets
/// - Sync queue operations
///
/// All data is persisted locally for offline access and synced to cloud when online.
class HiveNutritionDatasource {
  static const String mealsBoxName = 'meals';
  static const String targetsBoxName = 'macro_targets';
  static const String targetsKey = 'current';

  Box<Map> get _mealsBox => Hive.box<Map>(mealsBoxName);

  Box<Map> get _targetsBox => Hive.box<Map>(targetsBoxName);

  /// Save a meal entry to local storage.
  ///
  /// Stores the meal in Hive for offline access.
  /// Uses the meal ID as the key for easy retrieval.
  Future<void> saveMealEntry(MealModel meal) async {
    try {
      print('📊 [NutritionData] Saving meal entry...');
      print('🔍 [NutritionData] Meal ID: ${meal.id}, Name: ${meal.name}');
      
      if (!_mealsBox.isOpen) {
        print('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      await _mealsBox.put(meal.id, meal.toJson());
      
      print('✅ [NutritionData] Meal saved successfully');
      print('🔍 [NutritionData] Calories: ${meal.macros.calories}, Name: ${meal.name}');
    } catch (e, stackTrace) {
      print('❌ [NutritionData] Failed to save meal: $e');
      print('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get all meals for a specific date.
  ///
  /// Filters meals by date from local storage.
  /// Returns an empty list if no meals found.
  Future<List<MealModel>> getMealsByDate(DateTime date) async {
    try {
      print('📊 [NutritionData] Getting meals by date...');
      print('🔍 [NutritionData] Date: ${date.year}-${date.month}-${date.day}');
      
      if (!_mealsBox.isOpen) {
        print('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      final meals = _mealsBox.values
          .map((json) => MealModel.fromJson(_deepCast(json)))
          .where((meal) {
            final mealDate = DateTime.parse(meal.timestamp);
            return mealDate.year == date.year &&
                mealDate.month == date.month &&
                mealDate.day == date.day;
          })
          .toList();
      
      print('✅ [NutritionData] Meals retrieved successfully');
      print('🔍 [NutritionData] Found ${meals.length} meals for date');
      
      return meals;
    } catch (e, stackTrace) {
      print('❌ [NutritionData] Failed to get meals by date: $e');
      print('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get all meals for a date range.
  ///
  /// Filters meals between [startDate] and [endDate] from local storage.
  /// Useful for analytics and history views.
  Future<List<MealModel>> getMealsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      print('📊 [NutritionData] Getting meals by date range...');
      print('🔍 [NutritionData] Start: ${startDate.toIso8601String()}, End: ${endDate.toIso8601String()}');
      
      if (!_mealsBox.isOpen) {
        print('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      final meals = _mealsBox.values
          .map((json) => MealModel.fromJson(_deepCast(json)))
          .where((meal) {
            final mealDate = DateTime.parse(meal.timestamp);
            return mealDate.isAfter(startDate) && mealDate.isBefore(endDate);
          })
          .toList();
      
      print('✅ [NutritionData] Meals retrieved successfully');
      print('🔍 [NutritionData] Found ${meals.length} meals in date range');
      
      return meals;
    } catch (e, stackTrace) {
      print('❌ [NutritionData] Failed to get meals by date range: $e');
      print('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get all meals from local storage.
  ///
  /// Returns all meal entries stored locally.
  Future<List<MealModel>> getAllMeals() async {
    try {
      print('📊 [NutritionData] Getting all meals...');
      
      if (!_mealsBox.isOpen) {
        print('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      final meals = _mealsBox.values
          .map((json) => MealModel.fromJson(_deepCast(json)))
          .toList();
      
      print('✅ [NutritionData] All meals retrieved successfully');
      print('🔍 [NutritionData] Total meals: ${meals.length}');
      
      return meals;
    } catch (e, stackTrace) {
      print('❌ [NutritionData] Failed to get all meals: $e');
      print('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get a specific meal by ID.
  ///
  /// Returns the meal if found, null otherwise.
  Future<MealModel?> getMealById(String mealId) async {
    try {
      print('📊 [NutritionData] Getting meal by ID...');
      print('🔍 [NutritionData] Meal ID: $mealId');
      
      if (!_mealsBox.isOpen) {
        print('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      final json = _mealsBox.get(mealId);
      
      if (json == null) {
        print('⚠️ [NutritionData] Meal not found');
        return null;
      }
      
      final meal = MealModel.fromJson(_deepCast(json));
      print('✅ [NutritionData] Meal retrieved successfully');
      print('🔍 [NutritionData] Name: ${meal.name}, Calories: ${meal.macros.calories}');
      
      return meal;
    } catch (e, stackTrace) {
      print('❌ [NutritionData] Failed to get meal by ID: $e');
      print('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Delete a meal entry from local storage.
  ///
  /// Removes the meal by its ID.
  Future<void> deleteMealEntry(String mealId) async {
    try {
      print('📊 [NutritionData] Deleting meal entry...');
      print('🔍 [NutritionData] Meal ID: $mealId');
      
      if (!_mealsBox.isOpen) {
        print('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      await _mealsBox.delete(mealId);
      
      print('✅ [NutritionData] Meal deleted successfully');
    } catch (e, stackTrace) {
      print('❌ [NutritionData] Failed to delete meal: $e');
      print('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Delete all meals for a specific date.
  ///
  /// Useful for clearing a day's nutrition data.
  Future<void> deleteMealsByDate(DateTime date) async {
    try {
      print('📊 [NutritionData] Deleting meals by date...');
      print('🔍 [NutritionData] Date: ${date.year}-${date.month}-${date.day}');
      
      if (!_mealsBox.isOpen) {
        print('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      final meals = await getMealsByDate(date);
      print('🔍 [NutritionData] Found ${meals.length} meals to delete');
      
      for (final meal in meals) {
        await _mealsBox.delete(meal.id);
      }
      
      print('✅ [NutritionData] Meals deleted successfully');
      print('🔍 [NutritionData] Deleted ${meals.length} meals');
    } catch (e, stackTrace) {
      print('❌ [NutritionData] Failed to delete meals by date: $e');
      print('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Save nutrition targets to local storage.
  ///
  /// Stores the user's daily nutrition targets.
  Future<void> saveNutritionTargets(NutritionTargetsModel targets) async {
    try {
      print('📊 [NutritionData] Saving nutrition targets...');
      print('🔍 [NutritionData] Macros - Calories: ${targets.macros.calories}, Protein: ${targets.macros.protein}g');
      
      if (!_targetsBox.isOpen) {
        print('⚠️ [NutritionData] Targets box is not open');
        throw Exception('Targets box not open');
      }
      
      await _targetsBox.put(targetsKey, targets.toJson());
      
      print('✅ [NutritionData] Nutrition targets saved successfully');
      print('🔍 [NutritionData] Macros - Calories: ${targets.macros.calories}, Protein: ${targets.macros.protein}g, Carbs: ${targets.macros.carbs}g, Fat: ${targets.macros.fats}g');
    } catch (e, stackTrace) {
      print('❌ [NutritionData] Failed to save nutrition targets: $e');
      print('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get nutrition targets from local storage.
  ///
  /// Returns the stored targets or null if not set.
  Future<NutritionTargetsModel?> getNutritionTargets() async {
    try {
      print('📊 [NutritionData] Getting nutrition targets...');
      
      if (!_targetsBox.isOpen) {
        print('⚠️ [NutritionData] Targets box is not open');
        throw Exception('Targets box not open');
      }
      
      final json = _targetsBox.get(targetsKey);
      
      if (json == null) {
        print('⚠️ [NutritionData] No nutrition targets found');
        return null;
      }
      
      final targets = NutritionTargetsModel.fromJson(_deepCast(json));
      print('✅ [NutritionData] Nutrition targets retrieved successfully');
      print('🔍 [NutritionData] Macros - Calories: ${targets.macros.calories}, Protein: ${targets.macros.protein}g');
      
      return targets;
    } catch (e, stackTrace) {
      print('❌ [NutritionData] Failed to get nutrition targets: $e');
      print('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Clear all local nutrition data.
  ///
  /// Removes all meals and targets from local storage.
  /// Used for logout or data reset.
  Future<void> clearAllData() async {
    try {
      print('📊 [NutritionData] Clearing all nutrition data...');
      
      if (!_mealsBox.isOpen) {
        print('⚠️ [NutritionData] Meals box is not open');
      } else {
        final mealsCount = _mealsBox.length;
        await _mealsBox.clear();
        print('✅ [NutritionData] Meals box cleared (${mealsCount} meals removed)');
      }
      
      if (!_targetsBox.isOpen) {
        print('⚠️ [NutritionData] Targets box is not open');
      } else {
        await _targetsBox.clear();
        print('✅ [NutritionData] Targets box cleared');
      }
      
      print('✅ [NutritionData] All nutrition data cleared successfully');
    } catch (e, stackTrace) {
      print('❌ [NutritionData] Failed to clear all data: $e');
      print('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get count of meals in local storage.
  ///
  /// Useful for debugging and monitoring.
  Future<int> getMealCount() async {
    try {
      print('📊 [NutritionData] Getting meal count...');
      
      if (!_mealsBox.isOpen) {
        print('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      final count = _mealsBox.length;
      print('✅ [NutritionData] Meal count retrieved successfully');
      print('🔍 [NutritionData] Total meals: $count');
      
      return count;
    } catch (e, stackTrace) {
      print('❌ [NutritionData] Failed to get meal count: $e');
      print('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Check if local storage has any meals.
  ///
  /// Returns true if at least one meal is stored.
  Future<bool> hasMeals() async {
    try {
      print('📊 [NutritionData] Checking if meals exist...');
      
      if (!_mealsBox.isOpen) {
        print('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      final hasData = _mealsBox.isNotEmpty;
      print('✅ [NutritionData] Meal check completed');
      print('🔍 [NutritionData] Has meals: $hasData');
      
      return hasData;
    } catch (e, stackTrace) {
      print('❌ [NutritionData] Failed to check meals: $e');
      print('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get all unique dates with meals.
  ///
  /// Useful for calendar views and history.
  Future<List<DateTime>> getAllMealDates() async {
    try {
      print('📊 [NutritionData] Getting all meal dates...');
      
      if (!_mealsBox.isOpen) {
        print('⚠️ [NutritionData] Meals box is not open');
        throw Exception('Meals box not open');
      }
      
      final dates = <DateTime>{};
      for (final json in _mealsBox.values) {
        final meal = MealModel.fromJson(_deepCast(json));
        final mealDate = DateTime.parse(meal.timestamp);
        dates.add(DateTime(mealDate.year, mealDate.month, mealDate.day));
      }
      
      final sortedDates = dates.toList()..sort();
      print('✅ [NutritionData] Meal dates retrieved successfully');
      print('🔍 [NutritionData] Unique dates: ${sortedDates.length}');
      
      return sortedDates;
    } catch (e, stackTrace) {
      print('❌ [NutritionData] Failed to get meal dates: $e');
      print('🔍 [NutritionData] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
