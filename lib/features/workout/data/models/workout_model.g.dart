// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkoutModelImpl _$$WorkoutModelImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$WorkoutModelImpl', json, ($checkedConvert) {
      final val = _$WorkoutModelImpl(
        id: $checkedConvert('id', (v) => v as String),
        date: $checkedConvert('date', (v) => v as String),
        exercises: $checkedConvert(
          'exercises',
          (v) => (v as List<dynamic>)
              .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        durationSeconds: $checkedConvert(
          'durationSeconds',
          (v) => (v as num).toInt(),
        ),
        totalVolume: $checkedConvert(
          'totalVolume',
          (v) => (v as num).toDouble(),
        ),
        caloriesBurned: $checkedConvert(
          'caloriesBurned',
          (v) => (v as num?)?.toDouble() ?? 0,
        ),
        userId: $checkedConvert('userId', (v) => v as String?),
        programId: $checkedConvert('programId', (v) => v as String?),
        programDayIndex: $checkedConvert(
          'programDayIndex',
          (v) => (v as num?)?.toInt(),
        ),
        updatedAt: $checkedConvert('updatedAt', (v) => v as String?),
        deletedAt: $checkedConvert('deletedAt', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$$WorkoutModelImplToJson(_$WorkoutModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'exercises': instance.exercises.map((e) => e.toJson()).toList(),
      'durationSeconds': instance.durationSeconds,
      'totalVolume': instance.totalVolume,
      'caloriesBurned': instance.caloriesBurned,
      'userId': instance.userId,
      'programId': instance.programId,
      'programDayIndex': instance.programDayIndex,
      'updatedAt': instance.updatedAt,
      'deletedAt': instance.deletedAt,
    };
