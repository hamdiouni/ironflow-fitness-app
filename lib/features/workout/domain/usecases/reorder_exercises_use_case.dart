import '../entities/workout_program.dart';
import '../repositories/active_program_repository.dart';

/// Reorder exercises within a program day while preserving structure.
/// 
/// This use case moves an exercise from one position to another within
/// a program day, maintaining all exercise properties and the overall
/// program structure.
/// 
/// Validates: Requirements 3.4, 3.5
class ReorderExercisesUseCase {
  final ActiveProgramRepository repository;
  
  ReorderExercisesUseCase(this.repository);
  
  Future<void> call({
    required int dayIndex,
    required int oldIndex,
    required int newIndex,
  }) async {
    final activeProgram = await repository.loadActiveProgram();
    if (activeProgram == null) return;
    
    final day = activeProgram.program.days[dayIndex];
    final updatedExercises = List<ProgramExercise>.from(day.exercises);
    
    final exercise = updatedExercises.removeAt(oldIndex);
    updatedExercises.insert(newIndex, exercise);
    
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
