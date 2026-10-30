import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/animations/pr_celebration_animation.dart';
import '../../../../shared/presentation/components/app_button.dart';
import '../../../../shared/presentation/components/app_card.dart';
import '../../../../shared/presentation/services/app_haptics.dart';
import '../../domain/entities/active_program.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/set_entry.dart';
import '../../domain/entities/workout.dart';
import '../../domain/entities/workout_program.dart';
import '../../domain/usecases/workout_metrics.dart';
import '../providers/active_program_providers.dart';
import '../providers/workout_providers.dart';
import '../widgets/progression_suggestion_card.dart';

/// Displays the post-workout summary with Wave 2 canonical ordering:
/// 1. Result (time / Duration, working sets / Sets, working volume / Volume)
/// 2. Real PRs
/// 3. Collapsed exercise set lists
/// 4. Next-time progression suggestions (Accept, Skip, safe Undo)
/// 5. Done
///
/// Supports loading a saved workout by [workoutId] after refresh or from a
/// direct web link (`/workout/summary?workoutId=<id>` or `/workout/summary/<id>`).
class WorkoutSummaryScreen extends ConsumerStatefulWidget {
  const WorkoutSummaryScreen({
    this.workoutId,
    this.exercises = const [],
    this.totalSets = 0,
    this.totalVolume = 0.0,
    this.duration = Duration.zero,
    this.prCount = 0,
    this.exerciseNames = const [],
    super.key,
  });

  final String? workoutId;
  final List<Exercise> exercises;
  final int totalSets;
  final double totalVolume;
  final Duration duration;
  final int prCount;
  final List<String> exerciseNames;

  @override
  ConsumerState<WorkoutSummaryScreen> createState() =>
      _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends ConsumerState<WorkoutSummaryScreen> {
  Workout? _loadedWorkout;
  bool _loadingWorkoutById = false;

  @override
  void initState() {
    super.initState();
    if (widget.prCount > 0) {
      AppHaptics.shared.milestoneReached(milestoneId: 'workout_pr');
    }
    if (widget.workoutId != null && widget.workoutId!.trim().isNotEmpty) {
      _loadWorkoutFromRepository(widget.workoutId!.trim());
    }
  }

  Future<void> _loadWorkoutFromRepository(String id) async {
    setState(() {
      _loadingWorkoutById = true;
    });
    try {
      final repo = ref.read(workoutRepositoryProvider);
      final all = await repo.getAllWorkouts();
      final match = all.where((w) => w.id == id).firstOrNull;
      if (mounted) {
        setState(() {
          _loadedWorkout = match;
          _loadingWorkoutById = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingWorkoutById = false;
        });
      }
    }
  }

  void _navigateHome() {
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  Workout? _resolveWorkout(AsyncValue<List<Workout>>? historyAsync) {
    final targetId = widget.workoutId?.trim();
    if (targetId == null || targetId.isEmpty) {
      return null;
    }
    final fromHistory =
        historyAsync?.valueOrNull?.where((w) => w.id == targetId).firstOrNull;
    return fromHistory ?? _loadedWorkout;
  }

  @override
  Widget build(BuildContext context) {
    final hasWorkoutId =
        widget.workoutId != null && widget.workoutId!.trim().isNotEmpty;
    final historyAsync =
        hasWorkoutId ? ref.watch(workoutHistoryProvider) : null;
    final savedWorkout = _resolveWorkout(historyAsync);

    if (hasWorkoutId &&
        savedWorkout == null &&
        (_loadingWorkoutById || (historyAsync?.isLoading ?? false))) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final effectiveDuration = savedWorkout?.duration ?? widget.duration;
    final effectiveTotalSets = savedWorkout != null
        ? WorkoutMetrics.workingSetCount(savedWorkout)
        : widget.totalSets;
    final effectiveTotalVolume = savedWorkout != null
        ? WorkoutMetrics.calculateWorkoutVolume(savedWorkout)
        : widget.totalVolume;
    final effectiveExercises = savedWorkout != null
        ? savedWorkout.exercises
        : widget.exercises;
    final effectiveExerciseNames = effectiveExercises.isNotEmpty
        ? effectiveExercises.map((e) => e.name).toList(growable: false)
        : widget.exerciseNames;
    final effectivePrCount = widget.prCount;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // 1. RESULT SECTION (Time / Duration, Working Sets, Working Volume)
              _WorkoutSummaryResultCard(
                key: const Key('summary_section_result'),
                totalExercises: effectiveExerciseNames.length,
                totalSets: effectiveTotalSets,
                totalVolume: effectiveTotalVolume,
                duration: effectiveDuration,
              ),

              // 2. REAL PRS SECTION
              if (effectivePrCount > 0) ...[
                const SizedBox(height: AppTheme.spacingMedium),
                _PersonalRecordsSection(
                  key: const Key('summary_section_prs'),
                  prCount: effectivePrCount,
                ),
              ],

              // 3. COLLAPSED EXERCISE SETS SECTION
              if (effectiveExercises.isNotEmpty ||
                  effectiveExerciseNames.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingLarge),
                _ExerciseBreakdownCard(
                  key: const Key('summary_section_exercises'),
                  exercises: effectiveExercises,
                  exerciseNames: effectiveExerciseNames,
                ),
              ],

              // 4. NEXT-TIME PROGRESSION SUGGESTIONS SECTION
              if (effectiveExerciseNames.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingLarge),
                KeyedSubtree(
                  key: const Key('summary_section_suggestions'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildProgressionSuggestions(
                      context,
                      effectiveExerciseNames,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppTheme.spacingLarge),

              // 5. DONE ACTION
              KeyedSubtree(
                key: const Key('summary_section_done'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppButton(
                      key: const Key('summary_done_button'),
                      label: 'Done',
                      onPressed: _navigateHome,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _navigateHome,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Tap anywhere to continue',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProgressionSuggestions(
    BuildContext context,
    List<String> exerciseNames,
  ) {
    if (exerciseNames.isEmpty) return [];

    return [
      Text(
        'Progression Suggestions',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: AppTheme.spacingMedium),
      ...exerciseNames.map(
        (exerciseName) => _ProgressionSuggestionItem(
          exerciseName: exerciseName,
        ),
      ),
    ];
  }
}

/// Section 1: Result card showing time (Duration), working sets (Sets), and working volume (Volume).
class _WorkoutSummaryResultCard extends StatelessWidget {
  final int totalExercises;
  final int totalSets;
  final double totalVolume;
  final Duration duration;

  const _WorkoutSummaryResultCard({
    super.key,
    required this.totalExercises,
    required this.totalSets,
    required this.totalVolume,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

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
              color: AppTheme.primaryColor.withValues(alpha: 0.16),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            'Workout Complete!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Great job! Here\'s your summary',
            style: TextStyle(
              fontSize: 14,
              color: secondary,
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
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  icon: Icons.repeat,
                  value: '$totalSets',
                  label: totalSets == 1 ? 'Set' : 'Sets',
                  color: AppTheme.accentColor,
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
                  color: Colors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  icon: Icons.fitness_center,
                  value: '$totalExercises',
                  label: totalExercises == 1 ? 'Exercise' : 'Exercises',
                  color: AppTheme.primaryColor,
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
class _PersonalRecordsSection extends StatelessWidget {
  final int prCount;

  const _PersonalRecordsSection({
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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
class _ExerciseBreakdownCard extends StatelessWidget {
  final List<Exercise> exercises;
  final List<String> exerciseNames;

  const _ExerciseBreakdownCard({
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

/// Section 4 item: Displays a single progression suggestion with confirmation
/// (`Accept`), `Skip` (leaves target unchanged), and safe `UNDO` (only restores
/// prior target when the active program and exercise target have not diverged).
class _ProgressionSuggestionItem extends ConsumerStatefulWidget {
  final String exerciseName;

  const _ProgressionSuggestionItem({
    required this.exerciseName,
  });

  @override
  ConsumerState<_ProgressionSuggestionItem> createState() =>
      _ProgressionSuggestionItemState();
}

class _ProgressionSuggestionItemState
    extends ConsumerState<_ProgressionSuggestionItem> {
  bool _isSkipped = false;

  bool _matchesExercise(ProgramExercise ex) {
    return ex.exerciseName.trim().toLowerCase() ==
        widget.exerciseName.trim().toLowerCase();
  }

  /// Restores the prior target for [widget.exerciseName] only if the current
  /// active program is still the same program and the exercise's target still
  /// matches the values applied by this suggestion.
  Future<void> _restoreIfSafe({
    required String acceptedActiveProgramId,
    required String acceptedWorkoutProgramId,
    required double appliedWeight,
    required String appliedReps,
    required Map<int, Map<int, (double?, String)>> priorTargetsByDayAndIndex,
  }) async {
    ActiveProgram? currentProgram;
    try {
      currentProgram = ref.read(activeProgramProvider).value;
    } catch (_) {
      currentProgram = null;
    }
    if (currentProgram == null) return;

    // Abort undo if user switched active program or workout program
    if (currentProgram.id != acceptedActiveProgramId ||
        currentProgram.program.id != acceptedWorkoutProgramId) {
      return;
    }

    // Verify the exercise still has the target applied by this suggestion
    var isSafeToRestore = false;
    for (var d = 0; d < currentProgram.program.days.length; d++) {
      final day = currentProgram.program.days[d];
      for (var i = 0; i < day.exercises.length; i++) {
        final ex = day.exercises[i];
        if (_matchesExercise(ex)) {
          if (ex.targetWeight != appliedWeight || ex.reps != appliedReps) {
            return;
          }
          if (priorTargetsByDayAndIndex[d]?.containsKey(i) == true) {
            isSafeToRestore = true;
          }
        }
      }
    }

    if (!isSafeToRestore) return;

    final restoredDays = <ProgramDay>[];
    for (var d = 0; d < currentProgram.program.days.length; d++) {
      final day = currentProgram.program.days[d];
      final restoredExercises = <ProgramExercise>[];
      for (var i = 0; i < day.exercises.length; i++) {
        final ex = day.exercises[i];
        final prior = priorTargetsByDayAndIndex[d]?[i];
        if (_matchesExercise(ex) && prior != null) {
          restoredExercises.add(
            ProgramExercise(
              exerciseDefinitionId: ex.exerciseDefinitionId,
              exerciseName: ex.exerciseName,
              sets: ex.sets,
              reps: prior.$2,
              restSeconds: ex.restSeconds,
              notes: ex.notes,
              targetWeight: prior.$1,
            ),
          );
        } else {
          restoredExercises.add(ex);
        }
      }
      restoredDays.add(
        ProgramDay(
          dayNumber: day.dayNumber,
          name: day.name,
          focus: day.focus,
          exercises: restoredExercises,
          isRestDay: day.isRestDay,
        ),
      );
    }

    final restoredWorkoutProgram =
        currentProgram.program.copyWith(days: restoredDays);
    final restoredActiveProgram =
        currentProgram.updateProgram(restoredWorkoutProgram);
    try {
      await ref
          .read(activeProgramProvider.notifier)
          .updateProgram(restoredActiveProgram);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isSkipped) {
      return const SizedBox.shrink();
    }

    final exerciseName = widget.exerciseName;
    final suggestionAsync =
        ref.watch(progressionSuggestionProvider(exerciseName));

    return suggestionAsync.when(
      data: (suggestion) {
        if (suggestion == null) {
          return const SizedBox.shrink();
        }
        return ProgressionSuggestionCard(
          suggestion: suggestion,
          onAccept: () async {
            ActiveProgram? activeProgram;
            try {
              activeProgram = ref.read(activeProgramProvider).value;
            } catch (_) {
              activeProgram = null;
            }

            if (activeProgram != null) {
              final acceptedActiveProgramId = activeProgram.id;
              final acceptedWorkoutProgramId = activeProgram.program.id;
              final appliedWeight = suggestion.suggestedWeight;
              final appliedReps = suggestion.suggestedReps.toString();
              final priorTargetsByDayAndIndex =
                  <int, Map<int, (double?, String)>>{};

              final updatedDays = <ProgramDay>[];
              for (var d = 0; d < activeProgram.program.days.length; d++) {
                final day = activeProgram.program.days[d];
                final updatedExercises = <ProgramExercise>[];
                for (var i = 0; i < day.exercises.length; i++) {
                  final ex = day.exercises[i];
                  if (_matchesExercise(ex)) {
                    priorTargetsByDayAndIndex.putIfAbsent(d, () => {})[i] =
                        (ex.targetWeight, ex.reps);
                    updatedExercises.add(
                      ex.copyWith(
                        targetWeight: appliedWeight,
                        reps: appliedReps,
                      ),
                    );
                  } else {
                    updatedExercises.add(ex);
                  }
                }
                updatedDays.add(
                  ProgramDay(
                    dayNumber: day.dayNumber,
                    name: day.name,
                    focus: day.focus,
                    exercises: updatedExercises,
                    isRestDay: day.isRestDay,
                  ),
                );
              }

              final updatedProgram =
                  activeProgram.program.copyWith(days: updatedDays);
              final updatedActiveProgram =
                  activeProgram.updateProgram(updatedProgram);
              try {
                await ref
                    .read(activeProgramProvider.notifier)
                    .updateProgram(updatedActiveProgram);
              } catch (_) {}

              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Suggestion accepted for $exerciseName'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        _restoreIfSafe(
                          acceptedActiveProgramId: acceptedActiveProgramId,
                          acceptedWorkoutProgramId: acceptedWorkoutProgramId,
                          appliedWeight: appliedWeight,
                          appliedReps: appliedReps,
                          priorTargetsByDayAndIndex: priorTargetsByDayAndIndex,
                        );
                      },
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Suggestion accepted for $exerciseName'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          onSkip: () {
            setState(() {
              _isSkipped = true;
            });
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Suggestion skipped for $exerciseName'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(AppTheme.spacingMedium),
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}
