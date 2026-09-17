import '../repositories/active_program_repository.dart';

/// Clear the active program.
/// 
/// This use case removes the active program from persistent storage,
/// effectively deactivating the current program. Used when a user
/// wants to start fresh or select a different program.
/// 
/// Validates: Requirements 7.2
class ClearActiveProgramUseCase {
  final ActiveProgramRepository repository;
  
  ClearActiveProgramUseCase(this.repository);
  
  Future<void> call() async {
    await repository.clearActiveProgram();
  }
}
