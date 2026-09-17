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
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text('Ready to train?', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Start a new workout session', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 32),
            ElevatedButton.icon(
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
              icon: const Icon(Icons.play_arrow),
              label: const Text('Begin Workout'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 52)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutView(BuildContext context, Workout workout, DateTime startTime) {
    print('📊 [WorkoutUI] Building workout view');
    final hasExercises = workout.exercises.isNotEmpty;
    final hasSets = workout.exercises.any((e) => e.sets.isNotEmpty);
    
    print('🔍 [WorkoutUI] Has exercises: $hasExercises, Has sets: $hasSets');
    
    // Get program exercises from active program
    final programExercises = ref.watch(currentDayExercisesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Workout'),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
            tooltip: 'Add exercise',
            onPressed: () {
              print('📊 [WorkoutUI] Add exercise button pressed');
              _showExerciseSelection(context, workout);
            },
          ),
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
      
      // Update the workout with calories burned using maybeWhen
      print('📊 [WorkoutUI] Updating workout with calories...');
      final workoutState = ref.read(workoutNotifierProvider);
      workoutState.maybeWhen(
        inProgress: (workout, startTime) {
          // Update the workout entity with calories
          final updatedWorkout = workout.copyWith(
            caloriesBurned: caloriesBurned,
          );
          // Update the state with the new workout
          ref.read(workoutNotifierProvider.notifier).state = WorkoutState.inProgress(
            updatedWorkout,
            startTime,
          );
          print('✅ [WorkoutUI] Workout updated with calories');
        },
        orElse: () {
          print('⚠️ [WorkoutUI] Workout not in progress state');
        },
      );
      
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
        builder: (context) => AlertDialog(
          title: const Text('Calories Burned'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How many calories did you burn during this workout?',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                  suffixText: 'kcal',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tip: A typical strength training session burns 200-400 kcal',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final value = double.tryParse(controller.text) ?? 0;
                print('🔍 [WorkoutUI] User entered calories: $value');
                Navigator.of(context).pop(value);
              },
              child: const Text('Save'),
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    
    if (timerState.isRunning && !timerState.isComplete) {
      return Container(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            const RestTimerCircular(size: 90),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: () => ref.read(restTimerProvider.notifier).skip(), child: const Text('Skip')),
                const SizedBox(width: 16),
                TextButton(onPressed: () => ref.read(restTimerProvider.notifier).addTime(30), child: const Text('+30s')),
              ],
            ),
          ],
        ),
      );
    }
    
    if (timerState.isComplete) {
      return Container(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        padding: const EdgeInsets.all(8),
        child: const Text('Rest complete - time to lift!', style: TextStyle(color: AppTheme.primaryColor), textAlign: TextAlign.center),
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
    final suggestionAsync = ref.watch(progressionSuggestionProvider(widget.exercise.name));
    final thumbUrl = ExerciseVideoMap.thumbnailUrl(widget.exercise.name);
    
    // Check if all suggested sets are completed
    final allSuggestedSetsCompleted = _checkAllSuggestedSetsCompleted();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppTheme.glassmorphicCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _showVideo = !_showVideo),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: thumbUrl,
                          width: 72,
                          height: 52,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 72, height: 52,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.fitness_center, color: AppTheme.primaryColor, size: 24),
                          ),
                        ),
                        Container(
                          width: 72, height: 52,
                          color: Colors.black38,
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
                      Text(widget.exercise.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      // Display program exercise suggestion if available
                      if (widget.programExercise != null) ...[
                        Text(
                          'Target: ${widget.programExercise!.sets} x ${widget.programExercise!.reps}',
                          style: TextStyle(
                            color: allSuggestedSetsCompleted ? Colors.green : AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: allSuggestedSetsCompleted ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ] else ...[
                        suggestionAsync.when(
                          data: (s) => s != null ? Text(
                            s.isStagnant ? 'Stagnant - try ${(s.suggestedWeight * 1.05).toStringAsFixed(1)}kg' : 'Target: ${s.suggestedWeight}kg x ${s.suggestedReps}',
                            style: TextStyle(color: s.isStagnant ? Colors.orange : AppTheme.primaryColor, fontSize: 12),
                          ) : const SizedBox.shrink(),
                          loading: () => const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                          error: (_, __) => const SizedBox.shrink(),
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
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: widget.exercise.sets.asMap().entries.map((e) {
                  final setNumber = e.key + 1;
                  final isSuggestedSetCompleted = widget.programExercise != null && setNumber <= widget.programExercise!.sets;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSuggestedSetCompleted 
                          ? Colors.green.withValues(alpha: 0.1)
                          : AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSuggestedSetCompleted 
                            ? Colors.green.withValues(alpha: 0.3)
                            : AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Set $setNumber: ${e.value.weight}kg x ${e.value.reps}',
                      style: TextStyle(
                        color: isSuggestedSetCompleted ? Colors.green : AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: isSuggestedSetCompleted ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _NumberField(controller: _repsController, label: 'Reps')),
                const SizedBox(width: 8),
                Expanded(child: _NumberField(controller: _weightController, label: 'Weight', isDecimal: true)),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLogging ? null : _handleLogSet,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                  child: _isLogging ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) : const Text('Log Set'),
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
    // Use the new YouTube-based player with exercise name
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
  const _NumberField({required this.controller, required this.label, this.isDecimal = false});
  final TextEditingController controller;
  final String label;
  final bool isDecimal;

  @override
  Widget build(BuildContext context) {
    // FIX: use theme colors instead of hardcoded AppTheme.textPrimary (white)
    return TextField(
      controller: controller,
      keyboardType: isDecimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      ),
    );
  }
}

class _EmptyExerciseHint extends StatelessWidget {
  const _EmptyExerciseHint({required this.onAddExercise});
  final VoidCallback onAddExercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fitness_center, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No exercises yet', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: onAddExercise, icon: const Icon(Icons.add), label: const Text('Add Exercise')),
        ],
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
        child: ElevatedButton(
          onPressed: enabled ? onFinish : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Finish Workout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            autofocus: true,
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(hintText: 'Search exercises...', prefixIcon: Icon(Icons.search)),
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
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: thumbUrl,
                    width: 48,
                    height: 36,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 48, height: 36,
                      color: theme.colorScheme.surface,
                      child: Icon(Icons.fitness_center, color: theme.colorScheme.primary, size: 18),
                    ),
                  ),
                ),
                title: Text(name),
                onTap: () => widget.onExerciseSelected(name),
              );
            },
          ),
        ),
      ],
    );
  }
}
