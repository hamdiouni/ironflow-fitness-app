import 'package:freezed_annotation/freezed_annotation.dart';
import 'exercise_type.dart';
import 'set_entry.dart';

part 'exercise.freezed.dart';

/// Represents a single exercise within a workout session.
///
/// [id] is a UUID uniquely identifying this exercise entry.
/// [name] is the human-readable exercise name (e.g. "Bench Press").
/// [type] classifies the exercise as strength, cardio, or flexibility.
/// [sets] is the ordered list of sets performed for this exercise.
@freezed
class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String name,
    required ExerciseType type,
    required List<SetEntry> sets,
    int? suggestedReps,
    int? suggestedSets,
  }) = _Exercise;
}
