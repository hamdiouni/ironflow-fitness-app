import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/providers/connectivity_provider.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/body/domain/services/muscle_recovery_calculator.dart';
import 'package:progression_tracker/features/body/presentation/widgets/body_map/body_map_view.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:progression_tracker/features/workout/domain/entities/active_program.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_type.dart';
import 'package:progression_tracker/features/workout/domain/entities/set_entry.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/home_workout_provider.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/screens/active_workout_screen.dart';
import 'package:progression_tracker/features/workout/presentation/screens/home_screen.dart';
import 'package:progression_tracker/l10n/app_localizations.dart';
import 'package:progression_tracker/shared/widgets/exercise_media_stage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StubActiveProgramNotifier extends ActiveProgramNotifier {
  @override
  AsyncValue<ActiveProgram?> build() => const AsyncValue.data(null);
}

class _StubDailyNutritionNotifier
    extends FamilyNotifier<AsyncValue<DailyNutritionSummary>, String>
    implements DailyNutritionNotifier {
  @override
  AsyncValue<DailyNutritionSummary> build(String arg) => AsyncValue.data(
    DailyNutritionSummary(
      date: DateTime(2026, 6, 15),
      meals: const [],
      target: null,
    ),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubGlobalAINotifier extends Notifier<GlobalAIState>
    implements GlobalAINotifier {
  @override
  GlobalAIState build() => const GlobalAIState();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getInsights ||
        invocation.memberName == #refreshInsights) {
      return Future<List<Insight>>.value(const <Insight>[]);
    }
    return super.noSuchMethod(invocation);
  }
}

Widget _buildRtlTestHarness({
  required Widget child,
  double textScale = 1.0,
  Locale locale = const Locale('en'),
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, appChild) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(textScale),
            disableAnimations: true,
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: appChild ?? const SizedBox.shrink(),
          ),
        );
      },
      home: child,
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  final sampleWorkouts = <Workout>[
    Workout(
      id: 'w-rtl-1',
      date: DateTime(2026, 6, 14, 18, 0),
      duration: const Duration(minutes: 55),
      totalVolume: 2400,
      exercises: [
        Exercise(
          id: 'ex-rtl-1',
          name: 'Barbell Bench Press',
          type: ExerciseType.strength,
          sets: [
            SetEntry(
              id: 's-rtl-1',
              reps: 8,
              weight: 100,
              rpe: 8,
              timestamp: DateTime(2026, 6, 14, 18, 10),
            ),
          ],
        ),
      ],
    ),
  ];

  final baseOverrides = <Override>[
    workoutsStreamProvider.overrideWith((ref) => Stream.value(sampleWorkouts)),
    homeWorkoutDataProvider.overrideWith((ref) async => sampleWorkouts),
    activeProgramProvider.overrideWith(_StubActiveProgramNotifier.new),
    dailyNutritionSummaryProvider.overrideWith(_StubDailyNutritionNotifier.new),
    globalAIProvider.overrideWith(_StubGlobalAINotifier.new),
    isOnlineProvider.overrideWith((ref) => Stream.value(true)),
    userProfileProvider.overrideWith(
      (ref) async => const UserProfile(
        goal: FitnessGoal.gainMuscle,
        age: 28,
        weightKg: 80.0,
        heightCm: 180.0,
        fitnessLevel: FitnessLevel.intermediate,
        equipment: EquipmentType.gym,
        workoutDaysPerWeek: 4,
        budget: BudgetLevel.medium,
      ),
    ),
    currentUserIdProvider.overrideWithValue(null),
  ];

  group('Wave 6.4 — 7-Locale ARB String Coverage & Placeholder Parity', () {
    const supportedLocaleCodes = <String>[
      'en',
      'es',
      'fr',
      'de',
      'pt',
      'ja',
      'zh',
    ];

    test('all 7 ARB files have 100% key parity, non-empty values, and matching {placeholders}', () {
      final enFile = File('lib/l10n/app_en.arb');
      expect(enFile.existsSync(), isTrue);
      final enMap =
          jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
      final enKeys = enMap.keys.where((k) => !k.startsWith('@')).toSet();
      expect(enKeys.length, greaterThanOrEqualTo(122));

      final placeholderRegex = RegExp(r'\{([a-zA-Z0-9_]+)\}');

      for (final locale in supportedLocaleCodes) {
        final arbFile = File('lib/l10n/app_$locale.arb');
        expect(arbFile.existsSync(), isTrue, reason: 'Missing app_$locale.arb');
        final map =
            jsonDecode(arbFile.readAsStringSync()) as Map<String, dynamic>;
        final keys = map.keys.where((k) => !k.startsWith('@')).toSet();

        final missing = enKeys.difference(keys);
        final extra = keys.difference(enKeys);
        expect(
          missing,
          isEmpty,
          reason: 'Locale $locale missing keys: $missing',
        );
        expect(
          extra,
          isEmpty,
          reason: 'Locale $locale has extra keys: $extra',
        );

        for (final key in enKeys) {
          final enVal = enMap[key] as String;
          final locVal = (map[key] as String?) ?? '';
          expect(
            locVal.trim().isNotEmpty,
            isTrue,
            reason: 'Locale $locale has empty translation for key "$key"',
          );

          final enPlaceholders = placeholderRegex
              .allMatches(enVal)
              .map((m) => m.group(1)!)
              .toSet();
          final locPlaceholders = placeholderRegex
              .allMatches(locVal)
              .map((m) => m.group(1)!)
              .toSet();
          expect(
            locPlaceholders,
            equals(enPlaceholders),
            reason:
                'Locale $locale placeholder mismatch for key "$key": expected $enPlaceholders, got $locPlaceholders',
          );
        }
      }
    });

    testWidgets('AppLocalizations resolves all 7 supported locales without error', (tester) async {
      expect(AppLocalizations.supportedLocales.length, 7);

      for (final locale in AppLocalizations.supportedLocales) {
        late AppLocalizations resolvedL10n;
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) {
                resolvedL10n = AppLocalizations.of(context)!;
                return Scaffold(
                  body: Text(resolvedL10n.appTitle),
                );
              },
            ),
          ),
        );
        await tester.pump();

        expect(resolvedL10n.appTitle.isNotEmpty, isTrue);
        expect(resolvedL10n.navToday.isNotEmpty, isTrue);
        expect(resolvedL10n.workouts.isNotEmpty, isTrue);
        expect(resolvedL10n.nutrition.isNotEmpty, isTrue);
        expect(resolvedL10n.navProgress.isNotEmpty, isTrue);
        expect(resolvedL10n.settings.isNotEmpty, isTrue);
        expect(resolvedL10n.startWorkout.isNotEmpty, isTrue);
        expect(resolvedL10n.done.isNotEmpty, isTrue);
      }
    });
  });

  group('Wave 6.4 — Right-to-Left (TextDirection.rtl) Layout & 2.0x Text Scale', () {
    testWidgets('HomeScreen and ActiveWorkoutScreen render in RTL at 1.0x and 2.0x text scale without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final scale in <double>[1.0, 2.0]) {
        await tester.pumpWidget(
          _buildRtlTestHarness(
            textScale: scale,
            overrides: baseOverrides,
            child: const HomeScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 250));
        expect(
          tester.takeException(),
          isNull,
          reason: 'RTL HomeScreen failed at ${scale}x',
        );
        expect(
          Directionality.of(tester.element(find.byType(HomeScreen))),
          TextDirection.rtl,
        );

        await tester.pumpWidget(
          _buildRtlTestHarness(
            textScale: scale,
            overrides: baseOverrides,
            child: const ActiveWorkoutScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 250));
        expect(
          tester.takeException(),
          isNull,
          reason: 'RTL ActiveWorkoutScreen failed at ${scale}x',
        );
        expect(
          Directionality.of(tester.element(find.byType(ActiveWorkoutScreen))),
          TextDirection.rtl,
        );
      }
    });

    testWidgets('SettingsScreen renders in RTL at 1.0x and 2.0x text scale across locales without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final scale in <double>[1.0, 2.0]) {
        await tester.pumpWidget(
          _buildRtlTestHarness(
            textScale: scale,
            overrides: baseOverrides,
            child: const SettingsScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 250));
        expect(
          tester.takeException(),
          isNull,
          reason: 'RTL SettingsScreen failed at ${scale}x',
        );
        expect(
          Directionality.of(tester.element(find.byType(SettingsScreen))),
          TextDirection.rtl,
        );
      }
    });

    testWidgets('BodyMapView canvas and accessible list render in RTL at 1.0x and 2.0x text scale without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final scale in <double>[1.0, 2.0]) {
        await tester.pumpWidget(
          _buildRtlTestHarness(
            textScale: scale,
            overrides: baseOverrides,
            child: const Scaffold(
              body: SingleChildScrollView(
                child: BodyMapView(),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 250));
        expect(
          tester.takeException(),
          isNull,
          reason: 'RTL BodyMapView failed at ${scale}x',
        );
        expect(
          Directionality.of(tester.element(find.byType(BodyMapView))),
          TextDirection.rtl,
        );
      }
    });

    testWidgets('ExerciseMediaStage renders in RTL at 1.0x and 2.0x text scale without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final scale in <double>[1.0, 2.0]) {
        await tester.pumpWidget(
          _buildRtlTestHarness(
            textScale: scale,
            overrides: baseOverrides,
            child: const Scaffold(
              body: ExerciseMediaStage(
                exerciseName: 'Barbell Bench Press',
                instructionsOverride: <String>[
                  'Retract shoulder blades and plant feet firmly.',
                  'Lower the bar under control to mid-chest.',
                  'Press explosively back to full lockout.',
                ],
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(
          tester.takeException(),
          isNull,
          reason: 'RTL ExerciseMediaStage failed at ${scale}x',
        );
      }
    });
  });

  group('Wave 6.4 — Domain & Media Resilience', () {
    test('MuscleRecoveryCalculator handles extreme RPE, long duration, and zero/negative sets without NaN', () {
      final now = DateTime(2026, 6, 15, 12, 0);
      final extremeWorkout = Workout(
        id: 'extreme-w',
        date: now.subtract(const Duration(hours: 6)),
        duration: const Duration(hours: 5),
        totalVolume: 1000,
        exercises: [
          Exercise(
            id: 'ex-extreme',
            name: 'Barbell Bench Press',
            type: ExerciseType.strength,
            sets: [
              SetEntry(
                id: 's1',
                reps: 0,
                weight: -50,
                rpe: 99,
                timestamp: now.subtract(const Duration(hours: 6)),
              ),
              SetEntry(
                id: 's2',
                reps: 10,
                weight: 100,
                rpe: -5,
                timestamp: now.subtract(const Duration(hours: 6)),
              ),
            ],
          ),
        ],
      );

      const calculator = MuscleRecoveryCalculator();
      final states = calculator.calculate(
        workouts: [extremeWorkout],
        referenceNow: now,
      );

      expect(states.length, 20);
      for (final state in states.values) {
        expect(state.score.isNaN, isFalse);
        expect(state.score.isInfinite, isFalse);
        expect(state.score, inInclusiveRange(0.0, 1.0));
      }
    });

    testWidgets('ExerciseMediaStage degrades gracefully in RTL for unknown exercise with empty steps', (tester) async {
      await tester.pumpWidget(
        _buildRtlTestHarness(
          child: const Scaffold(
            body: ExerciseMediaStage(
              exerciseName: 'NonExistent_Unmapped_Exercise_XYZ',
              instructionsOverride: <String>[],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
      expect(find.byType(ExerciseMediaStage), findsOneWidget);
    });
  });
}
