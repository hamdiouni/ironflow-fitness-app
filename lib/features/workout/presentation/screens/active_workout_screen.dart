import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/theme/app_typography.dart';
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
import '../../../ai/presentation/widgets/quick_feedback_bottom_sheet.dart';
import '../../../ai/presentation/providers/global_ai_provider.dart';
import '../../../../shared/presentation/services/app_haptics.dart';

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
  int _prCount = 0;

  @override
  Widget build(BuildContext context) {
    print('📊 [WorkoutUI] Building active workout screen...');
    final workoutState = ref.watch(workoutNotifierProvider);
    return workoutState.when(
      initial: () {
        print('🔍 [WorkoutUI] State: initial');
        return _buildInitialView(context);
      },
      inProgress: (workout, startTime) {
        print('🔍 [WorkoutUI] State: inProgress, exercises: ${workout.exercises.length}');
        return _buildWorkoutView(context, workout, startTime);
      },
      completed: (workout) {
        print('🔍 [WorkoutUI] State: completed');
        return _buildCompletedView(context, workout);
      },
    );
  }

  Widget _buildInitialView(BuildContext context) {
    print('📊 [WorkoutUI] Building initial view');
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
                      print('📊 [WorkoutUI] Begin workout button pressed');
                      await ref.read(workoutNotifierProvider.notifier).start();
                      print('✅ [WorkoutUI] Workout started successfully');
                    } catch (e, s) {
                      print('❌ [WorkoutUI] Failed to start workout: $e');
                      print('🔍 [WorkoutUI] Stack trace: $s');
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
    print('📊 [WorkoutUI] Building workout view');
    final tokens = context.tokens;
    final hasExercises = workout.exercises.isNotEmpty;
    final hasSets = workout.exercises.any((e) => e.sets.isNotEmpty);
    
    print('🔍 [WorkoutUI] Has exercises: $hasExercises, Has sets: $hasSets');
    
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
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              icon: Icon(Icons.add, color: tokens.kineticAccent, size: 22),
              tooltip: 'Add exercise',
              onPressed: () {
                print('📊 [WorkoutUI] Add exercise button pressed');
                _showExerciseSelection(context, workout);
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
                        isAnimating: _animatingExerciseId == exercise.id,
                        onAnimationComplete: () { if (mounted) setState(() => _animatingExerciseId = null); },
                        onLogSet: (reps, weight) => _logSet(exercise, reps, weight),
                      );
                    },
                  )
                : _EmptyExerciseHint(onAddExercise: () => _showExerciseSelection(context, workout)),
          ),
          _FinishWorkoutButton(enabled: hasSets, onFinish: () => _finishWorkout(context)),
        ],
      ),
    );
  }

  Widget _buildCompletedView(BuildContext context, Workout workout) {
    print('📊 [WorkoutUI] Building completed view');
    final totalSets = workout.exercises.fold<int>(0, (s, e) => s + e.sets.length);
    print('🔍 [WorkoutUI] Total sets: $totalSets, Total volume: ${workout.totalVolume}, Duration: ${workout.duration}');
    
    // Watch quick feedback state to show bottom sheet
    final quickFeedback = ref.watch(globalAIProvider.select((state) => state.quickFeedback));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Show quick feedback bottom sheet if available
        if (quickFeedback != null) {
          print('🎉 [WorkoutUI] Quick feedback available, showing bottom sheet...');
          QuickFeedbackBottomSheet.show(context, quickFeedback);
          print('✅ [WorkoutUI] Quick feedback bottom sheet shown');
        }
        
        print('📊 [WorkoutUI] Navigating to workout summary...');
        context.go(AppRoutes.workoutSummary, extra: <String, dynamic>{
          'totalSets': totalSets,
          'totalVolume': workout.totalVolume,
          'duration': workout.duration,
          'prCount': _prCount,
        });
        print('✅ [WorkoutUI] Navigation to summary completed');
        
        print('📊 [WorkoutUI] Resetting workout state...');
        ref.read(workoutNotifierProvider.notifier).reset();
        print('✅ [WorkoutUI] Workout state reset');
      }
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  void _showExerciseSelection(BuildContext context, Workout workout) {
    try {
      print('📊 [WorkoutUI] Opening exercise selection sheet...');
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
              print('📊 [WorkoutUI] Exercise selected: $name');
              Navigator.of(sheetContext).pop();
              try {
                final exercise = Exercise(id: const Uuid().v4(), name: name, type: ExerciseType.strength, sets: const []);
                print('🔍 [WorkoutUI] Exercise ID: ${exercise.id}, Type: ${exercise.type}');
                
                await ref.read(workoutNotifierProvider.notifier).addExercise(exercise);
                print('✅ [WorkoutUI] Exercise added successfully');
              } catch (e, s) {
                print('❌ [WorkoutUI] Failed to add exercise: $e');
                print('🔍 [WorkoutUI] Stack trace: $s');
                if (context.mounted) ErrorHandler.handleError(context, e, s);
              }
            },
          ),
        ),
      );
      print('✅ [WorkoutUI] Exercise selection sheet opened');
    } catch (e, s) {
      print('❌ [WorkoutUI] Failed to open exercise selection: $e');
      print('🔍 [WorkoutUI] Stack trace: $s');
      if (context.mounted) ErrorHandler.handleError(context, e, s);
    }
  }

  Future<void> _logSet(Exercise exercise, int reps, double weight) async {
    try {
      print('📊 [WorkoutUI] Logging set for exercise: ${exercise.name}');
      print('🔍 [WorkoutUI] Reps: $reps, Weight: ${weight}kg');
      
      final set = SetEntry.create(reps: reps, weight: weight);
      final isPR = await ref.read(workoutNotifierProvider.notifier).logSetForExercise(exercise.id, set);
      
      print('✅ [WorkoutUI] Set logged successfully');
      ref.read(appHapticsProvider).setLogged();
      
      if (mounted) setState(() => _animatingExerciseId = exercise.id);
      
      print('📊 [WorkoutUI] Starting rest timer...');
      ref.read(restTimerProvider.notifier).start(90); // 90 seconds default rest time
      print('✅ [WorkoutUI] Rest timer started');
      
      if (isPR && mounted && context.mounted) {
        print('🎉 [WorkoutUI] New PR detected for ${exercise.name}!');
        setState(() => _prCount++);
        print('🔍 [WorkoutUI] Total PRs this workout: $_prCount');
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('New PR on ${exercise.name}!'),
          backgroundColor: AppTheme.primaryColor,
          duration: const Duration(seconds: 2),
        ));
        print('✅ [WorkoutUI] PR notification shown');
      }
    } catch (e, s) {
      print('❌ [WorkoutUI] Failed to log set: $e');
      print('🔍 [WorkoutUI] Stack trace: $s');
      if (context.mounted) ErrorHandler.handleError(context, e, s);
    }
  }

  Future<void> _finishWorkout(BuildContext context) async {
    try {
      print('📊 [WorkoutUI] Finishing workout...');
      
      // Show calorie input dialog first
      print('📊 [WorkoutUI] Showing calorie input dialog...');
      final caloriesBurned = await _showCalorieInputDialog(context);
      
      // If user cancelled, don't finish workout
      if (caloriesBurned == null) {
        print('⚠️ [WorkoutUI] User cancelled calorie input');
        return;
      }
      
      print('🔍 [WorkoutUI] Calories burned: $caloriesBurned');
      
      // Update the workout with calories burned
      print('📊 [WorkoutUI] Updating workout with calories...');
      ref.read(workoutNotifierProvider.notifier).updateCalories(caloriesBurned);
      
      // Complete the current workout day in the active program
      print('📊 [WorkoutUI] Completing current day in active program...');
      await ref.read(activeProgramProvider.notifier).completeCurrentDay();
      print('✅ [WorkoutUI] Current day completed');
      
      // Check if program is now complete
      final activeProgramAsync = ref.read(activeProgramProvider);
      final activeProgram = activeProgramAsync.value;
      
      if (activeProgram != null && activeProgram.isProgramComplete) {
        print('🎉 [WorkoutUI] Program completed!');
        // Show program complete dialog
        if (context.mounted) {
          print('📊 [WorkoutUI] Showing program complete dialog...');
          _showProgramCompleteDialog(context, activeProgram);
        }
      } else {
        print('📊 [WorkoutUI] Program not complete, finishing workout normally...');
        // Finish the workout session normally
        await ref.read(workoutNotifierProvider.notifier).finish();
        print('✅ [WorkoutUI] Workout finished successfully');
      }
    } catch (e, s) {
      print('❌ [WorkoutUI] Failed to finish workout: $e');
      print('🔍 [WorkoutUI] Stack trace: $s');
      if (context.mounted) ErrorHandler.handleError(context, e, s);
    }
  }
  
  Future<double?> _showCalorieInputDialog(BuildContext context) async {
    try {
      print('📊 [WorkoutUI] Opening calorie input dialog...');
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
                  print('⚠️ [WorkoutUI] User cancelled calorie input dialog');
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
                  print('🔍 [WorkoutUI] User entered calories: $value');
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
        print('✅ [WorkoutUI] Calorie input dialog completed with value: $result');
      } else {
        print('⚠️ [WorkoutUI] Calorie input dialog cancelled');
      }
      
      return result;
    } catch (e, s) {
      print('❌ [WorkoutUI] Failed to show calorie input dialog: $e');
      print('🔍 [WorkoutUI] Stack trace: $s');
      return null;
    }
  }
  
  void _showProgramCompleteDialog(BuildContext context, ActiveProgram activeProgram) {
    try {
      print('📊 [WorkoutUI] Opening program complete dialog...');
      print('🔍 [WorkoutUI] Program name: ${activeProgram.program.name}');
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProgramCompleteDialog(
          programName: activeProgram.program.name,
          onRestart: () async {
            try {
              print('📊 [WorkoutUI] User chose to restart program');
              await ref.read(activeProgramProvider.notifier).restartProgram();
              print('✅ [WorkoutUI] Program restarted successfully');
              
              if (context.mounted) {
                print('📊 [WorkoutUI] Finishing workout after program restart...');
                await ref.read(workoutNotifierProvider.notifier).finish();
                print('✅ [WorkoutUI] Workout finished after program restart');
              }
            } catch (e, s) {
              print('❌ [WorkoutUI] Failed to restart program: $e');
              print('🔍 [WorkoutUI] Stack trace: $s');
              if (context.mounted) ErrorHandler.handleError(context, e, s);
            }
          },
          onGenerateNew: () async {
            try {
              print('📊 [WorkoutUI] User chose to generate new program');
              
              // Clear the current program
              print('📊 [WorkoutUI] Clearing current program...');
              await ref.read(activeProgramProvider.notifier).clearProgram();
              print('✅ [WorkoutUI] Program cleared successfully');
              
              // Navigate to program selection
              if (context.mounted) {
                print('📊 [WorkoutUI] Navigating to program selection...');
                context.go(AppRoutes.workoutProgramSelection);
                print('✅ [WorkoutUI] Navigation to program selection completed');
              }
            } catch (e, s) {
              print('❌ [WorkoutUI] Failed to generate new program: $e');
              print('🔍 [WorkoutUI] Stack trace: $s');
              if (context.mounted) ErrorHandler.handleError(context, e, s);
            }
          },
        ),
      );
      print('✅ [WorkoutUI] Program complete dialog opened');
    } catch (e, s) {
      print('❌ [WorkoutUI] Failed to show program complete dialog: $e');
      print('🔍 [WorkoutUI] Stack trace: $s');
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
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 38,
                  child: AppButton(
                    label: 'SKIP',
                    variant: AppButtonVariant.ghost,
                    onPressed: () => ref.read(restTimerProvider.notifier).skip(),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 38,
                  child: AppButton(
                    label: '+30s',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => ref.read(restTimerProvider.notifier).addTime(30),
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: tokens.kineticAccent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt, color: tokens.kineticAccent, size: 18),
            const SizedBox(width: 6),
            Text(
              'REST COMPLETE — TIME TO LIFT',
              style: TextStyle(
                color: tokens.kineticAccent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFamily: AppTypography.fontFamilyHeadings,
                letterSpacing: 0.5,
              ),
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
    this.programExercise,
  });
  final Exercise exercise;
  final bool isAnimating;
  final VoidCallback onAnimationComplete;
  final Future<void> Function(int reps, double weight) onLogSet;
  final ProgramExercise? programExercise;
  @override
  ConsumerState<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<_ExerciseCard> {
  final _repsController = TextEditingController(text: '8');
  final _weightController = TextEditingController(text: '0');
  bool _isLogging = false;
  bool _showVideo = false;

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tokens.card,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderSubtle, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
                          'Target: ${widget.programExercise!.sets} × ${widget.programExercise!.reps}',
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
                  final setNumber = e.key + 1;
                  final isSuggestedSetCompleted = widget.programExercise != null && setNumber <= widget.programExercise!.sets;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tokens.panel,
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      border: Border.all(
                        color: isSuggestedSetCompleted 
                            ? tokens.kineticAccent.withValues(alpha: 0.4)
                            : tokens.borderSubtle,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'SET $setNumber: ${e.value.weight}KG × ${e.value.reps}',
                      style: TextStyle(
                        color: isSuggestedSetCompleted ? tokens.kineticAccent : tokens.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppTypography.fontFamilyHeadings,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _NumberField(controller: _repsController, label: 'REPS', tokens: tokens)),
                const SizedBox(width: 8),
                Expanded(child: _NumberField(controller: _weightController, label: 'WEIGHT (KG)', isDecimal: true, tokens: tokens)),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: AppButton(
                    label: 'LOG SET',
                    variant: AppButtonVariant.primary,
                    isLoading: _isLogging,
                    onPressed: _isLogging ? null : _handleLogSet,
                  ),
                ),
              ],
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
    final weight = double.tryParse(_weightController.text.trim());
    if (reps == null || reps <= 0 || weight == null || weight < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid reps and weight')));
      return;
    }
    setState(() => _isLogging = true);
    try { await widget.onLogSet(reps, weight); }
    catch (e, s) { if (mounted) ErrorHandler.handleError(context, e, s); }
    finally { if (mounted) setState(() => _isLogging = false); }
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
