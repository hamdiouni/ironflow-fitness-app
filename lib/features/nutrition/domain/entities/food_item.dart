/// A structured food item from the preloaded food database.
///
/// All macro values are per 100g. Use [FoodItem.macrosForGrams] to calculate
/// actual macros based on the quantity the user inputs.
class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.imageUrl,
    this.tags = const [],
  });

  final String id;
  final String name;
  final FoodCategory category;

  /// Calories per 100g
  final double caloriesPer100g;

  /// Protein in grams per 100g
  final double proteinPer100g;

  /// Carbohydrates in grams per 100g
  final double carbsPer100g;

  /// Fat in grams per 100g
  final double fatPer100g;

  /// Network URL for the food image (cached at runtime).
  final String imageUrl;

  /// Tags for dietary preferences (vegetarian, vegan, glutenFree, dairyFree)
  final List<String> tags;

  /// Returns macros scaled to [grams] quantity.
  FoodMacros macrosForGrams(double grams) {
    final factor = grams / 100.0;
    return FoodMacros(
      calories: caloriesPer100g * factor,
      protein: proteinPer100g * factor,
      carbs: carbsPer100g * factor,
      fat: fatPer100g * factor,
      grams: grams,
    );
  }
}

/// Calculated macros for a specific quantity of a [FoodItem].
class FoodMacros {
  const FoodMacros({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.grams,
  });

  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double grams;
}

enum FoodCategory {
  protein,
  carbs,
  vegetables,
  fruits,
  dairy,
  fats,
  snacks,
  beverages,
}

extension FoodCategoryX on FoodCategory {
  String get displayName => switch (this) {
    FoodCategory.protein => 'Protein',
    FoodCategory.carbs => 'Carbs',
    FoodCategory.vegetables => 'Vegetables',
    FoodCategory.fruits => 'Fruits',
    FoodCategory.dairy => 'Dairy',
    FoodCategory.fats => 'Fats',
    FoodCategory.snacks => 'Snacks',
    FoodCategory.beverages => 'Beverages',
  };
}
