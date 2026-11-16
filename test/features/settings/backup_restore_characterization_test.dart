import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/entities/measurement_type.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/settings/domain/usecases/backup_data_use_case.dart';
import 'package:progression_tracker/features/settings/domain/usecases/export_all_data_use_case.dart';
import 'package:progression_tracker/features/settings/domain/usecases/export_nutrition_use_case.dart';
import 'package:progression_tracker/features/settings/domain/usecases/export_workouts_use_case.dart';
import 'package:progression_tracker/features/settings/domain/usecases/restore_data_use_case.dart';
import 'package:progression_tracker/features/settings/domain/usecases/simple_json_export_use_case.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_type.dart';
import 'package:progression_tracker/features/workout/domain/entities/set_entry.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';

class FakeBackupWorkoutRepo implements WorkoutRepository {
  final Map<String, Workout> workouts = {};

  @override
  Future<void> saveWorkout(Workout workout) async {
    workouts[workout.id] = workout;
  }

  @override
  Future<List<Workout>> getAllWorkouts() async => workouts.values.toList();

  @override
  Future<void> deleteWorkout(String id) async {
    workouts.remove(id);
  }

  @override
  Future<List<Workout>> getWorkoutsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return workouts.values
        .where((w) => !w.date.isBefore(start) && !w.date.isAfter(end))
        .toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeBackupNutritionRepo implements NutritionRepository {
  final Map<String, Meal> meals = {};
  NutritionTargets? targets;

  @override
  Future<List<DailyNutritionSummary>> getNutritionHistory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (meals.isEmpty) return [];
    return [
      DailyNutritionSummary(
        date: DateTime.utc(2026, 4, 15),
        meals: meals.values.toList(),
        target: targets,
      ),
    ];
  }

  @override
  Future<NutritionTargets?> getNutritionTargets() async => targets;

  @override
  Future<void> clearAllData() async {
    meals.clear();
  }

  @override
  Future<void> saveMealEntry(Meal meal) async {
    meals[meal.id] = meal;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeBackupBodyRepo implements BodyRepository {
  final Map<String, BodyEntry> entries = {};

  @override
  Future<void> saveBodyEntry(BodyEntry entry) async {
    entries[entry.id] = entry;
  }

  @override
  Future<List<BodyEntry>> getAllBodyEntries() async => entries.values.toList();

  @override
  Future<List<BodyEntry>> getBodyEntriesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return entries.values
        .where((e) => !e.date.isBefore(start) && !e.date.isAfter(end))
        .toList();
  }

  @override
  Future<void> deleteBodyEntry(String id) async {
    entries.remove(id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeBackupAuthRepo implements AuthRepository {
  User? currentUser;
  UserProfile? profile;

  @override
  Future<User?> getCurrentUser() async => currentUser;

  @override
  Future<UserProfile?> getUserProfile(String userId) async => profile;

  @override
  Future<void> saveUserProfile(UserProfile newProfile) async {
    profile = newProfile;
  }

  @override
  Future<void> updateUserProfile(UserProfile newProfile) async {
    profile = newProfile;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Wave 2.1 — Backup, Restore & Safety Snapshot Characterization', () {
    late Directory tempDir;
    late FakeBackupWorkoutRepo workoutRepo;
    late FakeBackupNutritionRepo nutritionRepo;
    late FakeBackupBodyRepo bodyRepo;
    late FakeBackupAuthRepo authRepo;
    late RestoreDataUseCase restoreUseCase;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('backup_restore_wave2_');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (MethodCall methodCall) async => tempDir.path,
      );
      workoutRepo = FakeBackupWorkoutRepo();
      nutritionRepo = FakeBackupNutritionRepo();
      bodyRepo = FakeBackupBodyRepo();
      authRepo = FakeBackupAuthRepo()
        ..currentUser = User(
          id: 'user_alpha',
          email: 'alpha@ironflow.app',
          displayName: 'Alpha',
          photoUrl: null,
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        );

      restoreUseCase = RestoreDataUseCase(
        workoutRepo,
        nutritionRepo,
        bodyRepo,
        authRepo,
        null,
        tempDir,
      );
    });

    tearDown(() {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    test('BackupRecord serializes and deserializes toJson/fromJson cleanly', () {
      final record = BackupRecord(
        id: 'bkp_01',
        createdAt: DateTime.utc(2026, 4, 15, 12, 0),
        fileName: 'ironflow_backup.json',
        fileSize: 4096,
        cloudPath: 'users/user_alpha/backups/ironflow_backup.json',
        type: BackupType.manual,
        statistics: const {'workouts': 12, 'meals': 30},
      );

      final restored = BackupRecord.fromJson(record.toJson());
      expect(restored.id, 'bkp_01');
      expect(restored.type, BackupType.manual);
      expect(restored.statistics['workouts'], 12);
    });

    test('RestoreDataUseCase rejects malformed JSON and preserves existing local records (zero data loss)', () async {
      // Seed an existing workout
      final existingWorkout = Workout(
        id: 'w_existing',
        date: DateTime.utc(2026, 4, 10),
        exercises: const [],
        duration: const Duration(minutes: 45),
        totalVolume: 4500,
      );
      await workoutRepo.saveWorkout(existingWorkout);

      // 1. Non-object JSON
      final res1 = await restoreUseCase.restoreFromJsonString('["not_an_object"]');
      expect(res1.success, isFalse);

      // 2. Missing export_info section
      final res2 = await restoreUseCase.restoreFromJsonString('{"workouts": []}');
      expect(res2.success, isFalse);
      expect(res2.errors, contains('Missing export_info section'));

      // 3. Incompatible major version (< 1)
      final res3 = await restoreUseCase.restoreFromJsonString(jsonEncode({
        'export_info': {'export_version': '0.5'},
        'workouts': [],
      }));
      expect(res3.success, isFalse);

      // Existing workout was never touched!
      expect(workoutRepo.workouts.containsKey('w_existing'), isTrue);
    });

    test('createSafetySnapshot and restoreFromJsonString round-trip workouts and body measurements scoped to user', () async {
      final w1 = Workout(
        id: 'w_snap_1',
        date: DateTime.utc(2026, 4, 12, 9, 0),
        exercises: [
          Exercise(
            id: 'ex_1',
            name: 'Barbell Bench Press',
            type: ExerciseType.strength,
            sets: [
              SetEntry(
                id: 's1',
                reps: 8,
                weight: 100.0,
                timestamp: DateTime.utc(2026, 4, 12, 9, 5),
              ),
            ],
          ),
        ],
        duration: const Duration(minutes: 50),
        totalVolume: 800,
        userId: 'user_alpha',
      );
      await workoutRepo.saveWorkout(w1);
      await bodyRepo.saveBodyEntry(
        BodyEntry(
          id: 'body_1',
          date: DateTime.utc(2026, 4, 12),
          weight: 82.4,
          measurements: const {},
          userId: 'user_alpha',
        ),
      );

      // Create safety snapshot before wiping
      final snapshotFile = await restoreUseCase.createSafetySnapshot();
      expect(await snapshotFile.exists(), isTrue);

      // Wipe repositories
      workoutRepo.workouts.clear();
      bodyRepo.entries.clear();
      expect(workoutRepo.workouts, isEmpty);

      // Restore from local snapshot file
      final restoreRes = await restoreUseCase.restoreFromLocalFile(
        snapshotFile.path,
        overwriteExisting: true,
      );
      expect(restoreRes.success, isTrue);
      expect(workoutRepo.workouts['w_snap_1']?.totalVolume, 800);
      expect(bodyRepo.entries['body_1']?.weight, 82.4);
    });

    test('ExportWorkoutsUseCase, ExportNutritionUseCase, SimpleJsonExportUseCase, and ExportAllDataUseCase generate valid CSV, JSON, and ZIP exports', () async {
      final day = DateTime.utc(2026, 4, 15, 10, 0);
      await workoutRepo.saveWorkout(
        Workout(
          id: 'w_exp_1',
          date: day,
          exercises: [
            Exercise(
              id: 'ex_1',
              name: 'Barbell Squat',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 's_1',
                  reps: 5,
                  weight: 120.0,
                  rpe: 8,
                  timestamp: day,
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 45),
          totalVolume: 600,
          userId: 'user_alpha',
        ),
      );

      nutritionRepo.targets = NutritionTargets(
        userId: 'user_alpha',
        macros: const MacroTargets(
          calories: 2200,
          protein: 165,
          carbs: 220,
          fats: 70,
        ),
        micros: const MicroTargets(
          fiber: 30,
          sugar: 40,
          sodium: 2300,
          potassium: 3500,
        ),
        vitamins: const VitaminTargets(
          vitaminA: 900,
          vitaminB: 2.4,
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
        createdAt: day,
        updatedAt: day,
      );

      await nutritionRepo.saveMealEntry(
        Meal(
          id: 'm_exp_1',
          name: 'Post-Workout Shake',
          macros: const MealMacros(
            calories: 450,
            protein: 45,
            carbs: 50,
            fats: 8,
          ),
          micros: const MealMicros(
            fiber: 4,
            sugar: 12,
            sodium: 250,
            potassium: 500,
          ),
          vitamins: const MealVitamins(
            vitaminA: 100,
            vitaminB: 0.8,
            vitaminC: 20,
            vitaminD: 5,
            vitaminE: 3,
          ),
          minerals: const MealMinerals(
            calcium: 300,
            iron: 3,
            magnesium: 80,
            zinc: 2,
          ),
          timestamp: day,
          userId: 'user_alpha',
        ),
      );

      await bodyRepo.saveBodyEntry(
        BodyEntry(
          id: 'b_exp_1',
          date: day,
          weight: 81.2,
          measurements: const {
            MeasurementType.waist: 80.0,
            MeasurementType.chest: 104.0,
          },
          userId: 'user_alpha',
        ),
      );

      final start = DateTime.utc(2026, 4, 1);
      final end = DateTime.utc(2026, 4, 30);

      // 1. ExportWorkoutsUseCase
      final exportWorkouts = ExportWorkoutsUseCase(workoutRepo);
      expect(File(await exportWorkouts.exportToCSV()).existsSync(), isTrue);
      expect(File(await exportWorkouts.exportToJSON()).existsSync(), isTrue);
      expect(
        File(await exportWorkouts.exportDateRangeToCSV(start, end)).existsSync(),
        isTrue,
      );
      expect(
        File(await exportWorkouts.exportDateRangeToJSON(start, end)).existsSync(),
        isTrue,
      );
      expect(
        File(await exportWorkouts.exportSummaryToCSV()).existsSync(),
        isTrue,
      );

      // 2. ExportNutritionUseCase
      final exportNutrition = ExportNutritionUseCase(nutritionRepo);
      expect(File(await exportNutrition.exportToCSV()).existsSync(), isTrue);
      expect(File(await exportNutrition.exportToJSON()).existsSync(), isTrue);
      expect(
        File(await exportNutrition.exportDateRangeToCSV(start, end)).existsSync(),
        isTrue,
      );
      expect(
        File(await exportNutrition.exportDateRangeToJSON(start, end)).existsSync(),
        isTrue,
      );
      expect(
        File(await exportNutrition.exportSummaryToCSV()).existsSync(),
        isTrue,
      );
      expect(
        File(await exportNutrition.exportMacroTrendsToCSV()).existsSync(),
        isTrue,
      );

      // 3. SimpleJsonExportUseCase
      final simpleExport = SimpleJsonExportUseCase(
        workoutRepo,
        nutritionRepo,
        authRepo,
      );
      expect(
        File(await simpleExport.exportWorkoutsToJSON()).existsSync(),
        isTrue,
      );
      expect(
        File(await simpleExport.exportNutritionToJSON()).existsSync(),
        isTrue,
      );
      expect(
        File(await simpleExport.exportAllDataToJSON()).existsSync(),
        isTrue,
      );
      final simpleStats = await simpleExport.getExportStatistics();
      expect(simpleStats['workouts'], 1);
      expect(simpleStats['total_meals'], 1);

      // 4. ExportAllDataUseCase
      final exportAll = ExportAllDataUseCase(
        workoutRepo,
        nutritionRepo,
        bodyRepo,
        authRepo,
        exportWorkouts,
        exportNutrition,
      );
      expect(File(await exportAll.exportToJSON()).existsSync(), isTrue);
      expect(File(await exportAll.exportToZIP()).existsSync(), isTrue);
      expect(
        File(await exportAll.exportDateRangeToJSON(start, end)).existsSync(),
        isTrue,
      );
      final allStats = await exportAll.getExportStatistics();
      expect(allStats['workouts'], 1);
      expect(allStats['body_measurements'], 1);
    });

    test('BackupDataUseCase uploads with application/json SettableMetadata and rejects local-only users (Wave 1.1 & 1.5)', () async {
      final exportWorkouts = ExportWorkoutsUseCase(workoutRepo);
      final exportNutrition = ExportNutritionUseCase(nutritionRepo);
      final exportAll = ExportAllDataUseCase(
        workoutRepo,
        nutritionRepo,
        bodyRepo,
        authRepo,
        exportWorkouts,
        exportNutrition,
      );

      final fakeStorage = _FakeBackupFirebaseStorage();
      final fakeFirestore = _FakeBackupFirebaseFirestore();
      final backupUseCase = BackupDataUseCase(
        exportAll,
        authRepo,
        fakeFirestore,
        fakeStorage,
      );

      final record = await backupUseCase.createManualBackup();
      expect(record.cloudPath, startsWith('users/user_alpha/backups/'));
      expect(fakeStorage.lastMetadata?.contentType, equals('application/json'));
      expect(fakeFirestore.setCalls, contains('users/user_alpha/backups/${record.id}'));

      // Local-only guest & demo users cannot upload or delete cloud backups
      for (final localUid in [kLocalGuestUserId, kLocalDemoUserId]) {
        authRepo.currentUser = User(
          id: localUid,
          email: '$localUid@local.invalid',
          displayName: 'Local User',
          photoUrl: null,
          createdAt: DateTime.utc(2026, 1, 1),
          updatedAt: DateTime.utc(2026, 1, 1),
        );
        expect(await backupUseCase.getAllBackups(), isEmpty);
        await expectLater(
          backupUseCase.createManualBackup,
          throwsA(isA<UnsupportedError>()),
        );
        await expectLater(
          () => backupUseCase.deleteBackup('bkp_1'),
          throwsA(isA<UnsupportedError>()),
        );
      }
    });
  });
}

class _FakeBackupFirebaseStorage extends Fake implements FirebaseStorage {
  SettableMetadata? lastMetadata;
  String? lastPath;

  @override
  Reference ref([String? path]) =>
      _FakeBackupStorageReference(this, path ?? '');
}

class _FakeBackupStorageReference extends Fake implements Reference {
  _FakeBackupStorageReference(this._storage, this._path);

  final _FakeBackupFirebaseStorage _storage;
  final String _path;

  @override
  UploadTask putFile(File file, [SettableMetadata? metadata]) {
    _storage.lastPath = _path;
    _storage.lastMetadata = metadata;
    return _FakeBackupUploadTask();
  }
}

class _FakeBackupUploadTask extends Fake implements UploadTask {
  @override
  Future<S> then<S>(
    FutureOr<S> Function(TaskSnapshot value) onValue, {
    Function? onError,
  }) {
    return Future<TaskSnapshot>.value(_FakeTaskSnapshot()).then(
      onValue,
      onError: onError,
    );
  }
}

class _FakeTaskSnapshot extends Fake implements TaskSnapshot {}

class _FakeBackupFirebaseFirestore extends Fake implements FirebaseFirestore {
  final List<String> setCalls = <String>[];

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      _FakeBackupCollectionRef(this, collectionPath);
}

// ignore: subtype_of_sealed_class
class _FakeBackupCollectionRef extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _FakeBackupCollectionRef(this._firestore, this.path);

  final _FakeBackupFirebaseFirestore _firestore;
  @override
  final String path;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? docPath]) =>
      _FakeBackupDocRef(_firestore, '$path/$docPath');
}

// ignore: subtype_of_sealed_class
class _FakeBackupDocRef extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  _FakeBackupDocRef(this._firestore, this.path);

  final _FakeBackupFirebaseFirestore _firestore;
  @override
  final String path;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      _FakeBackupCollectionRef(_firestore, '$path/$collectionPath');

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    _firestore.setCalls.add(path);
  }
}
