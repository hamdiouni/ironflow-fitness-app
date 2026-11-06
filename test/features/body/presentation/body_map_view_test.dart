import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/body/domain/entities/muscle_recovery_status.dart';
import 'package:progression_tracker/features/body/domain/entities/muscle_region.dart';
import 'package:progression_tracker/features/body/presentation/providers/body_map_providers.dart';
import 'package:progression_tracker/features/body/presentation/widgets/body_map/body_map_view.dart';
import 'package:progression_tracker/features/body/presentation/widgets/body_map/muscle_detail_sheet.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';

void main() {
  Widget createWidgetUnderTest({
    List<Workout> workouts = const [],
    Set<String> manualSoreness = const {},
    ValueChanged<MuscleRegion>? onMuscleSelected,
  }) {
    return ProviderScope(
      overrides: [
        workoutsStreamProvider.overrideWith((ref) => Stream.value(workouts)),
        manualSorenessProvider.overrideWith(() => _FakeManualSorenessNotifier(manualSoreness)),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        theme: ThemeData(
          brightness: Brightness.dark,
          extensions: [AppThemeTokens.dark],
        ),
        home: Scaffold(
          body: BodyMapView(
            onMuscleSelected: onMuscleSelected,
          ),
        ),
      ),
    );
  }

  group('BodyMapView Widget Tests', () {
    testWidgets('renders toolbar controls: FRONT/BACK toggle, mode toggle, and list toggle',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('FRONT'), findsOneWidget);
      expect(find.text('BACK'), findsOneWidget);
      expect(find.text('RECOVERY'), findsOneWidget);
      expect(find.text('HEATMAP'), findsOneWidget);
      expect(find.byIcon(Icons.format_list_bulleted_rounded), findsOneWidget);
    });

    testWidgets('can toggle between FRONT and BACK view perspectives',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();

      // View should remain stable and interactive
      expect(find.text('BACK'), findsOneWidget);
      expect(find.text('FRONT'), findsOneWidget);
    });

    testWidgets('can toggle between RECOVERY and HEATMAP modes',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('HEATMAP'));
      await tester.pumpAndSettle();

      expect(find.text('HEATMAP'), findsOneWidget);
    });

    testWidgets('can toggle to accessible semantic list alternative',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('body_map_list_mode_button')));
      await tester.pumpAndSettle();

      // Semantic list shows muscle names directly
      expect(find.text('Chest'), findsOneWidget);
      expect(find.text('Biceps'), findsOneWidget);
      expect(find.text('Pectoralis Major & Minor'), findsOneWidget);
    });

    testWidgets('tapping a muscle in semantic list opens MuscleDetailSheet with diagnostics',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      MuscleRegion? tappedRegion;
      await tester.pumpWidget(createWidgetUnderTest(
        onMuscleSelected: (r) => tappedRegion = r,
      ));
      await tester.pumpAndSettle();

      // Open list view
      await tester.tap(find.byKey(const Key('body_map_list_mode_button')));
      await tester.pumpAndSettle();

      // Tap Chest
      await tester.tap(find.text('Chest'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tappedRegion, MuscleRegion.chest);
      expect(find.byType(MuscleDetailSheet), findsOneWidget);
      expect(find.textContaining('TRAIN THIS MUSCLE'), findsOneWidget);
      expect(find.text('Mark as Sore (DOMS)'), findsOneWidget);
    });
  });
}

class _FakeManualSorenessNotifier extends ManualSorenessNotifier {
  final Set<String> initial;
  _FakeManualSorenessNotifier(this.initial);

  @override
  Set<String> build() => Set<String>.from(initial);

  @override
  Future<void> toggleSoreness(String regionId, bool isSore) async {
    final next = Set<String>.from(state);
    if (isSore) {
      next.add(regionId);
    } else {
      next.remove(regionId);
    }
    state = next;
  }
}
