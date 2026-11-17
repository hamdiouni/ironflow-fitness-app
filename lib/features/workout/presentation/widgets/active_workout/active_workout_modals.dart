import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/core/utils/error_handler.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/widgets/program_complete_dialog.dart';
import 'package:progression_tracker/shared/presentation/components/components.dart';
import 'package:uuid/uuid.dart';

import 'exercise_selection_sheet.dart';

/// Opens the exercise picker bottom sheet and appends the chosen exercise.
void showActiveWorkoutExerciseSelectionSheet({
  required BuildContext context,
  required WidgetRef ref,
  required bool Function() isMounted,
}) {
  try {
    AppLogger.debug('📊 [WorkoutUI] Opening exercise selection sheet...');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (sheetContext, scrollController) => ExerciseSelectionSheet(
          scrollController: scrollController,
          onExerciseSelected: (name) async {
            AppLogger.debug('📊 [WorkoutUI] Exercise selected: $name');
            Navigator.of(sheetContext).pop();
            try {
              final exercise = Exercise(
                id: const Uuid().v4(),
                name: name,
                type: ExerciseType.strength,
                sets: const [],
              );
              AppLogger.debug(
                '🔍 [WorkoutUI] Exercise ID: ${exercise.id}, Type: ${exercise.type}',
              );

              await ref
                  .read(workoutNotifierProvider.notifier)
                  .addExercise(exercise);
              AppLogger.debug('✅ [WorkoutUI] Exercise added successfully');
            } catch (e, s) {
              AppLogger.debug('❌ [WorkoutUI] Failed to add exercise: $e');
              AppLogger.debug('🔍 [WorkoutUI] Stack trace: $s');
              if (isMounted() && context.mounted) {
                ErrorHandler.handleError(context, e, s);
              }
            }
          },
        ),
      ),
    );
    AppLogger.debug('✅ [WorkoutUI] Exercise selection sheet opened');
  } catch (e, s) {
    AppLogger.debug('❌ [WorkoutUI] Failed to open exercise selection: $e');
    AppLogger.debug('🔍 [WorkoutUI] Stack trace: $s');
    if (isMounted() && context.mounted) {
      ErrorHandler.handleError(context, e, s);
    }
  }
}

/// Prompts the user to record estimated calories burned for this workout.
Future<double?> showCalorieBurnedInputDialog(BuildContext context) async {
  try {
    AppLogger.debug('📊 [WorkoutUI] Opening calorie input dialog...');
    final controller = TextEditingController(text: '0');

    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        final tokens = context.tokens;
        return AlertDialog(
          backgroundColor: tokens.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            side: BorderSide(color: tokens.borderSubtle, width: 1),
          ),
          title: Text(
            'CALORIES BURNED',
            style: TextStyle(
              color: tokens.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: AppTypography.fontFamilyHeadings,
              letterSpacing: 0.5,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Record estimated energy expenditure during this session.',
                style: TextStyle(color: tokens.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontFamily: AppTypography.fontFamilyHeadings,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  labelText: 'Calories',
                  labelStyle: TextStyle(color: tokens.textMuted, fontSize: 12),
                  suffixText: 'kcal',
                  suffixStyle: TextStyle(
                    color: tokens.kineticAccent,
                    fontWeight: FontWeight.bold,
                  ),
                  filled: true,
                  fillColor: tokens.panel,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    borderSide: BorderSide(
                      color: tokens.borderSubtle,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    borderSide: BorderSide(
                      color: tokens.kineticAccent,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Tip: A typical strength training session burns 200–400 kcal.',
                style: TextStyle(
                  fontSize: 11,
                  color: tokens.textMuted,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                AppLogger.debug('⚠️ [WorkoutUI] User cancelled calorie input dialog');
                Navigator.of(context).pop(null);
              },
              child: Text('Cancel', style: TextStyle(color: tokens.textMuted)),
            ),
            AppButton(
              label: 'SAVE',
              variant: AppButtonVariant.primary,
              height: 40,
              onPressed: () {
                final value = double.tryParse(controller.text) ?? 0;
                AppLogger.debug('🔍 [WorkoutUI] User entered calories: $value');
                Navigator.of(context).pop(value);
              },
            ),
          ],
        );
      },
    ).then((value) {
      controller.dispose();
      return value;
    });

    if (result != null) {
      AppLogger.debug('✅ [WorkoutUI] Calorie input dialog completed with value: $result');
    } else {
      AppLogger.debug('⚠️ [WorkoutUI] Calorie input dialog cancelled');
    }

    return result;
  } catch (e, s) {
    AppLogger.debug('❌ [WorkoutUI] Failed to show calorie input dialog: $e');
    AppLogger.debug('🔍 [WorkoutUI] Stack trace: $s');
    return null;
  }
}

/// Shows the completion celebration dialog when a structured program ends.
void showProgramCompleteCelebrationDialog({
  required BuildContext context,
  required WidgetRef ref,
  required ActiveProgram activeProgram,
}) {
  try {
    AppLogger.debug('📊 [WorkoutUI] Opening program complete dialog...');
    AppLogger.debug('🔍 [WorkoutUI] Program name: ${activeProgram.program.name}');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgramCompleteDialog(
        programName: activeProgram.program.name,
        onRestart: () async {
          try {
            AppLogger.debug('📊 [WorkoutUI] User chose to restart program');
            await ref.read(activeProgramProvider.notifier).restartProgram();
            AppLogger.debug('✅ [WorkoutUI] Program restarted successfully');

            if (context.mounted) {
              AppLogger.debug('📊 [WorkoutUI] Finishing workout after program restart...');
              await ref.read(workoutNotifierProvider.notifier).finish();
              AppLogger.debug('✅ [WorkoutUI] Workout finished after program restart');
            }
          } catch (e, s) {
            AppLogger.debug('❌ [WorkoutUI] Failed to restart program: $e');
            AppLogger.debug('🔍 [WorkoutUI] Stack trace: $s');
            if (context.mounted) ErrorHandler.handleError(context, e, s);
          }
        },
        onGenerateNew: () async {
          try {
            AppLogger.debug('📊 [WorkoutUI] User chose to generate new program');

            // Clear the current program
            AppLogger.debug('📊 [WorkoutUI] Clearing current program...');
            await ref.read(activeProgramProvider.notifier).clearProgram();
            AppLogger.debug('✅ [WorkoutUI] Program cleared successfully');

            // Navigate to program selection
            if (context.mounted) {
              AppLogger.debug('📊 [WorkoutUI] Navigating to program selection...');
              context.go(AppRoutes.workoutProgramSelection);
              AppLogger.debug('✅ [WorkoutUI] Navigation to program selection completed');
            }
          } catch (e, s) {
            AppLogger.debug('❌ [WorkoutUI] Failed to generate new program: $e');
            AppLogger.debug('🔍 [WorkoutUI] Stack trace: $s');
            if (context.mounted) ErrorHandler.handleError(context, e, s);
          }
        },
      ),
    );
    AppLogger.debug('✅ [WorkoutUI] Program complete dialog opened');
  } catch (e, s) {
    AppLogger.debug('❌ [WorkoutUI] Failed to show program complete dialog: $e');
    AppLogger.debug('🔍 [WorkoutUI] Stack trace: $s');
    if (context.mounted) ErrorHandler.handleError(context, e, s);
  }
}
