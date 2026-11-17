import 'dart:math' as math;

import '../entities/exercise.dart';
import '../entities/set_entry.dart';
import '../entities/workout.dart';

/// Formula used to estimate a one-rep max.
enum E1rmFormula { epley, brzycki }

/// One point of an exercise's estimated-1RM history (best set per session).
class E1rmPoint {
  const E1rmPoint({
    required this.date,
    required this.e1rm,
    required this.weight,
    required this.reps,
  });

  final DateTime date;
  final double e1rm;
  final double weight;
  final int reps;
}

/// Single source of truth for estimated one-rep max (Wave 8.3, ADR-004).
///
/// Rules:
/// * Reps are capped at [maxRepCap] (10) so light high-rep sets do not
///   out-rank heavy strength sets (same rule as `WorkoutMetrics`).
/// * A 1-rep set returns the lifted weight exactly.
/// * Warm-up and drop sets never count: warm-ups are sub-maximal and drop
///   sets are done pre-fatigued, so both would distort the estimate.
class E1rmEngine {
  const E1rmEngine._();

  static const int maxRepCap = 10;

  /// Estimated 1RM for a single [weight] x [reps] set. Invalid input → 0.
  static double estimate(
    double weight,
    int reps, {
    E1rmFormula formula = E1rmFormula.epley,
  }) {
    if (!weight.isFinite || weight <= 0 || reps <= 0) return 0.0;
    if (reps == 1) return weight;
    final capped = math.min(reps, maxRepCap);
    return switch (formula) {
      E1rmFormula.epley => weight * (1.0 + capped / 30.0),
      E1rmFormula.brzycki => weight * 36.0 / (37.0 - capped),
    };
  }

  /// Working weight expected for [reps] given an [e1rm] (inverse Epley).
  static double weightForReps(double e1rm, int reps) {
    if (!e1rm.isFinite || e1rm <= 0 || reps <= 0) return 0.0;
    if (reps == 1) return e1rm;
    final capped = math.min(reps, maxRepCap);
    return e1rm / (1.0 + capped / 30.0);
  }

  /// Whether [set] may drive an e1RM estimate.
  static bool countsForE1rm(SetEntry set) {
    return set.type != SetType.warmup &&
        set.type != SetType.drop &&
        set.reps > 0 &&
        set.weight.isFinite &&
        set.weight > 0;
  }

  /// Best e1RM across [sets], or null when no set counts.
  static SetEntry? bestSet(Iterable<SetEntry> sets) {
    SetEntry? best;
    var bestValue = 0.0;
    for (final set in sets) {
      if (!countsForE1rm(set)) continue;
      final value = estimate(set.weight, set.reps);
      if (value > bestValue) {
        bestValue = value;
        best = set;
      }
    }
    return best;
  }

  /// Best e1RM for [exercise] (0 when nothing counts).
  static double bestForExercise(Exercise exercise) {
    final best = bestSet(exercise.sets);
    return best == null ? 0.0 : estimate(best.weight, best.reps);
  }

  /// Stable identity used to match one exercise across sessions.
  static String identityOf(Exercise exercise) {
    final id = exercise.exerciseDefinitionId;
    if (id != null && id.isNotEmpty) return id;
    return exercise.name.trim().toLowerCase();
  }

  /// Best e1RM per session for [exerciseKey] (catalog id or lower-case name),
  /// oldest first. Sessions with no qualifying set are skipped.
  static List<E1rmPoint> trend(Iterable<Workout> workouts, String exerciseKey) {
    final key = exerciseKey.trim().toLowerCase();
    final points = <E1rmPoint>[];
    for (final workout in workouts) {
      if (workout.deletedAt != null) continue;
      SetEntry? sessionBest;
      var sessionValue = 0.0;
      for (final exercise in workout.exercises) {
        final matches = identityOf(exercise).toLowerCase() == key ||
            exercise.name.trim().toLowerCase() == key;
        if (!matches) continue;
        final best = bestSet(exercise.sets);
        if (best == null) continue;
        final value = estimate(best.weight, best.reps);
        if (value > sessionValue) {
          sessionValue = value;
          sessionBest = best;
        }
      }
      if (sessionBest != null) {
        points.add(E1rmPoint(
          date: workout.date,
          e1rm: sessionValue,
          weight: sessionBest.weight,
          reps: sessionBest.reps,
        ));
      }
    }
    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }
}

/// A top set followed by its drop sets.
class DropSetChain {
  const DropSetChain({required this.topSet, required this.drops});

  final SetEntry topSet;
  final List<SetEntry> drops;

  bool get hasDrops => drops.isNotEmpty;

  int get totalReps =>
      topSet.reps + drops.fold<int>(0, (sum, s) => sum + s.reps);

  double get totalVolume =>
      topSet.weight * topSet.reps +
      drops.fold<double>(0, (sum, s) => sum + s.weight * s.reps);
}

/// Drop-set planning and grouping (Wave 8.3, ADR-004).
class DropSetPlanner {
  const DropSetPlanner._();

  /// Weights for [drops] drop sets after a top set at [startWeight], each
  /// [dropPercent] lighter than the previous one and rounded down to
  /// [increment]. Stops early instead of returning zero or repeated weights.
  static List<double> plan({
    required double startWeight,
    int drops = 2,
    double dropPercent = 0.2,
    double increment = 2.5,
  }) {
    if (!startWeight.isFinite || startWeight <= 0 || drops <= 0) return [];
    final percent = dropPercent.clamp(0.05, 0.5);
    final step = increment > 0 ? increment : 2.5;
    final result = <double>[];
    var previous = startWeight;
    for (var i = 0; i < drops; i++) {
      final raw = previous * (1 - percent);
      final rounded = (raw / step).floor() * step;
      if (rounded <= 0 || rounded >= previous) break;
      result.add(rounded);
      previous = rounded;
    }
    return result;
  }

  /// Groups [sets] into chains: every non-warm-up, non-drop set starts a
  /// chain and the drop sets right after it belong to it. Warm-ups are
  /// skipped; a drop set with no preceding top set starts its own chain.
  static List<DropSetChain> chains(List<SetEntry> sets) {
    final result = <DropSetChain>[];
    SetEntry? top;
    var drops = <SetEntry>[];
    void flush() {
      if (top != null) result.add(DropSetChain(topSet: top!, drops: drops));
      top = null;
      drops = <SetEntry>[];
    }

    for (final set in sets) {
      if (set.type == SetType.warmup) continue;
      if (set.type == SetType.drop && top != null) {
        drops.add(set);
      } else {
        flush();
        top = set;
      }
    }
    flush();
    return result;
  }
}

/// One block of the session: a single exercise or a superset.
class ExerciseBlock {
  const ExerciseBlock({required this.indices, this.groupId, this.letter});

  /// Indices into the workout's exercise list, in order.
  final List<int> indices;
  final String? groupId;

  /// `A`, `B`, ... for supersets; null for single exercises.
  final String? letter;

  bool get isSuperset => groupId != null && indices.length > 1;
}

/// Superset linking and rotation (Wave 8.3, ADR-004).
///
/// A superset is two or more **adjacent** exercises with the same non-null
/// `supersetGroupId`. A lone exercise carrying an id is treated as single.
class SupersetEngine {
  const SupersetEngine._();

  /// Splits [exercises] into ordered blocks and assigns letters A, B, C...
  static List<ExerciseBlock> blocks(List<Exercise> exercises) {
    final raw = <List<int>>[];
    for (var i = 0; i < exercises.length; i++) {
      final id = exercises[i].supersetGroupId;
      if (id != null &&
          raw.isNotEmpty &&
          exercises[raw.last.last].supersetGroupId == id) {
        raw.last.add(i);
      } else {
        raw.add([i]);
      }
    }
    var letterIndex = 0;
    return [
      for (final indices in raw)
        if (indices.length > 1)
          ExerciseBlock(
            indices: indices,
            groupId: exercises[indices.first].supersetGroupId,
            letter: _letter(letterIndex++),
          )
        else
          ExerciseBlock(indices: indices),
    ];
  }

  static String _letter(int index) {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return index < letters.length ? letters[index] : 'S${index + 1}';
  }

  static ExerciseBlock? _blockOf(List<Exercise> exercises, int index) {
    if (index < 0 || index >= exercises.length) return null;
    for (final block in blocks(exercises)) {
      if (block.indices.contains(index)) return block;
    }
    return null;
  }

  /// `A1`, `A2`, `B1`... for superset members, null otherwise.
  static String? labelFor(List<Exercise> exercises, int index) {
    final block = _blockOf(exercises, index);
    if (block == null || !block.isSuperset) return null;
    return '${block.letter}${block.indices.indexOf(index) + 1}';
  }

  /// Whether exercises at [upperIndex] and [upperIndex] + 1 are linked.
  static bool isLinkedWithNext(List<Exercise> exercises, int upperIndex) {
    if (upperIndex < 0 || upperIndex + 1 >= exercises.length) return false;
    final a = exercises[upperIndex].supersetGroupId;
    return a != null && a == exercises[upperIndex + 1].supersetGroupId;
  }

  /// Links or unlinks [upperIndex] with the exercise right below it.
  ///
  /// * Linking joins the existing group of either neighbour, or creates a
  ///   new group id from [newGroupId].
  /// * Unlinking splits the group at that point; any side left with one
  ///   exercise loses its id so no orphan ids are stored.
  static List<Exercise> toggleLinkWithNext(
    List<Exercise> exercises,
    int upperIndex, {
    required String Function() newGroupId,
  }) {
    if (upperIndex < 0 || upperIndex + 1 >= exercises.length) {
      return exercises;
    }
    final list = List<Exercise>.of(exercises);
    if (isLinkedWithNext(list, upperIndex)) {
      final oldId = list[upperIndex].supersetGroupId!;
      final freshId = newGroupId();
      for (var i = upperIndex + 1;
          i < list.length && list[i].supersetGroupId == oldId;
          i++) {
        list[i] = list[i].copyWith(supersetGroupId: freshId);
      }
      return _clearSingletons(list);
    }
    final upperId = list[upperIndex].supersetGroupId;
    final lowerId = list[upperIndex + 1].supersetGroupId;
    final upperInGroup = upperId != null &&
        upperIndex > 0 &&
        list[upperIndex - 1].supersetGroupId == upperId;
    final targetId = upperInGroup ? upperId : (lowerId ?? newGroupId());
    list[upperIndex] = list[upperIndex].copyWith(supersetGroupId: targetId);
    if (lowerId != null && lowerId != targetId) {
      for (var i = upperIndex + 1;
          i < list.length && list[i].supersetGroupId == lowerId;
          i++) {
        list[i] = list[i].copyWith(supersetGroupId: targetId);
      }
    } else {
      list[upperIndex + 1] =
          list[upperIndex + 1].copyWith(supersetGroupId: targetId);
    }
    return _clearSingletons(list);
  }

  static List<Exercise> _clearSingletons(List<Exercise> list) {
    final result = List<Exercise>.of(list);
    for (final block in blocks(result)) {
      if (block.indices.length == 1) {
        final i = block.indices.single;
        if (result[i].supersetGroupId != null) {
          result[i] = result[i].copyWith(supersetGroupId: null);
        }
      }
    }
    return result;
  }

  /// After a set on [index], the exercise to focus next inside its superset
  /// (next member, wrapping to the first), or null when not in a superset.
  static int? nextInRotation(List<Exercise> exercises, int index) {
    final block = _blockOf(exercises, index);
    if (block == null || !block.isSuperset) return null;
    final position = block.indices.indexOf(index);
    return block.indices[(position + 1) % block.indices.length];
  }

  /// Whether a rest should start after logging a set of [type] on [index].
  ///
  /// * Drop sets are done back-to-back → no rest.
  /// * Inside a superset, rest only after the last member of the round.
  static bool shouldRestAfter(
    List<Exercise> exercises,
    int index, {
    SetType type = SetType.normal,
  }) {
    if (type == SetType.drop) return false;
    final block = _blockOf(exercises, index);
    if (block == null || !block.isSuperset) return true;
    return block.indices.last == index;
  }
}
