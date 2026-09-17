import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/workout.dart';
import 'exercise_model.dart';

part 'workout_model.freezed.dart';
part 'workout_model.g.dart';

@freezed
class WorkoutModel with _$WorkoutModel {
  const factory WorkoutModel({
    required String id,
    required String date,
    required List<ExerciseModel> exercises,
    required int durationSeconds,
    required double totalVolume,
    @Default(0) double caloriesBurned,
  }) = _WorkoutModel;

  factory WorkoutModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutModelFromJson(json);

  factory WorkoutModel.fromEntity(Workout workout) {
    return WorkoutModel(
      id: workout.id,
      date: workout.date.toIso8601String(),
      exercises: workout.exercises.map(ExerciseModel.fromEntity).toList(),
      durationSeconds: workout.duration.inSeconds,
      totalVolume: workout.totalVolume,
      caloriesBurned: workout.caloriesBurned,
    );
  }
}

extension WorkoutModelX on WorkoutModel {
  Workout toEntity() {
    return Workout(
      id: id,
      date: DateTime.parse(date),
      exercises: exercises.map((e) => e.toEntity()).toList(),
      duration: Duration(seconds: durationSeconds),
      totalVolume: totalVolume,
      caloriesBurned: caloriesBurned,
    );
  }
}
