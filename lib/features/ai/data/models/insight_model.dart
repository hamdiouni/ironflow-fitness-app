import 'package:hive/hive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/insight.dart';

part 'insight_model.freezed.dart';
part 'insight_model.g.dart';

/// Hive model for storing Insight entities locally
///
/// **Requirements:**
/// - 11.3: Store insights in Hive for offline access
/// - 15.3: Use typeId: 11 for InsightModel
@HiveType(typeId: 11)
@freezed
class InsightModel with _$InsightModel {
  const factory InsightModel({
    @HiveField(0) required String id,
    @HiveField(1) required int context, // Store as int for Hive compatibility
    @HiveField(2) required String title,
    @HiveField(3) required String message,
    @HiveField(4) required String icon,
    @HiveField(5) required int priority, // Store as int for Hive compatibility
    @HiveField(6) required int generatedAtMillis, // Store as milliseconds since epoch
    @HiveField(7) @Default({}) Map<String, dynamic> metadata,
  }) = _InsightModel;

  factory InsightModel.fromJson(Map<String, dynamic> json) =>
      _$InsightModelFromJson(json);

  /// Create InsightModel from domain entity
  factory InsightModel.fromDomain(Insight insight) {
    return InsightModel(
      id: insight.id,
      context: insight.context.index,
      title: insight.title,
      message: insight.message,
      icon: insight.icon,
      priority: insight.priority.index,
      generatedAtMillis: insight.generatedAt.millisecondsSinceEpoch,
      metadata: insight.metadata,
    );
  }
}

extension InsightModelX on InsightModel {
  /// Convert to domain entity
  Insight toDomain() {
    return Insight(
      id: id,
      context: InsightContext.values[context],
      title: title,
      message: message,
      icon: icon,
      priority: InsightPriority.values[priority],
      generatedAt: DateTime.fromMillisecondsSinceEpoch(generatedAtMillis),
      metadata: metadata,
    );
  }
}