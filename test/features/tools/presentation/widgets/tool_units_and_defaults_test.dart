import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/providers/units_provider.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/tools/presentation/widgets/calculator_sheets.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('Canonical Defaults & Units Conversion Across Calculator Sheets', () {
    test('NutritionDefaults.fallbackMacros matches UserProfileDefaults.referenceProfile math', () {
      const refProfile = UserProfileDefaults.referenceProfile;
      final fallback = NutritionDefaults.fallbackMacros;

      expect(fallback.calories, equals(refProfile.dailyCalorieTarget));
      expect(fallback.protein, equals(refProfile.dailyProteinTargetGrams));
      expect(fallback.carbs, equals(refProfile.dailyCarbTargetGrams));
      expect(fallback.fats, equals(refProfile.dailyFatTargetGrams));
      final macroSum =
          fallback.protein * 4 + fallback.carbs * 4 + fallback.fats * 9;
      expect(macroSum, closeTo(fallback.calories, 1.0));
    });

    testWidgets('OneRepMaxSheet renders imperial lbs units when selected', (tester) async {
      await tester.pumpWidget(
        wrap(
          const OneRepMaxSheet(
            initialWeight: 225.0,
            initialReps: 5,
            units: UnitsSystem.imperial,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('lbs'), findsWidgets);
      expect(find.textContaining('lbs'), findsWidgets);
    });

    testWidgets('CalorieMacroSheet, BodyFatSheet, WeightGoalSheet, WaterIntakeSheet convert units to imperial',
        (tester) async {
      for (final sheet in const <Widget>[
        CalorieMacroSheet(units: UnitsSystem.imperial),
        BodyFatSheet(units: UnitsSystem.imperial),
        WeightGoalSheet(units: UnitsSystem.imperial),
        WaterIntakeSheet(units: UnitsSystem.imperial),
      ]) {
        await tester.pumpWidget(wrap(sheet));
        await tester.pumpAndSettle();
        expect(find.textContaining('lbs'), findsWidgets);
      }
    });

    testWidgets('Imperial sheets convert typed inputs back to metric storage smoothly',
        (tester) async {
      final femaleProfile = UserProfileDefaults.referenceProfile.copyWith(
        sex: BiologicalSex.female,
      );

      await tester.pumpWidget(
        wrap(
          SingleChildScrollView(
            child: Column(
              children: [
                BodyFatSheet(profile: femaleProfile, units: UnitsSystem.imperial),
                const WeightGoalSheet(units: UnitsSystem.imperial),
                const CalorieMacroSheet(units: UnitsSystem.imperial),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Update BodyFat inputs (NECK, WAIST, HIP), WeightGoal, and CalorieMacro inputs.
      final neckField = find.widgetWithText(TextFormField, 'NECK');
      final waistField = find.widgetWithText(TextFormField, 'WAIST');
      final hipField = find.widgetWithText(TextFormField, 'HIP');
      final curWeightField = find.widgetWithText(TextFormField, 'CURRENT WEIGHT');
      final targetWeightField = find.widgetWithText(TextFormField, 'TARGET WEIGHT');
      final calWeightField = find.widgetWithText(TextFormField, 'WEIGHT');
      final heightField = find.widgetWithText(TextFormField, 'HEIGHT');
      final ageField = find.widgetWithText(TextFormField, 'AGE');

      await tester.enterText(neckField, '14.5');
      await tester.enterText(waistField, '29.0');
      await tester.enterText(hipField, '38.0');
      await tester.enterText(curWeightField, '165');
      await tester.enterText(targetWeightField, '155');
      await tester.enterText(calWeightField, '170');
      await tester.enterText(heightField, '69.0');
      await tester.enterText(ageField, '28');
      await tester.pumpAndSettle();

      expect(find.text('HIP'), findsOneWidget);
      expect(find.textContaining('lbs'), findsWidgets);
    });
  });
}
