// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_program_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutProgramModelImpl _$$WorkoutProgramModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$WorkoutProgramModelImpl', json, ($checkedConvert) {
  final val = _$WorkoutProgramModelImpl(
    id: $checkedConvert('id', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    description: $checkedConvert('description', (v) => v as String),
    days: $checkedConvert(
      'days',
      (v) => (v as List<dynamic>)
          .map((e) => ProgramDayModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    durationWeeks: $checkedConvert('durationWeeks', (v) => (v as num).toInt()),
    difficulty: $checkedConvert('difficulty', (v) => v as String),
    splitId: $checkedConvert('splitId', (v) => v as String?),
    hybridSplitId: $checkedConvert('hybridSplitId', (v) => v as String?),
    hybridMode: $checkedConvert('hybridMode', (v) => v as String?),
    cycleLength: $checkedConvert('cycleLength', (v) => (v as num?)?.toInt()),
    userId: $checkedConvert('userId', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$$WorkoutProgramModelImplToJson(
  _$WorkoutProgramModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'days': instance.days.map((e) => e.toJson()).toList(),
  'durationWeeks': instance.durationWeeks,
  'difficulty': instance.difficulty,
  'splitId': instance.splitId,
  'hybridSplitId': instance.hybridSplitId,
  'hybridMode': instance.hybridMode,
  'cycleLength': instance.cycleLength,
  'userId': instance.userId,
};

_$ProgramDayModelImpl _$$ProgramDayModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$ProgramDayModelImpl', json, ($checkedConvert) {
  final val = _$ProgramDayModelImpl(
    dayNumber: $checkedConvert('dayNumber', (v) => (v as num).toInt()),
    name: $checkedConvert('name', (v) => v as String),
    focus: $checkedConvert('focus', (v) => v as String),
    exercises: $checkedConvert(
      'exercises',
      (v) => (v as List<dynamic>)
          .map((e) => ProgramExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    isRestDay: $checkedConvert('isRestDay', (v) => v as bool? ?? false),
  );
  return val;
});

Map<String, dynamic> _$$ProgramDayModelImplToJson(
  _$ProgramDayModelImpl instance,
) => <String, dynamic>{
  'dayNumber': instance.dayNumber,
  'name': instance.name,
  'focus': instance.focus,
  'exercises': instance.exercises.map((e) => e.toJson()).toList(),
  'isRestDay': instance.isRestDay,
};

_$ProgramExerciseModelImpl _$$ProgramExerciseModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$ProgramExerciseModelImpl', json, ($checkedConvert) {
  final val = _$ProgramExerciseModelImpl(
    exerciseName: $checkedConvert('exerciseName', (v) => v as String),
    sets: $checkedConvert('sets', (v) => (v as num).toInt()),
    reps: $checkedConvert('reps', (v) => v as String),
    restSeconds: $checkedConvert('restSeconds', (v) => (v as num).toInt()),
    targetWeight: $checkedConvert(
      'targetWeight',
      (v) => (v as num?)?.toDouble(),
    ),
    notes: $checkedConvert('notes', (v) => v as String?),
    exerciseDefinitionId: $checkedConvert(
      'exerciseDefinitionId',
      (v) => v as String?,
    ),
  );
  return val;
});

Map<String, dynamic> _$$ProgramExerciseModelImplToJson(
  _$ProgramExerciseModelImpl instance,
) => <String, dynamic>{
  'exerciseName': instance.exerciseName,
  'sets': instance.sets,
  'reps': instance.reps,
  'restSeconds': instance.restSeconds,
  'targetWeight': instance.targetWeight,
  'notes': instance.notes,
  'exerciseDefinitionId': instance.exerciseDefinitionId,
};
