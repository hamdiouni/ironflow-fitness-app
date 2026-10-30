import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../shared/presentation/components/components.dart';
import '../../data/exercise_video_map.dart';
import '../../domain/entities/entities.dart';
import '../../../../shared/animations/rest_timer_circular.dart';
import '../../../../shared/animations/set_completion_animation.dart';
import '../providers/rest_timer_provider.dart';
import '../providers/workout_providers.dart';
import '../providers/active_program_providers.dart';
import '../widgets/program_complete_dialog.dart';
import '../widgets/exercise_video_player.dart';
import '../widgets/plate_calculator_sheet.dart';
import '../../../ai/presentation/widgets/quick_feedback_bottom_sheet.dart';
import '../../../ai/presentation/providers/global_ai_provider.dart';
import '../../../../shared/presentation/services/app_haptics.dart';
import '../../domain/usecases/calculate_workout_volume_use_case.dart';
import '../../domain/usecases/workout_metrics.dart';

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
              borderRadius: BorderRadius.circular(tokens.radiusSm),
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
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
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
          const _RestTimerSection(),
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
                      
                      return _ExerciseCard(
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

class _RestTimerSection extends ConsumerWidget {
  const _RestTimerSection();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(restTimerProvider);
    final tokens = context.tokens;
    
    if (timerState.isRunning && !timerState.isComplete) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.35), width: 1),
          boxShadow: [
            BoxShadow(
              color: tokens.kineticAccent.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const RestTimerCircular(size: 90),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 36,
                  child: AppButton(
                    label: '-15s',
                    variant: AppButtonVariant.ghost,
                    onPressed: () {
                      AppHaptics.shared.buttonPress();
                      ref.read(restTimerProvider.notifier).addTime(-15);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 36,
                  child: AppButton(
                    label: 'SKIP',
                    variant: AppButtonVariant.secondary,
                    onPressed: () {
                      AppHaptics.shared.selectionChanged();
                      ref.read(restTimerProvider.notifier).skip();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 36,
                  child: AppButton(
                    label: '+30s',
                    variant: AppButtonVariant.primary,
                    onPressed: () {
                      AppHaptics.shared.buttonPress();
                      ref.read(restTimerProvider.notifier).addTime(30);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    
    if (timerState.isComplete) {
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: tokens.kineticAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          children: [
            Icon(Icons.bolt, color: tokens.kineticAccent, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'REST COMPLETE — READY TO LIFT',
                style: TextStyle(
                  color: tokens.kineticAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppTypography.fontFamilyHeadings,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: tokens.kineticAccent, size: 18),
              tooltip: 'Dismiss',
              onPressed: () {
                AppHaptics.shared.selectionChanged();
                ref.read(restTimerProvider.notifier).stop();
              },
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }
}

class _ExerciseCard extends ConsumerStatefulWidget {
  const _ExerciseCard({
    super.key,
    required this.exercise,
    required this.isAnimating,
    required this.onAnimationComplete,
    required this.onLogSet,
    required this.onUpdateSetType,
    this.programExercise,
    this.weightUnit = WeightUnit.kg,
  });
  final Exercise exercise;
  final bool isAnimating;
  final VoidCallback onAnimationComplete;
  final Future<void> Function(int reps, double weight, [SetType type, int? rpe]) onLogSet;
  final Future<void> Function(int setIndex, SetType newType) onUpdateSetType;
  final ProgramExercise? programExercise;
  final WeightUnit weightUnit;
  @override
  ConsumerState<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<_ExerciseCard> {
  final _repsController = TextEditingController(text: '8');
  final _weightController = TextEditingController(text: '0');
  final _rpeController = TextEditingController();
  bool _isRirMode = false;
  bool _isLogging = false;
  bool _showVideo = false;
  SetType _selectedSetType = SetType.normal;

  @override
  void initState() {
    super.initState();
    final prog = widget.programExercise;
    if (prog != null) {
      if (prog.targetWeight != null && prog.targetWeight! > 0) {
        _weightController.text = prog.targetWeight!.toStringAsFixed(1);
      }
      final parsedReps = int.tryParse(prog.reps);
      if (parsedReps != null && parsedReps > 0) {
        _repsController.text = parsedReps.toString();
      }
    }
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    _rpeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final suggestionAsync = ref.watch(progressionSuggestionProvider(widget.exercise.name));
    final thumbUrl = ExerciseVideoMap.thumbnailUrl(widget.exercise.name);
    
    // Check if all suggested sets are completed
    final allSuggestedSetsCompleted = _checkAllSuggestedSetsCompleted();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _showVideo = !_showVideo),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: thumbUrl,
                          width: 72,
                          height: 52,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Container(
                            width: 72, height: 52,
                            color: tokens.panel,
                            child: Icon(Icons.fitness_center, color: tokens.kineticAccent, size: 22),
                          ),
                        ),
                        Container(
                          width: 72, height: 52,
                          color: Colors.black45,
                          child: const Icon(Icons.play_circle_outline, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exercise.name,
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppTypography.fontFamilyHeadings,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Display program exercise suggestion if available
                      if (widget.programExercise != null) ...[
                        Text(
                          widget.programExercise!.targetWeight != null &&
                                  widget.programExercise!.targetWeight! > 0
                              ? 'Target: ${widget.programExercise!.targetWeight!.toStringAsFixed(1)}kg · ${widget.programExercise!.sets} × ${widget.programExercise!.reps}'
                              : 'Target: ${widget.programExercise!.sets} × ${widget.programExercise!.reps}',
                          style: TextStyle(
                            color: allSuggestedSetsCompleted ? tokens.kineticAccent : tokens.cyanAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: AppTypography.fontFamilyHeadings,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ] else ...[
                        suggestionAsync.when(
                          data: (s) => s != null ? Text(
                            s.isStagnant ? 'Stagnant — Try ${(s.suggestedWeight * 1.05).toStringAsFixed(1)}kg' : 'Target: ${s.suggestedWeight}kg × ${s.suggestedReps}',
                            style: TextStyle(
                              color: s.isStagnant ? tokens.warning : tokens.kineticAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ) : const SizedBox.shrink(),
                          loading: () => SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: tokens.kineticAccent),
                          ),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.isAnimating) SetCompletionAnimation(onComplete: widget.onAnimationComplete),
              ],
            ),
            if (_showVideo) ...[
              const SizedBox(height: 12),
              _VideoPreviewBanner(exerciseName: widget.exercise.name),
            ],
            if (widget.exercise.sets.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.exercise.sets.asMap().entries.map((e) {
                  final setIndex = e.key;
                  final set = e.value;
                  final setNumber = setIndex + 1;
                  final isSuggestedSetCompleted = widget.programExercise != null && setNumber <= widget.programExercise!.sets;
                  final setType = set.type;
                  final typeColor = switch (setType) {
                    SetType.warmup => tokens.cyanAccent,
                    SetType.normal => isSuggestedSetCompleted ? tokens.kineticAccent : tokens.textSecondary,
                    SetType.drop => tokens.warning,
                    SetType.failure => tokens.error,
                  };
                  final rpeText = set.rpe != null
                      ? (_isRirMode ? ' • ${10 - set.rpe!} RIR' : ' • @${set.rpe} RPE')
                      : '';
                  
                  return Tooltip(
                    message: 'Tap to cycle set type (${setType.label})',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      onTap: () async {
                        await AppHaptics.shared.selectionChanged();
                        await widget.onUpdateSetType(setIndex, setType.next);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: tokens.panel,
                          borderRadius: BorderRadius.circular(tokens.radiusSm),
                          border: Border.all(
                            color: typeColor.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                setType.shortCode,
                                style: TextStyle(
                                  color: typeColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: AppTypography.displayFontFamily,
                                ),
                              ),
                            ),
                            Text(
                              widget.weightUnit == WeightUnit.kg
                                  ? 'SET $setNumber: ${set.weight}KG × ${set.reps}$rpeText'
                                  : 'SET $setNumber: ${WorkoutMetrics.fromCanonicalKg(set.weight, WeightUnit.lb).toStringAsFixed(1)}LB × ${set.reps}$rpeText',
                              style: TextStyle(
                                color: typeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                fontFamily: AppTypography.fontFamilyHeadings,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 14),

            // ── Set Type Selector Row ─────────────────────────────────
            Row(
              children: SetType.values.map((type) {
                final isSelected = _selectedSetType == type;
                final color = switch (type) {
                  SetType.warmup => tokens.cyanAccent,
                  SetType.normal => tokens.kineticAccent,
                  SetType.drop => tokens.warning,
                  SetType.failure => tokens.error,
                };
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () {
                        AppHaptics.shared.selectionChanged();
                        setState(() => _selectedSetType = type);
                      },
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.18) : tokens.panel,
                          borderRadius: BorderRadius.circular(tokens.radiusSm),
                          border: Border.all(
                            color: isSelected ? color : tokens.borderSubtle,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            type.label.toUpperCase(),
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              fontSize: 9,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              letterSpacing: 0.3,
                              color: isSelected ? color : tokens.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            // ── Inputs Row (Reps, Weight, RPE/RIR, Plate Calc, Log Set) ─────────
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 360;
                final rpeStack = Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    _NumberField(
                      controller: _rpeController,
                      label: _isRirMode ? 'RIR' : 'RPE',
                      tokens: tokens,
                    ),
                    Positioned(
                      right: 4,
                      child: InkWell(
                        onTap: () {
                          AppHaptics.shared.selectionChanged();
                          setState(() {
                            _isRirMode = !_isRirMode;
                            final val = int.tryParse(_rpeController.text.trim());
                            if (val != null) {
                              final converted = (10 - val).clamp(0, 10);
                              _rpeController.text = converted.toString();
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: tokens.cyanAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: tokens.cyanAccent.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            _isRirMode ? 'RIR' : 'RPE',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: tokens.cyanAccent,
                              fontFamily: AppTypography.displayFontFamily,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );

                final plateCalcBtn = IconButton(
                  tooltip: 'Plate Calculator',
                  icon: Icon(Icons.calculate_outlined, color: tokens.kineticAccent, size: 24),
                  onPressed: () {
                    final currentWeight = double.tryParse(_weightController.text) ?? 60.0;
                    PlateCalculatorSheet.show(
                      context,
                      initialWeight: currentWeight,
                      onApplyWeight: (calcWeight) {
                        setState(() {
                          _weightController.text = calcWeight == calcWeight.roundToDouble()
                              ? calcWeight.toInt().toString()
                              : calcWeight.toStringAsFixed(1);
                        });
                      },
                    );
                  },
                );

                final logSetBtn = SizedBox(
                  height: 48,
                  child: AppButton(
                    label: 'LOG SET',
                    variant: AppButtonVariant.primary,
                    isLoading: _isLogging,
                    onPressed: _isLogging ? null : _handleLogSet,
                  ),
                );

                final weightLabel = 'WEIGHT (${widget.weightUnit.label})';

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: _NumberField(
                              controller: _repsController,
                              label: 'REPS',
                              tokens: tokens,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 6,
                            child: _NumberField(
                              controller: _weightController,
                              label: weightLabel,
                              isDecimal: true,
                              tokens: tokens,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(flex: 5, child: rpeStack),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          plateCalcBtn,
                          const SizedBox(width: 8),
                          Expanded(child: logSetBtn),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: _NumberField(
                        controller: _repsController,
                        label: 'REPS',
                        tokens: tokens,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 6,
                      child: _NumberField(
                        controller: _weightController,
                        label: weightLabel,
                        isDecimal: true,
                        tokens: tokens,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(flex: 5, child: rpeStack),
                    const SizedBox(width: 4),
                    plateCalcBtn,
                    const SizedBox(width: 4),
                    logSetBtn,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Check if all suggested sets from the program exercise have been completed
  bool _checkAllSuggestedSetsCompleted() {
    if (widget.programExercise == null) return false;
    return widget.exercise.sets.length >= widget.programExercise!.sets;
  }

  Future<void> _handleLogSet() async {
    final reps = int.tryParse(_repsController.text.trim());
    final rawWeight = double.tryParse(_weightController.text.trim());
    final canonicalWeight =
        WorkoutMetrics.toCanonicalKg(rawWeight, widget.weightUnit);
    if (reps == null ||
        !WorkoutMetrics.isValidReps(reps) ||
        canonicalWeight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid reps and weight')),
      );
      return;
    }

    int? parsedRpe;
    final rpeText = _rpeController.text.trim();
    if (rpeText.isNotEmpty) {
      final val = int.tryParse(rpeText);
      if (val != null) {
        if (_isRirMode) {
          if (val >= 0 && val <= 9) {
            parsedRpe = 10 - val;
          }
        } else {
          if (val >= 1 && val <= 10) {
            parsedRpe = val;
          }
        }
      }
    }

    setState(() => _isLogging = true);
    try {
      await widget.onLogSet(reps, canonicalWeight, _selectedSetType, parsedRpe);
    } catch (e, s) {
      if (mounted) ErrorHandler.handleError(context, e, s);
    } finally {
      if (mounted) setState(() => _isLogging = false);
    }
  }
}

class _VideoPreviewBanner extends StatelessWidget {
  const _VideoPreviewBanner({required this.exerciseName});
  final String exerciseName;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ExerciseVideoPlayer(
        exerciseName: exerciseName,
        onError: (error) {
          debugPrint('Video player error: $error');
        },
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.tokens,
    this.isDecimal = false,
  });

  final TextEditingController controller;
  final String label;
  final bool isDecimal;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: tokens.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        fontFamily: AppTypography.fontFamilyHeadings,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: tokens.textMuted,
          letterSpacing: 0.5,
        ),
        filled: true,
        fillColor: tokens.panel,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          borderSide: BorderSide(color: tokens.kineticAccent, width: 1.5),
        ),
      ),
    );
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
          message: 'Add exercises to this workout protocol to begin logging sets.',
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

class ExerciseSelectionSheet extends StatefulWidget {
  const ExerciseSelectionSheet({super.key, required this.scrollController, required this.onExerciseSelected});
  final ScrollController scrollController;
  final void Function(String name) onExerciseSelected;
  @override
  State<ExerciseSelectionSheet> createState() => _ExerciseSelectionSheetState();
}

class _ExerciseSelectionSheetState extends State<ExerciseSelectionSheet> {
  static const _exercises = [
    'Bench Press', 'Squat', 'Deadlift', 'Overhead Press', 'Barbell Row',
    'Pull-Up', 'Dip', 'Incline Bench Press', 'Romanian Deadlift', 'Leg Press',
    'Lunges', 'Bicep Curl', 'Barbell Curl', 'Dumbbell Curl', 'Tricep Pushdown',
    'Lateral Raise', 'Face Pull', 'Running', 'Cycling', 'Rowing Machine',
    'Jump Rope', 'Plank', 'Crunch', 'Leg Raise', 'Hip Thrust',
    'Glute Bridge', 'Lat Pulldown', 'Seated Cable Row', 'Dumbbell Row',
    'Push-Up', 'Hammer Curl', 'Skull Crusher', 'Calf Raise', 'Hack Squat',
    'Bulgarian Split Squat', 'Leg Curl', 'Leg Extension', 'Cable Crossover',
    'Arnold Press', 'Front Raise', 'Reverse Fly', 'Dumbbell Shoulder Press',
    'Overhead Tricep Extension', 'Close Grip Bench Press', 'Russian Twist',
  ];

  String _query = '';
  List<String> get _filtered => _query.isEmpty ? _exercises : _exercises.where((e) => e.toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: tokens.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radiusLg)),
        border: Border(top: BorderSide(color: tokens.borderSubtle, width: 1)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: tokens.borderSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              style: TextStyle(color: tokens.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                hintStyle: TextStyle(color: tokens.textMuted),
                prefixIcon: Icon(Icons.search, color: tokens.textMuted),
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
          ),
          Expanded(
            child: ListView.builder(
              controller: widget.scrollController,
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final name = _filtered[index];
                final thumbUrl = ExerciseVideoMap.thumbnailUrl(name);
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    child: CachedNetworkImage(
                      imageUrl: thumbUrl,
                      width: 48,
                      height: 36,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                        width: 48, height: 36,
                        color: tokens.panel,
                        child: Icon(Icons.fitness_center, color: tokens.kineticAccent, size: 18),
                      ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => widget.onExerciseSelected(name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
