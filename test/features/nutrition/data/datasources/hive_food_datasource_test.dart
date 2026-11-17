import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/firestore_food_datasource.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/hive_food_datasource.dart';
import 'package:progression_tracker/features/nutrition/data/repositories/food_repository_impl.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';

void main() {
  late Directory tempDir;
  late Box foodsBox;
  late Box customFoodsBox;

  FoodItem food({required String id, required String name}) {
    return FoodItem(
      id: id,
      name: name,
      category: FoodCategory.custom,
      rawCategory: 'Test',
      caloriesPer100g: 100,
      proteinPer100g: 10,
      carbsPer100g: 10,
      fatPer100g: 2,
      imageUrl: '',
      microsPer100g: const FoodMicros(
        fiberGrams: 1,
        sugarGrams: 1,
        sodiumMg: 10,
        potassiumMg: 20,
      ),
    );
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_food_scope_');
    Hive.init(tempDir.path);
    foodsBox = await Hive.openBox('foods');
    customFoodsBox = await Hive.openBox('custom_foods');
  });

  setUp(() async {
    await foodsBox.clear();
    await customFoodsBox.clear();
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
    await aliceSource.cacheFoods(<FoodItem>[
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
    expect(customFoodsBox.containsKey('custom_foods_alice'), isTrue);
    expect(customFoodsBox.containsKey('custom_foods_bob'), isTrue);
    expect(customFoodsBox.containsKey('custom_foods'), isFalse);
    expect(foodsBox.containsKey('custom_foods_alice'), isFalse);
    expect(foodsBox.containsKey('custom_foods_bob'), isFalse);
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
    expect(customFoodsBox.containsKey('custom_foods_alice'), isTrue);
    expect(customFoodsBox.containsKey('custom_foods'), isFalse);
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

  test('upsertCachedFood preserves existing cached foods and updates matching id in place (Wave 1.7e)', () async {
    final ds = HiveFoodDataSource(userId: 'u1');
    await ds.cacheFoods(<FoodItem>[
      food(id: 'f1', name: 'Oats'),
    ]);

    await ds.upsertCachedFood(food(id: 'f2', name: 'Greek Yogurt'));
    final afterInsert = await ds.getCachedFoods();
    expect(afterInsert.map((f) => f.id).toList(), <String>['f1', 'f2']);

    await ds.upsertCachedFood(food(id: 'f1', name: 'Rolled Oats'));
    final afterUpdate = await ds.getCachedFoods();
    expect(afterUpdate.length, 2);
    expect(afterUpdate.firstWhere((f) => f.id == 'f1').name, 'Rolled Oats');
  });

  test('FoodRepositoryImpl.getFoodById upserts into cache without clobbering existing entries (Wave 1.7e)', () async {
    final ds = HiveFoodDataSource(userId: 'u1');
    await ds.cacheFoods(<FoodItem>[
      food(id: 'f1', name: 'Existing Oats'),
    ]);

    final repo = FoodRepositoryImpl(
      firestoreDataSource: _FakeFirestoreFoodDatasource({
        'f2': food(id: 'f2', name: 'Fetched Banana'),
      }),
      hiveDataSource: ds,
    );

    final fetched = await repo.getFoodById('f2');
    expect(fetched?.name, 'Fetched Banana');

    final cached = await ds.getCachedFoods();
    expect(cached.map((f) => f.id).toList(), <String>['f1', 'f2']);
  });
}

class _FakeFirestoreFoodDatasource extends Fake
    implements FirestoreFoodDatasource {
  _FakeFirestoreFoodDatasource(this.foodsById);

  final Map<String, FoodItem> foodsById;

  @override
  Future<FoodItem?> getFoodById(String id) async => foodsById[id];
}
