import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/hive_active_program_datasource.dart';
import '../../data/repositories/active_program_repository_impl.dart';
import '../../domain/entities/active_program.dart';
import '../../domain/entities/workout_program.dart';
import '../../domain/repositories/active_program_repository.dart';
import '../../domain/usecases/clear_active_program_use_case.dart';
import '../../domain/usecases/complete_workout_day_use_case.dart';
import '../../domain/usecases/get_current_day_use_case.dart';
import '../../domain/usecases/reorder_exercises_use_case.dart';
import '../../domain/usecases/replace_exercise_use_case.dart';
import '../../domain/usecases/set_active_program_use_case.dart';
import '../../domain/usecases/update_active_program_use_case.dart';
import '../../domain/usecases/update_exercise_parameters_use_case.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

/// Provider for the ActiveProgramRepository.
/// 
/// This provider creates and manages the repository instance that handles
/// active program persistence using Hive local storage.
/// 
/// **Validates: Requirements 7.1, 9.1**
final activeProgramRepositoryProvider = Provider<ActiveProgramRepository>((ref) {
  final dataSource = HiveActiveProgramDataSource();
  return ActiveProgramRepositoryImpl(dataSource);
});

// ---------------------------------------------------------------------------
// Use Case Providers
// ---------------------------------------------------------------------------

/// Provider for SetActiveProgramUseCase.
/// 
/// This use case creates a new ActiveProgram from a WorkoutProgram
/// and saves it to persistent storage.
/// 
/// **Validates: Requirements 7.2, 9.2**
final setActiveProgramUseCaseProvider = Provider<SetActiveProgramUseCase>((ref) {
  final repository = ref.watch(activeProgramRepositoryProvider);
  return SetActiveProgramUseCase(repository);
});

/// Provider for UpdateActiveProgramUseCase.
/// 
/// This use case updates an existing ActiveProgram in persistent storage.
/// 
/// **Validates: Requirements 7.2, 9.2**
final updateActiveProgramUseCaseProvider = Provider<UpdateActiveProgramUseCase>((ref) {
  final repository = ref.watch(activeProgramRepositoryProvider);
  return UpdateActiveProgramUseCase(repository);
});

/// Provider for GetCurrentDayUseCase.
/// 
/// This use case retrieves the current day from the active program.
/// 
/// **Validates: Requirements 7.2, 9.2**
final getCurrentDayUseCaseProvider = Provider<GetCurrentDayUseCase>((ref) {
  final repository = ref.watch(activeProgramRepositoryProvider);
  return GetCurrentDayUseCase(repository);
});

/// Provider for CompleteWorkoutDayUseCase.
/// 
/// This use case marks the current day as complete and advances to the next day.
/// 
/// **Validates: Requirements 7.2, 9.2**
final completeWorkoutDayUseCaseProvider = Provider<CompleteWorkoutDayUseCase>((ref) {
  final repository = ref.watch(activeProgramRepositoryProvider);
  return CompleteWorkoutDayUseCase(repository);
});

/// Provider for ClearActiveProgramUseCase.
/// 
/// This use case removes the active program from persistent storage.
/// 
/// **Validates: Requirements 7.2, 9.2**
final clearActiveProgramUseCaseProvider = Provider<ClearActiveProgramUseCase>((ref) {
  final repository = ref.watch(activeProgramRepositoryProvider);
  return ClearActiveProgramUseCase(repository);
});

/// Provider for ReplaceExerciseUseCase.
/// 
/// This use case replaces an exercise in the active program while preserving parameters.
/// 
/// **Validates: Requirements 7.2, 9.2**
final replaceExerciseUseCaseProvider = Provider<ReplaceExerciseUseCase>((ref) {
  final repository = ref.watch(activeProgramRepositoryProvider);
  return ReplaceExerciseUseCase(repository);
});

/// Provider for ReorderExercisesUseCase.
/// 
/// This use case reorders exercises within a program day.
/// 
/// **Validates: Requirements 7.2, 9.2**
final reorderExercisesUseCaseProvider = Provider<ReorderExercisesUseCase>((ref) {
  final repository = ref.watch(activeProgramRepositoryProvider);
  return ReorderExercisesUseCase(repository);
});

/// Provider for UpdateExerciseParametersUseCase.
/// 
/// This use case updates exercise parameters (sets, reps, rest).
/// 
/// **Validates: Requirements 7.2, 9.2**
final updateExerciseParametersUseCaseProvider = Provider<UpdateExerciseParametersUseCase>((ref) {
  final repository = ref.watch(activeProgramRepositoryProvider);
  return UpdateExerciseParametersUseCase(repository);
});

// ---------------------------------------------------------------------------
// Active Program State Notifier
// ---------------------------------------------------------------------------

/// StateNotifier for managing the active workout program state.
/// 
/// This notifier provides centralized state management for the active program,
/// handling loading, updating, and clearing operations. It uses AsyncValue
/// to represent loading, data, and error states.
/// 
/// **Validates: Requirements 7.1, 7.3, 7.4, 7.5, 7.7, 7.8**
class ActiveProgramNotifier extends StateNotifier<AsyncValue<ActiveProgram?>> {
  final ActiveProgramRepository _repository;
  final UpdateActiveProgramUseCase _updateUseCase;
  
  ActiveProgramNotifier(this._repository, this._updateUseCase) 
      : super(const AsyncValue.loading()) {
    _loadActiveProgram();
  }
  
  /// Loads the active program from persistent storage.
  /// 
  /// Sets state to loading, then either data or error based on the result.
  Future<void> _loadActiveProgram() async {
    state = const AsyncValue.loading();
    try {
      final program = await _repository.loadActiveProgram();
      state = AsyncValue.data(program);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  /// Sets a new workout program as the active program.
  /// 
  /// Creates a new ActiveProgram with initial state (day 0, no completions)
  /// and persists it to storage.
  /// 
  /// **Validates: Requirements 7.3, 7.4**
  Future<void> setActiveProgram(WorkoutProgram program) async {
    final activeProgram = ActiveProgram(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      program: program,
      currentDayIndex: 0,
      isActive: true,
      lastWorkoutDate: null,
      completedDays: {},
    );
    
    await _repository.saveActiveProgram(activeProgram);
    state = AsyncValue.data(activeProgram);
  }
  
  /// Updates the active program with new data.
  /// 
  /// Persists the updated program to storage and updates the state.
  /// 
  /// **Validates: Requirements 7.4**
  Future<void> updateProgram(ActiveProgram program) async {
    await _updateUseCase(program);
    state = AsyncValue.data(program);
  }
  
  /// Clears the active program from storage and state.
  /// 
  /// **Validates: Requirements 7.4**
  Future<void> clearProgram() async {
    await _repository.clearActiveProgram();
    state = const AsyncValue.data(null);
  }
  
  /// Gets the current program day.
  /// 
  /// Returns null if no active program exists or state is loading/error.
  /// 
  /// **Validates: Requirements 7.5**
  ProgramDay? getCurrentDay() {
    return state.value?.currentDay;
  }
  
  /// Completes the current workout day and advances to the next day.
  /// 
  /// Marks the current day as complete, updates the last workout date,
  /// and advances to the next workout day (skipping rest days).
  /// 
  /// **Validates: Requirements 7.7, 8.6**
  Future<void> completeCurrentDay() async {
    final current = state.value;
    if (current == null) return;
    
    final updated = current.completeCurrentDay();
    await updateProgram(updated);
  }
  
  /// Sets the current day index manually.
  /// 
  /// Allows users to navigate to a specific day in the program.
  /// 
  /// **Validates: Requirements 7.8, 9.4**
  Future<void> setCurrentDayIndex(int index) async {
    final current = state.value;
    if (current == null) return;
    
    final updated = current.copyWith(currentDayIndex: index);
    await updateProgram(updated);
  }
  
  /// Refreshes the active program by reloading from storage.
  /// 
  /// Useful after external modifications to the program.
  /// 
  /// **Validates: Requirements 7.8**
  void refresh() {
    _loadActiveProgram();
  }
  
  /// Restarts the current program by resetting to day 0 and clearing completed days.
  /// 
  /// Keeps the same program but resets progress.
  /// 
  /// **Validates: Requirements 13.7**
  Future<void> restartProgram() async {
    final current = state.value;
    if (current == null) return;
    
    final restarted = current.restart();
    await updateProgram(restarted);
  }
}

// ---------------------------------------------------------------------------
// Active Program State Provider
// ---------------------------------------------------------------------------

/// StateNotifierProvider for the active workout program.
/// 
/// This provider manages the active program state using ActiveProgramNotifier,
/// wiring it with the repository and update use case dependencies.
/// 
/// The state is represented as `AsyncValue<ActiveProgram?>` to handle loading,
/// data, and error states consistently across the UI.
/// 
/// **Validates: Requirements 7.1, 7.4**
final activeProgramProvider = StateNotifierProvider<ActiveProgramNotifier, AsyncValue<ActiveProgram?>>(
  (ref) {
    final repository = ref.watch(activeProgramRepositoryProvider);
    final updateUseCase = ref.watch(updateActiveProgramUseCaseProvider);
    return ActiveProgramNotifier(repository, updateUseCase);
  },
);

// Helper Providers

/// Provider that returns the exercises for the current day from the active program.
/// 
/// This provider watches the activeProgramProvider and extracts the current day's
/// exercises. Returns an empty list if no active program exists, if the state is
/// loading, or if an error occurred.
/// 
/// **Validates: Requirements 7.5, 7.6, 9.3**
final currentDayExercisesProvider = Provider<List<ProgramExercise>>((ref) {
  final activeProgramAsync = ref.watch(activeProgramProvider);
  
  return activeProgramAsync.when(
    data: (program) => program?.currentDay.exercises ?? [],
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Provider that returns true if an active program exists and is active.
/// 
/// This provider watches the activeProgramProvider and checks if a program
/// exists and is marked as active. Returns false if no program exists, if the
/// state is loading, or if an error occurred.
/// 
/// **Validates: Requirements 7.5, 7.6, 9.3**
final hasActiveProgramProvider = Provider<bool>((ref) {
  final activeProgramAsync = ref.watch(activeProgramProvider);
  
  return activeProgramAsync.when(
    data: (program) => program != null && program.isActive,
    loading: () => false,
    error: (_, __) => false,
  );
});
