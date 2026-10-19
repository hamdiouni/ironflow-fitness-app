/// A structured workout program generated based on user profile.
class WorkoutProgram {
  const WorkoutProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.days,
    required this.durationWeeks,
    required this.difficulty,
    this.splitId,
    this.hybridSplitId,
    this.hybridMode,
    this.cycleLength,
  });

  final String id;
  final String name;
  final String description;
  final List<ProgramDay> days;
  final int durationWeeks;
  final String difficulty;
  final String? splitId;
  final String? hybridSplitId;
  final String? hybridMode;
  final int? cycleLength;

  /// Number of active training days in this program per week.
  int get daysPerWeek {
    final active = days.where((d) => !d.isRestDay).length;
    return active > 0 ? active : days.length;
  }

  WorkoutProgram copyWith({
    String? id,
    String? name,
    String? description,
    List<ProgramDay>? days,
    int? durationWeeks,
    String? difficulty,
    String? splitId,
    String? hybridSplitId,
    String? hybridMode,
    int? cycleLength,
  }) {
    return WorkoutProgram(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      days: days ?? this.days,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      difficulty: difficulty ?? this.difficulty,
      splitId: splitId ?? this.splitId,
      hybridSplitId: hybridSplitId ?? this.hybridSplitId,
      hybridMode: hybridMode ?? this.hybridMode,
      cycleLength: cycleLength ?? this.cycleLength,
    );
  }
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

  ProgramDay copyWith({
    int? dayNumber,
    String? name,
    String? focus,
    List<ProgramExercise>? exercises,
    bool? isRestDay,
  }) {
    return ProgramDay(
      dayNumber: dayNumber ?? this.dayNumber,
      name: name ?? this.name,
      focus: focus ?? this.focus,
      exercises: exercises ?? this.exercises,
      isRestDay: isRestDay ?? this.isRestDay,
    );
  }
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

