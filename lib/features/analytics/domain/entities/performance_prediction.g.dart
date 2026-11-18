// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_prediction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PerformancePredictionImpl _$$PerformancePredictionImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$PerformancePredictionImpl', json, ($checkedConvert) {
  final val = _$PerformancePredictionImpl(
    userId: $checkedConvert('userId', (v) => v as String),
    exercisePredictions: $checkedConvert(
      'exercisePredictions',
      (v) => (v as List<dynamic>)
          .map((e) => ExercisePrediction.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    overallStrength: $checkedConvert(
      'overallStrength',
      (v) => OverallPrediction.fromJson(v as Map<String, dynamic>),
    ),
    weightGoal: $checkedConvert(
      'weightGoal',
      (v) => v == null
          ? null
          : OverallPrediction.fromJson(v as Map<String, dynamic>),
    ),
    consistency: $checkedConvert(
      'consistency',
      (v) => OverallPrediction.fromJson(v as Map<String, dynamic>),
    ),
    confidenceLevel: $checkedConvert(
      'confidenceLevel',
      (v) => (v as num).toDouble(),
    ),
    generatedAt: $checkedConvert(
      'generatedAt',
      (v) => DateTime.parse(v as String),
    ),
    predictionDays: $checkedConvert(
      'predictionDays',
      (v) => (v as num).toInt(),
    ),
  );
  return val;
});

Map<String, dynamic> _$$PerformancePredictionImplToJson(
  _$PerformancePredictionImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'exercisePredictions': instance.exercisePredictions
      .map((e) => e.toJson())
      .toList(),
  'overallStrength': instance.overallStrength.toJson(),
  'weightGoal': instance.weightGoal?.toJson(),
  'consistency': instance.consistency.toJson(),
  'confidenceLevel': instance.confidenceLevel,
  'generatedAt': instance.generatedAt.toIso8601String(),
  'predictionDays': instance.predictionDays,
};

_$ExercisePredictionImpl _$$ExercisePredictionImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$ExercisePredictionImpl', json, ($checkedConvert) {
  final val = _$ExercisePredictionImpl(
    exerciseId: $checkedConvert('exerciseId', (v) => v as String),
    exerciseName: $checkedConvert('exerciseName', (v) => v as String),
    currentOneRepMax: $checkedConvert(
      'currentOneRepMax',
      (v) => (v as num).toDouble(),
    ),
    predictedOneRepMax: $checkedConvert(
      'predictedOneRepMax',
      (v) => (v as num).toDouble(),
    ),
    improvementPercentage: $checkedConvert(
      'improvementPercentage',
      (v) => (v as num).toDouble(),
    ),
    trainingRecommendation: $checkedConvert(
      'trainingRecommendation',
      (v) => v as String,
    ),
    confidence: $checkedConvert('confidence', (v) => (v as num).toDouble()),
    dataPointsUsed: $checkedConvert(
      'dataPointsUsed',
      (v) => (v as num).toInt(),
    ),
  );
  return val;
});

Map<String, dynamic> _$$ExercisePredictionImplToJson(
  _$ExercisePredictionImpl instance,
) => <String, dynamic>{
  'exerciseId': instance.exerciseId,
  'exerciseName': instance.exerciseName,
  'currentOneRepMax': instance.currentOneRepMax,
  'predictedOneRepMax': instance.predictedOneRepMax,
  'improvementPercentage': instance.improvementPercentage,
  'trainingRecommendation': instance.trainingRecommendation,
  'confidence': instance.confidence,
  'dataPointsUsed': instance.dataPointsUsed,
};

_$OverallPredictionImpl _$$OverallPredictionImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$OverallPredictionImpl', json, ($checkedConvert) {
  final val = _$OverallPredictionImpl(
    currentValue: $checkedConvert('currentValue', (v) => (v as num).toDouble()),
    predictedValue: $checkedConvert(
      'predictedValue',
      (v) => (v as num).toDouble(),
    ),
    change: $checkedConvert('change', (v) => (v as num).toDouble()),
    percentageChange: $checkedConvert(
      'percentageChange',
      (v) => (v as num).toDouble(),
    ),
    trend: $checkedConvert(
      'trend',
      (v) => $enumDecode(_$PredictionTrendEnumMap, v),
    ),
    recommendation: $checkedConvert('recommendation', (v) => v as String),
    confidence: $checkedConvert('confidence', (v) => (v as num).toDouble()),
  );
  return val;
});

Map<String, dynamic> _$$OverallPredictionImplToJson(
  _$OverallPredictionImpl instance,
) => <String, dynamic>{
  'currentValue': instance.currentValue,
  'predictedValue': instance.predictedValue,
  'change': instance.change,
  'percentageChange': instance.percentageChange,
  'trend': _$PredictionTrendEnumMap[instance.trend]!,
  'recommendation': instance.recommendation,
  'confidence': instance.confidence,
};

const _$PredictionTrendEnumMap = {
  PredictionTrend.strongIncrease: 'strongIncrease',
  PredictionTrend.increase: 'increase',
  PredictionTrend.stable: 'stable',
  PredictionTrend.decrease: 'decrease',
  PredictionTrend.strongDecrease: 'strongDecrease',
};
