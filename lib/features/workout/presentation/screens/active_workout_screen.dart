import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/core/utils/error_handler.dart';
import 'package:progression_tracker/shared/presentation/components/components.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/presentation/providers/rest_timer_provider.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/workout/presentation/widgets/program_complete_dialog.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/quick_feedback_bottom_sheet.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';
import 'package:progression_tracker/features/workout/domain/usecases/calculate_workout_volume_use_case.dart';
import 'package:progression_tracker/features/workout/domain/usecases/workout_metrics.dart';
import '../widgets/active_workout/active_exercise_card.dart';
import '../widgets/active_workout/active_rest_timer_section.dart';
import '../widgets/active_workout/exercise_selection_sheet.dart';
export '../widgets/active_workout/exercise_selection_sheet.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final ActiveProgram? activeProgram;

  const ActiveWorkoutScreen({
    super.key,
    this.activeProgram,
  });
  
  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  String? _animatingExerciseId;
  // Note: Deliberate product decision: PR celebration count is event-based from
  // when a set is first logged. Editing or removing that set does not recalculate
  // the live session celebration count. Saved workout data, history, and progression
  // remain correct and canonical.
  int _prCount = 0;
  WeightUnit _weightUnit = WeightUnit.kg;

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('📊 [WorkoutUI] Building active workout screen...');
    final workoutState = ref.watch(workoutNotifierProvider);
    return workoutState.when(
      initial: () {
        AppLogger.debug('🔍 [WorkoutUI] State: initial');
        return _buildInitialView(context);
      },
      inProgress: (workout, startTime) {
        AppLogger.debug('🔍 [WorkoutUI] State: inProgress, exercises: ${workout.exercises.length}');
        return _buildWorkoutView(context, workout, startTime);
      },
      completed: (workout) {
        AppLogger.debug('🔍 [WorkoutUI] State: completed');
        return _buildCompletedView(context, workout);
      },
    );
  }

  Widget _buildInitialView(BuildContext context) {
    AppLogger.debug('📊 [WorkoutUI] Building initial view');
    final tokens = context.tokens;
    return Scaffold(
      backgroundColor: tokens.canvas,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.kineticAccent.withValues(alpha: 0.12),
                  border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: tokens.kineticAccent.withValues(alpha: 0.25), blurRadius: 16),
                  ],
                ),
                child: Icon(Icons.fitness_center_rounded, size: 36, color: tokens.kineticAccent),
              ),
              const SizedBox(height: 24),
              Text(
                'READY TO TRAIN?',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: AppTypography.fontFamilyHeadings,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start a new session and log sets with telemetry.',
                style: TextStyle(color: tokens.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 220,
                height: 52,
                child: AppButton(
                  label: '▶ BEGIN WORKOUT',
                  variant: AppButtonVariant.primary,
                  onPressed: () async {
                    try {
                      AppLogger.debug('📊 [WorkoutUI] Begin workout button pressed');
                      await ref.read(workoutNotifierProvider.notifier).start();
                      AppLogger.debug('✅ [WorkoutUI] Workout started successfully');
                    } catch (e, s) {
                      AppLogger.debug('❌ [WorkoutUI] Failed to start workout: $e');
                      AppLogger.debug('🔍 [WorkoutUI] Stack trace: $s');
                      if (context.mounted) ErrorHandler.handleError(context, e, s);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutView(BuildContext context, Workout workout, DateTime startTime) {
    AppLogger.debug('📊 [WorkoutUI] Building workout view');
    final tokens = context.tokens;
    final hasExercises = workout.exercises.isNotEmpty;
    final hasSets = WorkoutMetrics.hasWorkingSets(workout);
    
    AppLogger.debug('🔍 [WorkoutUI] Has exercises: $hasExercises, Has sets: $hasSets');
    
    // Get program exercises from active program
    final programExercises = ref.watch(currentDayExercisesProvider);
    
    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        backgroundColor: tokens.canvas,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'ACTIVE WORKOUT',
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: AppTypography.fontFamilyHeadings,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          Center(
            child: InkWell(
              key: const Key('weight_unit_toggle'),
              borderRadius: BorderRadius.circular(tokens.radiusPill),
              onTap: () {
                AppHaptics.shared.selectionChanged();
                setState(() {
                  _weightUnit = _weightUnit == WeightUnit.kg
                      ? WeightUnit.lb
                      : WeightUnit.kg;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                  border: Border.all(color: tokens.borderSubtle, width: 1),
                ),
                child: Text(
                  _weightUnit.label,
                  style: TextStyle(
                    color: tokens.kineticAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    fontFamily: AppTypography.displayFontFamily,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              key: const Key('discard_workout_button'),
              icon: Icon(Icons.delete_outline, color: tokens.error, size: 22),
              tooltip: 'Discard Workout',
              onPressed: () => _confirmDiscardWorkout(context),
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: Icon(Icons.add, color: tokens.kineticAccent, size: 22),
              tooltip: 'Add exercise',
              onPressed: () {
                AppLogger.debug('📊 [WorkoutUI] Add exercise button pressed');
                _showExerciseSelection(workout);
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(

        children: [
          const ActiveRestTimerSection(),
          Expanded(
            child: hasExercises
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: workout.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = workout.exercises[index];
                      // Find corresponding program exercise if it exists
                      final programExercise = programExercises.firstWhereOrNull(
                        (pe) => pe.exerciseName.toLowerCase() == exercise.name.toLowerCase(),
                      );
                      
                      return ActiveExerciseCard(
                        key: ValueKey(exercise.id),
                        exercise: exercise,
                        programExercise: programExercise,
                        weightUnit: _weightUnit,
                        isAnimating: _animatingExerciseId == exercise.id,
                        onAnimationComplete: () { if (mounted) setState(() => _animatingExerciseId = null); },
                        onLogSet: (reps, weight, [type = SetType.normal, rpe]) => _logSet(exercise, reps, weight, type, rpe),
                        onUpdateSetType: (setIndex, newType) => ref.read(workoutNotifierProvider.notifier).updateSetType(exercise.id, setIndex, newType),
                      );
                    },
                  )
                : _EmptyExerciseHint(onAddExercise: () => _showExerciseSelection(workout)),
          ),
          _FinishWorkoutButton(enabled: hasSets, onFinish: () => _finishWorkout(context)),
        ],
      ),
    );
  }

  Future<void> _confirmDiscardWorkout(BuildContext context) async {
    final tokens = context.tokens;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: tokens.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          side: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        title: Text(
          'DISCARD WORKOUT?',
          style: TextStyle(
            color: tokens.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: AppTypography.fontFamilyHeadings,
          ),
        ),
        content: Text(
          'Are you sure you want to discard this workout session? Unsaved progress will be lost.',
          style: TextStyle(color: tokens.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('CANCEL', style: TextStyle(color: tokens.textMuted)),
          ),
          AppButton(
            key: const Key('confirm_discard_workout_button'),
            label: 'DISCARD',
            variant: AppButtonVariant.destructive,
            height: 40,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ref.read(restTimerProvider.notifier).stop();
      await ref.read(workoutNotifierProvider.notifier).reset();
      if (!context.mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        try {
          context.go(AppRoutes.workout);
        } catch (_) {}
      }
    }
  }

  Widget _buildCompletedView(BuildContext context, Workout workout) {
    AppLogger.debug('📊 [WorkoutUI] Building completed view');
    final totalWorkingSets = WorkoutMetrics.workingSetCount(workout);
    final volumeUseCase = CalculateWorkoutVolumeUseCase();
    final totalWorkingVolume = volumeUseCase(workout);
    AppLogger.debug('🔍 [WorkoutUI] Total working sets: $totalWorkingSets, Working volume: $totalWorkingVolume, Duration: ${workout.duration}');
    
    // Watch quick feedback state to show bottom sheet
    final quickFeedback = ref.watch(globalAIProvider.select((state) => state.quickFeedback));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Show quick feedback bottom sheet if available
        if (quickFeedback != null) {
          AppLogger.debug('🎉 [WorkoutUI] Quick feedback available, showing bottom sheet...');
          QuickFeedbackBottomSheet.show(context, quickFeedback);
          AppLogger.debug('✅ [WorkoutUI] Quick feedback bottom sheet shown');
        }
        
        AppLogger.debug('📊 [WorkoutUI] Navigating to workout summary...');
        context.go(AppRoutes.workoutSummary, extra: <String, dynamic>{
          'workoutId': workout.id,
          'exercises': workout.exercises,
          'totalSets': totalWorkingSets,
          'totalVolume': totalWorkingVolume,
          'duration': workout.duration,
          'prCount': _prCount,
          'exerciseNames': workout.exercises.map((e) => e.name).toList(),
        });
        AppLogger.debug('✅ [WorkoutUI] Navigation to summary completed');
        
        AppLogger.debug('📊 [WorkoutUI] Resetting workout state...');
        ref.read(workoutNotifierProvider.notifier).reset();
        AppLogger.debug('✅ [WorkoutUI] Workout state reset');
      }
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  void _showExerciseSelection(Workout workout) {
    try {
      AppLogger.debug('📊 [WorkoutUI] Opening exercise selection sheet...');
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                final exercise = Exercise(id: const Uuid().v4(), name: name, type: ExerciseType.strength, sets: const []);
                AppLogger.debug('🔍 [WorkoutUI] Exercise ID: ${exercise.id}, Type: ${exercise.type}');
                
                await ref.read(workoutNotifierProvider.notifier).addExercise(exercise);
                AppLogger.debug('✅ [WorkoutUI] Exercise added successfully');
              } catch (e, s) {
                AppLogger.debug('❌ [WorkoutUI] Failed to add exercise: $e');
                AppLogger.debug('🔍 [WorkoutUI] Stack trace: $s');
                if (mounted) ErrorHandler.handleError(context, e, s);
              }
            },
          ),
        ),
      );
      AppLogger.debug('✅ [WorkoutUI] Exercise selection sheet opened');
    } catch (e, s) {
      AppLogger.debug('❌ [WorkoutUI] Failed to open exercise selection: $e');
      AppLogger.debug('🔍 [WorkoutUI] Stack trace: $s');
      if (mounted) ErrorHandler.handleError(context, e, s);
    }
  }

  Future<void> _logSet(Exercise exercise, int reps, double weight, [SetType type = SetType.normal, int? rpe]) async {
    try {
      AppLogger.debug('📊 [WorkoutUI] Logging set for exercise: ${exercise.name}');
      AppLogger.debug('🔍 [WorkoutUI] Reps: $reps, Weight: ${weight}kg, Type: ${type.name}, RPE: $rpe');
      
      final set = SetEntry.create(reps: reps, weight: weight, type: type, rpe: rpe);
      final isPR = await ref.read(workoutNotifierProvider.notifier).logSetForExercise(exercise.id, set);
      
      AppLogger.debug('✅ [WorkoutUI] Set logged successfully');
      ref.read(appHapticsProvider).setLogged();
      
      if (mounted) setState(() => _animatingExerciseId = exercise.id);
      
      AppLogger.debug('📊 [WorkoutUI] Starting rest timer...');
      ref.read(restTimerProvider.notifier).start(90); // 90 seconds default rest time
      AppLogger.debug('✅ [WorkoutUI] Rest timer started');
      
      if (isPR && mounted && context.mounted) {
        AppLogger.debug('🎉 [WorkoutUI] New PR detected for ${exercise.name}!');
        setState(() => _prCount++);
        AppLogger.debug('🔍 [WorkoutUI] Total PRs this workout: $_prCount');
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('New PR on ${exercise.name}!'),
          backgroundColor: AppTheme.primaryColor,
          duration: const Duration(seconds: 2),
        ));
        AppLogger.debug('✅ [WorkoutUI] PR notification shown');
      }
    } catch (e, s) {
      AppLogger.debug('❌ [WorkoutUI] Failed to log set: $e');
      AppLogger.debug('🔍 [WorkoutUI] Stack trace: $s');
      if (mounted) ErrorHandler.handleError(context, e, s);
    }
  }

  Future<void> _finishWorkout(BuildContext context) async {
    try {
      final current = ref.read(workoutNotifierProvider);
      final hasWorkingSets = current.maybeWhen(
        inProgress: (w, _) => WorkoutMetrics.hasWorkingSets(w),
        orElse: () => false,
      );
      if (!hasWorkingSets) {
        AppLogger.debug('⚠️ [WorkoutUI] Cannot finish workout: zero working sets');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Log at least one working set before finishing.'),
            ),
          );
        }
        return;
      }

      AppLogger.debug('📊 [WorkoutUI] Finishing workout...');
      
      // Show calorie input dialog first
      AppLogger.debug('📊 [WorkoutUI] Showing calorie input dialog...');
      final caloriesBurned = await _showCalorieInputDialog(context);
      
      // If user cancelled, don't finish workout
      if (caloriesBurned == null) {
        AppLogger.debug('⚠️ [WorkoutUI] User cancelled calorie input');
        return;
      }
      
      AppLogger.debug('🔍 [WorkoutUI] Calories burned: $caloriesBurned');
      
      // Update the workout with calories burned
      AppLogger.debug('📊 [WorkoutUI] Updating workout with calories...');
      ref.read(workoutNotifierProvider.notifier).updateCalories(caloriesBurned);

      // Persist + advance as ONE orchestrated unit (Phase 3, F-06):
      // WorkoutNotifier.finish() runs CompleteWorkoutUseCase, which saves
      // the workout first and then advances the active program — but only
      // if this workout was the program's current day. The screen used to
      // call completeCurrentDay() separately here, which advanced the
      // program for ANY finished workout (custom/repeat sessions too).
      AppLogger.debug('📊 [WorkoutUI] Finishing (saving) workout session...');
      await ref.read(workoutNotifierProvider.notifier).finish();
      AppLogger.debug('✅ [WorkoutUI] Workout finished successfully');

      // finish() switched state to completed, whose view navigates to the
      // summary screen in a post-frame callback. If that already ran, this
      // widget is unmounted and `ref` must not be touched again — workout
      // and program day are already persisted, only the dialog is skipped.
      if (!mounted) return;

      // Check if the program is now complete. Read from the repository,
      // not the notifier: finish() advanced the program through the
      // repository, and the notifier's state refreshes asynchronously
      // via the box-watch stream — it may not have landed yet.
      final activeProgram = await ref
          .read(activeProgramRepositoryProvider)
          .loadActiveProgram();

      if (activeProgram != null && activeProgram.isProgramComplete) {
        AppLogger.debug('🎉 [WorkoutUI] Program completed!');
        // Show program complete dialog (workout is already saved; the
        // dialog's own finish() calls are now harmless no-ops)
        if (context.mounted) {
          AppLogger.debug('📊 [WorkoutUI] Showing program complete dialog...');
          _showProgramCompleteDialog(context, activeProgram);
        }
      }
    } catch (e, s) {
      AppLogger.debug('❌ [WorkoutUI] Failed to finish workout: $e');
      AppLogger.debug('🔍 [WorkoutUI] Stack trace: $s');
      if (context.mounted) ErrorHandler.handleError(context, e, s);
    }
  }
  
  Future<double?> _showCalorieInputDialog(BuildContext context) async {
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
                    suffixStyle: TextStyle(color: tokens.kineticAccent, fontWeight: FontWeight.bold),
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
  
  void _showProgramCompleteDialog(BuildContext context, ActiveProgram activeProgram) {
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
}

class _EmptyExerciseHint extends StatelessWidget {
  const _EmptyExerciseHint({required this.onAddExercise});
  final VoidCallback onAddExercise;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AppStateView.empty(
          title: 'NO EXERCISES YET',
          message: 'Add exercises to this workout to begin logging sets.',
          actionLabel: '+ ADD EXERCISE',
          onAction: onAddExercise,
        ),
      ),
    );
  }
}

class _FinishWorkoutButton extends StatelessWidget {
  const _FinishWorkoutButton({required this.enabled, required this.onFinish});
  final bool enabled;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: AppButton(
          label: 'FINISH WORKOUT',
          variant: AppButtonVariant.primary,
          isFullWidth: true,
          onPressed: enabled ? onFinish : null,
        ),
      ),
    );
  }
}
