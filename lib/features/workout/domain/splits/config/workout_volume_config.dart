import '../../../../onboarding/domain/entities/user_profile.dart';

/// Conservative defaults for sets, reps, and rest intervals.
/// These values serve as baseline generation defaults and remain 100% editable by the user.
class WorkoutVolumeConfig {
  WorkoutVolumeConfig._();

  // ── Beginner (Focus: motor control, form consistency, baseline adaptation) ──
  static const int beginnerCompoundSets = 3;
  static const String beginnerCompoundReps = '8-10';
  static const int beginnerCompoundRestSec = 90;

  static const int beginnerIsolationSets = 2;
  static const String beginnerIsolationReps = '10-12';
  static const int beginnerIsolationRestSec = 60;

  // ── Intermediate (Focus: progressive overload, hypertrophy volume) ────────
  static const int intermediateCompoundSets = 4;
  static const String intermediateCompoundReps = '6-8';
  static const int intermediateCompoundRestSec = 120;

  static const int intermediateIsolationSets = 3;
  static const String intermediateIsolationReps = '10-12';
  static const int intermediateIsolationRestSec = 60;

  // ── Advanced (Focus: high mechanical tension, metabolic fatigue) ──────────
  static const int advancedCompoundSets = 4;
  static const String advancedCompoundReps = '5-6';
  static const int advancedCompoundRestSec = 120;

  static const int advancedIsolationSets = 3;
  static const String advancedIsolationReps = '12-15';
  static const int advancedIsolationRestSec = 45;

  /// Returns recommended sets for a slot based on level and compound status.
  static int getSets({
    required FitnessLevel level,
    required bool isCompound,
  }) {
    return switch (level) {
      FitnessLevel.beginner =>
        isCompound ? beginnerCompoundSets : beginnerIsolationSets,
      FitnessLevel.intermediate =>
        isCompound ? intermediateCompoundSets : intermediateIsolationSets,
      FitnessLevel.advanced =>
        isCompound ? advancedCompoundSets : advancedIsolationSets,
    };
  }

  /// Returns recommended rep range for a slot based on level and compound status.
  static String getReps({
    required FitnessLevel level,
    required bool isCompound,
  }) {
    return switch (level) {
      FitnessLevel.beginner =>
        isCompound ? beginnerCompoundReps : beginnerIsolationReps,
      FitnessLevel.intermediate =>
        isCompound ? intermediateCompoundReps : intermediateIsolationReps,
      FitnessLevel.advanced =>
        isCompound ? advancedCompoundReps : advancedIsolationReps,
    };
  }

  /// Returns recommended rest interval in seconds for a slot.
  static int getRestSeconds({
    required FitnessLevel level,
    required bool isCompound,
  }) {
    return switch (level) {
      FitnessLevel.beginner =>
        isCompound ? beginnerCompoundRestSec : beginnerIsolationRestSec,
      FitnessLevel.intermediate =>
        isCompound ? intermediateCompoundRestSec : intermediateIsolationRestSec,
      FitnessLevel.advanced =>
        isCompound ? advancedCompoundRestSec : advancedIsolationRestSec,
    };
  }

  /// Deterministically estimates session duration in minutes.
  /// Formula: (totalSets * 45s work execution) + sum(restSeconds) + 5 min warm-up.
  static int estimateSessionDurationMinutes({
    required int totalSets,
    required int totalRestSeconds,
  }) {
    if (totalSets == 0) return 0;
    const workSecondsPerSet = 45;
    const warmUpSeconds = 5 * 60;
    final totalSeconds = (totalSets * workSecondsPerSet) + totalRestSeconds + warmUpSeconds;
    return (totalSeconds / 60).round();
  }
}
