import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/tools/presentation/screens/tools_hub_screen.dart';

void main() {
  const testProfile = UserProfile(
    goal: FitnessGoal.maintain,
    age: 28,
    weightKg: 80.0,
    heightCm: 180.0,
    fitnessLevel: FitnessLevel.intermediate,
    equipment: EquipmentType.gym,
    workoutDaysPerWeek: 4,
    budget: BudgetLevel.medium,
    sex: BiologicalSex.male,
  );

  Widget createTestWidget({UserProfile? profile = testProfile}) {
    return ProviderScope(
      overrides: [
        userProfileProvider.overrideWith((ref) => Future.value(profile)),
      ],
      child: const MaterialApp(
        home: ToolsHubScreen(),
      ),
    );
  }

  group('ToolsHubScreen Widget Tests', () {
    testWidgets('Renders all 6 calculator cards and header', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('CALCULATORS & TOOLS'), findsOneWidget);
      expect(find.text('Barbell Plate Calculator'), findsOneWidget);
      expect(find.text('1RM Strength Calculator'), findsOneWidget);
      expect(find.text('Calorie & Macro Calculator'), findsOneWidget);
      expect(find.text('Body Fat % Calculator'), findsOneWidget);
      expect(find.text('Weight Goal Planner'), findsOneWidget);
      expect(find.text('Daily Water Intake Target'), findsOneWidget);
    });

    testWidgets('Tapping 1RM Strength Calculator opens 1RM bottom sheet', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('tool_card_1rm')));
      await tester.pumpAndSettle();

      expect(find.text('1RM CALCULATOR'), findsOneWidget);
      expect(find.text('ESTIMATED 1-REP MAX'), findsOneWidget);
      expect(find.text('TRAINING PERCENTAGES'), findsOneWidget);
    });

    testWidgets('Tapping Calorie & Macro Calculator opens Calorie sheet', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('tool_card_calorie_macro')));
      await tester.pumpAndSettle();

      expect(find.text('CALORIE & MACRO CALCULATOR'), findsOneWidget);
      expect(find.text('DAILY CALORIC TARGET'), findsOneWidget);
      expect(find.text('PROTEIN'), findsOneWidget);
      expect(find.text('CARBS'), findsOneWidget);
      expect(find.text('FATS'), findsOneWidget);
    });

    testWidgets('Tapping Water Intake Target opens hydration sheet', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('tool_card_water_intake')));
      await tester.pumpAndSettle();

      expect(find.text('DAILY WATER INTAKE'), findsOneWidget);
      expect(find.text('DAILY HYDRATION TARGET'), findsOneWidget);
    });
  });
}
