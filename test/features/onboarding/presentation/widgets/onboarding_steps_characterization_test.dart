import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/diet_plan_state.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/diet_plan_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/services/food_catalog.dart';
import 'package:progression_tracker/features/nutrition/domain/usecases/generate_diet_plan_use_case.dart';
import 'package:progression_tracker/features/nutrition/domain/usecases/save_diet_plan_use_case.dart';
import 'package:progression_tracker/features/onboarding/data/user_profile_storage.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/onboarding/presentation/widgets/onboarding_step7_summary.dart';
import 'package:progression_tracker/features/onboarding/presentation/widgets/onboarding_steps_schedule.dart';
import 'package:progression_tracker/features/workout/domain/entities/active_program.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout_program.dart';
import 'package:progression_tracker/features/workout/domain/repositories/active_program_repository.dart';
import 'package:progression_tracker/features/workout/domain/usecases/generate_workout_program_use_case.dart';
import 'package:progression_tracker/features/workout/domain/usecases/set_active_program_use_case.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

class _InMemoryProfileStorage extends UserProfileStorage {
  UserProfile? saved;
  bool marked = false;

  @override
  Future<void> saveProfile(UserProfile profile, {String? userId}) async {
    saved = profile;
  }

  @override
  Future<void> markOnboarded({String? userId}) async {
    marked = true;
  }
}

class _InMemoryActiveProgramRepo extends Fake
    implements ActiveProgramRepository {
  ActiveProgram? program;

  @override
  Future<void> saveActiveProgram(ActiveProgram p) async {
    program = p;
  }
}

class _InMemoryDietPlanRepo extends Fake implements DietPlanRepository {
  DietPlanState? savedState;

  @override
  Future<void> saveDietPlan(DietPlanState planState) async {
    savedState = planState;
  }

  @override
  Future<DietPlanState?> loadDietPlan() async => savedState;
}

class _InMemoryNutritionRepo extends Fake implements NutritionRepository {
  NutritionTargets? savedTargets;

  @override
  Future<void> saveNutritionTargets(NutritionTargets targets) async {
    savedTargets = targets;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await FoodCatalog.ensureLoaded();
  });

  setUp(() {
    AppHaptics.shared = AppHaptics(isEnabled: false);
  });

  const sampleProfile = UserProfile(
    goal: FitnessGoal.gainMuscle,
    age: 28,
    weightKg: 80.0,
    heightCm: 180.0,
    fitnessLevel: FitnessLevel.intermediate,
    equipment: EquipmentType.gym,
    workoutDaysPerWeek: 4,
    budget: BudgetLevel.medium,
  );

  final sampleProgram = WorkoutProgram(
    id: 'prog-1',
    name: 'Upper / Lower',
    description: 'Balanced 4-day split',
    durationWeeks: 8,
    difficulty: 'Intermediate',
    days: const [
      ProgramDay(
        dayNumber: 1,
        name: 'Day 1 - Upper',
        focus: 'Chest & Back',
        exercises: [
          ProgramExercise(
            exerciseName: 'Barbell Bench Press',
            sets: 3,
            reps: '8-10',
            restSeconds: 120,
          ),
        ],
      ),
    ],
  );

  group('Wave 2.2 — Onboarding Schedule, Budget, Diet & Summary Characterization',
      () {
    testWidgets(
        'renders Steps 4, 5, 6 and Step 7 Summary with interactive swap and diet callbacks',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      int? pickedDays;
      FitnessLevel? pickedLevel;
      BudgetLevel? pickedBudget;
      String? swappedExercise;
      bool? dietToggled;

      final tokens = AppThemeTokens.dark;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(extensions: [tokens]),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  OnboardingStep4Frequency(
                    tokens: tokens,
                    daysPerWeek: 4,
                    chosenSplitId: null,
                    onDaysChanged: (d) => pickedDays = d,
                    onSplitChosen: (_) {},
                  ),
                  OnboardingStep5Experience(
                    tokens: tokens,
                    fitnessLevel: FitnessLevel.intermediate,
                    onLevelChanged: (l) => pickedLevel = l,
                  ),
                  OnboardingStep6Budget(
                    tokens: tokens,
                    budget: BudgetLevel.medium,
                    onBudgetChanged: (b) => pickedBudget = b,
                  ),
                  OnboardingStep7Summary(
                    tokens: tokens,
                    tempProfile: sampleProfile,
                    program: sampleProgram,
                    includeDietPlan: true,
                    synthesisError: null,
                    onSwapExercise: (day, idx, ex) =>
                        swappedExercise = ex.exerciseName,
                    onToggleDietPlan: (v) => dietToggled = v,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('WEEKLY FREQUENCY'), findsOneWidget);
      expect(find.text('NUTRITION BUDGET'), findsOneWidget);
      expect(find.text('PROTOCOL INITIALIZED'), findsOneWidget);
      expect(find.text('SUGGESTED MEAL PLAN'), findsOneWidget);

      await tester.tap(find.byKey(const Key('frequency_day_5')));
      await tester.pump();
      expect(pickedDays, 5);

      await tester.ensureVisible(find.text('BEGINNER'));
      await tester.tap(find.text('BEGINNER'));
      await tester.pump();
      expect(pickedLevel, FitnessLevel.beginner);

      await tester.ensureVisible(find.text('HIGH BUDGET'));
      await tester.tap(find.text('HIGH BUDGET'));
      await tester.pump();
      expect(pickedBudget, BudgetLevel.high);

      await tester.ensureVisible(find.byKey(const Key('swap_exercise_1_0')));
      await tester.tap(find.byKey(const Key('swap_exercise_1_0')));
      await tester.pump();
      expect(swappedExercise, 'Barbell Bench Press');

      await tester.ensureVisible(find.byType(Switch));
      await tester.tap(find.byType(Switch));
      await tester.pump();
      expect(dietToggled, isFalse);
    });

    test('OnboardingNotifier.completeOnboarding saves profile, program, diet plan, and nutrition targets',
        () async {
      final storage = _InMemoryProfileStorage();
      final programRepo = _InMemoryActiveProgramRepo();
      final dietRepo = _InMemoryDietPlanRepo();
      final nutritionRepo = _InMemoryNutritionRepo();

      final container = ProviderContainer(
        overrides: [
          onboardingNotifierProvider.overrideWith(
            () => OnboardingNotifier.withDependencies(
              storage,
              GenerateWorkoutProgramUseCase(),
              SetActiveProgramUseCase(programRepo),
              GenerateDietPlanUseCase(),
              SaveDietPlanUseCase(dietRepo),
              nutritionRepository: nutritionRepo,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(onboardingNotifierProvider.notifier)
          .completeOnboarding(
            sampleProfile,
            userId: 'u-onboard-1',
            customProgram: sampleProgram,
            includeDietPlan: true,
          );

      expect(storage.marked, isTrue);
      expect(storage.saved?.workoutDaysPerWeek, 1);
      expect(programRepo.program?.program.name, 'Upper / Lower');
      expect(dietRepo.savedState?.plan, isNotNull);
      expect(nutritionRepo.savedTargets?.userId, 'u-onboard-1');
      expect(
        nutritionRepo.savedTargets?.macros.calories,
        closeTo(storage.saved!.dailyCalorieTarget, 0.1),
      );
    });
  });
}
