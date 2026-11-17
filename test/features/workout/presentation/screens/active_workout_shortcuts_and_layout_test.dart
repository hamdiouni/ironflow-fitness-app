import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/providers/units_provider.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/domain/usecases/usecases.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/rest_timer_provider.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/screens/active_workout_screen.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

class _FixedUnitsNotifier extends UnitsNotifier {
  _FixedUnitsNotifier(this._units);
  final UnitsSystem _units;

  @override
  UnitsSystem build() => _units;
}

class _FakeActiveProgramNotifier extends Notifier<AsyncValue<ActiveProgram?>>
    implements ActiveProgramNotifier {
  @override
  AsyncValue<ActiveProgram?> build() => const AsyncValue.data(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGetProgressionSuggestionUseCase
    implements GetProgressionSuggestionUseCase {
  @override
  Future<ProgressionSuggestion?> call(String exerciseName) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWorkoutNotifier extends Notifier<WorkoutState>
    implements WorkoutNotifier {
  _FakeWorkoutNotifier(this._initial);
  final WorkoutState _initial;
  final List<SetEntry> logged = [];

  @override
  WorkoutState build() => _initial;

  @override
  Future<bool> logSetForExercise(String exerciseId, SetEntry set) async {
    logged.add(set);
    state.maybeWhen(
      inProgress: (workout, startTime) {
        final updatedExercises = [
          for (final ex in workout.exercises)
            if (ex.id == exerciseId)
              ex.copyWith(sets: [...ex.sets, set])
            else
              ex,
        ];
        state = WorkoutState.inProgress(
          workout.copyWith(exercises: updatedExercises),
          startTime,
        );
      },
      orElse: () {},
    );
    return false;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    AppHaptics.shared = AppHaptics(isEnabled: false);
  });

  Workout sampleWorkout() => Workout(
        id: 'w_shortcuts',
        date: DateTime(2026, 11, 17, 9, 0),
        exercises: const [
          Exercise(
            id: 'ex_1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [],
          ),
        ],
        duration: Duration.zero,
        totalVolume: 0,
      );

  group('ActiveWorkoutScreen Units Init, Shortcuts & Responsive Layouts', () {
    testWidgets(
        'initializes weight unit from unitsProvider and renders cleanly on 360px width',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final notifier = _FakeWorkoutNotifier(
        WorkoutState.inProgress(sampleWorkout(), DateTime.now()),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            unitsProvider.overrideWith(() => _FixedUnitsNotifier(UnitsSystem.imperial)),
            workoutNotifierProvider.overrideWith(() => notifier),
            activeProgramProvider.overrideWith(_FakeActiveProgramNotifier.new),
            progressionSuggestionUseCaseProvider.overrideWith(
              (ref) => _FakeGetProgressionSuggestionUseCase(),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const ActiveWorkoutScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('WORKOUT'), findsOneWidget);
      expect(find.byKey(const Key('active_workout_elapsed_badge')), findsOneWidget);
      expect(find.descendant(
        of: find.byKey(const Key('weight_unit_toggle')),
        matching: find.text('LB'),
      ), findsOneWidget);
    });

    testWidgets(
        'handles Alt+= weight step, Alt+L log set, and Alt+R rest timer shortcuts in 1280px 2-pane layout at 1.5x text scale',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final notifier = _FakeWorkoutNotifier(
        WorkoutState.inProgress(sampleWorkout(), DateTime.now()),
      );
      final container = ProviderContainer(
        overrides: [
          unitsProvider.overrideWith(() => _FixedUnitsNotifier(UnitsSystem.metric)),
          workoutNotifierProvider.overrideWith(() => notifier),
          activeProgramProvider.overrideWith(_FakeActiveProgramNotifier.new),
          progressionSuggestionUseCaseProvider.overrideWith(
            (ref) => _FakeGetProgressionSuggestionUseCase(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(1280, 800),
                textScaler: TextScaler.linear(1.5),
              ),
              child: const ActiveWorkoutScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('SESSION SUMMARY'), findsOneWidget);
      expect(find.textContaining('Alt+L Log set'), findsOneWidget);

      // Alt+= increments weight by 2.5 kg twice -> 5 kg.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.equal);
      await tester.sendKeyEvent(LogicalKeyboardKey.equal);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pump();

      // Alt+L logs a set with the stepped 5 kg weight and auto-starts rest timer.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyL);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pumpAndSettle();

      expect(notifier.logged.length, 1);
      expect(notifier.logged.first.weight, 5.0);
      expect(container.read(restTimerProvider).isRunning, isTrue);

      // Alt+R skips/stops active rest timer cleanly so no timers dangle.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      await tester.pumpAndSettle();

      expect(container.read(restTimerProvider).isRunning, isFalse);
      container.read(restTimerProvider.notifier).stop();
    });
  });
}
