import 'package:flutter/foundation.dart';

import '../../../onboarding/domain/entities/user_profile.dart' show BudgetLevel;

/// A structured food item with macros, serving definitions, budget tier,
/// data provenance, and micronutrients.
///
/// All macro and micro values are stored per 100g according to authoritative
/// USDA FoodData Central standards. Use [FoodItem.macrosForGrams] or
/// [FoodItem.macrosForServings] to calculate values for specific portions.
@immutable
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
    this.rawCategory,
  });

  final String id;
  final String name;
  final FoodCategory category;

  /// Optional original free-form category label (e.g. from custom foods or
  /// Firestore docs) preserved across round-trips when it differs from
  /// [FoodCategory.name].
  final String? rawCategory;

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

  /// Backward-compatible alias for [tags].
  List<String> get dietaryTags => tags;

  /// Preserves free-form category label if present, otherwise [category.name].
  String get categoryName => rawCategory ?? category.name;

  FoodItem copyWith({
    String? id,
    String? name,
    FoodCategory? category,
    String? rawCategory,
    double? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    String? imageUrl,
    List<String>? tags,
    String? description,
    String? servingUnit,
    double? servingWeightGrams,
    String? servingDescription,
    BudgetLevel? budgetTier,
    String? fdcId,
    String? source,
    FoodMicros? microsPer100g,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      rawCategory: rawCategory ?? this.rawCategory,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      servingUnit: servingUnit ?? this.servingUnit,
      servingWeightGrams: servingWeightGrams ?? this.servingWeightGrams,
      servingDescription: servingDescription ?? this.servingDescription,
      budgetTier: budgetTier ?? this.budgetTier,
      fdcId: fdcId ?? this.fdcId,
      source: source ?? this.source,
      microsPer100g: microsPer100g ?? this.microsPer100g,
    );
  }

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
        if (rawCategory != null) 'rawCategory': rawCategory,
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

  /// Parses canonical `foods_catalog.json` maps as well as legacy Hive
  /// `FoodItemFullModel` maps and nested Firestore `foods` documents.
  factory FoodItem.fromAnyJson(Map<String, dynamic> json) {
    final macrosMap = json['macros'] is Map
        ? Map<String, dynamic>.from(json['macros'] as Map)
        : null;
    if (macrosMap != null) {
      return _fromLegacyOrFirestoreJson(json, macrosMap);
    }

    final rawCat = json['rawCategory']?.toString() ?? json['category']?.toString();
    final category = FoodCategoryX.fromName(json['category']?.toString());
    final rawMicros = json['microsPer100g'];

    return FoodItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: category,
      rawCategory: (rawCat != null && rawCat != category.name) ? rawCat : null,
      caloriesPer100g: (json['caloriesPer100g'] as num?)?.toDouble() ?? 0.0,
      proteinPer100g: (json['proteinPer100g'] as num?)?.toDouble() ?? 0.0,
      carbsPer100g: (json['carbsPer100g'] as num?)?.toDouble() ?? 0.0,
      fatPer100g: (json['fatPer100g'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      tags: _parseTags(json['tags'] ?? json['dietaryTags']),
      description: json['description']?.toString() ?? '',
      servingUnit: json['servingUnit']?.toString() ?? 'g',
      servingWeightGrams:
          (json['servingWeightGrams'] as num?)?.toDouble() ?? 100.0,
      servingDescription: json['servingDescription']?.toString() ?? '100g',
      budgetTier: _parseBudget(json['budgetTier']?.toString()),
      fdcId: json['fdcId']?.toString(),
      source: json['source']?.toString() ??
          'USDA FoodData Central (Public Domain)',
      microsPer100g: rawMicros is Map
          ? FoodMicros.fromJson(Map<String, dynamic>.from(rawMicros))
          : null,
    );
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) =>
      FoodItem.fromAnyJson(json);

  static FoodItem _fromLegacyOrFirestoreJson(
    Map<String, dynamic> json,
    Map<String, dynamic> macrosMap,
  ) {
    final microsMap = json['micros'] is Map
        ? Map<String, dynamic>.from(json['micros'] as Map)
        : const <String, dynamic>{};
    final vitaminsMap = json['vitamins'] is Map
        ? Map<String, dynamic>.from(json['vitamins'] as Map)
        : const <String, dynamic>{};
    final mineralsMap = json['minerals'] is Map
        ? Map<String, dynamic>.from(json['minerals'] as Map)
        : const <String, dynamic>{};

    final hasMicros = microsMap.isNotEmpty ||
        vitaminsMap.isNotEmpty ||
        mineralsMap.isNotEmpty;

    final rawCat = json['rawCategory']?.toString() ?? json['category']?.toString();
    final category = FoodCategoryX.fromName(rawCat);

    return FoodItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: category,
      rawCategory: (rawCat != null && rawCat != category.name) ? rawCat : null,
      caloriesPer100g: _firstNum(macrosMap, ['caloriesPer100g', 'calories']) ?? 0.0,
      proteinPer100g: _firstNum(macrosMap, ['proteinPer100g', 'protein']) ?? 0.0,
      carbsPer100g: _firstNum(macrosMap, ['carbsPer100g', 'carbs']) ?? 0.0,
      fatPer100g: _firstNum(macrosMap, ['fatsPer100g', 'fats', 'fat']) ?? 0.0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      tags: _parseTags(json['tags'] ?? json['dietaryTags']),
      description: json['description']?.toString() ?? '',
      servingUnit: json['servingUnit']?.toString() ?? 'g',
      servingWeightGrams:
          (json['servingWeightGrams'] as num?)?.toDouble() ?? 100.0,
      servingDescription: json['servingDescription']?.toString() ?? '100g',
      budgetTier: _parseBudget(json['budgetTier']?.toString()),
      fdcId: json['fdcId']?.toString(),
      source: json['source']?.toString() ??
          'USDA FoodData Central (Public Domain)',
      microsPer100g: hasMicros
          ? FoodMicros(
              fiberGrams: _firstNum(microsMap, ['fiberPer100g', 'fiber']),
              sugarGrams: _firstNum(microsMap, ['sugarPer100g', 'sugar']),
              sodiumMg: _firstNum(microsMap, ['sodiumPer100g', 'sodium']),
              potassiumMg:
                  _firstNum(microsMap, ['potassiumPer100g', 'potassium']),
              calciumMg: _firstNum(mineralsMap, ['calciumPer100g', 'calcium']),
              ironMg: _firstNum(mineralsMap, ['ironPer100g', 'iron']),
              magnesiumMg:
                  _firstNum(mineralsMap, ['magnesiumPer100g', 'magnesium']),
              zincMg: _firstNum(mineralsMap, ['zincPer100g', 'zinc']),
              vitaminAMcg: _firstNum(vitaminsMap, ['aPer100g', 'vitaminA']),
              vitaminBMg: _firstNum(vitaminsMap, ['bPer100g', 'vitaminB']),
              vitaminCMg: _firstNum(vitaminsMap, ['cPer100g', 'vitaminC']),
              vitaminDMcg: _firstNum(vitaminsMap, ['dPer100g', 'vitaminD']),
              vitaminEMg: _firstNum(vitaminsMap, ['ePer100g', 'vitaminE']),
            )
          : null,
    );
  }

  static double? _firstNum(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final val = map[key];
      if (val is num) return val.toDouble();
    }
    return null;
  }

  static List<String> _parseTags(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return const [];
  }

  static BudgetLevel _parseBudget(String? raw) {
    if (raw == null) return BudgetLevel.medium;
    return BudgetLevel.values.firstWhere(
      (b) => b.name == raw,
      orElse: () => BudgetLevel.medium,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItem &&
        other.id == id &&
        other.name == name &&
        other.category == category &&
        other.rawCategory == rawCategory &&
        other.caloriesPer100g == caloriesPer100g &&
        other.proteinPer100g == proteinPer100g &&
        other.carbsPer100g == carbsPer100g &&
        other.fatPer100g == fatPer100g &&
        other.imageUrl == imageUrl &&
        listEquals(other.tags, tags) &&
        other.description == description &&
        other.servingUnit == servingUnit &&
        other.servingWeightGrams == servingWeightGrams &&
        other.servingDescription == servingDescription &&
        other.budgetTier == budgetTier &&
        other.fdcId == fdcId &&
        other.source == source &&
        other.microsPer100g == microsPer100g;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        category,
        rawCategory,
        caloriesPer100g,
        proteinPer100g,
        carbsPer100g,
        fatPer100g,
        imageUrl,
        Object.hashAll(tags),
        description,
        servingUnit,
        servingWeightGrams,
        servingDescription,
        budgetTier,
        fdcId,
        source,
        microsPer100g,
      );
}

/// Calculated macros for a specific quantity of a [FoodItem].
@immutable
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodMacros &&
        other.calories == calories &&
        other.protein == protein &&
        other.carbs == carbs &&
        other.fat == fat &&
        other.grams == grams;
  }

  @override
  int get hashCode => Object.hash(calories, protein, carbs, fat, grams);
}

/// Exact micronutrients per 100g (or scaled quantity) for a [FoodItem].
///
/// Null fields indicate the nutrient was not measured or not in the source record.
@immutable
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
    this.vitaminAMcg,
    this.vitaminBMg,
    this.vitaminCMg,
    this.vitaminEMg,
    this.magnesiumMg,
    this.zincMg,
  });

  final double? fiberGrams;
  final double? sugarGrams;
  final double? sodiumMg;
  final double? potassiumMg;
  final double? calciumMg;
  final double? ironMg;
  final double? vitaminDMcg;
  final double? saturatedFatGrams;
  final double? vitaminAMcg;
  final double? vitaminBMg;
  final double? vitaminCMg;
  final double? vitaminEMg;
  final double? magnesiumMg;
  final double? zincMg;

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
      vitaminAMcg: vitaminAMcg != null ? vitaminAMcg! * factor : null,
      vitaminBMg: vitaminBMg != null ? vitaminBMg! * factor : null,
      vitaminCMg: vitaminCMg != null ? vitaminCMg! * factor : null,
      vitaminEMg: vitaminEMg != null ? vitaminEMg! * factor : null,
      magnesiumMg: magnesiumMg != null ? magnesiumMg! * factor : null,
      zincMg: zincMg != null ? zincMg! * factor : null,
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
        if (vitaminAMcg != null) 'vitaminAMcg': vitaminAMcg,
        if (vitaminBMg != null) 'vitaminBMg': vitaminBMg,
        if (vitaminCMg != null) 'vitaminCMg': vitaminCMg,
        if (vitaminEMg != null) 'vitaminEMg': vitaminEMg,
        if (magnesiumMg != null) 'magnesiumMg': magnesiumMg,
        if (zincMg != null) 'zincMg': zincMg,
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
      vitaminAMcg: (json['vitaminAMcg'] as num?)?.toDouble(),
      vitaminBMg: (json['vitaminBMg'] as num?)?.toDouble(),
      vitaminCMg: (json['vitaminCMg'] as num?)?.toDouble(),
      vitaminEMg: (json['vitaminEMg'] as num?)?.toDouble(),
      magnesiumMg: (json['magnesiumMg'] as num?)?.toDouble(),
      zincMg: (json['zincMg'] as num?)?.toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodMicros &&
        other.fiberGrams == fiberGrams &&
        other.sugarGrams == sugarGrams &&
        other.sodiumMg == sodiumMg &&
        other.potassiumMg == potassiumMg &&
        other.calciumMg == calciumMg &&
        other.ironMg == ironMg &&
        other.vitaminDMcg == vitaminDMcg &&
        other.saturatedFatGrams == saturatedFatGrams &&
        other.vitaminAMcg == vitaminAMcg &&
        other.vitaminBMg == vitaminBMg &&
        other.vitaminCMg == vitaminCMg &&
        other.vitaminEMg == vitaminEMg &&
        other.magnesiumMg == magnesiumMg &&
        other.zincMg == zincMg;
  }

  @override
  int get hashCode => Object.hash(
        fiberGrams,
        sugarGrams,
        sodiumMg,
        potassiumMg,
        calciumMg,
        ironMg,
        vitaminDMcg,
        saturatedFatGrams,
        vitaminAMcg,
        vitaminBMg,
        vitaminCMg,
        vitaminEMg,
        magnesiumMg,
        zincMg,
      );
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
  custom,
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
        FoodCategory.custom => 'Custom',
      };

  static FoodCategory fromName(String? raw) {
    final norm = (raw ?? '').trim().toLowerCase();
    for (final c in FoodCategory.values) {
      if (c.name.toLowerCase() == norm || c.displayName.toLowerCase() == norm) {
        return c;
      }
    }
    return switch (norm) {
      'vegetable' => FoodCategory.vegetables,
      'fruit' => FoodCategory.fruits,
      'fat' => FoodCategory.fats,
      'snack' => FoodCategory.snacks,
      'beverage' => FoodCategory.beverages,
      'carb' => FoodCategory.carbs,
      'custom' => FoodCategory.custom,
      _ => FoodCategory.snacks,
    };
  }
}
