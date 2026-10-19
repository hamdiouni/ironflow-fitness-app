import '../../../../onboarding/domain/entities/user_profile.dart';
import '../../../data/exercise_database.dart';
import '../../entities/exercise_definition.dart';
import '../entities/movement_pattern.dart';

/// Result of an exercise selection for a slot.
class SelectedSlotExercise {
  const SelectedSlotExercise({
    required this.exerciseName,
    this.notes,
    this.isSubstitute = false,
  });

  final String exerciseName;
  final String? notes;
  final bool isSubstitute;
}

/// Pure, deterministic exercise selector.
/// Given a slot, user profile, and history of chosen exercises, returns the best candidate.
class DeterministicExerciseSelector {
  const DeterministicExerciseSelector();

  SelectedSlotExercise? selectExerciseForSlot({
    required SlotDefinition slot,
    required EquipmentType equipment,
    required FitnessLevel level,
    required FitnessGoal goal,
    required Set<String> usedInDay,
    required Set<String> usedInProgram,
  }) {
    final isHome = equipment == EquipmentType.home;

    // Filter database candidates
    final candidates = ExerciseDatabase.all.where((e) {
      // 1. Equipment check
      if (isHome) {
        final isHomeFriendly = e.equipment == Equipment.bodyweight ||
            e.equipment == Equipment.dumbbell ||
            e.equipment == Equipment.band;
        if (!isHomeFriendly) return false;
      }

      // 2. Muscle match (Primary or in primaryMuscles list)
      final matchesMuscle = e.muscleGroup == slot.primaryMuscle ||
          e.primaryMuscles.contains(slot.primaryMuscle);
      if (!matchesMuscle) return false;

      // 3. Movement pattern heuristics
      if (!_matchesPattern(e, slot.pattern)) return false;

      return true;
    }).toList();

    // Deterministic sorting score (higher score = better rank)
    int scoreCandidate(ExerciseDefinition e) {
      int score = 0;

      // Penalize already used in program to preserve variety
      if (usedInProgram.contains(e.name)) {
        score -= 50;
      }
      // Strictly avoid if already used today
      if (usedInDay.contains(e.name)) {
        score -= 500;
      }

      // Level preference
      if (level == FitnessLevel.beginner) {
        if (e.difficulty == Difficulty.beginner) score += 30;
        if (e.difficulty == Difficulty.intermediate) score += 15;
        if (e.difficulty == Difficulty.advanced) score -= 30;
      } else if (level == FitnessLevel.intermediate) {
        if (e.difficulty == Difficulty.intermediate) score += 30;
        if (e.difficulty == Difficulty.beginner) score += 20;
        if (e.difficulty == Difficulty.advanced) score += 10;
      } else {
        if (e.difficulty == Difficulty.advanced) score += 30;
        if (e.difficulty == Difficulty.intermediate) score += 25;
        if (e.difficulty == Difficulty.beginner) score += 10;
      }

      // Compound vs isolation preference
      final isBarbellOrDumbbellCompound = e.equipment == Equipment.barbell ||
          e.equipment == Equipment.dumbbell ||
          e.equipment == Equipment.bodyweight;
      if (slot.isCompound && isBarbellOrDumbbellCompound) {
        score += 20;
      }

      return score;
    }

    candidates.sort((a, b) {
      final scoreA = scoreCandidate(a);
      final scoreB = scoreCandidate(b);
      if (scoreA != scoreB) return scoreB.compareTo(scoreA);
      // Alphabetical tie-breaker for strict determinism
      return a.name.compareTo(b.name);
    });

    if (candidates.isNotEmpty && !usedInDay.contains(candidates.first.name)) {
      return SelectedSlotExercise(
        exerciseName: candidates.first.name,
        notes: slot.notes,
      );
    }

    // Fallback for documented gaps (e.g. Home Hamstrings)
    if (isHome && slot.pattern == MovementPattern.hipHinge) {
      final gluteFallback = ExerciseDatabase.all.firstWhere(
        (e) => (e.name == 'Glute Bridge' || e.name == 'Single-Leg Hip Thrust') &&
            !usedInDay.contains(e.name),
        orElse: () => ExerciseDatabase.all.firstWhere((e) => e.name == 'Glute Bridge'),
      );
      return SelectedSlotExercise(
        exerciseName: gluteFallback.name,
        notes: 'Home substitute: Glute/hamstring bridge for posterior chain.',
        isSubstitute: true,
      );
    }

    if (candidates.isNotEmpty) {
      return SelectedSlotExercise(
        exerciseName: candidates.first.name,
        notes: slot.notes,
      );
    }

    // No matching exercise found
    return null;
  }

  static bool _matchesPattern(ExerciseDefinition e, MovementPattern pattern) {
    final lowerName = e.name.toLowerCase();
    final lowerSub = e.subMuscle.toLowerCase();

    switch (pattern) {
      case MovementPattern.horizontalPush:
        return lowerName.contains('bench') ||
            lowerName.contains('push-up') ||
            lowerName.contains('fly') ||
            lowerName.contains('chest') ||
            lowerName.contains('press') ||
            e.muscleGroup == MuscleGroup.chest;

      case MovementPattern.verticalPush:
        return lowerName.contains('shoulder') ||
            lowerName.contains('overhead') ||
            lowerName.contains('arnold') ||
            lowerName.contains('pike') ||
            e.muscleGroup == MuscleGroup.shoulders;

      case MovementPattern.horizontalPull:
        return lowerName.contains('row') ||
            (e.muscleGroup == MuscleGroup.back && !lowerName.contains('pulldown') && !lowerName.contains('pull-up'));

      case MovementPattern.verticalPull:
        return lowerName.contains('pull-up') ||
            lowerName.contains('chin-up') ||
            lowerName.contains('pulldown') ||
            lowerName.contains('lat');

      case MovementPattern.kneeDominant:
        return lowerName.contains('squat') ||
            lowerName.contains('lunge') ||
            lowerName.contains('leg press') ||
            lowerName.contains('step up') ||
            lowerSub.contains('quad');

      case MovementPattern.hipHinge:
        return lowerName.contains('deadlift') ||
            lowerName.contains('hinge') ||
            lowerName.contains('curl') ||
            lowerName.contains('bridge') ||
            lowerName.contains('thrust') ||
            lowerSub.contains('hamstring') ||
            e.muscleGroup == MuscleGroup.glutes;

      case MovementPattern.deltoidIsolation:
        return lowerName.contains('lateral') ||
            lowerName.contains('raise') ||
            lowerName.contains('face pull') ||
            lowerName.contains('reverse fly') ||
            lowerName.contains('shrug');

      case MovementPattern.bicepIsolation:
        return lowerName.contains('curl') ||
            lowerSub.contains('biceps') ||
            lowerSub.contains('brachialis');

      case MovementPattern.tricepIsolation:
        return lowerName.contains('tricep') ||
            lowerName.contains('dip') ||
            lowerName.contains('pushdown') ||
            lowerName.contains('extension') ||
            lowerSub.contains('triceps');

      case MovementPattern.calfIsolation:
        return lowerName.contains('calf') || lowerSub.contains('gastrocnemius');

      case MovementPattern.core:
        return e.muscleGroup == MuscleGroup.abs ||
            lowerName.contains('plank') ||
            lowerName.contains('crunch') ||
            lowerName.contains('raise') ||
            lowerName.contains('twist');

      case MovementPattern.fullBodyCardio:
        return e.muscleGroup == MuscleGroup.cardio ||
            e.muscleGroup == MuscleGroup.fullBody;
    }
  }
}
