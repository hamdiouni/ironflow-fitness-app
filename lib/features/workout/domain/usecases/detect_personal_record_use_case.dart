import '../entities/entities.dart';
import '../repositories/workout_repository.dart';

/// Determines whether a new set constitutes a personal record (PR).
///
/// Compares the volume (weight × reps) of [newSet] against all historical
/// sets for [exerciseName]. Returns `true` if the new volume exceeds the
/// previous best, or if this is the first time the exercise has been logged.
class DetectPersonalRecordUseCase {
  final WorkoutRepository repository;

  DetectPersonalRecordUseCase(this.repository);

  Future<bool> call(String exerciseName, SetEntry newSet) async {
    final history = await repository.getExerciseHistory(exerciseName, 100);

    final allSets = history.expand((exercise) => exercise.sets).toList();

    if (allSets.isEmpty) return true; // First time is always a PR.

    final newVolume = newSet.weight * newSet.reps;
    final bestPreviousVolume = allSets
        .map((set) => set.weight * set.reps)
        .reduce((a, b) => a > b ? a : b);

    return newVolume > bestPreviousVolume;
  }
}
