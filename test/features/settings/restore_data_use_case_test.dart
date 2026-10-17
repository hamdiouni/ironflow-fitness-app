import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:progression_tracker/features/settings/domain/usecases/export_all_data_use_case.dart';
import 'package:progression_tracker/features/settings/domain/usecases/export_nutrition_use_case.dart';
import 'package:progression_tracker/features/settings/domain/usecases/export_workouts_use_case.dart';
import 'package:progression_tracker/features/settings/domain/usecases/restore_data_use_case.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_type.dart';
import 'package:progression_tracker/features/workout/domain/entities/set_entry.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';

class InMemoryWorkoutRepository implements WorkoutRepository {
  final List<Workout> workouts = [];

  @override
  Future<void> saveWorkout(Workout workout) async {
    workouts.removeWhere((w) => w.id == workout.id);
    workouts.add(workout);
  }

  @override
  Future<List<Workout>> getAllWorkouts() async => List.unmodifiable(workouts);

  @override
  Future<void> deleteWorkout(String id) async {
    workouts.removeWhere((w) => w.id == id);
  }

  @override
  Future<List<Workout>> getWorkoutsByDateRange(DateTime start, DateTime end) async {
    return workouts
        .where((w) => (w.date.isAfter(start) || w.date.isAtSameMomentAs(start)) && w.date.isBefore(end))
        .toList();
  }

  @override
  Future<List<Workout>> getWorkoutsPaginated({int offset = 0, int limit = 20}) async {
    return workouts.skip(offset).take(limit).toList();
  }

  @override
  Future<int> getWorkoutCount() async => workouts.length;

  @override
  Future<List<Exercise>> getExerciseHistory(String exerciseName, int limit) async => [];
}

class InMemoryNutritionRepository implements NutritionRepository {
  final List<Meal> meals = [];
  NutritionTargets? targets;

  @override
  Future<void> saveMealEntry(Meal meal) async {
    meals.removeWhere((m) => m.id == meal.id);
    meals.add(meal);
  }

  @override
  Future<void> deleteMealEntry(String mealId) async {
    meals.removeWhere((m) => m.id == mealId);
  }

  @override
  Future<List<Meal>> getMealsByDate(DateTime date) async {
    return meals
        .where((m) =>
            m.timestamp.year == date.year &&
            m.timestamp.month == date.month &&
            m.timestamp.day == date.day)
        .toList();
  }

  @override
  Future<DailyNutritionSummary> getDailyNutrition(DateTime date) async {
    final dayMeals = await getMealsByDate(date);
    return DailyNutritionSummary(date: date, meals: dayMeals, target: targets);
  }

  @override
  Future<List<DailyNutritionSummary>> getNutritionHistory(DateTime startDate, DateTime endDate) async {
    final Map<String, List<Meal>> grouped = {};
    for (final meal in meals) {
      if ((meal.timestamp.isAfter(startDate) || meal.timestamp.isAtSameMomentAs(startDate)) &&
          meal.timestamp.isBefore(endDate)) {
        final key = '${meal.timestamp.year}-${meal.timestamp.month}-${meal.timestamp.day}';
        grouped.putIfAbsent(key, () => []).add(meal);
      }
    }

    return grouped.entries.map((entry) {
      final first = entry.value.first;
      final date = DateTime(first.timestamp.year, first.timestamp.month, first.timestamp.day);
      return DailyNutritionSummary(date: date, meals: entry.value, target: targets);
    }).toList();
  }

  @override
  Future<List<DailyNutritionSummary>> getNutritionHistoryPaginated({int offset = 0, int limit = 20}) async => [];

  @override
  Future<int> getNutritionHistoryCount() async => meals.length;

  @override
  Future<NutritionTargets?> getNutritionTargets() async => targets;

  @override
  Future<void> saveNutritionTargets(NutritionTargets targets) async {
    this.targets = targets;
  }

  @override
  Future<void> clearAllData() async {
    meals.clear();
    targets = null;
  }
}

class InMemoryBodyRepository implements BodyRepository {
  final List<BodyEntry> entries = [];

  @override
  Future<void> saveBodyEntry(BodyEntry entry) async {
    entries.removeWhere((e) => e.id == entry.id);
    entries.add(entry);
  }

  @override
  Future<List<BodyEntry>> getAllBodyEntries() async => List.unmodifiable(entries);

  @override
  Future<List<BodyEntry>> getBodyEntriesByDateRange(DateTime start, DateTime end) async {
    return entries
        .where((e) => (e.date.isAfter(start) || e.date.isAtSameMomentAs(start)) && e.date.isBefore(end))
        .toList();
  }

  @override
  Future<void> deleteBodyEntry(String id) async {
    entries.removeWhere((e) => e.id == id);
  }
}

class InMemoryAuthRepository implements AuthRepository {
  User? currentUser;
  UserProfile? userProfile;

  @override
  Future<User?> getCurrentUser() async => currentUser;

  @override
  Future<UserProfile?> getUserProfile(String userId) async => userProfile;

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    userProfile = profile;
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    userProfile = profile;
  }

  @override
  Future<bool> isAuthenticated() async => currentUser != null;

  @override
  Future<void> signOut() async {
    currentUser = null;
  }

  @override
  Stream<User?> get authStateChanges => Stream.value(currentUser);

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<User> signInWithApple() async => throw UnimplementedError();

  @override
  Future<User> signInWithEmail({required String email, required String password}) async =>
      throw UnimplementedError();

  @override
  Future<User> signInWithGoogle() async => throw UnimplementedError();

  @override
  Future<User> signUpWithEmail({required String email, required String password}) async =>
      throw UnimplementedError();
}

void main() {
  group('RestoreDataUseCase Round-Trip & Error Handling Tests', () {
    late InMemoryWorkoutRepository workoutRepo;
    late InMemoryNutritionRepository nutritionRepo;
    late InMemoryBodyRepository bodyRepo;
    late InMemoryAuthRepository authRepo;
    late RestoreDataUseCase restoreUseCase;

    setUp(() {
      workoutRepo = InMemoryWorkoutRepository();
      nutritionRepo = InMemoryNutritionRepository();
      bodyRepo = InMemoryBodyRepository();
      authRepo = InMemoryAuthRepository();
      restoreUseCase = RestoreDataUseCase(
        workoutRepo,
        nutritionRepo,
        bodyRepo,
        authRepo,
      );
    });

    test('Round-trip test: export -> wipe -> restore -> assert equality', () async {
      final testDate = DateTime(2026, 10, 15, 14, 30);

      // 1. Seed Workout
      final originalWorkout = Workout(
        id: 'workout-101',
        date: testDate,
        duration: const Duration(minutes: 55),
        totalVolume: 12500.0,
        caloriesBurned: 450.0,
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [
              SetEntry(
                id: 'set-1',
                reps: 10,
                weight: 100.0,
                rpe: 8,
                timestamp: testDate,
              ),
              SetEntry(
                id: 'set-2',
                reps: 8,
                weight: 105.0,
                rpe: 9,
                timestamp: testDate.add(const Duration(minutes: 3)),
              ),
            ],
          ),
        ],
      );
      await workoutRepo.saveWorkout(originalWorkout);

      // 2. Seed Meal
      final originalMeal = Meal(
        id: 'meal-201',
        name: 'Post-workout Shake',
        macros: const MealMacros(calories: 350.0, protein: 45.0, carbs: 30.0, fats: 5.0),
        micros: const MealMicros(fiber: 4.0, sugar: 10.0, sodium: 200.0, potassium: 450.0),
        vitamins: const MealVitamins(vitaminA: 100.0, vitaminB: 2.0, vitaminC: 50.0, vitaminD: 10.0, vitaminE: 5.0),
        minerals: const MealMinerals(calcium: 300.0, iron: 5.0, magnesium: 100.0, zinc: 3.0),
        timestamp: testDate,
      );
      await nutritionRepo.saveMealEntry(originalMeal);

      // 3. Seed Body Entry
      final originalBodyEntry = BodyEntry(
        id: 'body-301',
        date: testDate,
        weight: 82.5,
        measurements: {
          MeasurementType.waist: 84.0,
          MeasurementType.chest: 106.0,
          MeasurementType.arms: 39.5,
        },
        photoPath: '/photos/body-301.jpg',
      );
      await bodyRepo.saveBodyEntry(originalBodyEntry);

      // 4. Seed User Profile
      final originalProfile = UserProfile(
        userId: 'user-401',
        email: 'athlete@ironflow.com',
        name: 'Iron Athlete',
        age: 28,
        gender: 'male',
        fitnessLevel: 'intermediate',
        goals: ['hypertrophy', 'strength'],
        equipment: ['barbell', 'dumbbell'],
        createdAt: testDate,
        updatedAt: testDate,
      );
      await authRepo.saveUserProfile(originalProfile);
      authRepo.currentUser = User(
        id: originalProfile.userId,
        email: originalProfile.email,
        displayName: originalProfile.name,
        photoUrl: null,
        createdAt: testDate,
        updatedAt: testDate,
      );

      // 5. Export all data
      final exportUseCase = ExportAllDataUseCase(
        workoutRepo,
        nutritionRepo,
        bodyRepo,
        authRepo,
        ExportWorkoutsUseCase(workoutRepo),
        ExportNutritionUseCase(nutritionRepo),
      );
      final stats = await exportUseCase.getExportStatistics();
      expect(stats['workouts'], 1);
      expect(stats['total_meals'], 1);
      expect(stats['body_measurements'], 1);

      final exportJsonMap = {
        'export_info': {
          'export_date': testDate.toIso8601String(),
          'export_version': '1.0',
          'app_version': '1.0.0',
          'export_type': 'complete_backup',
        },
        'user_profile': originalProfile.toJson(),
        'workouts': [
          {
            'id': originalWorkout.id,
            'date': originalWorkout.date.toIso8601String(),
            'duration_minutes': originalWorkout.duration.inMinutes,
            'total_volume': originalWorkout.totalVolume,
            'calories_burned': originalWorkout.caloriesBurned,
            'exercises': originalWorkout.exercises
                .map((e) => {
                      'id': e.id,
                      'name': e.name,
                      'type': e.type.name,
                      'sets': e.sets
                          .map((s) => {
                                'id': s.id,
                                'reps': s.reps,
                                'weight': s.weight,
                                'rpe': s.rpe,
                                'timestamp': s.timestamp.toIso8601String(),
                              })
                          .toList(),
                    })
                .toList(),
          }
        ],
        'programs': [],
        'nutrition_logs': [
          {
            'date': testDate.toIso8601String(),
            'meals': [
              {
                'id': originalMeal.id,
                'name': originalMeal.name,
                'timestamp': originalMeal.timestamp.toIso8601String(),
                'macros': {
                  'calories': originalMeal.macros.calories,
                  'protein': originalMeal.macros.protein,
                  'carbs': originalMeal.macros.carbs,
                  'fats': originalMeal.macros.fats,
                },
              }
            ],
          }
        ],
        'body_measurements': [
          {
            'id': originalBodyEntry.id,
            'date': originalBodyEntry.date.toIso8601String(),
            'weight': originalBodyEntry.weight,
            'measurements': originalBodyEntry.measurements.map((k, v) => MapEntry(k.name, v)),
            'photo_path': originalBodyEntry.photoPath,
          }
        ],
      };
      final backupJsonString = jsonEncode(exportJsonMap);

      // 6. Wipe all repositories
      workoutRepo.workouts.clear();
      nutritionRepo.meals.clear();
      bodyRepo.entries.clear();
      authRepo.userProfile = null;

      expect(workoutRepo.workouts, isEmpty);
      expect(nutritionRepo.meals, isEmpty);
      expect(bodyRepo.entries, isEmpty);
      expect(authRepo.userProfile, isNull);

      // 7. Restore from JSON string
      final restoreResult = await restoreUseCase.restoreFromJsonString(
        backupJsonString,
        overwriteExisting: false,
      );

      expect(restoreResult.success, isTrue);
      expect(restoreResult.errors, isEmpty);
      expect(restoreResult.restoredCounts['workouts'], 1);
      expect(restoreResult.restoredCounts['nutrition_logs'], 1);
      expect(restoreResult.restoredCounts['body_measurements'], 1);
      expect(restoreResult.restoredCounts['user_profile'], 1);

      // 8. Assert equality of restored data
      final restoredWorkouts = await workoutRepo.getAllWorkouts();
      expect(restoredWorkouts.length, 1);
      final rw = restoredWorkouts.first;
      expect(rw.id, originalWorkout.id);
      expect(rw.date, originalWorkout.date);
      expect(rw.duration.inMinutes, originalWorkout.duration.inMinutes);
      expect(rw.totalVolume, originalWorkout.totalVolume);
      expect(rw.caloriesBurned, originalWorkout.caloriesBurned);
      expect(rw.exercises.length, 1);
      expect(rw.exercises.first.name, 'Bench Press');
      expect(rw.exercises.first.sets.length, 2);
      expect(rw.exercises.first.sets.first.weight, 100.0);
      expect(rw.exercises.first.sets.last.weight, 105.0);

      final restoredMeals = await nutritionRepo.getMealsByDate(testDate);
      expect(restoredMeals.length, 1);
      final rm = restoredMeals.first;
      expect(rm.id, originalMeal.id);
      expect(rm.name, originalMeal.name);
      expect(rm.macros.calories, originalMeal.macros.calories);
      expect(rm.macros.protein, originalMeal.macros.protein);

      final restoredEntries = await bodyRepo.getAllBodyEntries();
      expect(restoredEntries.length, 1);
      final rb = restoredEntries.first;
      expect(rb.id, originalBodyEntry.id);
      expect(rb.weight, originalBodyEntry.weight);
      expect(rb.measurements[MeasurementType.waist], 84.0);
      expect(rb.measurements[MeasurementType.chest], 106.0);
      expect(rb.measurements[MeasurementType.arms], 39.5);
      expect(rb.photoPath, originalBodyEntry.photoPath);

      final restoredProfile = await authRepo.getUserProfile('user-401');
      expect(restoredProfile, isNotNull);
      expect(restoredProfile!.name, originalProfile.name);
      expect(restoredProfile.email, originalProfile.email);
    });

    test('Partial restore: malformed workout is surfaced and skipped without reporting false count', () async {
      final invalidBackupMap = {
        'export_info': {'export_version': '1.0'},
        'workouts': [
          'this is not a valid map', // malformed
        ],
        'body_measurements': [
          {
            'id': 'body-1',
            'date': DateTime.now().toIso8601String(),
            'weight': 75.0,
            'measurements': {},
          }
        ],
      };

      final result = await restoreUseCase.restoreFromJsonString(
        jsonEncode(invalidBackupMap),
      );

      // Body measurement was restored, but workout had an error
      expect(result.restoredCounts['workouts'], isNull);
      expect(result.restoredCounts['body_measurements'], 1);
      expect(result.errors.length, greaterThanOrEqualTo(1));
      expect(result.errors.first, contains('Failed to restore workout'));
    });

    test('Validation failure on missing export_info section', () async {
      final emptyMap = {'workouts': []};
      final result = await restoreUseCase.restoreFromJsonString(jsonEncode(emptyMap));

      expect(result.success, isFalse);
      expect(result.errors, contains('Missing export_info section'));
    });

    test('Pre-validation preview accurately counts records without touching repositories', () async {
      final backupJson = jsonEncode({
        'export_info': {
          'export_version': '1.0',
          'export_date': '2026-10-17T12:00:00.000Z',
        },
        'user_profile': {
          'userId': 'u1',
          'email': 'u1@test.com',
          'name': 'Test User',
          'age': 30,
          'gender': 'other',
          'fitnessLevel': 'intermediate',
          'goals': ['strength'],
          'equipment': ['barbell'],
          'createdAt': '2026-10-17T12:00:00.000Z',
          'updatedAt': '2026-10-17T12:00:00.000Z',
        },
        'workouts': [
          {'id': 'w1', 'date': '2026-10-17T10:00:00.000Z', 'exercises': []},
          {'id': 'w2', 'date': '2026-10-16T10:00:00.000Z', 'exercises': []},
        ],
        'daily_nutrition': [
          {'date': '2026-10-17T00:00:00.000Z', 'meals': []},
        ],
        'body_measurements': [
          {'id': 'b1', 'date': '2026-10-17T08:00:00.000Z', 'weight': 80.0},
          {'id': 'b2', 'date': '2026-10-16T08:00:00.000Z', 'weight': 80.5},
          {'id': 'b3', 'date': '2026-10-15T08:00:00.000Z', 'weight': 81.0},
        ],
      });

      final preview = restoreUseCase.getRestorePreviewFromJson(backupJson);

      expect(preview.isValid, isTrue);
      expect(preview.exportVersion, '1.0');
      expect(preview.workoutCount, 2);
      expect(preview.nutritionCount, 1);
      expect(preview.bodyMeasurementCount, 3);
      expect(preview.hasUserProfile, isTrue);

      // Verify zero repository mutations occurred during preview
      expect(await workoutRepo.getWorkoutCount(), 0);
      expect(await bodyRepo.getAllBodyEntries(), isEmpty);
    });

    test('Data safety: invalid schema rejection leaves existing data completely untouched', () async {
      // 1. Seed existing data
      final existingWorkout = Workout(
        id: 'existing-w',
        date: DateTime(2026, 1, 1),
        duration: const Duration(minutes: 30),
        totalVolume: 5000,
        caloriesBurned: 200,
        exercises: [],
      );
      await workoutRepo.saveWorkout(existingWorkout);

      final existingBody = BodyEntry(
        id: 'existing-b',
        date: DateTime(2026, 1, 1),
        weight: 77.0,
        measurements: const {},
      );
      await bodyRepo.saveBodyEntry(existingBody);

      expect(await workoutRepo.getWorkoutCount(), 1);
      expect((await bodyRepo.getAllBodyEntries()).length, 1);

      // 2. Attempt to restore completely corrupt JSON with overwriteExisting = true
      final corruptJson = '{"invalid_key": "not a backup"}';
      final result = await restoreUseCase.restoreFromJsonString(corruptJson, overwriteExisting: true);

      expect(result.success, isFalse);

      // 3. Verify existing data was NOT wiped or touched
      final workoutsAfter = await workoutRepo.getAllWorkouts();
      expect(workoutsAfter.length, 1);
      expect(workoutsAfter.first.id, 'existing-w');

      final bodyAfter = await bodyRepo.getAllBodyEntries();
      expect(bodyAfter.length, 1);
      expect(bodyAfter.first.id, 'existing-b');
    });

    test('Dual-key support: restores daily_nutrition and weight_kg without errors', () async {
      final dualKeyJson = jsonEncode({
        'export_info': {'export_version': '1.0'},
        'workouts': [
          {
            'id': 'w-dual',
            'date': '2026-10-17T12:00:00.000Z',
            'duration_minutes': 45,
            'total_volume_kg': 6000.0,
            'exercises': [
              {
                'id': 'ex-dual',
                'name': 'Squat',
                'type': 'ExerciseType.strength',
                'sets': [
                  {
                    'id': 's-1',
                    'reps': 5,
                    'weight_kg': 120.0,
                    'rpe': 8,
                  }
                ],
              }
            ],
          }
        ],
        'daily_nutrition': [
          {
            'date': '2026-10-17T00:00:00.000Z',
            'meals': [
              {
                'id': 'meal-dual',
                'name': 'Oatmeal',
                'timestamp': '2026-10-17T08:00:00.000Z',
                'macros': {
                  'calories': 400.0,
                  'protein': 20.0,
                  'carbs': 60.0,
                  'fats': 8.0,
                },
              }
            ],
          }
        ],
      });

      final result = await restoreUseCase.restoreFromJsonString(dualKeyJson, overwriteExisting: false);

      expect(result.success, isTrue);
      expect(result.restoredCounts['workouts'], 1);
      expect(result.restoredCounts['nutrition_logs'], 1);

      final w = (await workoutRepo.getAllWorkouts()).firstWhere((x) => x.id == 'w-dual');
      expect(w.totalVolume, 6000.0);
      expect(w.exercises.first.sets.first.weight, 120.0);
    });

    test('Merge mode preserves existing records while appending restored records', () async {
      final initialWorkout = Workout(
        id: 'initial-w',
        date: DateTime(2026, 5, 1),
        duration: const Duration(minutes: 40),
        totalVolume: 4000,
        caloriesBurned: 250,
        exercises: [],
      );
      await workoutRepo.saveWorkout(initialWorkout);

      final backupJson = jsonEncode({
        'export_info': {'export_version': '1.0'},
        'workouts': [
          {
            'id': 'restored-w',
            'date': '2026-10-17T12:00:00.000Z',
            'duration_minutes': 50,
            'total_volume': 8000.0,
            'exercises': [],
          }
        ],
      });

      final result = await restoreUseCase.restoreFromJsonString(backupJson, overwriteExisting: false);

      expect(result.success, isTrue);
      final all = await workoutRepo.getAllWorkouts();
      expect(all.length, 2);
      expect(all.map((w) => w.id), containsAll(['initial-w', 'restored-w']));
    });
  });
}

