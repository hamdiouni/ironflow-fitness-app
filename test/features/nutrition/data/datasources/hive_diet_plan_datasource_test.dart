import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/hive_diet_plan_datasource.dart';
import 'package:progression_tracker/features/nutrition/data/models/diet_plan_state_model.dart';

void main() {
  late Directory tempDir;
  late Box<dynamic> authSessionBox;
  late HiveDietPlanDataSource dataSource;

  DietPlanStateModel planModel(String name) => DietPlanStateModel(
        plan: DietPlanModel(
          name: name,
          dailyCalories: 2000,
          proteinG: 150,
          carbsG: 200,
          fatsG: 60,
          days: const [],
          tips: const [],
        ),
      );

  Future<void> signInAs(String userId) async {
    await authSessionBox.put('is_logged_in', true);
    await authSessionBox.put('user_id', userId);
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('diet_plan_scope_test_');
    Hive.init(tempDir.path);
    authSessionBox = await Hive.openBox<dynamic>('auth_session');
    await Hive.openBox<Map>('diet_plan');
  });

  setUp(() async {
    await authSessionBox.clear();
    await Hive.box<Map>('diet_plan').clear();
    dataSource = HiveDietPlanDataSource();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('diet plans are stored and loaded per signed-in account', () async {
    await signInAs('Alice');
    await dataSource.saveDietPlan(planModel('Alice plan'));
    expect((await dataSource.loadDietPlan())?.plan.name, 'Alice plan');

    await signInAs('bob');
    expect(await dataSource.loadDietPlan(), isNull);

    await dataSource.saveDietPlan(planModel('Bob plan'));
    expect((await dataSource.loadDietPlan())?.plan.name, 'Bob plan');

    await signInAs('Alice');
    expect((await dataSource.loadDietPlan())?.plan.name, 'Alice plan');
  });
}
