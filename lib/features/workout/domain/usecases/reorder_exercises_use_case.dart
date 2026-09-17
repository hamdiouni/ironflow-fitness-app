import '../entities/active_program.dart';
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
