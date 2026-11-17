import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/providers/connectivity_provider.dart';
import 'package:progression_tracker/core/providers/theme_provider.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/entities/measurement_type.dart';
import 'package:progression_tracker/features/body/domain/entities/weight_data_point.dart';
import 'package:progression_tracker/features/body/presentation/providers/body_providers.dart';
import 'package:progression_tracker/features/body/presentation/screens/progress_screen.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/diet_plan_providers.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:progression_tracker/features/nutrition/presentation/screens/nutrition_screen.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/domain/usecases/usecases.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/home_workout_provider.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/screens/active_workout_screen.dart';
import 'package:progression_tracker/features/workout/presentation/screens/home_screen.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/ai/integration/screen_integration_test.dart';

const bool _capturePngs = bool.fromEnvironment('CAPTURE_WAVE4');

class _FakeActiveProgramNotifier extends Notifier<AsyncValue<ActiveProgram?>>
    implements ActiveProgramNotifier {
  _FakeActiveProgramNotifier(this._program);
  final ActiveProgram? _program;
  @override
  AsyncValue<ActiveProgram?> build() => AsyncValue.data(_program);
  @override
  Future<void> completeCurrentDay() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDailyNutritionNotifier
    extends FamilyNotifier<AsyncValue<DailyNutritionSummary>, String>
    implements DailyNutritionNotifier {
  _FakeDailyNutritionNotifier(this._summary);
  final DailyNutritionSummary _summary;
  @override
  AsyncValue<DailyNutritionSummary> build(String arg) =>
      AsyncValue.data(_summary);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWorkoutNotifier extends Notifier<WorkoutState>
    implements WorkoutNotifier {
  _FakeWorkoutNotifier(this._state);
  final WorkoutState _state;
  @override
  WorkoutState build() => _state;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetProgressionSuggestion
    implements GetProgressionSuggestionUseCase {
  @override
  Future<ProgressionSuggestion?> call(String exerciseName) async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => AuthState(
        isAuthenticated: true,
        user: User(
          id: 'user-1',
          email: 'athlete@example.com',
          displayName: 'Alex Athlete',
          photoUrl: null,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );
}

class _FakeThemeNotifier extends ThemeNotifier {
  _FakeThemeNotifier(this.mode);
  final ThemeMode mode;
  @override
  ThemeMode build() => mode;
}

class _FakeHapticsNotifier extends HapticsNotifier {
  @override
  bool build() => true;
}

Future<void> _loadBundledFonts() async {
  const fonts = {
    'Inter': 'assets/fonts/Inter.ttf',
    'SpaceGrotesk': 'assets/fonts/SpaceGrotesk.ttf',
  };
  for (final entry in fonts.entries) {
    final file = File(entry.value);
    if (!file.existsSync()) continue;
    final bytes = file.readAsBytesSync();
    final loader = FontLoader(entry.key)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  final iconCandidates = [
    if (flutterRoot != null && flutterRoot.isNotEmpty)
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    'C:/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    '/opt/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ];
  for (final path in iconCandidates) {
    final iconFile = File(path);
    if (iconFile.existsSync()) {
      final bytes = iconFile.readAsBytesSync();
      final loader = FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.view(bytes.buffer)));
      await loader.load();
      break;
    }
  }
}

Future<void> _writePng(
  WidgetTester tester,
  GlobalKey key,
  List<String> paths,
) async {
  if (!_capturePngs) return;
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1.0);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  });
  for (final path in paths) {
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes!);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadBundledFonts();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => Directory.systemTemp.path,
    );
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final now = DateTime(2026, 11, 17, 10, 0);

  final activeProgram = ActiveProgram(
    id: 'active-1',
    program: const WorkoutProgram(
      id: 'prog-1',
      name: 'Upper / Lower (4 Days)',
      description: 'Strength and hypertrophy split',
      difficulty: 'Intermediate',
      durationWeeks: 8,
      days: [
        ProgramDay(
          dayNumber: 1,
          name: 'Upper Body — Power',
          focus: 'Chest & Back',
          exercises: [
            ProgramExercise(
              exerciseName: 'Bench Press',
              sets: 4,
              reps: '6-8',
              restSeconds: 120,
            ),
            ProgramExercise(
              exerciseName: 'Barbell Row',
              sets: 4,
              reps: '6-8',
              restSeconds: 90,
            ),
          ],
          isRestDay: false,
        ),
      ],
    ),
    currentDayIndex: 0,
    isActive: true,
    lastWorkoutDate: null,
    completedDays: const {},
  );

  final workouts = [
    for (var i = 0; i < 4; i++)
      Workout(
        id: 'w-$i',
        date: now.subtract(Duration(days: i * 2)),
        exercises: [
          Exercise(
            id: 'ex-$i',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [
              SetEntry(
                id: 's-$i',
                reps: 8,
                weight: 80,
                timestamp: now,
              ),
            ],
          ),
        ],
        duration: const Duration(minutes: 48),
        totalVolume: 6400 + i * 400,
      ),
  ];

  const profile = UserProfile(
    goal: FitnessGoal.gainMuscle,
    age: 28,
    weightKg: 80,
    heightCm: 180,
    fitnessLevel: FitnessLevel.intermediate,
    equipment: EquipmentType.gym,
    workoutDaysPerWeek: 4,
    budget: BudgetLevel.medium,
  );

  final nutritionSummary = DailyNutritionSummary(
    date: DateTime(now.year, now.month, now.day),
    meals: [
      Meal(
        id: 'meal-1',
        name: 'Greek Yogurt & Whey Bowl',
        macros: const MealMacros(
          calories: 540,
          protein: 52,
          carbs: 48,
          fats: 14,
        ),
        micros: const MealMicros(fiber: 4, sugar: 12, sodium: 180, potassium: 420),
        vitamins: const MealVitamins(
          vitaminA: 120,
          vitaminB: 0.8,
          vitaminC: 5,
          vitaminD: 2,
          vitaminE: 1,
        ),
        minerals: const MealMinerals(
          calcium: 300,
          iron: 2,
          magnesium: 60,
          zinc: 2,
        ),
        timestamp: now,
      ),
      Meal(
        id: 'meal-2',
        name: 'Chicken Breast, Rice & Avocado',
        macros: const MealMacros(
          calories: 790,
          protein: 58,
          carbs: 86,
          fats: 22,
        ),
        micros: const MealMicros(fiber: 8, sugar: 4, sodium: 420, potassium: 680),
        vitamins: const MealVitamins(
          vitaminA: 80,
          vitaminB: 1.2,
          vitaminC: 10,
          vitaminD: 0,
          vitaminE: 2,
        ),
        minerals: const MealMinerals(
          calcium: 40,
          iron: 3,
          magnesium: 75,
          zinc: 2.5,
        ),
        timestamp: now,
      ),
    ],
    target: NutritionTargets(
      userId: 'user-1',
      macros: const MacroTargets(
        calories: 2750,
        protein: 185,
        carbs: 310,
        fats: 80,
      ),
      micros: const MicroTargets(
        fiber: 30,
        sugar: 50,
        sodium: 2300,
        potassium: 3500,
      ),
      vitamins: const VitaminTargets(
        vitaminA: 900,
        vitaminB: 2.4,
        vitaminC: 90,
        vitaminD: 20,
        vitaminE: 15,
      ),
      minerals: const MineralTargets(
        calcium: 1000,
        iron: 18,
        magnesium: 400,
        zinc: 11,
      ),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  );

  final activeWorkout = Workout(
    id: 'active-w-1',
    date: now,
    exercises: [
      Exercise(
        id: 'ex-bench',
        name: 'Bench Press',
        type: ExerciseType.strength,
        sets: [SetEntry(id: 's-bench-1', reps: 8, weight: 80, timestamp: now)],
        suggestedSets: 4,
        suggestedReps: 8,
      ),
      Exercise(
        id: 'ex-row',
        name: 'Barbell Row',
        type: ExerciseType.strength,
        sets: [SetEntry(id: 's-row-1', reps: 8, weight: 75, timestamp: now)],
        suggestedSets: 4,
        suggestedReps: 8,
      ),
    ],
    duration: const Duration(minutes: 24),
    totalVolume: 1240,
  );

  List<Override> commonOverrides({required bool isDark}) => [
        globalAIProvider.overrideWith(
          () => FakeGlobalAINotifier(
            GlobalAIState(
              insights: {
                InsightContext.home: [
                  Insight(
                    id: 'ins-1',
                    context: InsightContext.home,
                    title: 'You\'re Progressing!',
                    message:
                        'You\'ve trained 4 times this week. workouts_this_week: 4.',
                    icon: '🚀',
                    priority: InsightPriority.high,
                    generatedAt: now,
                  ),
                ],
              },
              isLoading: const {InsightContext.home: false},
            ),
          ),
        ),
        isOnlineProvider.overrideWith((ref) => Stream.value(true)),
        homeWorkoutDataProvider.overrideWith((ref) async => workouts),
        workoutHistoryProvider.overrideWith((ref) async => workouts),
        workoutsStreamProvider.overrideWith((ref) => Stream.value(workouts)),
        activeProgramProvider.overrideWith(
          () => _FakeActiveProgramNotifier(activeProgram),
        ),
        dailyNutritionSummaryProvider.overrideWith(
          () => _FakeDailyNutritionNotifier(nutritionSummary),
        ),
        recentFoodsProvider.overrideWith((ref) async => nutritionSummary.meals),
        dietPlanProvider.overrideWith((ref) => Future.value(null)),
        userProfileProvider.overrideWith((ref) async => profile),
        workoutNotifierProvider.overrideWith(
          () => _FakeWorkoutNotifier(
            WorkoutState.inProgress(activeWorkout, now),
          ),
        ),
        progressionSuggestionUseCaseProvider.overrideWith(
          (ref) => _FakeGetProgressionSuggestion(),
        ),
        weightTrendProvider.overrideWith(
          (ref) async => [
            WeightDataPoint(
              date: now.subtract(const Duration(days: 10)),
              weight: 80.5,
            ),
            WeightDataPoint(date: now, weight: 79.5),
          ],
        ),
        bodyHistoryProvider.overrideWith(
          (ref) async => [
            BodyEntry(
              id: 'b-1',
              date: now,
              weight: 79.5,
              measurements: const {
                MeasurementType.waist: 82.0,
                MeasurementType.chest: 104.0,
              },
            ),
          ],
        ),
        authNotifierProvider.overrideWith(_FakeAuthNotifier.new),
        themeProvider.overrideWith(
          () => _FakeThemeNotifier(isDark ? ThemeMode.dark : ThemeMode.light),
        ),
        hapticsEnabledProvider.overrideWith(_FakeHapticsNotifier.new),
      ];

  Future<void> captureScreen({
    required WidgetTester tester,
    required Widget child,
    required Size size,
    required bool isDark,
    required List<String> outputPaths,
    bool useRouter = false,
  }) async {
    final key = GlobalKey();
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final theme = ThemeData.light().copyWith(extensions: [AppThemeTokens.light]);
    final darkTheme =
        ThemeData.dark().copyWith(extensions: [AppThemeTokens.dark]);

    final app = useRouter
        ? MaterialApp.router(
            debugShowCheckedModeBanner: false,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            theme: theme,
            darkTheme: darkTheme,
            routerConfig: GoRouter(
              initialLocation: '/',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (_, _) => child,
                ),
              ],
            ),
          )
        : MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            theme: theme,
            darkTheme: darkTheme,
            home: child,
          );

    await tester.pumpWidget(
      ProviderScope(
        overrides: commonOverrides(isDark: isDark),
        child: MediaQuery(
          data: MediaQueryData(
            size: size,
            devicePixelRatio: 1.0,
            disableAnimations: true,
          ),
          child: RepaintBoundary(key: key, child: app),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.takeException(), isNull);
    await _writePng(tester, key, outputPaths);
  }

  testWidgets('captures current baseline screenshots (before Wave 4.2)',
      (tester) async {
    await captureScreen(
      tester: tester,
      child: const HomeScreen(),
      size: const Size(390, 844),
      isDark: true,
      outputPaths: const [
        'docs/design-preview/00-current-design/today_main_390x844.png',
        'docs/screenshots/wave4-before/today_dark_390x844.png',
      ],
    );
    await captureScreen(
      tester: tester,
      child: const HomeScreen(),
      size: const Size(390, 844),
      isDark: false,
      outputPaths: const [
        'docs/design-preview/00-current-design/today_alt_390x844.png',
        'docs/screenshots/wave4-before/today_light_390x844.png',
      ],
    );
    await captureScreen(
      tester: tester,
      child: const HomeScreen(),
      size: const Size(1280, 800),
      isDark: true,
      outputPaths: const [
        'docs/design-preview/00-current-design/today_wide_1280x800.png',
        'docs/screenshots/wave4-before/today_wide_1280x800.png',
      ],
    );
    await captureScreen(
      tester: tester,
      child: const ActiveWorkoutScreen(),
      size: const Size(390, 844),
      isDark: true,
      useRouter: true,
      outputPaths: const [
        'docs/design-preview/00-current-design/active_workout_390x844.png',
        'docs/screenshots/wave4-before/active_workout_390x844.png',
      ],
    );
    await captureScreen(
      tester: tester,
      child: const NutritionScreen(),
      size: const Size(390, 844),
      isDark: true,
      outputPaths: const [
        'docs/design-preview/00-current-design/fuel_daily_390x844.png',
        'docs/screenshots/wave4-before/fuel_daily_390x844.png',
      ],
    );
    await captureScreen(
      tester: tester,
      child: const ProgressScreen(),
      size: const Size(390, 844),
      isDark: true,
      outputPaths: const [
        'docs/design-preview/00-current-design/progress_charts_390x844.png',
        'docs/screenshots/wave4-before/progress_charts_390x844.png',
      ],
    );
    await captureScreen(
      tester: tester,
      child: const ProgressScreen(),
      size: const Size(1280, 800),
      isDark: true,
      outputPaths: const [
        'docs/design-preview/00-current-design/progress_charts_wide_1280x800.png',
        'docs/screenshots/wave4-before/progress_charts_wide_1280x800.png',
      ],
    );
    await captureScreen(
      tester: tester,
      child: const SettingsScreen(),
      size: const Size(390, 844),
      isDark: true,
      outputPaths: const [
        'docs/design-preview/00-current-design/settings_390x844.png',
        'docs/screenshots/wave4-before/settings_390x844.png',
      ],
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 12));
  });
}
