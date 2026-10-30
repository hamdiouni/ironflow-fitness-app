import '../entities/entities.dart';
import '../repositories/workout_repository.dart';
import 'workout_metrics.dart';

/// Determines whether a new set constitutes a personal record (PR).
///
/// Rules:
/// 1. Warm-up sets ([SetType.warmup]) and negative/non-finite weights are strictly excluded.
/// 2. Evaluation criteria (never raw volume weight × reps):
///    - Heaviest weight lifted for this exercise.
///    - Best reps at the exact current weight (including valid 0 kg bodyweight sets).
///    - Estimated 1RM via Epley formula with a 10-rep cap:
///      1RM = weight × (1 + min(reps, 10) / 30.0).
/// 3. Returns `true` if this is the first working set or if any criterion exceeds all previous working sets.
class DetectPersonalRecordUseCase {
  static const int maxRepCapFor1RM = WorkoutMetrics.maxRepCapFor1RM;

  final WorkoutRepository repository;

  DetectPersonalRecordUseCase(this.repository);

  Future<bool> call(String exerciseName, SetEntry newSet) async {
    if (!WorkoutMetrics.isValidWorkingSet(newSet)) return false;

    final history = await repository.getExerciseHistory(exerciseName, 100);
    return WorkoutMetrics.isSetPersonalRecord(newSet, history);
  }

  /// Calculates estimated 1RM using Epley's formula with a strict rep cap of 10.
  static double calculateEstimated1RM(double weight, int reps) {
    return WorkoutMetrics.calculateEstimated1RM(weight, reps);
  }
}
