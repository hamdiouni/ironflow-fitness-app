import 'package:hive/hive.dart';
import '../models/diet_plan_state_model.dart';

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

/// Hive data source for diet plan storage
class HiveDietPlanDataSource {
  static const String boxName = 'diet_plan';
  static const String key = 'current_diet_plan';

  Future<Box<Map>> get _box async => await Hive.openBox<Map>(boxName);

  /// Save the diet plan to local storage
  Future<void> saveDietPlan(DietPlanStateModel planState) async {
    final box = await _box;
    await box.put(key, planState.toJson());
  }

  /// Load the diet plan from local storage
  Future<DietPlanStateModel?> loadDietPlan() async {
    final box = await _box;
    final json = box.get(key);
    if (json == null) return null;

    return DietPlanStateModel.fromJson(_deepCast(json));
  }

  /// Clear the diet plan from local storage
  Future<void> clearDietPlan() async {
    final box = await _box;
    await box.delete(key);
  }
}
