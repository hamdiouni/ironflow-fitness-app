import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/datasources/hive_workout_data_source.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/usecases/usecases.dart';
import '../../domain/usecases/get_progression_suggestion_use_case.dart';
import '../managers/workout_state_manager.dart';
import 'active_program_providers.dart';
import '../../../ai/presentation/providers/global_ai_provider.dart';
import '../../../../core/providers/analytics_provider.dart';

part 'workout_providers.freezed.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final dataSource = HiveWorkoutDataSource();
  return WorkoutRepositoryImpl(dataSource);
});

// ---------------------------------------------------------------------------
// Use-case providers
// ---------------------------------------------------------------------------

final startWorkoutUseCaseProvider = Provider<StartWorkoutUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  final activeProgramRepository = ref.watch(activeProgramRepositoryProvider);
  return StartWorkoutUseCase(repository, activeProgramRepository);
});

final calculateVolumeUseCaseProvider =
    Provider<CalculateWorkoutVolumeUseCase>((ref) {
  return CalculateWorkoutVolumeUseCase();
});

final saveWorkoutUseCaseProvider = Provider<SaveWorkoutUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  final calculateVolume = ref.watch(calculateVolumeUseCaseProvider);
  return SaveWorkoutUseCase(repository, calculateVolume);
});

final progressionSuggestionUseCaseProvider =
    Provider<GetProgressionSuggestionUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return GetProgressionSuggestionUseCase(repository);
});

// ---------------------------------------------------------------------------
// Progression Suggestion Provider
// ---------------------------------------------------------------------------

final detectPRUseCaseProvider = Provider<DetectPersonalRecordUseCase>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return DetectPersonalRecordUseCase(repository);
});

final generateWorkoutProgramUseCaseProvider = Provider<GenerateWorkoutProgramUseCase>((ref) {
  return GenerateWorkoutProgramUseCase();
});

/// Provides progression suggestions for a specific exercise.
final progressionSuggestionProvider =
    FutureProvider.family<ProgressionSuggestion?, String>((ref, exerciseName) async {
  final useCase = ref.watch(progressionSuggestionUseCaseProvider);
  return useCase(exerciseName);
});

// ---------------------------------------------------------------------------
// WorkoutState – sealed Freezed union
// ---------------------------------------------------------------------------

@freezed
class WorkoutState with _$WorkoutState {
  const factory WorkoutState.initial() = _Initial;
  const factory WorkoutState.inProgress(
    Workout workout,
    DateTime startTime,
  ) = _InProgress;
  const factory WorkoutState.completed(Workout workout) = _Completed;
}

// ---------------------------------------------------------------------------
// WorkoutStateManager provider
// ---------------------------------------------------------------------------

final workoutStateManagerProvider = Provider<WorkoutStateManager>((ref) {
  return WorkoutStateManager();
});

// ---------------------------------------------------------------------------
// WorkoutNotifier
// ---------------------------------------------------------------------------

class WorkoutNotifier extends StateNotifier<WorkoutState> {
  final StartWorkoutUseCase _startWorkout;
  final AddExerciseToWorkoutUseCase _addExercise;
  final LogSetUseCase _logSet;
  final SaveWorkoutUseCase _saveWorkout;
  final DetectPersonalRecordUseCase _detectPR;
  final WorkoutStateManager _stateManager;
  final Ref _ref;

  WorkoutNotifier({
    required StartWorkoutUseCase startWorkout,
    required AddExerciseToWorkoutUseCase addExercise,
    required LogSetUseCase logSet,
    required SaveWorkoutUseCase saveWorkout,
    required DetectPersonalRecordUseCase detectPR,
    required WorkoutStateManager stateManager,
    required Ref ref,
  })  : _startWorkout = startWorkout,
        _addExercise = addExercise,
        _logSet = logSet,
        _saveWorkout = saveWorkout,
        _detectPR = detectPR,
        _stateManager = stateManager,
        _ref = ref,
        super(const WorkoutState.initial());

  /// Starts a new workout session and transitions to [WorkoutState.inProgress].
  Future<void> start() async {
    try {
      print('📊 [Workout] Starting new workout session...');
      
      final workout = await _startWorkout();
      final startTime = DateTime.now();
      
      print('✅ [Workout] Workout created successfully');
      print('🔍 [Workout] Workout ID: ${workout.id}, Start time: $startTime');
      
      state = WorkoutState.inProgress(workout, startTime);
      print('✅ [Workout] State updated to inProgress');
      
      await _stateManager.saveState(workout, startTime);
      print('✅ [Workout] Workout state saved to Hive');
      
      // Track workout started
      try {
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.logWorkoutStarted(
          workoutId: workout.id,
        );
        print('📊 [Analytics] Workout started event logged');
      } catch (e) {
        print('⚠️ [Analytics] Failed to log workout started: $e');
      }
    } catch (e, stackTrace) {
      print('❌ [Workout] Failed to start workout: $e');
      print('🔍 [Workout] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Restores a previously saved workout state on app launch.
  ///
  /// Returns `true` if a state was restored, `false` otherwise.
  Future<bool> restoreState() async {
    try {
      print('📊 [Workout] Restoring workout state...');
      
      await _stateManager.init();
      print('✅ [Workout] State manager initialized');
      
      final saved = await _stateManager.restoreState();
      if (saved != null) {
        print('✅ [Workout] Workout state restored from Hive');
        print('🔍 [Workout] Workout ID: ${saved.workout.id}, Start time: ${saved.startTime}');
        print('🔍 [Workout] Exercises: ${saved.workout.exercises.length}');
        
        state = WorkoutState.inProgress(saved.workout, saved.startTime);
        print('✅ [Workout] State updated to inProgress');
        return true;
      } else {
        print('📊 [Workout] No saved workout state found');
        return false;
      }
    } catch (e, stackTrace) {
      print('❌ [Workout] Failed to restore workout state: $e');
      print('🔍 [Workout] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Adds [exercise] to the current in-progress workout.
  ///
  /// FIX: Same async-in-maybeWhen bug — extracted to direct state check.
  Future<void> addExercise(Exercise exercise) async {
    try {
      print('📊 [Workout] Adding exercise to workout...');
      print('🔍 [Workout] Exercise name: ${exercise.name}, Type: ${exercise.type}');
      
      final current = state;
      if (current is! _InProgress) {
        print('⚠️ [Workout] Cannot add exercise: workout not in progress');
        return;
      }

      final updated = await _addExercise(current.workout, exercise);
      print('✅ [Workout] Exercise added successfully');
      print('🔍 [Workout] Exercise ID: ${exercise.id}');
      print('🔍 [Workout] Total exercises: ${updated.exercises.length}');
      
      state = WorkoutState.inProgress(updated, current.startTime);
      print('✅ [Workout] State updated with new exercise');
      
      await _stateManager.saveState(updated, current.startTime);
      print('✅ [Workout] Workout state saved to Hive');
      
      // Track exercise added
      try {
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.logExerciseAdded(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
        );
        print('📊 [Analytics] Exercise added event logged');
      } catch (e) {
        print('⚠️ [Analytics] Failed to log exercise added: $e');
      }
    } catch (e, stackTrace) {
      print('❌ [Workout] Failed to add exercise: $e');
      print('🔍 [Workout] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Logs [set] for the exercise identified by [exerciseId].
  ///
  /// Returns `true` if the set constitutes a personal record (PR).
  /// Persists state after each set to prevent data loss (Requirement 17.6).
  ///
  /// FIX: The previous implementation used `await state.maybeWhen(async callback)`
  /// which does NOT await the inner async work — maybeWhen returns void.
  /// Fixed by extracting the async logic outside of maybeWhen.
  Future<bool> logSetForExercise(String exerciseId, SetEntry set) async {
    try {
      print('📊 [Workout] Logging set for exercise...');
      print('🔍 [Workout] Exercise ID: $exerciseId');
      print('🔍 [Workout] Reps: ${set.reps}, Weight: ${set.weight}kg');
      
      // Extract current state synchronously — no async inside maybeWhen
      final current = state;
      if (current is! _InProgress) {
        print('⚠️ [Workout] Cannot log set: workout not in progress');
        return false;
      }

      final workout = current.workout;
      final startTime = current.startTime;

      final exerciseIndex =
          workout.exercises.indexWhere((e) => e.id == exerciseId);
      if (exerciseIndex == -1) {
        print('⚠️ [Workout] Exercise not found in workout');
        return false;
      }

      final exercise = workout.exercises[exerciseIndex];
      print('🔍 [Workout] Exercise name: ${exercise.name}');

      // Append set immutably
      final updatedExercise = await _logSet(exercise, set);
      print('✅ [Workout] Set logged successfully');
      print('🔍 [Workout] Total sets for exercise: ${updatedExercise.sets.length}');

      // Check for PR against historical data
      final isPR = await _detectPR(exercise.name, set);
      if (isPR) {
        print('✅ [Workout] New PR detected!');
        print('🔍 [Workout] PR: ${set.reps} reps @ ${set.weight}kg');
      } else {
        print('📊 [Workout] No PR detected');
      }

      // Build new exercises list immutably
      final updatedExercises = [
        for (int i = 0; i < workout.exercises.length; i++)
          i == exerciseIndex ? updatedExercise : workout.exercises[i],
      ];

      final updatedWorkout = workout.copyWith(exercises: updatedExercises);

      // Update state — triggers UI rebuild
      state = WorkoutState.inProgress(updatedWorkout, startTime);
      print('✅ [Workout] State updated with new set');

      // Persist state after each set to prevent data loss
      await _stateManager.saveState(updatedWorkout, startTime);
      print('✅ [Workout] Workout state saved to Hive');
      
      // Track set completed
      try {
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.logSetCompleted(
          exerciseId: exerciseId,
          setNumber: updatedExercise.sets.length,
          weight: set.weight,
          reps: set.reps,
        );
        print('📊 [Analytics] Set completed event logged');
      } catch (e) {
        print('⚠️ [Analytics] Failed to log set completed: $e');
      }

      return isPR;
    } catch (e, stackTrace) {
      print('❌ [Workout] Failed to log set: $e');
      print('🔍 [Workout] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Finalises the workout, persists it, clears the active state, and
  /// transitions to [WorkoutState.completed].
  ///
  /// FIX: Same async-in-maybeWhen bug — extracted to direct state check.
  Future<void> finish() async {
    try {
      print('📊 [Workout] Finishing workout...');
      
      final current = state;
      if (current is! _InProgress) {
        print('⚠️ [Workout] Cannot finish: workout not in progress');
        return;
      }

      final duration = DateTime.now().difference(current.startTime);
      print('🔍 [Workout] Workout duration: ${duration.inMinutes} minutes');
      print('🔍 [Workout] Total exercises: ${current.workout.exercises.length}');
      
      print('📊 [Workout] Saving workout to repository...');
      await _saveWorkout(current.workout, duration);
      print('✅ [Workout] Workout saved successfully');
      
      // Track workout completed
      try {
        final analytics = _ref.read(analyticsServiceProvider);
        final totalSets = current.workout.exercises.fold<int>(
          0,
          (sum, exercise) => sum + exercise.sets.length,
        );
        await analytics.logWorkoutCompleted(
          workoutId: current.workout.id,
          durationMinutes: duration.inMinutes,
          exerciseCount: current.workout.exercises.length,
          setCount: totalSets,
        );
        print('📊 [Analytics] Workout completed event logged');
      } catch (e) {
        print('⚠️ [Analytics] Failed to log workout completed: $e');
      }
      
      // Notify Global AI Provider about workout completion for insights and quick feedback
      print('📊 [Workout] Notifying Global AI Provider about workout completion...');
      try {
        await _ref.read(globalAIProvider.notifier).onWorkoutCompleted(current.workout);
        print('✅ [Workout] Global AI Provider notified successfully');
      } catch (e) {
        print('⚠️ [Workout] Failed to notify Global AI Provider: $e');
        // Don't rethrow - AI notification failure shouldn't block workout completion
      }
      
      print('📊 [Workout] Clearing active workout state...');
      await _stateManager.clearState();
      print('✅ [Workout] Active state cleared from Hive');
      
      state = WorkoutState.completed(current.workout);
      print('✅ [Workout] State updated to completed');

      // Increment refresh counter so workoutHistoryProvider re-fetches
      _ref.read(workoutRefreshCounterProvider.notifier).state++;
      print('✅ [Workout] Workout history refresh triggered');
    } catch (e, stackTrace) {
      print('❌ [Workout] Failed to finish workout: $e');
      print('🔍 [Workout] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Resets the notifier back to [WorkoutState.initial] and clears any
  /// persisted active workout state.
  Future<void> reset() async {
    try {
      print('📊 [Workout] Resetting workout state...');
      
      await _stateManager.clearState();
      print('✅ [Workout] Active state cleared from Hive');
      
      state = const WorkoutState.initial();
      print('✅ [Workout] State reset to initial');
    } catch (e, stackTrace) {
      print('❌ [Workout] Failed to reset workout state: $e');
      print('🔍 [Workout] Stack trace: $stackTrace');
      rethrow;
    }
  }
}

// ---------------------------------------------------------------------------
// workoutNotifierProvider
// ---------------------------------------------------------------------------

final workoutNotifierProvider =
    StateNotifierProvider<WorkoutNotifier, WorkoutState>((ref) {
  return WorkoutNotifier(
    startWorkout: ref.watch(startWorkoutUseCaseProvider),
    addExercise: AddExerciseToWorkoutUseCase(),
    logSet: LogSetUseCase(),
    saveWorkout: ref.watch(saveWorkoutUseCaseProvider),
    detectPR: ref.watch(detectPRUseCaseProvider),
    stateManager: ref.watch(workoutStateManagerProvider),
    ref: ref,
  );
});

// ---------------------------------------------------------------------------
// workoutHistoryProvider
// ---------------------------------------------------------------------------

/// Refresh counter — increment after saving a workout to force history reload.
final workoutRefreshCounterProvider = StateProvider<int>((ref) => 0);

final workoutHistoryProvider = FutureProvider<List<Workout>>((ref) async {
  // Re-runs whenever workoutRefreshCounterProvider is incremented.
  ref.watch(workoutRefreshCounterProvider);
  final repository = ref.watch(workoutRepositoryProvider);
  final useCase = GetWorkoutHistoryUseCase(repository);
  return useCase();
});


