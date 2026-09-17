import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../retention/presentation/widgets/streak_display.dart';
import '../../domain/entities/workout_program.dart';
import '../../domain/usecases/generate_workout_program_use_case.dart';
import '../providers/active_program_providers.dart';
import '../providers/workout_providers.dart';
import '../widgets/program_exercise_card.dart';

/// Workout screen showing the user's active program and quick-start options.
///
/// Displays:
/// - Empty state when no active program exists
/// - Active program header with progress bar
/// - Week view with day chips
/// - Current day content display
/// - Program editor navigation
///
/// **Validates: Requirements 1.6, 8.1, 9.1, 9.5, 17.1, 17.2, 17.3, 17.4, 19.1, 19.4, 19.5**
class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProgramAsync = ref.watch(activeProgramProvider);
    final historyAsync = ref.watch(workoutHistoryProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        actions: [
          // Edit program button
          activeProgramAsync.when(
            data: (program) => program != null
                ? IconButton(
                    onPressed: () => context.go(AppRoutes.workoutEditor),
                    icon: Icon(Icons.edit, color: secondary),
                    tooltip: 'Edit Program',
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          IconButton(
            onPressed: () => context.go(AppRoutes.workoutHistory),
            icon: Icon(Icons.history, color: secondary),
            tooltip: 'History',
          ),
        ],
      ),
      body: SafeArea(
        child: activeProgramAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _ErrorState(
            error: error,
            stackTrace: stackTrace,
            onRetry: () => ref.refresh(activeProgramProvider),
          ),
          data: (activeProgram) {
            if (activeProgram == null) {
              return _EmptyState();
            }
            return _ActiveProgramContent(
              activeProgram: activeProgram,
              historyAsync: historyAsync,
            );
          },
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    this.stackTrace,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Program',
            style: TextStyle(
              color: onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error.toString(),
              style: TextStyle(color: secondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: secondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Program',
            style: TextStyle(
              color: onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate a program to get started',
            style: TextStyle(color: secondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go(AppRoutes.workoutProgramSelection),
            icon: const Icon(Icons.add),
            label: const Text('Generate Program'),
          ),
        ],
      ),
    );
  }
}

// ── Active Program Content ─────────────────────────────────────────────────

class _ActiveProgramContent extends ConsumerWidget {
  final dynamic activeProgram;
  final AsyncValue<List<dynamic>> historyAsync;

  const _ActiveProgramContent({
    required this.activeProgram,
    required this.historyAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // Streak Display
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: StreakDisplay(),
          ),
        ),

        // Active Program Header
        SliverToBoxAdapter(
          child: _ActiveProgramHeader(activeProgram: activeProgram),
        ),

        // Week View with Day Chips
        SliverToBoxAdapter(
          child: _WeekView(activeProgram: activeProgram),
        ),

        // Current Day Content
        SliverToBoxAdapter(
          child: _CurrentDayContent(activeProgram: activeProgram),
        ),

        // History Preview
        SliverToBoxAdapter(
          child: historyAsync.when(
            data: (workouts) => workouts.isNotEmpty
                ? _HistoryPreview(workouts: workouts.take(3).toList())
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

// ── Active Program Header ──────────────────────────────────────────────────

class _ActiveProgramHeader extends StatelessWidget {
  final dynamic activeProgram;

  const _ActiveProgramHeader({required this.activeProgram});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final program = activeProgram.program;
    final completionPercentage = activeProgram.weekCompletionPercentage;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program name and description
          Text(
            program.name,
            style: TextStyle(
              color: onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            program.description,
            style: TextStyle(color: secondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Week Progress',
                    style: TextStyle(
                      color: secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(completionPercentage * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: completionPercentage,
                  minHeight: 6,
                  backgroundColor: secondary.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
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

// ── Week View with Day Chips ───────────────────────────────────────────────

class _WeekView extends ConsumerWidget {
  final dynamic activeProgram;

  const _WeekView({required this.activeProgram});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = activeProgram.program;
    final currentDayIndex = activeProgram.currentDayIndex;
    final completedDays = activeProgram.completedDays;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Program Days',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: program.days.length,
              itemBuilder: (context, index) {
                final day = program.days[index];
                final isCurrentDay = index == currentDayIndex;
                final isCompleted = completedDays.containsKey(index);

                return _DayChip(
                  day: day,
                  index: index,
                  isCurrentDay: isCurrentDay,
                  isCompleted: isCompleted,
                  onTap: () {
                    ref
                        .read(activeProgramProvider.notifier)
                        .setCurrentDayIndex(index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final ProgramDay day;
  final int index;
  final bool isCurrentDay;
  final bool isCompleted;
  final VoidCallback onTap;

  const _DayChip({
    required this.day,
    required this.index,
    required this.isCurrentDay,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final surfaceHigh = Theme.of(context).colorScheme.surfaceContainerHighest;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          color: isCurrentDay
              ? AppTheme.primaryColor.withValues(alpha: 0.15)
              : surfaceHigh.withValues(alpha: 0.5),
          border: Border.all(
            color: isCurrentDay
                ? AppTheme.primaryColor
                : onSurface.withValues(alpha: 0.08),
            width: isCurrentDay ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCompleted)
              const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20)
            else if (day.isRestDay)
              const Icon(Icons.hotel, color: AppTheme.primaryColor, size: 20)
            else
              Text(
                'Day ${day.dayNumber}',
                style: TextStyle(
                  color: secondary,
                  fontSize: 10,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              day.isRestDay ? 'Rest' : day.focus.split(' ').first,
              style: TextStyle(
                color: isCurrentDay ? AppTheme.primaryColor : onSurface,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Current Day Content ────────────────────────────────────────────────────

class _CurrentDayContent extends StatelessWidget {
  final dynamic activeProgram;

  const _CurrentDayContent({required this.activeProgram});

  @override
  Widget build(BuildContext context) {
    final currentDay = activeProgram.currentDay;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Text(
            currentDay.name,
            style: TextStyle(
              color: onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentDay.focus,
            style: TextStyle(color: secondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          // Rest day or exercises
          if (currentDay.isRestDay)
            _RestDayMessage()
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exercises',
                  style: TextStyle(
                    color: secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ...currentDay.exercises.asMap().entries.map((entry) {
                  return ProgramExerciseCard(
                    exercise: entry.value,
                    index: entry.key,
                  );
                }),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(
                      AppRoutes.workoutActive,
                      extra: activeProgram,
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Workout'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RestDayMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Center(
      child: Column(
        children: [
          Icon(
            Icons.hotel,
            size: 48,
            color: secondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'Rest Day',
            style: TextStyle(
              color: secondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Take it easy and recover',
            style: TextStyle(color: secondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}


// ── History Preview ───────────────────────────────────────────────────────

class _HistoryPreview extends StatelessWidget {
  const _HistoryPreview({required this.workouts});
  final List<dynamic> workouts;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Workouts',
                style: TextStyle(
                  color: onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.workoutHistory),
                child: const Text(
                  'See All',
                  style: TextStyle(color: AppTheme.primaryColor, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        ...workouts.asMap().entries.map((entry) {
          final workout = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: _HistoryItem(workout: workout),
          ).animate().fadeIn(delay: (300 + entry.key * 80).ms);
        }),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.workout});
  final dynamic workout;

  @override
  Widget build(BuildContext context) {
    final dateStr = '${workout.date.day}/${workout.date.month}/${workout.date.year}';
    final h = workout.duration.inHours;
    final m = workout.duration.inMinutes.remainder(60);
    final duration = h > 0 ? '${h}h ${m}m' : '${m}m';
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: AppTheme.primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${workout.exercises.length} exercises',
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(dateStr, style: TextStyle(color: secondary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${workout.totalVolume.toStringAsFixed(0)}kg',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(duration, style: TextStyle(color: secondary, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

