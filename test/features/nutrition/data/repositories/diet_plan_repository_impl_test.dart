import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/hive_diet_plan_datasource.dart';
import 'package:progression_tracker/features/nutrition/data/repositories/diet_plan_repository_impl.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/diet_plan.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/diet_plan_state.dart';

void main() {
  late Directory tempDir;
  late Box<Map> dietPlanBox;
  late HiveDietPlanDataSource dataSource;

  DietPlanState planState(String name) {
    return DietPlanState(
      plan: DietPlan(
        name: name,
        dailyCalories: 2000,
        proteinG: 150,
        carbsG: 200,
        fatsG: 60,
        days: const <DietDay>[],
        tips: const <String>[],
      ),
    );
  }

  DietPlanRepositoryImpl repositoryFor(String userId) {
    return DietPlanRepositoryImpl(dataSource, userId: userId);
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('diet_plan_repository_');
    Hive.init(tempDir.path);
    dietPlanBox = await Hive.openBox<Map>('diet_plan');
  });

  setUp(() async {
    await dietPlanBox.clear();
    dataSource = HiveDietPlanDataSource();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('repository passes its explicit user id to diet plan storage',
      () async {
    final aliceRepository = repositoryFor('Alice');
    final bobRepository = repositoryFor('bob');

    expect(aliceRepository.userId, 'Alice');
    expect(bobRepository.userId, 'bob');

    await aliceRepository.saveDietPlan(planState('Alice plan'));
    expect((await aliceRepository.loadDietPlan())?.plan.name, 'Alice plan');
    expect(await bobRepository.loadDietPlan(), isNull);

    await bobRepository.saveDietPlan(planState('Bob plan'));
    expect((await bobRepository.loadDietPlan())?.plan.name, 'Bob plan');
    expect((await aliceRepository.loadDietPlan())?.plan.name, 'Alice plan');

    await aliceRepository.clearDietPlan();

    expect(await aliceRepository.loadDietPlan(), isNull);
    expect((await bobRepository.loadDietPlan())?.plan.name, 'Bob plan');
  });
}
