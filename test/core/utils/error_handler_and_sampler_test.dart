import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/error/exceptions.dart';
import 'package:progression_tracker/core/utils/chart_data_sampler.dart';
import 'package:progression_tracker/core/utils/error_handler.dart';
import 'package:progression_tracker/features/nutrition/domain/exceptions/diet_plan_exceptions.dart';
import 'package:progression_tracker/features/workout/domain/exceptions/workout_exceptions.dart';

void main() {
  group('ChartDataSampler', () {
    test('returns data unchanged when length <= maxPoints', () {
      final input = [1, 2, 3, 4, 5];
      expect(ChartDataSampler.sample(input, maxPoints: 5), same(input));
      expect(ChartDataSampler.sample(input, maxPoints: 10), same(input));
    });

    test('downsamples large datasets while preserving first and last points', () {
      final input = List.generate(250, (i) => i);
      final sampled = ChartDataSampler.sample(input, maxPoints: 25);

      expect(sampled, hasLength(25));
      expect(sampled.first, 0);
      expect(sampled.last, 249);
    });
  });

  group('ErrorHandler', () {
    Future<void> pumpHost(
      WidgetTester tester,
      void Function(BuildContext context) action,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(extensions: [AppThemeTokens.dark]),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => action(context),
                child: const Text('TRIGGER'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('TRIGGER'));
      await tester.pumpAndSettle();
    }

    testWidgets('maps known domain, core, and unexpected errors into Notice dialogs', (tester) async {
      final cases = <(Object, String)>[
        (ActiveProgramException(message: 'Active plan missing'), 'Active plan missing'),
        (ProgramValidationException(message: 'Bad set target'), 'Bad set target'),
        (DietPlanException(message: 'Meal slot unavailable'), 'Meal slot unavailable'),
        (InvalidRepsException(), 'Reps must be a positive integer'),
        (InvalidWeightException(), 'Weight must be a positive number'),
        (InvalidRPEException(), 'RPE must be between 1 and 10'),
        (InvalidMacroException(), 'Macro values must be non-negative'),
        (EntityNotFoundException('Workout', 'w1'), 'Item not found'),
        (StorageException('Disk full'), 'Failed to save data. Please try again.'),
        (SerializationException('Bad JSON'), 'Failed to process data. Please try again.'),
        (StateError('unexpected'), 'An unexpected error occurred'),
      ];

      for (final (error, expectedMessage) in cases) {
        await pumpHost(
          tester,
          (ctx) => ErrorHandler.handleError(ctx, error, StackTrace.current),
        );
        expect(find.text('Notice'), findsOneWidget);
        expect(find.text(expectedMessage), findsOneWidget);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(find.text('Notice'), findsNothing);
      }
    });

    testWidgets('showSnackBar displays floating message banner', (tester) async {
      await pumpHost(
        tester,
        (ctx) => ErrorHandler.showSnackBar(ctx, 'Saved cleanly'),
      );
      expect(find.text('Saved cleanly'), findsOneWidget);
    });
  });
}
