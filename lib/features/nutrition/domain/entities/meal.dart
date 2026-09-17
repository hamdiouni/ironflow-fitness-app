import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/validators.dart';

part 'meal.freezed.dart';

/// Macronutrients for a meal
@freezed
class MealMacros with _$MealMacros {
  const factory MealMacros({
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
  }) = _MealMacros;
}

/// Micronutrients for a meal
@freezed
class MealMicros with _$MealMicros {
  const factory MealMicros({
    required double fiber,
    required double sugar,
    required double sodium,
    required double potassium,
  }) = _MealMicros;
}

/// Vitamins for a meal
@freezed
class MealVitamins with _$MealVitamins {
  const factory MealVitamins({
    required double vitaminA,
    required double vitaminB,
    required double vitaminC,
    required double vitaminD,
    required double vitaminE,
  }) = _MealVitamins;
}

/// Minerals for a meal
@freezed
class MealMinerals with _$MealMinerals {
  const factory MealMinerals({
    required double calcium,
    required double iron,
    required double magnesium,
    required double zinc,
  }) = _MealMinerals;
}

/// Represents a logged meal entry with complete nutritional information.
///
/// Use [Meal.create] to construct a validated instance. The default
/// constructor is available for deserialization only.
///
/// [id] is a UUID uniquely identifying this meal.
/// [name] is the human-readable meal name.
/// [macros], [micros], [vitamins], [minerals] contain complete nutritional data.
/// [timestamp] records when the meal was logged.
@freezed
class Meal with _$Meal {
  const factory Meal({
    required String id,
    required String name,
    required MealMacros macros,
    required MealMicros micros,
    required MealVitamins vitamins,
    required MealMinerals minerals,
    required DateTime timestamp,
  }) = _Meal;

  const Meal._();

  /// Factory constructor with validation
  factory Meal.create({
    required String name,
    required MealMacros macros,
    required MealMicros micros,
    required MealVitamins vitamins,
    required MealMinerals minerals,
  }) {
    if (!Validators.isValidMacro(macros.protein) ||
        !Validators.isValidMacro(macros.carbs) ||
        !Validators.isValidMacro(macros.fats)) {
      throw InvalidMacroException();
    }

    return Meal(
      id: const Uuid().v4(),
      name: name,
      macros: macros,
      micros: micros,
      vitamins: vitamins,
      minerals: minerals,
      timestamp: DateTime.now(),
    );
  }

  /// Convenience getters for backward compatibility
  double get calories => macros.calories;
  double get protein => macros.protein;
  double get carbs => macros.carbs;
  double get fats => macros.fats;
}
