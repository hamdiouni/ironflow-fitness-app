import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_theme.dart';
import '../../../domain/entities/active_program.dart';
import '../../../domain/entities/workout_program.dart';
import '../../providers/active_program_providers.dart';
import '../../providers/workout_providers.dart';
import '../progression_suggestion_card.dart';

/// Section 4 item: Displays a single progression suggestion with confirmation
/// (`Accept`), `Skip` (leaves target unchanged), and safe `UNDO` (only restores
/// prior target when the active program and exercise target have not diverged).
class WorkoutProgressionSuggestionItem extends ConsumerStatefulWidget {
  final String exerciseName;

  const WorkoutProgressionSuggestionItem({
    super.key,
    required this.exerciseName,
  });

  @override
  ConsumerState<WorkoutProgressionSuggestionItem> createState() =>
      _WorkoutProgressionSuggestionItemState();
}

class _WorkoutProgressionSuggestionItemState
    extends ConsumerState<WorkoutProgressionSuggestionItem> {
  bool _isSkipped = false;

  bool _matchesExercise(ProgramExercise ex) {
    return ex.exerciseName.trim().toLowerCase() ==
        widget.exerciseName.trim().toLowerCase();
  }

  /// Restores the prior target for [widget.exerciseName] only if the current
  /// active program is still the same program and the exercise's target still
  /// matches the values applied by this suggestion.
  Future<void> _restoreIfSafe({
    required String acceptedActiveProgramId,
    required String acceptedWorkoutProgramId,
    required double appliedWeight,
    required String appliedReps,
    required Map<int, Map<int, (double?, String)>> priorTargetsByDayAndIndex,
  }) async {
    ActiveProgram? currentProgram;
    try {
      currentProgram = ref.read(activeProgramProvider).value;
    } catch (_) {
      currentProgram = null;
    }
    if (currentProgram == null) return;

    // Abort undo if user switched active program or workout program
    if (currentProgram.id != acceptedActiveProgramId ||
        currentProgram.program.id != acceptedWorkoutProgramId) {
      return;
    }

    // Verify the exercise still has the target applied by this suggestion
    var isSafeToRestore = false;
    for (var d = 0; d < currentProgram.program.days.length; d++) {
      final day = currentProgram.program.days[d];
      for (var i = 0; i < day.exercises.length; i++) {
        final ex = day.exercises[i];
        if (_matchesExercise(ex)) {
          if (ex.targetWeight != appliedWeight || ex.reps != appliedReps) {
            return;
          }
          if (priorTargetsByDayAndIndex[d]?.containsKey(i) == true) {
            isSafeToRestore = true;
          }
        }
      }
    }

    if (!isSafeToRestore) return;

    final restoredDays = <ProgramDay>[];
    for (var d = 0; d < currentProgram.program.days.length; d++) {
      final day = currentProgram.program.days[d];
      final restoredExercises = <ProgramExercise>[];
      for (var i = 0; i < day.exercises.length; i++) {
        final ex = day.exercises[i];
        final prior = priorTargetsByDayAndIndex[d]?[i];
        if (_matchesExercise(ex) && prior != null) {
          restoredExercises.add(
            ProgramExercise(
              exerciseDefinitionId: ex.exerciseDefinitionId,
              exerciseName: ex.exerciseName,
              sets: ex.sets,
              reps: prior.$2,
              restSeconds: ex.restSeconds,
              notes: ex.notes,
              targetWeight: prior.$1,
            ),
          );
        } else {
          restoredExercises.add(ex);
        }
      }
      restoredDays.add(
        ProgramDay(
          dayNumber: day.dayNumber,
          name: day.name,
          focus: day.focus,
          exercises: restoredExercises,
          isRestDay: day.isRestDay,
        ),
      );
    }

    final restoredWorkoutProgram =
        currentProgram.program.copyWith(days: restoredDays);
    final restoredActiveProgram =
        currentProgram.updateProgram(restoredWorkoutProgram);
    try {
      await ref
          .read(activeProgramProvider.notifier)
          .updateProgram(restoredActiveProgram);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isSkipped) {
      return const SizedBox.shrink();
    }

    final exerciseName = widget.exerciseName;
    final suggestionAsync =
        ref.watch(progressionSuggestionProvider(exerciseName));

    return suggestionAsync.when(
      data: (suggestion) {
        if (suggestion == null) {
          return const SizedBox.shrink();
        }
        return ProgressionSuggestionCard(
          suggestion: suggestion,
          onAccept: () async {
            ActiveProgram? activeProgram;
            try {
              activeProgram = ref.read(activeProgramProvider).value;
            } catch (_) {
              activeProgram = null;
            }

            if (activeProgram != null) {
              final acceptedActiveProgramId = activeProgram.id;
              final acceptedWorkoutProgramId = activeProgram.program.id;
              final appliedWeight = suggestion.suggestedWeight;
              final appliedReps = suggestion.suggestedReps.toString();
              final priorTargetsByDayAndIndex =
                  <int, Map<int, (double?, String)>>{};

              final updatedDays = <ProgramDay>[];
              for (var d = 0; d < activeProgram.program.days.length; d++) {
                final day = activeProgram.program.days[d];
                final updatedExercises = <ProgramExercise>[];
                for (var i = 0; i < day.exercises.length; i++) {
                  final ex = day.exercises[i];
                  if (_matchesExercise(ex)) {
                    priorTargetsByDayAndIndex.putIfAbsent(d, () => {})[i] =
                        (ex.targetWeight, ex.reps);
                    updatedExercises.add(
                      ex.copyWith(
                        targetWeight: appliedWeight,
                        reps: appliedReps,
                      ),
                    );
                  } else {
                    updatedExercises.add(ex);
                  }
                }
                updatedDays.add(
                  ProgramDay(
                    dayNumber: day.dayNumber,
                    name: day.name,
                    focus: day.focus,
                    exercises: updatedExercises,
                    isRestDay: day.isRestDay,
                  ),
                );
              }

              final updatedProgram =
                  activeProgram.program.copyWith(days: updatedDays);
              final updatedActiveProgram =
                  activeProgram.updateProgram(updatedProgram);
              try {
                await ref
                    .read(activeProgramProvider.notifier)
                    .updateProgram(updatedActiveProgram);
              } catch (_) {}

              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Suggestion accepted for $exerciseName'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        _restoreIfSafe(
                          acceptedActiveProgramId: acceptedActiveProgramId,
                          acceptedWorkoutProgramId: acceptedWorkoutProgramId,
                          appliedWeight: appliedWeight,
                          appliedReps: appliedReps,
                          priorTargetsByDayAndIndex: priorTargetsByDayAndIndex,
                        );
                      },
                    ),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Suggestion accepted for $exerciseName'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          onSkip: () {
            setState(() {
              _isSkipped = true;
            });
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Suggestion skipped for $exerciseName'),
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

