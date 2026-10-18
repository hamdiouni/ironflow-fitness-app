/// A structured workout program generated based on user profile.
class WorkoutProgram {
  const WorkoutProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.days,
    required this.durationWeeks,
    required this.difficulty,
  });

  final String id;
  final String name;
  final String description;
  final List<ProgramDay> days;
  final int durationWeeks;
  final String difficulty;
}

class ProgramDay {
  const ProgramDay({
    required this.dayNumber,
    required this.name,
    required this.focus,
    required this.exercises,
    this.isRestDay = false,
  });

  final int dayNumber;
  final String name;
  final String focus;
  final List<ProgramExercise> exercises;
  final bool isRestDay;
}

class ProgramExercise {
  const ProgramExercise({
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.targetWeight,
    this.notes,
  });

  final String exerciseName;
  final int sets;
  final String reps; // e.g. "8-12" or "15"
  final int restSeconds;
  final double? targetWeight;
  final String? notes;

  ProgramExercise copyWith({
    String? exerciseName,
    int? sets,
    String? reps,
    int? restSeconds,
    double? targetWeight,
    String? notes,
  }) {
    return ProgramExercise(
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      targetWeight: targetWeight ?? this.targetWeight,
      notes: notes ?? this.notes,
    );
  }
}

