import 'package:flutter/material.dart' hide Split;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/workout/domain/entities/active_program.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout_program.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/workout/presentation/screens/program_selection_screen.dart';

class MockActiveProgramNotifier extends StateNotifier<AsyncValue<ActiveProgram?>>
    implements ActiveProgramNotifier {
  MockActiveProgramNotifier(ActiveProgram? initial)
      : super(AsyncValue.data(initial));

  ActiveProgram? archivedProgram;
  WorkoutProgram? lastSavedProgram;
  bool archivePreviousCalled = false;
  bool undoCalled = false;

  @override
  Future<void> setActiveProgram(WorkoutProgram program, {bool archivePrevious = true}) async {
    lastSavedProgram = program;
    archivePreviousCalled = archivePrevious;
    if (archivePrevious && state.value != null) {
      archivedProgram = state.value;
    }
    final active = ActiveProgram(
      id: 'mock_active_${DateTime.now().millisecondsSinceEpoch}',
      program: program,
      currentDayIndex: 0,
      isActive: true,
      lastWorkoutDate: null,
      completedDays: {},
    );
    state = AsyncValue.data(active);
  }

  @override
  Future<bool> undoProgramChange() async {
    undoCalled = true;
    if (archivedProgram != null) {
      state = AsyncValue.data(archivedProgram);
      archivedProgram = null;
      return true;
    }
    return false;
  }

  @override
  Future<bool> hasArchivedProgram() async => archivedProgram != null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const testProfile = UserProfile(
    goal: FitnessGoal.gainMuscle,
    age: 26,
    weightKg: 78,
    heightCm: 180,
    fitnessLevel: FitnessLevel.intermediate,
    equipment: EquipmentType.gym,
    workoutDaysPerWeek: 4,
    budget: BudgetLevel.medium,
    sex: BiologicalSex.male,
  );

  final initialProgram = WorkoutProgram(
    id: 'initial_program',
    name: 'Initial Program',
    description: 'Existing initial program before generator run',
    days: const [
      ProgramDay(dayNumber: 1, name: 'Full Body A', focus: 'Compounds', exercises: []),
    ],
    durationWeeks: 8,
    difficulty: 'Intermediate',
  );

  final initialActive = ActiveProgram(
    id: 'initial_active',
    program: initialProgram,
    currentDayIndex: 0,
    isActive: true,
    lastWorkoutDate: null,
    completedDays: {},
  );

  Widget createWidgetUnderTest({
    UserProfile profile = testProfile,
    ActiveProgram? activeProgram,
    MockActiveProgramNotifier? notifier,
  }) {
    final effectiveNotifier = notifier ?? MockActiveProgramNotifier(activeProgram);

    return ProviderScope(
      overrides: [
        userProfileProvider.overrideWith((ref) => Future.value(profile)),
        activeProgramProvider.overrideWith((ref) => effectiveNotifier),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        theme: ThemeData.dark().copyWith(
          extensions: [AppThemeTokens.dark],
        ),
        home: const ProgramSelectionScreen(),
      ),
    );
  }

  group('ProgramSelectionScreen Widget Tests (Sci-Fi Split Generator)', () {
    testWidgets('Renders PROTOCOL GENERATOR title and category tabs', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('PROTOCOL GENERATOR'), findsOneWidget);
      expect(find.text('STANDARD'), findsOneWidget);
      expect(find.text('HYBRIDS'), findsOneWidget);
      expect(find.text('MIX / CUSTOM'), findsOneWidget);
      expect(find.text('TRAINING DAYS PER WEEK'), findsOneWidget);
      expect(find.text('SCHEDULE MATRIX'), findsOneWidget);
      expect(find.text('MUSCLE FREQUENCY'), findsOneWidget);
      expect(find.byKey(const Key('apply_protocol_btn')), findsOneWidget);
    });

    testWidgets('Renders standard split options', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('UPPER / LOWER'), findsOneWidget);
      expect(find.text('PUSH / PULL / LEGS'), findsOneWidget);
      expect(find.text('FULL BODY'), findsOneWidget);
      expect(find.text('ARNOLD SPLIT'), findsOneWidget);
    });

    testWidgets('Adjusting days stepper to 2 on PPL reveals non-blocking advisory badge', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Select Push/Pull/Legs card
      final pplCard = find.byKey(const Key('split_card_push_pull_legs'));
      await tester.tap(pplCard);
      await tester.pumpAndSettle();

      // Tap day 2 in days stepper
      final day2Btn = find.byKey(const Key('days_stepper_day_2'));
      await tester.tap(day2Btn);
      await tester.pumpAndSettle();

      // Guidance badge should appear with non-blocking advisory
      expect(find.text('PROTOCOL ADVISORY'), findsOneWidget);
      expect(find.text('NON-BLOCKING'), findsOneWidget);
      expect(find.textContaining('lower frequency'), findsOneWidget);
    });

    testWidgets('Switching category to HYBRIDS renders hybrid splits and mode toggle', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap HYBRIDS category tab
      await tester.tap(find.text('HYBRIDS'));
      await tester.pumpAndSettle();

      expect(find.text('PPL X ARNOLD'), findsOneWidget);
      expect(find.text('ARNOLD X UPPER / LOWER'), findsOneWidget);
      expect(find.text('PPL X UPPER / LOWER'), findsOneWidget);

      // Hybrid mode selector should be visible
      expect(find.text('HYBRID ARCHITECTURE MODE'), findsOneWidget);
      expect(find.text('COMBINED CYCLE'), findsOneWidget);
      expect(find.text('ALTERNATE WEEKS'), findsOneWidget);
    });

    testWidgets('Switching preview tab to MUSCLE FREQUENCY renders frequency telemetry card', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap MUSCLE FREQUENCY tab
      await tester.tap(find.byKey(const Key('preview_mode_frequency')));
      await tester.pumpAndSettle();

      expect(find.text('WEEKLY MUSCLE FREQUENCY'), findsOneWidget);
      expect(find.textContaining('SESSIONS/WK'), findsOneWidget);
      expect(find.text('Chest'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('Tapping APPLY PROTOCOL saves program with archive and shows SnackBar with UNDO', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final notifier = MockActiveProgramNotifier(initialActive);

      await tester.pumpWidget(createWidgetUnderTest(
        activeProgram: initialActive,
        notifier: notifier,
      ));
      await tester.pumpAndSettle();

      // Tap APPLY PROTOCOL button
      final applyBtn = find.byKey(const Key('apply_protocol_btn'));
      await tester.tap(applyBtn);
      await tester.pumpAndSettle();

      // Verifications:
      expect(notifier.lastSavedProgram, isNotNull);
      expect(notifier.archivePreviousCalled, isTrue);
      expect(notifier.archivedProgram, equals(initialActive));

      // SnackBar with UNDO should appear
      expect(find.textContaining('Protocol initialized:'), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);

      // Tap UNDO
      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();

      expect(notifier.undoCalled, isTrue);
      expect(notifier.state.value, equals(initialActive));
      expect(find.text('Previous protocol restored.'), findsOneWidget);
    });
  });
}
