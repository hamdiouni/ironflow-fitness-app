import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/shared/presentation/components/app_card.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/workout/domain/entities/active_program.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout_program.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/screens/workout_screen.dart';

import '../../../ai/integration/screen_integration_test.dart';

class FakeActiveProgramNotifier extends StateNotifier<AsyncValue<ActiveProgram?>>
    implements ActiveProgramNotifier {
  FakeActiveProgramNotifier(ActiveProgram? program)
      : super(AsyncValue.data(program));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget createWidgetUnderTest({
    ActiveProgram? activeProgram,
    List<Workout> history = const [],
    ThemeMode themeMode = ThemeMode.dark,
  }) {
    return ProviderScope(
      overrides: [
        globalAIProvider.overrideWith(
          (ref) => FakeGlobalAINotifier(const GlobalAIState()),
        ),
        activeProgramProvider.overrideWith(
          (ref) => FakeActiveProgramNotifier(activeProgram),
        ),
        workoutHistoryProvider.overrideWith(
          (ref) => Future.value(history),
        ),
      ],
      child: MaterialApp(
        themeMode: themeMode,
        theme: ThemeData.light().copyWith(
          extensions: [AppThemeTokens.light],
        ),
        darkTheme: ThemeData.dark().copyWith(
          extensions: [AppThemeTokens.dark],
        ),
        home: const WorkoutScreen(),
      ),
    );
  }

  group('WorkoutScreen Widget Tests (Monolithic Sci-Fi)', () {
    testWidgets('renders WORKOUT title and empty state when no program active', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(activeProgram: null));
      await tester.pumpAndSettle();

      expect(find.text('WORKOUT'), findsOneWidget);
      expect(find.text('NO ACTIVE PROGRAM'), findsOneWidget);
      expect(find.text('GENERATE PROGRAM'), findsOneWidget);
    });

    testWidgets('renders active program protocol, schedule, exercises and start session button', (tester) async {
      final program = WorkoutProgram(
        id: 'test-program-1',
        name: 'Hypertrophy Protocol Alpha',
        description: 'High volume monolithic protocol',
        difficulty: 'Intermediate',
        durationWeeks: 8,
        days: [
          ProgramDay(
            dayNumber: 1,
            name: 'Push Alpha',
            focus: 'Chest and Triceps',
            exercises: [
              ProgramExercise(
                exerciseName: 'Incline Dumbbell Press',
                sets: 4,
                reps: '8-10',
                restSeconds: 90,
              ),
              ProgramExercise(
                exerciseName: 'Overhead Cable Extension',
                sets: 3,
                reps: '12-15',
                restSeconds: 60,
              ),
            ],
            isRestDay: false,
          ),
          ProgramDay(
            dayNumber: 2,
            name: 'Rest Day',
            focus: 'Recovery and Mobility',
            exercises: const [],
            isRestDay: true,
          ),
        ],
      );

      final activeProgram = ActiveProgram(
        id: 'active-1',
        program: program,
        currentDayIndex: 0,
        isActive: true,
        lastWorkoutDate: null,
        completedDays: {},
      );

      await tester.pumpWidget(createWidgetUnderTest(activeProgram: activeProgram));
      await tester.pumpAndSettle();

      expect(find.text('WORKOUT'), findsOneWidget);
      expect(find.text('ACTIVE PROTOCOL'), findsOneWidget);
      expect(find.text('Hypertrophy Protocol Alpha'), findsOneWidget);
      expect(find.text('CYCLE SCHEDULE'), findsOneWidget);
      expect(find.text('DAY 1'), findsOneWidget);
      expect(find.text('PUSH ALPHA'), findsOneWidget);
      expect(find.text('Incline Dumbbell Press'), findsOneWidget);
      expect(find.text('▶ START SESSION'), findsOneWidget);
      expect(find.byType(AppCard), findsAtLeastNWidgets(3));
    });

    testWidgets('renders correctly in light mode with Architectural Titanium tokens', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        activeProgram: null,
        themeMode: ThemeMode.light,
      ));
      await tester.pumpAndSettle();

      expect(find.text('WORKOUT'), findsOneWidget);
      expect(find.text('NO ACTIVE PROGRAM'), findsOneWidget);
    });
  });
}
