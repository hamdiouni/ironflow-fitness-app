import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/error_handler.dart';
import '../../domain/entities/workout_program.dart';
import '../../domain/exceptions/workout_exceptions.dart';
import '../providers/active_program_providers.dart';
import '../widgets/exercise_edit_card.dart';

/// Screen for editing the active workout program.
///
/// Allows users to:
/// - Select which day to edit
/// - Replace exercises
/// - Edit exercise parameters (sets, reps, rest)
/// - Reorder exercises via drag-drop
/// - Delete exercises
///
/// Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.8
class ProgramEditorScreen extends ConsumerStatefulWidget {
  const ProgramEditorScreen({super.key});

  @override
  ConsumerState<ProgramEditorScreen> createState() => _ProgramEditorScreenState();
}

class _ProgramEditorScreenState extends ConsumerState<ProgramEditorScreen> {
  late int _selectedDayIndex;

  @override
  void initState() {
    super.initState();
    _selectedDayIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final activeProgramAsync = ref.watch(activeProgramProvider);

    return activeProgramAsync.when(
      data: (activeProgram) {
        if (activeProgram == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Program Editor')),
            body: const Center(
              child: Text('No active program'),
            ),
          );
        }

        final program = activeProgram.program;
        final currentDay = program.days[_selectedDayIndex];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Program'),
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Save and close',
              ),
            ],
          ),
          body: Column(
            children: [
              // Day selector with horizontal scrollable chips
              _buildDaySelector(program),
              // Exercise list with drag-drop reordering
              Expanded(
                child: _buildExerciseList(
                  activeProgram,
                  _selectedDayIndex,
                  currentDay,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Program Editor')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Program Editor')),
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  /// Builds the day selector with horizontal scrollable chips.
  Widget _buildDaySelector(WorkoutProgram program) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(
          program.days.length,
          (index) {
            final day = program.days[index];
            final isSelected = index == _selectedDayIndex;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(day.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedDayIndex = index;
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the exercise list with drag-drop reordering.
  Widget _buildExerciseList(
    dynamic activeProgram,
    int dayIndex,
    ProgramDay day,
  ) {
    if (day.isRestDay) {
      return const Center(
        child: Text('Rest Day'),
      );
    }

    if (day.exercises.isEmpty) {
      return const Center(
        child: Text('No exercises'),
      );
    }

    return ReorderableListView.builder(
      onReorder: (oldIndex, newIndex) async {
        // Adjust newIndex if dragging down
        if (oldIndex < newIndex) {
          newIndex--;
        }

        // Call reorder use case
        final reorderUseCase = ref.read(reorderExercisesUseCaseProvider);
        await reorderUseCase(
          dayIndex: dayIndex,
          oldIndex: oldIndex,
          newIndex: newIndex,
        );

        // Refresh the provider
        ref.refresh(activeProgramProvider);
      },
      itemCount: day.exercises.length,
      itemBuilder: (context, index) {
        final exercise = day.exercises[index];

        return ExerciseEditCard(
          key: ValueKey(exercise.exerciseName + index.toString()),
          exercise: exercise,
          dayIndex: dayIndex,
          exerciseIndex: index,
          onReplace: () => _showReplaceDialog(dayIndex, index),
          onEdit: () => _showEditDialog(dayIndex, index),
          onDelete: () => _deleteExercise(dayIndex, index),
        );
      },
    );
  }

  /// Shows dialog to replace an exercise.
  void _showReplaceDialog(int dayIndex, int exerciseIndex) async {
    final exercise = ref
        .read(activeProgramProvider)
        .value
        ?.program
        .days[dayIndex]
        .exercises[exerciseIndex];

    if (exercise == null) return;

    // Navigate to exercise picker and wait for result
    final selectedExerciseName = await context.push<String>(
      AppRoutes.exercisePicker,
    );

    if (selectedExerciseName == null || !mounted) return;

    try {
      final replaceUseCase = ref.read(replaceExerciseUseCaseProvider);
      await replaceUseCase(
        dayIndex: dayIndex,
        exerciseIndex: exerciseIndex,
        newExerciseName: selectedExerciseName,
      );

      ref.refresh(activeProgramProvider);
      if (mounted) {
        ErrorHandler.showSnackBar(context, 'Exercise replaced successfully');
      }
    } on ActiveProgramException catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e, null);
      }
    } catch (e, s) {
      if (mounted) {
        ErrorHandler.handleError(context, e, s);
      }
    }
  }

  /// Shows dialog to edit exercise parameters.
  void _showEditDialog(int dayIndex, int exerciseIndex) {
    final exercise = ref
        .read(activeProgramProvider)
        .value
        ?.program
        .days[dayIndex]
        .exercises[exerciseIndex];

    if (exercise == null) return;

    final setsController = TextEditingController(text: exercise.sets.toString());
    final repsController = TextEditingController(text: exercise.reps);
    final restController =
        TextEditingController(text: exercise.restSeconds.toString());

    String? setsError;
    String? repsError;
    String? restError;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Parameters'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: setsController,
                  decoration: InputDecoration(
                    labelText: 'Sets',
                    errorText: setsError,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: repsController,
                  decoration: InputDecoration(
                    labelText: 'Reps (e.g., "8-12" or "15")',
                    errorText: repsError,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: restController,
                  decoration: InputDecoration(
                    labelText: 'Rest (seconds)',
                    errorText: restError,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Validate inputs
                setState(() {
                  setsError = null;
                  repsError = null;
                  restError = null;
                });

                final setsStr = setsController.text.trim();
                final repsStr = repsController.text.trim();
                final restStr = restController.text.trim();

                bool isValid = true;

                // Validate sets
                final sets = int.tryParse(setsStr);
                if (sets == null || sets <= 0) {
                  setState(() {
                    setsError = 'Must be positive integer';
                  });
                  isValid = false;
                }

                // Validate reps
                if (!_isValidRepsFormat(repsStr)) {
                  setState(() {
                    repsError = 'Invalid format (e.g., "8-12" or "15")';
                  });
                  isValid = false;
                }

                // Validate rest
                final rest = int.tryParse(restStr);
                if (rest == null || rest < 0) {
                  setState(() {
                    restError = 'Must be non-negative integer';
                  });
                  isValid = false;
                }

                if (!isValid) return;

                try {
                  // Update exercise
                  final updateUseCase =
                      ref.read(updateExerciseParametersUseCaseProvider);
                  await updateUseCase(
                    dayIndex: dayIndex,
                    exerciseIndex: exerciseIndex,
                    sets: sets,
                    reps: repsStr,
                    restSeconds: rest,
                  );

                  ref.refresh(activeProgramProvider);
                  if (mounted) {
                    Navigator.of(context).pop();
                    ErrorHandler.showSnackBar(context, 'Parameters updated successfully');
                  }
                } on ProgramValidationException catch (e) {
                  if (mounted) {
                    ErrorHandler.handleError(context, e, null);
                  }
                } on ActiveProgramException catch (e) {
                  if (mounted) {
                    ErrorHandler.handleError(context, e, null);
                  }
                } catch (e, s) {
                  if (mounted) {
                    ErrorHandler.handleError(context, e, s);
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  /// Deletes an exercise from the program day.
  Future<void> _deleteExercise(int dayIndex, int exerciseIndex) async {
    final activeProgram = ref.read(activeProgramProvider).value;
    if (activeProgram == null) return;

    final day = activeProgram.program.days[dayIndex];
    if (day.exercises.length <= 1) {
      if (mounted) {
        ErrorHandler.showSnackBar(
          context,
          'Cannot delete the last exercise in a day',
        );
      }
      return;
    }

    try {
      final updatedExercises = List<ProgramExercise>.from(day.exercises);
      updatedExercises.removeAt(exerciseIndex);

      final updatedDay = ProgramDay(
        dayNumber: day.dayNumber,
        name: day.name,
        focus: day.focus,
        exercises: updatedExercises,
        isRestDay: day.isRestDay,
      );

      final updatedDays = List<ProgramDay>.from(activeProgram.program.days);
      updatedDays[dayIndex] = updatedDay;

      final updatedProgram = WorkoutProgram(
        id: activeProgram.program.id,
        name: activeProgram.program.name,
        description: activeProgram.program.description,
        days: updatedDays,
        durationWeeks: activeProgram.program.durationWeeks,
        difficulty: activeProgram.program.difficulty,
      );

      final updated = activeProgram.updateProgram(updatedProgram);
      final updateUseCase = ref.read(updateActiveProgramUseCaseProvider);
      await updateUseCase(updated);

      ref.refresh(activeProgramProvider);
      if (mounted) {
        ErrorHandler.showSnackBar(context, 'Exercise deleted successfully');
      }
    } on ActiveProgramException catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e, null);
      }
    } catch (e, s) {
      if (mounted) {
        ErrorHandler.handleError(context, e, s);
      }
    }
  }

  /// Validates reps format.
  bool _isValidRepsFormat(String reps) {
    // Single number (must be positive)
    final singleNumber = int.tryParse(reps);
    if (singleNumber != null) {
      return singleNumber > 0;
    }

    // Range format (e.g., "8-12")
    final parts = reps.split('-');
    if (parts.length == 2) {
      final start = int.tryParse(parts[0]);
      final end = int.tryParse(parts[1]);
      return start != null &&
          end != null &&
          start > 0 &&
          end > 0 &&
          start < end;
    }

    return false;
  }
}
