import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/settings/domain/usecases/restore_data_use_case.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_type.dart';
import 'package:progression_tracker/features/workout/domain/entities/set_entry.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';

class InMemoryWorkoutRepository implements WorkoutRepository {
  final List<Workout> workouts = [];
  bool shouldThrowOnSave = false;
  String? throwOnWorkoutId;

  @override
  Future<void> saveWorkout(Workout workout) async {
    if (throwOnWorkoutId != null && workout.id == throwOnWorkoutId) {
      throw Exception('Injected database disk fault mid-restore for ${workout.id}!');
    }
    if (shouldThrowOnSave) {
      throw Exception('Injected database disk fault mid-restore!');
    }
    workouts.removeWhere((w) => w.id == workout.id);
    workouts.add(workout);
  }

  @override
  Future<List<Workout>> getAllWorkouts() async => List.from(workouts);

  @override
  Future<void> deleteWorkout(String id) async {
    workouts.removeWhere((w) => w.id == id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class InMemoryNutritionRepository implements NutritionRepository {
  final List<Meal> meals = [];

  @override
  Future<void> saveMealEntry(Meal meal) async {
    meals.removeWhere((m) => m.id == meal.id);
    meals.add(meal);
  }

  @override
  Future<void> clearAllData() async {
    meals.clear();
  }

  @override
  Future<List<DailyNutritionSummary>> getNutritionHistory(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (meals.isEmpty) return [];
    return [
      DailyNutritionSummary(
        date: DateTime.now(),
        meals: List.from(meals),
        target: null,
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class InMemoryBodyRepository implements BodyRepository {
  final List<BodyEntry> entries = [];

  @override
  Future<void> saveBodyEntry(BodyEntry entry) async {
    entries.removeWhere((e) => e.id == entry.id);
    entries.add(entry);
  }

  @override
  Future<List<BodyEntry>> getAllBodyEntries() async => List.from(entries);

  @override
  Future<void> deleteBodyEntry(String id) async {
    entries.removeWhere((e) => e.id == id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class InMemoryAuthRepository implements AuthRepository {
  User? user;
  UserProfile? profile;

  @override
  Future<User?> getCurrentUser() async => user;

  @override
  Future<UserProfile?> getUserProfile(String userId) async => profile;

  @override
  Future<void> saveUserProfile(UserProfile p) async {
    profile = p;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory tempDir;
  late InMemoryWorkoutRepository workoutRepo;
  late InMemoryNutritionRepository nutritionRepo;
  late InMemoryBodyRepository bodyRepo;
  late InMemoryAuthRepository authRepo;
  late RestoreDataUseCase restoreUseCase;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('restore_safety_test_');
    workoutRepo = InMemoryWorkoutRepository();
    nutritionRepo = InMemoryNutritionRepository();
    bodyRepo = InMemoryBodyRepository();
    authRepo = InMemoryAuthRepository();

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
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Restore Safety & Rollback (REL-03)', () {
    test('1. Successful restore creates a safety snapshot before overwriting', () async {
      // Seed pre-existing data
      final initialWorkout = Workout(
        id: 'w-pre-1',
        date: DateTime(2026, 10, 10),
        duration: const Duration(minutes: 45),
        totalVolume: 5000.0,
        caloriesBurned: 300.0,
        exercises: [],
      );
      await workoutRepo.saveWorkout(initialWorkout);

      final backupData = jsonEncode({
        'export_info': {'export_version': '1.0'},
        'workouts': [
          {
            'id': 'w-new-1',
            'date': '2026-10-18T10:00:00.000Z',
            'duration_minutes': 60,
            'total_volume': 8500.0,
            'exercises': [],
          }
        ],
      });

      final result = await restoreUseCase.restoreFromJsonString(backupData, overwriteExisting: true);

      expect(result.success, isTrue);
      // New workout restored
      final currentWorkouts = await workoutRepo.getAllWorkouts();
      expect(currentWorkouts.length, 1);
      expect(currentWorkouts.first.id, 'w-new-1');

      // Safety snapshot file exists in temp directory
      expect(await restoreUseCase.hasUndoSnapshot(), isTrue);
      final latest = await restoreUseCase.getLatestSnapshot();
      expect(latest, isNotNull);
      expect(latest!.existsSync(), isTrue);

      final snapshotContent = await latest.readAsString();
      expect(snapshotContent, contains('w-pre-1'));
    });

    test('2. Corrupt or unparseable JSON fails early without touching data or creating snapshot', () async {
      final initialWorkout = Workout(
        id: 'w-keep-me',
        date: DateTime(2026, 10, 10),
        duration: const Duration(minutes: 30),
        totalVolume: 3000.0,
        caloriesBurned: 200.0,
        exercises: [],
      );
      await workoutRepo.saveWorkout(initialWorkout);

      const corruptJson = '{"export_info": { invalid json content';

      final result = await restoreUseCase.restoreFromJsonString(corruptJson, overwriteExisting: true);

      expect(result.success, isFalse);
      expect(result.message, contains('Failed to parse JSON'));

      // Existing data unchanged
      final currentWorkouts = await workoutRepo.getAllWorkouts();
      expect(currentWorkouts.length, 1);
      expect(currentWorkouts.first.id, 'w-keep-me');
    });

    test('3. Injected failure mid-restore automatically rolls back to exact pre-restore state', () async {
      // Seed pre-existing data across repositories
      final originalWorkout = Workout(
        id: 'w-original',
        date: DateTime(2026, 10, 12),
        duration: const Duration(minutes: 50),
        totalVolume: 6200.0,
        caloriesBurned: 350.0,
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Squat',
            type: ExerciseType.strength,
            sets: [
              SetEntry(
                id: 's1',
                reps: 5,
                weight: 120.0,
                timestamp: DateTime(2026, 10, 12),
              ),
            ],
          ),
        ],
      );
      await workoutRepo.saveWorkout(originalWorkout);

      final originalMeal = Meal(
        id: 'meal-original',
        name: 'Protein Shake',
        macros: const MealMacros(calories: 300, protein: 40, carbs: 10, fats: 5),
        micros: const MealMicros(fiber: 2, sugar: 3, sodium: 150, potassium: 300),
        vitamins: const MealVitamins(vitaminA: 0, vitaminB: 0, vitaminC: 0, vitaminD: 0, vitaminE: 0),
        minerals: const MealMinerals(calcium: 200, iron: 1, magnesium: 50, zinc: 2),
        timestamp: DateTime(2026, 10, 12, 11, 0),
      );
      await nutritionRepo.saveMealEntry(originalMeal);

      // Prepare new restore data
      final restorePayload = jsonEncode({
        'export_info': {'export_version': '1.0'},
        'workouts': [
          {
            'id': 'w-corrupting-1',
            'date': '2026-10-18T10:00:00.000Z',
            'duration_minutes': 60,
            'total_volume': 9000.0,
            'exercises': [],
          }
        ],
      });

      // Inject disk fault on saveWorkout for the corrupting workout
      workoutRepo.throwOnWorkoutId = 'w-corrupting-1';

      final result = await restoreUseCase.restoreFromJsonString(restorePayload, overwriteExisting: true);

      expect(result.success, isFalse);
      expect(result.message, contains('safely rolled back from safety snapshot'));

      // Assert rollback restored original workout and meals exactly!
      final workoutsAfterRollback = await workoutRepo.getAllWorkouts();
      expect(workoutsAfterRollback.length, 1);
      expect(workoutsAfterRollback.first.id, 'w-original');
      expect(workoutsAfterRollback.first.totalVolume, 6200.0);
      expect(workoutsAfterRollback.first.exercises.first.name, 'Squat');

      final mealsAfterRollback = nutritionRepo.meals;
      expect(mealsAfterRollback.length, 1);
      expect(mealsAfterRollback.first.id, 'meal-original');
    });

    test('4. Undo restore recovers previous state and removes snapshot', () async {
      // 1. Initial state: User has workout A
      final workoutA = Workout(
        id: 'w-state-A',
        date: DateTime(2026, 10, 1),
        duration: const Duration(minutes: 30),
        totalVolume: 2500.0,
        caloriesBurned: 180.0,
        exercises: [],
      );
      await workoutRepo.saveWorkout(workoutA);

      // 2. Restore workout B
      final backupB = jsonEncode({
        'export_info': {'export_version': '1.0'},
        'workouts': [
          {
            'id': 'w-state-B',
            'date': '2026-10-18T10:00:00.000Z',
            'duration_minutes': 75,
            'total_volume': 11000.0,
            'exercises': [],
          }
        ],
      });

      final restoreResult = await restoreUseCase.restoreFromJsonString(backupB, overwriteExisting: true);
      expect(restoreResult.success, isTrue);
      expect((await workoutRepo.getAllWorkouts()).first.id, 'w-state-B');
      expect(await restoreUseCase.hasUndoSnapshot(), isTrue);

      // 3. User taps "Undo Restore"
      final undoResult = await restoreUseCase.undoRestore();
      expect(undoResult.success, isTrue);

      // Assert workout A is back!
      final workoutsRestored = await workoutRepo.getAllWorkouts();
      expect(workoutsRestored.length, 1);
      expect(workoutsRestored.first.id, 'w-state-A');
      expect(workoutsRestored.first.totalVolume, 2500.0);

      // Snapshot consumed
      expect(await restoreUseCase.hasUndoSnapshot(), isFalse);
    });

    test('5. Snapshot retention retains at most 3 snapshots and prunes older ones', () async {
      for (int i = 1; i <= 6; i++) {
        final workout = Workout(
          id: 'w-step-$i',
          date: DateTime(2026, 10, i),
          duration: const Duration(minutes: 30),
          totalVolume: 1000.0 * i,
          caloriesBurned: 100.0 * i,
          exercises: [],
        );
        await workoutRepo.saveWorkout(workout);

        final backup = jsonEncode({
          'export_info': {'export_version': '1.0'},
          'workouts': [
            {
              'id': 'w-step-${i + 1}',
              'date': '2026-10-18T10:00:00.000Z',
              'duration_minutes': 30,
              'total_volume': 2000.0,
              'exercises': [],
            }
          ],
        });

        await restoreUseCase.restoreFromJsonString(backup, overwriteExisting: true);
        // Small delay to ensure timestamp resolution
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      final snapshotDir = await restoreUseCase.getSafetySnapshotDirectory();
      final snapshots = snapshotDir.listSync().whereType<File>().toList();
      expect(snapshots.length, lessThanOrEqualTo(3));
    });

    test('6. Clear all snapshots wipes all snapshot files from app-private storage', () async {
      await restoreUseCase.createSafetySnapshot();
      await restoreUseCase.createSafetySnapshot();

      expect(await restoreUseCase.hasUndoSnapshot(), isTrue);

      await restoreUseCase.clearAllSnapshots();

      expect(await restoreUseCase.hasUndoSnapshot(), isFalse);
      final snapshotDir = await restoreUseCase.getSafetySnapshotDirectory();
      final remaining = snapshotDir.listSync().whereType<File>().toList();
      expect(remaining, isEmpty);
    });

    test('7. Safety snapshots are scoped to the current user', () async {
      User user(String id) {
        return User(
          id: id,
          email: '$id@ironflow.com',
          displayName: id,
          photoUrl: null,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        );
      }

      authRepo.user = user('Alice');
      final aliceSnapshot = await restoreUseCase.createSafetySnapshot();
      expect(aliceSnapshot.path, contains('safety_snapshot_alice_'));
      expect(await restoreUseCase.hasUndoSnapshot(), isTrue);

      authRepo.user = user('bob');
      expect(await restoreUseCase.hasUndoSnapshot(), isFalse);
      final bobSnapshot = await restoreUseCase.createSafetySnapshot();
      expect(bobSnapshot.path, contains('safety_snapshot_bob_'));
      expect(await restoreUseCase.hasUndoSnapshot(), isTrue);

      await restoreUseCase.clearAllSnapshots();
      expect(await bobSnapshot.exists(), isFalse);
      expect(await aliceSnapshot.exists(), isTrue);

      authRepo.user = user('Alice');
      expect(await restoreUseCase.hasUndoSnapshot(), isTrue);
    });
  });
}
