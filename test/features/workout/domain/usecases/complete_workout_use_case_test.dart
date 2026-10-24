import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/domain/repositories/active_program_repository.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/usecases/calculate_workout_volume_use_case.dart';
import 'package:progression_tracker/features/workout/domain/usecases/complete_workout_use_case.dart';
import 'package:progression_tracker/features/workout/domain/usecases/save_workout_use_case.dart';

class _InMemoryWorkoutRepository implements WorkoutRepository {
  final List<Workout> saved = [];

  @override
  Future<void> saveWorkout(Workout workout) async {
    saved.removeWhere((w) => w.id == workout.id);
    saved.add(workout);
  }

  @override
  Future<void> deleteWorkout(String id) async {
    saved.removeWhere((w) => w.id == id);
  }

  @override
  Future<List<Workout>> getAllWorkouts() async => List.unmodifiable(saved);

  @override
  Future<List<Exercise>> getExerciseHistory(
    String exerciseName,
    int limit,
  ) async =>
      const [];

  @override
  Future<int> getWorkoutCount() async => saved.length;

  @override
  Future<List<Workout>> getWorkoutsByDateRange(
    DateTime start,
    DateTime end,
  ) async =>
      saved
          .where(
            (w) =>
                (w.date.isAfter(start) || w.date.isAtSameMomentAs(start)) &&
                w.date.isBefore(end),
          )
          .toList();

  @override
  Future<List<Workout>> getWorkoutsPaginated({
    int offset = 0,
    int limit = 20,
  }) async =>
      saved.skip(offset).take(limit).toList();
}

class _InMemoryActiveProgramRepository implements ActiveProgramRepository {
  _InMemoryActiveProgramRepository(this.current);

  ActiveProgram? current;
  final List<ActiveProgram> updated = [];

  @override
  Future<void> archiveCurrentProgram() async {}

  @override
  Future<void> clearActiveProgram() async {
    current = null;
  }

  @override
  Future<bool> hasArchivedProgram() async => false;

  @override
  Future<ActiveProgram?> loadActiveProgram() async => current;

  @override
  Future<ActiveProgram?> restoreArchivedProgram() async => null;

  @override
  Future<void> saveActiveProgram(ActiveProgram program) async {
    current = program;
  }

  @override
  Future<void> updateActiveProgram(ActiveProgram program) async {
    current = program;
    updated.add(program);
  }
}

void main() {
  const program = WorkoutProgram(
    id: 'program-1',
    name: 'Three Day Program',
    description: 'Push, rest, pull',
    durationWeeks: 4,
    difficulty: 'beginner',
    days: [
      ProgramDay(
        dayNumber: 1,
        name: 'Push',
        focus: 'Chest',
        exercises: [],
      ),
      ProgramDay(
        dayNumber: 2,
        name: 'Rest',
        focus: 'Recovery',
        exercises: [],
        isRestDay: true,
      ),
      ProgramDay(
        dayNumber: 3,
        name: 'Pull',
        focus: 'Back',
        exercises: [],
      ),
    ],
  );

  late _InMemoryWorkoutRepository workoutRepository;
  late _InMemoryActiveProgramRepository activeProgramRepository;
  late CompleteWorkoutUseCase useCase;

  Workout buildWorkout({
    String id = 'workout-1',
    String? programId = 'program-1',
    int? programDayIndex = 0,
  }) {
    return Workout(
      id: id,
      date: DateTime(2026, 10, 23),
      duration: Duration.zero,
      totalVolume: 0,
      programId: programId,
      programDayIndex: programDayIndex,
      exercises: [
        Exercise(
          id: 'exercise-1',
          name: 'Bench Press',
          type: ExerciseType.strength,
          sets: [
            SetEntry(
              id: 'set-1',
              reps: 5,
              weight: 100,
              timestamp: DateTime(2026, 10, 23),
            ),
          ],
        ),
      ],
    );
  }

  setUp(() {
    workoutRepository = _InMemoryWorkoutRepository();
    activeProgramRepository = _InMemoryActiveProgramRepository(
      const ActiveProgram(
        id: 'active-1',
        program: program,
        currentDayIndex: 0,
        isActive: true,
      ),
    );
    useCase = CompleteWorkoutUseCase(
      saveWorkout: SaveWorkoutUseCase(
        workoutRepository,
        CalculateWorkoutVolumeUseCase(),
      ),
      activeProgramRepository: activeProgramRepository,
    );
  });

  group('CompleteWorkoutUseCase', () {
    test('saves the workout and advances only its matching current day',
        () async {
      await useCase(buildWorkout(), const Duration(minutes: 45));

      expect(workoutRepository.saved, hasLength(1));
      expect(workoutRepository.saved.single.duration, const Duration(minutes: 45));
      expect(workoutRepository.saved.single.totalVolume, 500);
      expect(activeProgramRepository.updated, hasLength(1));
      expect(activeProgramRepository.current?.currentDayIndex, 2);
      expect(
        activeProgramRepository.current?.completedDays.containsKey(0),
        isTrue,
      );
    });

    test('saves a repeated/non-current day without advancing the program',
        () async {
      await useCase(
        buildWorkout(id: 'workout-repeat', programDayIndex: 2),
        const Duration(minutes: 30),
      );

      expect(workoutRepository.saved.single.id, 'workout-repeat');
      expect(activeProgramRepository.updated, isEmpty);
      expect(activeProgramRepository.current?.currentDayIndex, 0);
    });

    test('saves a custom workout without touching the active program',
        () async {
      await useCase(
        buildWorkout(
          id: 'workout-custom',
          programId: null,
          programDayIndex: null,
        ),
        const Duration(minutes: 20),
      );

      expect(workoutRepository.saved.single.id, 'workout-custom');
      expect(activeProgramRepository.updated, isEmpty);
      expect(activeProgramRepository.current?.currentDayIndex, 0);
    });

    test('does not advance a different program', () async {
      await useCase(
        buildWorkout(id: 'workout-other', programId: 'program-2'),
        const Duration(minutes: 25),
      );

      expect(workoutRepository.saved.single.id, 'workout-other');
      expect(activeProgramRepository.updated, isEmpty);
      expect(activeProgramRepository.current?.currentDayIndex, 0);
    });
  });
}
