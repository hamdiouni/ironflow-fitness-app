// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseModelImpl _$$ExerciseModelImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$ExerciseModelImpl', json, ($checkedConvert) {
      final val = _$ExerciseModelImpl(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        type: $checkedConvert('type', (v) => v as String),
        sets: $checkedConvert(
          'sets',
          (v) => (v as List<dynamic>)
              .map((e) => SetEntryModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        suggestedReps: $checkedConvert(
          'suggestedReps',
          (v) => (v as num?)?.toInt(),
        ),
        suggestedSets: $checkedConvert(
          'suggestedSets',
          (v) => (v as num?)?.toInt(),
        ),
        exerciseDefinitionId: $checkedConvert(
          'exerciseDefinitionId',
          (v) => v as String?,
        ),
        supersetGroupId: $checkedConvert(
          'supersetGroupId',
          (v) => v as String?,
        ),
      );
      return val;
    });

Map<String, dynamic> _$$ExerciseModelImplToJson(_$ExerciseModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'sets': instance.sets.map((e) => e.toJson()).toList(),
      'suggestedReps': instance.suggestedReps,
      'suggestedSets': instance.suggestedSets,
      'exerciseDefinitionId': instance.exerciseDefinitionId,
      'supersetGroupId': instance.supersetGroupId,
    };
