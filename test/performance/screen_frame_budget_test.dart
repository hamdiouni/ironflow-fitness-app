import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/body/presentation/providers/body_map_providers.dart';
import 'package:progression_tracker/features/body/presentation/screens/progress_screen.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/screens/workout_summary_screen.dart';

void main() {
  final now = DateTime(2026, 11, 7, 12, 0);

  final sampleWorkout = Workout(
    id: 'perf-workout-1',
    date: now,
    duration: const Duration(minutes: 50),
    totalVolume: 5200.0,
    exercises: [
      Exercise(
        id: 'ex-bench',
        name: 'Barbell Bench Press',
        type: ExerciseType.strength,
        exerciseDefinitionId: 'chest_001',
        sets: [
          SetEntry.create(reps: 10, weight: 80.0, type: SetType.normal),
          SetEntry.create(reps: 8, weight: 85.0, type: SetType.normal),
        ],
      ),
    ],
  );

  Widget wrapWithTheme(Widget child) {
    return ProviderScope(
      overrides: [
        workoutsStreamProvider.overrideWith((ref) => Stream.value([sampleWorkout])),
        manualSorenessProvider.overrideWith(() => _FakeSorenessNotifier()),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
          extensions: [AppThemeTokens.dark],
        ),
        home: MediaQuery(
          data: const MediaQueryData(size: Size(390, 844)),
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  group('Wave 5.1 Screen Frame Budgets & Render Benchmarks', () {
    testWidgets('1. ProgressScreen (Body Map tab) frame budget verification',
        (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(const ProgressScreen(initialTab: 'bodymap')),
      );

      // Measure single-frame paint & build budget
      // Note: On unoptimized debug VM test runners under multi-core load, initial frame
      // can vary (40-150ms). Real target in release/profile is <16ms; budget for debug test is <250ms.
      final frameStopwatch = Stopwatch()..start();
      await tester.pump();
      frameStopwatch.stop();

      final elapsedMs = frameStopwatch.elapsedMilliseconds;
      expect(elapsedMs, lessThan(250),
          reason: 'Single frame render took ${elapsedMs}ms (budget: <250ms in debug test)');
      expect(find.byType(ProgressScreen), findsOneWidget);
    });

    testWidgets('2. WorkoutSummaryScreen frame budget verification with zero overflow',
        (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          WorkoutSummaryScreen(
            workoutId: sampleWorkout.id,
            exercises: sampleWorkout.exercises,
            duration: sampleWorkout.duration,
            totalSets: 2,
            totalVolume: sampleWorkout.totalVolume,
          ),
        ),
      );

      final frameStopwatch = Stopwatch()..start();
      await tester.pump();
      frameStopwatch.stop();

      final elapsedMs = frameStopwatch.elapsedMilliseconds;
      expect(elapsedMs, lessThan(250),
          reason: 'WorkoutSummaryScreen frame render took ${elapsedMs}ms (budget: <250ms in debug test)');
      expect(find.byType(WorkoutSummaryScreen), findsOneWidget);
    });
  });
}

class _FakeSorenessNotifier extends ManualSorenessNotifier {
  @override
  Set<String> build() => const {};
}
