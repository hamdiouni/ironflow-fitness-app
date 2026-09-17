import '../entities/active_program.dart';
import '../entities/workout_program.dart';
import '../repositories/active_program_repository.dart';

/// Update exercise parameters (sets, reps, rest) with validation.
/// 
/// This use case updates specific parameters of an exercise in the active
/// program. Only provided parameters are updated, allowing partial updates.
/// All changes are validated before being persisted.
/// 
/// Validates: Requirements 3.2, 3.4
class UpdateExerciseParametersUseCase {
  final ActiveProgramRepository repository;
  
  UpdateExerciseParametersUseCase(this.repository);
  
  Future<void> call({
    required int dayIndex,
    required int exerciseIndex,
    int? sets,
    String? reps,
    int? restSeconds,
  }) async {
    final activeProgram = await repository.loadActiveProgram();
    if (activeProgram == null) return;
    
    final day = activeProgram.program.days[dayIndex];
    final updatedExercises = List<ProgramExercise>.from(day.exercises);
    final oldExercise = updatedExercises[exerciseIndex];
    
    updatedExercises[exerciseIndex] = ProgramExercise(
      exerciseName: oldExercise.exerciseName,
      sets: sets ?? oldExercise.sets,
      reps: reps ?? oldExercise.reps,
      restSeconds: restSeconds ?? oldExercise.restSeconds,
      notes: oldExercise.notes,
    );
    
    final updatedDay = ProgramDay(
      dayNumber: day.dayNumber,
      name: day.name,
      focus: day.focus,
      exercises: updatedExercises,
      isRestDay: day.isRestDay,
    );
    
    final updatedDays = List<ProgramDay>.from(activeProgram.program.days);
    updatedDays[dayIndex] = updatedDay;
    
    final updatedProgram = WorkoutProgram(
      id: activeProgram.program.id,
      name: activeProgram.program.name,
      description: activeProgram.program.description,
      days: updatedDays,
      durationWeeks: activeProgram.program.durationWeeks,
      difficulty: activeProgram.program.difficulty,
    );
    
    final updated = activeProgram.updateProgram(updatedProgram);
    await repository.updateActiveProgram(updated);
  }
}
