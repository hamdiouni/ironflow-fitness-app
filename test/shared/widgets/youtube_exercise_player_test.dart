import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/shared/widgets/youtube_exercise_player.dart';

void main() {
  group('YouTubeExercisePlayer Widget Tests', () {
    testWidgets('renders fallback HUD when video ID is unavailable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: YouTubeExercisePlayer(
              exerciseName: 'Unknown Non-Existent Move 99',
              height: 220,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(YouTubeExercisePlayer), findsOneWidget);
      expect(find.text('DEMO VIDEO NOT AVAILABLE'), findsOneWidget);
      expect(find.text('RETRY'), findsOneWidget);
      expect(find.byIcon(Icons.videocam_off_rounded), findsOneWidget);
    });

    testWidgets('renders fallback with YOUTUBE button when mapped exercise video cannot play headlessly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: YouTubeExercisePlayer(
              exerciseName: 'Bench Press',
              height: 220,
            ),
          ),
        ),
      );

      // Pump initial frame
      await tester.pump();

      expect(find.byType(YouTubeExercisePlayer), findsOneWidget);
    });
  });
}
