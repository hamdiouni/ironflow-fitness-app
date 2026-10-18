import 'dart:math' as math;
import '../entities/entities.dart';
import '../repositories/workout_repository.dart';

/// Determines whether a new set constitutes a personal record (PR).
///
/// Rules:
/// 1. Warm-up sets ([SetType.warmup]) are strictly excluded from PR consideration.
/// 2. Evaluation criteria (never raw volume weight × reps):
///    - Heaviest weight lifted for this exercise.
///    - Best reps at the exact current weight.
///    - Estimated 1RM via Epley formula with a 10-rep cap:
///      1RM = weight × (1 + min(reps, 10) / 30.0).
/// 3. Returns `true` if this is the first working set or if any criterion exceeds all previous working sets.
class DetectPersonalRecordUseCase {
  static const int maxRepCapFor1RM = 10;

  final WorkoutRepository repository;

  DetectPersonalRecordUseCase(this.repository);

  Future<bool> call(String exerciseName, SetEntry newSet) async {
    // Warm-ups never qualify as personal records
    if (newSet.type == SetType.warmup) return false;

    final history = await repository.getExerciseHistory(exerciseName, 100);

    // Only compare against historical working sets (exclude warm-ups)
    final workingSets = history
        .expand((exercise) => exercise.sets)
        .where((set) => set.type != SetType.warmup)
        .toList();

    // First working set ever recorded is a personal record
    if (workingSets.isEmpty) return true;

    // 1. Heaviest weight criterion
    final bestWeight = workingSets
        .map((s) => s.weight)
        .reduce((a, b) => math.max(a, b));
    if (newSet.weight > bestWeight) return true;

    // 2. Best reps at identical weight criterion
    final sameWeightSets = workingSets
        .where((s) => (s.weight - newSet.weight).abs() < 0.001)
        .toList();
    if (sameWeightSets.isNotEmpty) {
      final bestRepsAtWeight = sameWeightSets
          .map((s) => s.reps)
          .reduce((a, b) => math.max(a, b));
      if (newSet.reps > bestRepsAtWeight) return true;
    }

    // 3. Estimated 1RM criterion (Epley formula with rep cap)
    final newEstimated1RM = calculateEstimated1RM(newSet.weight, newSet.reps);
    final bestEstimated1RM = workingSets
        .map((s) => calculateEstimated1RM(s.weight, s.reps))
        .reduce((a, b) => math.max(a, b));

    return newEstimated1RM > bestEstimated1RM + 0.01;
  }

  /// Calculates estimated 1RM using Epley's formula with a strict rep cap of 10.
  static double calculateEstimated1RM(double weight, int reps) {
    if (weight <= 0 || reps <= 0) return 0.0;
    final cappedReps = math.min(reps, maxRepCapFor1RM);
    return weight * (1.0 + (cappedReps / 30.0));
  }
}
