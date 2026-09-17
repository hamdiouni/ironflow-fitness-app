import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/animations/pr_celebration_animation.dart';
import '../providers/workout_providers.dart';
import '../widgets/progression_suggestion_card.dart';

/// Displays an animated workout summary after the user finishes a workout.
///
/// Shows real metrics with proper calculations:
/// - Total exercises completed
/// - Total sets performed
/// - Total volume (weight × reps)
/// - Workout duration
/// - Personal records achieved
///
/// Features animated cards, progress bars, and visual improvements.
/// Auto-navigates to home after 5 seconds, or immediately on user tap.
///
/// Requirements: 17.5, 17.8
class WorkoutSummaryScreen extends StatefulWidget {
  const WorkoutSummaryScreen({
    required this.totalSets,
    required this.totalVolume,
    required this.duration,
    required this.prCount,
    required this.exerciseNames,
    super.key,
  });

  final int totalSets;
  final double totalVolume;
  final Duration duration;
  final int prCount;
  final List<String> exerciseNames;

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  Timer? _autoNavTimer;

  @override
  void initState() {
    super.initState();
    // Increased to 5 seconds to give user time to read
    _autoNavTimer = Timer(const Duration(seconds: 5), _navigateHome);
  }

  @override
  void dispose() {
    _autoNavTimer?.cancel();
    super.dispose();
  }

  void _navigateHome() {
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalExercises = widget.exerciseNames.length;
    
    return GestureDetector(
      onTap: () {
        _autoNavTimer?.cancel();
        _navigateHome();
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Celebration animation for PRs
                if (widget.prCount > 0) ...[
                  const PRCelebrationAnimation(),
                  const SizedBox(height: AppTheme.spacingMedium),
                ],
                
                // Main summary card with real metrics
                _WorkoutSummaryCard(
                  totalExercises: totalExercises,
                  totalSets: widget.totalSets,
                  totalVolume: widget.totalVolume,
                  duration: widget.duration,
                  prCount: widget.prCount,
                ).animate()
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    ),
                
                const SizedBox(height: AppTheme.spacingLarge),
                
                // Exercise breakdown
                if (totalExercises > 0) ...[
                  _ExerciseBreakdownCard(
                    exerciseNames: widget.exerciseNames,
                  ).animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.2, duration: 400.ms),
                  
                  const SizedBox(height: AppTheme.spacingLarge),
                ],
                
                // Progression suggestions for each exercise
                ..._buildProgressionSuggestions(context),
                
                const SizedBox(height: AppTheme.spacingLarge),
                
                Text(
                  'Tap anywhere to continue',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ).animate()
                    .fadeIn(delay: 600.ms, duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProgressionSuggestions(BuildContext context) {
    if (widget.exerciseNames.isEmpty) return [];

    return [
      Text(
        'Progression Suggestions',
        style: Theme.of(context).textTheme.titleMedium,
      ).animate()
          .fadeIn(delay: 400.ms, duration: 400.ms),
      const SizedBox(height: AppTheme.spacingMedium),
      ...widget.exerciseNames.asMap().entries.map((entry) {
        final index = entry.key;
        final exerciseName = entry.value;
        return _ProgressionSuggestionItem(
          exerciseName: exerciseName,
        ).animate()
            .fadeIn(delay: (500 + index * 100).ms, duration: 400.ms)
            .slideX(begin: 0.2, duration: 400.ms);
      }).toList(),
    ];
  }
}

/// Main workout summary card with real metrics
class _WorkoutSummaryCard extends StatelessWidget {
  final int totalExercises;
  final int totalSets;
  final double totalVolume;
  final Duration duration;
  final int prCount;

  const _WorkoutSummaryCard({
    required this.totalExercises,
    required this.totalSets,
    required this.totalVolume,
    required this.duration,
    required this.prCount,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 40,
              color: Colors.white,
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
          
          // Metrics grid
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.fitness_center,
                  value: '$totalExercises',
                  label: totalExercises == 1 ? 'Exercise' : 'Exercises',
                  color: AppTheme.primaryColor,
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
                  icon: Icons.timer_outlined,
                  value: _formatDuration(duration),
                  label: 'Duration',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          
          if (prCount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.2),
                    AppTheme.accentColor.withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$prCount Personal ${prCount == 1 ? 'Record' : 'Records'}! 🎉',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
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

/// Individual metric card
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
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Exercise breakdown card showing list of completed exercises
class _ExerciseBreakdownCard extends StatelessWidget {
  final List<String> exerciseNames;

  const _ExerciseBreakdownCard({
    required this.exerciseNames,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
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
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 1.0,
              minHeight: 8,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 12),
          
          // Exercise list
          ...exerciseNames.asMap().entries.map((entry) {
            final index = entry.key;
            final name = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        color: onSurface,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}


/// Widget that displays a single progression suggestion for an exercise.
class _ProgressionSuggestionItem extends ConsumerWidget {
  final String exerciseName;

  const _ProgressionSuggestionItem({
    required this.exerciseName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionAsync =
        ref.watch(progressionSuggestionProvider(exerciseName));

    return suggestionAsync.when(
      data: (suggestion) {
        if (suggestion == null) {
          return const SizedBox.shrink();
        }
        return ProgressionSuggestionCard(
          suggestion: suggestion,
          onAccept: () {
            // TODO: Update program with accepted suggestion
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Suggestion accepted for $exerciseName'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          onDismiss: () {
            // Dismiss suggestion
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Suggestion dismissed for $exerciseName'),
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
