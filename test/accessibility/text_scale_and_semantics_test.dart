import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/body/domain/entities/muscle_region.dart';
import 'package:progression_tracker/features/body/presentation/providers/body_map_providers.dart';
import 'package:progression_tracker/features/body/presentation/widgets/body_map/body_map_view.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';

class _FakeSelectedMuscleRegionNotifier extends SelectedMuscleRegionNotifier {
  _FakeSelectedMuscleRegionNotifier(this._initial);
  final MuscleRegion? _initial;
  @override
  MuscleRegion? build() => _initial;
}

class _FakeManualSorenessNotifier extends ManualSorenessNotifier {
  _FakeManualSorenessNotifier(this._initial);
  final Set<String> _initial;
  @override
  Set<String> build() => _initial;
}

void main() {
  Widget buildTestableWidget({
    required Widget child,
    bool disableAnimations = false,
    double textScaleFactor = 1.0,
    MuscleRegion? selectedRegion,
    Set<String> manualSoreness = const {},
    List<Workout> workouts = const [],
  }) {
    return ProviderScope(
      overrides: [
        workoutsStreamProvider.overrideWith((ref) => Stream.value(workouts)),
        manualSorenessProvider.overrideWith(() => _FakeManualSorenessNotifier(manualSoreness)),
        selectedMuscleRegionProvider.overrideWith(() => _FakeSelectedMuscleRegionNotifier(selectedRegion)),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
          extensions: [AppThemeTokens.dark],
        ),
        home: MediaQuery(
          data: MediaQueryData(
            disableAnimations: disableAnimations,
            textScaler: TextScaler.linear(textScaleFactor),
            size: const Size(400, 800),
          ),
          child: Scaffold(body: child),
        ),
      ),
    );
  }

  group('Wave 5.4 Accessibility (a11y) Verification Suite', () {
    testWidgets('1. Reduced Motion: BodyMapView honors disableAnimations',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          disableAnimations: true,
          selectedRegion: MuscleRegion.chest,
          child: const BodyMapView(),
        ),
      );
      await tester.pumpAndSettle();

      // In reduced motion mode, the pulse animation does not continuously loop
      // pumpAndSettle settles immediately without pending timer frames
      expect(find.byType(BodyMapView), findsOneWidget);
    });

    testWidgets('2. Accessible List View: provides explicit semantic labels',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        buildTestableWidget(
          child: const BodyMapView(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to accessible list mode
      final listButton = find.byKey(const Key('body_map_list_mode_button'));
      expect(listButton, findsOneWidget);
      await tester.tap(listButton);
      await tester.pumpAndSettle();

      // Verify semantics node for Chest
      expect(
        find.bySemanticsLabel(RegExp(r'Chest.*FRESH recovery.*100 percent')),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('3. 2.0x Text Scale Factor: BodyMapView scales without RenderFlex overflow',
        (tester) async {
      // Pump with large text scaling (2.0x for low vision users)
      await tester.pumpWidget(
        buildTestableWidget(
          textScaleFactor: 2.0,
          child: const SingleChildScrollView(child: BodyMapView()),
        ),
      );
      await tester.pumpAndSettle();

      // Zero exceptions thrown during layout pass
      expect(tester.takeException(), isNull);
      expect(find.byType(BodyMapView), findsOneWidget);
    });

    testWidgets('4. Semantic Roles: Segment buttons declare button and selected state',
        (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        buildTestableWidget(
          child: const BodyMapView(),
        ),
      );
      await tester.pumpAndSettle();

      // Front button should have selected=true semantics
      expect(
        tester.getSemantics(find.text('FRONT')),
        matchesSemantics(
          label: 'FRONT',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );

      // Back button should have selected=false semantics
      expect(
        tester.getSemantics(find.text('BACK')),
        matchesSemantics(
          label: 'BACK',
          isButton: true,
          isSelected: false,
          hasSelectedState: true,
          hasEnabledState: true,
          isEnabled: true,
        ),
      );

      handle.dispose();
    });
  });
}
