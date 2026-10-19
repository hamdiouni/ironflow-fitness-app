import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../shared/presentation/components/components.dart';
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
    final tokens = context.tokens;
    final activeProgramAsync = ref.watch(activeProgramProvider);

    return activeProgramAsync.when(
      data: (activeProgram) {
        if (activeProgram == null) {
          return Scaffold(
            backgroundColor: tokens.canvas,
            appBar: AppBar(
              backgroundColor: tokens.canvas,
              elevation: 0,
              title: Text(
                'EDIT PROGRAM',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTypography.fontFamilyHeadings,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AppStateView.empty(
                  title: 'NO ACTIVE PROGRAM',
                  message: 'Initialize a training split before editing protocol parameters.',
                ),
              ),
            ),
          );
        }

        final program = activeProgram.program;
        final currentDay = program.days[_selectedDayIndex];

        return Scaffold(
          backgroundColor: tokens.canvas,
          appBar: AppBar(
            backgroundColor: tokens.canvas,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'EDIT PROGRAM',
              style: TextStyle(
                color: tokens.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: AppTypography.fontFamilyHeadings,
                letterSpacing: 1.2,
              ),
            ),
            actions: [
              SizedBox(
                width: 48,
                height: 48,
                child: IconButton(
                  icon: Icon(Icons.check, color: tokens.kineticAccent, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Save and close',
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Day selector with horizontal scrollable chips
              _buildDaySelector(program, tokens),
              // Exercise list with drag-drop reordering
              Expanded(
                child: _buildExerciseList(
                  activeProgram,
                  _selectedDayIndex,
                  currentDay,
                  tokens,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: context.tokens.canvas,
        appBar: AppBar(
          backgroundColor: context.tokens.canvas,
          elevation: 0,
          title: Text(
            'EDIT PROGRAM',
            style: TextStyle(
              color: context.tokens.textPrimary,
              fontFamily: AppTypography.fontFamilyHeadings,
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: context.tokens.kineticAccent,
          ),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: context.tokens.canvas,
        appBar: AppBar(
          backgroundColor: context.tokens.canvas,
          elevation: 0,
          title: Text(
            'EDIT PROGRAM',
            style: TextStyle(
              color: context.tokens.textPrimary,
              fontFamily: AppTypography.fontFamilyHeadings,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: AppStateView.error(
              title: 'LOAD FAILED',
              message: error.toString(),
              onRetry: () => ref.refresh(activeProgramProvider),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the day selector with horizontal scrollable chips.
  Widget _buildDaySelector(WorkoutProgram program, AppThemeTokens tokens) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(
          program.days.length,
          (index) {
            final day = program.days[index];
            final isSelected = index == _selectedDayIndex;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDayIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? tokens.panel : tokens.card,
                    borderRadius: BorderRadius.circular(tokens.radiusPill),
                    border: Border.all(
                      color: isSelected ? tokens.kineticAccent : tokens.borderSubtle,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: tokens.kineticAccent.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    day.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? tokens.kineticAccent : tokens.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTypography.fontFamilyHeadings,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
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
    AppThemeTokens tokens,
  ) {
    if (day.isRestDay) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AppStateView.empty(
            title: 'RECOVERY DAY',
            message: 'No exercises scheduled for rest and tissue adaptation.',
            icon: Icon(Icons.bedtime_outlined, size: 48, color: tokens.kineticAccent),
          ),
        ),
      );
    }

    if (day.exercises.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AppStateView.empty(
            title: 'NO EXERCISES IN DAY',
            message: 'Add exercises to this training split day.',
          ),
        ),
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

        // Invalidate the provider
        ref.invalidate(activeProgramProvider);
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

      ref.invalidate(activeProgramProvider);
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
    final tokens = context.tokens;
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
          backgroundColor: tokens.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            side: BorderSide(color: tokens.borderSubtle, width: 1),
          ),
          title: Text(
            'EDIT PARAMETERS',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: AppTypography.fontFamilyHeadings,
              letterSpacing: 0.5,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: setsController,
                  style: TextStyle(color: tokens.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Sets',
                    labelStyle: TextStyle(color: tokens.textMuted, fontSize: 12),
                    errorText: setsError,
                    filled: true,
                    fillColor: tokens.panel,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      borderSide: BorderSide(color: tokens.kineticAccent, width: 1.5),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: repsController,
                  style: TextStyle(color: tokens.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Reps (e.g., "8-12" or "15")',
                    labelStyle: TextStyle(color: tokens.textMuted, fontSize: 12),
                    errorText: repsError,
                    filled: true,
                    fillColor: tokens.panel,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      borderSide: BorderSide(color: tokens.kineticAccent, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: restController,
                  style: TextStyle(color: tokens.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Rest (seconds)',
                    labelStyle: TextStyle(color: tokens.textMuted, fontSize: 12),
                    errorText: restError,
                    filled: true,
                    fillColor: tokens.panel,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      borderSide: BorderSide(color: tokens.kineticAccent, width: 1.5),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: tokens.textMuted)),
            ),
            AppButton(
              label: 'SAVE',
              variant: AppButtonVariant.primary,
              height: 40,
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

                  ref.invalidate(activeProgramProvider);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ErrorHandler.showSnackBar(context, 'Parameters updated successfully');
                  }
                } on ProgramValidationException catch (e) {
                  if (context.mounted) {
                    ErrorHandler.handleError(context, e, null);
                  }
                } on ActiveProgramException catch (e) {
                  if (context.mounted) {
                    ErrorHandler.handleError(context, e, null);
                  }
                } catch (e, s) {
                  if (context.mounted) {
                    ErrorHandler.handleError(context, e, s);
                  }
                }
              },
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

      ref.invalidate(activeProgramProvider);
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
