// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StreakImpl _$$StreakImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$StreakImpl', json, ($checkedConvert) {
  final val = _$StreakImpl(
    currentStreak: $checkedConvert('currentStreak', (v) => (v as num).toInt()),
    longestStreak: $checkedConvert('longestStreak', (v) => (v as num).toInt()),
    lastWorkoutDate: $checkedConvert(
      'lastWorkoutDate',
      (v) => DateTime.parse(v as String),
    ),
    streakStartDate: $checkedConvert(
      'streakStartDate',
      (v) => DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$$StreakImplToJson(_$StreakImpl instance) =>
    <String, dynamic>{
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastWorkoutDate': instance.lastWorkoutDate.toIso8601String(),
      'streakStartDate': instance.streakStartDate.toIso8601String(),
    };
