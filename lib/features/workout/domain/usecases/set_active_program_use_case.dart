import 'package:uuid/uuid.dart';
import '../entities/active_program.dart';
import '../entities/workout_program.dart';
import '../repositories/active_program_repository.dart';

/// Set a workout program as the active program.
/// 
/// This use case creates a new ActiveProgram from a WorkoutProgram
/// and saves it to persistent storage, making it the single source
/// of truth for workout sessions.
/// 
/// Validates: Requirements 1.2, 7.2
class SetActiveProgramUseCase {
  final ActiveProgramRepository repository;
  
  SetActiveProgramUseCase(this.repository);
  
  Future<void> call(WorkoutProgram program) async {
    final activeProgram = ActiveProgram(
      id: const Uuid().v4(),
      program: program,
      currentDayIndex: 0,
      isActive: true,
      lastWorkoutDate: null,
      completedDays: {},
    );
    
    await repository.saveActiveProgram(activeProgram);
  }
}
