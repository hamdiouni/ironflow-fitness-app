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
    // Persisted since Phase 0 (DATABASE_AND_SYNC_AUDIT F-05): these used to
    // be dropped by fromEntity/toEntity, so planned sets/reps were lost on
    // every save/load round-trip. Nullable = old stored JSON still loads.
    // Requires `dart run build_runner build` to regenerate the model code.
    int? suggestedReps,
    int? suggestedSets,
  }) = _ExerciseModel;

  factory ExerciseModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseModelFromJson(json);

  factory ExerciseModel.fromEntity(Exercise exercise) {
    return ExerciseModel(
      id: exercise.id,
      name: exercise.name,
      type: exercise.type.name,
      sets: exercise.sets.map(SetEntryModel.fromEntity).toList(),
      suggestedReps: exercise.suggestedReps,
      suggestedSets: exercise.suggestedSets,
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
      suggestedReps: suggestedReps,
      suggestedSets: suggestedSets,
    );
  }
}
