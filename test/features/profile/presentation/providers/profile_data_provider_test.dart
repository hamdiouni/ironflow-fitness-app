import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/diet_plan.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/diet_plan_state.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/profile/presentation/providers/profile_data_provider.dart';
import 'package:progression_tracker/features/workout/domain/entities/active_program.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout_program.dart';

void main() {
  final now = DateTime(2026, 10, 23, 12);

  const profile = UserProfile(
    goal: FitnessGoal.gainMuscle,
    age: 26,
    weightKg: 82.5,
    heightCm: 180,
    fitnessLevel: FitnessLevel.intermediate,
    equipment: EquipmentType.gym,
    workoutDaysPerWeek: 4,
    budget: BudgetLevel.medium,
  );

  final Alice = User(
    id: 'Alice',
    email: 'Alice@example.com',
    displayName: 'Alice Martin',
    photoUrl: null,
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2026, 1, 1),
  );

  Workout workout(
    String id,
    DateTime date, {
    String? userId = 'Alice',
    double volume = 1000,
    DateTime? deletedAt,
  }) {
    return Workout(
      id: id,
      date: date,
      exercises: const [],
      duration: const Duration(minutes: 45),
      totalVolume: volume,
      caloriesBurned: 300,
      userId: userId,
      deletedAt: deletedAt,
    );
  }

  Meal meal(
    String id, {
    String? userId = 'Alice',
    required double calories,
    required double protein,
  }) {
    return Meal(
      id: id,
      name: id,
      macros: MealMacros(
        calories: calories,
        protein: protein,
        carbs: 50,
        fats: 20,
      ),
      micros: const MealMicros(fiber: 0, sugar: 0, sodium: 0, potassium: 0),
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
      timestamp: now,
      userId: userId,
    );
  }

  NutritionTargets targets(String userId) => NutritionTargets(
        userId: userId,
        macros: const MacroTargets(
          calories: 2200,
          protein: 180,
          carbs: 220,
          fats: 70,
        ),
        micros: const MicroTargets(
          fiber: 30,
          sugar: 50,
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
        createdAt: now,
        updatedAt: now,
      );

  group('buildProfileData', () {
    test('derives profile from the signed-in user\'s real records only', () {
      const program = WorkoutProgram(
        id: 'program-1',
        name: 'Alice Strength Block',
        description: 'Saved program',
        durationWeeks: 6,
        difficulty: 'intermediate',
        userId: 'Alice',
        days: [
          ProgramDay(
            dayNumber: 1,
            name: 'Upper',
            focus: 'Chest',
            exercises: [],
          ),
          ProgramDay(
            dayNumber: 2,
            name: 'Rest',
            focus: 'Recovery',
            exercises: [],
            isRestDay: true,
          ),
          ProgramDay(
            dayNumber: 3,
            name: 'Lower',
            focus: 'Legs',
            exercises: [],
          ),
        ],
      );

      final data = buildProfileData(
        profile: profile,
        accountUser: Alice,
        now: now,
        bodyEntries: [
          BodyEntry(
            id: 'body-bob-newer',
            date: DateTime(2026, 10, 23),
            weight: 120,
            measurements: const {},
            userId: 'bob',
          ),
          BodyEntry(
            id: 'body-Alice-latest',
            date: DateTime(2026, 10, 20),
            weight: 79,
            measurements: const {},
            userId: 'Alice',
          ),
          BodyEntry(
            id: 'body-Alice-older',
            date: DateTime(2026, 10, 1),
            weight: 81,
            measurements: const {},
            userId: 'Alice',
          ),
        ],
        workouts: [
          workout('Alice-today', DateTime(2026, 10, 23), volume: 5000),
          workout('Alice-yesterday', DateTime(2026, 10, 22), volume: 4000),
          workout('Alice-two-days-ago', DateTime(2026, 10, 21), volume: 3000),
          workout('legacy', DateTime(2026, 10, 10), userId: null, volume: 500),
          workout('bob-today', DateTime(2026, 10, 23), userId: 'bob'),
          workout(
            'Alice-deleted',
            DateTime(2026, 10, 23),
            deletedAt: DateTime(2026, 10, 23),
          ),
        ],
        activeProgram: ActiveProgram(
          id: 'active-1',
          program: program,
          currentDayIndex: 2,
          isActive: true,
          completedDays: {0: DateTime(2026, 10, 21)},
          userId: 'Alice',
        ),
        dietPlanState: DietPlanState(
          plan: const DietPlan(
            name: 'Alice Saved Plan',
            dailyCalories: 2100,
            proteinG: 170,
            carbsG: 200,
            fatsG: 65,
            tips: [],
            days: [
              DietDay(
                dayName: 'Day 1',
                meals: [
                  DietMeal(
                    mealType: MealType.breakfast,
                    name: 'Original oats',
                    ingredients: ['oats'],
                    calories: 450,
                    proteinG: 25,
                    carbsG: 50,
                    fatsG: 12,
                  ),
                ],
              ),
            ],
          ),
          mealSwaps: const {
            'Day 1_breakfast': DietMeal(
              mealType: MealType.breakfast,
              name: 'Swapped eggs',
              ingredients: ['eggs'],
              calories: 420,
              proteinG: 30,
              carbsG: 10,
              fatsG: 25,
            ),
          },
        ),
        todayNutrition: DailyNutritionSummary(
          date: now,
          target: targets('Alice'),
          meals: [
            meal('Alice-meal', calories: 600, protein: 40),
            meal('legacy-meal', userId: null, calories: 100, protein: 5),
            meal('bob-meal', userId: 'bob', calories: 999, protein: 99),
          ],
        ),
      );

      expect(data.displayName, 'Alice Martin');
      expect(data.initials, 'AM');
      expect(data.email, 'Alice@example.com');

      // Latest logged weight wins over the onboarding value; Bob's
      // newer entry is not Alice's data.
      expect(data.currentWeightKg, 79);
      expect(data.bmi, closeTo(24.38, 0.01));
      expect(data.effectiveProfile.weightKg, 79);

      expect(data.totalWorkouts, 4);
      expect(data.workoutsThisWeek, 3);
      expect(data.currentStreakDays, 3);
      expect(data.longestStreakDays, 3);
      expect(data.totalVolumeKg, 12500);
      expect(data.lastWorkoutDate, DateTime(2026, 10, 23));

      expect(data.activeProgram?.program.name, 'Alice Strength Block');
      expect(data.completedProgramDays, 1);
      expect(data.programProgress, closeTo(1 / 3, 0.001));

      expect(data.savedDietPlan?.name, 'Alice Saved Plan');
      expect(data.savedDietPlanMeals.single.name, 'Swapped eggs');
      expect(data.nutritionTargets?.userId, 'Alice');
      expect(data.targetCalories, 2200);
      expect(data.consumedCaloriesToday, 700);
      expect(data.consumedProteinTodayG, 45);
      expect(data.mealsLoggedToday, 2);
    });

    test('foreign active program and targets are not presented as the user\'s',
        () {
      const foreignProgram = WorkoutProgram(
        id: 'foreign-program',
        name: 'Bob Program',
        description: 'Not Alice\'s',
        durationWeeks: 4,
        difficulty: 'beginner',
        userId: 'bob',
        days: [
          ProgramDay(
            dayNumber: 1,
            name: 'Day 1',
            focus: 'Full body',
            exercises: [],
          ),
        ],
      );

      final data = buildProfileData(
        profile: profile,
        accountUser: Alice,
        now: now,
        activeProgram: const ActiveProgram(
          id: 'foreign-active',
          program: foreignProgram,
          currentDayIndex: 0,
          isActive: true,
          userId: 'bob',
        ),
        todayNutrition: DailyNutritionSummary(
          date: now,
          target: targets('bob'),
          meals: const [],
        ),
      );

      expect(data.activeProgram, isNull);
      expect(data.nutritionTargets, isNull);
      // Falls back to targets derived from Alice's own profile.
      expect(data.nutritionTargetSourceLabel, 'Targets from your profile');
      expect(data.targetCalories, profile.dailyCalorieTarget);
    });
  });
}
