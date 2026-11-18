// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_tracking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeightTrackingImpl _$$WeightTrackingImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$WeightTrackingImpl', json, ($checkedConvert) {
  final val = _$WeightTrackingImpl(
    userId: $checkedConvert('userId', (v) => v as String),
    measurements: $checkedConvert(
      'measurements',
      (v) => (v as List<dynamic>)
          .map((e) => WeightMeasurement.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    currentWeight: $checkedConvert(
      'currentWeight',
      (v) => (v as num).toDouble(),
    ),
    startingWeight: $checkedConvert(
      'startingWeight',
      (v) => (v as num).toDouble(),
    ),
    goalWeight: $checkedConvert('goalWeight', (v) => (v as num).toDouble()),
    totalChange: $checkedConvert('totalChange', (v) => (v as num).toDouble()),
    averageWeeklyChange: $checkedConvert(
      'averageWeeklyChange',
      (v) => (v as num).toDouble(),
    ),
    projectedGoalDate: $checkedConvert(
      'projectedGoalDate',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    startDate: $checkedConvert('startDate', (v) => DateTime.parse(v as String)),
    endDate: $checkedConvert('endDate', (v) => DateTime.parse(v as String)),
  );
  return val;
});

Map<String, dynamic> _$$WeightTrackingImplToJson(
  _$WeightTrackingImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'measurements': instance.measurements.map((e) => e.toJson()).toList(),
  'currentWeight': instance.currentWeight,
  'startingWeight': instance.startingWeight,
  'goalWeight': instance.goalWeight,
  'totalChange': instance.totalChange,
  'averageWeeklyChange': instance.averageWeeklyChange,
  'projectedGoalDate': instance.projectedGoalDate?.toIso8601String(),
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
};

_$WeightMeasurementImpl _$$WeightMeasurementImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$WeightMeasurementImpl', json, ($checkedConvert) {
  final val = _$WeightMeasurementImpl(
    date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
    weight: $checkedConvert('weight', (v) => (v as num).toDouble()),
    note: $checkedConvert('note', (v) => v as String?),
    bodyFatPercentage: $checkedConvert(
      'bodyFatPercentage',
      (v) => (v as num?)?.toDouble(),
    ),
    muscleMass: $checkedConvert('muscleMass', (v) => (v as num?)?.toDouble()),
  );
  return val;
});

Map<String, dynamic> _$$WeightMeasurementImplToJson(
  _$WeightMeasurementImpl instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'weight': instance.weight,
  'note': instance.note,
  'bodyFatPercentage': instance.bodyFatPercentage,
  'muscleMass': instance.muscleMass,
};
