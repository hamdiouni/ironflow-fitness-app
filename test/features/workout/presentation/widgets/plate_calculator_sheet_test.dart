import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/workout/presentation/widgets/plate_calculator_sheet.dart';

void main() {
  Widget buildTestableWidget({
    double initialWeight = 60.0,
    PlateUnit initialUnit = PlateUnit.kg,
    void Function(double weight)? onApplyWeight,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: PlateCalculatorSheet(
          initialWeight: initialWeight,
          initialUnit: initialUnit,
          onApplyWeight: onApplyWeight,
        ),
      ),
    );
  }

  group('PlateCalculatorSheet Tests', () {
    testWidgets('renders title, barbell diagram, and weight breakdown', (tester) async {
      await tester.pumpWidget(buildTestableWidget(initialWeight: 60.0));
      await tester.pumpAndSettle();

      expect(find.text('PLATE CALCULATOR'), findsOneWidget);
      expect(find.text('SLEEVE CONFIGURATION (ONE SIDE)'), findsOneWidget);
      expect(find.text('EACH SIDE REQUIRES:'), findsOneWidget);
      expect(find.text('60'), findsOneWidget);
      expect(find.text('BAR: 20 KG'), findsOneWidget);
    });

    testWidgets('calculates 60kg Olympic bar as 1x20kg plate per side', (tester) async {
      await tester.pumpWidget(buildTestableWidget(initialWeight: 60.0));
      await tester.pumpAndSettle();

      // (60 - 20) / 2 = 20kg per side -> 1 × 20 KG
      expect(find.text('1 × 20 KG'), findsOneWidget);
    });

    testWidgets('adjusting weight with +2.5kg button increments weight and recalculates', (tester) async {
      await tester.pumpWidget(buildTestableWidget(initialWeight: 60.0));
      await tester.pumpAndSettle();

      final plusButton = find.text('+2.5');
      expect(plusButton, findsOneWidget);
      await tester.tap(plusButton);
      await tester.pumpAndSettle();

      // New weight is 62.5 kg -> (62.5 - 20) / 2 = 21.25 -> 1 × 20 KG and 1 × 1.25 KG
      expect(find.text('62.5'), findsOneWidget);
      expect(find.text('1 × 20 KG'), findsOneWidget);
      expect(find.text('1 × 1.25 KG'), findsOneWidget);
    });

    testWidgets('switching from KG to LB updates unit and bar weight', (tester) async {
      await tester.pumpWidget(buildTestableWidget(initialWeight: 60.0, initialUnit: PlateUnit.kg));
      await tester.pumpAndSettle();

      final lbTab = find.text('LB');
      expect(lbTab, findsOneWidget);
      await tester.tap(lbTab);
      await tester.pumpAndSettle();

      expect(find.text('BAR: 45 LB'), findsOneWidget);
    });

    testWidgets('applying weight triggers callback with correct weight', (tester) async {
      double? appliedWeight;
      await tester.pumpWidget(buildTestableWidget(
        initialWeight: 100.0,
        onApplyWeight: (w) => appliedWeight = w,
      ));
      await tester.pumpAndSettle();

      final applyButton = find.text('APPLY WEIGHT');
      expect(applyButton, findsOneWidget);
      await tester.tap(applyButton);
      await tester.pumpAndSettle();

      expect(appliedWeight, equals(100.0));
    });
  });
}
