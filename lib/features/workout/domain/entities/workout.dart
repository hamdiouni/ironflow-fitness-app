import 'package:freezed_annotation/freezed_annotation.dart';
import 'exercise.dart';

part 'workout.freezed.dart';

/// Represents a completed or in-progress workout session.
///
/// [id] is a UUID uniquely identifying the session.
/// [date] is when the session was started.
/// [exercises] is the ordered list of exercises performed.
/// [duration] is the total elapsed time of the session.
/// [totalVolume] is the sum of (weight × reps) across all sets.
/// [caloriesBurned] is the estimated or manually entered calories burned.
@freezed
class Workout with _$Workout {
  const factory Workout({
    required String id,
    required DateTime date,
    required List<Exercise> exercises,
    required Duration duration,
    required double totalVolume,
    @Default(0) double caloriesBurned,
  }) = _Workout;
}
