import 'package:flutter/material.dart';

import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/workout_program.dart';

/// A card widget displaying a program exercise with its parameters.
///
/// Displays:
/// - Exercise name as title
/// - Sets, reps, rest seconds as info chips with icons
/// - Optional notes in italic gray text
///
/// **Validates: Requirements 8.3**
class ProgramExerciseCard extends StatelessWidget {
  final ProgramExercise exercise;
  final int index;
  final VoidCallback? onTap;

  const ProgramExerciseCard({
    required this.exercise,
    required this.index,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final surface = Theme.of(context).colorScheme.surfaceContainerHighest;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
          color: surface.withValues(alpha: 0.5),
          border: Border.all(
            color: onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name with index
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exercise.exerciseName,
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Info chips
            Row(
              children: [
                _InfoChip(
                  icon: Icons.repeat,
                  label: 'Sets',
                  value: '${exercise.sets}',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.trending_up,
                  label: 'Reps',
                  value: exercise.reps,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.schedule,
                  label: 'Rest',
                  value: '${exercise.restSeconds}s',
                ),
              ],
            ),
            // Notes if present
            if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                exercise.notes!,
                style: TextStyle(
                  color: secondary,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final surface = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: secondary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: secondary,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
