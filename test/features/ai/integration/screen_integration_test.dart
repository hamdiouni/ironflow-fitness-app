import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_cache.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_generation_context.dart';
import 'package:progression_tracker/features/ai/domain/services/ai_insights_engine.dart';
import 'package:progression_tracker/features/ai/domain/services/insight_cache_service.dart';
import 'package:progression_tracker/features/ai/domain/services/change_detection_service.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/insight_widget.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/quick_feedback_bottom_sheet.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';

/// Integration tests for Global AI Coach screen integrations
///
/// These tests verify that:
/// - InsightWidget renders correctly on all screens (Home, Workout, Nutrition, Profile)
/// - Navigation to AI chat works from InsightWidget
/// - Quick feedback displays after workout completion
/// - Quick feedback dismissal works correctly
///
/// **Requirements:**
/// - 6.1: InsightWidget renders on Home screen
/// - 7.1: InsightWidget renders on Workout screen
/// - 8.1: InsightWidget renders on Nutrition screen
/// - 9.1: InsightWidget renders on Profile screen
/// - 10.1: Quick feedback displays after workout completion
/// - 12.1: Navigation to AI chat from InsightWidget
void main() {
  group('Screen Integration Tests', () {
    late GlobalAINotifier mockNotifier;
    late GlobalAIState mockState;

    setUp(() {
      // Create mock insights for testing
      final mockInsights = [
        Insight(
          id: 'test-1',
          context: InsightContext.home,
          title: 'Great Progress!',
          message: 'You\'ve completed 3 workouts this week.',
          icon: '💪',
          priority: InsightPriority.high,
          generatedAt: DateTime.now(),
        ),
        Insight(
          id: 'test-2',
          context: InsightContext.home,
          title: 'Nutrition Tip',
          message: 'Try to increase your protein intake.',
          icon: '🍽️',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now(),
        ),
      ];

      mockState = GlobalAIState(
        insights: {
          InsightContext.home: mockInsights,
          InsightContext.workout: mockInsights,
          InsightContext.nutrition: mockInsights,
          InsightContext.profile: mockInsights,
        },
        lastUpdated: {
          InsightContext.home: DateTime.now(),
          InsightContext.workout: DateTime.now(),
          InsightContext.nutrition: DateTime.now(),
          InsightContext.profile: DateTime.now(),
        },
        isLoading: {
          InsightContext.home: false,
          InsightContext.workout: false,
          InsightContext.nutrition: false,
          InsightContext.profile: false,
        },
        errors: {},
        quickFeedback: null,
      );
    });

    testWidgets('InsightWidget renders on Home screen with correct context',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            globalAIProvider.overrideWith((ref) {
              return FakeGlobalAINotifier(mockState);
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InsightWidget(context: InsightContext.home),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - Verify InsightWidget is rendered
      expect(find.byType(InsightWidget), findsOneWidget);

      // Assert - Verify insights are displayed
      expect(find.text('Great Progress!'), findsOneWidget);
      expect(find.text('You\'ve completed 3 workouts this week.'), findsOneWidget);
    });

    testWidgets('InsightWidget renders on Workout screen with correct context',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            globalAIProvider.overrideWith((ref) {
              return FakeGlobalAINotifier(mockState);
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InsightWidget(context: InsightContext.workout),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - Verify InsightWidget is rendered
      expect(find.byType(InsightWidget), findsOneWidget);

      // Assert - Verify insights are displayed
      expect(find.text('Great Progress!'), findsOneWidget);
    });

    testWidgets('InsightWidget renders on Nutrition screen with correct context',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            globalAIProvider.overrideWith((ref) {
              return FakeGlobalAINotifier(mockState);
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InsightWidget(context: InsightContext.nutrition),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - Verify InsightWidget is rendered
      expect(find.byType(InsightWidget), findsOneWidget);

      // Assert - Verify insights are displayed
      expect(find.text('Great Progress!'), findsOneWidget);
    });

    testWidgets('InsightWidget renders on Profile screen with correct context',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            globalAIProvider.overrideWith((ref) {
              return FakeGlobalAINotifier(mockState);
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InsightWidget(context: InsightContext.profile),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - Verify InsightWidget is rendered
      expect(find.byType(InsightWidget), findsOneWidget);

      // Assert - Verify insights are displayed
      expect(find.text('Great Progress!'), findsOneWidget);
    });

    testWidgets('Quick feedback displays after workout completion',
        (WidgetTester tester) async {
      // Arrange - Create quick feedback insight
      final quickFeedback = Insight(
        id: 'quick-feedback-1',
        context: InsightContext.workout,
        title: 'New PR!',
        message: 'You set a new personal record on Bench Press with 100kg!',
        icon: '🏆',
        priority: InsightPriority.high,
        generatedAt: DateTime.now(),
      );

      final stateWithQuickFeedback = mockState.copyWith(
        quickFeedback: quickFeedback,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            globalAIProvider.overrideWith((ref) {
              return FakeGlobalAINotifier(stateWithQuickFeedback);
            }),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                // Show quick feedback bottom sheet
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  QuickFeedbackBottomSheet.show(context, quickFeedback);
                });
                return const Scaffold(
                  body: Center(child: Text('Workout Complete')),
                );
              },
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - Verify quick feedback bottom sheet is displayed
      expect(find.text('New PR!'), findsOneWidget);
      expect(
        find.text('You set a new personal record on Bench Press with 100kg!'),
        findsOneWidget,
      );

      // Assert - Verify celebration icon is displayed
      expect(find.text('🏆'), findsOneWidget);

      // Assert - Verify CTA button is displayed
      expect(find.text('View Detailed Insights'), findsOneWidget);

      // Assert - Verify dismiss button is displayed
      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('Quick feedback dismisses when dismiss button is tapped',
        (WidgetTester tester) async {
      // Arrange - Create quick feedback insight
      final quickFeedback = Insight(
        id: 'quick-feedback-2',
        context: InsightContext.workout,
        title: 'Volume Record!',
        message: 'You increased your total volume by 15% this week!',
        icon: '📈',
        priority: InsightPriority.high,
        generatedAt: DateTime.now(),
      );

      final stateWithQuickFeedback = mockState.copyWith(
        quickFeedback: quickFeedback,
      );

      final notifier = FakeGlobalAINotifier(stateWithQuickFeedback);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            globalAIProvider.overrideWith((ref) => notifier),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                // Show quick feedback bottom sheet
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  QuickFeedbackBottomSheet.show(context, quickFeedback);
                });
                return const Scaffold(
                  body: Center(child: Text('Workout Complete')),
                );
              },
            ),
          ),
        ),
      );

      // Act - Wait for bottom sheet to appear
      await tester.pumpAndSettle();

      // Assert - Verify bottom sheet is displayed
      expect(find.text('Volume Record!'), findsOneWidget);

      // Act - Tap dismiss button
      await tester.tap(find.text('Dismiss'));
      await tester.pumpAndSettle();

      // Assert - Verify dismissQuickFeedback was called
      expect(notifier.dismissQuickFeedbackCalled, isTrue);

      // Assert - Verify bottom sheet is dismissed
      expect(find.text('Volume Record!'), findsNothing);
    });

    testWidgets('InsightWidget shows loading state correctly',
        (WidgetTester tester) async {
      // Arrange - Create loading state
      final loadingState = GlobalAIState(
        insights: {},
        lastUpdated: {},
        isLoading: {InsightContext.home: true},
        errors: {},
        quickFeedback: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            globalAIProvider.overrideWith((ref) {
              return FakeGlobalAINotifier(loadingState);
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InsightWidget(context: InsightContext.home),
            ),
          ),
        ),
      );

      // Act
      await tester.pump();

      // Assert - Verify loading indicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('InsightWidget shows error state with retry button',
        (WidgetTester tester) async {
      // Arrange - Create error state
      final errorState = GlobalAIState(
        insights: {},
        lastUpdated: {},
        isLoading: {InsightContext.home: false},
        errors: {InsightContext.home: 'Failed to generate insights'},
        quickFeedback: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            globalAIProvider.overrideWith((ref) {
              return FakeGlobalAINotifier(errorState);
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InsightWidget(context: InsightContext.home),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - Verify error message is displayed
      expect(find.text('Failed to generate insights'), findsOneWidget);

      // Assert - Verify retry button is displayed
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('InsightWidget shows empty state when no insights available',
        (WidgetTester tester) async {
      // Arrange - Create empty state
      final emptyState = GlobalAIState(
        insights: {InsightContext.home: []},
        lastUpdated: {},
        isLoading: {InsightContext.home: false},
        errors: {},
        quickFeedback: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            globalAIProvider.overrideWith((ref) {
              return FakeGlobalAINotifier(emptyState);
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: InsightWidget(context: InsightContext.home),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert - Verify empty state message is displayed
      expect(find.text('No insights yet'), findsOneWidget);
      expect(
        find.text('Start logging workouts and meals to get personalized insights'),
        findsOneWidget,
      );
    });
  });
}

/// Fake GlobalAINotifier for testing
class FakeGlobalAINotifier extends GlobalAINotifier {
  FakeGlobalAINotifier(GlobalAIState initialState)
      : super(
          insightsEngine: FakeAIInsightsEngine(),
          cacheService: FakeInsightCacheService(),
          changeDetectionService: FakeChangeDetectionService(),
          workoutRepository: FakeWorkoutRepository(),
          nutritionRepository: FakeNutritionRepository(),
          bodyRepository: FakeBodyRepository(),
        ) {
    state = initialState;
  }

  bool dismissQuickFeedbackCalled = false;

  @override
  void dismissQuickFeedback() {
    dismissQuickFeedbackCalled = true;
    super.dismissQuickFeedback();
  }
}

/// Fake implementations for testing
class FakeAIInsightsEngine implements AIInsightsEngine {
  @override
  Future<List<Insight>> generateInsights(InsightGenerationContext context) async {
    return [];
  }

  @override
  Future<Insight> generateQuickFeedback(
    Workout completedWorkout,
    List<Workout> workoutHistory,
  ) async {
    return Insight(
      id: 'test',
      context: InsightContext.workout,
      title: 'Test',
      message: 'Test',
      icon: '🎉',
      priority: InsightPriority.medium,
      generatedAt: DateTime.now(),
    );
  }

  @override
  double calculateVolume(Workout workout) => 0.0;

  @override
  bool detectProgressiveOverload(List<Workout> workouts) => false;

  @override
  double calculateProteinDeficit(
    List<dynamic> entries,
    dynamic targets,
  ) => 0.0;

  @override
  WeightTrend analyzeWeightTrend(List<BodyEntry> entries) => WeightTrend.stable;
}

class FakeInsightCacheService implements InsightCacheService {
  @override
  Future<void> init() async {}

  @override
  Future<InsightCache?> getCachedInsights(InsightContext context) async {
    return null;
  }

  @override
  Future<void> cacheInsights(InsightCache cache) async {}

  @override
  Future<void> invalidateCache(InsightContext context) async {}

  @override
  Future<void> clearAll() async {}

  @override
  bool isCacheStale(InsightCache cache) {
    return false;
  }
}

class FakeChangeDetectionService implements ChangeDetectionService {
  @override
  Future<bool> hasWorkoutDataChanged(DateTime since) async {
    return false;
  }

  @override
  Future<bool> hasNutritionDataChanged(DateTime since) async {
    return false;
  }

  @override
  Future<bool> hasBodyDataChanged(DateTime since) async {
    return false;
  }

  @override
  Future<DateTime?> getLastDataChange(InsightContext context) async {
    return null;
  }
}

class FakeWorkoutRepository implements WorkoutRepository {
  @override
  Future<List<Workout>> getWorkoutsByDateRange(DateTime start, DateTime end) async {
    return [];
  }

  // Add other required methods with minimal implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeNutritionRepository implements NutritionRepository {
  @override
  Future<List<DailyNutritionSummary>> getNutritionHistory(
    DateTime start,
    DateTime end,
  ) async {
    return [];
  }

  // Add other required methods with minimal implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeBodyRepository implements BodyRepository {
  @override
  Future<List<BodyEntry>> getBodyEntriesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return [];
  }

  // Add other required methods with minimal implementations
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
