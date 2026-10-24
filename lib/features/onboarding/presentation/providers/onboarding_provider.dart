import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final userId = ref.watch(authNotifierProvider.select((s) => s.user?.id));
  final storage = ref.watch(userProfileStorageProvider);
  return storage.isOnboarded(userId: userId);
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final userId = ref.watch(authNotifierProvider.select((s) => s.user?.id));
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
class OnboardingNotifier extends StateNotifier<AsyncValue<void>> {
  OnboardingNotifier(
    this._storage,
    this._generateProgramUseCase,
    this._setActiveProgramUseCase,
    this._generateDietPlanUseCase,
    this._saveDietPlanUseCase, {
    NutritionRepository? nutritionRepository,
  })  : _nutritionRepository = nutritionRepository,
        super(const AsyncValue.data(null));

  final UserProfileStorage _storage;
  final GenerateWorkoutProgramUseCase _generateProgramUseCase;
  final SetActiveProgramUseCase _setActiveProgramUseCase;
  final GenerateDietPlanUseCase _generateDietPlanUseCase;
  final SaveDietPlanUseCase _saveDietPlanUseCase;

  /// Optional so unit tests can construct this notifier without a nutrition
  /// stack. When present, onboarding also writes the user's [NutritionTargets]
  /// derived from the profile (DATABASE_AND_SYNC_AUDIT F-08: these previously
  /// had no live writer at all, so every targets-based UI read null).
  final NutritionRepository? _nutritionRepository;

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
              userId: userId ?? 'local-user',
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
    StateNotifierProvider<OnboardingNotifier, AsyncValue<void>>((ref) {
  return OnboardingNotifier(
    ref.watch(userProfileStorageProvider),
    ref.watch(generateWorkoutProgramUseCaseProvider),
    ref.watch(setActiveProgramUseCaseProvider),
    GenerateDietPlanUseCase(),
    ref.watch(saveDietPlanUseCaseProvider),
    nutritionRepository: ref.watch(nutritionRepositoryProvider),
  );
});
