import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/hive_food_datasource.dart';
import 'package:progression_tracker/features/nutrition/data/models/food_item_full_model.dart';

void main() {
  late Directory tempDir;
  late Box foodsBox;

  FoodItemFullModel food({required String id, required String name}) {
    return FoodItemFullModel(
      id: id,
      name: name,
      category: 'Test',
      macros: const MacrosPer100gModel(
        calories: 100,
        protein: 10,
        carbs: 10,
        fats: 2,
      ),
      micros: const MicrosPer100gModel(
        fiber: 1,
        sugar: 1,
        sodium: 10,
        potassium: 20,
      ),
      vitamins: const VitaminsPer100gModel(
        vitaminA: 0,
        vitaminB: 0,
        vitaminC: 0,
        vitaminD: 0,
        vitaminE: 0,
      ),
      minerals: const MineralsPer100gModel(
        calcium: 0,
        iron: 0,
        magnesium: 0,
        zinc: 0,
      ),
      imageUrl: '',
    );
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_food_scope_');
    Hive.init(tempDir.path);
    foodsBox = await Hive.openBox('foods');
  });

  setUp(() async {
    await foodsBox.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('custom foods are stored separately for each user', () async {
    final aliceSource = HiveFoodDataSource(userId: 'Alice');
    final bobSource = HiveFoodDataSource(userId: 'bob');
    await aliceSource.cacheFoods(<FoodItemFullModel>[
      food(id: 'catalog-1', name: 'Catalog Food'),
    ]);

    await aliceSource.saveCustomFood(food(id: 'Alice-food', name: 'Alice Food'));
    await bobSource.saveCustomFood(food(id: 'bob-food', name: 'Bob Food'));

    expect(
      (await aliceSource.getCustomFoods()).map((item) => item.id),
      <String>['Alice-food'],
    );
    expect(
      (await bobSource.getCustomFoods()).map((item) => item.id),
      <String>['bob-food'],
    );
    expect(
      (await aliceSource.getCachedFoods()).map((item) => item.id),
      containsAll(<String>['catalog-1', 'Alice-food']),
    );
    expect(
      (await aliceSource.getCachedFoods()).map((item) => item.id),
      isNot(contains('bob-food')),
    );
    expect(foodsBox.containsKey('custom_foods_alice'), isTrue);
    expect(foodsBox.containsKey('custom_foods_bob'), isTrue);
    expect(foodsBox.containsKey('custom_foods'), isFalse);
  });

  test('legacy custom foods are adopted only by the first scoped user',
      () async {
    await foodsBox.put('custom_foods', <Map<String, dynamic>>[
      food(id: 'legacy-food', name: 'Legacy Food').toJson(),
    ]);
    final aliceSource = HiveFoodDataSource(userId: 'Alice');
    final bobSource = HiveFoodDataSource(userId: 'bob');

    expect(
      (await aliceSource.getCustomFoods()).map((item) => item.id),
      <String>['legacy-food'],
    );
    expect(await bobSource.getCustomFoods(), isEmpty);
    expect(foodsBox.containsKey('custom_foods_alice'), isTrue);
    expect(foodsBox.containsKey('custom_foods'), isFalse);
  });

  test('delete and clearCache do not remove another user custom foods',
      () async {
    final aliceSource = HiveFoodDataSource(userId: 'Alice');
    final bobSource = HiveFoodDataSource(userId: 'bob');
    await aliceSource.saveCustomFood(food(id: 'Alice-food', name: 'Alice Food'));
    await bobSource.saveCustomFood(food(id: 'bob-food', name: 'Bob Food'));

    await aliceSource.deleteCustomFood('bob-food');
    expect((await bobSource.getCustomFoods()).single.id, 'bob-food');

    await aliceSource.clearCache();

    expect(await aliceSource.getCustomFoods(), isEmpty);
    expect((await bobSource.getCustomFoods()).single.id, 'bob-food');
  });
}
