import 'package:flutter/material.dart';

import '../../../../../core/constants/app_theme.dart';
import '../../../../../shared/animations/pr_celebration_animation.dart';
import '../../../../../shared/presentation/components/app_card.dart';
import '../../../domain/entities/exercise.dart';
import '../../../domain/entities/set_entry.dart';
import '../../../domain/usecases/workout_metrics.dart';

/// Section 1: Result card showing time (Duration), working sets (Sets), and working volume (Volume).
class WorkoutSummaryResultCard extends StatelessWidget {
  final int totalExercises;
  final int totalSets;
  final double totalVolume;
  final Duration duration;

  const WorkoutSummaryResultCard({
    super.key,
    required this.totalExercises,
    required this.totalSets,
    required this.totalVolume,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.kineticAccent.withValues(alpha: 0.16),
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 40,
              color: tokens.kineticAccent,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            'Workout Complete!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              fontFamily: AppTypography.displayFontFamily,
              color: tokens.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Great job! Here\'s your summary',
            style: TextStyle(
              fontSize: 13,
              fontFamily: AppTypography.bodyFontFamily,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // Primary result metrics in canonical order: Time (Duration), Working Sets (Sets), Working Volume (Volume)
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.timer_outlined,
                  value: _formatDuration(duration),
                  label: 'Duration',
                  color: tokens.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  icon: Icons.repeat,
                  value: '$totalSets',
                  label: totalSets == 1 ? 'Set' : 'Sets',
                  color: tokens.cyanAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.monitor_weight_outlined,
                  value: _formatVolume(totalVolume),
                  label: 'Volume',
                  color: tokens.violetAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  icon: Icons.fitness_center,
                  value: '$totalExercises',
                  label: totalExercises == 1 ? 'Exercise' : 'Exercises',
                  color: tokens.kineticAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatVolume(double volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}k kg';
    }
    return '${volume.toStringAsFixed(0)} kg';
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes == 0) {
      return '${seconds}s';
    }
    if (seconds == 0) {
      return '${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }
}

/// Section 2: Real Personal Records section.
class PersonalRecordsSection extends StatelessWidget {
  final int prCount;

  const PersonalRecordsSection({
    super.key,
    required this.prCount,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        children: [
          PRCelebrationAnimation(prCount: prCount),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  '$prCount Personal ${prCount == 1 ? 'Record' : 'Records'} Achieved',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual metric tile inside the Result card.
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(tokens.radiusLg),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.85),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Section 3: Collapsed exercise set lists.
class ExerciseBreakdownCard extends StatelessWidget {
  final List<Exercise> exercises;
  final List<String> exerciseNames;

  const ExerciseBreakdownCard({
    super.key,
    required this.exercises,
    required this.exerciseNames,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final itemCount =
        exercises.isNotEmpty ? exercises.length : exerciseNames.length;

    return AppCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.list_alt,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Exercises Completed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(itemCount, (index) {
            final exercise =
                index < exercises.length ? exercises[index] : null;
            final name = exercise?.name ?? exerciseNames[index];
            final workingSetCount = exercise != null
                ? WorkoutMetrics.workingSetsForExercise(exercise).length
                : null;
            final allSets = exercise?.sets ?? const <SetEntry>[];

            return Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
              ),
              child: ExpansionTile(
                key: Key('summary_exercise_tile_$index'),
                initiallyExpanded: false,
                tilePadding: EdgeInsets.zero,
                childrenPadding:
                    const EdgeInsets.only(left: 36, right: 8, bottom: 8),
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                  ),
                ),
                subtitle: workingSetCount != null
                    ? Text(
                        '$workingSetCount working ${workingSetCount == 1 ? 'set' : 'sets'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    : null,
                children: allSets.isEmpty
                    ? [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Completed in session',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ]
                    : allSets.asMap().entries.map((entry) {
                        final setIdx = entry.key + 1;
                        final set = entry.value;
                        final prefix = set.type == SetType.warmup
                            ? 'Warm-up $setIdx'
                            : 'Set $setIdx';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prefix,
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                '${set.weight.toStringAsFixed(1)} kg × ${set.reps}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}

