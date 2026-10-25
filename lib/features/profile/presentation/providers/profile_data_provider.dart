import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/record_ownership.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../body/domain/entities/body_entry.dart';
import '../../../body/presentation/providers/body_providers.dart';
import '../../../nutrition/domain/entities/daily_nutrition_summary.dart';
import '../../../nutrition/domain/entities/diet_plan.dart';
import '../../../nutrition/domain/entities/diet_plan_state.dart';
import '../../../nutrition/domain/entities/meal.dart';
import '../../../nutrition/domain/entities/nutrition_targets.dart';
import '../../../nutrition/presentation/providers/diet_plan_providers.dart';
import '../../../nutrition/presentation/providers/nutrition_providers.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../workout/domain/entities/active_program.dart';
import '../../../workout/domain/entities/workout.dart';
import '../../../workout/presentation/providers/active_program_providers.dart';
import '../../../workout/presentation/providers/workout_providers.dart';

/// Everything the Profile screen renders, derived from the signed-in
/// user's *real* records.
///
/// The screen used to be fed only by the frozen onboarding
/// [UserProfile]: the header showed the fitness goal instead of the
/// account, weight/BMI never reflected logged body entries, and both
/// the workout program and the diet plan were regenerated
/// deterministically on every build (`GenerateWorkoutProgramUseCase` /
/// `GenerateDietPlanUseCase`) instead of reading the program/plan the
/// user actually has saved. This view model replaces all of that:
///
/// - identity (name, email, avatar initials, member-since) from the
///   auth account;
/// - current weight/BMI from the newest [BodyEntry] (the onboarding
///   weight is only the fallback before anything is logged);
/// - workout totals, this-week sessions and the streak computed from
///   the user's own workout history (not the global streak box);
/// - the persisted [ActiveProgram] with its real progress;
/// - today's logged meals against the user's saved
///   [NutritionTargets] / saved [DietPlan].
///
/// Workout/body/meal/program records carry a `userId` (schema v2).
/// Records owned by a *different* account on the same device are
/// filtered out; legacy unowned rows (`null`/empty/`local-user`) are
/// treated as the device user's own, matching the sync initial-push
/// ownership rules.
class ProfileData {
  const ProfileData({
    required this.accountUser,
    required this.displayName,
    required this.email,
    required this.initials,
    required this.profile,
    required this.effectiveProfile,
    required this.currentWeightKg,
    required this.bmi,
    required this.latestBodyEntry,
    required this.workouts,
    required this.totalWorkouts,
    required this.workoutsThisWeek,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.totalVolumeKg,
    required this.totalCaloriesBurned,
    required this.totalTrainingMinutes,
    required this.lastWorkoutDate,
    required this.activeProgram,
    required this.savedDietPlan,
    required this.savedDietPlanDayName,
    required this.savedDietPlanMeals,
    required this.nutritionTargets,
    required this.nutritionTargetSourceLabel,
    required this.targetCalories,
    required this.targetProteinG,
    required this.targetCarbsG,
    required this.targetFatsG,
    required this.consumedCaloriesToday,
    required this.consumedProteinTodayG,
    required this.consumedCarbsTodayG,
    required this.consumedFatsTodayG,
    required this.mealsLoggedToday,
  });

  /// The signed-in auth account, when there is one.
  final User? accountUser;
  final String displayName;
  final String? email;
  final String initials;

  /// The onboarding profile as saved for this user.
  final UserProfile profile;

  /// [profile] with its weight replaced by the newest logged body
  /// weight, so derived targets (BMR/TDEE/calories) track real data.
  final UserProfile effectiveProfile;

  final double currentWeightKg;
  final double bmi;
  final BodyEntry? latestBodyEntry;

  /// This user's workouts, newest first, tombstones excluded.
  final List<Workout> workouts;
  final int totalWorkouts;
  final int workoutsThisWeek;
  final int currentStreakDays;
  final int longestStreakDays;
  final double totalVolumeKg;
  final double totalCaloriesBurned;
  final int totalTrainingMinutes;
  final DateTime? lastWorkoutDate;

  /// The user's persisted active program, or null when none is active
  /// (or the stored singleton belongs to another account).
  final ActiveProgram? activeProgram;

  /// The diet plan saved for this user, if any.
  final DietPlan? savedDietPlan;
  final String? savedDietPlanDayName;
  final List<DietMeal> savedDietPlanMeals;

  /// The user's saved nutrition targets, when they belong to them.
  final NutritionTargets? nutritionTargets;

  /// Where the displayed macro targets came from (for honest labels).
  final String nutritionTargetSourceLabel;
  final double targetCalories;
  final double targetProteinG;
  final double targetCarbsG;
  final double targetFatsG;

  /// Today's intake from this user's logged meals.
  final double consumedCaloriesToday;
  final double consumedProteinTodayG;
  final double consumedCarbsTodayG;
  final double consumedFatsTodayG;
  final int mealsLoggedToday;

  int get completedProgramDays => activeProgram?.completedDays.length ?? 0;

  double get programProgress {
    final program = activeProgram;
    if (program == null || program.program.days.isEmpty) return 0;
    return (program.completedDays.length / program.program.days.length)
        .clamp(0.0, 1.0);
  }
}

/// Whether a record stamped with [ownerId] belongs to [userId].
///
/// Unowned/guest rows are treated as the device user's own (they were
/// created before accounts stamped ownership); a *different* account's
/// rows are never shown.
bool profileRecordBelongsToUser(String? ownerId, String? userId) {
  return RecordOwnershipRules.belongsToCurrentUser(
    ownerId: ownerId,
    currentUserId: userId,
  );
}

DateTime _dateOnlyUtc(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

int _currentStreakDays(Set<DateTime> workoutDays, DateTime now) {
  var cursor = _dateOnlyUtc(now);
  if (!workoutDays.contains(cursor)) {
    cursor = cursor.subtract(const Duration(days: 1));
    if (!workoutDays.contains(cursor)) return 0;
  }
  var streak = 0;
  while (workoutDays.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

int _longestStreakDays(Set<DateTime> workoutDays) {
  if (workoutDays.isEmpty) return 0;
  final sorted = workoutDays.toList()..sort();
  var longest = 1;
  var run = 1;
  for (var i = 1; i < sorted.length; i++) {
    if (sorted[i].difference(sorted[i - 1]).inDays == 1) {
      run++;
      if (run > longest) longest = run;
    } else {
      run = 1;
    }
  }
  return longest;
}

String _initialsFor(String displayName, String? email) {
  final source = displayName.trim().isNotEmpty
      ? displayName.trim()
      : (email?.split('@').first ?? '');
  if (source.isEmpty) return '?';
  final words =
      source.split(RegExp(r'[\s._-]+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return source[0].toUpperCase();
  if (words.length == 1) {
    final word = words.first;
    return (word.length >= 2 ? word.substring(0, 2) : word).toUpperCase();
  }
  return '${words[0][0]}${words[1][0]}'.toUpperCase();
}

/// Pure builder so the ownership filtering and derivations can be unit
/// tested without Hive or Riverpod.
ProfileData buildProfileData({
  required UserProfile profile,
  User? accountUser,
  List<Workout> workouts = const [],
  List<BodyEntry> bodyEntries = const [],
  ActiveProgram? activeProgram,
  DietPlanState? dietPlanState,
  DailyNutritionSummary? todayNutrition,
  DateTime? now,
}) {
  final userId = accountUser?.id;
  final referenceNow = now ?? DateTime.now();

  // --- Identity ---------------------------------------------------------
  final email = accountUser?.email.trim();
  final accountName = accountUser?.displayName?.trim();
  final displayName = (accountName != null && accountName.isNotEmpty)
      ? accountName
      : (email != null && email.isNotEmpty)
          ? email.split('@').first
          : 'Your profile';

  // --- Body -------------------------------------------------------------
  final ownBodyEntries = bodyEntries
      .where((e) =>
          e.deletedAt == null &&
          profileRecordBelongsToUser(e.userId, userId))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  final latestBodyEntry = ownBodyEntries.isEmpty ? null : ownBodyEntries.first;
  final currentWeightKg = latestBodyEntry?.weight ?? profile.weightKg;
  final effectiveProfile = profile.copyWith(weightKg: currentWeightKg);
  final heightM = profile.heightCm / 100;
  final bmi = heightM > 0 ? currentWeightKg / (heightM * heightM) : 0.0;

  // --- Workouts ----------------------------------------------------------
  final ownWorkouts = workouts
      .where((w) =>
          w.deletedAt == null &&
          profileRecordBelongsToUser(w.userId, userId))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  final workoutDays = ownWorkouts.map((w) => _dateOnlyUtc(w.date)).toSet();
  final today = _dateOnlyUtc(referenceNow);
  final weekStart =
      today.subtract(Duration(days: today.weekday - DateTime.monday));
  final workoutsThisWeek = ownWorkouts.where((w) {
    final day = _dateOnlyUtc(w.date);
    return !day.isBefore(weekStart) && !day.isAfter(today);
  }).length;

  // --- Active program -----------------------------------------------------
  final ownActiveProgram = (activeProgram != null &&
          activeProgram.isActive &&
          activeProgram.program.days.isNotEmpty &&
          profileRecordBelongsToUser(activeProgram.userId, userId) &&
          profileRecordBelongsToUser(activeProgram.program.userId, userId))
      ? activeProgram
      : null;

  // --- Nutrition ----------------------------------------------------------
  final savedDietPlan = dietPlanState?.plan;
  String? savedDietPlanDayName;
  var savedDietPlanMeals = const <DietMeal>[];
  if (dietPlanState != null &&
      savedDietPlan != null &&
      savedDietPlan.days.isNotEmpty) {
    final firstDayName = savedDietPlan.days.first.dayName;
    savedDietPlanDayName = firstDayName;
    savedDietPlanMeals = dietPlanState.getMealsForDay(firstDayName);
  }

  final summaryTarget = todayNutrition?.target;
  final ownTargets =
      (summaryTarget != null &&
              profileRecordBelongsToUser(summaryTarget.userId, userId))
          ? summaryTarget
          : null;

  final ownMealsToday = (todayNutrition?.meals ?? const [])
      .where((m) =>
          m.deletedAt == null &&
          profileRecordBelongsToUser(m.userId, userId))
      .toList();

  double sumMeals(double Function(Meal meal) pick) =>
      ownMealsToday.fold<double>(0, (sum, meal) => sum + pick(meal));

  final double targetCalories;
  final double targetProteinG;
  final double targetCarbsG;
  final double targetFatsG;
  final String targetSourceLabel;
  if (ownTargets != null) {
    targetCalories = ownTargets.macros.calories;
    targetProteinG = ownTargets.macros.protein;
    targetCarbsG = ownTargets.macros.carbs;
    targetFatsG = ownTargets.macros.fats;
    targetSourceLabel = 'Your saved targets';
  } else if (savedDietPlan != null) {
    targetCalories = savedDietPlan.dailyCalories;
    targetProteinG = savedDietPlan.proteinG;
    targetCarbsG = savedDietPlan.carbsG;
    targetFatsG = savedDietPlan.fatsG;
    targetSourceLabel = 'Your saved diet plan';
  } else {
    // Derived from this user's saved onboarding profile + latest
    // logged weight — still their data, just not yet persisted as a
    // targets document.
    targetCalories = effectiveProfile.dailyCalorieTarget;
    targetProteinG = effectiveProfile.dailyProteinTargetGrams;
    targetCarbsG = effectiveProfile.dailyCarbTargetGrams;
    targetFatsG = effectiveProfile.dailyFatTargetGrams;
    targetSourceLabel = 'Targets from your profile';
  }

  return ProfileData(
    accountUser: accountUser,
    displayName: displayName,
    email: (email == null || email.isEmpty) ? null : email,
    initials: _initialsFor(displayName, email),
    profile: profile,
    effectiveProfile: effectiveProfile,
    currentWeightKg: currentWeightKg,
    bmi: bmi,
    latestBodyEntry: latestBodyEntry,
    workouts: List.unmodifiable(ownWorkouts),
    totalWorkouts: ownWorkouts.length,
    workoutsThisWeek: workoutsThisWeek,
    currentStreakDays: _currentStreakDays(workoutDays, referenceNow),
    longestStreakDays: _longestStreakDays(workoutDays),
    totalVolumeKg:
        ownWorkouts.fold<double>(0, (sum, w) => sum + w.totalVolume),
    totalCaloriesBurned:
        ownWorkouts.fold<double>(0, (sum, w) => sum + w.caloriesBurned),
    totalTrainingMinutes:
        ownWorkouts.fold<int>(0, (sum, w) => sum + w.duration.inMinutes),
    lastWorkoutDate: ownWorkouts.isEmpty ? null : ownWorkouts.first.date,
    activeProgram: ownActiveProgram,
    savedDietPlan: savedDietPlan,
    savedDietPlanDayName: savedDietPlanDayName,
    savedDietPlanMeals: List.unmodifiable(savedDietPlanMeals),
    nutritionTargets: ownTargets,
    nutritionTargetSourceLabel: targetSourceLabel,
    targetCalories: targetCalories,
    targetProteinG: targetProteinG,
    targetCarbsG: targetCarbsG,
    targetFatsG: targetFatsG,
    consumedCaloriesToday: sumMeals((m) => m.macros.calories),
    consumedProteinTodayG: sumMeals((m) => m.macros.protein),
    consumedCarbsTodayG: sumMeals((m) => m.macros.carbs),
    consumedFatsTodayG: sumMeals((m) => m.macros.fats),
    mealsLoggedToday: ownMealsToday.length,
  );
}

/// Live profile data for the signed-in user.
///
/// Returns null until the user's onboarding profile has loaded (the
/// screen gates on `userProfileProvider` for its loading/empty
/// states). Everything else degrades gracefully via `valueOrNull`:
/// sections appear as their real data streams land.
final profileDataProvider = Provider<ProfileData?>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (profile == null) return null;

  final accountUser =
      ref.watch(authNotifierProvider.select((s) => s.user));
  final workouts =
      ref.watch(workoutsStreamProvider).valueOrNull ?? const <Workout>[];
  final bodyEntries =
      ref.watch(bodyEntriesStreamProvider).valueOrNull ??
          const <BodyEntry>[];
  final activeProgram = ref.watch(activeProgramProvider).valueOrNull;
  final dietPlanState = ref.watch(dietPlanProvider).valueOrNull;
  final todayNutrition = ref
      .watch(dailyNutritionSummaryProvider(todayNutritionDayKey()))
      .valueOrNull;

  return buildProfileData(
    profile: profile,
    accountUser: accountUser,
    workouts: workouts,
    bodyEntries: bodyEntries,
    activeProgram: activeProgram,
    dietPlanState: dietPlanState,
    todayNutrition: todayNutrition,
  );
});
