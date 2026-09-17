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
      print('📊 [WorkoutData] Saving workout...');
      print('🔍 [WorkoutData] Workout ID: ${workout.id}');
      
      if (!_box.isOpen) {
        print('⚠️ [WorkoutData] Workouts box is not open');
        throw Exception('Workouts box not open');
      }
      
      await _box.put(workout.id, workout.toJson());
      
      print('✅ [WorkoutData] Workout saved successfully');
      print('🔍 [WorkoutData] Exercises: ${workout.exercises.length}, Duration: ${workout.durationSeconds}s');
    } catch (e, stackTrace) {
      print('❌ [WorkoutData] Failed to save workout: $e');
      print('🔍 [WorkoutData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<WorkoutModel>> getAllWorkouts() async {
    try {
      print('📊 [WorkoutData] Retrieving all workouts...');
      
      if (!_box.isOpen) {
        print('⚠️ [WorkoutData] Workouts box is not open');
        throw Exception('Workouts box not open');
      }
      
      print('🔍 [WorkoutData] Deserializing workout data...');
      final workouts = _box.values
          .map((json) => WorkoutModel.fromJson(_deepCast(json)))
          .toList();

      // Sort by date descending
      workouts.sort((a, b) => b.date.compareTo(a.date));
      
      print('✅ [WorkoutData] All workouts retrieved successfully');
      print('🔍 [WorkoutData] Total workouts: ${workouts.length}');
      
      return workouts;
    } catch (e, stackTrace) {
      print('❌ [WorkoutData] Failed to retrieve workouts: $e');
      print('🔍 [WorkoutData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<WorkoutModel>> getWorkoutsPaginated({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      print('📊 [WorkoutData] Retrieving paginated workouts...');
      print('🔍 [WorkoutData] Offset: $offset, Limit: $limit');
      
      if (!_box.isOpen) {
        print('⚠️ [WorkoutData] Workouts box is not open');
        throw Exception('Workouts box not open');
      }
      
      print('🔍 [WorkoutData] Deserializing workout data...');
      final workouts = _box.values
          .map((json) => WorkoutModel.fromJson(_deepCast(json)))
          .toList();

      // Sort by date descending
      workouts.sort((a, b) => b.date.compareTo(a.date));
      
      // Apply pagination
      final startIndex = offset;
      final endIndex = (offset + limit).clamp(0, workouts.length);
      
      if (startIndex >= workouts.length) {
        print('⚠️ [WorkoutData] Offset exceeds total workouts');
        print('🔍 [WorkoutData] Returning empty list');
        return [];
      }
      
      final paginatedWorkouts = workouts.sublist(startIndex, endIndex);
      
      print('✅ [WorkoutData] Paginated workouts retrieved successfully');
      print('🔍 [WorkoutData] Returned: ${paginatedWorkouts.length} workouts (${startIndex + 1}-$endIndex of ${workouts.length})');
      
      return paginatedWorkouts;
    } catch (e, stackTrace) {
      print('❌ [WorkoutData] Failed to retrieve paginated workouts: $e');
      print('🔍 [WorkoutData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<int> getWorkoutCount() async {
    try {
      print('📊 [WorkoutData] Getting workout count...');
      
      if (!_box.isOpen) {
        print('⚠️ [WorkoutData] Workouts box is not open');
        throw Exception('Workouts box not open');
      }
      
      final count = _box.length;
      
      print('✅ [WorkoutData] Workout count retrieved successfully');
      print('🔍 [WorkoutData] Total workouts: $count');
      
      return count;
    } catch (e, stackTrace) {
      print('❌ [WorkoutData] Failed to get workout count: $e');
      print('🔍 [WorkoutData] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> deleteWorkout(String id) async {
    try {
      print('📊 [WorkoutData] Deleting workout...');
      print('🔍 [WorkoutData] Workout ID: $id');
      
      if (!_box.isOpen) {
        print('⚠️ [WorkoutData] Workouts box is not open');
        throw Exception('Workouts box not open');
      }
      
      await _box.delete(id);
      
      print('✅ [WorkoutData] Workout deleted successfully');
    } catch (e, stackTrace) {
      print('❌ [WorkoutData] Failed to delete workout: $e');
      print('🔍 [WorkoutData] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
