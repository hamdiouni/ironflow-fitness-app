import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/food_item_full.dart';

part 'food_item_full_model.freezed.dart';
part 'food_item_full_model.g.dart';

/// Data model for MacrosPer100g with JSON serialization
@freezed
class MacrosPer100gModel with _$MacrosPer100gModel {
  const factory MacrosPer100gModel({
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
  }) = _MacrosPer100gModel;

  factory MacrosPer100gModel.fromJson(Map<String, dynamic> json) =>
      _$MacrosPer100gModelFromJson(json);

  factory MacrosPer100gModel.fromEntity(MacrosPer100g entity) {
    return MacrosPer100gModel(
      calories: entity.calories,
      protein: entity.protein,
      carbs: entity.carbs,
      fats: entity.fats,
    );
  }
}

extension MacrosPer100gModelX on MacrosPer100gModel {
  MacrosPer100g toEntity() {
    return MacrosPer100g(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
    );
  }
}

/// Data model for MicrosPer100g with JSON serialization
@freezed
class MicrosPer100gModel with _$MicrosPer100gModel {
  const factory MicrosPer100gModel({
    required double fiber,
    required double sugar,
    required double sodium,
    required double potassium,
  }) = _MicrosPer100gModel;

  factory MicrosPer100gModel.fromJson(Map<String, dynamic> json) =>
      _$MicrosPer100gModelFromJson(json);

  factory MicrosPer100gModel.fromEntity(MicrosPer100g entity) {
    return MicrosPer100gModel(
      fiber: entity.fiber,
      sugar: entity.sugar,
      sodium: entity.sodium,
      potassium: entity.potassium,
    );
  }
}

extension MicrosPer100gModelX on MicrosPer100gModel {
  MicrosPer100g toEntity() {
    return MicrosPer100g(
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      potassium: potassium,
    );
  }
}

/// Data model for VitaminsPer100g with JSON serialization
@freezed
class VitaminsPer100gModel with _$VitaminsPer100gModel {
  const factory VitaminsPer100gModel({
    required double vitaminA,
    required double vitaminB,
    required double vitaminC,
    required double vitaminD,
    required double vitaminE,
  }) = _VitaminsPer100gModel;

  factory VitaminsPer100gModel.fromJson(Map<String, dynamic> json) =>
      _$VitaminsPer100gModelFromJson(json);

  factory VitaminsPer100gModel.fromEntity(VitaminsPer100g entity) {
    return VitaminsPer100gModel(
      vitaminA: entity.vitaminA,
      vitaminB: entity.vitaminB,
      vitaminC: entity.vitaminC,
      vitaminD: entity.vitaminD,
      vitaminE: entity.vitaminE,
    );
  }
}

extension VitaminsPer100gModelX on VitaminsPer100gModel {
  VitaminsPer100g toEntity() {
    return VitaminsPer100g(
      vitaminA: vitaminA,
      vitaminB: vitaminB,
      vitaminC: vitaminC,
      vitaminD: vitaminD,
      vitaminE: vitaminE,
    );
  }
}

/// Data model for MineralsPer100g with JSON serialization
@freezed
class MineralsPer100gModel with _$MineralsPer100gModel {
  const factory MineralsPer100gModel({
    required double calcium,
    required double iron,
    required double magnesium,
    required double zinc,
  }) = _MineralsPer100gModel;

  factory MineralsPer100gModel.fromJson(Map<String, dynamic> json) =>
      _$MineralsPer100gModelFromJson(json);

  factory MineralsPer100gModel.fromEntity(MineralsPer100g entity) {
    return MineralsPer100gModel(
      calcium: entity.calcium,
      iron: entity.iron,
      magnesium: entity.magnesium,
      zinc: entity.zinc,
    );
  }
}

extension MineralsPer100gModelX on MineralsPer100gModel {
  MineralsPer100g toEntity() {
    return MineralsPer100g(
      calcium: calcium,
      iron: iron,
      magnesium: magnesium,
      zinc: zinc,
    );
  }
}

/// Data model for FoodItemFull with JSON serialization
@freezed
class FoodItemFullModel with _$FoodItemFullModel {
  const factory FoodItemFullModel({
    required String id,
    required String name,
    required String category,
    required MacrosPer100gModel macros,
    required MicrosPer100gModel micros,
    required VitaminsPer100gModel vitamins,
    required MineralsPer100gModel minerals,
    required String imageUrl,
    @Default([]) List<String> dietaryTags,
  }) = _FoodItemFullModel;

  factory FoodItemFullModel.fromJson(Map<String, dynamic> json) =>
      _$FoodItemFullModelFromJson(json);

  factory FoodItemFullModel.fromEntity(FoodItemFull entity) {
    return FoodItemFullModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      macros: MacrosPer100gModel.fromEntity(entity.macros),
      micros: MicrosPer100gModel.fromEntity(entity.micros),
      vitamins: VitaminsPer100gModel.fromEntity(entity.vitamins),
      minerals: MineralsPer100gModel.fromEntity(entity.minerals),
      imageUrl: entity.imageUrl,
      dietaryTags: entity.dietaryTags,
    );
  }
}

extension FoodItemFullModelX on FoodItemFullModel {
  FoodItemFull toEntity() {
    return FoodItemFull(
      id: id,
      name: name,
      category: category,
      macros: macros.toEntity(),
      micros: micros.toEntity(),
      vitamins: vitamins.toEntity(),
      minerals: minerals.toEntity(),
      imageUrl: imageUrl,
      dietaryTags: dietaryTags,
    );
  }
}
