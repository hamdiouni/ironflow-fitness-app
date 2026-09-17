import 'package:flutter/material.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Drag handle
            ReorderableDragStartListener(
              index: exerciseIndex,
              child: const Icon(
                Icons.drag_handle,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.exerciseName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        '${exercise.sets} sets',
                        Icons.repeat,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        context,
                        '${exercise.reps} reps',
                        Icons.fitness_center,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        context,
                        '${exercise.restSeconds}s rest',
                        Icons.schedule,
                      ),
                    ],
                  ),
                  if (exercise.notes != null && exercise.notes!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        exercise.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                ],
              ),
            ),
            // Menu button
            PopupMenuButton<String>(
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
                const PopupMenuItem<String>(
                  value: 'replace',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, size: 20),
                      SizedBox(width: 8),
                      Text('Replace'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20),
                      SizedBox(width: 8),
                      Text('Delete'),
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

  /// Builds an info chip with icon and text.
  Widget _buildInfoChip(
    BuildContext context,
    String label,
    IconData icon,
  ) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}
