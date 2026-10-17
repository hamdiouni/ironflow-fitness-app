import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/diet_plan_state.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/diet_plan_providers.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:progression_tracker/features/nutrition/presentation/screens/nutrition_screen.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';

import '../../../ai/integration/screen_integration_test.dart';

class FakeDailyNutritionNotifier
    extends StateNotifier<AsyncValue<DailyNutritionSummary>>
    implements DailyNutritionNotifier {
  FakeDailyNutritionNotifier(DailyNutritionSummary summary)
      : super(AsyncValue.data(summary));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  DateTime todayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  NutritionTargets createTestTargets({
    double calories = 2000,
    double protein = 150,
    double carbs = 200,
    double fats = 60,
  }) {
    return NutritionTargets(
      userId: 'test-user',
      macros: MacroTargets(
        calories: calories,
        protein: protein,
        carbs: carbs,
        fats: fats,
      ),
      micros: const MicroTargets(fiber: 30, sugar: 50, sodium: 2300, potassium: 3500),
      vitamins: const VitaminTargets(vitaminA: 900, vitaminB: 2.4, vitaminC: 90, vitaminD: 20, vitaminE: 15),
      minerals: const MineralTargets(calcium: 1000, iron: 18, magnesium: 400, zinc: 11),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  Widget createWidgetUnderTest({
    DailyNutritionSummary? summary,
    DietPlanState? dietPlan,
    ThemeMode themeMode = ThemeMode.dark,
  }) {
    final today = todayDate();
    final effectiveSummary = summary ??
        DailyNutritionSummary(
          date: today,
          meals: const [],
          target: createTestTargets(),
        );

    return ProviderScope(
      overrides: [
        globalAIProvider.overrideWith(
          (ref) => FakeGlobalAINotifier(const GlobalAIState()),
        ),
        dailyNutritionSummaryProvider(today).overrideWith(
          (ref) => FakeDailyNutritionNotifier(effectiveSummary),
        ),
        dietPlanProvider.overrideWith(
          (ref) => Future.value(dietPlan),
        ),
        userProfileProvider.overrideWith(
          (ref) => Future.value(null),
        ),
      ],
      child: MaterialApp(
        themeMode: themeMode,
        theme: ThemeData.light().copyWith(
          extensions: [AppThemeTokens.light],
        ),
        darkTheme: ThemeData.dark().copyWith(
          extensions: [AppThemeTokens.dark],
        ),
        home: const NutritionScreen(),
      ),
    );
  }

  group('NutritionScreen Widget Tests (Monolithic Sci-Fi)', () {
    testWidgets('renders NUTRITION title, targets HUD, macro gauge and CTAs', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('NUTRITION'), findsOneWidget);
      expect(find.text('DAILY TARGET PROTOCOL'), findsOneWidget);
      expect(find.text('CALORIES'), findsWidgets);
      expect(find.text('REMAINING FUEL'), findsOneWidget);
      expect(find.text('TODAY\'S FUEL'), findsOneWidget);
      expect(find.text('SEARCH & LOG FOOD'), findsOneWidget);
      expect(find.text('LOG CUSTOM MEAL'), findsOneWidget);
    });

    testWidgets('renders logged meals with high contrast telemetry chips', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final today = todayDate();
      final summaryWithMeals = DailyNutritionSummary(
        date: today,
        meals: [
          Meal.create(
            name: 'Grilled Salmon Bowl',
            macros: const MealMacros(
              calories: 620,
              protein: 48,
              carbs: 52,
              fats: 22,
            ),
            micros: const MealMicros(fiber: 4, sugar: 2, sodium: 300, potassium: 500),
            vitamins: const MealVitamins(vitaminA: 0, vitaminB: 0, vitaminC: 0, vitaminD: 0, vitaminE: 0),
            minerals: const MealMinerals(calcium: 0, iron: 0, magnesium: 0, zinc: 0),
          ),
        ],
        target: createTestTargets(calories: 2200, protein: 160, carbs: 220, fats: 70),
      );

      await tester.pumpWidget(createWidgetUnderTest(summary: summaryWithMeals));
      await tester.pumpAndSettle();

      expect(find.text('Grilled Salmon Bowl'), findsOneWidget);
      expect(find.text('620 KCAL'), findsOneWidget);
      expect(find.text('1 LOGGED'), findsOneWidget);
    });
  });
}
