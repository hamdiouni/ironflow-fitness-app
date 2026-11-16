import 'package:progression_tracker/features/body/data/datasources/hive_body_data_source.dart';
import 'package:progression_tracker/features/body/data/models/body_entry_model.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/hive_nutrition_datasource.dart';
import 'package:progression_tracker/features/nutrition/data/models/meal_model.dart';
import 'package:progression_tracker/features/nutrition/data/models/nutrition_targets_model.dart';
import 'package:progression_tracker/features/onboarding/data/user_profile_storage.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/workout/data/datasources/hive_active_program_datasource.dart';
import 'package:progression_tracker/features/workout/data/datasources/hive_workout_data_source.dart';
import 'package:progression_tracker/features/workout/data/models/exercise_model.dart';
import 'package:progression_tracker/features/workout/data/models/set_entry_model.dart';
import 'package:progression_tracker/features/workout/data/models/workout_model.dart';
import 'package:progression_tracker/features/workout/data/repositories/active_program_repository_impl.dart';
import 'package:progression_tracker/features/workout/domain/usecases/generate_workout_program_use_case.dart';
import 'package:progression_tracker/features/workout/domain/usecases/set_active_program_use_case.dart';

import 'package:progression_tracker/core/utils/record_ownership.dart';
export 'package:progression_tracker/core/utils/record_ownership.dart'
    show kLocalGuestUserId, kLocalDemoUserId, isLocalOnlyUserId;

/// Seeds realistic offline showcase data into AES-encrypted local Hive boxes
/// for [kLocalDemoUserId] so users can inspect every screen (Today Readiness,
/// 18-Region 2D Body Map, Volume Charts, Nutrition Macros, and AI Coach)
/// without touching cloud backends.
class LocalSampleDataSeeder {
  const LocalSampleDataSeeder();

  Future<void> seedDemoShowcaseIfEmpty({DateTime? referenceNow}) async {
    final now = referenceNow ?? DateTime.now();
    const uid = kLocalDemoUserId;

    // 1. Ensure onboarded UserProfile exists for demo showcase user
    final profileStorage = UserProfileStorage();
    const demoProfile = UserProfile(
      goal: FitnessGoal.gainMuscle,
      age: 27,
      weightKg: 79.6,
      heightCm: 180.0,
      fitnessLevel: FitnessLevel.intermediate,
      equipment: EquipmentType.gym,
      workoutDaysPerWeek: 4,
      budget: BudgetLevel.medium,
      sex: BiologicalSex.male,
      targetWeightKg: 82.5,
    );
    final existingProfile = await profileStorage.loadProfile(userId: uid);
    if (existingProfile == null) {
      await profileStorage.saveProfile(demoProfile, userId: uid);
    }
    await profileStorage.markOnboarded(userId: uid);

    // 2. Ensure active 4-Day Upper/Lower program exists
    try {
      final programRepo = ActiveProgramRepositoryImpl(
        HiveActiveProgramDataSource(),
        userId: uid,
      );
      final existingProgram = await programRepo.loadActiveProgram();
      if (existingProgram == null) {
        final program = const GenerateWorkoutProgramUseCase().call(
          userProfile: demoProfile,
        );
        await SetActiveProgramUseCase(programRepo).call(program);
      }
    } catch (_) {
      // Non-fatal if Hive active_program box is unavailable in headless tests
    }

    // 3. Seed recent workouts across upper/lower/pull splits so the 18-region
    // Body Map displays Fresh, Recovering, and Needs Rest muscles cleanly.
    try {
      final workoutDs = HiveWorkoutDataSource();
      final allWorkouts = await workoutDs.getAllWorkouts();
      final hasDemoWorkouts = allWorkouts.any((w) => w.userId == uid);
      if (!hasDemoWorkouts) {
        final pushTime = now.subtract(const Duration(hours: 16));
        final legsTime = now.subtract(const Duration(hours: 52));
        final pullTime = now.subtract(const Duration(days: 4, hours: 3));
        final upperPowerTime = now.subtract(const Duration(days: 6, hours: 2));

        final workouts = <WorkoutModel>[
          _buildWorkout(
            id: 'demo_w_push_1',
            date: pushTime,
            durationSeconds: 3420,
            caloriesBurned: 410,
            userId: uid,
            exercises: [
              _ex('ex_d1', 'Bench Press', 'chest_001', pushTime, [
                (95.0, 8, 8),
                (100.0, 8, 8),
                (100.0, 7, 9),
                (102.5, 6, 9),
              ]),
              _ex('ex_d2', 'Incline Bench Press', 'chest_002', pushTime, [
                (77.5, 10, 8),
                (80.0, 9, 8),
                (80.0, 8, 9),
              ]),
              _ex('ex_d3', 'Overhead Press', 'shoulders_001', pushTime, [
                (55.0, 8, 8),
                (57.5, 8, 8),
                (60.0, 7, 9),
              ]),
              _ex('ex_d4', 'Lateral Raise', 'shoulders_003', pushTime, [
                (14.0, 14, 8),
                (14.0, 12, 9),
                (14.0, 12, 9),
              ]),
              _ex('ex_d5', 'Tricep Pushdown', 'arms_005', pushTime, [
                (32.5, 12, 8),
                (35.0, 12, 8),
                (35.0, 10, 9),
              ]),
            ],
          ),
          _buildWorkout(
            id: 'demo_w_legs_2',
            date: legsTime,
            durationSeconds: 3780,
            caloriesBurned: 485,
            userId: uid,
            exercises: [
              _ex('ex_d6', 'Squat', 'legs_001', legsTime, [
                (120.0, 6, 8),
                (125.0, 6, 8),
                (130.0, 5, 9),
                (130.0, 5, 9),
              ]),
              _ex('ex_d7', 'Romanian Deadlift', 'legs_002', legsTime, [
                (105.0, 8, 8),
                (110.0, 8, 8),
                (110.0, 8, 9),
              ]),
              _ex('ex_d8', 'Leg Extension', 'legs_005', legsTime, [
                (65.0, 12, 8),
                (70.0, 12, 9),
                (70.0, 11, 9),
              ]),
              _ex('ex_d9', 'Calf Raise', 'legs_008', legsTime, [
                (75.0, 15, 8),
                (80.0, 14, 9),
                (80.0, 14, 9),
              ]),
            ],
          ),
          _buildWorkout(
            id: 'demo_w_pull_3',
            date: pullTime,
            durationSeconds: 3300,
            caloriesBurned: 390,
            userId: uid,
            exercises: [
              _ex('ex_d10', 'Pull-Up', 'back_003', pullTime, [
                (80.0, 10, 8),
                (82.5, 9, 8),
                (82.5, 8, 9),
              ]),
              _ex('ex_d11', 'Barbell Row', 'back_002', pullTime, [
                (85.0, 8, 8),
                (90.0, 8, 8),
                (90.0, 8, 9),
                (92.5, 7, 9),
              ]),
              _ex('ex_d12', 'Reverse Fly', 'shoulders_005', pullTime, [
                (12.0, 15, 8),
                (12.0, 14, 8),
                (12.0, 14, 9),
              ]),
              _ex('ex_d13', 'Barbell Curl', 'arms_001', pullTime, [
                (35.0, 10, 8),
                (37.5, 10, 8),
                (37.5, 9, 9),
              ]),
              _ex('ex_d14', 'Hanging Leg Raise', 'abs_006', pullTime, [
                (10.0, 14, 8),
                (10.0, 12, 8),
                (10.0, 12, 9),
              ]),
            ],
          ),
          _buildWorkout(
            id: 'demo_w_upper_4',
            date: upperPowerTime,
            durationSeconds: 3180,
            caloriesBurned: 375,
            userId: uid,
            exercises: [
              _ex('ex_d15', 'Bench Press', 'chest_001', upperPowerTime, [
                (92.5, 8, 8),
                (97.5, 8, 8),
                (97.5, 7, 9),
                (100.0, 6, 9),
              ]),
              _ex('ex_d16', 'Barbell Row', 'back_002', upperPowerTime, [
                (85.0, 8, 8),
                (87.5, 8, 8),
                (87.5, 8, 9),
              ]),
              _ex('ex_d17', 'Dumbbell Shoulder Press', 'shoulders_002', upperPowerTime, [
                (26.0, 10, 8),
                (28.0, 9, 8),
                (28.0, 8, 9),
              ]),
            ],
          ),
        ];

        for (final workout in workouts) {
          await workoutDs.saveWorkout(workout);
        }
      }
    } catch (_) {}

    // 4. Seed body weight & circumference progression
    try {
      final bodyDs = HiveBodyDataSource();
      final existingEntries = await bodyDs.getAllBodyEntries();
      final hasDemoBody = existingEntries.any((e) => e.userId == uid);
      if (!hasDemoBody) {
        final points = <(int, double, Map<String, double>)>[
          (21, 78.4, {'chest': 102.5, 'waist': 81.5, 'arms': 37.8}),
          (14, 78.8, {'chest': 103.0, 'waist': 81.4, 'arms': 38.0}),
          (9, 79.1, {'chest': 103.4, 'waist': 81.5, 'arms': 38.2}),
          (4, 79.4, {'chest': 103.8, 'waist': 81.6, 'arms': 38.4}),
          (0, 79.6, {'chest': 104.2, 'waist': 81.5, 'arms': 38.6}),
        ];
        for (final point in points) {
          final ts = now.subtract(Duration(days: point.$1)).toIso8601String();
          await bodyDs.saveBodyEntry(
            BodyEntryModel(
              id: 'demo_body_${point.$1}',
              date: ts,
              weight: point.$2,
              measurements: point.$3,
              userId: uid,
              updatedAt: ts,
            ),
          );
        }
      }
    } catch (_) {}

    // 5. Seed today's nutrition targets & sample meals
    try {
      final nutritionDs = HiveNutritionDatasource();
      final nowIso = now.toIso8601String();
      final existingTargets = await nutritionDs.getNutritionTargets(userId: uid);
      if (existingTargets == null) {
        await nutritionDs.saveNutritionTargets(
          NutritionTargetsModel(
            userId: uid,
            macros: const MacroTargetsModel(
              calories: 2750,
              protein: 165,
              carbs: 320,
              fats: 82,
            ),
            micros: const MicroTargetsModel(
              fiber: 34,
              sugar: 50,
              sodium: 2300,
              potassium: 3500,
            ),
            vitamins: const VitaminTargetsModel(
              vitaminA: 900,
              vitaminB: 2.4,
              vitaminC: 90,
              vitaminD: 20,
              vitaminE: 15,
            ),
            minerals: const MineralTargetsModel(
              calcium: 1000,
              iron: 8,
              magnesium: 400,
              zinc: 11,
            ),
            createdAt: nowIso,
            updatedAt: nowIso,
          ),
          userId: uid,
        );
      }

      final todayMeals = await nutritionDs.getMealsByDate(now);
      final hasDemoMeals = todayMeals.any((m) => m.userId == uid);
      if (!hasDemoMeals) {
        final breakfastTs = DateTime(now.year, now.month, now.day, 8, 15).toIso8601String();
        final lunchTs = DateTime(now.year, now.month, now.day, 13, 10).toIso8601String();
        final snackTs = DateTime(now.year, now.month, now.day, 16, 30).toIso8601String();

        final meals = <MealModel>[
          _meal(
            id: 'demo_meal_1_${now.year}_${now.month}_${now.day}',
            name: 'Protein Oats, Whey & Blueberries',
            calories: 585,
            protein: 46,
            carbs: 72,
            fats: 12,
            ts: breakfastTs,
            uid: uid,
          ),
          _meal(
            id: 'demo_meal_2_${now.year}_${now.month}_${now.day}',
            name: 'Grilled Chicken Breast & Jasmine Rice',
            calories: 690,
            protein: 58,
            carbs: 84,
            fats: 13,
            ts: lunchTs,
            uid: uid,
          ),
          _meal(
            id: 'demo_meal_3_${now.year}_${now.month}_${now.day}',
            name: 'Greek Yogurt, Honey & Almonds',
            calories: 365,
            protein: 28,
            carbs: 31,
            fats: 14,
            ts: snackTs,
            uid: uid,
          ),
        ];

        for (final m in meals) {
          await nutritionDs.saveMealEntry(m);
        }
      }
    } catch (_) {}
  }

  static ExerciseModel _ex(
    String id,
    String name,
    String definitionId,
    DateTime sessionTime,
    List<(double, int, int)> sets,
  ) {
    return ExerciseModel(
      id: id,
      name: name,
      type: 'strength',
      suggestedSets: sets.length,
      suggestedReps: sets.first.$2,
      exerciseDefinitionId: definitionId,
      sets: [
        for (var i = 0; i < sets.length; i++)
          SetEntryModel(
            id: '${id}_s$i',
            weight: sets[i].$1,
            reps: sets[i].$2,
            rpe: sets[i].$3,
            type: 'normal',
            timestamp: sessionTime.add(Duration(minutes: i * 3)).toIso8601String(),
          ),
      ],
    );
  }

  static WorkoutModel _buildWorkout({
    required String id,
    required DateTime date,
    required int durationSeconds,
    required double caloriesBurned,
    required String userId,
    required List<ExerciseModel> exercises,
  }) {
    double volume = 0;
    for (final ex in exercises) {
      for (final s in ex.sets) {
        volume += s.weight * s.reps;
      }
    }
    final iso = date.toIso8601String();
    return WorkoutModel(
      id: id,
      date: iso,
      exercises: exercises,
      durationSeconds: durationSeconds,
      totalVolume: volume,
      caloriesBurned: caloriesBurned,
      userId: userId,
      updatedAt: iso,
    );
  }

  static MealModel _meal({
    required String id,
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
    required String ts,
    required String uid,
  }) {
    return MealModel(
      id: id,
      name: name,
      macros: MealMacrosModel(
        calories: calories,
        protein: protein,
        carbs: carbs,
        fats: fats,
      ),
      micros: const MealMicrosModel(
        fiber: 8,
        sugar: 9,
        sodium: 420,
        potassium: 680,
      ),
      vitamins: const MealVitaminsModel(
        vitaminA: 180,
        vitaminB: 0.8,
        vitaminC: 24,
        vitaminD: 4,
        vitaminE: 3,
      ),
      minerals: const MealMineralsModel(
        calcium: 220,
        iron: 2.2,
        magnesium: 95,
        zinc: 3.1,
      ),
      timestamp: ts,
      userId: uid,
      updatedAt: ts,
    );
  }
}
