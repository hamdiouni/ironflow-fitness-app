import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/data/user_profile_storage.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout_program.dart';
import 'package:progression_tracker/features/workout/domain/entities/active_program.dart';
import 'package:progression_tracker/features/workout/domain/repositories/active_program_repository.dart';
import 'package:progression_tracker/features/workout/domain/splits/services/split_catalog.dart';
import 'package:progression_tracker/features/workout/domain/usecases/generate_workout_program_use_case.dart';
import 'package:progression_tracker/features/workout/domain/usecases/set_active_program_use_case.dart';
import 'package:progression_tracker/features/nutrition/domain/usecases/generate_diet_plan_use_case.dart';
import 'package:progression_tracker/features/nutrition/domain/usecases/save_diet_plan_use_case.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/diet_plan_state.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/diet_plan_repository.dart';

class FakeUserProfileStorage extends UserProfileStorage {
  UserProfile? savedProfile;
  bool isUserOnboarded = false;

  @override
  Future<void> saveProfile(UserProfile profile, {String? userId}) async {
    savedProfile = profile;
  }

  @override
  Future<UserProfile?> loadProfile({String? userId}) async {
    return savedProfile;
  }

  @override
  Future<void> markOnboarded({String? userId}) async {
    isUserOnboarded = true;
  }
}

class FakeActiveProgramRepository implements ActiveProgramRepository {
  ActiveProgram? activeProgram;

  @override
  Future<void> saveActiveProgram(ActiveProgram program) async {
    activeProgram = program;
  }

  @override
  Future<ActiveProgram?> loadActiveProgram() async => activeProgram;

  @override
  Future<void> clearActiveProgram() async {
    activeProgram = null;
  }

  @override
  Future<void> updateActiveProgram(ActiveProgram program) async {
    activeProgram = program;
  }

  @override
  Future<void> archiveCurrentProgram() async {}

  @override
  Future<ActiveProgram?> restoreArchivedProgram() async => null;

  @override
  Future<bool> hasArchivedProgram() async => false;
}

class FakeDietPlanRepository implements DietPlanRepository {
  DietPlanState? savedPlan;

  @override
  Future<void> saveDietPlan(DietPlanState planState) async {
    savedPlan = planState;
  }

  @override
  Future<DietPlanState?> loadDietPlan() async => savedPlan;

  @override
  Future<void> clearDietPlan() async {
    savedPlan = null;
  }
}

void main() {
  const baseProfile = UserProfile(
    goal: FitnessGoal.gainMuscle,
    age: 25,
    weightKg: 75,
    heightCm: 178,
    fitnessLevel: FitnessLevel.intermediate,
    equipment: EquipmentType.gym,
    workoutDaysPerWeek: 4,
    budget: BudgetLevel.medium,
    sex: BiologicalSex.male,
  );

  group('Onboarding Guided Ready Plan Tests', () {
    test('GenerateWorkoutProgramUseCase creates a ready program with pre-selected exercises', () {
      final useCase = GenerateWorkoutProgramUseCase();
      final program = useCase(userProfile: baseProfile);

      expect(program.name, contains('Upper / Lower'));
      expect(program.days.length, equals(7));
      expect(program.daysPerWeek, equals(4));
      final trainingDays = program.days.where((d) => !d.isRestDay).toList();
      expect(trainingDays.length, equals(4));
      for (final day in trainingDays) {
        expect(day.exercises, isNotEmpty, reason: 'Every training day must have pre-selected exercises');
        for (final ex in day.exercises) {
          expect(ex.exerciseName, isNotEmpty);
          expect(ex.sets, greaterThan(0));
          expect(ex.reps, isNotEmpty);
        }
      }
    });

    test('User can choose a hybrid split during onboarding and receive valid days and exercises', () {
      final useCase = GenerateWorkoutProgramUseCase();
      final hybrid = SplitCatalog.pplXUpperLower();
      final program = useCase(
        userProfile: baseProfile.copyWith(workoutDaysPerWeek: 5),
        split: hybrid,
        overrideDays: 5,
      );

      expect(program.days.length, equals(7));
      expect(program.daysPerWeek, equals(5));
      expect(program.name, contains('PPL x Upper / Lower'));
      final trainingDays = program.days.where((d) => !d.isRestDay).toList();
      expect(trainingDays.length, equals(5));
      for (final day in trainingDays) {
        expect(day.exercises, isNotEmpty);
      }
    });

    test('OnboardingNotifier.completeOnboarding preserves customized program and syncs workout days', () async {
      final fakeStorage = FakeUserProfileStorage();
      final fakeActiveProgramRepo = FakeActiveProgramRepository();
      final fakeDietRepo = FakeDietPlanRepository();

      final notifier = OnboardingNotifier(
        fakeStorage,
        GenerateWorkoutProgramUseCase(),
        SetActiveProgramUseCase(fakeActiveProgramRepo),
        GenerateDietPlanUseCase(),
        SaveDietPlanUseCase(fakeDietRepo),
      );

      // Create a customized program where user swapped an exercise
      final useCase = GenerateWorkoutProgramUseCase();
      final baseProgram = useCase(userProfile: baseProfile);
      final customDays = List<ProgramDay>.from(baseProgram.days);
      final firstDayExercises = List<ProgramExercise>.from(customDays[0].exercises);
      firstDayExercises[0] = firstDayExercises[0].copyWith(exerciseName: 'Incline Dumbbell Press');
      customDays[0] = customDays[0].copyWith(exercises: firstDayExercises);
      final customProgram = baseProgram.copyWith(days: customDays);

      await notifier.completeOnboarding(
        baseProfile,
        customProgram: customProgram,
      );

      // Verifications:
      expect(fakeStorage.isUserOnboarded, isTrue);
      expect(fakeStorage.savedProfile, isNotNull);
      expect(fakeStorage.savedProfile!.workoutDaysPerWeek, equals(customProgram.daysPerWeek));
      expect(fakeActiveProgramRepo.activeProgram, isNotNull);
      expect(
        fakeActiveProgramRepo.activeProgram!.program.days[0].exercises[0].exerciseName,
        equals('Incline Dumbbell Press'),
      );
      expect(fakeDietRepo.savedPlan, isNotNull);
    });

    test('WorkoutProgram.daysPerWeek getter correctly calculates active non-rest training days', () {
      final prog = WorkoutProgram(
        id: 'test_p',
        name: 'Test Program',
        description: 'Test',
        days: const [
          ProgramDay(dayNumber: 1, name: 'Day 1', focus: 'Upper', exercises: [], isRestDay: false),
          ProgramDay(dayNumber: 2, name: 'Day 2', focus: 'Lower', exercises: [], isRestDay: false),
          ProgramDay(dayNumber: 3, name: 'Rest', focus: 'Rest', exercises: [], isRestDay: true),
          ProgramDay(dayNumber: 4, name: 'Day 3', focus: 'Upper', exercises: [], isRestDay: false),
        ],
        durationWeeks: 8,
        difficulty: 'Intermediate',
      );

      expect(prog.daysPerWeek, equals(3));
    });
  });
}
