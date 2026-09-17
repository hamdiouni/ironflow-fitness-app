import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_type.dart';
import 'set_entry_model.dart';

part 'exercise_model.freezed.dart';
part 'exercise_model.g.dart';

@freezed
class ExerciseModel with _$ExerciseModel {
  const factory ExerciseModel({
    required String id,
    required String name,
    required String type,
    required List<SetEntryModel> sets,
  }) = _ExerciseModel;

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);

  factory ExerciseModel.fromEntity(Exercise exercise) {
    return ExerciseModel(
      id: exercise.id,
      name: exercise.name,
      type: exercise.type.name,
      sets: exercise.sets.map(SetEntryModel.fromEntity).toList(),
    );
  }
}

extension ExerciseModelX on ExerciseModel {
  Exercise toEntity() {
    return Exercise(
      id: id,
      name: name,
      type: ExerciseType.values.firstWhere((e) => e.name == type),
      sets: sets.map((s) => s.toEntity()).toList(),
    );
  }
}
