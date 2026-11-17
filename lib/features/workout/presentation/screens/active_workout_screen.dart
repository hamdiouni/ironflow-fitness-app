import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/providers/units_provider.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/core/utils/error_handler.dart';
import 'package:progression_tracker/l10n/app_localizations.dart';
import 'package:progression_tracker/shared/presentation/components/components.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/presentation/providers/rest_timer_provider.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/workout/presentation/widgets/plate_calculator_sheet.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/quick_feedback_bottom_sheet.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';
import 'package:progression_tracker/features/workout/domain/usecases/calculate_workout_volume_use_case.dart';
import 'package:progression_tracker/features/workout/domain/usecases/workout_metrics.dart';
import '../../domain/services/strength_engine.dart';
import '../widgets/active_workout/active_exercise_card.dart';
import '../widgets/active_workout/active_rest_timer_section.dart';
import '../widgets/active_workout/active_workout_chrome.dart';
import '../widgets/active_workout/active_workout_modals.dart';
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
  late WeightUnit _weightUnit;
  String? _selectedExerciseId;
  final Map<String, GlobalKey<ActiveExerciseCardState>> _cardKeys = {};

  @override
  void initState() {
    super.initState();
    _weightUnit = ref.read(unitsProvider) == UnitsSystem.imperial
        ? WeightUnit.lb
        : WeightUnit.kg;
  }

  GlobalKey<ActiveExerciseCardState> _cardKeyFor(String exerciseId) {
    return _cardKeys.putIfAbsent(
      exerciseId,
      () => GlobalKey<ActiveExerciseCardState>(),
    );
  }

  String? _activeExerciseId(Workout workout) {
    if (workout.exercises.isEmpty) return null;
    if (_selectedExerciseId != null &&
        workout.exercises.any((e) => e.id == _selectedExerciseId)) {
      return _selectedExerciseId;
    }
    return workout.exercises.first.id;
  }

  void _toggleRestTimerShortcut() {
    final timer = ref.read(restTimerProvider);
    final notifier = ref.read(restTimerProvider.notifier);
    if (timer.isRunning && !timer.isComplete) {
      notifier.skip();
    } else {
      notifier.start(90);
    }
  }

  void _logActiveSetShortcut(Workout workout) {
    final id = _activeExerciseId(workout);
    if (id == null) return;
    _cardKeys[id]?.currentState?.logCurrentSet();
  }

  void _stepWeightShortcut(Workout workout, double sign) {
    final id = _activeExerciseId(workout);
    if (id == null) return;
    final step = _weightUnit == WeightUnit.lb ? 5.0 : 2.5;
    _cardKeys[id]?.currentState?.stepWeight(sign * step);
  }

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
                'Start a new session and log your sets.',
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
    final activeExerciseId = _activeExerciseId(workout);

    AppLogger.debug('🔍 [WorkoutUI] Has exercises: $hasExercises, Has sets: $hasSets');

    // Get program exercises from active program
    final programExercises = ref.watch(currentDayExercisesProvider);

    Widget buildExerciseList() {
      if (!hasExercises) {
        return WorkoutEmptyExerciseHint(
          onAddExercise: () => _showExerciseSelection(workout),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: workout.exercises.length,
        itemBuilder: (context, index) {
          final exercise = workout.exercises[index];
          final programExercise = programExercises.firstWhereOrNull(
            (pe) =>
                pe.exerciseName.toLowerCase() == exercise.name.toLowerCase(),
          );
          final isSelected = exercise.id == activeExerciseId;
          final isLinked =
              SupersetEngine.isLinkedWithNext(workout.exercises, index);
          final supersetLabel =
              SupersetEngine.labelFor(workout.exercises, index);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Listener(
                onPointerDown: (_) {
                  if (_selectedExerciseId != exercise.id) {
                    setState(() => _selectedExerciseId = exercise.id);
                  }
                },
                child: ActiveExerciseCard(
                  key: _cardKeyFor(exercise.id),
                  exercise: exercise,
                  programExercise: programExercise,
                  weightUnit: _weightUnit,
                  isFocused: isSelected,
                  isAnimating: _animatingExerciseId == exercise.id,
                  supersetLabel: supersetLabel,
                  onAnimationComplete: () {
                    if (mounted) setState(() => _animatingExerciseId = null);
                  },
                  onLogSet: (reps, weight, [type = SetType.normal, rpe]) =>
                      _logSet(exercise, reps, weight, type, rpe),
                  onUpdateSetType: (setIndex, newType) => ref
                      .read(workoutNotifierProvider.notifier)
                      .updateSetType(exercise.id, setIndex, newType),
                ),
              ),
              if (index < workout.exercises.length - 1)
                SupersetConnectorDivider(
                  key: Key('toggle_superset_${exercise.id}'),
                  isLinked: isLinked,
                  onToggle: () {
                    ref.read(appHapticsProvider).selectionChanged();
                    ref
                        .read(workoutNotifierProvider.notifier)
                        .toggleSupersetLink(index);
                  },
                ),
            ],
          );
        },
      );
    }

    final workingSetCount = WorkoutMetrics.workingSetCount(workout);
    final volumeKg = CalculateWorkoutVolumeUseCase()(workout);
    final displayVolume = _weightUnit == WeightUnit.lb
        ? UnitsConverter.convertWeightToDisplay(volumeKg, UnitsSystem.imperial)
        : volumeKg;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyL, alt: true): () =>
            _logActiveSetShortcut(workout),
        const SingleActivator(LogicalKeyboardKey.keyR, alt: true):
            _toggleRestTimerShortcut,
        const SingleActivator(LogicalKeyboardKey.equal, alt: true): () =>
            _stepWeightShortcut(workout, 1),
        const SingleActivator(LogicalKeyboardKey.add, alt: true): () =>
            _stepWeightShortcut(workout, 1),
        const SingleActivator(LogicalKeyboardKey.minus, alt: true): () =>
            _stepWeightShortcut(workout, -1),
        const SingleActivator(LogicalKeyboardKey.numpadSubtract, alt: true): () =>
            _stepWeightShortcut(workout, -1),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: tokens.canvas,
          appBar: AppBar(
            backgroundColor: tokens.canvas,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 16,
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    'WORKOUT',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tokens.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTypography.fontFamilyHeadings,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                WorkoutElapsedBadge(startTime: startTime, tokens: tokens),
              ],
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
              IconButton(
                key: const Key('add_exercise_button'),
                icon: Icon(Icons.add, color: tokens.kineticAccent, size: 22),
                tooltip: AppLocalizations.of(context)?.addExercise ??
                    'Add exercise',
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: () {
                  AppLogger.debug('📊 [WorkoutUI] Add exercise button pressed');
                  _showExerciseSelection(workout);
                },
              ),
              PopupMenuButton<String>(
                key: const Key('active_workout_menu_button'),
                tooltip: 'Workout actions',
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: tokens.textPrimary,
                  size: 20,
                ),
                color: tokens.panel,
                onSelected: (value) {
                  if (value == 'plate_calc') {
                    PlateCalculatorSheet.show(
                      context,
                      initialUnit: _weightUnit == WeightUnit.lb
                          ? PlateUnit.lb
                          : PlateUnit.kg,
                    );
                  } else if (value == 'discard') {
                    _confirmDiscardWorkout(context);
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem<String>(
                    value: 'plate_calc',
                    child: Row(
                      children: [
                        Icon(
                          Icons.calculate_outlined,
                          color: tokens.kineticAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Plate Calculator',
                          style: TextStyle(
                            color: tokens.textPrimary,
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    key: const Key('discard_workout_button'),
                    value: 'discard',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: tokens.error,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Discard Workout',
                          style: TextStyle(
                            color: tokens.error,
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 6,
                      child: buildExerciseList(),
                    ),
                    Container(
                      width: 1,
                      color: tokens.borderSubtle,
                    ),
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SessionScoreboardPanel(
                              exerciseCount: workout.exercises.length,
                              workingSets: workingSetCount,
                              volumeLabel:
                                  '${displayVolume.toStringAsFixed(0)} ${_weightUnit.label}',
                              tokens: tokens,
                            ),
                            const SizedBox(height: 12),
                            const ActiveRestTimerSection(),
                            const SizedBox(height: 12),
                            KeyboardShortcutsHint(tokens: tokens),
                            const SizedBox(height: 12),
                            FinishWorkoutButton(
                              enabled: hasSets,
                              onFinish: () => _finishWorkout(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  const ActiveRestTimerSection(),
                  Expanded(child: buildExerciseList()),
                  FinishWorkoutButton(
                    enabled: hasSets,
                    onFinish: () => _finishWorkout(context),
                  ),
                ],
              );
            },
          ),
        ),
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
    showActiveWorkoutExerciseSelectionSheet(
      context: context,
      ref: ref,
      isMounted: () => mounted,
    );
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
      
      final currentWorkout = ref.read(workoutNotifierProvider).maybeWhen(
        inProgress: (w, _) => w,
        orElse: () => null,
      );
      final exIndex =
          currentWorkout?.exercises.indexWhere((e) => e.id == exercise.id) ?? -1;
      final shouldRest = currentWorkout == null || exIndex == -1
          ? (type != SetType.drop)
          : SupersetEngine.shouldRestAfter(
              currentWorkout.exercises,
              exIndex,
              type: type,
            );

      if (shouldRest) {
        AppLogger.debug('📊 [WorkoutUI] Starting rest timer...');
        ref.read(restTimerProvider.notifier).start(90); // 90 seconds default rest time
        AppLogger.debug('✅ [WorkoutUI] Rest timer started');
      } else {
        AppLogger.debug(
          '⏭️ [WorkoutUI] Rest skipped for drop set / superset transition',
        );
      }

      if (currentWorkout != null && exIndex != -1) {
        final nextIndex =
            SupersetEngine.nextInRotation(currentWorkout.exercises, exIndex);
        if (nextIndex != null && nextIndex != exIndex) {
          final nextEx = currentWorkout.exercises[nextIndex];
          setState(() => _selectedExerciseId = nextEx.id);
        }
      }
      
      if (isPR && mounted && context.mounted) {
        AppLogger.debug('🎉 [WorkoutUI] New PR detected for ${exercise.name}!');
        setState(() => _prCount++);
        AppLogger.debug('🔍 [WorkoutUI] Total PRs this workout: $_prCount');
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'New PR on ${exercise.name}!',
            style: TextStyle(color: context.tokens.onAccent),
          ),
          backgroundColor: context.tokens.kineticAccent,
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
      final caloriesBurned = await showCalorieBurnedInputDialog(context);
      
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
          showProgramCompleteCelebrationDialog(
            context: context,
            ref: ref,
            activeProgram: activeProgram,
          );
        }
      }
    } catch (e, s) {
      AppLogger.debug('❌ [WorkoutUI] Failed to finish workout: $e');
      AppLogger.debug('🔍 [WorkoutUI] Stack trace: $s');
      if (context.mounted) ErrorHandler.handleError(context, e, s);
    }
  }
}
