import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_response.freezed.dart';
part 'ai_response.g.dart';

/// Types of AI responses
enum AIResponseType {
  text,
  suggestion,
  program,
  mealPlan,
  analysis,
  celebration,
}

/// Represents an actionable suggestion from the AI
@freezed
class AISuggestion with _$AISuggestion {
  const factory AISuggestion({
    required String id,
    required String title,
    required String description,
    required String actionType, // 'exercise_swap', 'progression', 'nutrition', etc.
    @Default({}) Map<String, dynamic> payload,
    @Default(0.8) double confidence, // 0.0 - 1.0
  }) = _AISuggestion;

  factory AISuggestion.fromJson(Map<String, dynamic> json) =>
      _$AISuggestionFromJson(json);
}

/// Represents a complete AI response
@freezed
class AIResponse with _$AIResponse {
  const factory AIResponse({
    required String id,
    required AIResponseType type,
    required String text,
    @Default([]) List<AISuggestion> suggestions,
    @Default({}) Map<String, dynamic> data,
    @Default(true) bool isActionable,
  }) = _AIResponse;

  factory AIResponse.fromJson(Map<String, dynamic> json) =>
      _$AIResponseFromJson(json);
}
