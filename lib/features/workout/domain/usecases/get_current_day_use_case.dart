import '../entities/workout_program.dart';
import '../repositories/active_program_repository.dart';

/// Get the current program day.
/// 
/// This use case retrieves the current day from the active program
/// based on the currentDayIndex. Returns null if no active program exists.
/// 
/// Validates: Requirements 8.1
class GetCurrentDayUseCase {
  final ActiveProgramRepository repository;
  
  GetCurrentDayUseCase(this.repository);
  
  Future<ProgramDay?> call() async {
    final activeProgram = await repository.loadActiveProgram();
    return activeProgram?.currentDay;
  }
}
