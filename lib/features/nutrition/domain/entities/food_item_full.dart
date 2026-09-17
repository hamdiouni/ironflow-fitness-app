import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_item_full.freezed.dart';

/// Macronutrients per 100g
@freezed
class MacrosPer100g with _$MacrosPer100g {
  const factory MacrosPer100g({
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
  }) = _MacrosPer100g;
}

/// Micronutrients per 100g
@freezed
class MicrosPer100g with _$MicrosPer100g {
  const factory MicrosPer100g({
    required double fiber,
    required double sugar,
    required double sodium,
    required double potassium,
  }) = _MicrosPer100g;
}

/// Vitamins per 100g
@freezed
class VitaminsPer100g with _$VitaminsPer100g {
  const factory VitaminsPer100g({
    required double vitaminA,
    required double vitaminB,
    required double vitaminC,
    required double vitaminD,
    required double vitaminE,
  }) = _VitaminsPer100g;
}

/// Minerals per 100g
@freezed
class MineralsPer100g with _$MineralsPer100g {
  const factory MineralsPer100g({
    required double calcium,
    required double iron,
    required double magnesium,
    required double zinc,
  }) = _MineralsPer100g;
}

/// Complete food item with all nutritional data per 100g
///
/// All values are per 100g in the database. Use scaling methods to calculate
/// actual values based on quantity consumed.
@freezed
class FoodItemFull with _$FoodItemFull {
  const factory FoodItemFull({
    required String id,
    required String name,
    required String category,
    required MacrosPer100g macros,
    required MicrosPer100g micros,
    required VitaminsPer100g vitamins,
    required MineralsPer100g minerals,
    required String imageUrl,
    @Default([]) List<String> dietaryTags,
  }) = _FoodItemFull;

  /// Scale macros by quantity in grams
  factory FoodItemFull.scaleMacros(FoodItemFull food, double grams) {
    final factor = grams / 100.0;
    return food.copyWith(
      macros: MacrosPer100g(
        calories: food.macros.calories * factor,
        protein: food.macros.protein * factor,
        carbs: food.macros.carbs * factor,
        fats: food.macros.fats * factor,
      ),
    );
  }

  /// Scale micros by quantity in grams
  factory FoodItemFull.scaleMicros(FoodItemFull food, double grams) {
    final factor = grams / 100.0;
    return food.copyWith(
      micros: MicrosPer100g(
        fiber: food.micros.fiber * factor,
        sugar: food.micros.sugar * factor,
        sodium: food.micros.sodium * factor,
        potassium: food.micros.potassium * factor,
      ),
    );
  }

  /// Scale vitamins by quantity in grams
  factory FoodItemFull.scaleVitamins(FoodItemFull food, double grams) {
    final factor = grams / 100.0;
    return food.copyWith(
      vitamins: VitaminsPer100g(
        vitaminA: food.vitamins.vitaminA * factor,
        vitaminB: food.vitamins.vitaminB * factor,
        vitaminC: food.vitamins.vitaminC * factor,
        vitaminD: food.vitamins.vitaminD * factor,
        vitaminE: food.vitamins.vitaminE * factor,
      ),
    );
  }

  /// Scale minerals by quantity in grams
  factory FoodItemFull.scaleMinerals(FoodItemFull food, double grams) {
    final factor = grams / 100.0;
    return food.copyWith(
      minerals: MineralsPer100g(
        calcium: food.minerals.calcium * factor,
        iron: food.minerals.iron * factor,
        magnesium: food.minerals.magnesium * factor,
        zinc: food.minerals.zinc * factor,
      ),
    );
  }

  /// Scale all nutritional values by quantity in grams
  factory FoodItemFull.scaleAll(FoodItemFull food, double grams) {
    final factor = grams / 100.0;
    return FoodItemFull(
      id: food.id,
      name: food.name,
      category: food.category,
      macros: MacrosPer100g(
        calories: food.macros.calories * factor,
        protein: food.macros.protein * factor,
        carbs: food.macros.carbs * factor,
        fats: food.macros.fats * factor,
      ),
      micros: MicrosPer100g(
        fiber: food.micros.fiber * factor,
        sugar: food.micros.sugar * factor,
        sodium: food.micros.sodium * factor,
        potassium: food.micros.potassium * factor,
      ),
      vitamins: VitaminsPer100g(
        vitaminA: food.vitamins.vitaminA * factor,
        vitaminB: food.vitamins.vitaminB * factor,
        vitaminC: food.vitamins.vitaminC * factor,
        vitaminD: food.vitamins.vitaminD * factor,
        vitaminE: food.vitamins.vitaminE * factor,
      ),
      minerals: MineralsPer100g(
        calcium: food.minerals.calcium * factor,
        iron: food.minerals.iron * factor,
        magnesium: food.minerals.magnesium * factor,
        zinc: food.minerals.zinc * factor,
      ),
      imageUrl: food.imageUrl,
      dietaryTags: food.dietaryTags,
    );
  }
}
