import '../repositories/active_program_repository.dart';

/// Complete the current workout day and advance.
/// 
/// This use case marks the current day as complete, records the completion
/// date, and advances to the next workout day (skipping rest days).
/// 
/// Validates: Requirements 8.6
class CompleteWorkoutDayUseCase {
  final ActiveProgramRepository repository;
  
  CompleteWorkoutDayUseCase(this.repository);
  
  Future<void> call() async {
    final activeProgram = await repository.loadActiveProgram();
    if (activeProgram == null) return;
    
    final updated = activeProgram.completeCurrentDay();
    await repository.updateActiveProgram(updated);
  }
}
