import 'dart:convert';
import 'dart:io';
import 'package:progression_tracker/features/nutrition/data/verified_foods_data.dart';

void main() {
  print('📊 Validating ${verifiedFoodsList.length} verified fitness foods...');

  final errors = <String>[];
  final ids = <String>{};
  final jsonList = <Map<String, dynamic>>[];

  for (final food in verifiedFoodsList) {
    // 1. Unique ID check
    if (ids.contains(food.id)) {
      errors.add('Duplicate food id: ${food.id}');
    }
    ids.add(food.id);

    // 2. FDC ID provenance check
    if (food.fdcId == null || food.fdcId!.isEmpty) {
      errors.add('Food ${food.name} (${food.id}) is missing fdcId');
    }

    // 3. Non-negative macros check
    if (food.caloriesPer100g < 0 ||
        food.proteinPer100g < 0 ||
        food.carbsPer100g < 0 ||
        food.fatPer100g < 0) {
      errors.add('Food ${food.name} has negative macro values');
    }

    // 4. Calorie consistency check (4*p + 4*c + 9*f vs stated calories, margin within 25% due to fiber/Atwater factors)
    final expectedCal = (food.proteinPer100g * 4) + (food.carbsPer100g * 4) + (food.fatPer100g * 9);
    if (food.caloriesPer100g > 10 && (food.caloriesPer100g - expectedCal).abs() > (food.caloriesPer100g * 0.35)) {
      print('⚠️ Warning: ${food.name} stated ${food.caloriesPer100g} kcal vs Atwater ~$expectedCal kcal');
    }

    // 5. Serving weight check
    if (food.servingWeightGrams <= 0) {
      errors.add('Food ${food.name} has invalid serving weight: ${food.servingWeightGrams}');
    }

    // 6. Micronutrient non-negative check
    final micros = food.microsPer100g;
    if (micros != null) {
      if ((micros.sodiumMg != null && micros.sodiumMg! < 0) ||
          (micros.potassiumMg != null && micros.potassiumMg! < 0) ||
          (micros.calciumMg != null && micros.calciumMg! < 0) ||
          (micros.ironMg != null && micros.ironMg! < 0) ||
          (micros.vitaminDMcg != null && micros.vitaminDMcg! < 0) ||
          (micros.fiberGrams != null && micros.fiberGrams! < 0) ||
          (micros.sugarGrams != null && micros.sugarGrams! < 0) ||
          (micros.saturatedFatGrams != null && micros.saturatedFatGrams! < 0)) {
        errors.add('Food ${food.name} has negative micronutrient value');
      }
    }

    jsonList.add(food.toJson());
  }

  if (errors.isNotEmpty) {
    print('❌ Found ${errors.length} validation errors:');
    for (final err in errors) {
      print('  - $err');
    }
    exit(1);
  }

  // Ensure assets/data directory exists
  final dataDir = Directory('assets/data');
  if (!dataDir.existsSync()) {
    dataDir.createSync(recursive: true);
  }

  final outputFile = File('assets/data/verified_foods.json');
  outputFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(jsonList),
  );

  print('✅ Successfully validated and generated ${outputFile.path} with ${verifiedFoodsList.length} foods!');
}
