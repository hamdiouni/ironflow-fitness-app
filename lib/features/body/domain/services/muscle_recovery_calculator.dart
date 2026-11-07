import 'dart:math' as math;
import 'package:progression_tracker/features/workout/domain/entities/exercise_definition.dart';
import 'package:progression_tracker/features/workout/domain/entities/set_entry.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/services/exercise_catalog.dart';
import '../entities/muscle_recovery_status.dart';
import '../entities/muscle_region.dart';

/// Scientific recovery and volume load aggregator for the Body Map (Wave 4).
class MuscleRecoveryCalculator {
  const MuscleRecoveryCalculator();

  static final Map<String, (List<MuscleRegion>, List<MuscleRegion>)> _exerciseTargetCache = {};

  /// Calculates recovery metrics and volume history for all 20 anatomical regions
  /// based on the user's completed [workouts] and manual soreness flags.
  Map<MuscleRegion, MuscleRecoveryData> calculate({
    required List<Workout> workouts,
    Set<String> manualSoreRegionIds = const {},
    DateTime? referenceNow,
  }) {
    final now = referenceNow ?? DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Intermediate tracking maps
    final lastTrainedMap = <MuscleRegion, DateTime>{};
    final volume7dMap = <MuscleRegion, double>{};
    final sets7dMap = <MuscleRegion, int>{};
    final volume30dMap = <MuscleRegion, double>{};
    final sets30dMap = <MuscleRegion, int>{};
    final recentExercisesMap = <MuscleRegion, List<String>>{};

    // Sort workouts ascending by date to process chronologically
    final sortedWorkouts = List<Workout>.from(workouts)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final workout in sortedWorkouts) {
      final workoutDate = workout.date;

      for (final exercise in workout.exercises) {
        // Resolve definition to get canonical primary & secondary regions (memoized)
        final cacheKey = '${exercise.exerciseDefinitionId ?? ""}_${exercise.name}';
        var targets = _exerciseTargetCache[cacheKey];
        if (targets == null) {
          final definition = _resolveDefinition(
            exerciseDefinitionId: exercise.exerciseDefinitionId,
            name: exercise.name,
          );

          final p = <MuscleRegion>[];
          final s = <MuscleRegion>[];

          if (definition != null) {
            for (final id in definition.primaryRegions) {
              final region = MuscleRegion.fromId(id);
              if (region != null && !p.contains(region)) {
                p.add(region);
              }
            }
            for (final id in definition.secondaryRegions) {
              final region = MuscleRegion.fromId(id);
              if (region != null && !p.contains(region) && !s.contains(region)) {
                s.add(region);
              }
            }
          }

          // If definition had no regions or was uncataloged, infer from coarse muscle group
          if (p.isEmpty && definition != null) {
            final fallback = inferFromMuscleGroup(definition.muscleGroup);
            p.addAll(fallback);
          }

          targets = (p, s);
          _exerciseTargetCache[cacheKey] = targets;
        }

        final primaryRegions = targets.$1;
        final secondaryRegions = targets.$2;

        if (primaryRegions.isEmpty && secondaryRegions.isEmpty) {
          continue;
        }

        // Calculate working volume and sets for this exercise
        double workingVolume = 0;
        int workingSets = 0;

        for (final set in exercise.sets) {
          // Warmups contribute minimal fatigue (20%), working sets contribute 100%
          final weightFactor = set.type == SetType.warmup ? 0.2 : 1.0;
          final setVolume = (set.weight * set.reps) * weightFactor;
          workingVolume += setVolume;
          if (set.type != SetType.warmup) {
            workingSets++;
          }
        }

        if (workingSets == 0 && workingVolume == 0) continue;

        // Apply to primary regions (weight 1.0)
        for (final region in primaryRegions) {
          if (lastTrainedMap[region] == null ||
              workoutDate.isAfter(lastTrainedMap[region]!)) {
            lastTrainedMap[region] = workoutDate;
          }
          if (workoutDate.isAfter(sevenDaysAgo)) {
            volume7dMap[region] = (volume7dMap[region] ?? 0) + workingVolume;
            sets7dMap[region] = (sets7dMap[region] ?? 0) + workingSets;
          }
          if (workoutDate.isAfter(thirtyDaysAgo)) {
            volume30dMap[region] = (volume30dMap[region] ?? 0) + workingVolume;
            sets30dMap[region] = (sets30dMap[region] ?? 0) + workingSets;
          }
          final list = recentExercisesMap.putIfAbsent(region, () => []);
          if (!list.contains(exercise.name)) {
            list.insert(0, exercise.name);
            if (list.length > 5) list.removeLast();
          }
        }

        // Apply to secondary regions (weight 0.5)
        for (final region in secondaryRegions) {
          if (lastTrainedMap[region] == null ||
              workoutDate.isAfter(lastTrainedMap[region]!)) {
            lastTrainedMap[region] = workoutDate;
          }
          if (workoutDate.isAfter(sevenDaysAgo)) {
            volume7dMap[region] =
                (volume7dMap[region] ?? 0) + (workingVolume * 0.5);
            sets7dMap[region] =
                (sets7dMap[region] ?? 0) + ((workingSets * 0.5).round());
          }
          if (workoutDate.isAfter(thirtyDaysAgo)) {
            volume30dMap[region] =
                (volume30dMap[region] ?? 0) + (workingVolume * 0.5);
            sets30dMap[region] =
                (sets30dMap[region] ?? 0) + ((workingSets * 0.5).round());
          }
          final list = recentExercisesMap.putIfAbsent(region, () => []);
          if (!list.contains(exercise.name)) {
            list.insert(0, exercise.name);
            if (list.length > 5) list.removeLast();
          }
        }
      }
    }

    // Build final telemetry map for all 20 anatomical regions
    final result = <MuscleRegion, MuscleRecoveryData>{};

    for (final region in MuscleRegion.values) {
      final lastTrained = lastTrainedMap[region];
      final sets7d = sets7dMap[region] ?? 0;
      final volume7d = volume7dMap[region] ?? 0;
      final sets30d = sets30dMap[region] ?? 0;
      final volume30d = volume30dMap[region] ?? 0;
      final recentExercises = recentExercisesMap[region] ?? const [];
      final isManuallySore = manualSoreRegionIds.contains(region.id);

      if (lastTrained == null) {
        if (isManuallySore) {
          result[region] = MuscleRecoveryData(
            region: region,
            score: 0.35,
            tier: RecoveryTier.sore,
            hoursSinceTrained: null,
            estimatedHoursRemaining: 24,
            lastTrainedDate: null,
            volumeLoad7Days: 0,
            sets7Days: 0,
            volumeLoad30Days: 0,
            sets30Days: 0,
            isManuallyMarkedSore: true,
            recentExercises: const [],
          );
        } else {
          result[region] = MuscleRecoveryData.fresh(region);
        }
        continue;
      }

      final diff = now.difference(lastTrained);
      final elapsedHours = math.max(0.0, diff.inMinutes / 60.0);

      // Volume-adjusted recovery window:
      // Base hours + 5% per recent working set capped at 12 sets (+60%)
      final baseHours = region.baseRecoveryHours.toDouble();
      final volumeMultiplier = 1.0 + (0.05 * math.min(sets7d, 12));
      final requiredHours = baseHours * volumeMultiplier;

      double score = math.min(1.0, elapsedHours / requiredHours);
      score = (score * 100).round() / 100.0;

      int remainingHours = 0;
      if (score < 1.0) {
        remainingHours = math.max(1, ((1.0 - score) * requiredHours).round());
      }

      RecoveryTier tier;
      if (isManuallySore) {
        tier = RecoveryTier.sore;
        score = math.min(score, 0.30);
        remainingHours = math.max(12, remainingHours);
      } else if (score >= 0.90) {
        tier = RecoveryTier.fresh;
        remainingHours = 0;
      } else if (score >= 0.50) {
        tier = RecoveryTier.recovering;
      } else {
        tier = RecoveryTier.fatigued;
      }

      result[region] = MuscleRecoveryData(
        region: region,
        score: score,
        tier: tier,
        hoursSinceTrained: (elapsedHours * 10).round() / 10.0,
        estimatedHoursRemaining: remainingHours,
        lastTrainedDate: lastTrained,
        volumeLoad7Days: (volume7d * 10).round() / 10.0,
        sets7Days: sets7d,
        volumeLoad30Days: (volume30d * 10).round() / 10.0,
        sets30Days: sets30d,
        isManuallyMarkedSore: isManuallySore,
        recentExercises: recentExercises,
      );
    }

    return result;
  }

  ExerciseDefinition? _resolveDefinition({
    String? exerciseDefinitionId,
    required String name,
  }) {
    if (exerciseDefinitionId != null && exerciseDefinitionId.isNotEmpty) {
      final fromCatalog = ExerciseCatalog.getById(
        exerciseDefinitionId,
        exerciseName: name,
      );
      if (fromCatalog != null) return fromCatalog;
    }

    final byName = ExerciseCatalog.getByName(name);
    if (byName != null) return byName;

    return null;
  }

  /// Resolves the muscle regions targeted by an exercise name or definition ID.
  static List<MuscleRegion> resolveRegionsForExercise({
    String? exerciseDefinitionId,
    required String name,
  }) {
    ExerciseDefinition? definition;
    if (exerciseDefinitionId != null && exerciseDefinitionId.isNotEmpty) {
      definition = ExerciseCatalog.getById(
        exerciseDefinitionId,
        exerciseName: name,
      );
    }
    definition ??= ExerciseCatalog.getByName(name);

    final regions = <MuscleRegion>[];
    if (definition != null) {
      for (final id in definition.primaryRegions) {
        final r = MuscleRegion.fromId(id);
        if (r != null && !regions.contains(r)) {
          regions.add(r);
        }
      }
      for (final id in definition.secondaryRegions) {
        final r = MuscleRegion.fromId(id);
        if (r != null && !regions.contains(r)) {
          regions.add(r);
        }
      }
      if (regions.isEmpty) {
        regions.addAll(inferFromMuscleGroup(definition.muscleGroup));
      }
    }
    return regions;
  }

  static List<MuscleRegion> inferFromMuscleGroup(MuscleGroup group) {
    return switch (group) {
      MuscleGroup.chest => [MuscleRegion.chest],
      MuscleGroup.back => [MuscleRegion.lats, MuscleRegion.middleBack],
      MuscleGroup.shoulders => [MuscleRegion.frontDelts, MuscleRegion.sideDelts],
      MuscleGroup.arms => [MuscleRegion.biceps, MuscleRegion.triceps],
      MuscleGroup.legs => [MuscleRegion.quads, MuscleRegion.hamstrings],
      MuscleGroup.glutes => [MuscleRegion.glutes],
      MuscleGroup.abs => [MuscleRegion.upperAbs, MuscleRegion.lowerAbs],
      _ => const [],
    };
  }
}
