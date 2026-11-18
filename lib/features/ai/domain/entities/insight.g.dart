// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InsightImpl _$$InsightImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$InsightImpl', json, ($checkedConvert) {
      final val = _$InsightImpl(
        id: $checkedConvert('id', (v) => v as String),
        context: $checkedConvert(
          'context',
          (v) => $enumDecode(_$InsightContextEnumMap, v),
        ),
        title: $checkedConvert('title', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
        icon: $checkedConvert('icon', (v) => v as String),
        priority: $checkedConvert(
          'priority',
          (v) => $enumDecode(_$InsightPriorityEnumMap, v),
        ),
        generatedAt: $checkedConvert(
          'generatedAt',
          (v) => DateTime.parse(v as String),
        ),
        metadata: $checkedConvert(
          'metadata',
          (v) => v as Map<String, dynamic>? ?? const {},
        ),
      );
      return val;
    });

Map<String, dynamic> _$$InsightImplToJson(_$InsightImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'context': _$InsightContextEnumMap[instance.context]!,
      'title': instance.title,
      'message': instance.message,
      'icon': instance.icon,
      'priority': _$InsightPriorityEnumMap[instance.priority]!,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$InsightContextEnumMap = {
  InsightContext.home: 'home',
  InsightContext.workout: 'workout',
  InsightContext.nutrition: 'nutrition',
  InsightContext.profile: 'profile',
};

const _$InsightPriorityEnumMap = {
  InsightPriority.high: 'high',
  InsightPriority.medium: 'medium',
  InsightPriority.low: 'low',
};
