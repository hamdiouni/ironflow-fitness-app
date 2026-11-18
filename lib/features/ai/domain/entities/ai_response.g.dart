// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AISuggestionImpl _$$AISuggestionImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$AISuggestionImpl', json, ($checkedConvert) {
      final val = _$AISuggestionImpl(
        id: $checkedConvert('id', (v) => v as String),
        title: $checkedConvert('title', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String),
        actionType: $checkedConvert('actionType', (v) => v as String),
        payload: $checkedConvert(
          'payload',
          (v) => v as Map<String, dynamic>? ?? const {},
        ),
        confidence: $checkedConvert(
          'confidence',
          (v) => (v as num?)?.toDouble() ?? 0.8,
        ),
      );
      return val;
    });

Map<String, dynamic> _$$AISuggestionImplToJson(_$AISuggestionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'actionType': instance.actionType,
      'payload': instance.payload,
      'confidence': instance.confidence,
    };

_$AIResponseImpl _$$AIResponseImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$AIResponseImpl', json, ($checkedConvert) {
      final val = _$AIResponseImpl(
        id: $checkedConvert('id', (v) => v as String),
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$AIResponseTypeEnumMap, v),
        ),
        text: $checkedConvert('text', (v) => v as String),
        suggestions: $checkedConvert(
          'suggestions',
          (v) =>
              (v as List<dynamic>?)
                  ?.map((e) => AISuggestion.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              const [],
        ),
        data: $checkedConvert(
          'data',
          (v) => v as Map<String, dynamic>? ?? const {},
        ),
        isActionable: $checkedConvert(
          'isActionable',
          (v) => v as bool? ?? true,
        ),
      );
      return val;
    });

Map<String, dynamic> _$$AIResponseImplToJson(_$AIResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$AIResponseTypeEnumMap[instance.type]!,
      'text': instance.text,
      'suggestions': instance.suggestions.map((e) => e.toJson()).toList(),
      'data': instance.data,
      'isActionable': instance.isActionable,
    };

const _$AIResponseTypeEnumMap = {
  AIResponseType.text: 'text',
  AIResponseType.suggestion: 'suggestion',
  AIResponseType.program: 'program',
  AIResponseType.mealPlan: 'mealPlan',
  AIResponseType.analysis: 'analysis',
  AIResponseType.celebration: 'celebration',
};
