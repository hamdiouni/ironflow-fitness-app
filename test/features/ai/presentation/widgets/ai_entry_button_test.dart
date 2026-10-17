import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/ai_entry_button.dart';
import 'package:progression_tracker/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:progression_tracker/features/workout/presentation/screens/home_screen.dart';
import 'package:progression_tracker/features/workout/presentation/screens/program_editor_screen.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/home_workout_provider.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import '../../integration/screen_integration_test.dart';

import 'package:progression_tracker/features/workout/domain/entities/active_program.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/nutrition_providers.dart';

class _FakeDailyNutritionNotifier
    extends StateNotifier<AsyncValue<DailyNutritionSummary>>
    implements DailyNutritionNotifier {
  _FakeDailyNutritionNotifier()
      : super(AsyncValue.data(
          DailyNutritionSummary(
            date: DateTime(2026, 1, 1),
            meals: const [],
            target: null,
          ),
        ));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeActiveProgramNotifier
    extends StateNotifier<AsyncValue<ActiveProgram?>>
    implements ActiveProgramNotifier {
  _FakeActiveProgramNotifier() : super(const AsyncValue.data(null));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AiEntryButton Tests', () {
    testWidgets('has at least 48x48dp minimum tap target and correct semantics',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(56),
                child: Row(
                  children: [AiEntryButton()],
                ),
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(AiEntryButton);
      expect(buttonFinder, findsOneWidget);

      final size = tester.getSize(buttonFinder);
      expect(size.width, greaterThanOrEqualTo(48.0));
      expect(size.height, greaterThanOrEqualTo(48.0));

      expect(find.byTooltip('AI Fitness Coach'), findsOneWidget);
      expect(find.bySemanticsLabel('AI Fitness Coach'), findsOneWidget);
    });

    testWidgets('calls custom callback on tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Row(
                  children: [
                    AiEntryButton(onPressed: () => tapped = true),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AiEntryButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('AiEntryButton is present on HomeScreen header',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeWorkoutDataProvider.overrideWith((ref) async => []),
            userProfileProvider.overrideWith((ref) async => null),
            globalAIProvider.overrideWith(
              (ref) => FakeGlobalAINotifier(const GlobalAIState()),
            ),
            activeProgramProvider.overrideWith(
              (ref) => _FakeActiveProgramNotifier(),
            ),
            dailyNutritionSummaryProvider.overrideWith(
              (ref, date) => _FakeDailyNutritionNotifier(),
            ),
          ],
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AiEntryButton), findsOneWidget);
    });

    testWidgets('AiEntryButton is present on AnalyticsScreen header',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutHistoryProvider.overrideWith((ref) async => []),
            userProfileProvider.overrideWith((ref) async => null),
          ],
          child: const MaterialApp(
            home: AnalyticsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AiEntryButton), findsOneWidget);
    });

    testWidgets('AiEntryButton is NOT present on ProgramEditorScreen',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeProgramProvider.overrideWith((ref) => _FakeActiveProgramNotifier()),
          ],
          child: const MaterialApp(
            home: ProgramEditorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AiEntryButton), findsNothing);
    });
  });
}

