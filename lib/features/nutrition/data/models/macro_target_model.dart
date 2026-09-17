import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/macro_target.dart';

part 'macro_target_model.freezed.dart';
part 'macro_target_model.g.dart';

@freezed
class MacroTargetModel with _$MacroTargetModel {
  const factory MacroTargetModel({
    required double protein,
    required double carbs,
    required double fats,
  }) = _MacroTargetModel;

  factory MacroTargetModel.fromJson(Map<String, dynamic> json) =>
      _$MacroTargetModelFromJson(json);

  factory MacroTargetModel.fromEntity(MacroTarget target) {
    return MacroTargetModel(
      protein: target.protein,
      carbs: target.carbs,
      fats: target.fats,
    );
  }
}

extension MacroTargetModelX on MacroTargetModel {
  MacroTarget toEntity() {
    return MacroTarget(
      protein: protein,
      carbs: carbs,
      fats: fats,
    );
  }
}
