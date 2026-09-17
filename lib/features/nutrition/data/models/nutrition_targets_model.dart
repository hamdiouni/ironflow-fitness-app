import '../../domain/entities/nutrition_targets.dart';

/// Simple model classes without Freezed to avoid code generation issues

class MacroTargetsModel {
  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  const MacroTargetsModel({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
      };

  factory MacroTargetsModel.fromJson(Map<String, dynamic> json) {
    return MacroTargetsModel(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
    );
  }

  factory MacroTargetsModel.fromEntity(MacroTargets entity) {
    return MacroTargetsModel(
      calories: entity.calories,
      protein: entity.protein,
      carbs: entity.carbs,
      fats: entity.fats,
    );
  }

  MacroTargets toEntity() {
    return MacroTargets(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
    );
  }
}

class MicroTargetsModel {
  final double fiber;
  final double sugar;
  final double sodium;
  final double potassium;

  const MicroTargetsModel({
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.potassium,
  });

  Map<String, dynamic> toJson() => {
        'fiber': fiber,
        'sugar': sugar,
        'sodium': sodium,
        'potassium': potassium,
      };

  factory MicroTargetsModel.fromJson(Map<String, dynamic> json) {
    return MicroTargetsModel(
      fiber: (json['fiber'] as num).toDouble(),
      sugar: (json['sugar'] as num).toDouble(),
      sodium: (json['sodium'] as num).toDouble(),
      potassium: (json['potassium'] as num).toDouble(),
    );
  }

  factory MicroTargetsModel.fromEntity(MicroTargets entity) {
    return MicroTargetsModel(
      fiber: entity.fiber,
      sugar: entity.sugar,
      sodium: entity.sodium,
      potassium: entity.potassium,
    );
  }

  MicroTargets toEntity() {
    return MicroTargets(
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      potassium: potassium,
    );
  }
}

class VitaminTargetsModel {
  final double vitaminA;
  final double vitaminB;
  final double vitaminC;
  final double vitaminD;
  final double vitaminE;

  const VitaminTargetsModel({
    required this.vitaminA,
    required this.vitaminB,
    required this.vitaminC,
    required this.vitaminD,
    required this.vitaminE,
  });

  Map<String, dynamic> toJson() => {
        'vitaminA': vitaminA,
        'vitaminB': vitaminB,
        'vitaminC': vitaminC,
        'vitaminD': vitaminD,
        'vitaminE': vitaminE,
      };

  factory VitaminTargetsModel.fromJson(Map<String, dynamic> json) {
    return VitaminTargetsModel(
      vitaminA: (json['vitaminA'] as num).toDouble(),
      vitaminB: (json['vitaminB'] as num).toDouble(),
      vitaminC: (json['vitaminC'] as num).toDouble(),
      vitaminD: (json['vitaminD'] as num).toDouble(),
      vitaminE: (json['vitaminE'] as num).toDouble(),
    );
  }

  factory VitaminTargetsModel.fromEntity(VitaminTargets entity) {
    return VitaminTargetsModel(
      vitaminA: entity.vitaminA,
      vitaminB: entity.vitaminB,
      vitaminC: entity.vitaminC,
      vitaminD: entity.vitaminD,
      vitaminE: entity.vitaminE,
    );
  }

  VitaminTargets toEntity() {
    return VitaminTargets(
      vitaminA: vitaminA,
      vitaminB: vitaminB,
      vitaminC: vitaminC,
      vitaminD: vitaminD,
      vitaminE: vitaminE,
    );
  }
}

class MineralTargetsModel {
  final double calcium;
  final double iron;
  final double magnesium;
  final double zinc;

  const MineralTargetsModel({
    required this.calcium,
    required this.iron,
    required this.magnesium,
    required this.zinc,
  });

  Map<String, dynamic> toJson() => {
        'calcium': calcium,
        'iron': iron,
        'magnesium': magnesium,
        'zinc': zinc,
      };

  factory MineralTargetsModel.fromJson(Map<String, dynamic> json) {
    return MineralTargetsModel(
      calcium: (json['calcium'] as num).toDouble(),
      iron: (json['iron'] as num).toDouble(),
      magnesium: (json['magnesium'] as num).toDouble(),
      zinc: (json['zinc'] as num).toDouble(),
    );
  }

  factory MineralTargetsModel.fromEntity(MineralTargets entity) {
    return MineralTargetsModel(
      calcium: entity.calcium,
      iron: entity.iron,
      magnesium: entity.magnesium,
      zinc: entity.zinc,
    );
  }

  MineralTargets toEntity() {
    return MineralTargets(
      calcium: calcium,
      iron: iron,
      magnesium: magnesium,
      zinc: zinc,
    );
  }
}

class NutritionTargetsModel {
  final String userId;
  final MacroTargetsModel macros;
  final MicroTargetsModel micros;
  final VitaminTargetsModel vitamins;
  final MineralTargetsModel minerals;
  final String createdAt;
  final String updatedAt;

  const NutritionTargetsModel({
    required this.userId,
    required this.macros,
    required this.micros,
    required this.vitamins,
    required this.minerals,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'macros': macros.toJson(),
        'micros': micros.toJson(),
        'vitamins': vitamins.toJson(),
        'minerals': minerals.toJson(),
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  factory NutritionTargetsModel.fromJson(Map<String, dynamic> json) {
    return NutritionTargetsModel(
      userId: json['userId'] as String,
      macros: MacroTargetsModel.fromJson(json['macros'] as Map<String, dynamic>),
      micros: MicroTargetsModel.fromJson(json['micros'] as Map<String, dynamic>),
      vitamins: VitaminTargetsModel.fromJson(json['vitamins'] as Map<String, dynamic>),
      minerals: MineralTargetsModel.fromJson(json['minerals'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  factory NutritionTargetsModel.fromEntity(NutritionTargets entity) {
    return NutritionTargetsModel(
      userId: entity.userId,
      macros: MacroTargetsModel.fromEntity(entity.macros),
      micros: MicroTargetsModel.fromEntity(entity.micros),
      vitamins: VitaminTargetsModel.fromEntity(entity.vitamins),
      minerals: MineralTargetsModel.fromEntity(entity.minerals),
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  NutritionTargets toEntity() {
    return NutritionTargets(
      userId: userId,
      macros: macros.toEntity(),
      micros: micros.toEntity(),
      vitamins: vitamins.toEntity(),
      minerals: minerals.toEntity(),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
