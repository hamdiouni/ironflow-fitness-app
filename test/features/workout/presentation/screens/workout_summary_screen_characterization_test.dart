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

    testWidgets('enforces canonical section order: result -> PRs -> collapsed exercise sets -> suggestions -> Done', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      const suggestion = ProgressionSuggestion(
        suggestedWeight: 92.5,
        suggestedReps: 8,
        isStagnant: false,
        message: 'Add 2.5kg next session',
      );

      final router = GoRouter(
        initialLocation: '/summary',
        routes: [
          GoRoute(
            path: '/summary',
            builder: (context, state) => Scaffold(
              body: WorkoutSummaryScreen(
                totalSets: 3,
                totalVolume: 2100.0,
                duration: const Duration(minutes: 35),
                prCount: 1,
                exercises: [
                  Exercise(
                    id: 'ex-bench',
                    name: 'Bench Press',
                    type: ExerciseType.strength,
                    sets: [
                      SetEntry(
                        id: 's1',
                        reps: 10,
                        weight: 40.0,
                        type: SetType.warmup,
                        timestamp: DateTime(2026, 10, 28),
                      ),
                      SetEntry(
                        id: 's2',
                        reps: 8,
                        weight: 85.0,
                        type: SetType.normal,
                        timestamp: DateTime(2026, 10, 28),
                      ),
                    ],
                  ),
                ],
                exerciseNames: const ['Bench Press'],
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            progressionSuggestionProvider('Bench Press').overrideWith(
              (ref) async => suggestion,
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final resultTop =
          tester.getTopLeft(find.byKey(const Key('summary_section_result'))).dy;
      final prsTop =
          tester.getTopLeft(find.byKey(const Key('summary_section_prs'))).dy;
      final exercisesTop = tester
          .getTopLeft(find.byKey(const Key('summary_section_exercises')))
          .dy;
      final suggestionsTop = tester
          .getTopLeft(find.byKey(const Key('summary_section_suggestions')))
          .dy;
      final doneTop =
          tester.getTopLeft(find.byKey(const Key('summary_section_done'))).dy;

      expect(resultTop, lessThan(prsTop));
      expect(prsTop, lessThan(exercisesTop));
      expect(exercisesTop, lessThan(suggestionsTop));
      expect(suggestionsTop, lessThan(doneTop));

      // Exercise set list starts collapsed; expanding shows individual set breakdown
      expect(find.text('85.0 kg × 8'), findsNothing);
      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();
      expect(find.text('85.0 kg × 8'), findsOneWidget);

      // Tapping Done button navigates home
      await tester.tap(find.byKey(const Key('summary_done_button')));
      await tester.pumpAndSettle();
      expect(find.text('Home Screen Destination'), findsOneWidget);
    });

    testWidgets('loads saved workout summary by session ID after refresh / direct web link', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final savedWorkout = Workout(
        id: 'session-42',
        date: DateTime(2026, 10, 28, 18, 0),
        duration: const Duration(minutes: 48, seconds: 30),
        totalVolume: 1600.0,
        exercises: [
          Exercise(
            id: 'ex-1',
            name: 'Overhead Press',
            type: ExerciseType.strength,
            sets: [
              SetEntry(
                id: 'w1',
                reps: 10,
                weight: 20.0,
                type: SetType.warmup,
                timestamp: DateTime(2026, 10, 28, 18, 5),
              ),
              SetEntry(
                id: 's1',
                reps: 8,
                weight: 50.0,
                type: SetType.normal,
                timestamp: DateTime(2026, 10, 28, 18, 10),
              ),
              SetEntry(
                id: 's2',
                reps: 8,
                weight: 50.0,
                type: SetType.normal,
                timestamp: DateTime(2026, 10, 28, 18, 15),
              ),
            ],
          ),
        ],
      );

      final router = GoRouter(
        initialLocation: '/workout/summary?workoutId=session-42',
        routes: [
          GoRoute(
            path: '/workout/summary',
            builder: (context, state) => WorkoutSummaryScreen(
              workoutId: state.uri.queryParameters['workoutId'],
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutHistoryProvider.overrideWith(
              (ref) async => [savedWorkout],
            ),
            progressionSuggestionProvider('Overhead Press').overrideWith(
              (ref) async => null,
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Working sets only (2 working sets, warmup excluded; 800 kg working volume)
      expect(find.text('48m 30s'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('800 kg'), findsOneWidget);
      expect(find.text('Overhead Press'), findsOneWidget);
      expect(find.text('2 working sets'), findsOneWidget);
    });
  });
}
