// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insight_cache.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InsightCacheImpl _$$InsightCacheImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$InsightCacheImpl', json, ($checkedConvert) {
      final val = _$InsightCacheImpl(
        context: $checkedConvert(
          'context',
          (v) => $enumDecode(_$InsightContextEnumMap, v),
        ),
        insights: $checkedConvert(
          'insights',
          (v) => (v as List<dynamic>)
              .map((e) => Insight.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        cachedAt: $checkedConvert(
          'cachedAt',
          (v) => DateTime.parse(v as String),
        ),
        dataTimestamps: $checkedConvert(
          'dataTimestamps',
          (v) => (v as Map<String, dynamic>).map(
            (k, e) => MapEntry(k, DateTime.parse(e as String)),
          ),
        ),
      );
      return val;
    });

Map<String, dynamic> _$$InsightCacheImplToJson(_$InsightCacheImpl instance) =>
    <String, dynamic>{
      'context': _$InsightContextEnumMap[instance.context]!,
      'insights': instance.insights.map((e) => e.toJson()).toList(),
      'cachedAt': instance.cachedAt.toIso8601String(),
      'dataTimestamps': instance.dataTimestamps.map(
        (k, e) => MapEntry(k, e.toIso8601String()),
      ),
    };

const _$InsightContextEnumMap = {
  InsightContext.home: 'home',
  InsightContext.workout: 'workout',
  InsightContext.nutrition: 'nutrition',
  InsightContext.profile: 'profile',
};
