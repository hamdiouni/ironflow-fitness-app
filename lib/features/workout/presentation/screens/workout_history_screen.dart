import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../ai/domain/entities/insight.dart';
import '../../../ai/presentation/widgets/insight_widget.dart';
import '../../domain/entities/workout.dart';
import '../providers/paginated_workout_provider.dart';

/// Displays the full workout history with lazy loading for performance.
///
/// Uses pagination to load workouts in batches of 20 items, loading more
/// as the user scrolls. This handles 1000+ workouts efficiently (Requirement 8.1).
class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paginatedWorkoutProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when user is 200px from bottom
      ref.read(paginatedWorkoutProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paginatedWorkoutProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History'),
        actions: [
          if (state.totalCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${state.workouts.length}/${state.totalCount}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(paginatedWorkoutProvider.notifier).refresh(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(PaginatedWorkoutState state) {
    if (state.isLoading && state.workouts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.workouts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load workout history.\n${state.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.errorColor),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(paginatedWorkoutProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.workouts.isEmpty && !state.isLoading) {
      return EmptyStates.workouts(
        onStartWorkout: () {
          // Navigate to workout screen to start first workout
          // You can implement navigation logic here
        },
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      // Add 1 for InsightWidget at the top, plus 1 for loading indicator if loading more
      itemCount: 1 + state.workouts.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // First item is the InsightWidget
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: AppTheme.spacingSmall),
            child: InsightWidget(context: InsightContext.workout),
          );
        }
        
        // Adjust index for workout items (subtract 1 because InsightWidget is at index 0)
        final workoutIndex = index - 1;
        
        if (workoutIndex == state.workouts.length) {
          // Loading indicator at the end
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return _WorkoutHistoryItem(workout: state.workouts[workoutIndex]);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// List item widget - Now expandable to show exercise details
// ---------------------------------------------------------------------------

class _WorkoutHistoryItem extends StatefulWidget {
  const _WorkoutHistoryItem({required this.workout});

  final Workout workout;

  @override
  State<_WorkoutHistoryItem> createState() => _WorkoutHistoryItemState();
}

class _WorkoutHistoryItemState extends State<_WorkoutHistoryItem> {
  bool _isExpanded = false;

  // Static DateFormat instances avoid re-allocation on every build call,
  // which matters when scrolling through 1000+ items (Requirement 16.1).
  static final _dateFormat = DateFormat('EEE, MMM d, yyyy');
  static final _timeFormat = DateFormat('h:mm a');
  static final _dayFormat = DateFormat('d');
  static final _monthFormat = DateFormat('MMM');

  @override
  Widget build(BuildContext context) {
    final dateLabel = _dateFormat.format(widget.workout.date);
    final timeLabel = _timeFormat.format(widget.workout.date);
    final durationLabel = _formatDuration(widget.workout.duration);
    final volumeLabel =
        '${widget.workout.totalVolume.toStringAsFixed(1)} kg';
    final exerciseCount = widget.workout.exercises.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      child: AppTheme.glassmorphicCard(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date badge
                  Container(
                    width: 52,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingSmall,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _dayFormat.format(widget.workout.date),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          _monthFormat.format(widget.workout.date).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMedium),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$dateLabel · $timeLabel',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingXSmall),
                        Row(
                          children: [
                            _Stat(
                              icon: Icons.fitness_center,
                              label: '$exerciseCount exercise${exerciseCount == 1 ? '' : 's'}',
                            ),
                            const SizedBox(width: AppTheme.spacingMedium),
                            _Stat(
                              icon: Icons.monitor_weight_outlined,
                              label: volumeLabel,
                            ),
                            const SizedBox(width: AppTheme.spacingMedium),
                            _Stat(
                              icon: Icons.timer_outlined,
                              label: durationLabel,
                            ),
                          ],
                        ),
                        if (widget.workout.caloriesBurned > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _Stat(
                                icon: Icons.local_fire_department,
                                label: '${widget.workout.caloriesBurned.toInt()} kcal',
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Expand/collapse icon
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
            // Exercise details (shown when expanded)
            if (_isExpanded) ...[
              const Divider(height: 24),
              _ExerciseDetailsList(exercises: widget.workout.exercises),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }
}

// ---------------------------------------------------------------------------
// Exercise details list
// ---------------------------------------------------------------------------

class _ExerciseDetailsList extends StatelessWidget {
  const _ExerciseDetailsList({required this.exercises});

  final List exercises;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercises',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ...exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          return _ExerciseDetailItem(
            exerciseNumber: index + 1,
            exercise: exercise,
          );
        }),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual exercise detail item
// ---------------------------------------------------------------------------

class _ExerciseDetailItem extends StatelessWidget {
  const _ExerciseDetailItem({
    required this.exerciseNumber,
    required this.exercise,
  });

  final int exerciseNumber;
  final dynamic exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sets = exercise.sets as List? ?? [];
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$exerciseNumber',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exercise.name ?? 'Unknown Exercise',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (sets.isNotEmpty) ...[
              const SizedBox(height: 8),
              // Sets table header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 40,
                      child: Text(
                        'Set',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 60,
                      child: Text(
                        'Weight',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                      child: Text(
                        'Reps',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Sets data
              ...sets.asMap().entries.map((entry) {
                final setIndex = entry.key;
                final set = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${setIndex + 1}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          '${set.weight.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: Text(
                          '${set.reps ?? 0}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small stat chip
// ---------------------------------------------------------------------------

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: secondary),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: secondary),
        ),
      ],
    );
  }
}
