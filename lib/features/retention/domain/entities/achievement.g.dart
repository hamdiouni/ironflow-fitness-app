// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AchievementImpl _$$AchievementImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$AchievementImpl', json, ($checkedConvert) {
      final val = _$AchievementImpl(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String),
        icon: $checkedConvert('icon', (v) => v as String),
        threshold: $checkedConvert('threshold', (v) => (v as num).toInt()),
        type: $checkedConvert(
          'type',
          (v) => $enumDecode(_$AchievementTypeEnumMap, v),
        ),
        isUnlocked: $checkedConvert('isUnlocked', (v) => v as bool),
        unlockedDate: $checkedConvert(
          'unlockedDate',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        progress: $checkedConvert('progress', (v) => (v as num).toDouble()),
      );
      return val;
    });

Map<String, dynamic> _$$AchievementImplToJson(_$AchievementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'threshold': instance.threshold,
      'type': _$AchievementTypeEnumMap[instance.type]!,
      'isUnlocked': instance.isUnlocked,
      'unlockedDate': instance.unlockedDate?.toIso8601String(),
      'progress': instance.progress,
    };

const _$AchievementTypeEnumMap = {
  AchievementType.workouts: 'workouts',
  AchievementType.streak: 'streak',
  AchievementType.volume: 'volume',
  AchievementType.consistency: 'consistency',
  AchievementType.personalRecord: 'personalRecord',
};
