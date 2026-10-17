import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/entities/measurement_type.dart';
import 'package:progression_tracker/features/body/domain/entities/weight_data_point.dart';
import 'package:progression_tracker/features/body/presentation/providers/body_providers.dart';
import 'package:progression_tracker/features/body/presentation/screens/progress_screen.dart';

import '../../../ai/integration/screen_integration_test.dart';

void main() {
  final now = DateTime.now();

  final List<WeightDataPoint> mockWeightPoints = [
    WeightDataPoint(date: now.subtract(const Duration(days: 10)), weight: 80.0),
    WeightDataPoint(date: now.subtract(const Duration(days: 5)), weight: 79.5),
    WeightDataPoint(date: now, weight: 79.0),
  ];

  final List<BodyEntry> mockBodyEntries = [
    BodyEntry(
      id: 'entry-1',
      date: now,
      weight: 79.0,
      measurements: {
        MeasurementType.waist: 82.0,
        MeasurementType.chest: 104.0,
        MeasurementType.arms: 38.0,
      },
    ),
    BodyEntry(
      id: 'entry-2',
      date: now.subtract(const Duration(days: 5)),
      weight: 79.5,
      measurements: {
        MeasurementType.waist: 82.5,
        MeasurementType.chest: 103.5,
      },
    ),
  ];

  Widget createWidgetUnderTest({
    List<WeightDataPoint>? weightPoints,
    List<BodyEntry>? bodyEntries,
    ThemeMode themeMode = ThemeMode.dark,
  }) {
    return ProviderScope(
      overrides: [
        globalAIProvider.overrideWith((ref) => FakeGlobalAINotifier(
              const GlobalAIState(),
            )),
        weightTrendProvider.overrideWith((ref) async => weightPoints ?? mockWeightPoints),
        bodyHistoryProvider.overrideWith((ref) async => bodyEntries ?? mockBodyEntries),
      ],
      child: MaterialApp(
        themeMode: themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          extensions: [AppThemeTokens.light],
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          extensions: [AppThemeTokens.dark],
        ),
        home: const ProgressScreen(),
      ),
    );
  }

  group('ProgressScreen Widget Tests (Monolithic Sci-Fi)', () {
    testWidgets('renders PROGRESS header, tabs, and weight trend telemetry',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('PROGRESS'), findsOneWidget);
      expect(find.text('BIOMETRIC TELEMETRY'), findsOneWidget);
      expect(find.text('WEIGHT'), findsOneWidget);
      expect(find.text('MEASUREMENTS'), findsOneWidget);
      expect(find.text('PHOTOS'), findsOneWidget);
      expect(find.text('WEIGHT TREND'), findsOneWidget);
      expect(find.text('RECENT LOGS'), findsOneWidget);
      expect(find.text('LOG WEIGHT'), findsOneWidget);
    });

    testWidgets('can switch to MEASUREMENTS tab and render telemetry table',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('MEASUREMENTS'));
      await tester.pumpAndSettle();

      expect(find.text('LATEST TELEMETRY'), findsOneWidget);
      expect(find.text('LOG MEASUREMENTS'), findsOneWidget);
    });
  });
}
