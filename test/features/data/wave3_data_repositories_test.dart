import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/core/services/telemetry_preferences.dart';
import 'package:progression_tracker/features/ai/data/repositories/ai_preferences_repository_impl.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/firestore_food_datasource.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/hive_food_datasource.dart';
import 'package:progression_tracker/features/nutrition/data/repositories/food_repository_impl.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';
import 'package:progression_tracker/features/settings/data/repositories/privacy_preferences_repository_impl.dart';
import 'package:progression_tracker/features/workout/data/datasources/hive_active_program_datasource.dart';
import 'package:progression_tracker/features/workout/data/models/active_program_model.dart';
import 'package:progression_tracker/features/workout/data/repositories/active_program_repository_impl.dart';
import 'package:progression_tracker/features/workout/domain/entities/active_program.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout_program.dart';
import 'package:progression_tracker/features/workout/domain/exceptions/workout_exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeFirestoreFoodDatasource extends Fake
    implements FirestoreFoodDatasource {
  _FakeFirestoreFoodDatasource(this.remoteFoods);

  List<FoodItem> remoteFoods;
  bool shouldFail = false;

  @override
  Future<FoodPageResult> getFoodsPage({
    int limit = FirestoreFoodDatasource.defaultPageSize,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    if (shouldFail) throw Exception('Firestore offline');
    final items = remoteFoods.take(limit).toList();
    return FoodPageResult(
      items: items,
      lastDocument: null,
      hasMore: false,
    );
  }

  @override
  Future<List<FoodItem>> getAllFoods({
    int limit = FirestoreFoodDatasource.maxBatchQueryLimit,
  }) async {
    if (shouldFail) throw Exception('Firestore offline');
    return remoteFoods.take(limit).toList();
  }

  @override
  Future<FoodItem?> getFoodById(String id) async {
    if (shouldFail) throw Exception('Firestore offline');
    for (final f in remoteFoods) {
      if (f.id == id) return f;
    }
    return null;
  }

  @override
  Future<List<FoodItem>> getFoodsByCategory(
    String category, {
    int limit = 100,
  }) async {
    if (shouldFail) throw Exception('Firestore offline');
    return remoteFoods
        .where((f) => f.categoryName.toLowerCase() == category.toLowerCase())
        .take(limit)
        .toList();
  }

  @override
  Future<List<FoodItem>> getFoodsByTags(
    List<String> tags, {
    int limit = 100,
  }) async {
    if (shouldFail) throw Exception('Firestore offline');
    return remoteFoods
        .where((f) => tags.any((t) => f.dietaryTags.contains(t)))
        .take(limit)
        .toList();
  }

  @override
  Future<List<FoodItem>> searchFoods(
    String query, {
    int limit = FirestoreFoodDatasource.defaultPageSize,
  }) async {
    if (shouldFail) throw Exception('Firestore offline');
    final q = query.toLowerCase();
    return remoteFoods
        .where((f) => f.name.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }

  @override
  Future<void> uploadFoods(List<FoodItem> foods) async {
    if (shouldFail) throw Exception('Firestore offline');
    remoteFoods = List<FoodItem>.from(foods);
  }

  @override
  Map<String, dynamic> foodToMap(FoodItem food) => food.toJson();

  @override
  FoodItem? mapToFoodSafe(Map<String, dynamic>? data, String id) =>
      data == null ? null : FoodItem.fromAnyJson({...data, 'id': id});

  @override
  FoodItem mapToFood(Map<String, dynamic> data, String id) =>
      FoodItem.fromAnyJson({...data, 'id': id});
}

class _FaultyActiveProgramDataSource extends HiveActiveProgramDataSource {
  Object? errorToThrow;

  @override
  Future<void> saveActiveProgram(
    ActiveProgramModel program, {
    String? userId,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return super.saveActiveProgram(program, userId: userId);
  }

  @override
  Future<ActiveProgramModel?> loadActiveProgram({String? userId}) async {
    if (errorToThrow != null) throw errorToThrow!;
    return super.loadActiveProgram(userId: userId);
  }

  @override
  Future<void> clearActiveProgram({String? userId}) async {
    if (errorToThrow != null) throw errorToThrow!;
    return super.clearActiveProgram(userId: userId);
  }
}

FoodItem _sampleFood({
  required String id,
  required String name,
  String category = 'protein',
  List<String> dietaryTags = const ['high_protein', 'gluten_free'],
}) {
  return FoodItem(
    id: id,
    name: name,
    category: FoodCategoryX.fromName(category),
    rawCategory: category,
    caloriesPer100g: 165,
    proteinPer100g: 31,
    carbsPer100g: 0,
    fatPer100g: 3.6,
    imageUrl: 'https://example.com/$id.png',
    tags: dietaryTags,
    microsPer100g: const FoodMicros(
      fiberGrams: 0,
      sugarGrams: 0,
      sodiumMg: 74,
      potassiumMg: 256,
      calciumMg: 15,
      ironMg: 1.0,
      magnesiumMg: 29,
      zincMg: 1.0,
      vitaminAMcg: 6,
      vitaminBMg: 0.6,
      vitaminCMg: 0,
      vitaminDMcg: 0.1,
      vitaminEMg: 0.3,
    ),
  );
}

ActiveProgram _sampleActiveProgram({String id = 'ap_1', String? userId}) {
  return ActiveProgram(
    id: id,
    userId: userId,
    program: WorkoutProgram(
      id: 'prog_1',
      name: 'Upper Lower 4x',
      description: 'Balanced strength & hypertrophy',
      durationWeeks: 8,
      difficulty: 'intermediate',
      userId: userId,
      days: const [
        ProgramDay(
          dayNumber: 1,
          name: 'Upper A',
          focus: 'Chest & Back',
          exercises: [
            ProgramExercise(
              exerciseName: 'Barbell Bench Press',
              exerciseDefinitionId: 'chest_001',
              sets: 4,
              reps: '6-8',
              restSeconds: 150,
            ),
          ],
        ),
      ],
    ),
    currentDayIndex: 0,
    isActive: true,
    lastWorkoutDate: null,
    completedDays: const {},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('wave3_data_repos_');
    Hive.init(tempDir.path);
    await Hive.openBox<dynamic>('foods');
    await Hive.openBox<dynamic>('custom_foods');
    await Hive.openBox<Map>('active_program');
  });

  setUp(() async {
    await Hive.box<dynamic>('foods').clear();
    await Hive.box<dynamic>('custom_foods').clear();
    await Hive.box<Map>('active_program').clear();
    SharedPreferences.setMockInitialValues({});
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('Wave 3.7 — ActiveProgramRepositoryImpl', () {
    test('stamps userId, triggers outbox hook, and round-trips save/load/update/clear',
        () async {
      final savedNotifications = <ActiveProgram>[];
      final dataSource = HiveActiveProgramDataSource();
      final repo = ActiveProgramRepositoryImpl(
        dataSource,
        userId: 'user_alpha',
        onProgramSaved: (program) async {
          savedNotifications.add(program);
        },
      );

      final initial = _sampleActiveProgram(id: 'ap_alpha');
      await repo.saveActiveProgram(initial);

      expect(savedNotifications, hasLength(1));
      expect(savedNotifications.single.userId, 'user_alpha');
      expect(savedNotifications.single.program.userId, 'user_alpha');

      final loaded = await repo.loadActiveProgram();
      expect(loaded, isNotNull);
      expect(loaded!.id, 'ap_alpha');
      expect(loaded.userId, 'user_alpha');
      expect(loaded.program.userId, 'user_alpha');

      final updated = loaded.copyWith(
        currentDayIndex: 1,
        completedDays: {0: DateTime(2026, 11, 6)},
      );
      await repo.updateActiveProgram(updated);
      expect(savedNotifications, hasLength(2));

      final reloaded = await repo.loadActiveProgram();
      expect(reloaded!.currentDayIndex, 1);
      expect(reloaded.completedDays.containsKey(0), isTrue);

      await repo.clearActiveProgram();
      expect(await repo.loadActiveProgram(), isNull);
    });

    test('swallows outbox hook errors without failing local persistence and supports archive/restore undo',
        () async {
      final dataSource = HiveActiveProgramDataSource();
      final repo = ActiveProgramRepositoryImpl(
        dataSource,
        userId: 'user_undo',
        onProgramSaved: (_) async => throw Exception('Sync queue busy'),
      );

      await repo.saveActiveProgram(_sampleActiveProgram(id: 'ap_v1'));
      expect(await repo.hasArchivedProgram(), isFalse);

      await repo.archiveCurrentProgram();
      expect(await repo.hasArchivedProgram(), isTrue);

      await repo.saveActiveProgram(_sampleActiveProgram(id: 'ap_v2'));
      expect((await repo.loadActiveProgram())!.id, 'ap_v2');

      final restored = await repo.restoreArchivedProgram();
      expect(restored, isNotNull);
      expect(restored!.id, 'ap_v1');
    });

    test('wraps HiveError, FormatException, and unexpected errors in ActiveProgramException',
        () async {
      final faulty = _FaultyActiveProgramDataSource();
      final repo = ActiveProgramRepositoryImpl(faulty, userId: 'user_err');
      final sample = _sampleActiveProgram();

      faulty.errorToThrow = HiveError('disk full');
      await expectLater(
        repo.saveActiveProgram(sample),
        throwsA(isA<ActiveProgramException>()),
      );
      await expectLater(
        repo.loadActiveProgram(),
        throwsA(isA<ActiveProgramException>()),
      );
      await expectLater(
        repo.updateActiveProgram(sample),
        throwsA(isA<ActiveProgramException>()),
      );
      await expectLater(
        repo.clearActiveProgram(),
        throwsA(isA<ActiveProgramException>()),
      );

      faulty.errorToThrow = const FormatException('bad json');
      await expectLater(
        repo.saveActiveProgram(sample),
        throwsA(isA<ActiveProgramException>()),
      );
      await expectLater(
        repo.loadActiveProgram(),
        throwsA(isA<ActiveProgramException>()),
      );
      await expectLater(
        repo.updateActiveProgram(sample),
        throwsA(isA<ActiveProgramException>()),
      );

      faulty.errorToThrow = StateError('unexpected');
      await expectLater(
        repo.saveActiveProgram(sample),
        throwsA(isA<ActiveProgramException>()),
      );
      await expectLater(
        repo.loadActiveProgram(),
        throwsA(isA<ActiveProgramException>()),
      );
      await expectLater(
        repo.updateActiveProgram(sample),
        throwsA(isA<ActiveProgramException>()),
      );
      await expectLater(
        repo.clearActiveProgram(),
        throwsA(isA<ActiveProgramException>()),
      );
    });
  });

  group('Wave 3.4 & 3.7 — FoodRepositoryImpl & HiveFoodDataSource', () {
    test('populates Hive cache from remote, searches/filters/counts, and falls back offline',
        () async {
      final seedFoods = <FoodItem>[
        _sampleFood(id: 'food_chicken', name: 'Chicken Breast', category: 'protein'),
        _sampleFood(
          id: 'food_oats',
          name: 'Rolled Oats',
          category: 'carbs',
          dietaryTags: const ['vegan', 'whole_grain'],
        ),
        _sampleFood(
          id: 'food_avocado',
          name: 'Avocado',
          category: 'fats',
          dietaryTags: const ['vegan', 'keto'],
        ),
      ];
      final remote = _FakeFirestoreFoodDatasource(seedFoods);
      final local = HiveFoodDataSource(userId: 'user_food_a');
      final repo = FoodRepositoryImpl(
        firestoreDataSource: remote,
        hiveDataSource: local,
      );

      expect(await repo.isCacheValid(), isFalse);

      final all = await repo.getAllFoods();
      expect(all.length, seedFoods.length);
      expect(await repo.isCacheValid(), isTrue);
      expect(await repo.getCachedFoodCount(), seedFoods.length);

      // JSON round-trip sanity
      final encoded = seedFoods.first.toJson();
      expect(FoodItem.fromAnyJson(encoded).id, seedFoods.first.id);

      // Cached lookups while remote is offline
      remote.shouldFail = true;
      final cachedAll = await repo.getAllFoods();
      expect(cachedAll.length, seedFoods.length);

      final forcedFallback = await repo.getAllFoods(forceRefresh: true);
      expect(forcedFallback.length, seedFoods.length);

      final byId = await repo.getFoodById('food_chicken');
      expect(byId?.name, 'Chicken Breast');

      final searched = await repo.searchFoods('Chicken');
      expect(searched.map((f) => f.id), contains('food_chicken'));

      final byCat = await repo.getFoodsByCategory('carbs');
      expect(byCat.map((f) => f.id), contains('food_oats'));

      final categories = await repo.getAllCategories();
      expect(categories, containsAll(['protein', 'carbs', 'fats']));

      final tags = await repo.getAllDietaryTags();
      expect(tags, containsAll(['high_protein', 'vegan']));

      final byTag = await repo.getFoodsByTags(const ['keto']);
      expect(byTag.map((f) => f.id), contains('food_avocado'));

      // Uncached getFoodById when remote recovers
      remote.shouldFail = false;
      final extraFood = _sampleFood(id: 'food_salmon', name: 'Atlantic Salmon');
      remote.remoteFoods.add(extraFood);
      final fetchedExtra = await repo.getFoodById('food_salmon');
      expect(fetchedExtra?.id, 'food_salmon');

      // Fallback search/category/tag paths when cache is invalidated
      await repo.invalidateCache();
      expect(await repo.isCacheValid(), isFalse);

      await repo.clearCache();
      expect(await repo.getCachedFoodCount(), 0);
    });

    test('isolates user custom foods per userId and supports save/list/delete',
        () async {
      final remote = _FakeFirestoreFoodDatasource(const []);
      final repoUserA = FoodRepositoryImpl(
        firestoreDataSource: remote,
        hiveDataSource: HiveFoodDataSource(userId: 'user_a'),
      );
      final repoUserB = FoodRepositoryImpl(
        firestoreDataSource: remote,
        hiveDataSource: HiveFoodDataSource(userId: 'user_b'),
      );

      final customShake = _sampleFood(
        id: 'custom_shake_1',
        name: 'Post-Workout Whey Shake',
      );

      await repoUserA.saveCustomFood(customShake);

      final userACustom = await repoUserA.getCustomFoods();
      final userBCustom = await repoUserB.getCustomFoods();
      expect(userACustom.map((f) => f.id), ['custom_shake_1']);
      expect(userBCustom, isEmpty);

      await repoUserA.deleteCustomFood('custom_shake_1');
      expect(await repoUserA.getCustomFoods(), isEmpty);
    });
  });

  group('Wave 3.7 — AIPreferencesRepositoryImpl & PrivacyPreferencesRepositoryImpl', () {
    test('migrates legacy consent & banner dismissals once and isolates per user',
        () async {
      SharedPreferences.setMockInitialValues({
        AIPreferencesRepositoryImpl.consentKey: true,
        AIPreferencesRepositoryImpl.dismissedBannersKey: ['banner_1', 'banner_2'],
      });

      final aiRepo = AIPreferencesRepositoryImpl();

      // First signed-in user adopts legacy global preferences and removes legacy keys
      final userAConsent =
          await aiRepo.loadPersonalizationConsent(userId: 'user_a');
      expect(userAConsent, isTrue);

      final userADismissed =
          await aiRepo.loadDismissedBanners(userId: 'user_a');
      expect(userADismissed, equals({'banner_1', 'banner_2'}));

      // Second signed-in user starts clean without inheriting user A's migrated values
      expect(
        await aiRepo.loadPersonalizationConsent(userId: 'user_b'),
        isFalse,
      );
      expect(await aiRepo.loadDismissedBanners(userId: 'user_b'), isNull);

      await aiRepo.savePersonalizationConsent(userId: 'user_b', consent: true);
      await aiRepo.saveDismissedBanners(
        userId: 'user_b',
        dismissedIds: {'banner_b'},
      );
      expect(await aiRepo.loadPersonalizationConsent(userId: 'user_b'), isTrue);
      expect(
        await aiRepo.loadDismissedBanners(userId: 'user_b'),
        equals({'banner_b'}),
      );

      await aiRepo.clearDismissedBanners(userId: 'user_b');
      expect(await aiRepo.loadDismissedBanners(userId: 'user_b'), isNull);
    });

    test('PrivacyPreferencesRepositoryImpl loads defaults and persists full consent snapshot',
        () async {
      SharedPreferences.setMockInitialValues({});
      final repo = PrivacyPreferencesRepositoryImpl();

      final initial = await repo.loadSettings(userId: 'user_priv');
      expect(initial.analyticsEnabled, isFalse);
      expect(initial.crashReportingEnabled, isFalse);
      expect(initial.dataSharingEnabled, isFalse);
      expect(initial.aiPersonalizationConsent, isFalse);
      expect(initial.hasRecordedTelemetryConsent, isFalse);

      await repo.saveSettings(
        userId: 'user_priv',
        analyticsEnabled: true,
        crashReportingEnabled: true,
        dataSharingEnabled: false,
        aiPersonalizationConsent: true,
      );

      final saved = await repo.loadSettings(userId: 'user_priv');
      expect(saved.analyticsEnabled, isTrue);
      expect(saved.crashReportingEnabled, isTrue);
      expect(saved.dataSharingEnabled, isFalse);
      expect(saved.aiPersonalizationConsent, isTrue);
      expect(saved.hasRecordedTelemetryConsent, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getBool(TelemetryPreferences.consentPromptShownKey),
        isTrue,
      );
    });
  });
}
