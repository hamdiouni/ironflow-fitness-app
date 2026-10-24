import '../entities/workout_program.dart';
import '../repositories/active_program_repository.dart';
import '../../data/exercise_database.dart';

/// Replace an exercise in the active program while preserving parameters.
/// 
/// This use case replaces an exercise at a specific position in a program day
/// while preserving the original sets, reps, and rest seconds. This allows
/// users to adapt their program to equipment availability or preferences.
/// 
/// Validates: Requirements 3.2, 11.1, 11.4
class ReplaceExerciseUseCase {
  final ActiveProgramRepository repository;
  
  ReplaceExerciseUseCase(this.repository);
  
  Future<void> call({
    required int dayIndex,
    required int exerciseIndex,
    required String newExerciseName,
  }) async {
    final activeProgram = await repository.loadActiveProgram();
    if (activeProgram == null) return;
    
    final day = activeProgram.program.days[dayIndex];
    final updatedExercises = List<ProgramExercise>.from(day.exercises);
    final oldExercise = updatedExercises[exerciseIndex];
    
    // Preserve sets, reps, rest when replacing
    updatedExercises[exerciseIndex] = ProgramExercise(
      exerciseName: newExerciseName,
      exerciseDefinitionId:
          ExerciseDatabase.getByName(newExerciseName)?.id,
      sets: oldExercise.sets,
      reps: oldExercise.reps,
      restSeconds: oldExercise.restSeconds,
      targetWeight: oldExercise.targetWeight,
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
    
    // copyWith preserves split/hybrid metadata and userId (Phase 1);
    // manual rebuilds silently dropped them.
    final updatedProgram = activeProgram.program.copyWith(days: updatedDays);
    
    final updated = activeProgram.updateProgram(updatedProgram);
    await repository.updateActiveProgram(updated);
  }
}
