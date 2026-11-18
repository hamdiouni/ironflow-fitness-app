// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consistency_metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConsistencyMetricsImpl _$$ConsistencyMetricsImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$ConsistencyMetricsImpl', json, ($checkedConvert) {
  final val = _$ConsistencyMetricsImpl(
    userId: $checkedConvert('userId', (v) => v as String),
    totalWorkouts: $checkedConvert('totalWorkouts', (v) => (v as num).toInt()),
    totalWeeks: $checkedConvert('totalWeeks', (v) => (v as num).toInt()),
    averageWorkoutsPerWeek: $checkedConvert(
      'averageWorkoutsPerWeek',
      (v) => (v as num).toDouble(),
    ),
    currentStreak: $checkedConvert('currentStreak', (v) => (v as num).toInt()),
    longestStreak: $checkedConvert('longestStreak', (v) => (v as num).toInt()),
    adherenceRate: $checkedConvert(
      'adherenceRate',
      (v) => (v as num).toDouble(),
    ),
    weeklyData: $checkedConvert(
      'weeklyData',
      (v) => (v as List<dynamic>)
          .map((e) => WeeklyConsistency.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    mostActiveDay: $checkedConvert('mostActiveDay', (v) => (v as num).toInt()),
    leastActiveDay: $checkedConvert(
      'leastActiveDay',
      (v) => (v as num).toInt(),
    ),
    averageDuration: $checkedConvert(
      'averageDuration',
      (v) => (v as num).toDouble(),
    ),
    startDate: $checkedConvert('startDate', (v) => DateTime.parse(v as String)),
    endDate: $checkedConvert('endDate', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$$ConsistencyMetricsImplToJson(
  _$ConsistencyMetricsImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'totalWorkouts': instance.totalWorkouts,
  'totalWeeks': instance.totalWeeks,
  'averageWorkoutsPerWeek': instance.averageWorkoutsPerWeek,
  'currentStreak': instance.currentStreak,
  'longestStreak': instance.longestStreak,
  'adherenceRate': instance.adherenceRate,
  'weeklyData': instance.weeklyData.map((e) => e.toJson()).toList(),
  'mostActiveDay': instance.mostActiveDay,
  'leastActiveDay': instance.leastActiveDay,
  'averageDuration': instance.averageDuration,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
};

_$WeeklyConsistencyImpl _$$WeeklyConsistencyImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$WeeklyConsistencyImpl', json, ($checkedConvert) {
  final val = _$WeeklyConsistencyImpl(
    weekStart: $checkedConvert('weekStart', (v) => DateTime.parse(v as String)),
    workoutsCompleted: $checkedConvert(
      'workoutsCompleted',
      (v) => (v as num).toInt(),
    ),
    workoutsPlanned: $checkedConvert(
      'workoutsPlanned',
      (v) => (v as num).toInt(),
    ),
    dailyStatus: $checkedConvert(
      'dailyStatus',
      (v) => (v as List<dynamic>).map((e) => e as bool).toList(),
    ),
    totalVolume: $checkedConvert('totalVolume', (v) => (v as num).toDouble()),
    adherenceRate: $checkedConvert(
      'adherenceRate',
      (v) => (v as num).toDouble(),
    ),
  );
  return val;
});

Map<String, dynamic> _$$WeeklyConsistencyImplToJson(
  _$WeeklyConsistencyImpl instance,
) => <String, dynamic>{
  'weekStart': instance.weekStart.toIso8601String(),
  'workoutsCompleted': instance.workoutsCompleted,
  'workoutsPlanned': instance.workoutsPlanned,
  'dailyStatus': instance.dailyStatus,
  'totalVolume': instance.totalVolume,
  'adherenceRate': instance.adherenceRate,
};
