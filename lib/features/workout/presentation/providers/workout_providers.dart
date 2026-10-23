import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/hive_workout_data_source.dart';
import '../../data/repositories/synced_workout_repository.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/workout_repository.dart';
import '../../domain/usecases/usecases.dart';
import '../managers/workout_state_manager.dart';
import 'active_program_providers.dart';
import '../../../ai/presentation/providers/global_ai_provider.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../retention/presentation/providers/streak_provider.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
import '../../../../core/providers/analytics_provider.dart';

part 'workout_providers.freezed.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final dataSource = HiveWorkoutDataSource();
  // Wire workout writes into the sync outbox when a user is signed in.
  // SyncedWorkoutRepository was previously never instantiated, so workouts
  // never enqueued a single sync action (DATABASE_AND_SYNC_AUDIT F-03).
  // Watching the auth user id rebuilds this provider on login/logout.
  // Local Hive remains the source of truth either way.
  final userId = ref.watch(authNotifierProvider.select((s) => s.user?.id));
  if (userId == null || userId.isEmpty) {
    return WorkoutRepositoryImpl(dataSource);
  }
  return SyncedWorkoutRepository(
    hiveDataSource: dataSource,
    syncService: ref.watch(syncServiceProvider),
    userId: userId,
  );
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
  /// If [initialExercises] are passed, uses them directly. Otherwise, loads from the active program,
  /// falling back gracefully to an empty workout if no active program exists.
  Future<void> start({List<Exercise>? initialExercises}) async {
    try {
      AppLogger.debug('📊 [Workout] Starting workout session...');
      Workout workout;
      if (initialExercises != null) {
        workout = Workout(
          id: const Uuid().v4(),
          date: DateTime.now(),
          exercises: initialExercises,
          duration: Duration.zero,
          totalVolume: 0,
        );
      } else {
        try {
          workout = await _startWorkout();
        } catch (e) {
          AppLogger.debug('⚠️ [Workout] Could not load active program workout ($e); launching empty workout');
          workout = Workout(
            id: const Uuid().v4(),
            date: DateTime.now(),
            exercises: const [],
            duration: Duration.zero,
            totalVolume: 0,
          );
        }
      }
      final startTime = DateTime.now();
      
      AppLogger.debug('✅ [Workout] Workout created successfully');
      AppLogger.debug('🔍 [Workout] Workout ID: ${workout.id}, Start time: $startTime');
      
      state = WorkoutState.inProgress(workout, startTime);
      AppLogger.debug('✅ [Workout] State updated to inProgress');
      
      await _stateManager.saveState(workout, startTime);
      AppLogger.debug('✅ [Workout] Workout state saved to Hive');
      
      // Track workout started
      try {
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.logWorkoutStarted(
          workoutId: workout.id,
        );
        AppLogger.debug('📊 [Analytics] Workout started event logged');
      } catch (e) {
        AppLogger.debug('⚠️ [Analytics] Failed to log workout started: $e');
      }
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Workout] Failed to start workout: $e');
      AppLogger.debug('🔍 [Workout] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Starts a repeated workout based on a previous workout template.
  Future<void> repeatWorkout(Workout previous) async {
    final freshExercises = previous.exercises.map((e) => Exercise(
      id: const Uuid().v4(),
      name: e.name,
      type: e.type,
      sets: const [],
    )).toList();
    await start(initialExercises: freshExercises);
  }

  /// Restores a previously saved workout state on app launch.
  ///
  /// Returns `true` if a state was restored, `false` otherwise.
  Future<bool> restoreState() async {
    try {
      AppLogger.debug('📊 [Workout] Restoring workout state...');
      
      await _stateManager.init();
      AppLogger.debug('✅ [Workout] State manager initialized');
      
      final saved = await _stateManager.restoreState();
      if (saved != null) {
        AppLogger.debug('✅ [Workout] Workout state restored from Hive');
        AppLogger.debug('🔍 [Workout] Workout ID: ${saved.workout.id}, Start time: ${saved.startTime}');
        AppLogger.debug('🔍 [Workout] Exercises: ${saved.workout.exercises.length}');
        
        state = WorkoutState.inProgress(saved.workout, saved.startTime);
        AppLogger.debug('✅ [Workout] State updated to inProgress');
        return true;
      } else {
        AppLogger.debug('📊 [Workout] No saved workout state found');
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Workout] Failed to restore workout state: $e');
      AppLogger.debug('🔍 [Workout] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Adds [exercise] to the current in-progress workout.
  ///
  /// FIX: Same async-in-maybeWhen bug — extracted to direct state check.
  Future<void> addExercise(Exercise exercise) async {
    try {
      AppLogger.debug('📊 [Workout] Adding exercise to workout...');
      AppLogger.debug('🔍 [Workout] Exercise name: ${exercise.name}, Type: ${exercise.type}');
      
      final current = state;
      if (current is! _InProgress) {
        AppLogger.debug('⚠️ [Workout] Cannot add exercise: workout not in progress');
        return;
      }

      final updated = await _addExercise(current.workout, exercise);
      AppLogger.debug('✅ [Workout] Exercise added successfully');
      AppLogger.debug('🔍 [Workout] Exercise ID: ${exercise.id}');
      AppLogger.debug('🔍 [Workout] Total exercises: ${updated.exercises.length}');
      
      state = WorkoutState.inProgress(updated, current.startTime);
      AppLogger.debug('✅ [Workout] State updated with new exercise');
      
      await _stateManager.saveState(updated, current.startTime);
      AppLogger.debug('✅ [Workout] Workout state saved to Hive');
      
      // Track exercise added
      try {
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.logExerciseAdded(
          exerciseId: exercise.id,
          exerciseName: exercise.name,
        );
        AppLogger.debug('📊 [Analytics] Exercise added event logged');
      } catch (e) {
        AppLogger.debug('⚠️ [Analytics] Failed to log exercise added: $e');
      }
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Workout] Failed to add exercise: $e');
      AppLogger.debug('🔍 [Workout] Stack trace: $stackTrace');
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
      AppLogger.debug('📊 [Workout] Logging set for exercise...');
      AppLogger.debug('🔍 [Workout] Exercise ID: $exerciseId');
      AppLogger.debug('🔍 [Workout] Reps: ${set.reps}, Weight: ${set.weight}kg');
      
      // Extract current state synchronously — no async inside maybeWhen
      final current = state;
      if (current is! _InProgress) {
        AppLogger.debug('⚠️ [Workout] Cannot log set: workout not in progress');
        return false;
      }

      final workout = current.workout;
      final startTime = current.startTime;

      final exerciseIndex =
          workout.exercises.indexWhere((e) => e.id == exerciseId);
      if (exerciseIndex == -1) {
        AppLogger.debug('⚠️ [Workout] Exercise not found in workout');
        return false;
      }

      final exercise = workout.exercises[exerciseIndex];
      AppLogger.debug('🔍 [Workout] Exercise name: ${exercise.name}');

      // Append set immutably
      final updatedExercise = await _logSet(exercise, set);
      AppLogger.debug('✅ [Workout] Set logged successfully');
      AppLogger.debug('🔍 [Workout] Total sets for exercise: ${updatedExercise.sets.length}');

      // Check for PR against historical data
      final isPR = await _detectPR(exercise.name, set);
      if (isPR) {
        AppLogger.debug('✅ [Workout] New PR detected!');
        AppLogger.debug('🔍 [Workout] PR: ${set.reps} reps @ ${set.weight}kg');
      } else {
        AppLogger.debug('📊 [Workout] No PR detected');
      }

      // Build new exercises list immutably
      final updatedExercises = [
        for (int i = 0; i < workout.exercises.length; i++)
          i == exerciseIndex ? updatedExercise : workout.exercises[i],
      ];

      final updatedWorkout = workout.copyWith(exercises: updatedExercises);

      // Update state — triggers UI rebuild
      state = WorkoutState.inProgress(updatedWorkout, startTime);
      AppLogger.debug('✅ [Workout] State updated with new set');

      // Persist state after each set to prevent data loss
      await _stateManager.saveState(updatedWorkout, startTime);
      AppLogger.debug('✅ [Workout] Workout state saved to Hive');
      
      // Track set completed
      try {
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.logSetCompleted(
          exerciseId: exerciseId,
          setNumber: updatedExercise.sets.length,
          weight: set.weight,
          reps: set.reps,
        );
        AppLogger.debug('📊 [Analytics] Set completed event logged');
      } catch (e) {
        AppLogger.debug('⚠️ [Analytics] Failed to log set completed: $e');
      }

      return isPR;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Workout] Failed to log set: $e');
      AppLogger.debug('🔍 [Workout] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Updates the [SetType] of an already logged set (for quick-cycling in UI).
  Future<void> updateSetType(String exerciseId, int setIndex, SetType newType) async {
    try {
      final current = state;
      if (current is! _InProgress) return;

      final workout = current.workout;
      final startTime = current.startTime;

      final exerciseIndex =
          workout.exercises.indexWhere((e) => e.id == exerciseId);
      if (exerciseIndex == -1) return;

      final exercise = workout.exercises[exerciseIndex];
      if (setIndex < 0 || setIndex >= exercise.sets.length) return;

      final oldSet = exercise.sets[setIndex];
      final updatedSet = oldSet.copyWith(type: newType);
      final updatedSets = List<SetEntry>.from(exercise.sets);
      updatedSets[setIndex] = updatedSet;

      final updatedExercise = exercise.copyWith(sets: updatedSets);
      final updatedExercises = [
        for (int i = 0; i < workout.exercises.length; i++)
          i == exerciseIndex ? updatedExercise : workout.exercises[i],
      ];

      final updatedWorkout = workout.copyWith(exercises: updatedExercises);
      state = WorkoutState.inProgress(updatedWorkout, startTime);
      await _stateManager.saveState(updatedWorkout, startTime);
    } catch (e) {
      AppLogger.debug('❌ [Workout] Failed to update set type: $e');
    }
  }

  /// Finalises the workout, persists it, clears the active state, and
  /// transitions to [WorkoutState.completed].
  ///
  /// FIX: Same async-in-maybeWhen bug — extracted to direct state check.
  Future<void> finish() async {
    try {
      AppLogger.debug('📊 [Workout] Finishing workout...');
      
      final current = state;
      if (current is! _InProgress) {
        AppLogger.debug('⚠️ [Workout] Cannot finish: workout not in progress');
        return;
      }

      final duration = DateTime.now().difference(current.startTime);
      AppLogger.debug('🔍 [Workout] Workout duration: ${duration.inMinutes} minutes');
      AppLogger.debug('🔍 [Workout] Total exercises: ${current.workout.exercises.length}');
      
      AppLogger.debug('📊 [Workout] Saving workout to repository...');
      await _saveWorkout(current.workout, duration);
      AppLogger.debug('✅ [Workout] Workout saved successfully');

      // Update the streak from the freshly persisted workout. This link was
      // previously missing entirely (StreakNotifier.updateAfterWorkout had
      // zero callers), so the stored streak never moved
      // (DATABASE_AND_SYNC_AUDIT F-06). Best-effort: must not fail finish().
      try {
        await _ref.read(streakNotifierProvider.notifier).updateAfterWorkout();
        _ref.invalidate(streakProvider);
        AppLogger.debug('✅ [Workout] Streak updated');
      } catch (e) {
        AppLogger.debug('⚠️ [Workout] Failed to update streak: $e');
      }

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
        AppLogger.debug('📊 [Analytics] Workout completed event logged');
      } catch (e) {
        AppLogger.debug('⚠️ [Analytics] Failed to log workout completed: $e');
      }
      
      // Notify Global AI Provider about workout completion for insights and quick feedback
      AppLogger.debug('📊 [Workout] Notifying Global AI Provider about workout completion...');
      try {
        await _ref.read(globalAIProvider.notifier).onWorkoutCompleted(current.workout);
        AppLogger.debug('✅ [Workout] Global AI Provider notified successfully');
      } catch (e) {
        AppLogger.debug('⚠️ [Workout] Failed to notify Global AI Provider: $e');
        // Don't rethrow - AI notification failure shouldn't block workout completion
      }
      
      AppLogger.debug('📊 [Workout] Clearing active workout state...');
      await _stateManager.clearState();
      AppLogger.debug('✅ [Workout] Active state cleared from Hive');
      
      state = WorkoutState.completed(current.workout);
      AppLogger.debug('✅ [Workout] State updated to completed');

      // Increment refresh counter so workoutHistoryProvider re-fetches
      _ref.read(workoutRefreshCounterProvider.notifier).state++;
      AppLogger.debug('✅ [Workout] Workout history refresh triggered');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Workout] Failed to finish workout: $e');
      AppLogger.debug('🔍 [Workout] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Updates the calories burned for the in-progress workout.
  void updateCalories(double caloriesBurned) {
    state.maybeWhen(
      inProgress: (workout, startTime) {
        final updatedWorkout = workout.copyWith(caloriesBurned: caloriesBurned);
        state = WorkoutState.inProgress(updatedWorkout, startTime);
        _stateManager.saveState(updatedWorkout, startTime);
        AppLogger.debug('✅ [Workout] Workout updated with calories: $caloriesBurned');
      },
      orElse: () {
        AppLogger.debug('⚠️ [Workout] Cannot update calories: workout not in progress');
      },
    );
  }

  /// Resets the notifier back to [WorkoutState.initial] and clears any
  /// persisted active workout state.
  Future<void> reset() async {
    try {
      AppLogger.debug('📊 [Workout] Resetting workout state...');
      
      await _stateManager.clearState();
      AppLogger.debug('✅ [Workout] Active state cleared from Hive');
      
      state = const WorkoutState.initial();
      AppLogger.debug('✅ [Workout] State reset to initial');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Workout] Failed to reset workout state: $e');
      AppLogger.debug('🔍 [Workout] Stack trace: $stackTrace');
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


