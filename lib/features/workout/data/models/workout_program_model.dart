import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/workout_program.dart';

part 'workout_program_model.freezed.dart';
part 'workout_program_model.g.dart';

/// Data model for WorkoutProgram with JSON serialization
@freezed
class WorkoutProgramModel with _$WorkoutProgramModel {
  const factory WorkoutProgramModel({
    required String id,
    required String name,
    required String description,
    required List<ProgramDayModel> days,
    required int durationWeeks,
    required String difficulty,
  }) = _WorkoutProgramModel;
  
  factory WorkoutProgramModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutProgramModelFromJson(json);
  
  factory WorkoutProgramModel.fromEntity(WorkoutProgram entity) {
    return WorkoutProgramModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      days: entity.days.map(ProgramDayModel.fromEntity).toList(),
      durationWeeks: entity.durationWeeks,
      difficulty: entity.difficulty,
    );
  }
}

extension WorkoutProgramModelX on WorkoutProgramModel {
  WorkoutProgram toEntity() {
    return WorkoutProgram(
      id: id,
      name: name,
      description: description,
      days: days.map((d) => d.toEntity()).toList(),
      durationWeeks: durationWeeks,
      difficulty: difficulty,
    );
  }
}

/// Data model for ProgramDay with JSON serialization
@freezed
class ProgramDayModel with _$ProgramDayModel {
  const factory ProgramDayModel({
    required int dayNumber,
    required String name,
    required String focus,
    required List<ProgramExerciseModel> exercises,
    @Default(false) bool isRestDay,
  }) = _ProgramDayModel;
  
  factory ProgramDayModel.fromJson(Map<String, dynamic> json) =>
      _$ProgramDayModelFromJson(json);
  
  factory ProgramDayModel.fromEntity(ProgramDay entity) {
    return ProgramDayModel(
      dayNumber: entity.dayNumber,
      name: entity.name,
      focus: entity.focus,
      exercises: entity.exercises.map(ProgramExerciseModel.fromEntity).toList(),
      isRestDay: entity.isRestDay,
    );
  }
}

extension ProgramDayModelX on ProgramDayModel {
  ProgramDay toEntity() {
    return ProgramDay(
      dayNumber: dayNumber,
      name: name,
      focus: focus,
      exercises: exercises.map((e) => e.toEntity()).toList(),
      isRestDay: isRestDay,
    );
  }
}

/// Data model for ProgramExercise with JSON serialization
@freezed
class ProgramExerciseModel with _$ProgramExerciseModel {
  const factory ProgramExerciseModel({
    required String exerciseName,
    required int sets,
    required String reps,
    required int restSeconds,
    String? notes,
  }) = _ProgramExerciseModel;
  
  factory ProgramExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ProgramExerciseModelFromJson(json);
  
  factory ProgramExerciseModel.fromEntity(ProgramExercise entity) {
    return ProgramExerciseModel(
      exerciseName: entity.exerciseName,
      sets: entity.sets,
      reps: entity.reps,
      restSeconds: entity.restSeconds,
      notes: entity.notes,
    );
  }
}

extension ProgramExerciseModelX on ProgramExerciseModel {
  ProgramExercise toEntity() {
    return ProgramExercise(
      exerciseName: exerciseName,
      sets: sets,
      reps: reps,
      restSeconds: restSeconds,
      notes: notes,
    );
  }
}
