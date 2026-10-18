import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/screens/workout_summary_screen.dart';

void main() {
  Widget buildTestWidget({
    required int totalSets,
    required double totalVolume,
    required Duration duration,
    required int prCount,
    required List<String> exerciseNames,
    List<Override> overrides = const [],
  }) {
    final router = GoRouter(
      initialLocation: '/summary',
      routes: [
        GoRoute(
          path: '/summary',
          builder: (context, state) => Scaffold(
            body: WorkoutSummaryScreen(
              totalSets: totalSets,
              totalVolume: totalVolume,
              duration: duration,
              prCount: prCount,
              exerciseNames: exerciseNames,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const Scaffold(
            body: Text('Home Screen Destination'),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('WorkoutSummaryScreen Characterization Tests (Unmodified Baseline)', () {
    testWidgets('renders all metric cards with formatted values', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestWidget(
          totalSets: 12,
          totalVolume: 4500.5,
          duration: const Duration(minutes: 42, seconds: 15),
          prCount: 2,
          exerciseNames: ['Bench Press'],
          overrides: [
            progressionSuggestionProvider('Bench Press').overrideWith(
              (ref) async => null,
            ),
          ],
        ),
      );

      // Settle animations
      await tester.pumpAndSettle();

      // Check summary title and subtitle
      expect(find.text('Workout Complete!'), findsOneWidget);
      expect(find.text("Great job! Here's your summary"), findsOneWidget);

      // Total sets
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Sets'), findsOneWidget);

      // Total volume
      expect(find.text('4.5k kg'), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);

      // Duration
      expect(find.text('42m 15s'), findsOneWidget);
      expect(find.text('Duration'), findsOneWidget);

      // PRs badge
      expect(find.text('2 Personal Records Achieved'), findsOneWidget);

      // Tap prompt
      expect(find.text('Tap anywhere to continue'), findsOneWidget);

      // Auto-nav timer cleanup
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('displays progression suggestion card when available, handles accept/dismiss', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const suggestion = ProgressionSuggestion(
        suggestedWeight: 85.0,
        suggestedReps: 8,
        isStagnant: false,
        message: 'Increase load by 2.5kg next session',
      );

      await tester.pumpWidget(
        buildTestWidget(
          totalSets: 8,
          totalVolume: 2400.0,
          duration: const Duration(minutes: 30),
          prCount: 0,
          exerciseNames: ['Squat'],
          overrides: [
            progressionSuggestionProvider('Squat').overrideWith(
              (ref) async => suggestion,
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Verify suggestion section & card rendered
      expect(find.text('Progression Suggestions'), findsOneWidget);
      expect(find.text('Increase load by 2.5kg next session'), findsOneWidget);
      expect(find.text('Suggested Weight:'), findsOneWidget);
      expect(find.text('85.0 kg'), findsOneWidget);
      expect(find.text('Suggested Reps:'), findsOneWidget);

      // Verify Accept action
      final acceptButton = find.widgetWithText(ElevatedButton, 'Accept');
      expect(acceptButton, findsOneWidget);
      await tester.ensureVisible(acceptButton);
      await tester.tap(acceptButton);
      await tester.pump();
      expect(find.text('Suggestion accepted for Squat'), findsOneWidget);

      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('tap on screen invokes navigation callback via GoRouter', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          totalSets: 5,
          totalVolume: 1200.0,
          duration: const Duration(minutes: 20),
          prCount: 0,
          exerciseNames: const [],
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Tap anywhere to continue'), findsOneWidget);

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(find.text('Home Screen Destination'), findsOneWidget);
    });
  });
}
