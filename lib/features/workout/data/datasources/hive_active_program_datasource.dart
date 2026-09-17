import 'package:hive/hive.dart';
import '../models/active_program_model.dart';

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

/// Hive data source for active program storage
class HiveActiveProgramDataSource {
  static const String boxName = 'active_program';
  static const String key = 'current_active_program';

  Future<Box<Map>> get _box async => await Hive.openBox<Map>(boxName);

  /// Save the active program to local storage
  Future<void> saveActiveProgram(ActiveProgramModel program) async {
    final box = await _box;
    await box.put(key, program.toJson());
  }

  /// Load the active program from local storage
  Future<ActiveProgramModel?> loadActiveProgram() async {
    final box = await _box;
    final json = box.get(key);
    if (json == null) return null;

    return ActiveProgramModel.fromJson(_deepCast(json));
  }

  /// Clear the active program from local storage
  Future<void> clearActiveProgram() async {
    final box = await _box;
    await box.delete(key);
  }
}
