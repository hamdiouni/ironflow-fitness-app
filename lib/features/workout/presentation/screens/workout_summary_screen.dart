import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/presentation/components/app_button.dart';
import '../../../../shared/presentation/services/app_haptics.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/workout.dart';
import '../../domain/usecases/workout_metrics.dart';
import '../providers/workout_providers.dart';
import '../widgets/summary/workout_progression_suggestion_item.dart';
import '../widgets/summary/workout_summary_sections.dart';

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
              WorkoutSummaryResultCard(
                key: const Key('summary_section_result'),
                totalExercises: effectiveExerciseNames.length,
                totalSets: effectiveTotalSets,
                totalVolume: effectiveTotalVolume,
                duration: effectiveDuration,
              ),

              // 2. REAL PRS SECTION
              if (effectivePrCount > 0) ...[
                const SizedBox(height: AppTheme.spacingMedium),
                PersonalRecordsSection(
                  key: const Key('summary_section_prs'),
                  prCount: effectivePrCount,
                ),
              ],

              // 3. COLLAPSED EXERCISE SETS SECTION
              if (effectiveExercises.isNotEmpty ||
                  effectiveExerciseNames.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingLarge),
                ExerciseBreakdownCard(
                  key: const Key('summary_section_exercises'),
                  exercises: effectiveExercises,
                  exerciseNames: effectiveExerciseNames,
                ),
                const SizedBox(height: AppTheme.spacingMedium),
                WorkoutSummaryMusclesCard(
                  key: const Key('summary_section_muscles'),
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
        (exerciseName) => WorkoutProgressionSuggestionItem(
          exerciseName: exerciseName,
        ),
      ),
    ];
  }
}
