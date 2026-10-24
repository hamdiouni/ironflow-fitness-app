import 'package:uuid/uuid.dart';
import '../../data/exercise_database.dart';
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
    
    // Convert program exercises to workout exercises, carrying the planned
    // sets/reps into the session (previously dropped here, so an in-progress
    // workout had no record of the plan — DATABASE_AND_SYNC_AUDIT F-05).
    // Phase 1: also carry the stable catalog link — from the program
    // exercise when present, else resolved by name against the catalog.
    final exercises = currentDay.exercises.map((pe) => Exercise(
      id: const Uuid().v4(),
      exerciseDefinitionId: pe.exerciseDefinitionId ??
          ExerciseDatabase.getByName(pe.exerciseName)?.id,
      name: pe.exerciseName,
      type: ExerciseType.strength,
      sets: [],
      suggestedSets: pe.sets,
      suggestedReps: _parseFirstRepCount(pe.reps),
    )).toList();

    // Phase 1: the workout records which program/day it came from and who
    // owns it; updatedAt is stamped for last-write-wins sync.
    return Workout(
      id: const Uuid().v4(),
      userId: activeProgram.userId ?? activeProgram.program.userId,
      programId: activeProgram.program.id,
      programDayIndex: activeProgram.currentDayIndex,
      date: DateTime.now(),
      exercises: exercises,
      duration: Duration.zero,
      totalVolume: 0,
      updatedAt: DateTime.now(),
    );
  }

  /// Extracts the first rep count from a program rep scheme
  /// ('8-12' → 8, '15' → 15, 'AMRAP' → null).
  static int? _parseFirstRepCount(String reps) {
    final match = RegExp(r'\d+').firstMatch(reps);
    return match == null ? null : int.tryParse(match.group(0)!);
  }
}
