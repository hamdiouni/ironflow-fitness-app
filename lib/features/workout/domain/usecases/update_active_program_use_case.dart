import '../entities/active_program.dart';
import '../repositories/active_program_repository.dart';

/// Update the active program (for editing).
/// 
/// This use case updates an existing ActiveProgram in persistent storage.
/// Typically used for progress tracking, exercise modifications,
/// or advancing to the next day.
/// 
/// Validates: Requirements 7.4
class UpdateActiveProgramUseCase {
  final ActiveProgramRepository repository;
  
  UpdateActiveProgramUseCase(this.repository);
  
  Future<void> call(ActiveProgram program) async {
    await repository.updateActiveProgram(program);
  }
}
