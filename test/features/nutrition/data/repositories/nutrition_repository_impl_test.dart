import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/hive_nutrition_datasource.dart';
import 'package:progression_tracker/features/nutrition/data/models/meal_model.dart';
import 'package:progression_tracker/features/nutrition/data/models/nutrition_targets_model.dart';
import 'package:progression_tracker/features/nutrition/data/repositories/nutrition_repository_impl.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';

void main() {
  late Directory tempDir;
  late Box<Map> mealsBox;
  late Box<Map> targetsBox;
  late NutritionRepositoryImpl repository;
  late List<Meal> savedMealCallbacks;
  late List<String> deletedMealCallbacks;
  late List<NutritionTargetsModel> savedTargetCallbacks;

  Meal meal({
    required String id,
    required DateTime timestamp,
    double calories = 100,
    double protein = 10,
    double carbs = 20,
    double fats = 5,
    String? userId,
  }) {
    return Meal(
      id: id,
      name: 'Meal $id',
      macros: MealMacros(
        calories: calories,
        protein: protein,
        carbs: carbs,
        fats: fats,
      ),
      micros: const MealMicros(
        fiber: 0,
        sugar: 0,
        sodium: 0,
        potassium: 0,
      ),
      vitamins: const MealVitamins(
        vitaminA: 0,
        vitaminB: 0,
        vitaminC: 0,
        vitaminD: 0,
        vitaminE: 0,
      ),
      minerals: const MealMinerals(
        calcium: 0,
        iron: 0,
        magnesium: 0,
        zinc: 0,
      ),
      timestamp: timestamp,
      userId: userId,
    );
  }

  NutritionTargets targets({String userId = 'Alice'}) {
    return NutritionTargets(
      userId: userId,
      macros: const MacroTargets(
        calories: 2000,
        protein: 150,
        carbs: 200,
        fats: 60,
      ),
      micros: const MicroTargets(
        fiber: 30,
        sugar: 50,
        sodium: 2000,
        potassium: 3000,
      ),
      vitamins: const VitaminTargets(
        vitaminA: 900,
        vitaminB: 2,
        vitaminC: 90,
        vitaminD: 20,
        vitaminE: 15,
      ),
      minerals: const MineralTargets(
        calcium: 1000,
        iron: 18,
        magnesium: 400,
        zinc: 11,
      ),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  Future<void> saveAll(List<Meal> meals) async {
    for (final item in meals) {
      await repository.saveMealEntry(item);
    }
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('nutrition_repository_');
    Hive.init(tempDir.path);
    mealsBox = await Hive.openBox<Map>('meals');
    targetsBox = await Hive.openBox<Map>('macro_targets');
  });

  setUp(() async {
    await mealsBox.clear();
    await targetsBox.clear();
    savedMealCallbacks = <Meal>[];
    deletedMealCallbacks = <String>[];
    savedTargetCallbacks = <NutritionTargetsModel>[];
    repository = NutritionRepositoryImpl(
      hiveDataSource: HiveNutritionDatasource(),
      userId: 'Alice',
      onMealSaved: (item) async {
        savedMealCallbacks.add(item);
      },
      onMealDeleted: (id) async {
        deletedMealCallbacks.add(id);
      },
      onTargetsSaved: (item) async {
        savedTargetCallbacks.add(item);
      },
    );
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('save stamps the repository owner and updatedAt before callbacks',
      () async {
    final before = DateTime.now().subtract(const Duration(seconds: 1));
    await repository.saveMealEntry(
      meal(id: 'breakfast', timestamp: DateTime(2026, 1, 2, 8)),
    );
    final after = DateTime.now().add(const Duration(seconds: 1));

    final meals = await repository.getMealsByDate(DateTime(2026, 1, 2, 23));

    expect(meals, hasLength(1));
    expect(meals.single.userId, 'Alice');
    expect(meals.single.updatedAt, isNotNull);
    expect(meals.single.updatedAt!.isBefore(before), isFalse);
    expect(meals.single.updatedAt!.isAfter(after), isFalse);

    expect(savedMealCallbacks, hasLength(1));
    expect(savedMealCallbacks.single.id, 'breakfast');
    expect(savedMealCallbacks.single.userId, 'Alice');
    expect(savedMealCallbacks.single.updatedAt, meals.single.updatedAt);
  });

  test('daily summary totals only the requested calendar day', () async {
    await repository.saveNutritionTargets(targets());
    await saveAll(<Meal>[
      meal(
        id: 'breakfast',
        timestamp: DateTime(2026, 1, 2, 8),
        calories: 300,
        protein: 20,
        carbs: 30,
        fats: 10,
      ),
      meal(
        id: 'lunch',
        timestamp: DateTime(2026, 1, 2, 13),
        calories: 500,
        protein: 35,
        carbs: 45,
        fats: 15,
      ),
      meal(
        id: 'next-day',
        timestamp: DateTime(2026, 1, 3, 8),
        calories: 900,
      ),
    ]);

    final summary =
        await repository.getDailyNutrition(DateTime(2026, 1, 2, 23, 59));

    expect(summary.meals.map((item) => item.id),
        containsAll(<String>['breakfast', 'lunch']));
    expect(summary.meals, hasLength(2));
    expect(summary.totalCalories, 800);
    expect(summary.totalProtein, 55);
    expect(summary.totalCarbs, 75);
    expect(summary.totalFats, 25);
    expect(summary.target?.userId, 'Alice');
    expect(summary.target?.macros.calories, 2000);
  });

  test('history groups by day descending and excludes exact boundaries',
      () async {
    final start = DateTime(2026, 1, 1);
    final end = DateTime(2026, 1, 3);
    await saveAll(<Meal>[
      meal(id: 'at-start', timestamp: start),
      meal(id: 'day-1', timestamp: DateTime(2026, 1, 1, 12)),
      meal(id: 'day-2', timestamp: DateTime(2026, 1, 2, 12)),
      meal(id: 'at-end', timestamp: end),
    ]);

    final history = await repository.getNutritionHistory(start, end);

    expect(
      history.map((item) => item.date),
      <DateTime>[DateTime(2026, 1, 2), DateTime(2026, 1, 1)],
    );
    expect(history[0].meals.map((item) => item.id), <String>['day-2']);
    expect(history[1].meals.map((item) => item.id), <String>['day-1']);
  });

  test('history pagination and count use unique meal dates', () async {
    await saveAll(<Meal>[
      meal(id: 'day-1-breakfast', timestamp: DateTime(2026, 1, 1, 8)),
      meal(id: 'day-1-lunch', timestamp: DateTime(2026, 1, 1, 13)),
      meal(id: 'day-2', timestamp: DateTime(2026, 1, 2, 8)),
      meal(id: 'day-3', timestamp: DateTime(2026, 1, 3, 8)),
      meal(id: 'day-4', timestamp: DateTime(2026, 1, 4, 8)),
    ]);

    final firstPage =
        await repository.getNutritionHistoryPaginated(offset: 0, limit: 2);
    final secondPage =
        await repository.getNutritionHistoryPaginated(offset: 2, limit: 2);

    expect(await repository.getNutritionHistoryCount(), 4);
    expect(
      firstPage.map((item) => item.date),
      <DateTime>[DateTime(2026, 1, 4), DateTime(2026, 1, 3)],
    );
    expect(
      secondPage.map((item) => item.date),
      <DateTime>[DateTime(2026, 1, 2), DateTime(2026, 1, 1)],
    );
    expect(secondPage.last.meals, hasLength(2));
  });

  test('targets round-trip and delete uses the delete callback', () async {
    await repository.saveNutritionTargets(targets());
    await repository.saveMealEntry(
      meal(id: 'delete-me', timestamp: DateTime(2026, 1, 2, 8)),
    );

    final storedTargets = await repository.getNutritionTargets();

    expect(storedTargets?.userId, 'Alice');
    expect(storedTargets?.macros.protein, 150);
    expect(savedTargetCallbacks, hasLength(1));
    expect(savedTargetCallbacks.single.userId, 'Alice');

    await repository.deleteMealEntry('delete-me');

    expect(await repository.getMealsByDate(DateTime(2026, 1, 2)), isEmpty);
    expect(deletedMealCallbacks, <String>['delete-me']);
  });

  test('clearAllData removes stored meals and targets', () async {
    await repository.saveNutritionTargets(targets());
    await repository.saveMealEntry(
      meal(id: 'meal-1', timestamp: DateTime(2026, 1, 2, 8)),
    );

    await repository.clearAllData();

    expect(await repository.getMealsByDate(DateTime(2026, 1, 2)), isEmpty);
    expect(await repository.getNutritionTargets(), isNull);
    expect(await repository.getNutritionHistoryCount(), 0);
  });

  test('reads include legacy meals and exclude foreign meals and targets',
      () async {
    final dataSource = HiveNutritionDatasource();
    final bobRepository = NutritionRepositoryImpl(
      hiveDataSource: dataSource,
      userId: 'bob',
    );

    await bobRepository.saveNutritionTargets(targets(userId: 'bob'));
    await bobRepository.saveMealEntry(
      meal(id: 'bob-jan-2', timestamp: DateTime(2026, 1, 2, 9), calories: 900),
    );
    await bobRepository.saveMealEntry(
      meal(id: 'bob-jan-4', timestamp: DateTime(2026, 1, 4, 9)),
    );
    await repository.saveMealEntry(
      meal(id: 'Alice-jan-2', timestamp: DateTime(2026, 1, 2, 8), calories: 300),
    );
    await dataSource.saveMealEntry(
      MealModel.fromEntity(
        meal(id: 'legacy-jan-2', timestamp: DateTime(2026, 1, 2, 12), calories: 200),
      ),
    );
    await dataSource.saveMealEntry(
      MealModel.fromEntity(
        meal(
          id: 'guest-jan-3',
          timestamp: DateTime(2026, 1, 3, 9),
          userId: 'local-user',
        ),
      ),
    );

    final daily =
        await repository.getDailyNutrition(DateTime(2026, 1, 2, 23, 59));
    final mealsForDay =
        await repository.getMealsByDate(DateTime(2026, 1, 2, 23, 59));
    final history = await repository.getNutritionHistory(
      DateTime(2026, 1, 1),
      DateTime(2026, 1, 5),
    );
    final firstPage =
        await repository.getNutritionHistoryPaginated(offset: 0, limit: 1);
    final secondPage =
        await repository.getNutritionHistoryPaginated(offset: 1, limit: 1);

    expect(daily.meals.map((item) => item.id),
        containsAll(<String>['Alice-jan-2', 'legacy-jan-2']));
    expect(daily.meals, hasLength(2));
    expect(daily.totalCalories, 500);
    expect(daily.target, isNull);
    expect(mealsForDay.map((item) => item.id),
        containsAll(<String>['Alice-jan-2', 'legacy-jan-2']));
    expect(mealsForDay, hasLength(2));
    expect(
      history.map((item) => item.date),
      <DateTime>[DateTime(2026, 1, 3), DateTime(2026, 1, 2)],
    );
    expect(await repository.getNutritionHistoryCount(), 2);
    expect(firstPage.single.date, DateTime(2026, 1, 3));
    expect(firstPage.single.meals.map((item) => item.id), <String>['guest-jan-3']);
    expect(secondPage.single.date, DateTime(2026, 1, 2));
    expect(secondPage.single.meals, hasLength(2));
    expect(await repository.getNutritionTargets(), isNull);
  });

  test('foreign meal and target writes are refused without callbacks',
      () async {
    final bobRepository = NutritionRepositoryImpl(
      hiveDataSource: HiveNutritionDatasource(),
      userId: 'bob',
    );
    await bobRepository.saveNutritionTargets(targets(userId: 'bob'));
    await bobRepository.saveMealEntry(
      meal(id: 'bob-meal', timestamp: DateTime(2026, 1, 2, 8), calories: 400),
    );

    savedMealCallbacks.clear();
    deletedMealCallbacks.clear();
    savedTargetCallbacks.clear();

    await repository.saveMealEntry(
      meal(id: 'new-bob', timestamp: DateTime(2026, 1, 3, 8), userId: 'bob'),
    );
    await repository.saveMealEntry(
      meal(id: 'bob-meal', timestamp: DateTime(2026, 1, 4, 8), calories: 999),
    );
    await repository.deleteMealEntry('bob-meal');
    await repository.saveNutritionTargets(targets(userId: 'bob'));
    await repository.saveNutritionTargets(targets(userId: 'Alice'));

    final bobMeals = await bobRepository.getMealsByDate(DateTime(2026, 1, 2));
    expect(bobMeals, hasLength(1));
    expect(bobMeals.single.id, 'bob-meal');
    expect(bobMeals.single.macros.calories, 400);
    expect(await bobRepository.getMealsByDate(DateTime(2026, 1, 3)), isEmpty);
    expect((await bobRepository.getNutritionTargets())?.userId, 'bob');
    expect(savedMealCallbacks, isEmpty);
    expect(deletedMealCallbacks, isEmpty);
    expect(savedTargetCallbacks, isEmpty);
  });

  test('legacy target saved by a scoped repository is retagged', () async {
    await repository.saveNutritionTargets(targets(userId: 'local-user'));

    expect(savedTargetCallbacks.single.userId, 'Alice');
    expect((await repository.getNutritionTargets())?.userId, 'Alice');
  });
}
