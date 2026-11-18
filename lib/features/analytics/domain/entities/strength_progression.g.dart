// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'strength_progression.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StrengthProgressionImpl _$$StrengthProgressionImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$StrengthProgressionImpl', json, ($checkedConvert) {
  final val = _$StrengthProgressionImpl(
    exerciseId: $checkedConvert('exerciseId', (v) => v as String),
    exerciseName: $checkedConvert('exerciseName', (v) => v as String),
    muscleGroup: $checkedConvert('muscleGroup', (v) => v as String),
    dataPoints: $checkedConvert(
      'dataPoints',
      (v) => (v as List<dynamic>)
          .map((e) => StrengthDataPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    currentOneRepMax: $checkedConvert(
      'currentOneRepMax',
      (v) => (v as num).toDouble(),
    ),
    previousOneRepMax: $checkedConvert(
      'previousOneRepMax',
      (v) => (v as num).toDouble(),
    ),
    percentageChange: $checkedConvert(
      'percentageChange',
      (v) => (v as num).toDouble(),
    ),
    totalVolume: $checkedConvert('totalVolume', (v) => (v as num).toDouble()),
    startDate: $checkedConvert('startDate', (v) => DateTime.parse(v as String)),
    endDate: $checkedConvert('endDate', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$$StrengthProgressionImplToJson(
  _$StrengthProgressionImpl instance,
) => <String, dynamic>{
  'exerciseId': instance.exerciseId,
  'exerciseName': instance.exerciseName,
  'muscleGroup': instance.muscleGroup,
  'dataPoints': instance.dataPoints.map((e) => e.toJson()).toList(),
  'currentOneRepMax': instance.currentOneRepMax,
  'previousOneRepMax': instance.previousOneRepMax,
  'percentageChange': instance.percentageChange,
  'totalVolume': instance.totalVolume,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
};

_$StrengthDataPointImpl _$$StrengthDataPointImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$StrengthDataPointImpl', json, ($checkedConvert) {
  final val = _$StrengthDataPointImpl(
    date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
    weight: $checkedConvert('weight', (v) => (v as num).toDouble()),
    reps: $checkedConvert('reps', (v) => (v as num).toInt()),
    sets: $checkedConvert('sets', (v) => (v as num).toInt()),
    volume: $checkedConvert('volume', (v) => (v as num).toDouble()),
    estimatedOneRepMax: $checkedConvert(
      'estimatedOneRepMax',
      (v) => (v as num).toDouble(),
    ),
  );
  return val;
});

Map<String, dynamic> _$$StrengthDataPointImplToJson(
  _$StrengthDataPointImpl instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'weight': instance.weight,
  'reps': instance.reps,
  'sets': instance.sets,
  'volume': instance.volume,
  'estimatedOneRepMax': instance.estimatedOneRepMax,
};
