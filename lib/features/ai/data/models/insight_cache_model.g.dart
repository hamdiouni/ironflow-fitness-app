// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_cache_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InsightCacheModelImpl _$$InsightCacheModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$InsightCacheModelImpl', json, ($checkedConvert) {
  final val = _$InsightCacheModelImpl(
    context: $checkedConvert('context', (v) => v as String),
    insights: $checkedConvert(
      'insights',
      (v) => (v as List<dynamic>)
          .map((e) => InsightModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
    cachedAtMillis: $checkedConvert(
      'cachedAtMillis',
      (v) => (v as num).toInt(),
    ),
    dataTimestampsMillis: $checkedConvert(
      'dataTimestampsMillis',
      (v) =>
          (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    ),
  );
  return val;
});

Map<String, dynamic> _$$InsightCacheModelImplToJson(
  _$InsightCacheModelImpl instance,
) => <String, dynamic>{
  'context': instance.context,
  'insights': instance.insights.map((e) => e.toJson()).toList(),
  'cachedAtMillis': instance.cachedAtMillis,
  'dataTimestampsMillis': instance.dataTimestampsMillis,
};
