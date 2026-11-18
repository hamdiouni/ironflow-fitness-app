import 'dart:convert';

import '../../../onboarding/domain/entities/user_profile.dart' show BudgetLevel;
import '../entities/food_item.dart';

/// Pure-Dart HTTP callback signature for Open Food Facts API v2 requests.
typedef OpenFoodFactsHttpGetter = Future<({int statusCode, String body})>
    Function(Uri uri, Map<String, String> headers);

/// Result of an Open Food Facts barcode lookup.
class OpenFoodFactsLookupResult {
  const OpenFoodFactsLookupResult({
    required this.found,
    required this.barcode,
    this.food,
    this.message,
    this.isFromOfflineCatalog = false,
  });

  final bool found;
  final String barcode;
  final FoodItem? food;
  final String? message;
  final bool isFromOfflineCatalog;
}

/// Domain service for validating EAN/UPC/GTIN barcodes and resolving nutritional
/// data from Open Food Facts (ODbL v1.0) with an offline verified gym-food catalog.
class OpenFoodFactsService {
  const OpenFoodFactsService({
    this.httpGetter,
  });

  final OpenFoodFactsHttpGetter? httpGetter;

  static const String attributionSource = 'Open Food Facts (ODbL v1.0)';
  static const String userAgent =
      'IronFlow/2.0.0 (https://ironflow.app; ODbL-compliant nutrition tracker)';

  /// Strips spaces, dashes, and non-digit characters from a raw barcode string.
  static String normalizeBarcode(String raw) {
    return raw.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Validates that [raw] normalizes to a standard 8-to-14 digit GTIN/EAN/UPC code.
  static bool isValidBarcode(String raw) {
    final digits = normalizeBarcode(raw);
    return digits.length >= 8 && digits.length <= 14;
  }

  /// Validates the GS1 Modulo-10 check digit for standard 8, 12, 13, or 14-digit GTINs.
  static bool hasValidGtinCheckDigit(String raw) {
    final digits = normalizeBarcode(raw);
    if (!const {8, 12, 13, 14}.contains(digits.length)) {
      return false;
    }
    int sum = 0;
    for (int i = 0; i < digits.length - 1; i++) {
      final digit = digits.codeUnitAt(digits.length - 2 - i) - 48;
      if (digit < 0 || digit > 9) return false;
      sum += (i.isEven ? digit * 3 : digit);
    }
    final checkDigit = (10 - (sum % 10)) % 10;
    final actualCheck = digits.codeUnitAt(digits.length - 1) - 48;
    return checkDigit == actualCheck;
  }

  /// Offline verified catalog of common lifter/gym barcodes for zero-latency
  /// offline lookup and instant testing.
  static const List<({String barcode, String brand, FoodItem food})>
      offlineVerifiedBarcodes = [
    (
      barcode: '0748927024081',
      brand: 'Optimum Nutrition',
      food: FoodItem(
        id: 'off_0748927024081',
        name: 'Gold Standard 100% Whey Double Rich Chocolate',
        category: FoodCategory.protein,
        caloriesPer100g: 394.0,
        proteinPer100g: 78.8,
        carbsPer100g: 9.8,
        fatPer100g: 4.9,
        imageUrl: '',
        tags: ['high-protein', 'whey', 'post-workout'],
        description:
            'Whey protein isolate primary source with 24g protein per 30.4g scoop.',
        servingUnit: 'scoop',
        servingWeightGrams: 30.4,
        servingDescription: '1 scoop (30.4g)',
        budgetTier: BudgetLevel.medium,
        fdcId: 'OFF:0748927024081',
        source: attributionSource,
        microsPer100g: FoodMicros(
          sodiumMg: 328.0,
          calciumMg: 427.0,
          potassiumMg: 493.0,
        ),
      ),
    ),
    (
      barcode: '5201054017615',
      brand: 'FAGE',
      food: FoodItem(
        id: 'off_5201054017615',
        name: 'FAGE Total 0% Nonfat Greek Strained Yogurt',
        category: FoodCategory.dairy,
        caloriesPer100g: 53.0,
        proteinPer100g: 10.6,
        carbsPer100g: 3.0,
        fatPer100g: 0.0,
        imageUrl: '',
        tags: ['high-protein', 'low-fat', 'vegetarian', 'probiotic'],
        description:
            'Strained nonfat Greek yogurt rich in casein and whey protein.',
        servingUnit: 'cup',
        servingWeightGrams: 170.0,
        servingDescription: '1 container (170g)',
        budgetTier: BudgetLevel.medium,
        fdcId: 'OFF:5201054017615',
        source: attributionSource,
        microsPer100g: FoodMicros(
          sugarGrams: 3.0,
          sodiumMg: 38.0,
          calciumMg: 118.0,
        ),
      ),
    ),
    (
      barcode: '0030000010402',
      brand: 'Quaker',
      food: FoodItem(
        id: 'off_0030000010402',
        name: 'Quaker Old Fashioned Rolled Oats',
        category: FoodCategory.carbs,
        caloriesPer100g: 375.0,
        proteinPer100g: 12.5,
        carbsPer100g: 67.5,
        fatPer100g: 7.5,
        imageUrl: '',
        tags: ['whole-grain', 'vegan', 'complex-carbs', 'high-fiber'],
        description:
            '100% whole grain rolled oats providing sustained glycemic release.',
        servingUnit: 'half-cup',
        servingWeightGrams: 40.0,
        servingDescription: '1/2 cup dry (40g)',
        budgetTier: BudgetLevel.low,
        fdcId: 'OFF:0030000010402',
        source: attributionSource,
        microsPer100g: FoodMicros(
          fiberGrams: 10.0,
          sugarGrams: 2.5,
          ironMg: 3.8,
          magnesiumMg: 138.0,
        ),
      ),
    ),
    (
      barcode: '0811620020032',
      brand: 'Fairlife',
      food: FoodItem(
        id: 'off_0811620020032',
        name: 'Fairlife Core Power Elite 42g Protein Shake',
        category: FoodCategory.dairy,
        caloriesPer100g: 55.6,
        proteinPer100g: 10.1,
        carbsPer100g: 1.9,
        fatPer100g: 0.8,
        imageUrl: '',
        tags: ['high-protein', 'lactose-free', 'recovery'],
        description:
            'Ultra-filtered milk protein shake delivering 42g complete protein per bottle.',
        servingUnit: 'bottle',
        servingWeightGrams: 414.0,
        servingDescription: '1 bottle (414ml)',
        budgetTier: BudgetLevel.high,
        fdcId: 'OFF:0811620020032',
        source: attributionSource,
        microsPer100g: FoodMicros(
          sugarGrams: 1.7,
          sodiumMg: 63.0,
          calciumMg: 222.0,
        ),
      ),
    ),
    (
      barcode: '0888849000005',
      brand: 'Quest Nutrition',
      food: FoodItem(
        id: 'off_0888849000005',
        name: 'Quest Protein Bar Chocolate Chip Cookie Dough',
        category: FoodCategory.snacks,
        caloriesPer100g: 317.0,
        proteinPer100g: 35.0,
        carbsPer100g: 35.0,
        fatPer100g: 15.0,
        imageUrl: '',
        tags: ['high-protein', 'high-fiber', 'low-sugar'],
        description:
            '21g protein bar with 14g dietary fiber and 1g sugar per 60g bar.',
        servingUnit: 'bar',
        servingWeightGrams: 60.0,
        servingDescription: '1 bar (60g)',
        budgetTier: BudgetLevel.medium,
        fdcId: 'OFF:0888849000005',
        source: attributionSource,
        microsPer100g: FoodMicros(
          fiberGrams: 23.3,
          sugarGrams: 1.7,
          sodiumMg: 367.0,
        ),
      ),
    ),
  ];

  /// Looks up a barcode in the local verified catalog first, then via Open Food Facts API v2.
  Future<OpenFoodFactsLookupResult> lookupBarcode(String rawBarcode) async {
    final normalized = normalizeBarcode(rawBarcode);
    if (!isValidBarcode(normalized)) {
      return OpenFoodFactsLookupResult(
        found: false,
        barcode: normalized,
        message: 'Enter a valid 8–14 digit EAN or UPC barcode.',
      );
    }

    for (final entry in offlineVerifiedBarcodes) {
      if (entry.barcode == normalized ||
          entry.barcode.endsWith(normalized) ||
          normalized.endsWith(entry.barcode)) {
        return OpenFoodFactsLookupResult(
          found: true,
          barcode: entry.barcode,
          food: entry.food,
          isFromOfflineCatalog: true,
        );
      }
    }

    final getter = httpGetter;
    if (getter == null) {
      return OpenFoodFactsLookupResult(
        found: false,
        barcode: normalized,
        message:
            'Product $normalized not found in offline catalog. Connect to query Open Food Facts.',
      );
    }

    try {
      final uri = Uri.parse(
        'https://world.openfoodfacts.org/api/v2/product/$normalized.json'
        '?fields=code,product_name,brands,nutriments,serving_size,serving_quantity,categories_tags,image_front_small_url',
      );
      final response = await getter(uri, {
        'User-Agent': userAgent,
        'Accept': 'application/json',
      });

      if (response.statusCode != 200) {
        return OpenFoodFactsLookupResult(
          found: false,
          barcode: normalized,
          message:
              'Open Food Facts returned status ${response.statusCode} for $normalized.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return OpenFoodFactsLookupResult(
          found: false,
          barcode: normalized,
          message: 'Unexpected response format from Open Food Facts.',
        );
      }

      final food = parseProductJson(normalized, decoded);
      if (food == null) {
        return OpenFoodFactsLookupResult(
          found: false,
          barcode: normalized,
          message: 'No nutrition record found on Open Food Facts for $normalized.',
        );
      }

      return OpenFoodFactsLookupResult(
        found: true,
        barcode: normalized,
        food: food,
      );
    } catch (e) {
      return OpenFoodFactsLookupResult(
        found: false,
        barcode: normalized,
        message: 'Could not reach Open Food Facts: $e',
      );
    }
  }

  /// Parses an Open Food Facts API v2 JSON envelope into a normalized [FoodItem].
  static FoodItem? parseProductJson(
    String barcode,
    Map<String, dynamic> envelope,
  ) {
    final status = envelope['status'];
    if (status == 0 || status == '0') {
      return null;
    }
    final product = envelope['product'];
    if (product is! Map<String, dynamic>) {
      return null;
    }

    final rawName = (product['product_name'] as String?)?.trim() ?? '';
    final rawBrand = (product['brands'] as String?)?.trim() ?? '';
    if (rawName.isEmpty && rawBrand.isEmpty) {
      return null;
    }
    final displayName = rawBrand.isNotEmpty &&
            !rawName.toLowerCase().contains(rawBrand.toLowerCase())
        ? '$rawBrand $rawName'.trim()
        : rawName;

    final nutriments = product['nutriments'] is Map<String, dynamic>
        ? product['nutriments'] as Map<String, dynamic>
        : const <String, dynamic>{};

    double readNutrient(List<String> keys) {
      for (final k in keys) {
        final v = nutriments[k];
        if (v is num) return v.toDouble().clamp(0.0, 10000.0);
        if (v is String) {
          final parsed = double.tryParse(v);
          if (parsed != null) return parsed.clamp(0.0, 10000.0);
        }
      }
      return 0.0;
    }

    double? readOptionalNutrient(List<String> keys) {
      for (final k in keys) {
        final v = nutriments[k];
        if (v is num) return v.toDouble().clamp(0.0, 100000.0);
        if (v is String) {
          final parsed = double.tryParse(v);
          if (parsed != null) return parsed.clamp(0.0, 100000.0);
        }
      }
      return null;
    }

    final protein = readNutrient(const ['proteins_100g', 'proteins']);
    final carbs = readNutrient(const ['carbohydrates_100g', 'carbohydrates']);
    final fat = readNutrient(const ['fat_100g', 'fat']);
    var calories = readNutrient(const [
      'energy-kcal_100g',
      'energy-kcal',
    ]);
    if (calories <= 0 && (protein > 0 || carbs > 0 || fat > 0)) {
      calories = (protein * 4.0) + (carbs * 4.0) + (fat * 9.0);
    }

    final servingGramsRaw = product['serving_quantity'];
    double servingWeight = 100.0;
    if (servingGramsRaw is num && servingGramsRaw > 0) {
      servingWeight = servingGramsRaw.toDouble();
    } else if (servingGramsRaw is String) {
      final parsed = double.tryParse(servingGramsRaw);
      if (parsed != null && parsed > 0) {
        servingWeight = parsed;
      }
    }

    final servingLabel =
        (product['serving_size'] as String?)?.trim().isNotEmpty == true
            ? (product['serving_size'] as String).trim()
            : '${servingWeight.toStringAsFixed(0)}g';

    final sodiumGrams = readOptionalNutrient(const ['sodium_100g']);
    final micros = FoodMicros(
      fiberGrams: readOptionalNutrient(const ['fiber_100g']),
      sugarGrams: readOptionalNutrient(const ['sugars_100g']),
      saturatedFatGrams: readOptionalNutrient(const ['saturated-fat_100g']),
      sodiumMg: sodiumGrams != null ? sodiumGrams * 1000.0 : null,
    );

    return FoodItem(
      id: 'off_$barcode',
      name: displayName,
      category: _inferCategory(product['categories_tags'], protein, carbs, fat),
      caloriesPer100g: double.parse(calories.toStringAsFixed(1)),
      proteinPer100g: double.parse(protein.toStringAsFixed(1)),
      carbsPer100g: double.parse(carbs.toStringAsFixed(1)),
      fatPer100g: double.parse(fat.toStringAsFixed(1)),
      imageUrl: (product['image_front_small_url'] as String?) ?? '',
      tags: const ['barcode-scanned', 'open-food-facts'],
      description: 'Barcode $barcode · Verified via Open Food Facts (ODbL v1.0).',
      servingUnit: 'serving',
      servingWeightGrams: servingWeight,
      servingDescription: servingLabel,
      budgetTier: BudgetLevel.medium,
      fdcId: 'OFF:$barcode',
      source: attributionSource,
      microsPer100g: micros,
    );
  }

  static FoodCategory _inferCategory(
    Object? rawTags,
    double protein,
    double carbs,
    double fat,
  ) {
    final joined = rawTags is List
        ? rawTags.map((e) => e.toString().toLowerCase()).join(' ')
        : '';
    if (joined.contains('supplement') || joined.contains('protein-powder')) {
      return FoodCategory.protein;
    }
    if (joined.contains('dairy') ||
        joined.contains('yogurt') ||
        joined.contains('milk') ||
        joined.contains('cheese')) {
      return FoodCategory.dairy;
    }
    if (joined.contains('cereal') ||
        joined.contains('oat') ||
        joined.contains('bread') ||
        joined.contains('pasta')) {
      return FoodCategory.carbs;
    }
    if (joined.contains('fruit')) return FoodCategory.fruits;
    if (joined.contains('vegetable')) return FoodCategory.vegetables;
    if (protein >= 20 && protein >= carbs) return FoodCategory.protein;
    return FoodCategory.snacks;
  }
}
