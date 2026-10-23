import 'food_item.dart';
import 'food_item_full.dart';

/// Canonical conversions between the two remaining food shapes
/// (Phase 3, F-15 partial).
///
/// The app still has two food models with different jobs:
///
/// - [FoodItem] — the static, USDA-sourced catalog type. Carries
///   serving/budget/provenance metadata and *nullable* micros:
///   `null` means "not measured", which matters for data honesty.
/// - [FoodItemFull] — the freezed repository/persistence type used by
///   the Firestore/Hive food store, custom foods, suggestions and the
///   AI deficiency features. All nutrient groups are non-nullable.
///
/// Merging them into one class needs a compile-verified migration of
/// the 287-entry static catalog AND the persisted `food_items_full`
/// schema, so it stays a follow-up. What Phase 3 removes is the chaos
/// around them — conversions used to be re-invented per call site,
/// including a `dynamic` converter in the upload script that
/// *fabricated* vitamins/minerals from category stereotypes while
/// ignoring the catalog's measured micros. These extensions are now
/// the single place the mapping is defined:
///
/// - [FoodItemToFull.toFoodItemFull] copies **measured** values only.
///   Nutrients the catalog doesn't measure (vitamins A/B/C/E,
///   magnesium, zinc, and any `null` micro) become `0`, which in
///   [FoodItemFull] land means "unknown" — never an invented estimate.
/// - [FoodItemFullToItem.toFoodItem] is lossy by construction:
///   vitamins A/B/C/E, magnesium and zinc have no home in [FoodItem],
///   and serving/budget/source default. Use it only where the catalog
///   shape is required (e.g. static-catalog UI paths).
extension FoodItemToFull on FoodItem {
  FoodItemFull toFoodItemFull() {
    final micros = microsPer100g;
    return FoodItemFull(
      id: id,
      name: name,
      category: category.name,
      macros: MacrosPer100g(
        calories: caloriesPer100g,
        protein: proteinPer100g,
        carbs: carbsPer100g,
        fats: fatPer100g,
      ),
      micros: MicrosPer100g(
        fiber: micros?.fiberGrams ?? 0,
        sugar: micros?.sugarGrams ?? 0,
        sodium: micros?.sodiumMg ?? 0,
        potassium: micros?.potassiumMg ?? 0,
      ),
      vitamins: VitaminsPer100g(
        // Only vitamin D is measured in the catalog.
        vitaminA: 0,
        vitaminB: 0,
        vitaminC: 0,
        vitaminD: micros?.vitaminDMcg ?? 0,
        vitaminE: 0,
      ),
      minerals: MineralsPer100g(
        calcium: micros?.calciumMg ?? 0,
        iron: micros?.ironMg ?? 0,
        // Not measured in the catalog.
        magnesium: 0,
        zinc: 0,
      ),
      imageUrl: imageUrl,
      dietaryTags: tags,
    );
  }
}

extension FoodItemFullToItem on FoodItemFull {
  FoodItem toFoodItem() {
    return FoodItem(
      id: id,
      name: name,
      category: foodCategoryFromName(category),
      caloriesPer100g: macros.calories,
      proteinPer100g: macros.protein,
      carbsPer100g: macros.carbs,
      fatPer100g: macros.fats,
      imageUrl: imageUrl,
      tags: dietaryTags,
      microsPer100g: FoodMicros(
        fiberGrams: micros.fiber,
        sugarGrams: micros.sugar,
        sodiumMg: micros.sodium,
        potassiumMg: micros.potassium,
        calciumMg: minerals.calcium,
        ironMg: minerals.iron,
        vitaminDMcg: vitamins.vitaminD,
        // Vitamins A/B/C/E, magnesium and zinc cannot be represented
        // in FoodItem and are dropped (see file doc).
      ),
    );
  }
}

/// Parses a [FoodItemFull.category] string into the catalog enum.
///
/// Unknown strings fall back to [FoodCategory.snacks] as the generic
/// bucket — repository foods may carry free-form categories the
/// catalog enum doesn't know.
FoodCategory foodCategoryFromName(String name) {
  final normalized = name.trim().toLowerCase();
  for (final value in FoodCategory.values) {
    if (value.name == normalized) return value;
  }
  return FoodCategory.snacks;
}
