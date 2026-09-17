import 'package:freezed_annotation/freezed_annotation.dart';

part 'progression_suggestion.freezed.dart';

/// Represents a progression suggestion for an exercise.
///
/// Contains the suggested weight and reps for the next session,
/// whether the user is stagnating, and an optional motivational message.
@freezed
class ProgressionSuggestion with _$ProgressionSuggestion {
  const factory ProgressionSuggestion({
    required double suggestedWeight,
    required int suggestedReps,
    required bool isStagnant,
    String? message,
  }) = _ProgressionSuggestion;
}
