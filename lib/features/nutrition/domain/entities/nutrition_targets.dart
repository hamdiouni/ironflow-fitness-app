import 'package:freezed_annotation/freezed_annotation.dart';

part 'nutrition_targets.freezed.dart';

/// Macro targets for daily nutrition
@freezed
class MacroTargets with _$MacroTargets {
  const factory MacroTargets({
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
  }) = _MacroTargets;

  const MacroTargets._();

  /// Validate that all targets are positive
  bool get isValid =>
      calories > 0 && protein > 0 && carbs > 0 && fats > 0;
}

/// Micro targets for daily nutrition
@freezed
class MicroTargets with _$MicroTargets {
  const factory MicroTargets({
    required double fiber,
    required double sugar,
    required double sodium,
    required double potassium,
  }) = _MicroTargets;

  const MicroTargets._();

  /// Validate that all targets are positive
  bool get isValid =>
      fiber > 0 && sugar > 0 && sodium > 0 && potassium > 0;
}

/// Vitamin targets for daily nutrition
@freezed
class VitaminTargets with _$VitaminTargets {
  const factory VitaminTargets({
    required double vitaminA,
    required double vitaminB,
    required double vitaminC,
    required double vitaminD,
    required double vitaminE,
  }) = _VitaminTargets;

  const VitaminTargets._();

  /// Validate that all targets are positive
  bool get isValid =>
      vitaminA > 0 &&
      vitaminB > 0 &&
      vitaminC > 0 &&
      vitaminD > 0 &&
      vitaminE > 0;
}

/// Mineral targets for daily nutrition
@freezed
class MineralTargets with _$MineralTargets {
  const factory MineralTargets({
    required double calcium,
    required double iron,
    required double magnesium,
    required double zinc,
  }) = _MineralTargets;

  const MineralTargets._();

  /// Validate that all targets are positive
  bool get isValid =>
      calcium > 0 && iron > 0 && magnesium > 0 && zinc > 0;
}

/// Complete nutrition targets for daily tracking
///
/// Contains all macro, micro, vitamin, and mineral targets for a user's daily
/// nutrition goals. All values should be positive numbers representing daily targets.
@freezed
class NutritionTargets with _$NutritionTargets {
  const factory NutritionTargets({
    required String userId,
    required MacroTargets macros,
    required MicroTargets micros,
    required VitaminTargets vitamins,
    required MineralTargets minerals,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _NutritionTargets;

  const NutritionTargets._();

  /// Validate that all targets are positive
  bool get isValid =>
      macros.isValid &&
      micros.isValid &&
      vitamins.isValid &&
      minerals.isValid;

  /// Calculate remaining macros given consumed values
  MacroTargets getRemainingMacros(MacroTargets consumed) {
    return MacroTargets(
      calories: (macros.calories - consumed.calories).clamp(0, double.infinity),
      protein: (macros.protein - consumed.protein).clamp(0, double.infinity),
      carbs: (macros.carbs - consumed.carbs).clamp(0, double.infinity),
      fats: (macros.fats - consumed.fats).clamp(0, double.infinity),
    );
  }

  /// Calculate remaining micros given consumed values
  MicroTargets getRemainingMicros(MicroTargets consumed) {
    return MicroTargets(
      fiber: (micros.fiber - consumed.fiber).clamp(0, double.infinity),
      sugar: (micros.sugar - consumed.sugar).clamp(0, double.infinity),
      sodium: (micros.sodium - consumed.sodium).clamp(0, double.infinity),
      potassium:
          (micros.potassium - consumed.potassium).clamp(0, double.infinity),
    );
  }

  /// Calculate remaining vitamins given consumed values
  VitaminTargets getRemainingVitamins(VitaminTargets consumed) {
    return VitaminTargets(
      vitaminA: (vitamins.vitaminA - consumed.vitaminA).clamp(0, double.infinity),
      vitaminB: (vitamins.vitaminB - consumed.vitaminB).clamp(0, double.infinity),
      vitaminC: (vitamins.vitaminC - consumed.vitaminC).clamp(0, double.infinity),
      vitaminD: (vitamins.vitaminD - consumed.vitaminD).clamp(0, double.infinity),
      vitaminE: (vitamins.vitaminE - consumed.vitaminE).clamp(0, double.infinity),
    );
  }

  /// Calculate remaining minerals given consumed values
  MineralTargets getRemainingMinerals(MineralTargets consumed) {
    return MineralTargets(
      calcium: (minerals.calcium - consumed.calcium).clamp(0, double.infinity),
      iron: (minerals.iron - consumed.iron).clamp(0, double.infinity),
      magnesium:
          (minerals.magnesium - consumed.magnesium).clamp(0, double.infinity),
      zinc: (minerals.zinc - consumed.zinc).clamp(0, double.infinity),
    );
  }

  /// Calculate macro completion percentage (0-100)
  double getMacroCompletionPercentage(MacroTargets consumed) {
    if (!macros.isValid) return 0;
    final totalTarget = macros.calories;
    final totalConsumed = consumed.calories;
    return ((totalConsumed / totalTarget) * 100).clamp(0, 100);
  }

  /// Calculate protein completion percentage (0-100)
  double getProteinCompletionPercentage(MacroTargets consumed) {
    if (macros.protein <= 0) return 0;
    return ((consumed.protein / macros.protein) * 100).clamp(0, 100);
  }

  /// Calculate carbs completion percentage (0-100)
  double getCarbsCompletionPercentage(MacroTargets consumed) {
    if (macros.carbs <= 0) return 0;
    return ((consumed.carbs / macros.carbs) * 100).clamp(0, 100);
  }

  /// Calculate fats completion percentage (0-100)
  double getFatsCompletionPercentage(MacroTargets consumed) {
    if (macros.fats <= 0) return 0;
    return ((consumed.fats / macros.fats) * 100).clamp(0, 100);
  }

  /// Calculate fiber completion percentage (0-100)
  double getFiberCompletionPercentage(MicroTargets consumed) {
    if (micros.fiber <= 0) return 0;
    return ((consumed.fiber / micros.fiber) * 100).clamp(0, 100);
  }

  /// Calculate sodium completion percentage (0-100)
  double getSodiumCompletionPercentage(MicroTargets consumed) {
    if (micros.sodium <= 0) return 0;
    return ((consumed.sodium / micros.sodium) * 100).clamp(0, 100);
  }

  /// Calculate potassium completion percentage (0-100)
  double getPotassiumCompletionPercentage(MicroTargets consumed) {
    if (micros.potassium <= 0) return 0;
    return ((consumed.potassium / micros.potassium) * 100).clamp(0, 100);
  }

  /// Get color status for a completion percentage
  /// Green: 80-120%, Orange: 50-80% or 120-150%, Red: <50% or >150%
  NutritionStatus getStatusForPercentage(double percentage) {
    if (percentage >= 80 && percentage <= 120) {
      return NutritionStatus.good;
    } else if ((percentage >= 50 && percentage < 80) ||
        (percentage > 120 && percentage <= 150)) {
      return NutritionStatus.moderate;
    } else {
      return NutritionStatus.poor;
    }
  }
}

/// Status of nutrition target completion
enum NutritionStatus {
  good,     // Within target range (80-120%)
  moderate, // Moderate deviation (50-80% or 120-150%)
  poor,     // Outside target range (<50% or >150%)
}
