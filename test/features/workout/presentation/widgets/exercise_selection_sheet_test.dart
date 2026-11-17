import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/workout/domain/services/exercise_catalog.dart';
import 'package:progression_tracker/features/workout/presentation/widgets/active_workout/exercise_selection_sheet.dart';

void main() {
  Widget wrapSheet({required void Function(String) onSelected}) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(extensions: [AppThemeTokens.dark]),
      home: Scaffold(
        body: SizedBox(
          height: 600,
          child: ExerciseSelectionSheet(
            scrollController: ScrollController(),
            onExerciseSelected: onSelected,
          ),
        ),
      ),
    );
  }

  group('ExerciseSelectionSheet Full Catalog Tests', () {
    testWidgets('displays dynamic count for all 129 exercises and searches across them',
        (tester) async {
      String? picked;
      await tester.pumpWidget(wrapSheet(onSelected: (name) => picked = name));
      await tester.pumpAndSettle();

      expect(
        find.text(
          '${ExerciseCatalog.all.length} OF ${ExerciseCatalog.all.length} EXERCISES',
        ),
        findsOneWidget,
      );

      // Search for an exercise beyond the old 45-item hardcoded subset.
      await tester.enterText(find.byType(TextField), 'Bulgarian Split Squat');
      await tester.pumpAndSettle();

      final resultFinder = find.descendant(
        of: find.byType(ListTile),
        matching: find.text('Bulgarian Split Squat'),
      );
      expect(resultFinder, findsOneWidget);
      await tester.tap(resultFinder);
      await tester.pump();
      expect(picked, 'Bulgarian Split Squat');
    });

    testWidgets('filters exercises by muscle group search', (tester) async {
      await tester.pumpWidget(wrapSheet(onSelected: (_) {}));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Barbell Row');
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Barbell Row'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.text('Bench Press'),
        ),
        findsNothing,
      );
    });
  });
}
