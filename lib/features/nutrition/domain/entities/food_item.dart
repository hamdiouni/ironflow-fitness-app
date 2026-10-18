import '../../../onboarding/domain/entities/user_profile.dart' show BudgetLevel;

/// A structured food item with macros, serving definitions, budget tier,
/// data provenance, and micronutrients.
///
/// All macro and micro values are stored per 100g according to authoritative
/// USDA FoodData Central standards. Use [FoodItem.macrosForGrams] or
/// [FoodItem.macrosForServings] to calculate values for specific portions.
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
    this.description = '',
    this.servingUnit = 'g',
    this.servingWeightGrams = 100.0,
    this.servingDescription = '100g',
    this.budgetTier = BudgetLevel.medium,
    this.fdcId,
    this.source = 'USDA FoodData Central (Public Domain)',
    this.microsPer100g,
  });

  final String id;
  final String name;
  final FoodCategory category;

  /// Calories per 100g (kcal)
  final double caloriesPer100g;

  /// Protein in grams per 100g
  final double proteinPer100g;

  /// Carbohydrates in grams per 100g
  final double carbsPer100g;

  /// Fat in grams per 100g
  final double fatPer100g;

  /// Network URL for the food image (cached at runtime).
  final String imageUrl;

  /// Tags for dietary preferences (vegetarian, vegan, glutenFree, dairyFree, etc.)
  final List<String> tags;

  /// Factual description of the food item and nutritional role.
  final String description;

  /// Common serving unit (e.g. 'breast', 'egg', 'scoop', 'cup', 'can', 'slice', 'tbsp', 'g')
  final String servingUnit;

  /// Gram weight of one standard serving.
  final double servingWeightGrams;

  /// Human-readable serving description (e.g. '1 large egg (50g)', '1 scoop (30g)')
  final String servingDescription;

  /// Budget tier matching user profile onboarding choice (low, medium, high).
  final BudgetLevel budgetTier;

  /// USDA FoodData Central ID or authoritative reference number.
  final String? fdcId;

  /// Data provenance attribution.
  final String source;

  /// Exact micronutrients per 100g. Null indicates nutrient was unmeasured/missing.
  final FoodMicros? microsPer100g;

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

  /// Returns micronutrients scaled to [grams] quantity.
  FoodMicros? microsForGrams(double grams) {
    if (microsPer100g == null) return null;
    return microsPer100g!.scale(grams / 100.0);
  }

  /// Returns macros scaled by number of standard [servings].
  FoodMacros macrosForServings(double servings) =>
      macrosForGrams(servings * servingWeightGrams);

  /// Returns micronutrients scaled by number of standard [servings].
  FoodMicros? microsForServings(double servings) =>
      microsForGrams(servings * servingWeightGrams);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'caloriesPer100g': caloriesPer100g,
        'proteinPer100g': proteinPer100g,
        'carbsPer100g': carbsPer100g,
        'fatPer100g': fatPer100g,
        'imageUrl': imageUrl,
        'tags': tags,
        'description': description,
        'servingUnit': servingUnit,
        'servingWeightGrams': servingWeightGrams,
        'servingDescription': servingDescription,
        'budgetTier': budgetTier.name,
        if (fdcId != null) 'fdcId': fdcId,
        'source': source,
        if (microsPer100g != null) 'microsPer100g': microsPer100g!.toJson(),
      };

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: FoodCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => FoodCategory.protein,
      ),
      caloriesPer100g: (json['caloriesPer100g'] as num).toDouble(),
      proteinPer100g: (json['proteinPer100g'] as num).toDouble(),
      carbsPer100g: (json['carbsPer100g'] as num).toDouble(),
      fatPer100g: (json['fatPer100g'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      description: json['description'] as String? ?? '',
      servingUnit: json['servingUnit'] as String? ?? 'g',
      servingWeightGrams:
          (json['servingWeightGrams'] as num?)?.toDouble() ?? 100.0,
      servingDescription: json['servingDescription'] as String? ?? '100g',
      budgetTier: json['budgetTier'] != null
          ? BudgetLevel.values.firstWhere(
              (b) => b.name == json['budgetTier'],
              orElse: () => BudgetLevel.medium,
            )
          : BudgetLevel.medium,
      fdcId: json['fdcId'] as String?,
      source: json['source'] as String? ??
          'USDA FoodData Central (Public Domain)',
      microsPer100g: json['microsPer100g'] != null
          ? FoodMicros.fromJson(
              json['microsPer100g'] as Map<String, dynamic>)
          : null,
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

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'grams': grams,
      };

  factory FoodMacros.fromJson(Map<String, dynamic> json) => FoodMacros(
        calories: (json['calories'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
        grams: (json['grams'] as num).toDouble(),
      );
}

/// Exact micronutrients for a food item.
/// Null fields indicate the nutrient was not measured or not in the USDA record.
/// (Prevents misleading zero values).
class FoodMicros {
  const FoodMicros({
    this.fiberGrams,
    this.sugarGrams,
    this.sodiumMg,
    this.potassiumMg,
    this.calciumMg,
    this.ironMg,
    this.vitaminDMcg,
    this.saturatedFatGrams,
  });

  final double? fiberGrams;
  final double? sugarGrams;
  final double? sodiumMg;
  final double? potassiumMg;
  final double? calciumMg;
  final double? ironMg;
  final double? vitaminDMcg;
  final double? saturatedFatGrams;

  FoodMicros scale(double factor) {
    return FoodMicros(
      fiberGrams: fiberGrams != null ? fiberGrams! * factor : null,
      sugarGrams: sugarGrams != null ? sugarGrams! * factor : null,
      sodiumMg: sodiumMg != null ? sodiumMg! * factor : null,
      potassiumMg: potassiumMg != null ? potassiumMg! * factor : null,
      calciumMg: calciumMg != null ? calciumMg! * factor : null,
      ironMg: ironMg != null ? ironMg! * factor : null,
      vitaminDMcg: vitaminDMcg != null ? vitaminDMcg! * factor : null,
      saturatedFatGrams:
          saturatedFatGrams != null ? saturatedFatGrams! * factor : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'fiberGrams': fiberGrams,
        'sugarGrams': sugarGrams,
        'sodiumMg': sodiumMg,
        'potassiumMg': potassiumMg,
        'calciumMg': calciumMg,
        'ironMg': ironMg,
        'vitaminDMcg': vitaminDMcg,
        'saturatedFatGrams': saturatedFatGrams,
      };

  factory FoodMicros.fromJson(Map<String, dynamic> json) {
    return FoodMicros(
      fiberGrams: (json['fiberGrams'] as num?)?.toDouble(),
      sugarGrams: (json['sugarGrams'] as num?)?.toDouble(),
      sodiumMg: (json['sodiumMg'] as num?)?.toDouble(),
      potassiumMg: (json['potassiumMg'] as num?)?.toDouble(),
      calciumMg: (json['calciumMg'] as num?)?.toDouble(),
      ironMg: (json['ironMg'] as num?)?.toDouble(),
      vitaminDMcg: (json['vitaminDMcg'] as num?)?.toDouble(),
      saturatedFatGrams: (json['saturatedFatGrams'] as num?)?.toDouble(),
    );
  }
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
