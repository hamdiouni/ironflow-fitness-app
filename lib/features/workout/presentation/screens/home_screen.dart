import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/providers/units_provider.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/core/utils/workout_streak_calculator.dart';
import 'package:progression_tracker/shared/widgets/ironflow_logo.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/ai_coach_hero_card.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/ai_entry_button.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/home_workout_provider.dart';
import '../widgets/home/home_activity_and_summary.dart';
import '../widgets/home/home_readiness_and_fuel.dart';
import '../widgets/home/home_workout_cards_and_states.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(homeWorkoutDataProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final units = ref.watch(unitsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh all providers
            ref.invalidate(homeWorkoutDataProvider);
            ref.invalidate(userProfileProvider);
            ref.invalidate(activeProgramProvider);
            // The family is keyed by the yyyy-MM-dd day string (Phase 3),
            // so there's exactly one canonical key for today. See F-07 in
            // docs/architecture/DATABASE_AND_SYNC_AUDIT.md.
            ref.invalidate(
              dailyNutritionSummaryProvider(todayNutritionDayKey()),
            );
            // Wait for data to load
            await Future.wait([
              ref.read(homeWorkoutDataProvider.future),
              ref.read(userProfileProvider.future),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Header (Logo, Greeting, Streak, AI Entry, Account)
              SliverToBoxAdapter(
                child: _HomeHeader(
                  profileAsync: profileAsync,
                  historyAsync: historyAsync,
                ),
              ),

              SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final readiness = const HeroReadinessBanner();
                    final directive = const TodayDirectiveCard();
                    final fuel = DailyFuelSummaryBar(profileAsync: profileAsync);
                    final quick = historyAsync.when(
                      data: (workouts) => QuickWorkoutActions(workouts: workouts),
                      loading: () => const QuickWorkoutActions(workouts: []),
                      error: (_, _) => const QuickWorkoutActions(workouts: []),
                    );
                    final coach = const AiCoachHeroCard();
                    final weekly = historyAsync.when(
                      data: (workouts) => profileAsync.when(
                        data: (profile) {
                          if (profile == null) {
                            return const ProfileSetupPrompt();
                          }
                          return WeeklyActivitySection(
                            workouts: workouts,
                            target: profile.workoutDaysPerWeek,
                          );
                        },
                        loading: () => const LoadingWeeklyActivity(),
                        error: (_, _) => const LoadingWeeklyActivity(),
                      ),
                      loading: () => const LoadingWeeklyActivity(),
                      error: (error, stack) => HomeErrorCard(
                        message: 'Failed to load workout data',
                        onRetry: () => ref.invalidate(homeWorkoutDataProvider),
                      ),
                    );
                    final summary = profileAsync.when(
                      data: (profile) => historyAsync.when(
                        data: (workouts) => TodaySummaryRow(
                          workouts: workouts,
                          profile: profile,
                          units: units,
                        ),
                        loading: () => const LoadingSummaryRow(),
                        error: (_, _) => const LoadingSummaryRow(),
                      ),
                      loading: () => const LoadingSummaryRow(),
                      error: (_, _) => const LoadingSummaryRow(),
                    );
                    final suggestion = historyAsync.when(
                      data: (workouts) => profileAsync.when(
                        data: (profile) => HomeSuggestionCard(
                          workouts: workouts,
                          profile: profile,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    );
                    final recent = historyAsync.when(
                      data: (workouts) => workouts.isNotEmpty
                          ? RecentWorkoutCard(workout: workouts.first)
                          : const EmptyWorkoutCard(),
                      loading: () => const LoadingWorkoutCard(),
                      error: (_, _) => const SizedBox.shrink(),
                    );

                    if (constraints.maxWidth >= 900) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                directive,
                                quick,
                                coach,
                                recent,
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                readiness,
                                fuel,
                                weekly,
                                summary,
                                suggestion,
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        readiness,
                        directive,
                        fuel,
                        quick,
                        coach,
                        weekly,
                        summary,
                        suggestion,
                        recent,
                      ],
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.profileAsync,
    required this.historyAsync,
  });
  final AsyncValue<UserProfile?> profileAsync;
  final AsyncValue<List<dynamic>> historyAsync;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final workouts = historyAsync.valueOrNull ?? const [];
    final streakDays = WorkoutStreakCalculator.calculateFromDates(
      workouts.map<DateTime>((w) => w.date as DateTime),
    ).currentStreak;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacings.lg,
        AppSpacings.md,
        AppSpacings.lg,
        AppSpacings.xs,
      ),
      child: Row(
        children: [
          const IronFlowLogo(size: 40),
          const SizedBox(width: AppSpacings.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY OVERVIEW',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    color: tokens.kineticAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ready to train',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    color: tokens.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: tokens.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(tokens.radiusPill),
              border: Border.all(color: tokens.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department_rounded, size: 15, color: tokens.warning),
                const SizedBox(width: 4),
                Text(
                  '$streakDays d',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacings.xs),
          const AiEntryButton(contextScreen: 'today'),
          const SizedBox(width: AppSpacings.xs),
          Semantics(
            button: true,
            label: 'Open User Profile and Settings',
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: InkWell(
                onTap: () => _openUserHub(context, tokens),
                customBorder: const CircleBorder(),
                child: Center(
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tokens.card,
                      border: Border.all(color: tokens.borderSubtle, width: 1),
                    ),
                    child: Icon(Icons.person_outline, color: tokens.textPrimary, size: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.05);
  }

  void _openUserHub(BuildContext context, AppThemeTokens tokens) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(tokens.radiusLg)),
        side: BorderSide(color: tokens.borderSubtle, width: 1),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tokens.card,
                      shape: BoxShape.circle,
                      border: Border.all(color: tokens.kineticAccent, width: 1.5),
                    ),
                    child: Icon(Icons.person, color: tokens.kineticAccent, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PROFILE',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            color: tokens.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'PROFILE & SETTINGS',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            color: tokens.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.badge_outlined, color: tokens.kineticAccent),
                title: Text(
                  'PROFILE & BIOMETRICS',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    color: tokens.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                subtitle: Text(
                  'Workout plan, fitness level, and nutrition targets',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    color: tokens.textSecondary,
                    fontSize: 11,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: tokens.textTertiary),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(AppRoutes.profile);
                },
              ),
              Divider(color: tokens.borderSubtle, height: 1),
              ListTile(
                leading: Icon(Icons.settings_outlined, color: tokens.kineticAccent),
                title: Text(
                  'SETTINGS & DATA',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    color: tokens.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                subtitle: Text(
                  'Appearance, haptics, export, backup, and restore',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    color: tokens.textSecondary,
                    fontSize: 11,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: tokens.textTertiary),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(AppRoutes.settings);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

