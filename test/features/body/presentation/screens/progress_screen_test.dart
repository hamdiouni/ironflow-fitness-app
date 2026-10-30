import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/shared/presentation/components/app_card.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/entities/measurement_type.dart';
import 'package:progression_tracker/features/body/domain/entities/weight_data_point.dart';
import 'package:progression_tracker/features/body/presentation/providers/body_providers.dart';
import 'package:progression_tracker/features/body/presentation/screens/progress_screen.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';

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

  final List<Workout> mockWorkouts = [
    Workout(
      id: 'w-1',
      date: now,
      exercises: [],
      duration: const Duration(minutes: 50),
      totalVolume: 8500.0,
    ),
    Workout(
      id: 'w-2',
      date: now.subtract(const Duration(days: 1)),
      exercises: [],
      duration: const Duration(minutes: 45),
      totalVolume: 7200.0,
    ),
  ];

  Widget createWidgetUnderTest({
    List<WeightDataPoint>? weightPoints,
    List<BodyEntry>? bodyEntries,
    List<Workout>? workouts,
    String? initialTab,
    ThemeMode themeMode = ThemeMode.dark,
  }) {
    return ProviderScope(
      overrides: [
        globalAIProvider.overrideWith((ref) => FakeGlobalAINotifier(
              const GlobalAIState(),
            )),
        weightTrendProvider.overrideWith((ref) async => weightPoints ?? mockWeightPoints),
        bodyHistoryProvider.overrideWith((ref) async => bodyEntries ?? mockBodyEntries),
        workoutHistoryProvider.overrideWith((ref) async => workouts ?? mockWorkouts),
        userProfileProvider.overrideWith((ref) async => const UserProfile(
              goal: FitnessGoal.gainMuscle,
              age: 28,
              weightKg: 80.0,
              heightCm: 180.0,
              fitnessLevel: FitnessLevel.intermediate,
              equipment: EquipmentType.gym,
              workoutDaysPerWeek: 4,
              budget: BudgetLevel.medium,
            )),
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
        home: ProgressScreen(initialTab: initialTab),
      ),
    );
  }

  group('ProgressScreen Widget Tests (Monolithic Sci-Fi Segmented)', () {
    testWidgets('renders PROGRESS header and 3 segmented tabs: LIFTS & VOLUME, BODY WEIGHT, PHOTOS',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('PROGRESS'), findsOneWidget);
      expect(find.text('LIFTS & VOLUME'), findsOneWidget);
      expect(find.text('BODY WEIGHT'), findsOneWidget);
      expect(find.text('PHOTOS'), findsOneWidget);
    });

    testWidgets('Tab 0 (LIFTS & VOLUME) renders analytics telemetry cards',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Total Workouts'), findsOneWidget);
      expect(find.text('Current Streak'), findsOneWidget);
      expect(find.text('Weekly Consistency'), findsOneWidget);
      expect(find.text('Workout Frequency'), findsOneWidget);
      expect(find.text('Total Volume Over Time'), findsOneWidget);
    });

    testWidgets('can switch to BODY WEIGHT tab and render weight trend + telemetry',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('BODY WEIGHT'));
      await tester.pumpAndSettle();

      expect(find.text('WEIGHT TREND'), findsOneWidget);
      expect(find.text('RECENT LOGS'), findsOneWidget);
      expect(find.text('LOG WEIGHT'), findsOneWidget);
      expect(find.text('LATEST TELEMETRY'), findsOneWidget);
      expect(find.text('LOG MEASUREMENTS'), findsOneWidget);
    });

    testWidgets('initialTab "weight" deep-links directly to BODY WEIGHT tab',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest(initialTab: 'weight'));
      await tester.pumpAndSettle();

      expect(find.text('WEIGHT TREND'), findsOneWidget);
      expect(find.text('LOG WEIGHT'), findsOneWidget);
    });

    testWidgets('initialTab "photos" deep-links directly to PHOTOS tab',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest(initialTab: 'photos'));
      await tester.pumpAndSettle();

      expect(find.text('NO PROGRESS PHOTOS YET'), findsOneWidget);
    });

    testWidgets('BODY WEIGHT tab renders weight trend, recent logs, and telemetry on shared AppCard surfaces',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest(initialTab: 'weight'));
      await tester.pumpAndSettle();

      expect(find.byType(AppCard), findsAtLeastNWidgets(3));
    });
  });
}
