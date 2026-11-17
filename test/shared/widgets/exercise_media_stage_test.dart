import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/shared/widgets/exercise_media_stage.dart';

void main() {
  Widget wrap(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? AppTheme.darkTheme,
      home: Scaffold(body: child),
    );
  }

  group('ExerciseMediaStage Unified Media & Steps Fallback Tests (Wave 5.3)', () {
    testWidgets(
      'mapped exercise with Coach 1 and Coach 2 renders mode tabs and defers iframe until tap',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const ExerciseMediaStage(
              exerciseName: 'Deadlift',
              height: 220,
            ),
          ),
        );
        await tester.pump();

        // Coach 1, Coach 2, and Steps tabs are present (no fake 3D Form tab)
        expect(find.byKey(const Key('media_stage_mode_form3d')), findsNothing);
        expect(find.byKey(const Key('media_stage_mode_coach1')), findsOneWidget);
        expect(find.byKey(const Key('media_stage_mode_coach2')), findsOneWidget);
        expect(find.byKey(const Key('media_stage_mode_steps')), findsOneWidget);

        // Tap-to-load poster button is displayed without eager iframe crash
        expect(
          find.byKey(const Key('youtube_tap_to_load_button')),
          findsOneWidget,
        );

        // Switch to Coach 2 tab
        await tester.tap(find.byKey(const Key('media_stage_mode_coach2')));
        await tester.pump();
        expect(
          find.byKey(const Key('youtube_tap_to_load_button')),
          findsOneWidget,
        );

        // Switch to Steps tab
        await tester.tap(find.byKey(const Key('media_stage_mode_steps')));
        await tester.pump();
        expect(
          find.byKey(const Key('exercise_media_steps_view')),
          findsOneWidget,
        );
        expect(find.text('EXECUTION STEPS'), findsOneWidget);
      },
    );

    testWidgets(
      'unmapped exercise falls back directly to step-by-step instructions in light mode',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            const ExerciseMediaStage(
              exerciseName: 'Plank',
              height: 220,
            ),
            theme: AppTheme.lightTheme,
          ),
        );
        await tester.pump();

        expect(find.byKey(const Key('media_stage_mode_coach1')), findsNothing);
        expect(find.byKey(const Key('media_stage_mode_steps')), findsOneWidget);
        expect(
          find.byKey(const Key('exercise_media_steps_view')),
          findsOneWidget,
        );
        expect(
          find.text('EXECUTION STEPS (NO VIDEO MAPPED)'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '3D Form mode appears when loop URL is supplied and falls back to steps on asset error',
      (tester) async {
        expect(
          ExerciseMediaLoopSpec.canonicalLoopFileName('Chest_001'),
          equals('chest_001_loop.mp4'),
        );
        expect(
          ExerciseMediaLoopSpec.canonicalPosterFileName('Chest_001'),
          equals('chest_001_poster.webp'),
        );

        await tester.pumpWidget(
          wrap(
            const ExerciseMediaStage(
              exerciseName: 'Bench Press',
              formLoopUrlOverride: 'assets/media/loops/missing_loop.mp4',
              height: 220,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Missing loop asset gracefully falls back to Steps view without crashing
        expect(
          find.byKey(const Key('exercise_media_steps_view')),
          findsOneWidget,
        );
      },
    );
  });
}
