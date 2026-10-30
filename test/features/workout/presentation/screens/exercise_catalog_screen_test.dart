import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_definition.dart';
import 'package:progression_tracker/features/workout/presentation/screens/exercise_catalog_screen.dart';
import 'package:progression_tracker/shared/presentation/components/app_card.dart';

void main() {
  Widget buildSubject({
    void Function(ExerciseDefinition)? onSelect,
    ThemeMode themeMode = ThemeMode.dark,
  }) {
    return ProviderScope(
      child: MaterialApp(
        themeMode: themeMode,
        theme: ThemeData.light().copyWith(
          extensions: [AppThemeTokens.light],
        ),
        darkTheme: ThemeData.dark().copyWith(
          extensions: [AppThemeTokens.dark],
        ),
        home: ExerciseCatalogScreen(onSelect: onSelect),
      ),
    );
  }

  group('ExerciseCatalogScreen Widget Tests (Wave 2 AppCard Migration)', () {
    testWidgets('renders EXERCISE CATALOG header, muscle group tabs, and AppCard grid tiles',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('EXERCISE CATALOG'), findsOneWidget);
      expect(find.text('ALL'), findsWidgets);
      expect(find.text('CHEST'), findsWidgets);
      expect(find.text('BACK'), findsWidgets);
      expect(find.text('LEGS'), findsWidgets);

      // Grid tiles must use shared AppCard surface
      expect(find.byType(AppCard), findsWidgets);
    });

    testWidgets('filters exercises by search query and invokes onSelect when tile is tapped',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      ExerciseDefinition? selected;
      await tester.pumpWidget(
        buildSubject(onSelect: (exercise) => selected = exercise),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Bench Press');
      await tester.pumpAndSettle();

      expect(find.byType(AppCard), findsWidgets);
      await tester.tap(find.byType(AppCard).first);
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.name.toLowerCase(), contains('bench press'));
    });
  });
}

