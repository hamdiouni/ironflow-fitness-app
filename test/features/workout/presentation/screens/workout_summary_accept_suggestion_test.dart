import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/screens/workout_summary_screen.dart';

class TestActiveProgramNotifier
    extends StateNotifier<AsyncValue<ActiveProgram?>>
    implements ActiveProgramNotifier {
  TestActiveProgramNotifier(ActiveProgram? program)
      : super(AsyncValue.data(program));

  final List<ActiveProgram> updatedPrograms = [];

  @override
  Future<void> updateProgram(ActiveProgram program) async {
    updatedPrograms.add(program);
    state = AsyncValue.data(program);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late WorkoutProgram initialWorkoutProgram;
  late ActiveProgram initialActiveProgram;

  setUp(() {
    initialWorkoutProgram = const WorkoutProgram(
      id: 'prog1',
      name: 'PPL Program',
      description: 'Push Pull Legs',
      durationWeeks: 8,
      difficulty: 'Intermediate',
      days: [
        ProgramDay(
          dayNumber: 1,
          name: 'Leg Day',
          focus: 'Quads & Glutes',
          exercises: [
            ProgramExercise(
              exerciseName: 'Squat',
              sets: 3,
              reps: '6-8',
              restSeconds: 90,
              targetWeight: 80.0,
            ),
          ],
        ),
      ],
    );

    initialActiveProgram = ActiveProgram(
      id: 'active1',
      program: initialWorkoutProgram,
      currentDayIndex: 0,
      isActive: true,
    );
  });

  testWidgets('Accepting progression suggestion updates active program and supports UNDO (TRN-03)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final notifier = TestActiveProgramNotifier(initialActiveProgram);

    const suggestion = ProgressionSuggestion(
      suggestedWeight: 85.0,
      suggestedReps: 8,
      isStagnant: false,
      message: 'Increase weight by 5.0kg next session',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activeProgramProvider.overrideWith((ref) => notifier),
          progressionSuggestionProvider('Squat').overrideWith((ref) async => suggestion),
        ],
        child: const MaterialApp(
          home: WorkoutSummaryScreen(
            totalSets: 3,
            totalVolume: 2400.0,
            duration: Duration(minutes: 40),
            prCount: 1,
            exerciseNames: ['Squat'],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Suggestion card is displayed
    expect(find.text('Progression Suggestions'), findsOneWidget);
    expect(find.text('Suggested Weight:'), findsOneWidget);
    expect(find.text('85.0 kg'), findsOneWidget);

    // Tap Accept button
    final acceptButton = find.widgetWithText(ElevatedButton, 'Accept');
    expect(acceptButton, findsOneWidget);
    await tester.ensureVisible(acceptButton);
    await tester.tap(acceptButton);
    // Allow SnackBar entrance animation ticks to complete
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify ActiveProgram updated with new target weight and reps
    expect(notifier.updatedPrograms.length, equals(1));
    final updatedExercise = notifier.updatedPrograms.first.program.days.first.exercises.first;
    expect(updatedExercise.targetWeight, equals(85.0));
    expect(updatedExercise.reps, equals('8'));

    // Verify SnackBar with UNDO action is shown
    expect(find.text('Suggestion accepted for Squat'), findsOneWidget);
    final undoButton = find.widgetWithText(SnackBarAction, 'UNDO');
    expect(undoButton, findsOneWidget);

    // Tap UNDO
    await tester.ensureVisible(undoButton);
    await tester.tap(undoButton);
    await tester.pump(const Duration(milliseconds: 300));

    // Verify program was restored back to original targets
    expect(notifier.updatedPrograms.length, equals(2));
    final revertedExercise = notifier.updatedPrograms.last.program.days.first.exercises.first;
    expect(revertedExercise.targetWeight, equals(80.0));
    expect(revertedExercise.reps, equals('6-8'));
  });
}
