import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/core/utils/data_migration.dart';
import 'package:progression_tracker/core/utils/hive_manager.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('data_migration_v4_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    HiveManager.resetForTest();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('v3 to v4 migrates custom_foods out of foods box and normalizes storageScope keys', () async {
    final settings = await Hive.openBox<String>('app_settings');
    await settings.put('schema_version', '3');
    await settings.put('exercise_alias_migration_version', '1');

    final foods = await Hive.openBox<dynamic>('foods');
    await foods.put('foods_cache', [
      {'id': 'oats', 'name': 'Oats'},
    ]);
    await foods.put('custom_foods', [
      {'id': 'custom_legacy', 'name': 'Legacy Shake'},
    ]);
    await foods.put('custom_foods_Alice', [
      {'id': 'custom_alice', 'name': 'Alice Pancake'},
    ]);

    final userProfile = await Hive.openBox<dynamic>('user_profile');
    await userProfile.put('profile_Alice', '{"name":"Alice"}');
    await userProfile.put('onboarded_Alice', true);

    final dietPlan = await Hive.openBox<Map>('diet_plan');
    await dietPlan.put('current_diet_plan_Alice', {'calories': 2400});

    final customFoods = await Hive.openBox<dynamic>('custom_foods');

    await DataMigration.runIfNeeded(currentUserId: 'Alice');

    expect(settings.get('schema_version'), '${DataMigration.currentSchemaVersion}');
    expect(DataMigration.currentSchemaVersion, greaterThanOrEqualTo(4));

    // Legacy custom_foods moved into dedicated custom_foods box & normalized via storageScope
    expect(customFoods.get('custom_foods'), [{'id': 'custom_legacy', 'name': 'Legacy Shake'}]);
    expect(customFoods.get('custom_foods_alice'), [{'id': 'custom_alice', 'name': 'Alice Pancake'}]);
    expect(foods.containsKey('custom_foods'), isFalse);
    expect(foods.containsKey('custom_foods_Alice'), isFalse);
    // Catalog cache inside foods stays intact
    expect(foods.get('foods_cache'), [{'id': 'oats', 'name': 'Oats'}]);

    // user_profile & diet_plan keys normalized via RecordOwnershipRules.storageScope
    expect(userProfile.get('profile_alice'), '{"name":"Alice"}');
    expect(userProfile.get('onboarded_alice'), isTrue);
    expect(userProfile.containsKey('profile_Alice'), isFalse);
    expect(dietPlan.get('current_diet_plan_alice'), {'calories': 2400});
    expect(dietPlan.containsKey('current_diet_plan_Alice'), isFalse);
  });
}
