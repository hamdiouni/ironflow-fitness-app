import 'package:freezed_annotation/freezed_annotation.dart';

part 'insight.freezed.dart';
part 'insight.g.dart';

/// Context in which an insight is generated
enum InsightContext {
  home,
  workout,
  nutrition,
  profile,
}

/// Priority level of an insight
enum InsightPriority {
  high,    // Critical actions (e.g., 3+ days without workout)
  medium,  // Important recommendations (e.g., protein deficit)
  low,     // General encouragement and tips
}

/// Represents a single AI-generated coaching insight
@freezed
class Insight with _$Insight {
  const factory Insight({
    required String id,
    required InsightContext context,
    required String title,
    required String message,
    required String icon,
    required InsightPriority priority,
    required DateTime generatedAt,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Insight;

  factory Insight.fromJson(Map<String, dynamic> json) =>
      _$InsightFromJson(json);
}
