import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/active_program.dart';
import 'workout_program_model.dart';

part 'active_program_model.freezed.dart';
part 'active_program_model.g.dart';

/// Data model for ActiveProgram with JSON serialization
@freezed
class ActiveProgramModel with _$ActiveProgramModel {
  const factory ActiveProgramModel({
    required String id,
    required WorkoutProgramModel program,
    required int currentDayIndex,
    required bool isActive,
    String? lastWorkoutDate,  // ISO 8601 string
    @Default({}) Map<String, String> completedDays,  // dayIndex as string -> ISO date
  }) = _ActiveProgramModel;
  
  factory ActiveProgramModel.fromJson(Map<String, dynamic> json) =>
      _$ActiveProgramModelFromJson(json);
  
  factory ActiveProgramModel.fromEntity(ActiveProgram entity) {
    return ActiveProgramModel(
      id: entity.id,
      program: WorkoutProgramModel.fromEntity(entity.program),
      currentDayIndex: entity.currentDayIndex,
      isActive: entity.isActive,
      lastWorkoutDate: entity.lastWorkoutDate?.toIso8601String(),
      completedDays: entity.completedDays.map(
        (key, value) => MapEntry(key.toString(), value.toIso8601String()),
      ),
    );
  }
}

extension ActiveProgramModelX on ActiveProgramModel {
  ActiveProgram toEntity() {
    return ActiveProgram(
      id: id,
      program: program.toEntity(),
      currentDayIndex: currentDayIndex,
      isActive: isActive,
      lastWorkoutDate: lastWorkoutDate != null 
          ? DateTime.parse(lastWorkoutDate!) 
          : null,
      completedDays: completedDays.map(
        (key, value) => MapEntry(int.parse(key), DateTime.parse(value)),
      ),
    );
  }
}
