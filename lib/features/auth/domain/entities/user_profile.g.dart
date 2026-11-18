// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$UserProfileImpl', json, ($checkedConvert) {
  final val = _$UserProfileImpl(
    userId: $checkedConvert('userId', (v) => v as String),
    email: $checkedConvert('email', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String?),
    age: $checkedConvert('age', (v) => (v as num?)?.toInt()),
    gender: $checkedConvert('gender', (v) => v as String?),
    fitnessLevel: $checkedConvert('fitnessLevel', (v) => v as String?),
    goals: $checkedConvert(
      'goals',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    equipment: $checkedConvert(
      'equipment',
      (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
    ),
    createdAt: $checkedConvert('createdAt', (v) => DateTime.parse(v as String)),
    updatedAt: $checkedConvert('updatedAt', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
      'fitnessLevel': instance.fitnessLevel,
      'goals': instance.goals,
      'equipment': instance.equipment,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
