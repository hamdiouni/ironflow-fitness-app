import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/workout_program.dart';

/// Card widget for editing a single exercise in the program editor.
///
/// Displays:
/// - Exercise name
/// - Sets, reps, rest seconds
/// - Drag handle for reordering
/// - PopupMenu with Replace, Edit, Delete options
///
/// Validates: Requirements 3.2
class ExerciseEditCard extends StatelessWidget {
  /// The exercise to display
  final ProgramExercise exercise;

  /// The day index in the program
  final int dayIndex;

  /// The exercise index within the day
  final int exerciseIndex;

  /// Callback when replace is selected
  final VoidCallback onReplace;

  /// Callback when edit is selected
  final VoidCallback onEdit;

  /// Callback when delete is selected
  final VoidCallback onDelete;

  const ExerciseEditCard({
    required this.exercise,
    required this.dayIndex,
    required this.exerciseIndex,
    required this.onReplace,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Drag handle
            ReorderableDragStartListener(
              index: exerciseIndex,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.drag_indicator_rounded,
                  color: tokens.textMuted,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.exerciseName,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTypography.fontFamilyHeadings,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildInfoChip(
                        tokens,
                        '${exercise.sets} SETS',
                        Icons.repeat,
                      ),
                      _buildInfoChip(
                        tokens,
                        '${exercise.reps} REPS',
                        Icons.fitness_center,
                      ),
                      _buildInfoChip(
                        tokens,
                        '${exercise.restSeconds}S REST',
                        Icons.schedule,
                      ),
                    ],
                  ),
                  if (exercise.notes != null && exercise.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        exercise.notes!,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: tokens.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Menu button
            PopupMenuButton<String>(
              color: tokens.panel,
              iconColor: tokens.textMuted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                side: BorderSide(color: tokens.borderSubtle, width: 1),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'replace':
                    onReplace();
                    break;
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'replace',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, size: 18, color: tokens.cyanAccent),
                      const SizedBox(width: 8),
                      Text('Replace', style: TextStyle(color: tokens.textPrimary, fontSize: 13)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18, color: tokens.textPrimary),
                      const SizedBox(width: 8),
                      Text('Edit', style: TextStyle(color: tokens.textPrimary, fontSize: 13)),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 18, color: tokens.error),
                      const SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: tokens.error, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a monolithic info chip with icon and text.
  Widget _buildInfoChip(
    AppThemeTokens tokens,
    String label,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: tokens.kineticAccent),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: tokens.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: AppTypography.fontFamilyHeadings,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
