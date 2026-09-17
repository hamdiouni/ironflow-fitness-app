import 'package:hive/hive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/insight_cache.dart';
import '../../domain/entities/insight.dart';
import 'insight_model.dart';

part 'insight_cache_model.freezed.dart';
part 'insight_cache_model.g.dart';

/// Hive model for storing InsightCache entities locally
///
/// **Requirements:**
/// - 11.3: Store insight caches in Hive for offline access
/// - 15.3: Use typeId: 10 for InsightCacheModel
/// - Store timestamps as milliseconds since epoch for Hive compatibility
@HiveType(typeId: 10)
@freezed
class InsightCacheModel with _$InsightCacheModel {
  const factory InsightCacheModel({
    @HiveField(0) required String context, // Store context as string
    @HiveField(1) required List<InsightModel> insights,
    @HiveField(2) required int cachedAtMillis, // Store as milliseconds since epoch
    @HiveField(3) @Default({}) Map<String, int> dataTimestampsMillis, // Store timestamps as milliseconds
  }) = _InsightCacheModel;

  factory InsightCacheModel.fromJson(Map<String, dynamic> json) =>
      _$InsightCacheModelFromJson(json);

  /// Create InsightCacheModel from domain entity
  factory InsightCacheModel.fromDomain(InsightCache cache) {
    return InsightCacheModel(
      context: cache.context.name,
      insights: cache.insights.map((insight) => InsightModel.fromDomain(insight)).toList(),
      cachedAtMillis: cache.cachedAt.millisecondsSinceEpoch,
      dataTimestampsMillis: cache.dataTimestamps.map(
        (key, value) => MapEntry(key, value.millisecondsSinceEpoch),
      ),
    );
  }
}

extension InsightCacheModelX on InsightCacheModel {
  /// Convert to domain entity
  InsightCache toDomain() {
    return InsightCache(
      context: InsightContext.values.firstWhere((e) => e.name == context),
      insights: insights.map((model) => model.toDomain()).toList(),
      cachedAt: DateTime.fromMillisecondsSinceEpoch(cachedAtMillis),
      dataTimestamps: dataTimestampsMillis.map(
        (key, value) => MapEntry(key, DateTime.fromMillisecondsSinceEpoch(value)),
      ),
    );
  }
}