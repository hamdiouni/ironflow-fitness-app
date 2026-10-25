import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/hive_nutrition_datasource.dart';
import 'package:progression_tracker/features/nutrition/data/models/meal_model.dart';
import 'package:progression_tracker/features/nutrition/data/models/nutrition_targets_model.dart';

void main() {
  late Directory tempDir;
  late Box<Map> mealsBox;
  late Box<Map> targetsBox;
  late HiveNutritionDatasource dataSource;

  MealModel meal({required String id, required DateTime timestamp}) {
    return MealModel(
      id: id,
      name: 'Breakfast',
      macros: const MealMacrosModel(
        calories: 500,
        protein: 30,
        carbs: 50,
        fats: 20,
      ),
      micros: const MealMicrosModel(
        fiber: 0,
        sugar: 0,
        sodium: 0,
        potassium: 0,
      ),
      vitamins: const MealVitaminsModel(
        vitaminA: 0,
        vitaminB: 0,
        vitaminC: 0,
        vitaminD: 0,
        vitaminE: 0,
      ),
      minerals: const MealMineralsModel(
        calcium: 0,
        iron: 0,
        magnesium: 0,
        zinc: 0,
      ),
      timestamp: timestamp.toIso8601String(),
      userId: 'Alice',
      updatedAt: '2026-01-01T00:00:00.000',
    );
  }

  NutritionTargetsModel targets({
    String userId = 'Alice',
    double calories = 2200,
  }) {
    return NutritionTargetsModel(
      userId: userId,
      macros: MacroTargetsModel(
        calories: calories,
        protein: 160,
        carbs: 220,
        fats: 75,
      ),
      micros: MicroTargetsModel(
        fiber: 30,
        sugar: 50,
        sodium: 2000,
        potassium: 3000,
      ),
      vitamins: VitaminTargetsModel(
        vitaminA: 900,
        vitaminB: 2,
        vitaminC: 90,
        vitaminD: 20,
        vitaminE: 15,
      ),
      minerals: MineralTargetsModel(
        calcium: 1000,
        iron: 18,
        magnesium: 400,
        zinc: 11,
      ),
      createdAt: '2026-01-01T00:00:00.000',
      updatedAt: '2026-01-01T00:00:00.000',
    );
  }

  Future<void> letStreamSubscribe() {
    return Future<void>.delayed(const Duration(milliseconds: 10));
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_nutrition_stream_');
    Hive.init(tempDir.path);
    mealsBox = await Hive.openBox<Map>('meals');
    targetsBox = await Hive.openBox<Map>('macro_targets');
  });

  setUp(() async {
    await mealsBox.clear();
    await targetsBox.clear();
    dataSource = HiveNutritionDatasource();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('watchNutritionChanges starts at zero', () async {
    await expectLater(dataSource.watchNutritionChanges().first, completion(0));
  });

  test('watchNutritionChanges ticks for meal and target box writes',
      () async {
    final ticksFuture = dataSource.watchNutritionChanges().take(4).toList();
    await letStreamSubscribe();

    await dataSource.saveMealEntry(
      meal(id: 'meal-1', timestamp: DateTime(2026, 1, 2, 8)),
    );
    await letStreamSubscribe();
    await dataSource.saveNutritionTargets(targets());
    await letStreamSubscribe();
    await dataSource.deleteMealEntry('meal-1');

    final ticks = await ticksFuture.timeout(const Duration(seconds: 5));

    expect(ticks, <int>[0, 1, 2, 3]);
  });

  test('nutrition targets are stored separately for each user', () async {
    await dataSource.saveNutritionTargets(
      targets(userId: 'Alice', calories: 2200),
      userId: 'Alice',
    );
    await dataSource.saveNutritionTargets(
      targets(userId: 'bob', calories: 1800),
      userId: 'bob',
    );

    final aliceTargets =
        await dataSource.getNutritionTargets(userId: 'Alice');
    final bobTargets = await dataSource.getNutritionTargets(userId: 'bob');

    expect(aliceTargets?.userId, 'Alice');
    expect(aliceTargets?.macros.calories, 2200);
    expect(bobTargets?.userId, 'bob');
    expect(bobTargets?.macros.calories, 1800);
    expect(targetsBox.containsKey('current_alice'), isTrue);
    expect(targetsBox.containsKey('current_bob'), isTrue);
    expect(targetsBox.containsKey('current'), isFalse);
  });

  test('exact-owner legacy targets migrate to the scoped key', () async {
    await targetsBox.put('current', targets(userId: 'Alice').toJson());

    final stored = await dataSource.getNutritionTargets(userId: 'Alice');

    expect(stored?.userId, 'Alice');
    expect(targetsBox.containsKey('current_alice'), isTrue);
    expect(targetsBox.containsKey('current'), isFalse);
  });

  test('foreign legacy targets are not adopted by another user', () async {
    await targetsBox.put('current', targets(userId: 'bob').toJson());

    final stored = await dataSource.getNutritionTargets(userId: 'Alice');

    expect(stored, isNull);
    expect(targetsBox.containsKey('current_alice'), isFalse);
    expect(targetsBox.containsKey('current'), isTrue);
  });

  test('deleteNutritionTargets removes only the requested user target',
      () async {
    await dataSource.saveNutritionTargets(targets(userId: 'Alice'));
    await dataSource.saveNutritionTargets(targets(userId: 'bob'));

    await dataSource.deleteNutritionTargets(userId: 'Alice');

    expect(await dataSource.getNutritionTargets(userId: 'Alice'), isNull);
    expect((await dataSource.getNutritionTargets(userId: 'bob'))?.userId, 'bob');
  });
}
