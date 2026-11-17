import 'package:hive/hive.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/core/utils/hive_json_utils.dart';
import 'package:progression_tracker/core/utils/hive_manager.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import '../models/workout_model.dart';

class HiveWorkoutDataSource {
  static const String boxName = HiveManager.workoutsBox;
  static const String indexKey = '__workout_time_index__';

  Future<Box<Map>> get _box => HiveManager.ensureWorkoutBox();

  int _dataRecordCount(Box<Map> box) =>
      box.length - (box.containsKey(indexKey) ? 1 : 0);

  static int _compareDatesDesc(String a, String b) {
    final dtA = DateTime.tryParse(a);
    final dtB = DateTime.tryParse(b);
    if (dtA != null && dtB != null) {
      return dtB.compareTo(dtA);
    }
    return b.compareTo(a);
  }

  List<Map<String, dynamic>>? _tryReadCachedIndex(Box<Map> box) {
    final raw = box.get(indexKey);
    if (raw == null) return null;
    final scannedCount = raw['scannedCount'];
    final entriesRaw = raw['entries'];
    if (scannedCount is! int ||
        entriesRaw is! List ||
        scannedCount != _dataRecordCount(box)) {
      return null;
    }
    return entriesRaw
        .whereType<Map>()
        .map((e) => deepCastMap(e))
        .toList();
  }

  Future<List<Map<String, dynamic>>> _rebuildIndex(Box<Map> box) async {
    final entries = <Map<String, dynamic>>[];
    var scannedCount = 0;

    for (final key in box.keys) {
      if (key == indexKey) continue;
      scannedCount++;
      final raw = box.get(key);
      if (raw == null) continue;
      try {
        final model = WorkoutModel.fromJson(deepCastMap(raw));
        entries.add({
          'id': model.id,
          'date': model.date,
          if (model.userId != null) 'userId': model.userId,
        });
      } catch (e) {
        AppLogger.debug(
          '⚠️ [WorkoutData] Skipping corrupt workout "$key" during index build: $e',
        );
      }
    }

    entries.sort(
      (a, b) => _compareDatesDesc(
        a['date'] as String? ?? '',
        b['date'] as String? ?? '',
      ),
    );
    await box.put(indexKey, {
      'scannedCount': scannedCount,
      'entries': entries,
    });
    return entries;
  }

  Future<List<Map<String, dynamic>>> _loadOrRebuildIndex(Box<Map> box) async {
    return _tryReadCachedIndex(box) ?? await _rebuildIndex(box);
  }

  Future<void> _upsertIndexEntry(Box<Map> box, WorkoutModel workout) async {
    final cached = _tryReadCachedIndex(box);
    if (cached == null) {
      await _rebuildIndex(box);
      return;
    }
    cached.removeWhere((e) => e['id'] == workout.id);
    cached.add({
      'id': workout.id,
      'date': workout.date,
      if (workout.userId != null) 'userId': workout.userId,
    });
    cached.sort(
      (a, b) => _compareDatesDesc(
        a['date'] as String? ?? '',
        b['date'] as String? ?? '',
      ),
    );
    await box.put(indexKey, {
      'scannedCount': _dataRecordCount(box),
      'entries': cached,
    });
  }

  Future<void> _removeIndexEntry(Box<Map> box, String id) async {
    final cached = _tryReadCachedIndex(box);
    if (cached == null) return;
    cached.removeWhere((e) => e['id'] == id);
    await box.put(indexKey, {
      'scannedCount': _dataRecordCount(box),
      'entries': cached,
    });
  }

  Future<WorkoutModel?> getWorkoutById(String id) async {
    if (id == indexKey) return null;
    final box = await _box;
    if (!box.isOpen) return null;
    final raw = box.get(id);
    if (raw == null) return null;
    try {
      return WorkoutModel.fromJson(deepCastMap(raw));
    } catch (e) {
      AppLogger.debug('⚠️ [WorkoutData] Corrupt workout "$id": $e');
      return null;
    }
  }

  Future<void> saveWorkout(WorkoutModel workout) async {
    try {
      AppLogger.debug('📊 [WorkoutData] Saving workout...');
      AppLogger.debug('🔍 [WorkoutData] Workout ID: ${workout.id}');
      
      final box = await _box;
      if (!box.isOpen) {
        AppLogger.debug('⚠️ [WorkoutData] Workouts box is not open');
        throw Exception('Workouts box not open');
      }
      
      await box.put(workout.id, workout.toJson());
      await _upsertIndexEntry(box, workout);
      
      AppLogger.debug('✅ [WorkoutData] Workout saved successfully');
      AppLogger.debug('🔍 [WorkoutData] Exercises: ${workout.exercises.length}, Duration: ${workout.durationSeconds}s');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [WorkoutData] Failed to save workout: $e');
      AppLogger.debug('🔍 [WorkoutData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<WorkoutModel>> getAllWorkouts() async {
    try {
      AppLogger.debug('📊 [WorkoutData] Retrieving all workouts...');
      
      final box = await _box;
      if (!box.isOpen) {
        AppLogger.debug('⚠️ [WorkoutData] Workouts box is not open');
        throw Exception('Workouts box not open');
      }
      
      AppLogger.debug('🔍 [WorkoutData] Deserializing workout data...');
      final workouts = <WorkoutModel>[];
      for (final key in box.keys) {
        if (key == indexKey) continue;
        final raw = box.get(key);
        if (raw == null) continue;
        try {
          workouts.add(WorkoutModel.fromJson(deepCastMap(raw)));
        } catch (e) {
          AppLogger.debug('⚠️ [WorkoutData] Skipping corrupt workout "$key": $e');
        }
      }

      // Sort by date descending
      workouts.sort((a, b) => b.date.compareTo(a.date));
      
      AppLogger.debug('✅ [WorkoutData] All workouts retrieved successfully');
      AppLogger.debug('🔍 [WorkoutData] Total workouts: ${workouts.length}');
      
      return workouts;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [WorkoutData] Failed to retrieve workouts: $e');
      AppLogger.debug('🔍 [WorkoutData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Reactive stream of all workouts (Phase 3, F-12): emits the current
  /// snapshot immediately, then a fresh snapshot on every box change.
  Stream<List<WorkoutModel>> watchAllWorkouts() async* {
    final box = await _box;
    yield await getAllWorkouts();
    yield* box
        .watch()
        .where((event) => event.key != indexKey)
        .asyncMap((_) => getAllWorkouts());
  }

  Future<List<WorkoutModel>> getWorkoutsPaginated({
    int offset = 0,
    int limit = 20,
    String? userId,
  }) async {
    try {
      AppLogger.debug('📊 [WorkoutData] Retrieving paginated workouts...');
      AppLogger.debug('🔍 [WorkoutData] Offset: $offset, Limit: $limit');
      
      final box = await _box;
      if (!box.isOpen) {
        AppLogger.debug('⚠️ [WorkoutData] Workouts box is not open');
        throw Exception('Workouts box not open');
      }

      final normalizedUser = RecordOwnershipRules.normalizeUserId(userId);
      final index = await _loadOrRebuildIndex(box);
      final filteredEntries = normalizedUser == null
          ? index
          : index
              .where(
                (entry) => RecordOwnershipRules.belongsToCurrentUser(
                  ownerId: entry['userId'] as String?,
                  currentUserId: normalizedUser,
                ),
              )
              .toList();

      if (offset >= filteredEntries.length || limit <= 0) {
        return [];
      }
      final endIndex = (offset + limit).clamp(0, filteredEntries.length);
      final pageEntries = filteredEntries.sublist(offset, endIndex);

      final paginatedWorkouts = <WorkoutModel>[];
      for (final entry in pageEntries) {
        final id = entry['id'] as String?;
        if (id == null) continue;
        final raw = box.get(id);
        if (raw == null) continue;
        try {
          paginatedWorkouts.add(WorkoutModel.fromJson(deepCastMap(raw)));
        } catch (e) {
          AppLogger.debug(
            '⚠️ [WorkoutData] Skipping corrupt workout "$id" in page: $e',
          );
        }
      }
      
      AppLogger.debug('✅ [WorkoutData] Paginated workouts retrieved successfully');
      AppLogger.debug('🔍 [WorkoutData] Returned: ${paginatedWorkouts.length} workouts (${offset + 1}-$endIndex of ${filteredEntries.length})');
      
      return paginatedWorkouts;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [WorkoutData] Failed to retrieve paginated workouts: $e');
      AppLogger.debug('🔍 [WorkoutData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<int> getWorkoutCount({String? userId}) async {
    try {
      AppLogger.debug('📊 [WorkoutData] Getting workout count...');
      
      final box = await _box;
      if (!box.isOpen) {
        AppLogger.debug('⚠️ [WorkoutData] Workouts box is not open');
        throw Exception('Workouts box not open');
      }
      
      final normalizedUser = RecordOwnershipRules.normalizeUserId(userId);
      final int count;
      if (normalizedUser == null) {
        count = _dataRecordCount(box);
      } else {
        final index = await _loadOrRebuildIndex(box);
        count = index
            .where(
              (entry) => RecordOwnershipRules.belongsToCurrentUser(
                ownerId: entry['userId'] as String?,
                currentUserId: normalizedUser,
              ),
            )
            .length;
      }
      
      AppLogger.debug('✅ [WorkoutData] Workout count retrieved successfully');
      AppLogger.debug('🔍 [WorkoutData] Total workouts: $count');
      
      return count;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [WorkoutData] Failed to get workout count: $e');
      AppLogger.debug('🔍 [WorkoutData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> deleteWorkout(String id) async {
    try {
      AppLogger.debug('📊 [WorkoutData] Deleting workout...');
      AppLogger.debug('🔍 [WorkoutData] Workout ID: $id');
      
      final box = await _box;
      if (!box.isOpen) {
        AppLogger.debug('⚠️ [WorkoutData] Workouts box is not open');
        throw Exception('Workouts box not open');
      }
      
      await box.delete(id);
      await _removeIndexEntry(box, id);
      
      AppLogger.debug('✅ [WorkoutData] Workout deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [WorkoutData] Failed to delete workout: $e');
      AppLogger.debug('🔍 [WorkoutData] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
