// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InsightModelImpl _$$InsightModelImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$InsightModelImpl', json, ($checkedConvert) {
      final val = _$InsightModelImpl(
        id: $checkedConvert('id', (v) => v as String),
        context: $checkedConvert('context', (v) => (v as num).toInt()),
        title: $checkedConvert('title', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
        icon: $checkedConvert('icon', (v) => v as String),
        priority: $checkedConvert('priority', (v) => (v as num).toInt()),
        generatedAtMillis: $checkedConvert(
          'generatedAtMillis',
          (v) => (v as num).toInt(),
        ),
        metadata: $checkedConvert(
          'metadata',
          (v) => v as Map<String, dynamic>? ?? const {},
        ),
      );
      return val;
    });

Map<String, dynamic> _$$InsightModelImplToJson(_$InsightModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'context': instance.context,
      'title': instance.title,
      'message': instance.message,
      'icon': instance.icon,
      'priority': instance.priority,
      'generatedAtMillis': instance.generatedAtMillis,
      'metadata': instance.metadata,
    };
