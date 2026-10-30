import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/components/app_card.dart';
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
    final tokens = AppThemeTokens.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name with index badge
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    color: tokens.kineticAccent.withValues(alpha: 0.12),
                    border: Border.all(
                      color: tokens.kineticAccent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: tokens.kineticAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppTypography.fontFamilyHeadings,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exercise.exerciseName,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTypography.fontFamilyHeadings,
                      letterSpacing: -0.2,
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
                  label: 'SETS',
                  value: '${exercise.sets}',
                  tokens: tokens,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.trending_up,
                  label: 'REPS',
                  value: exercise.reps,
                  tokens: tokens,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.schedule,
                  label: 'REST',
                  value: '${exercise.restSeconds}s',
                  tokens: tokens,
                ),
              ],
            ),
            // Notes if present
            if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                exercise.notes!,
                style: TextStyle(
                  color: tokens.textMuted,
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
  final AppThemeTokens tokens;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(
          color: tokens.borderSubtle,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: tokens.kineticAccent),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: tokens.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTypography.fontFamilyHeadings,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

