import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/core/catalog/catalog_search_index.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/hive_food_datasource.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';
import 'package:progression_tracker/features/nutrition/domain/services/food_catalog.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_definition.dart';
import 'package:progression_tracker/features/workout/domain/services/exercise_catalog.dart';

class _DiskAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = await File(key).readAsBytes();
    return ByteData.view(bytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return File(key).readAsString();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wave 3.4 Lazy JSON Catalog + Isolate Search Index Parity & Benchmarks', () {
    late Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('ironflow_catalog_idx_');
      Hive.init(tempDir.path);
      await Hive.openBox('foods');
      await Hive.openBox('custom_foods');
    });

    tearDownAll(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Exercise JSON catalog matches ExerciseCatalog 1:1 and searches accurately', () async {
      final bundle = _DiskAssetBundle();
      final swLoad = Stopwatch()..start();
      final index = await LazyJsonCatalogLoader.loadExercisesIndex(bundle: bundle);
      swLoad.stop();

      expect(index.length, 129);
      expect(index.length, ExerciseCatalog.all.length);

      for (final expected in ExerciseCatalog.all) {
        final actual = index.getById(expected.id);
        expect(actual, isNotNull, reason: 'Missing exercise ${expected.id}');
        expect(actual!.name, expected.name);
        expect(actual.muscleGroup, expected.muscleGroup);
        expect(actual.equipment, expected.equipment);
        expect(actual.primaryRegions, expected.primaryRegions);
        expect(actual.secondaryRegions, expected.secondaryRegions);
      }

      final swSearch = Stopwatch()..start();
      List<ExerciseDefinition> benchHits = const [];
      for (var i = 0; i < 1000; i++) {
        benchHits = index.search('barbell bench');
      }
      swSearch.stop();

      expect(benchHits.map((e) => e.id), contains('chest_001'));
      final rearDeltHits = index.search('rear');
      expect(rearDeltHits, isNotEmpty);

      debugPrint(
        '[BENCHMARK] Exercises JSON (129 items): load+isolateIndex=${swLoad.elapsedMicroseconds}us, '
        '1000x search=${swSearch.elapsedMicroseconds}us',
      );
    });

    test('Food JSON catalog matches FoodCatalog 1:1 and keeps user custom foods separate', () async {
      final bundle = _DiskAssetBundle();
      await FoodCatalog.ensureLoaded(bundle: bundle);
      final swLoad = Stopwatch()..start();
      final index = await LazyJsonCatalogLoader.loadFoodsIndex(bundle: bundle);
      swLoad.stop();

      expect(index.length, 282);
      expect(index.length, FoodCatalog.foods.length);

      for (final expected in FoodCatalog.foods) {
        final actual = index.getById(expected.id);
        expect(actual, isNotNull, reason: 'Missing food ${expected.id}');
        expect(actual!.name, expected.name);
        expect(actual.category, expected.category);
        expect(actual.caloriesPer100g, closeTo(expected.caloriesPer100g, 0.001));
        expect(actual.proteinPer100g, closeTo(expected.proteinPer100g, 0.001));
        expect(actual.carbsPer100g, closeTo(expected.carbsPer100g, 0.001));
        expect(actual.fatPer100g, closeTo(expected.fatPer100g, 0.001));
        expect(actual.budgetTier, expected.budgetTier);
      }

      final swSearch = Stopwatch()..start();
      List<FoodItem> chickenHits = const [];
      for (var i = 0; i < 1000; i++) {
        chickenHits = index.search('chicken breast');
      }
      swSearch.stop();

      expect(chickenHits.map((f) => f.id), contains('usda_chicken_breast_raw'));

      // User custom food stored in Hive stays separate per user and out of static catalog
      final user1CustomDs = HiveFoodDataSource(userId: 'user_1');
      final user2CustomDs = HiveFoodDataSource(userId: 'user_2');
      await user1CustomDs.saveCustomFood(
        const FoodItem(
          id: 'custom_protein_pancake_u1',
          name: 'My Homemade Protein Pancake',
          category: FoodCategory.protein,
          caloriesPer100g: 310,
          proteinPer100g: 32,
          carbsPer100g: 28,
          fatPer100g: 6,
          imageUrl: '',
          microsPer100g: FoodMicros(
            fiberGrams: 3,
            sugarGrams: 4,
            sodiumMg: 180,
            potassiumMg: 210,
            calciumMg: 80,
            ironMg: 1.2,
            magnesiumMg: 20,
            zincMg: 1.0,
          ),
        ),
      );
      final user1Custom = await user1CustomDs.getCustomFoods();
      final user2Custom = await user2CustomDs.getCustomFoods();
      expect(user1Custom.map((f) => f.id), contains('custom_protein_pancake_u1'));
      expect(user2Custom, isEmpty);
      expect(index.getById('custom_protein_pancake_u1'), isNull);
      expect(FoodCatalog.getFoodById('custom_protein_pancake_u1'), isNull);

      debugPrint(
        '[BENCHMARK] Foods JSON (282 items): load+isolateIndex=${swLoad.elapsedMicroseconds}us, '
        '1000x search=${swSearch.elapsedMicroseconds}us',
      );
    });
  });
}
