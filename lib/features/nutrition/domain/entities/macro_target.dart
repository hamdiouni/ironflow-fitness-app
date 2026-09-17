import 'package:freezed_annotation/freezed_annotation.dart';

part 'macro_target.freezed.dart';

/// The user's daily macro targets in grams.
///
/// [totalCalories] is derived from the standard caloric densities:
/// protein and carbs contribute 4 kcal/g, fats contribute 9 kcal/g.
@freezed
class MacroTarget with _$MacroTarget {
  const MacroTarget._();

  const factory MacroTarget({
    required double protein,
    required double carbs,
    required double fats,
  }) = _MacroTarget;

  /// Total calories: protein and carbs = 4 kcal/g, fats = 9 kcal/g
  double get totalCalories => (protein * 4) + (carbs * 4) + (fats * 9);
}
