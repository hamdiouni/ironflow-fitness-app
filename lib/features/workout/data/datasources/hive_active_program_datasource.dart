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

  Future<Box<Map>?> get _box async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box<Map>(boxName);
      }
      try {
        if ((Hive as dynamic).homePath == null) {
          return null;
        }
      } catch (_) {
        return null;
      }
      return await Hive.openBox<Map>(boxName);
    } catch (_) {
      return null;
    }
  }

  /// Save the active program to local storage
  Future<void> saveActiveProgram(ActiveProgramModel program) async {
    final box = await _box;
    if (box == null) return;
    await box.put(key, program.toJson());
  }

  /// Load the active program from local storage
  Future<ActiveProgramModel?> loadActiveProgram() async {
    final box = await _box;
    if (box == null) return null;
    final json = box.get(key);
    if (json == null) return null;

    return ActiveProgramModel.fromJson(_deepCast(json));
  }

  static const String archivedKey = 'archived_active_program';

  /// Clear the active program from local storage
  Future<void> clearActiveProgram() async {
    final box = await _box;
    if (box == null) return;
    await box.delete(key);
  }

  /// Archives the current active program for undo support
  Future<void> archiveCurrentProgram() async {
    final box = await _box;
    if (box == null) return;
    final current = box.get(key);
    if (current != null) {
      await box.put(archivedKey, current);
    }
  }

  /// Restores the previously archived active program and returns it
  Future<ActiveProgramModel?> restoreArchivedProgram() async {
    final box = await _box;
    if (box == null) return null;
    final archived = box.get(archivedKey);
    if (archived == null) return null;
    await box.put(key, archived);
    await box.delete(archivedKey);
    return ActiveProgramModel.fromJson(_deepCast(archived));
  }

  /// Checks if an archived program exists
  Future<bool> hasArchivedProgram() async {
    final box = await _box;
    if (box == null) return false;
    return box.containsKey(archivedKey);
  }

  /// Reactive stream of the active program (Phase 3, F-12): emits the
  /// current value immediately, then re-loads on every change to the
  /// active-program key. Emits just the initial value when Hive is not
  /// initialized yet (tests).
  Stream<ActiveProgramModel?> watchActiveProgram() async* {
    yield await loadActiveProgram();
    final box = await _box;
    if (box == null) return;
    yield* box.watch(key: key).asyncMap((_) => loadActiveProgram());
  }
}
