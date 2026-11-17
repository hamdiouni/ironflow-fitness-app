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

    // Intermediate tracking maps (sets accumulated as fractional doubles and rounded once)
    final lastTrainedMap = <MuscleRegion, DateTime>{};
    final volume7dMap = <MuscleRegion, double>{};
    final rawSets7dMap = <MuscleRegion, double>{};
    final volume30dMap = <MuscleRegion, double>{};
    final rawSets30dMap = <MuscleRegion, double>{};
    final rpeWeightedSum7d = <MuscleRegion, double>{};
    final rpeWeightTotal7d = <MuscleRegion, double>{};
    final lastSessionDurationMinMap = <MuscleRegion, double>{};
    final recentExercisesMap = <MuscleRegion, List<String>>{};

    // Sort workouts ascending by date to process chronologically
    final sortedWorkouts = List<Workout>.from(workouts)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final workout in sortedWorkouts) {
      final workoutDate = workout.date;
      final sessionMinutes = workout.duration.inMinutes.toDouble();

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

        // Calculate working volume, sets, and logged RPE for this exercise
        double workingVolume = 0;
        int workingSets = 0;
        double exerciseRpeSum = 0;
        int exerciseRpeCount = 0;

        for (final set in exercise.sets) {
          // Warmups contribute minimal fatigue (20%), working sets contribute 100%
          final weightFactor = set.type == SetType.warmup ? 0.2 : 1.0;
          final setVolume = (set.weight * set.reps) * weightFactor;
          workingVolume += setVolume;
          if (set.type != SetType.warmup) {
            workingSets++;
            if (set.rpe != null) {
              exerciseRpeSum += set.rpe!.clamp(1, 10);
              exerciseRpeCount++;
            }
          }
        }

        if (workingSets == 0 && workingVolume == 0) continue;

        final avgExerciseRpe =
            exerciseRpeCount > 0 ? (exerciseRpeSum / exerciseRpeCount) : null;

        // Apply to primary regions (weight 1.0)
        for (final region in primaryRegions) {
          if (lastTrainedMap[region] == null ||
              !workoutDate.isBefore(lastTrainedMap[region]!)) {
            lastTrainedMap[region] = workoutDate;
            if (sessionMinutes > 0) {
              lastSessionDurationMinMap[region] = sessionMinutes;
            }
          }
          if (workoutDate.isAfter(sevenDaysAgo)) {
            volume7dMap[region] = (volume7dMap[region] ?? 0) + workingVolume;
            rawSets7dMap[region] =
                (rawSets7dMap[region] ?? 0) + workingSets.toDouble();
            if (avgExerciseRpe != null && workingSets > 0) {
              rpeWeightedSum7d[region] = (rpeWeightedSum7d[region] ?? 0) +
                  (avgExerciseRpe * workingSets);
              rpeWeightTotal7d[region] =
                  (rpeWeightTotal7d[region] ?? 0) + workingSets.toDouble();
            }
          }
          if (workoutDate.isAfter(thirtyDaysAgo)) {
            volume30dMap[region] = (volume30dMap[region] ?? 0) + workingVolume;
            rawSets30dMap[region] =
                (rawSets30dMap[region] ?? 0) + workingSets.toDouble();
          }
          final list = recentExercisesMap.putIfAbsent(region, () => []);
          if (!list.contains(exercise.name)) {
            list.insert(0, exercise.name);
            if (list.length > 5) list.removeLast();
          }
        }

        // Apply to secondary regions (weight 0.5 — accumulated fractionally before rounding)
        for (final region in secondaryRegions) {
          if (lastTrainedMap[region] == null ||
              !workoutDate.isBefore(lastTrainedMap[region]!)) {
            lastTrainedMap[region] = workoutDate;
            if (sessionMinutes > 0) {
              lastSessionDurationMinMap[region] = sessionMinutes;
            }
          }
          final fractionalSets = workingSets * 0.5;
          if (workoutDate.isAfter(sevenDaysAgo)) {
            volume7dMap[region] =
                (volume7dMap[region] ?? 0) + (workingVolume * 0.5);
            rawSets7dMap[region] =
                (rawSets7dMap[region] ?? 0) + fractionalSets;
            if (avgExerciseRpe != null && fractionalSets > 0) {
              rpeWeightedSum7d[region] = (rpeWeightedSum7d[region] ?? 0) +
                  (avgExerciseRpe * fractionalSets);
              rpeWeightTotal7d[region] =
                  (rpeWeightTotal7d[region] ?? 0) + fractionalSets;
            }
          }
          if (workoutDate.isAfter(thirtyDaysAgo)) {
            volume30dMap[region] =
                (volume30dMap[region] ?? 0) + (workingVolume * 0.5);
            rawSets30dMap[region] =
                (rawSets30dMap[region] ?? 0) + fractionalSets;
          }
          final list = recentExercisesMap.putIfAbsent(region, () => []);
          if (!list.contains(exercise.name)) {
            list.insert(0, exercise.name);
            if (list.length > 5) list.removeLast();
          }
        }
      }
    }

    // Build final recovery map for all 20 anatomical regions
    final result = <MuscleRegion, MuscleRecoveryData>{};

    for (final region in MuscleRegion.values) {
      final lastTrained = lastTrainedMap[region];
      final rawSets7d = rawSets7dMap[region] ?? 0.0;
      final sets7d = rawSets7d.round();
      final volume7d = volume7dMap[region] ?? 0;
      final sets30d = (rawSets30dMap[region] ?? 0.0).round();
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

      // Volume, RPE, and session-duration adjusted recovery window:
      // 1. Volume: Base hours + 5% per recent effective working set capped at 12 sets (+60%)
      // 2. RPE: Baseline 7.0 (1.0x), +/- 8% per RPE point when RPE is logged
      // 3. Duration: Baseline 60 min (1.0x), +/- 12% per 60 min deviation when duration > 0
      final baseHours = region.baseRecoveryHours.toDouble();
      final volumeMultiplier = 1.0 + (0.05 * math.min(rawSets7d, 12.0));
      final rpeWeight = rpeWeightTotal7d[region] ?? 0.0;
      final rpeMultiplier = rpeWeight > 0
          ? (1.0 + (((rpeWeightedSum7d[region]! / rpeWeight) - 7.0) * 0.08))
              .clamp(0.85, 1.30)
          : 1.0;
      final lastDurationMin = lastSessionDurationMinMap[region];
      final durationMultiplier =
          (lastDurationMin != null && lastDurationMin > 0)
              ? (1.0 + (((lastDurationMin - 60.0) / 60.0) * 0.12))
                  .clamp(0.85, 1.25)
              : 1.0;
      final requiredHours =
          baseHours * volumeMultiplier * rpeMultiplier * durationMultiplier;

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
