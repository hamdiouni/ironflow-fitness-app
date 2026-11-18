// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$ChatMessageImpl', json, ($checkedConvert) {
      final val = _$ChatMessageImpl(
        id: $checkedConvert('id', (v) => v as String),
        role: $checkedConvert('role', (v) => v as String),
        content: $checkedConvert('content', (v) => v as String),
        timestamp: $checkedConvert(
          'timestamp',
          (v) => DateTime.parse(v as String),
        ),
        metadata: $checkedConvert(
          'metadata',
          (v) => v as Map<String, dynamic>? ?? const {},
        ),
      );
      return val;
    });

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'metadata': instance.metadata,
    };
