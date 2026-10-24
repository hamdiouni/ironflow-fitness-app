import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/diet_plan.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/diet_plan_state.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/profile/presentation/providers/profile_data_provider.dart';
import 'package:progression_tracker/features/profile/presentation/screens/profile_screen.dart';
import 'package:progression_tracker/features/workout/domain/entities/active_program.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout_program.dart';

import '../../../ai/integration/screen_integration_test.dart';

void main() {
  const testProfile = UserProfile(
    goal: FitnessGoal.gainMuscle,
    age: 26,
    weightKg: 82.5,
    heightCm: 180,
    fitnessLevel: FitnessLevel.intermediate,
    equipment: EquipmentType.gym,
    workoutDaysPerWeek: 4,
    budget: BudgetLevel.medium,
  );

  ProfileData buildLinkedData() {
    final now = DateTime(2026, 10, 23, 12);
    return buildProfileData(
      profile: testProfile,
      accountUser: User(
        id: 'Alice',
        email: 'Alice@example.com',
        displayName: 'Alice Martin',
        photoUrl: null,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2026, 1, 1),
      ),
      now: now,
      bodyEntries: [
        BodyEntry(
          id: 'body-latest',
          date: DateTime(2026, 10, 20),
          weight: 79,
          measurements: const {},
          userId: 'Alice',
        ),
      ],
      workouts: [
        Workout(
          id: 'w1',
          date: DateTime(2026, 10, 23),
          exercises: const [],
          duration: const Duration(minutes: 50),
          totalVolume: 12500,
          userId: 'Alice',
        ),
        Workout(
          id: 'w2',
          date: DateTime(2026, 10, 22),
          exercises: const [],
          duration: const Duration(minutes: 40),
          totalVolume: 8000,
          userId: 'Alice',
        ),
      ],
      activeProgram: const ActiveProgram(
        id: 'active-1',
        currentDayIndex: 2,
        isActive: true,
        userId: 'Alice',
        program: WorkoutProgram(
          id: 'program-1',
          name: 'Alice Strength Block',
          description: 'Saved program description',
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
        ),
      ),
      dietPlanState: const DietPlanState(
        plan: DietPlan(
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
                  name: 'Protein oats',
                  ingredients: ['oats', 'whey'],
                  calories: 450,
                  proteinG: 35,
                  carbsG: 50,
                  fatsG: 10,
                ),
              ],
            ),
          ],
        ),
      ),
      todayNutrition: DailyNutritionSummary(
        date: now,
        target: NutritionTargets(
          userId: 'Alice',
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
        ),
        meals: [
          Meal(
            id: 'meal-1',
            name: 'Lunch',
            macros: const MealMacros(
              calories: 700,
              protein: 45,
              carbs: 60,
              fats: 25,
            ),
            micros:
                const MealMicros(fiber: 0, sugar: 0, sodium: 0, potassium: 0),
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
            userId: 'Alice',
          ),
        ],
      ),
    );
  }

  Widget createWidgetUnderTest({
    UserProfile? profile = testProfile,
    ThemeMode themeMode = ThemeMode.dark,
  }) {
    return ProviderScope(
      overrides: [
        globalAIProvider.overrideWith((ref) => FakeGlobalAINotifier(
              const GlobalAIState(),
            )),
        userProfileProvider.overrideWith((ref) async => profile),
        profileDataProvider.overrideWith((ref) => buildLinkedData()),
      ],
      child: MaterialApp(
        themeMode: themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          extensions: [AppThemeTokens.light],
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          extensions: [AppThemeTokens.dark],
        ),
        home: const ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen Widget Tests (Monolithic Sci-Fi)', () {
    testWidgets('renders the signed-in user\'s linked real data',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('PROFILE'), findsOneWidget);
      expect(find.text('PROFILE & WORKOUT PLAN'), findsOneWidget);

      // Identity comes from the auth account, not the goal.
      expect(find.text('Alice MARTIN'), findsOneWidget);
      expect(find.text('Alice@example.com'), findsOneWidget);
      expect(find.text('AM'), findsOneWidget);
      expect(
        find.textContaining('GAIN MUSCLE · INTERMEDIATE · FULL GYM · SINCE 2024'),
        findsOneWidget,
      );
      expect(find.text('DAY 3 · 2X / WEEK'), findsOneWidget);

      // Body stats reflect the latest logged entry, not onboarding.
      expect(find.text('AGE'), findsOneWidget);
      expect(find.text('26'), findsOneWidget);
      expect(find.text('WEIGHT'), findsOneWidget);
      expect(find.text('79.0'), findsOneWidget);
      expect(find.text('82.5'), findsNothing);
      expect(find.text('HEIGHT'), findsOneWidget);
      expect(find.text('180'), findsOneWidget);
      expect(find.text('BMI'), findsOneWidget);

      // Real workout activity.
      expect(find.text('WORKOUTS'), findsOneWidget);
      expect(find.text('THIS WEEK'), findsOneWidget);
      expect(find.text('STREAK'), findsOneWidget);
      expect(find.text('20.5k'), findsOneWidget);

      // Saved active program, not a regenerated one.
      expect(find.text('WORKOUT PROGRAM'), findsOneWidget);
      expect(find.text('ACTIVE PROTOCOL'), findsOneWidget);
      expect(find.text('Alice Strength Block'), findsOneWidget);

      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -700),
      );
      await tester.pumpAndSettle();

      // Saved diet plan + today's logged intake vs saved targets.
      expect(find.text('NUTRITION PROTOCOL'), findsOneWidget);
      expect(find.text('Alice Saved Plan'), findsOneWidget);
      expect(
        find.text('TODAY: 700 / 2200 KCAL · 1 MEAL LOGGED'),
        findsOneWidget,
      );
      expect(find.text('45/180 G'), findsOneWidget);
      expect(find.textContaining('SAMPLE'), findsNothing);
      expect(find.text('Protein oats'), findsOneWidget);
    });

    testWidgets('renders empty state when userProfile is null', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest(profile: null));
      await tester.pumpAndSettle();

      expect(find.text('NO PROFILE FOUND'), findsOneWidget);
      expect(find.text('START SETUP'), findsOneWidget);
    });
  });
}
