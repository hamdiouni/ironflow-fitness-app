import 'package:hive/hive.dart';
import '../models/meal_model.dart';
import '../models/macro_target_model.dart';
import '../../domain/entities/food_item.dart';
import '../food_database.dart';

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

class HiveNutritionDataSource {
  static const String mealsBoxName = 'meals';
  static const String macroTargetsBoxName = 'macro_targets';
  static const String macroTargetKey = 'current';

  Box<Map> get _mealsBox => Hive.box<Map>(mealsBoxName);

  Box<Map> get _macroTargetsBox => Hive.box<Map>(macroTargetsBoxName);

  Future<void> saveMeal(MealModel meal) async {
    await _mealsBox.put(meal.id, meal.toJson());
  }

  Future<List<MealModel>> getMealsByDate(DateTime date) async {
    final meals = _mealsBox.values
        .map((json) => MealModel.fromJson(_deepCast(json)))
        .where((meal) {
          final mealDate = DateTime.parse(meal.timestamp);
          return mealDate.year == date.year &&
              mealDate.month == date.month &&
              mealDate.day == date.day;
        })
        .toList();
    return meals;
  }

  Future<List<MealModel>> getAllMeals() async {
    return _mealsBox.values
        .map((json) => MealModel.fromJson(_deepCast(json)))
        .toList();
  }

  Future<void> deleteMeal(String id) async {
    await _mealsBox.delete(id);
  }

  Future<void> saveMacroTarget(MacroTargetModel target) async {
    await _macroTargetsBox.put(macroTargetKey, target.toJson());
  }

  Future<MacroTargetModel?> getMacroTarget() async {
    final json = _macroTargetsBox.get(macroTargetKey);
    if (json == null) return null;
    return MacroTargetModel.fromJson(_deepCast(json));
  }

  /// Get all available food items from the preloaded database.
  Future<List<FoodItem>> getAllFoods() async {
    return FoodDatabase.all;
  }
}
