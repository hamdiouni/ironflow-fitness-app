import 'package:freezed_annotation/freezed_annotation.dart';
import 'meal_category.dart';

part 'meal_suggestion.freezed.dart';

/// A rule-based meal suggestion that fits within the user's remaining macro budget.
///
/// [calories] is derived from macro values using standard caloric densities
/// (protein/carbs = 4 kcal/g, fats = 9 kcal/g).
@freezed
class MealSuggestion with _$MealSuggestion {
  const MealSuggestion._();

  const factory MealSuggestion({
    required String name,
    required double protein,
    required double carbs,
    required double fats,
    required MealCategory category,
  }) = _MealSuggestion;

  /// Calories: protein and carbs = 4 kcal/g, fats = 9 kcal/g
  double get calories => (protein * 4) + (carbs * 4) + (fats * 9);
}
