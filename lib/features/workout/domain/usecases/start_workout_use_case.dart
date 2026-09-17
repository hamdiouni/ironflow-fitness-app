import 'package:uuid/uuid.dart';
import '../entities/entities.dart';
import '../repositories/workout_repository.dart';
import '../repositories/active_program_repository.dart';
import '../exceptions/workout_exceptions.dart';

/// Creates a new workout session pre-populated with exercises from the active program.
/// 
/// This use case loads the active program, extracts the current day's exercises,
/// and creates a workout session with all exercises ready to be logged.
/// 
/// Throws [ActiveProgramException] if no active program is set.
class StartWorkoutUseCase {
  final WorkoutRepository repository;
  final ActiveProgramRepository activeProgramRepository;

  StartWorkoutUseCase(this.repository, this.activeProgramRepository);

  Future<Workout> call() async {
    // Load active program
    final activeProgram = await activeProgramRepository.loadActiveProgram();
    
    if (activeProgram == null) {
      throw ActiveProgramException(
        message: 'No active program set. Please generate a program first.',
      );
    }

    // Get current day exercises
    final currentDay = activeProgram.currentDay;
    
    // Convert program exercises to workout exercises
    final exercises = currentDay.exercises.map((pe) => Exercise(
      id: const Uuid().v4(),
      name: pe.exerciseName,
      type: ExerciseType.strength,
      sets: [],
    )).toList();

    return Workout(
      id: const Uuid().v4(),
      date: DateTime.now(),
      exercises: exercises,
      duration: Duration.zero,
      totalVolume: 0,
    );
  }
}
