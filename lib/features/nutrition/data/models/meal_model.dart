import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/meal.dart';

part 'meal_model.freezed.dart';
part 'meal_model.g.dart';

@freezed
class MealMacrosModel with _$MealMacrosModel {
  const factory MealMacrosModel({
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
  }) = _MealMacrosModel;

  factory MealMacrosModel.fromJson(Map<String, dynamic> json) =>
      _$MealMacrosModelFromJson(json);

  factory MealMacrosModel.fromEntity(MealMacros entity) {
    return MealMacrosModel(
      calories: entity.calories,
      protein: entity.protein,
      carbs: entity.carbs,
      fats: entity.fats,
    );
  }
}

extension MealMacrosModelX on MealMacrosModel {
  MealMacros toEntity() {
    return MealMacros(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
    );
  }
}

@freezed
class MealMicrosModel with _$MealMicrosModel {
  const factory MealMicrosModel({
    required double fiber,
    required double sugar,
    required double sodium,
    required double potassium,
  }) = _MealMicrosModel;

  factory MealMicrosModel.fromJson(Map<String, dynamic> json) =>
      _$MealMicrosModelFromJson(json);

  factory MealMicrosModel.fromEntity(MealMicros entity) {
    return MealMicrosModel(
      fiber: entity.fiber,
      sugar: entity.sugar,
      sodium: entity.sodium,
      potassium: entity.potassium,
    );
  }
}

extension MealMicrosModelX on MealMicrosModel {
  MealMicros toEntity() {
    return MealMicros(
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      potassium: potassium,
    );
  }
}

@freezed
class MealVitaminsModel with _$MealVitaminsModel {
  const factory MealVitaminsModel({
    required double vitaminA,
    required double vitaminB,
    required double vitaminC,
    required double vitaminD,
    required double vitaminE,
  }) = _MealVitaminsModel;

  factory MealVitaminsModel.fromJson(Map<String, dynamic> json) =>
      _$MealVitaminsModelFromJson(json);

  factory MealVitaminsModel.fromEntity(MealVitamins entity) {
    return MealVitaminsModel(
      vitaminA: entity.vitaminA,
      vitaminB: entity.vitaminB,
      vitaminC: entity.vitaminC,
      vitaminD: entity.vitaminD,
      vitaminE: entity.vitaminE,
    );
  }
}

extension MealVitaminsModelX on MealVitaminsModel {
  MealVitamins toEntity() {
    return MealVitamins(
      vitaminA: vitaminA,
      vitaminB: vitaminB,
      vitaminC: vitaminC,
      vitaminD: vitaminD,
      vitaminE: vitaminE,
    );
  }
}

@freezed
class MealMineralsModel with _$MealMineralsModel {
  const factory MealMineralsModel({
    required double calcium,
    required double iron,
    required double magnesium,
    required double zinc,
  }) = _MealMineralsModel;

  factory MealMineralsModel.fromJson(Map<String, dynamic> json) =>
      _$MealMineralsModelFromJson(json);

  factory MealMineralsModel.fromEntity(MealMinerals entity) {
    return MealMineralsModel(
      calcium: entity.calcium,
      iron: entity.iron,
      magnesium: entity.magnesium,
      zinc: entity.zinc,
    );
  }
}

extension MealMineralsModelX on MealMineralsModel {
  MealMinerals toEntity() {
    return MealMinerals(
      calcium: calcium,
      iron: iron,
      magnesium: magnesium,
      zinc: zinc,
    );
  }
}

@freezed
class MealModel with _$MealModel {
  const factory MealModel({
    required String id,
    required String name,
    required MealMacrosModel macros,
    required MealMicrosModel micros,
    required MealVitaminsModel vitamins,
    required MealMineralsModel minerals,
    required String timestamp,
  }) = _MealModel;

  factory MealModel.fromJson(Map<String, dynamic> json) =>
      _$MealModelFromJson(json);

  factory MealModel.fromEntity(Meal meal) {
    return MealModel(
      id: meal.id,
      name: meal.name,
      macros: MealMacrosModel.fromEntity(meal.macros),
      micros: MealMicrosModel.fromEntity(meal.micros),
      vitamins: MealVitaminsModel.fromEntity(meal.vitamins),
      minerals: MealMineralsModel.fromEntity(meal.minerals),
      timestamp: meal.timestamp.toIso8601String(),
    );
  }
}

extension MealModelX on MealModel {
  Meal toEntity() {
    return Meal(
      id: id,
      name: name,
      macros: macros.toEntity(),
      micros: micros.toEntity(),
      vitamins: vitamins.toEntity(),
      minerals: minerals.toEntity(),
      timestamp: DateTime.parse(timestamp),
    );
  }
}
