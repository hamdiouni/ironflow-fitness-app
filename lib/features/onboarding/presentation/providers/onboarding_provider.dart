import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/record_ownership.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../data/user_profile_storage.dart';
import '../../domain/entities/user_profile.dart';
import '../../../workout/domain/usecases/generate_workout_program_use_case.dart';
import '../../../workout/domain/usecases/set_active_program_use_case.dart';
import '../../../workout/presentation/providers/active_program_providers.dart';
import '../../../workout/presentation/providers/workout_providers.dart';
import '../../../workout/domain/entities/workout_program.dart';
import '../../../workout/domain/splits/entities/split.dart';
import '../../../nutrition/domain/entities/diet_plan.dart';
import '../../../nutrition/domain/entities/nutrition_targets.dart';
import '../../../nutrition/domain/repositories/nutrition_repository.dart';
import '../../../nutrition/domain/usecases/generate_diet_plan_use_case.dart';
import '../../../nutrition/domain/usecases/save_diet_plan_use_case.dart';
import '../../../nutrition/presentation/providers/diet_plan_providers.dart';
import '../../../nutrition/presentation/providers/nutrition_providers.dart';

final userProfileStorageProvider = Provider<UserProfileStorage>(
  (_) => UserProfileStorage(),
);

final isOnboardedProvider = FutureProvider<bool>((ref) async {
  // Re-evaluate when the signed-in account changes: onboarding state and
  // the onboarding profile are stored per user id, so a cached result
  // from the previous account must never leak into the next one.
  final userId = ref.watch(currentUserIdProvider);
  final storage = ref.watch(userProfileStorageProvider);
  return storage.isOnboarded(userId: userId);
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final storage = ref.watch(userProfileStorageProvider);
  return storage.loadProfile(userId: userId);
});

/// Notifier for saving the user profile during onboarding.
/// 
/// After profile save, this notifier:
/// 1. Generates or adopts the personalized workout program
/// 2. Sets it as the active program
/// 3. Generates a personalized diet plan
/// 4. Saves the diet plan
/// 5. Marks the user as onboarded
/// 
/// This ensures users complete onboarding with a ready-to-use program.
class OnboardingNotifier extends Notifier<AsyncValue<void>> {
  OnboardingNotifier([
    this._injectedStorage,
    this._injectedGenerateProgramUseCase,
    this._injectedSetActiveProgramUseCase,
    this._injectedGenerateDietPlanUseCase,
    this._injectedSaveDietPlanUseCase,
  ]) : _injectedNutritionRepository = null;

  OnboardingNotifier.withDependencies(
    this._injectedStorage,
    this._injectedGenerateProgramUseCase,
    this._injectedSetActiveProgramUseCase,
    this._injectedGenerateDietPlanUseCase,
    this._injectedSaveDietPlanUseCase, {
    NutritionRepository? nutritionRepository,
  }) : _injectedNutritionRepository = nutritionRepository;

  final UserProfileStorage? _injectedStorage;
  final GenerateWorkoutProgramUseCase? _injectedGenerateProgramUseCase;
  final SetActiveProgramUseCase? _injectedSetActiveProgramUseCase;
  final GenerateDietPlanUseCase? _injectedGenerateDietPlanUseCase;
  final SaveDietPlanUseCase? _injectedSaveDietPlanUseCase;
  final NutritionRepository? _injectedNutritionRepository;

  late UserProfileStorage _storage;
  late GenerateWorkoutProgramUseCase _generateProgramUseCase;
  late SetActiveProgramUseCase _setActiveProgramUseCase;
  late GenerateDietPlanUseCase _generateDietPlanUseCase;
  late SaveDietPlanUseCase _saveDietPlanUseCase;
  NutritionRepository? _nutritionRepository;

  @override
  AsyncValue<void> build() {
    _storage = _injectedStorage ?? ref.watch(userProfileStorageProvider);
    _generateProgramUseCase = _injectedGenerateProgramUseCase ??
        ref.watch(generateWorkoutProgramUseCaseProvider);
    _setActiveProgramUseCase = _injectedSetActiveProgramUseCase ??
        ref.watch(setActiveProgramUseCaseProvider);
    _generateDietPlanUseCase =
        _injectedGenerateDietPlanUseCase ?? GenerateDietPlanUseCase();
    _saveDietPlanUseCase =
        _injectedSaveDietPlanUseCase ?? ref.watch(saveDietPlanUseCaseProvider);
    _nutritionRepository = _injectedNutritionRepository ??
        (_injectedStorage != null ? null : ref.watch(nutritionRepositoryProvider));
    return const AsyncValue.data(null);
  }

  Future<void> completeOnboarding(
    UserProfile profile, {
    String? userId,
    WorkoutProgram? customProgram,
    Split? chosenSplit,
    bool includeDietPlan = true,
    DietPlan? customDietPlan,
  }) async {
    state = const AsyncValue.loading();
    try {
      // 1. Generate or adopt custom program
      final program = customProgram ??
          _generateProgramUseCase(
            userProfile: profile,
            split: chosenSplit,
            overrideDays: profile.workoutDaysPerWeek,
          );

      // Ensure profile workoutDaysPerWeek strictly matches program daysPerWeek
      final effectiveProfile = profile.workoutDaysPerWeek == program.daysPerWeek
          ? profile
          : profile.copyWith(workoutDaysPerWeek: program.daysPerWeek);

      // 2. Save profile
      await _storage.saveProfile(effectiveProfile, userId: userId);

      // 3. Set active program
      await _setActiveProgramUseCase(program);

      // 4. Optionally generate and save diet plan
      if (includeDietPlan) {
        final dietPlan = customDietPlan ?? _generateDietPlanUseCase(effectiveProfile);
        await _saveDietPlanUseCase(dietPlan);
      }

      // 4b. Derive and persist nutrition targets from the profile so the
      // nutrition summary / AI deficiency checks have a real target
      // document from day one (F-08). Best-effort: never fail onboarding.
      final nutritionRepository = _nutritionRepository;
      if (nutritionRepository != null) {
        try {
          final now = DateTime.now();
          await nutritionRepository.saveNutritionTargets(
            NutritionTargets(
              userId: userId ?? RecordOwnershipRules.guestUserId,
              macros: MacroTargets(
                calories: effectiveProfile.dailyCalorieTarget,
                protein: effectiveProfile.dailyProteinTargetGrams,
                carbs: effectiveProfile.dailyCarbTargetGrams,
                fats: effectiveProfile.dailyFatTargetGrams,
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
              createdAt: now,
              updatedAt: now,
            ),
          );
        } catch (_) {
          // Targets derivation is best-effort.
        }
      }

      // 5. Mark onboarded
      await _storage.markOnboarded(userId: userId);

      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}

final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, AsyncValue<void>>(
  OnboardingNotifier.new,
);
