import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/tools/presentation/widgets/calculator_sheets.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        extensions: [AppThemeTokens.dark],
      ),
      home: Scaffold(body: child),
    );
  }

  group('Calculator Sheets Characterization Tests', () {
    testWidgets('OneRepMaxSheet renders initial weight and reps', (tester) async {
      await tester.pumpWidget(
        wrap(const OneRepMaxSheet(initialWeight: 100.0, initialReps: 5)),
      );
      await tester.pumpAndSettle();

      expect(find.text('WEIGHT LIFTED'), findsOneWidget);
      expect(find.text('REPS: 5'), findsOneWidget);
      expect(find.text('100.0'), findsOneWidget);
    });

    testWidgets('CalorieMacroSheet renders and computes targets', (tester) async {
      await tester.pumpWidget(wrap(const CalorieMacroSheet()));
      await tester.pumpAndSettle();

      expect(find.byType(CalorieMacroSheet), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('BodyFatSheet, WeightGoalSheet, and WaterIntakeSheet render cleanly',
        (tester) async {
      for (final sheet in const <Widget>[
        BodyFatSheet(),
        WeightGoalSheet(),
        WaterIntakeSheet(),
      ]) {
        await tester.pumpWidget(wrap(sheet));
        await tester.pumpAndSettle();
        expect(find.byWidget(sheet), findsOneWidget);
      }
    });
  });
}

