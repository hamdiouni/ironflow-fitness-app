import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/set_entry.dart';

part 'set_entry_model.freezed.dart';
part 'set_entry_model.g.dart';

@freezed
class SetEntryModel with _$SetEntryModel {
  const factory SetEntryModel({
    required String id,
    required int reps,
    required double weight,
    int? rpe,
    required String timestamp,
  }) = _SetEntryModel;

  factory SetEntryModel.fromJson(Map<String, dynamic> json) =>
      _$SetEntryModelFromJson(json);

  factory SetEntryModel.fromEntity(SetEntry set) {
    return SetEntryModel(
      id: set.id,
      reps: set.reps,
      weight: set.weight,
      rpe: set.rpe,
      timestamp: set.timestamp.toIso8601String(),
    );
  }
}

extension SetEntryModelX on SetEntryModel {
  SetEntry toEntity() {
    return SetEntry(
      id: id,
      reps: reps,
      weight: weight,
      rpe: rpe,
      timestamp: DateTime.parse(timestamp),
    );
  }
}
