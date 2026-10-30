import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/providers/connectivity_provider.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/ai_coach_hero_card.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/ai_loading_state.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/ai_empty_state.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/ai_error_state.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/ai_offline_state.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/ai_no_key_state.dart';
import 'package:progression_tracker/shared/presentation/components/app_card.dart';
import '../../integration/screen_integration_test.dart';

void main() {
  group('AiCoachHeroCard Widget Tests', () {
    late List<Insight> mockInsights;

    setUp(() {
      mockInsights = [
        Insight(
          id: 'test-1',
          context: InsightContext.home,
          title: 'Optimal Recovery',
          message: 'Your sleep quality is excellent. Great time for heavy lifts!',
          icon: '💪',
          priority: InsightPriority.high,
          generatedAt: DateTime.now(),
        ),
        Insight(
          id: 'test-2',
          context: InsightContext.home,
          title: 'Macro Balance',
          message: 'Protein is right on track today.',
          icon: '🥗',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now(),
        ),
      ];
    });

    Widget createTestWidget({
      required GlobalAIState state,
      bool isOnline = true,
      bool isConfigured = true,
      Size surfaceSize = const Size(390, 844),
      double textScale = 1.0,
    }) {
      return ProviderScope(
        overrides: [
          globalAIProvider.overrideWith((ref) => FakeGlobalAINotifier(state)),
          isOnlineProvider.overrideWith((ref) => Stream.value(isOnline)),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: surfaceSize,
              textScaler: TextScaler.linear(textScale),
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: AiCoachHeroCard(isConfigured: isConfigured),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders success state with top insight and Chat with Coach CTA',
        (tester) async {
      final state = GlobalAIState(
        insights: {InsightContext.home: mockInsights},
        isLoading: {InsightContext.home: false},
      );

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(find.byType(AiCoachHeroCard), findsOneWidget);
      expect(find.text('AI COACH'), findsOneWidget);
      expect(find.text('Optimal Recovery'), findsOneWidget);
      expect(
        find.text('Your sleep quality is excellent. Great time for heavy lifts!'),
        findsOneWidget,
      );
      expect(find.text('Chat with Coach'), findsOneWidget);
    });

    testWidgets('renders loading shimmer state when loading and insights empty',
        (tester) async {
      final state = const GlobalAIState(
        insights: {InsightContext.home: []},
        isLoading: {InsightContext.home: true},
      );

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pump();

      expect(find.byType(AiLoadingState), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('renders empty state when no insights available',
        (tester) async {
      final state = const GlobalAIState(
        insights: {InsightContext.home: []},
        isLoading: {InsightContext.home: false},
      );

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(find.byType(AiEmptyState), findsOneWidget);
      expect(find.text('Start Your Journey'), findsOneWidget);
      expect(find.text('Ask Coach Anything'), findsOneWidget);
    });

    testWidgets('renders error state with retry button', (tester) async {
      final state = const GlobalAIState(
        insights: {InsightContext.home: []},
        isLoading: {InsightContext.home: false},
        errors: {InsightContext.home: 'Failed to connect to AI service'},
      );

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(find.byType(AiErrorState), findsOneWidget);
      expect(find.text('Failed to connect to AI service'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('renders offline state when offline and insights empty',
        (tester) async {
      final state = const GlobalAIState(
        insights: {InsightContext.home: []},
        isLoading: {InsightContext.home: false},
      );

      await tester.pumpWidget(createTestWidget(state: state, isOnline: false));
      await tester.pumpAndSettle();

      expect(find.byType(AiOfflineState), findsOneWidget);
      expect(find.text("You're currently offline"), findsOneWidget);
    });

    testWidgets('renders no-key state when not configured and no insights',
        (tester) async {
      final state = const GlobalAIState(
        insights: {InsightContext.home: []},
        isLoading: {InsightContext.home: false},
      );

      await tester.pumpWidget(
        createTestWidget(state: state, isConfigured: false),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AiNoKeyState), findsOneWidget);
      expect(find.text('AI Coach Unavailable'), findsOneWidget);
    });

    testWidgets('carousel switches between multiple insights on tap',
        (tester) async {
      final state = GlobalAIState(
        insights: {InsightContext.home: mockInsights},
        isLoading: {InsightContext.home: false},
      );

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      expect(find.text('Optimal Recovery'), findsOneWidget);

      // Tap on second carousel indicator
      await tester.tap(find.byKey(const ValueKey('carousel_dot_1')));
      await tester.pumpAndSettle();

      expect(find.text('Macro Balance'), findsOneWidget);
    });

    testWidgets('handles 1.5x text scale without overflow on small screens',
        (tester) async {
      final state = GlobalAIState(
        insights: {InsightContext.home: mockInsights},
        isLoading: {InsightContext.home: false},
      );

      // iPhone SE 1st gen size (320x568) with 1.5x font scale
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        createTestWidget(
          state: state,
          surfaceSize: const Size(320, 568),
          textScale: 1.5,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AiCoachHeroCard), findsOneWidget);
    });

    testWidgets('handles large tablet surface size cleanly',
        (tester) async {
      final state = GlobalAIState(
        insights: {InsightContext.home: mockInsights},
        isLoading: {InsightContext.home: false},
      );

      await tester.binding.setSurfaceSize(const Size(800, 1280));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        createTestWidget(
          state: state,
          surfaceSize: const Size(800, 1280),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AiCoachHeroCard), findsOneWidget);
    });

    testWidgets('uses non-glowing AppCard surface so it does not compete with weekly goal emphasis',
        (tester) async {
      final state = GlobalAIState(
        insights: {InsightContext.home: mockInsights},
        isLoading: {InsightContext.home: false},
      );

      await tester.pumpWidget(createTestWidget(state: state));
      await tester.pumpAndSettle();

      final appCardFinder = find.descendant(
        of: find.byType(AiCoachHeroCard),
        matching: find.byType(AppCard),
      );
      expect(appCardFinder, findsOneWidget);
      final appCard = tester.widget<AppCard>(appCardFinder);
      expect(appCard.isGlowing, isFalse);
    });
  });
}
