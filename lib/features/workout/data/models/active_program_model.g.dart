// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_program_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActiveProgramModelImpl _$$ActiveProgramModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$ActiveProgramModelImpl', json, ($checkedConvert) {
  final val = _$ActiveProgramModelImpl(
    id: $checkedConvert('id', (v) => v as String),
    program: $checkedConvert(
      'program',
      (v) => WorkoutProgramModel.fromJson(v as Map<String, dynamic>),
    ),
    currentDayIndex: $checkedConvert(
      'currentDayIndex',
      (v) => (v as num).toInt(),
    ),
    isActive: $checkedConvert('isActive', (v) => v as bool),
    lastWorkoutDate: $checkedConvert('lastWorkoutDate', (v) => v as String?),
    completedDays: $checkedConvert(
      'completedDays',
      (v) =>
          (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    ),
    userId: $checkedConvert('userId', (v) => v as String?),
    updatedAt: $checkedConvert('updatedAt', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$$ActiveProgramModelImplToJson(
  _$ActiveProgramModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'program': instance.program.toJson(),
  'currentDayIndex': instance.currentDayIndex,
  'isActive': instance.isActive,
  'lastWorkoutDate': instance.lastWorkoutDate,
  'completedDays': instance.completedDays,
  'userId': instance.userId,
  'updatedAt': instance.updatedAt,
};
