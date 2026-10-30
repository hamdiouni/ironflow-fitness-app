import '../entities/entities.dart';
import '../repositories/active_program_repository.dart';
import 'complete_workout_day_use_case.dart';
import 'save_workout_use_case.dart';
import 'workout_metrics.dart';

/// Finishes a workout as one orchestrated unit (Phase 3, F-06 residual):
///
/// 1. Persists the workout via [SaveWorkoutUseCase].
/// 2. Advances the active program **only if** this workout is the active
///    program's current day — i.e. it was started from the program
///    ([Workout.programId] / [Workout.programDayIndex] stamped by
///    `StartWorkoutUseCase`) and the program hasn't moved on since.
///
/// Before Phase 3 the presentation layer performed these as two separate
/// calls (`finish()` then `completeCurrentDay()` on the screen), and the
/// program advanced for *any* finished workout — including custom,
/// repeated, or legacy sessions that had nothing to do with the current
/// program day. The screen now only calls `WorkoutNotifier.finish()`;
/// streak/AI/analytics side effects stay in the notifier (they need
/// `Ref`), and UI refresh is handled by the reactive box-watch streams.
class CompleteWorkoutUseCase {
  final SaveWorkoutUseCase _saveWorkout;
  final ActiveProgramRepository _activeProgramRepository;
  final CompleteWorkoutDayUseCase _completeWorkoutDay;

  CompleteWorkoutUseCase({
    required SaveWorkoutUseCase saveWorkout,
    required ActiveProgramRepository activeProgramRepository,
    CompleteWorkoutDayUseCase? completeWorkoutDay,
  })  : _saveWorkout = saveWorkout,
        _activeProgramRepository = activeProgramRepository,
        _completeWorkoutDay =
            completeWorkoutDay ?? CompleteWorkoutDayUseCase(activeProgramRepository);

  Future<void> call(Workout workout, Duration duration) async {
    if (!WorkoutMetrics.hasWorkingSets(workout)) {
      return;
    }
    await _saveWorkout(workout, duration);
    await _advanceActiveProgramIfCurrent(workout);
  }

  Future<void> _advanceActiveProgramIfCurrent(Workout workout) async {
    final programId = workout.programId;
    final dayIndex = workout.programDayIndex;
    // Custom / legacy / repeated workouts aren't tied to a program day.
    if (programId == null || dayIndex == null) return;

    final active = await _activeProgramRepository.loadActiveProgram();
    if (active == null) return;

    // Only advance when the finished workout *is* the program's current
    // day. If the user re-did an earlier day, switched programs, or the
    // day was already completed on another device, leave progress alone.
    if (active.program.id != programId) return;
    if (active.currentDayIndex != dayIndex) return;

    await _completeWorkoutDay();
  }
}
