// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BodyEntryModelImpl _$$BodyEntryModelImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$BodyEntryModelImpl', json, ($checkedConvert) {
      final val = _$BodyEntryModelImpl(
        id: $checkedConvert('id', (v) => v as String),
        date: $checkedConvert('date', (v) => v as String),
        weight: $checkedConvert('weight', (v) => (v as num).toDouble()),
        measurements: $checkedConvert(
          'measurements',
          (v) => (v as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ),
        ),
        photoPath: $checkedConvert('photoPath', (v) => v as String?),
        userId: $checkedConvert('userId', (v) => v as String?),
        updatedAt: $checkedConvert('updatedAt', (v) => v as String?),
        deletedAt: $checkedConvert('deletedAt', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$$BodyEntryModelImplToJson(
  _$BodyEntryModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date,
  'weight': instance.weight,
  'measurements': instance.measurements,
  'photoPath': instance.photoPath,
  'userId': instance.userId,
  'updatedAt': instance.updatedAt,
  'deletedAt': instance.deletedAt,
};
