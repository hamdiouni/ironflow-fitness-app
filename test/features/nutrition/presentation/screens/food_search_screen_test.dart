import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';
import 'package:progression_tracker/features/nutrition/presentation/screens/food_search_screen.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';

void main() {
  Widget buildTestableWidget({
    required void Function(FoodItem food, double grams) onFoodLogged,
  }) {
    return ProviderScope(
      overrides: [
        userProfileProvider.overrideWith((ref) => Future.value(null)),
      ],
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: FoodSearchScreen(onFoodLogged: onFoodLogged),
      ),
    );
  }

  group('FoodSearchScreen Widget Tests (Monolithic Sci-Fi Fuel Experience)', () {
    testWidgets('renders Sci-Fi headers, search input, and filter pills',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableWidget(onFoodLogged: (_, _) {}),
      );
      await tester.pumpAndSettle();

      expect(find.text('FUEL DATABASE'), findsOneWidget);
      expect(find.text('VERIFIED NUTRITION TELEMETRY'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Verify category pills exist
      expect(find.text('ALL CATEGORIES'), findsOneWidget);
      expect(find.text('PROTEIN'), findsOneWidget);

      // Verify budget pills exist
      expect(find.text('ALL BUDGETS'), findsOneWidget);
      expect(find.text('BUDGET \$'), findsWidgets);
      expect(find.text('MODERATE \$\$'), findsWidgets);
      expect(find.text('PREMIUM \$\$\$'), findsWidgets);
    });

    testWidgets('tapping a food card opens detail sheet with serving controls and micros',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      FoodItem? loggedFood;
      double? loggedGrams;

      await tester.pumpWidget(
        buildTestableWidget(
          onFoodLogged: (food, grams) {
            loggedFood = food;
            loggedGrams = grams;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the chicken breast item
      final chickenFinder = find.text('Chicken Breast (Raw)');
      expect(chickenFinder, findsOneWidget);
      await tester.tap(chickenFinder);
      await tester.pumpAndSettle();

      // Check detail sheet elements
      expect(find.text('SCIENTIFIC PROFILE & BIOAVAILABILITY'), findsOneWidget);
      expect(find.text('BY STANDARD SERVING'), findsOneWidget);
      expect(find.text('CUSTOM GRAM WEIGHT'), findsOneWidget);
      expect(find.text('EXACT MICRONUTRIENT TELEMETRY'), findsOneWidget);

      // Confirm button is present
      final confirmBtnFinder = find.textContaining('LOG');
      expect(confirmBtnFinder, findsWidgets);

      // Tap confirm to log
      await tester.tap(confirmBtnFinder.last);
      await tester.pumpAndSettle();

      expect(loggedFood, isNotNull);
      expect(loggedFood!.id, equals('usda_chicken_breast_raw'));
      expect(loggedGrams, greaterThan(0));
    });
  });
}
