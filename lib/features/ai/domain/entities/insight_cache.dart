import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';

part 'insight_cache.freezed.dart';
part 'insight_cache.g.dart';

/// Represents cached insights for a specific context
@freezed
class InsightCache with _$InsightCache {
  const factory InsightCache({
    required InsightContext context,
    required List<Insight> insights,
    required DateTime cachedAt,
    required Map<String, DateTime> dataTimestamps,
  }) = _InsightCache;

  factory InsightCache.fromJson(Map<String, dynamic> json) =>
      _$InsightCacheFromJson(json);
}
