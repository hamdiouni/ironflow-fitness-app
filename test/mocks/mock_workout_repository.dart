import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';

/// Mock implementation of WorkoutRepository for testing
class MockWorkoutRepository implements WorkoutRepository {
  List<Workout> _workouts = [];

  void setWorkouts(List<Workout> workouts) {
    _workouts = workouts;
  }

  @override
  Future<List<Workout>> getWorkoutsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _workouts.where((workout) {
      return workout.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          workout.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<void> saveWorkout(Workout workout) async {
    _workouts.add(workout);
  }

  @override
  Future<List<Workout>> getAllWorkouts() async {
    return _workouts;
  }

  @override
  Future<Workout?> getWorkoutById(String id) async {
    try {
      return _workouts.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    _workouts.removeWhere((w) => w.id == id);
  }

  @override
  Future<void> updateWorkout(Workout workout) async {
    final index = _workouts.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      _workouts[index] = workout;
    }
  }

  @override
  Future<List<Workout>> getWorkoutsPaginated({
    int offset = 0,
    int limit = 20,
  }) async {
    final sorted = List<Workout>.from(_workouts);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.skip(offset).take(limit).toList();
  }

  @override
  Future<int> getWorkoutCount() async {
    return _workouts.length;
  }

  @override
  Future<List<Exercise>> getExerciseHistory(String exerciseName, int limit) async {
    final exercises = <Exercise>[];
    for (final workout in _workouts) {
      for (final exercise in workout.exercises) {
        if (exercise.name == exerciseName) {
          exercises.add(exercise);
        }
      }
    }
    exercises.sort((a, b) => b.id.compareTo(a.id)); // Sort by most recent
    return exercises.take(limit).toList();
  }
}
