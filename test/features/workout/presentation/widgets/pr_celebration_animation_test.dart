import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/screens/workout_summary_screen.dart';
import 'package:progression_tracker/shared/animations/pr_celebration_animation.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PRCelebrationAnimation Widget Tests', () {
    testWidgets('renders single PR text and telemetry by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PRCelebrationAnimation(),
          ),
        ),
      );

      // Verify widget elements
      expect(find.byKey(const ValueKey('pr_celebration_badge')), findsOneWidget);
      expect(find.text('TELEMETRY // MILESTONE'), findsOneWidget);
      expect(find.text('PERSONAL RECORD'), findsOneWidget);
      expect(find.text('PERFORMANCE THRESHOLD EXCEEDED'), findsOneWidget);
      expect(find.byIcon(Icons.workspace_premium_rounded), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('renders plural count when prCount > 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PRCelebrationAnimation(prCount: 3),
          ),
        ),
      );

      expect(find.text('3 PERSONAL RECORDS'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('respects MediaQuery disableAnimations (reduced motion)', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: PRCelebrationAnimation(prCount: 2),
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('pr_celebration_badge')), findsOneWidget);
      expect(find.text('2 PERSONAL RECORDS'), findsOneWidget);

      // In reduced motion mode, no ScaleTransition or FadeTransition is inside PRCelebrationAnimation
      expect(
        find.descendant(
          of: find.byType(PRCelebrationAnimation),
          matching: find.byType(ScaleTransition),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: find.byType(PRCelebrationAnimation),
          matching: find.byType(FadeTransition),
        ),
        findsNothing,
      );

      await tester.pumpAndSettle();
    });

    testWidgets('wraps with ScaleTransition and FadeTransition when animations enabled', (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: false),
          child: MaterialApp(
            home: Scaffold(
              body: PRCelebrationAnimation(prCount: 1),
            ),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(PRCelebrationAnimation),
          matching: find.byType(ScaleTransition),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(PRCelebrationAnimation),
          matching: find.byType(FadeTransition),
        ),
        findsOneWidget,
      );

      await tester.pumpAndSettle();
    });
  });

  group('WorkoutSummaryScreen PR Integration Tests', () {
    late AppHaptics mockHaptics;

    setUp(() {
      mockHaptics = AppHaptics(isEnabled: true);
      AppHaptics.shared = mockHaptics;
    });

    testWidgets('triggers milestoneReached and shows PRCelebrationAnimation when prCount > 0', (tester) async {
      final router = GoRouter(
        initialLocation: '/summary',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/summary',
            builder: (context, state) => const WorkoutSummaryScreen(
              totalSets: 12,
              totalVolume: 5000,
              duration: Duration(minutes: 45),
              prCount: 2,
              exerciseNames: ['Barbell Squat', 'Bench Press'],
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            progressionSuggestionProvider('Barbell Squat')
                .overrideWith((ref) => null),
            progressionSuggestionProvider('Bench Press')
                .overrideWith((ref) => null),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify PR celebration badge is present
      expect(find.byType(PRCelebrationAnimation), findsOneWidget);
      expect(find.text('2 PERSONAL RECORDS'), findsOneWidget);

      // Verify milestoneReached was recorded
      final targetDate = DateTime.now();
      final dateKey =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}_workout_pr';
      expect(mockHaptics.triggeredMilestones.contains(dateKey), isTrue);

      // Let auto-nav timer elapse safely
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });

    testWidgets('does not show PRCelebrationAnimation when prCount == 0', (tester) async {
      final router = GoRouter(
        initialLocation: '/summary',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/summary',
            builder: (context, state) => const WorkoutSummaryScreen(
              totalSets: 8,
              totalVolume: 3200,
              duration: Duration(minutes: 30),
              prCount: 0,
              exerciseNames: ['Overhead Press'],
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            progressionSuggestionProvider('Overhead Press')
                .overrideWith((ref) => null),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(PRCelebrationAnimation), findsNothing);
      expect(find.textContaining('PERSONAL RECORD'), findsNothing);

      // Let auto-nav timer elapse safely
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });
  });
}
