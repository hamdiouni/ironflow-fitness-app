// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SetEntryModelImpl _$$SetEntryModelImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$SetEntryModelImpl', json, ($checkedConvert) {
      final val = _$SetEntryModelImpl(
        id: $checkedConvert('id', (v) => v as String),
        reps: $checkedConvert('reps', (v) => (v as num).toInt()),
        weight: $checkedConvert('weight', (v) => (v as num).toDouble()),
        rpe: $checkedConvert('rpe', (v) => (v as num?)?.toInt()),
        type: $checkedConvert('type', (v) => v as String? ?? 'normal'),
        timestamp: $checkedConvert('timestamp', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$$SetEntryModelImplToJson(_$SetEntryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reps': instance.reps,
      'weight': instance.weight,
      'rpe': instance.rpe,
      'type': instance.type,
      'timestamp': instance.timestamp,
    };
