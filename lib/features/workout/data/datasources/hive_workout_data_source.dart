import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:hive/hive.dart';
import '../models/workout_model.dart';

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

class HiveWorkoutDataSource {
  static const String boxName = 'workouts';

  Box<Map> get _box => Hive.box<Map>(boxName);

  Future<void> saveWorkout(WorkoutModel workout) async {
    try {
      AppLogger.debug('📊 [WorkoutData] Saving workout...');
      AppLogger.debug('🔍 [WorkoutData] Workout ID: ${workout.id}');
      
      if (!_box.isOpen) {
        AppLogger.debug('⚠️ [WorkoutData] Workouts box is not open');
        throw Exception('Workouts box not open');
      }
      
      await _box.put(workout.id, workout.toJson());
      
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
      
      if (!_box.isOpen) {
        AppLogger.debug('⚠️ [WorkoutData] Workouts box is not open');
        throw Exception('Workouts box not open');
      }
      
      AppLogger.debug('🔍 [WorkoutData] Deserializing workout data...');
      final workouts = _box.values
          .map((json) => WorkoutModel.fromJson(_deepCast(json)))
          .toList();

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
  /// This replaces the manual refresh-counter bumps that UI code used to
  /// make after every write.
  Stream<List<WorkoutModel>> watchAllWorkouts() async* {
    yield await getAllWorkouts();
    yield* _box.watch().asyncMap((_) => getAllWorkouts());
  }

  Future<List<WorkoutModel>> getWorkoutsPaginated({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      AppLogger.debug('📊 [WorkoutData] Retrieving paginated workouts...');
      AppLogger.debug('🔍 [WorkoutData] Offset: $offset, Limit: $limit');
      
      if (!_box.isOpen) {
        AppLogger.debug('⚠️ [WorkoutData] Workouts box is not open');
        throw Exception('Workouts box not open');
      }
      
      AppLogger.debug('🔍 [WorkoutData] Deserializing workout data...');
      final workouts = _box.values
          .map((json) => WorkoutModel.fromJson(_deepCast(json)))
          .toList();

      // Sort by date descending
      workouts.sort((a, b) => b.date.compareTo(a.date));
      
      // Apply pagination
      final startIndex = offset;
      final endIndex = (offset + limit).clamp(0, workouts.length);
      
      if (startIndex >= workouts.length) {
        AppLogger.debug('⚠️ [WorkoutData] Offset exceeds total workouts');
        AppLogger.debug('🔍 [WorkoutData] Returning empty list');
        return [];
      }
      
      final paginatedWorkouts = workouts.sublist(startIndex, endIndex);
      
      AppLogger.debug('✅ [WorkoutData] Paginated workouts retrieved successfully');
      AppLogger.debug('🔍 [WorkoutData] Returned: ${paginatedWorkouts.length} workouts (${startIndex + 1}-$endIndex of ${workouts.length})');
      
      return paginatedWorkouts;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [WorkoutData] Failed to retrieve paginated workouts: $e');
      AppLogger.debug('🔍 [WorkoutData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<int> getWorkoutCount() async {
    try {
      AppLogger.debug('📊 [WorkoutData] Getting workout count...');
      
      if (!_box.isOpen) {
        AppLogger.debug('⚠️ [WorkoutData] Workouts box is not open');
        throw Exception('Workouts box not open');
      }
      
      final count = _box.length;
      
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
      
      if (!_box.isOpen) {
        AppLogger.debug('⚠️ [WorkoutData] Workouts box is not open');
        throw Exception('Workouts box not open');
      }
      
      await _box.delete(id);
      
      AppLogger.debug('✅ [WorkoutData] Workout deleted successfully');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [WorkoutData] Failed to delete workout: $e');
      AppLogger.debug('🔍 [WorkoutData] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
