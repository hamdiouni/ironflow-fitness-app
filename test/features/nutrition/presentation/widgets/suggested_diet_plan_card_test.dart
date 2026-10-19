import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/diet_plan.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/diet_plan_state.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/diet_plan_providers.dart';
import 'package:progression_tracker/features/nutrition/presentation/widgets/suggested_diet_plan_card.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';

void main() {
  const testProfile = UserProfile(
    goal: FitnessGoal.loseWeight,
    age: 25,
    weightKg: 75,
    heightCm: 175,
    fitnessLevel: FitnessLevel.intermediate,
    equipment: EquipmentType.gym,
    workoutDaysPerWeek: 4,
    budget: BudgetLevel.low,
    sex: BiologicalSex.male,
  );
  final testPlan = DietPlan(
    name: 'Budget-Friendly Fat Loss Plan',
    dailyCalories: 2100,
    proteinG: 160,
    carbsG: 220,
    fatsG: 55,
    days: [
      const DietDay(
        dayName: 'Day 1',
        meals: [
          DietMeal(
            mealType: MealType.breakfast,
            name: 'Scrambled Eggs & Whole Wheat Toast',
            ingredients: ['100g Whole Eggs', '64g Whole Wheat Bread'],
            calories: 450,
            proteinG: 25,
            carbsG: 35,
            fatsG: 15,
            prepTime: '8 min',
            alternatives: ['Oatmeal with peanut butter'],
          ),
          DietMeal(
            mealType: MealType.lunch,
            name: 'Canned Tuna & Brown Rice Bowl',
            ingredients: ['140g Canned Tuna in Water', '200g Cooked Brown Rice'],
            calories: 650,
            proteinG: 45,
            carbsG: 60,
            fatsG: 10,
            prepTime: '10 min',
            alternatives: ['Chicken thigh with potato'],
          ),
        ],
      ),
      const DietDay(
        dayName: 'Day 2',
        meals: [
          DietMeal(
            mealType: MealType.breakfast,
            name: 'Peanut Butter Oatmeal',
            ingredients: ['60g Oats', '30g Peanut Butter'],
            calories: 480,
            proteinG: 20,
            carbsG: 55,
            fatsG: 18,
            prepTime: '5 min',
            alternatives: ['Scrambled eggs'],
          ),
        ],
      ),
    ],
    tips: ['Buy oats and tuna in bulk to save.'],
  );

  Widget createWidget({
    DietPlanState? planState,
    Future<void> Function(Meal)? onLogMeal,
    void Function(Meal)? onSwapMeal,
  }) {
    return ProviderScope(
      overrides: [
        dietPlanProvider.overrideWith((ref) => Future.value(planState)),
        userProfileProvider.overrideWith((ref) => Future.value(testProfile)),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SuggestedDietPlanCard(
              onLogMeal: onLogMeal ?? (_) async {},
              onSwapMeal: onSwapMeal,
            ),
          ),
        ),
      ),
    );
  }

  group('SuggestedDietPlanCard', () {
    testWidgets('renders invitation card when no diet plan is active', (tester) async {
      await tester.pumpWidget(createWidget(planState: null));
      await tester.pumpAndSettle();

      expect(find.text('OPTIONAL BUDGET MEAL PLAN'), findsOneWidget);
      expect(find.text('GET BUDGET MEAL PLAN'), findsOneWidget);
    });

    testWidgets('renders plan name, meals, and day selector when plan exists', (tester) async {
      final state = DietPlanState(plan: testPlan);
      await tester.pumpWidget(createWidget(planState: state));
      await tester.pumpAndSettle();

      expect(find.text('BUDGET-FRIENDLY FAT LOSS PLAN'), findsOneWidget);
      expect(find.text('Day 1'), findsOneWidget);
      expect(find.text('Day 2'), findsOneWidget);
      expect(find.text('Scrambled Eggs & Whole Wheat Toast'), findsOneWidget);
      expect(find.text('Canned Tuna & Brown Rice Bowl'), findsOneWidget);

      // Switch to Day 2
      await tester.tap(find.text('Day 2'));
      await tester.pumpAndSettle();

      expect(find.text('Peanut Butter Oatmeal'), findsOneWidget);
    });

    testWidgets('tap "LOG TO TODAY" logs the meal and displays SnackBar', (tester) async {
      Meal? loggedMeal;
      final state = DietPlanState(plan: testPlan);

      await tester.pumpWidget(createWidget(
        planState: state,
        onLogMeal: (meal) async {
          loggedMeal = meal;
        },
      ));
      await tester.pumpAndSettle();

      // Tap first "LOG TO TODAY" button
      final logButtons = find.text('LOG TO TODAY');
      expect(logButtons, findsWidgets);

      await tester.tap(logButtons.first);
      await tester.pumpAndSettle();

      expect(loggedMeal, isNotNull);
      expect(loggedMeal!.name, equals('Scrambled Eggs & Whole Wheat Toast'));
      expect(loggedMeal!.macros.calories, equals(450));
      expect(find.textContaining('Logged Scrambled Eggs & Whole Wheat Toast'), findsOneWidget);
    });

    testWidgets('tap "SWAP" calls onSwapMeal callback', (tester) async {
      Meal? swappedMeal;
      final state = DietPlanState(plan: testPlan);

      await tester.pumpWidget(createWidget(
        planState: state,
        onSwapMeal: (meal) {
          swappedMeal = meal;
        },
      ));
      await tester.pumpAndSettle();

      final swapButtons = find.text('SWAP');
      expect(swapButtons, findsWidgets);

      await tester.tap(swapButtons.first);
      await tester.pumpAndSettle();

      expect(swappedMeal, isNotNull);
      expect(swappedMeal!.name, equals('Scrambled Eggs & Whole Wheat Toast'));
    });
  });
}
