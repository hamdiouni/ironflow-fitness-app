import 'dart:math' as math;
import '../entities/exercise.dart';
import '../entities/set_entry.dart';
import '../entities/workout.dart';

/// Weight unit supported in active workout entry and display.
enum WeightUnit {
  kg,
  lb;

  String get label => this == WeightUnit.kg ? 'KG' : 'LB';
  String get lowerLabel => this == WeightUnit.kg ? 'kg' : 'lb';
}

/// Centralized Wave 2 domain rules for workout working sets, volume,
/// personal record (PR) eligibility, and kg/lb unit conversion.
class WorkoutMetrics {
  const WorkoutMetrics._();

  /// Conversion factor from kilograms to pounds.
  static const double kgToLbFactor = 2.20462262185;

  /// Maximum effective reps used in Epley 1RM estimation so high-rep light
  /// sets (e.g. 50 kg x 15) do not artificially beat heavy strength sets
  /// (e.g. 140 kg x 5).
  static const int maxRepCapFor1RM = 10;

  /// Validates that [weight] is finite and non-negative.
  /// Zero weight (`0.0`) is valid for bodyweight sets.
  static bool isValidWeight(double weight) {
    return weight.isFinite && weight >= 0;
  }

  /// Validates that [reps] is a positive integer.
  static bool isValidReps(int reps) {
    return reps > 0;
  }

  /// Returns true if [set] has valid reps and a finite non-negative weight
  /// (regardless of whether it is a warm-up or working set).
  static bool isValidSet(SetEntry set) {
    return isValidReps(set.reps) && isValidWeight(set.weight);
  }

  /// Returns true if [set] is a valid working set (non-warmup, positive reps,
  /// and finite non-negative weight).
  static bool isValidWorkingSet(SetEntry set) {
    return set.type != SetType.warmup && isValidSet(set);
  }

  /// Returns all valid working sets for [exercise].
  static List<SetEntry> workingSetsForExercise(Exercise exercise) {
    return exercise.sets.where(isValidWorkingSet).toList(growable: false);
  }

  /// Returns all valid working sets across all exercises in [workout].
  static List<SetEntry> workingSetsForWorkout(Workout workout) {
    return workout.exercises
        .expand(workingSetsForExercise)
        .toList(growable: false);
  }

  /// Returns the number of valid working sets in [workout].
  static int workingSetCount(Workout workout) {
    var count = 0;
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        if (isValidWorkingSet(set)) {
          count++;
        }
      }
    }
    return count;
  }

  /// Returns true when [workout] contains at least one valid working set.
  /// Zero-working-set workouts (empty or warm-up only) must not be saved.
  static bool hasWorkingSets(Workout workout) {
    return workingSetCount(workout) > 0;
  }

  /// Calculates working volume (`weight * reps`) for a single [set].
  /// Warm-up sets and sets with invalid/non-finite weights contribute `0.0`.
  static double calculateSetVolume(SetEntry set) {
    if (!isValidWorkingSet(set)) {
      return 0.0;
    }
    final volume = set.weight * set.reps;
    return volume.isFinite && volume >= 0 ? volume : 0.0;
  }

  /// Calculates total working volume for [exercise].
  static double calculateExerciseVolume(Exercise exercise) {
    var total = 0.0;
    for (final set in exercise.sets) {
      total += calculateSetVolume(set);
    }
    return total;
  }

  /// Calculates total working volume for a [workout].
  static double calculateWorkoutVolume(Workout workout) {
    var total = 0.0;
    for (final exercise in workout.exercises) {
      total += calculateExerciseVolume(exercise);
    }
    return total;
  }

  /// Calculates estimated 1RM using Epley's formula with a strict 10-rep cap:
  /// `weight * (1 + min(reps, 10) / 30.0)`.
  /// Non-finite, negative, or zero weights return `0.0`.
  static double calculateEstimated1RM(double weight, int reps) {
    if (!weight.isFinite || weight <= 0 || reps <= 0) {
      return 0.0;
    }
    final cappedReps = math.min(reps, maxRepCapFor1RM);
    return weight * (1.0 + (cappedReps / 30.0));
  }

  /// Evaluates whether [newSet] is a personal record against [history] for the
  /// same exercise.
  ///
  /// Rules:
  /// - Warm-up sets and negative/non-finite weights never qualify.
  /// - Valid zero-weight bodyweight sets (`0.0 kg`) are supported.
  /// - `50 kg x 15` does not beat `140 kg x 5` merely due to reps.
  static bool isSetPersonalRecord(SetEntry newSet, List<Exercise> history) {
    if (!isValidWorkingSet(newSet)) {
      return false;
    }

    final workingSets = history
        .expand((exercise) => exercise.sets)
        .where(isValidWorkingSet)
        .toList(growable: false);

    if (workingSets.isEmpty) {
      return true;
    }

    // 1. Heaviest weight criterion
    final bestWeight =
        workingSets.map((s) => s.weight).reduce((a, b) => math.max(a, b));
    if (newSet.weight > bestWeight) {
      return true;
    }

    // 2. Best reps at identical weight criterion (also supports 0 kg bodyweight sets)
    final sameWeightSets = workingSets
        .where((s) => (s.weight - newSet.weight).abs() < 0.001)
        .toList(growable: false);
    if (sameWeightSets.isNotEmpty) {
      final bestRepsAtWeight =
          sameWeightSets.map((s) => s.reps).reduce((a, b) => math.max(a, b));
      if (newSet.reps > bestRepsAtWeight) {
        return true;
      }
    }

    // 3. Estimated 1RM criterion (Epley formula with 10-rep cap)
    final newEstimated1RM = calculateEstimated1RM(newSet.weight, newSet.reps);
    final bestEstimated1RM = workingSets
        .map((s) => calculateEstimated1RM(s.weight, s.reps))
        .reduce((a, b) => math.max(a, b));

    return newEstimated1RM > bestEstimated1RM + 0.01;
  }

  /// Converts a weight in kilograms to pounds.
  static double kgToLb(double kg) {
    if (!isValidWeight(kg)) {
      return 0.0;
    }
    return kg * kgToLbFactor;
  }

  /// Converts a weight in pounds to kilograms.
  static double lbToKg(double lb) {
    if (!isValidWeight(lb)) {
      return 0.0;
    }
    return lb / kgToLbFactor;
  }

  /// Converts a canonical [weightKg] into the requested [unit].
  static double fromCanonicalKg(double weightKg, WeightUnit unit) {
    if (!isValidWeight(weightKg)) {
      return 0.0;
    }
    return unit == WeightUnit.kg ? weightKg : kgToLb(weightKg);
  }

  /// Converts an entered [value] in [unit] into canonical kilograms.
  /// Returns `null` if [value] is null, negative, or non-finite.
  static double? toCanonicalKg(double? value, WeightUnit unit) {
    if (value == null || !isValidWeight(value)) {
      return null;
    }
    return unit == WeightUnit.kg ? value : lbToKg(value);
  }
}
