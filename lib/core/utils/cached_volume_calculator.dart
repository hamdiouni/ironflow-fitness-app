import '../../features/workout/domain/entities/entities.dart';

/// A caching wrapper around workout volume calculation.
///
/// Caches the computed volume for each workout by its [Workout.id].
/// When the same workout ID is requested again, the cached value is returned
/// without recomputing. When data changes (e.g. a new set is added), call
/// [invalidate] with the workout ID to clear the stale entry.
///
/// Requirements: 16.4
class CachedVolumeCalculator {
  final Map<String, double> _cache = {};

  /// Returns the total volume for [workout], using a cached value when available.
  ///
  /// Volume = sum of (weight × reps) across all sets of all exercises.
  double calculate(Workout workout) {
    if (_cache.containsKey(workout.id)) {
      return _cache[workout.id]!;
    }

    final volume = workout.exercises.fold(0.0, (total, exercise) {
      return total +
          exercise.sets.fold(0.0, (sum, set) => sum + (set.weight * set.reps));
    });

    _cache[workout.id] = volume;
    return volume;
  }

  /// Removes the cached volume for the given [workoutId].
  ///
  /// Call this whenever the workout's sets change so the next [calculate]
  /// call recomputes the value from scratch.
  void invalidate(String workoutId) {
    _cache.remove(workoutId);
  }

  /// Clears all cached values.
  void invalidateAll() {
    _cache.clear();
  }

  /// Returns `true` if a cached value exists for [workoutId].
  bool isCached(String workoutId) => _cache.containsKey(workoutId);
}
