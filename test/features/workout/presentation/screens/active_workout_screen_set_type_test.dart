import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/domain/usecases/usecases.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/screens/active_workout_screen.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

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

  final List<MapEntry<String, SetEntry>> loggedSets = [];
  final List<(String, int, SetType)> updatedSetTypes = [];

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
          state = WorkoutState.inProgress(
            workout.copyWith(exercises: updatedExercises),
            startTime,
          );
        }
      },
      orElse: () {},
    );
    return true;
  }

  @override
  Future<void> updateSetType(
      String exerciseId, int setIndex, SetType newType) async {
    updatedSetTypes.add((exerciseId, setIndex, newType));
    state.maybeWhen(
      inProgress: (workout, startTime) {
        final exerciseIndex =
            workout.exercises.indexWhere((e) => e.id == exerciseId);
        if (exerciseIndex != -1) {
          final exercise = workout.exercises[exerciseIndex];
          if (setIndex >= 0 && setIndex < exercise.sets.length) {
            final oldSet = exercise.sets[setIndex];
            final updatedSet = oldSet.copyWith(type: newType);
            final updatedSets = List<SetEntry>.from(exercise.sets);
            updatedSets[setIndex] = updatedSet;
            final updatedExercise = exercise.copyWith(sets: updatedSets);
            final updatedExercises = List<Exercise>.from(workout.exercises);
            updatedExercises[exerciseIndex] = updatedExercise;
            state = WorkoutState.inProgress(
              workout.copyWith(exercises: updatedExercises),
              startTime,
            );
          }
        }
      },
      orElse: () {},
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    AppHaptics.shared = AppHaptics(isEnabled: false);
  });

  Widget buildTestWidget({
    required WorkoutNotifier notifier,
  }) {
    final router = GoRouter(
      initialLocation: '/active-workout',
      routes: [
        GoRoute(
          path: '/active-workout',
          builder: (context, state) => const ActiveWorkoutScreen(),
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
      ],
      child: MaterialApp.router(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(),
        routerConfig: router,
      ),
    );
  }

  group('ActiveWorkoutScreen Training Integrity (TRN-01, TRN-03)', () {
    testWidgets('SetType chip cycles Normal -> Warmup -> Drop Set -> Failure -> Normal', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final workout = Workout(
        id: 'w1',
        date: DateTime.now(),
        duration: Duration.zero,
        totalVolume: 0,
        exercises: [
          Exercise(
            id: 'ex1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: const [],
          ),
        ],
      );

      final notifier = TestWorkoutNotifier(
        WorkoutState.inProgress(workout, DateTime.now()),
      );

      await tester.pumpWidget(buildTestWidget(notifier: notifier));
      await tester.pumpAndSettle();

      // Initially, SetType chip says "NORMAL"
      expect(find.text('NORMAL'), findsOneWidget);

      // Tap to cycle -> WARMUP
      await tester.tap(find.text('NORMAL'));
      await tester.pump();
      expect(find.text('WARMUP'), findsOneWidget);

      // Tap to cycle -> DROP SET
      await tester.tap(find.text('WARMUP'));
      await tester.pump();
      expect(find.text('DROP SET'), findsOneWidget);

      // Tap to cycle -> FAILURE
      await tester.tap(find.text('DROP SET'));
      await tester.pump();
      expect(find.text('FAILURE'), findsOneWidget);

      // Tap to cycle -> back to NORMAL
      await tester.tap(find.text('FAILURE'));
      await tester.pump();
      expect(find.text('NORMAL'), findsOneWidget);
    });

    testWidgets('RPE / RIR toggle chip converts dynamically between RPE and RIR', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final workout = Workout(
        id: 'w1',
        date: DateTime.now(),
        duration: Duration.zero,
        totalVolume: 0,
        exercises: [
          Exercise(
            id: 'ex1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: const [],
          ),
        ],
      );

      final notifier = TestWorkoutNotifier(
        WorkoutState.inProgress(workout, DateTime.now()),
      );

      await tester.pumpWidget(buildTestWidget(notifier: notifier));
      await tester.pumpAndSettle();

      // Initially RPE mode is active: text label shows RPE
      expect(find.text('RPE'), findsWidgets);

      // Enter RPE: 8
      final rpeFinder = find.byType(TextField).at(2); // 3rd TextField (reps, weight, rpe)
      await tester.enterText(rpeFinder, '8');
      await tester.pump();

      // Tap RPE chip to toggle to RIR (the chip is inside the Stack on the right)
      final toggleChip = find.text('RPE').last;
      await tester.tap(toggleChip);
      await tester.pump();

      // Should convert RPE 8 to RIR 2 (10 - 8 = 2)
      expect(find.text('RIR'), findsWidgets);
      final rirField = tester.widget<TextField>(rpeFinder);
      expect(rirField.controller?.text, equals('2'));

      // Toggle back to RPE
      await tester.tap(find.text('RIR').last);
      await tester.pump();
      expect(find.text('RPE'), findsWidgets);
      final revertedField = tester.widget<TextField>(rpeFinder);
      expect(revertedField.controller?.text, equals('8'));
    });

    testWidgets('Logging set with Warmup type and RPE logs accurate values', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final workout = Workout(
        id: 'w1',
        date: DateTime.now(),
        duration: Duration.zero,
        totalVolume: 0,
        exercises: [
          Exercise(
            id: 'ex1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: const [],
          ),
        ],
      );

      final notifier = TestWorkoutNotifier(
        WorkoutState.inProgress(workout, DateTime.now()),
      );

      await tester.pumpWidget(buildTestWidget(notifier: notifier));
      await tester.pumpAndSettle();

      // Cycle to WARMUP
      await tester.tap(find.text('WARMUP'));
      await tester.pump();

      // Enter Reps 10, Weight 60, RPE 6
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '10');
      await tester.enterText(textFields.at(1), '60.0');
      await tester.enterText(textFields.at(2), '6');
      await tester.pump();

      // Tap LOG SET
      final logSetBtn = find.text('LOG SET');
      await tester.ensureVisible(logSetBtn);
      await tester.tap(logSetBtn);
      await tester.pump();

      // Verify set was logged with SetType.warmup and RPE 6
      expect(notifier.loggedSets.length, equals(1));
      final logged = notifier.loggedSets.first.value;
      expect(logged.reps, equals(10));
      expect(logged.weight, equals(60.0));
      expect(logged.type, equals(SetType.warmup));
      expect(logged.rpe, equals(6));

      // Clean up rest timer triggered by log set
      await tester.pump(const Duration(seconds: 65));
    });

    testWidgets('Tapping logged set type chip invokes updateSetType', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final workout = Workout(
        id: 'w1',
        date: DateTime.now(),
        duration: Duration.zero,
        totalVolume: 800.0,
        exercises: [
          Exercise(
            id: 'ex1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [
              SetEntry.create(reps: 10, weight: 80.0, type: SetType.normal),
            ],
          ),
        ],
      );

      final notifier = TestWorkoutNotifier(
        WorkoutState.inProgress(workout, DateTime.now()),
      );

      await tester.pumpWidget(buildTestWidget(notifier: notifier));
      await tester.pumpAndSettle();

      // Logged set is shown with badge 'N' for normal
      final loggedChip = find.text('N');
      expect(loggedChip, findsOneWidget);

      // Tap on logged chip to quick-cycle to Warmup ('W')
      await tester.tap(loggedChip);
      await tester.pump();

      // Verify updateSetType was called with new type warmup
      expect(notifier.updatedSetTypes.length, equals(1));
      expect(notifier.updatedSetTypes.first.$1, equals('ex1'));
      expect(notifier.updatedSetTypes.first.$2, equals(0));
      expect(notifier.updatedSetTypes.first.$3, equals(SetType.warmup));
    });
  });
}
