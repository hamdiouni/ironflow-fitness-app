import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/user_profile_storage.dart';
import '../../domain/entities/user_profile.dart';
import '../../../workout/domain/usecases/generate_workout_program_use_case.dart';
import '../../../workout/domain/usecases/set_active_program_use_case.dart';
import '../../../workout/presentation/providers/active_program_providers.dart';
import '../../../workout/presentation/providers/workout_providers.dart';
import '../../../workout/domain/entities/workout_program.dart';
import '../../../workout/domain/splits/entities/split.dart';
import '../../../nutrition/domain/usecases/generate_diet_plan_use_case.dart';
import '../../../nutrition/domain/usecases/save_diet_plan_use_case.dart';
import '../../../nutrition/presentation/providers/diet_plan_providers.dart';

final userProfileStorageProvider = Provider<UserProfileStorage>(
  (_) => UserProfileStorage(),
);

final isOnboardedProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(userProfileStorageProvider);
  return storage.isOnboarded();
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final storage = ref.watch(userProfileStorageProvider);
  return storage.loadProfile();
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
    this._saveDietPlanUseCase,
  ) : super(const AsyncValue.data(null));

  final UserProfileStorage _storage;
  final GenerateWorkoutProgramUseCase _generateProgramUseCase;
  final SetActiveProgramUseCase _setActiveProgramUseCase;
  final GenerateDietPlanUseCase _generateDietPlanUseCase;
  final SaveDietPlanUseCase _saveDietPlanUseCase;

  Future<void> completeOnboarding(
    UserProfile profile, {
    String? userId,
    WorkoutProgram? customProgram,
    Split? chosenSplit,
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

      // 4. Generate and save diet plan
      final dietPlan = _generateDietPlanUseCase(effectiveProfile);
      await _saveDietPlanUseCase(dietPlan);

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
  );
});
