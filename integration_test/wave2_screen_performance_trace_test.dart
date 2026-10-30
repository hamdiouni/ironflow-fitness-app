import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:progression_tracker/core/providers/connectivity_provider.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/ai/presentation/screens/ai_chat_screen.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/entities/measurement_type.dart';
import 'package:progression_tracker/features/body/domain/entities/weight_data_point.dart';
import 'package:progression_tracker/features/body/presentation/providers/body_providers.dart';
import 'package:progression_tracker/features/body/presentation/screens/progress_screen.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/diet_plan_providers.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:progression_tracker/features/nutrition/presentation/screens/food_search_screen.dart';
import 'package:progression_tracker/features/nutrition/presentation/screens/nutrition_screen.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/home_workout_provider.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/screens/active_workout_screen.dart';
import 'package:progression_tracker/features/workout/presentation/screens/exercise_catalog_screen.dart';
import 'package:progression_tracker/features/workout/presentation/screens/home_screen.dart';
import 'package:progression_tracker/features/workout/presentation/screens/workout_screen.dart';
import 'package:progression_tracker/features/workout/presentation/screens/workout_summary_screen.dart';

class _TraceGlobalAINotifier extends StateNotifier<GlobalAIState>
    implements GlobalAINotifier {
  _TraceGlobalAINotifier(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _TraceActiveProgramNotifier
    extends StateNotifier<AsyncValue<ActiveProgram?>>
    implements ActiveProgramNotifier {
  _TraceActiveProgramNotifier(ActiveProgram? program)
      : super(AsyncValue.data(program));

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _TraceDailyNutritionNotifier
    extends StateNotifier<AsyncValue<DailyNutritionSummary>>
    implements DailyNutritionNotifier {
  _TraceDailyNutritionNotifier(DailyNutritionSummary summary)
      : super(AsyncValue.data(summary));

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _TraceWorkoutNotifier extends StateNotifier<WorkoutState>
    implements WorkoutNotifier {
  _TraceWorkoutNotifier(super.state);

  @override
  Future<void> start({List<Exercise>? initialExercises}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime(2026, 4, 20, 12);

  final sampleWorkout = Workout(
    id: 'trace-workout-1',
    date: now,
    duration: const Duration(minutes: 48),
    totalVolume: 4200,
    exercises: [
      Exercise(
        id: 'ex-bench',
        name: 'Barbell Bench Press',
        type: ExerciseType.strength,
        sets: [
          SetEntry(
            id: 'set-1',
            reps: 8,
            weight: 100,
            timestamp: now,
            type: SetType.normal,
          ),
          SetEntry(
            id: 'set-2',
            reps: 8,
            weight: 100,
            timestamp: now,
            type: SetType.normal,
          ),
        ],
      ),
    ],
  );

  final sampleProgram = ActiveProgram(
    id: 'trace-prog-1',
    program: WorkoutProgram(
      id: 'prog-1',
      name: 'Slate Teal Hypertrophy',
      description: 'Wave 2 trace protocol',
      difficulty: 'Intermediate',
      durationWeeks: 8,
      days: const [
        ProgramDay(
          dayNumber: 1,
          name: 'Push Alpha',
          focus: 'Chest & Shoulders',
          exercises: [
            ProgramExercise(
              exerciseName: 'Barbell Bench Press',
              sets: 4,
              reps: '6-8',
              restSeconds: 120,
            ),
          ],
          isRestDay: false,
        ),
      ],
    ),
    currentDayIndex: 0,
    isActive: true,
    lastWorkoutDate: now,
    completedDays: const {},
  );

  Widget wrapWithProviders(Widget child) {
    final todayKey = todayNutritionDayKey();
    return ProviderScope(
      overrides: [
        globalAIProvider.overrideWith(
          (ref) => _TraceGlobalAINotifier(const GlobalAIState()),
        ),
        isOnlineProvider.overrideWith((ref) => Stream.value(true)),
        homeWorkoutDataProvider.overrideWith((ref) async => [sampleWorkout]),
        workoutHistoryProvider.overrideWith((ref) async => [sampleWorkout]),
        activeProgramProvider.overrideWith(
          (ref) => _TraceActiveProgramNotifier(sampleProgram),
        ),
        workoutNotifierProvider.overrideWith(
          (ref) => _TraceWorkoutNotifier(
            WorkoutState.inProgress(sampleWorkout, now),
          ),
        ),
        dailyNutritionSummaryProvider(todayKey).overrideWith(
          (ref) => _TraceDailyNutritionNotifier(
            DailyNutritionSummary(
              date: DateTime(now.year, now.month, now.day),
              meals: const [],
              target: null,
            ),
          ),
        ),
        recentFoodsProvider.overrideWith((ref) async => const []),
        dietPlanProvider.overrideWith((ref) async => null),
        weightTrendProvider.overrideWith(
          (ref) async => [
            WeightDataPoint(
              date: now.subtract(const Duration(days: 7)),
              weight: 80.5,
            ),
            WeightDataPoint(date: now, weight: 80.0),
          ],
        ),
        bodyHistoryProvider.overrideWith(
          (ref) async => [
            BodyEntry(
              id: 'b-1',
              date: now,
              weight: 80.0,
              measurements: const {MeasurementType.waist: 82.0},
            ),
          ],
        ),
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
      ],
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
          extensions: [AppThemeTokens.dark],
        ),
        home: child,
      ),
    );
  }

  group('Wave 2 Screen Performance Trace Suite', () {
    final screens = <String, Widget Function()>{
      'home_screen': () => const HomeScreen(),
      'train_workout_screen': () => const WorkoutScreen(),
      'active_workout_screen': () => const ActiveWorkoutScreen(),
      'workout_summary_screen': () => WorkoutSummaryScreen(
            workoutId: sampleWorkout.id,
            exercises: sampleWorkout.exercises,
            duration: sampleWorkout.duration,
            totalSets: 2,
            totalVolume: sampleWorkout.totalVolume,
          ),
      'nutrition_fuel_screen': () => const NutritionScreen(),
      'food_search_screen': () => FoodSearchScreen(onFoodLogged: (_, _) {}),
      'progress_screen': () => const ProgressScreen(initialTab: 'weight'),
      'exercise_catalog_screen': () => const ExerciseCatalogScreen(),
      'ai_chat_screen': () => const AIChatScreen(),
    };

    for (final entry in screens.entries) {
      testWidgets('trace ${entry.key}', (tester) async {
        await binding.traceAction(
          () async {
            await tester.pumpWidget(wrapWithProviders(entry.value()));
            await tester.pumpAndSettle();

            final scrollable = find.byType(Scrollable);
            if (scrollable.evaluate().isNotEmpty) {
              await tester.fling(scrollable.first, const Offset(0, -300), 1000);
              await tester.pumpAndSettle();
            }
          },
          reportKey: 'wave2_${entry.key}_timeline',
        );
      });
    }
  });
}
