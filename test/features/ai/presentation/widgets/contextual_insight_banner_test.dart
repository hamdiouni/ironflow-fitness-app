import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/presentation/providers/banner_dismissal_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/contextual_insight_banner.dart';
import '../../integration/screen_integration_test.dart';

void main() {
  group('ContextualInsightBanner Widget Tests', () {
    late List<Insight> mockWorkoutInsights;

    setUp(() {
      mockWorkoutInsights = [
        Insight(
          id: 'workout-tip-1',
          context: InsightContext.workout,
          title: 'Deload Week Recommended',
          message: 'Your training volume was peak over the last 3 weeks.',
          icon: '🏋️',
          priority: InsightPriority.high,
          generatedAt: DateTime.now(),
        ),
        Insight(
          id: 'workout-tip-2',
          context: InsightContext.workout,
          title: 'Hydration Check',
          message: 'Drink at least 500ml before your session.',
          icon: '💧',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now(),
        ),
      ];
    });

    Widget createTestWidget({
      required InsightContext context,
      required GlobalAIState state,
      Set<String>? initialDismissed,
      Size surfaceSize = const Size(390, 844),
      double textScale = 1.0,
    }) {
      return ProviderScope(
        overrides: [
          globalAIProvider.overrideWith((ref) => FakeGlobalAINotifier(state)),
          if (initialDismissed != null)
            bannerDismissalProvider.overrideWith(
              (ref) => BannerDismissalNotifier(initial: initialDismissed),
            ),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: surfaceSize,
              textScaler: TextScaler.linear(textScale),
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: ContextualInsightBanner(context: context),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('never renders on Home screen even when home insights exist',
        (tester) async {
      final homeInsights = [
        Insight(
          id: 'home-tip-1',
          context: InsightContext.home,
          title: 'Home Tip',
          message: 'Hero card handles this.',
          icon: '🏠',
          priority: InsightPriority.high,
          generatedAt: DateTime.now(),
        ),
      ];

      final state = GlobalAIState(
        insights: {InsightContext.home: homeInsights},
      );

      await tester.pumpWidget(
        createTestWidget(
          context: InsightContext.home,
          state: state,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home Tip'), findsNothing);
      expect(find.text('Hero card handles this.'), findsNothing);
    });

    testWidgets('renders at most ONE top insight on Workout screen',
        (tester) async {
      final state = GlobalAIState(
        insights: {InsightContext.workout: mockWorkoutInsights},
      );

      await tester.pumpWidget(
        createTestWidget(
          context: InsightContext.workout,
          state: state,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Deload Week Recommended'), findsOneWidget);
      expect(
        find.text('Your training volume was peak over the last 3 weeks.'),
        findsOneWidget,
      );

      // Second insight must NOT be shown concurrently
      expect(find.text('Hydration Check'), findsNothing);
    });

    testWidgets('dismissing banner removes it from the UI and updates provider',
        (tester) async {
      final state = GlobalAIState(
        insights: {InsightContext.workout: [mockWorkoutInsights.first]},
      );

      await tester.pumpWidget(
        createTestWidget(
          context: InsightContext.workout,
          state: state,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Deload Week Recommended'), findsOneWidget);

      // Tap dismiss icon button
      final dismissFinder = find.byTooltip('Dismiss');
      expect(dismissFinder, findsOneWidget);
      await tester.tap(dismissFinder);
      await tester.pumpAndSettle();

      // Banner should now be gone
      expect(find.text('Deload Week Recommended'), findsNothing);
    });

    testWidgets('pre-dismissed insight is skipped and next active insight is shown',
        (tester) async {
      final state = GlobalAIState(
        insights: {InsightContext.workout: mockWorkoutInsights},
      );

      await tester.pumpWidget(
        createTestWidget(
          context: InsightContext.workout,
          state: state,
          initialDismissed: {'workout-tip-1'},
        ),
      );
      await tester.pumpAndSettle();

      // First tip was dismissed, so second tip is shown
      expect(find.text('Deload Week Recommended'), findsNothing);
      expect(find.text('Hydration Check'), findsOneWidget);
    });

    testWidgets('tapping banner does not throw and has minimum 48dp dismiss button',
        (tester) async {
      final state = GlobalAIState(
        insights: {InsightContext.workout: mockWorkoutInsights},
      );

      await tester.pumpWidget(
        createTestWidget(
          context: InsightContext.workout,
          state: state,
        ),
      );
      await tester.pumpAndSettle();

      // Verify dismiss target size
      final dismissButton = find.byTooltip('Dismiss');
      final size = tester.getSize(dismissButton);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));

      // Tap the banner body
      await tester.tap(find.text('Deload Week Recommended'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles 1.5x font scale without overflow on small screens',
        (tester) async {
      final state = GlobalAIState(
        insights: {InsightContext.workout: mockWorkoutInsights},
      );

      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        createTestWidget(
          context: InsightContext.workout,
          state: state,
          surfaceSize: const Size(320, 568),
          textScale: 1.5,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Deload Week Recommended'), findsOneWidget);
    });
  });
}
