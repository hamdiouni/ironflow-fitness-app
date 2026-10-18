import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/screens/active_workout_screen.dart';
import 'package:progression_tracker/features/workout/domain/usecases/usecases.dart';
import 'package:progression_tracker/shared/presentation/components/components.dart';

class FakeGetProgressionSuggestionUseCase
    implements GetProgressionSuggestionUseCase {
  @override
  Future<ProgressionSuggestion?> call(String exerciseName) async => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeActiveProgramNotifier
    extends StateNotifier<AsyncValue<ActiveProgram?>>
    implements ActiveProgramNotifier {
  FakeActiveProgramNotifier([ActiveProgram? program])
      : super(AsyncValue.data(program));

  @override
  Future<void> completeCurrentDay() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGlobalAINotifier extends StateNotifier<GlobalAIState>
    implements GlobalAINotifier {
  FakeGlobalAINotifier([super.state = const GlobalAIState()]);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class TestWorkoutNotifier extends StateNotifier<WorkoutState>
    implements WorkoutNotifier {
  TestWorkoutNotifier(super.initialState);

  bool startCalled = false;
  bool finishCalled = false;
  bool resetCalled = false;
  double? updatedCalories;
  final List<Exercise> addedExercises = [];
  final List<MapEntry<String, SetEntry>> loggedSets = [];

  @override
  Future<void> start({List<Exercise>? initialExercises}) async {
    startCalled = true;
    final workout = Workout(
      id: 'test_workout_id',
      date: DateTime.now(),
      exercises: initialExercises ?? [],
      duration: Duration.zero,
      totalVolume: 0,
    );
    state = WorkoutState.inProgress(workout, DateTime.now());
  }

  @override
  Future<void> addExercise(Exercise exercise) async {
    addedExercises.add(exercise);
    state.maybeWhen(
      inProgress: (workout, startTime) {
        final updated = workout.copyWith(
          exercises: [...workout.exercises, exercise],
        );
        state = WorkoutState.inProgress(updated, startTime);
      },
      orElse: () {},
    );
  }

  @override
  Future<bool> logSetForExercise(String exerciseId, SetEntry set) async {
    loggedSets.add(MapEntry(exerciseId, set));
    state.maybeWhen(
      inProgress: (workout, startTime) {
        final exerciseIndex =
            workout.exercises.indexWhere((e) => e.id == exerciseId);
        if (exerciseIndex != -1) {
          final exercise = workout.exercises[exerciseIndex];
          final updatedExercise = exercise.copyWith(
            sets: [...exercise.sets, set],
          );
          final updatedExercises = [
            for (int i = 0; i < workout.exercises.length; i++)
              i == exerciseIndex ? updatedExercise : workout.exercises[i],
          ];
          final updatedWorkout =
              workout.copyWith(exercises: updatedExercises);
          state = WorkoutState.inProgress(updatedWorkout, startTime);
        }
      },
      orElse: () {},
    );
    return false;
  }

  @override
  void updateCalories(double caloriesBurned) {
    updatedCalories = caloriesBurned;
  }

  @override
  Future<void> finish() async {
    finishCalled = true;
    state.maybeWhen(
      inProgress: (workout, _) {
        state = WorkoutState.completed(workout);
      },
      orElse: () {},
    );
  }

  @override
  Future<void> reset() async {
    resetCalled = true;
    state = const WorkoutState.initial();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  Widget buildTestWidget({
    required WorkoutNotifier notifier,
    List<Override> extraOverrides = const [],
  }) {
    final router = GoRouter(
      initialLocation: '/active-workout',
      routes: [
        GoRoute(
          path: '/active-workout',
          builder: (context, state) => const ActiveWorkoutScreen(),
        ),
        GoRoute(
          path: AppRoutes.workoutSummary,
          builder: (context, state) => const Scaffold(
            body: Text('Summary Screen Destination'),
          ),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        workoutNotifierProvider.overrideWith((ref) => notifier),
        progressionSuggestionUseCaseProvider
            .overrideWithValue(FakeGetProgressionSuggestionUseCase()),
        activeProgramProvider
            .overrideWith((ref) => FakeActiveProgramNotifier(null)),
        globalAIProvider
            .overrideWith((ref) => FakeGlobalAINotifier(const GlobalAIState())),
        currentDayExercisesProvider.overrideWith((ref) => []),
        ...extraOverrides,
      ],
      child: MaterialApp.router(
        themeMode: ThemeMode.dark,
        theme: ThemeData.dark().copyWith(
          extensions: [AppThemeTokens.dark],
        ),
        routerConfig: router,
      ),
    );
  }

  group('ActiveWorkoutScreen Characterization Tests (Unmodified Baseline)', () {
    testWidgets('1. Initial view renders READY TO TRAIN and starts workout on tap', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final notifier = TestWorkoutNotifier(const WorkoutState.initial());

      await tester.pumpWidget(buildTestWidget(notifier: notifier));
      await tester.pumpAndSettle();

      expect(find.text('READY TO TRAIN?'), findsOneWidget);
      expect(find.text('Start a new session and log sets with telemetry.'), findsOneWidget);
      expect(find.text('▶ BEGIN WORKOUT'), findsOneWidget);

      await tester.tap(find.text('▶ BEGIN WORKOUT'));
      await tester.pumpAndSettle();

      expect(notifier.startCalled, isTrue);
      expect(find.text('ACTIVE WORKOUT'), findsOneWidget);
      expect(find.text('NO EXERCISES YET'), findsOneWidget);
    });

    testWidgets('2. Empty workout view renders NO EXERCISES YET and disabled FINISH button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final workout = Workout(
        id: 'w1',
        date: DateTime.now(),
        exercises: const [],
        duration: Duration.zero,
        totalVolume: 0,
      );
      final notifier = TestWorkoutNotifier(WorkoutState.inProgress(workout, DateTime.now()));

      await tester.pumpWidget(buildTestWidget(notifier: notifier));
      await tester.pumpAndSettle();

      expect(find.text('ACTIVE WORKOUT'), findsOneWidget);
      expect(find.text('NO EXERCISES YET'), findsOneWidget);
      expect(find.text('+ ADD EXERCISE'), findsOneWidget);

      // Finish workout button is present but disabled because hasSets is false
      final finishBtn = find.widgetWithText(AppButton, 'FINISH WORKOUT');
      expect(finishBtn, findsOneWidget);
      final appButtonWidget = tester.widget<AppButton>(finishBtn);
      expect(appButtonWidget.onPressed, isNull);
    });

    testWidgets('3. Can add exercise from selection sheet and log set', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final workout = Workout(
        id: 'w1',
        date: DateTime.now(),
        exercises: const [
          Exercise(
            id: 'ex_bench',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [],
          ),
        ],
        duration: Duration.zero,
        totalVolume: 0,
      );
      final notifier = TestWorkoutNotifier(WorkoutState.inProgress(workout, DateTime.now()));

      await tester.pumpWidget(buildTestWidget(notifier: notifier));
      await tester.pumpAndSettle();

      // Verify exercise card rendered
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('WARMUP'), findsOneWidget);
      expect(find.text('NORMAL'), findsOneWidget);
      expect(find.text('DROP SET'), findsOneWidget);
      expect(find.text('FAILURE'), findsOneWidget);

      // Enter reps and weight
      final repsField = find.widgetWithText(TextField, 'REPS');
      final weightField = find.widgetWithText(TextField, 'WEIGHT (KG)');
      expect(repsField, findsOneWidget);
      expect(weightField, findsOneWidget);

      await tester.enterText(repsField, '10');
      await tester.enterText(weightField, '80');
      await tester.pumpAndSettle();

      // Tap LOG SET
      final logSetBtn = find.widgetWithText(AppButton, 'LOG SET');
      expect(logSetBtn, findsOneWidget);
      await tester.tap(logSetBtn);
      await tester.pumpAndSettle();

      // Verify set logged in notifier
      expect(notifier.loggedSets.length, 1);
      expect(notifier.loggedSets.first.key, 'ex_bench');
      expect(notifier.loggedSets.first.value.reps, 10);
      expect(notifier.loggedSets.first.value.weight, 80.0);

      // Verify set tag rendered in card
      expect(find.text('SET 1: 80.0KG × 10'), findsOneWidget);

      // FINISH WORKOUT should now be enabled
      final finishBtn = tester.widget<AppButton>(find.widgetWithText(AppButton, 'FINISH WORKOUT'));
      expect(finishBtn.onPressed, isNotNull);
    });

    testWidgets('4. Opens Plate Calculator sheet on icon button tap', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final workout = Workout(
        id: 'w1',
        date: DateTime.now(),
        exercises: const [
          Exercise(
            id: 'ex_bench',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [],
          ),
        ],
        duration: Duration.zero,
        totalVolume: 0,
      );
      final notifier = TestWorkoutNotifier(WorkoutState.inProgress(workout, DateTime.now()));

      await tester.pumpWidget(buildTestWidget(notifier: notifier));
      await tester.pumpAndSettle();

      final calcBtn = find.byTooltip('Plate Calculator');
      expect(calcBtn, findsOneWidget);
      await tester.tap(calcBtn);
      await tester.pumpAndSettle();

      // Verify plate calculator sheet opens
      expect(find.text('PLATE CALCULATOR'), findsOneWidget);
      expect(find.text('TARGET LOAD'), findsOneWidget);
    });

    testWidgets('5. Completed workout state renders loading and navigates to summary', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final workout = Workout(
        id: 'w1',
        date: DateTime.now(),
        exercises: [
          Exercise(
            id: 'ex_bench',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [
              SetEntry(
                id: 's1',
                reps: 10,
                weight: 80.0,
                timestamp: DateTime.now(),
              ),
            ],
          ),
        ],
        duration: const Duration(minutes: 30),
        totalVolume: 800.0,
      );
      final notifier = TestWorkoutNotifier(WorkoutState.completed(workout));

      await tester.pumpWidget(buildTestWidget(notifier: notifier));
      await tester.pumpAndSettle();

      // Completed state triggers navigation to AppRoutes.workoutSummary and resets notifier
      expect(find.text('Summary Screen Destination'), findsOneWidget);
      expect(notifier.resetCalled, isTrue);
    });

    testWidgets('6. Resuming workout from saved state renders directly inProgress', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final resumedWorkout = Workout(
        id: 'resumed_id',
        date: DateTime(2026, 10, 18, 14, 0),
        exercises: [
          Exercise(
            id: 'ex_squat',
            name: 'Squat',
            type: ExerciseType.strength,
            sets: [
              SetEntry(id: 's1', reps: 5, weight: 120.0, timestamp: DateTime.now()),
              SetEntry(id: 's2', reps: 5, weight: 120.0, timestamp: DateTime.now()),
            ],
          ),
        ],
        duration: const Duration(minutes: 25),
        totalVolume: 1200.0,
      );
      final notifier = TestWorkoutNotifier(
        WorkoutState.inProgress(resumedWorkout, DateTime(2026, 10, 18, 14, 0)),
      );

      await tester.pumpWidget(buildTestWidget(notifier: notifier));
      await tester.pumpAndSettle();

      // Restored workout displays directly without "READY TO TRAIN?"
      expect(find.text('READY TO TRAIN?'), findsNothing);
      expect(find.text('ACTIVE WORKOUT'), findsOneWidget);
      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('SET 1: 120.0KG × 5'), findsOneWidget);
      expect(find.text('SET 2: 120.0KG × 5'), findsOneWidget);
    });
  });
}
