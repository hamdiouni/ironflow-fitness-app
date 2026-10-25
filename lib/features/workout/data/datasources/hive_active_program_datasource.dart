import 'package:hive/hive.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
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

/// Hive data source for active program storage.
///
/// Active/archived programs are stored per signed-in user
/// (`current_active_program_<uid>` / `archived_active_program_<uid>`).
/// The previous device-wide singleton meant a second account could see or
/// overwrite the first account's active program. Legacy singleton values
/// are adopted once only when no scoped value exists yet and the stored
/// model is legacy/unowned or already belongs to the requesting user.
class HiveActiveProgramDataSource {
  static const String boxName = 'active_program';
  static const String key = 'current_active_program';
  static const String archivedKey = 'archived_active_program';

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

  String? _sessionUserId() {
    if (!Hive.isBoxOpen('auth_session')) return null;
    final sessionBox = Hive.box('auth_session');
    final isLoggedIn =
        sessionBox.get('is_logged_in', defaultValue: false) as bool;
    if (!isLoggedIn) return null;
    final userId = sessionBox.get('user_id') as String?;
    return (userId != null && userId.isNotEmpty) ? userId : null;
  }

  String? _nonEmpty(String? value) =>
      (value != null && value.isNotEmpty) ? value : null;

  String? _resolveUserId(
    String? explicitUserId, {
    ActiveProgramModel? program,
  }) {
    return _nonEmpty(explicitUserId) ??
        _nonEmpty(program?.userId) ??
        _nonEmpty(program?.program.userId) ??
        _sessionUserId();
  }

  String _currentKeyFor(String? userId) =>
      userId == null ? key : '${key}_$userId';

  String _archivedKeyFor(String? userId) =>
      userId == null ? archivedKey : '${archivedKey}_$userId';

  bool _ownerMatches(String? ownerId, String? userId) {
    return RecordOwnershipRules.belongsToCurrentUser(
      ownerId: ownerId,
      currentUserId: userId,
    );
  }

  bool _belongsTo(ActiveProgramModel model, String? userId) {
    return _ownerMatches(model.userId, userId) &&
        _ownerMatches(model.program.userId, userId);
  }

  ActiveProgramModel? _parseOwned(Map? json, String? userId) {
    if (json == null) return null;
    final model = ActiveProgramModel.fromJson(_deepCast(json));
    return _belongsTo(model, userId) ? model : null;
  }

  bool _hasScopedKey(Box<Map> box, String legacyKey) {
    return box.keys.any((k) => k.toString().startsWith('${legacyKey}_'));
  }

  Future<ActiveProgramModel?> _loadFromKey(
    Box<Map> box, {
    required String legacyKey,
    required String scopedKey,
    required String? userId,
    required bool adoptLegacy,
  }) async {
    if (userId == null) {
      return _parseOwned(box.get(legacyKey), null);
    }

    final scoped = _parseOwned(box.get(scopedKey), userId);
    if (scoped != null) return scoped;

    if (!adoptLegacy || _hasScopedKey(box, legacyKey)) return null;

    final legacyJson = box.get(legacyKey);
    final legacy = _parseOwned(legacyJson, userId);
    if (legacy == null || legacyJson == null) return null;

    await box.put(scopedKey, legacyJson);
    await box.delete(legacyKey);
    return legacy;
  }

  /// Save the active program to local storage for its owner.
  Future<void> saveActiveProgram(
    ActiveProgramModel program, {
    String? userId,
  }) async {
    final box = await _box;
    if (box == null) return;
    final resolvedUserId = _resolveUserId(userId, program: program);
    await box.put(
      _currentKeyFor(resolvedUserId),
      program.toJson(),
    );
  }

  /// Load the active program for [userId] (or the signed-in session user).
  Future<ActiveProgramModel?> loadActiveProgram({String? userId}) async {
    final box = await _box;
    if (box == null) return null;
    final resolvedUserId = _resolveUserId(userId);
    return _loadFromKey(
      box,
      legacyKey: key,
      scopedKey: _currentKeyFor(resolvedUserId),
      userId: resolvedUserId,
      adoptLegacy: true,
    );
  }

  /// Clear the active program for [userId] (or the session user).
  Future<void> clearActiveProgram({String? userId}) async {
    final box = await _box;
    if (box == null) return;
    final resolvedUserId = _resolveUserId(userId);
    await box.delete(_currentKeyFor(resolvedUserId));
  }

  /// Archives the current active program for undo support, per user.
  Future<void> archiveCurrentProgram({String? userId}) async {
    final box = await _box;
    if (box == null) return;
    final resolvedUserId = _resolveUserId(userId);
    final current = await _loadFromKey(
      box,
      legacyKey: key,
      scopedKey: _currentKeyFor(resolvedUserId),
      userId: resolvedUserId,
      adoptLegacy: true,
    );
    if (current != null) {
      await box.put(
        _archivedKeyFor(resolvedUserId),
        current.toJson(),
      );
    }
  }

  /// Restores the previously archived program for [userId] and returns it.
  Future<ActiveProgramModel?> restoreArchivedProgram({
    String? userId,
  }) async {
    final box = await _box;
    if (box == null) return null;
    final resolvedUserId = _resolveUserId(userId);
    final archived = await _loadFromKey(
      box,
      legacyKey: archivedKey,
      scopedKey: _archivedKeyFor(resolvedUserId),
      userId: resolvedUserId,
      adoptLegacy: true,
    );
    if (archived == null) return null;

    await box.put(
      _currentKeyFor(resolvedUserId),
      archived.toJson(),
    );
    await box.delete(_archivedKeyFor(resolvedUserId));
    return archived;
  }

  /// Checks if an archived program exists for [userId].
  Future<bool> hasArchivedProgram({String? userId}) async {
    final box = await _box;
    if (box == null) return false;
    final resolvedUserId = _resolveUserId(userId);
    if (box.containsKey(_archivedKeyFor(resolvedUserId))) return true;
    if (resolvedUserId == null) return false;
    if (_hasScopedKey(box, archivedKey)) return false;
    return _parseOwned(box.get(archivedKey), resolvedUserId) != null;
  }

  /// Reactive stream of the active program for [userId] (Phase 3, F-12):
  /// emits the current value immediately, then re-loads on every change to
  /// that user's active-program key. Emits just the initial value when
  /// Hive is not initialized yet (tests).
  Stream<ActiveProgramModel?> watchActiveProgram({String? userId}) async* {
    final resolvedUserId = _resolveUserId(userId);
    yield await loadActiveProgram(userId: resolvedUserId);
    final box = await _box;
    if (box == null) return;
    yield* box
        .watch(key: _currentKeyFor(resolvedUserId))
        .asyncMap((_) => loadActiveProgram(userId: resolvedUserId));
  }
}
