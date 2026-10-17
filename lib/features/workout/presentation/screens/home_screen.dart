import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/presentation/components/components.dart';
import '../../../../shared/widgets/ironflow_logo.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../ai/presentation/widgets/ai_coach_hero_card.dart';
import '../../../ai/presentation/widgets/ai_entry_button.dart';
import '../../domain/entities/workout.dart';
import '../../../nutrition/presentation/providers/nutrition_providers.dart';
import '../providers/active_program_providers.dart';
import '../providers/home_workout_provider.dart';
import '../providers/workout_providers.dart';
import '../../../../shared/presentation/services/app_haptics.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(homeWorkoutDataProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh all providers
            ref.invalidate(homeWorkoutDataProvider);
            ref.invalidate(userProfileProvider);
            ref.invalidate(activeProgramProvider);
            ref.invalidate(dailyNutritionSummaryProvider(DateTime.now()));
            // Wait for data to load
            await Future.wait([
              ref.read(homeWorkoutDataProvider.future),
              ref.read(userProfileProvider.future),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 1. Header (Avatar -> Operator Hub, IronFlow Logo, AI Entry)
              SliverToBoxAdapter(
                child: _HomeHeader(profileAsync: profileAsync),
              ),

              // 2. Today's Program Directive (Protocol Day or Rest Day card)
              const SliverToBoxAdapter(
                child: _TodayDirectiveCard(),
              ),

              // 3. Daily Fuel Telemetry (Summary bar connecting directly to /nutrition)
              SliverToBoxAdapter(
                child: _DailyFuelSummaryBar(profileAsync: profileAsync),
              ),

              // 4. Quick Workout Actions (Quick Start + Repeat Last Workout)
              SliverToBoxAdapter(
                child: historyAsync.when(
                  data: (workouts) => _QuickWorkoutActions(workouts: workouts),
                  loading: () => const _QuickWorkoutActions(workouts: []),
                  error: (_, _) => const _QuickWorkoutActions(workouts: []),
                ),
              ),

              // 5. AI Coach Hero Card
              const SliverToBoxAdapter(
                child: AiCoachHeroCard(),
              ),

              // 6. Weekly Activity Section
              SliverToBoxAdapter(
                child: historyAsync.when(
                  data: (workouts) => profileAsync.when(
                    data: (profile) {
                      if (profile == null) {
                        return const _ProfileSetupPrompt();
                      }
                      return _WeeklyActivitySection(
                        workouts: workouts,
                        target: profile.workoutDaysPerWeek,
                      );
                    },
                    loading: () => const _LoadingWeeklyActivity(),
                    error: (_, _) => const _LoadingWeeklyActivity(),
                  ),
                  loading: () => const _LoadingWeeklyActivity(),
                  error: (error, stack) => _ErrorCard(
                    message: 'Failed to load workout data',
                    onRetry: () => ref.invalidate(homeWorkoutDataProvider),
                  ),
                ),
              ),

              // 7. Today Summary Metric Cards
              SliverToBoxAdapter(
                child: profileAsync.when(
                  data: (profile) => historyAsync.when(
                    data: (workouts) => _TodaySummaryRow(
                      workouts: workouts,
                      profile: profile,
                    ),
                    loading: () => const _LoadingSummaryRow(),
                    error: (_, _) => const _LoadingSummaryRow(),
                  ),
                  loading: () => const _LoadingSummaryRow(),
                  error: (_, _) => const _LoadingSummaryRow(),
                ),
              ),

              // 8. Suggestion Card
              SliverToBoxAdapter(
                child: historyAsync.when(
                  data: (workouts) => profileAsync.when(
                    data: (profile) => _SuggestionCard(
                      workouts: workouts,
                      profile: profile,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),

              // 9. Recent Workout Card (with Repeat CTA)
              SliverToBoxAdapter(
                child: historyAsync.when(
                  data: (workouts) => workouts.isNotEmpty
                      ? _RecentWorkoutCard(workout: workouts.first)
                      : const _EmptyWorkoutCard(),
                  loading: () => const _LoadingWorkoutCard(),
                  error: (_, _) => const SizedBox.shrink(),
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
  const _HomeHeader({required this.profileAsync});
  final AsyncValue<UserProfile?> profileAsync;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';
    final tokens = context.tokens;

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
                  greeting,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    color: tokens.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'IronFlow',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    color: tokens.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const AiEntryButton(),
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
                          'OPERATOR HUB',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            color: tokens.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'PROFILE & SYSTEM CONFIGURATION',
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
                  'Directives, fitness level, and nutrition targets',
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

// ── Weekly Activity Section ───────────────────────────────────────────────────

class _WeeklyActivitySection extends StatelessWidget {
  const _WeeklyActivitySection({required this.workouts, required this.target});
  final List<Workout> workouts;
  final int target;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 6));
    final weekWorkouts = workouts.where((w) => w.date.isAfter(weekStart)).toList();
    final count = weekWorkouts.length;
    final tokens = context.tokens;
    final progress = target > 0 ? (count / target).clamp(0.0, 1.0) : 0.0;
    final isGoalMet = count >= target && target > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.sm,
      ),
      child: AppCard(
        isGlowing: isGoalMet,
        padding: const EdgeInsets.all(AppSpacings.lg),
        child: Row(
          children: [
            AppProgressRing(
              progress: progress,
              size: 82,
              strokeWidth: 8,
              progressColor: tokens.kineticAccent,
              backgroundColor: tokens.elevated,
              centerWidget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$count',
                    style: AppTypography.tabularMetric(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: tokens.kineticAccent,
                    ),
                  ),
                  Text(
                    '/ $target',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      color: tokens.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacings.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WEEKLY ACTIVITY',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      color: tokens.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count == 0
                        ? 'Start your first workout!'
                        : count < target
                            ? '${target - count} more to reach goal'
                            : 'Weekly goal achieved!',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      color: tokens.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacings.md),
                  _WeekDayDots(workouts: weekWorkouts),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05);
  }
}

class _WeekDayDots extends StatelessWidget {
  const _WeekDayDots({required this.workouts});
  final List<Workout> workouts;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final workoutDates = workouts
        .map((w) => DateTime(w.date.year, w.date.month, w.date.day))
        .toSet();
    final tokens = context.tokens;

    return Row(
      children: days.map((day) {
        final hasWorkout = workoutDates.contains(DateTime(day.year, day.month, day.day));
        final isToday = day.day == now.day && day.month == now.month && day.year == now.year;
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasWorkout
                      ? tokens.kineticAccent
                      : isToday
                          ? tokens.elevated
                          : tokens.panel,
                  border: isToday
                      ? Border.all(color: tokens.kineticAccent, width: 1.5)
                      : Border.all(color: tokens.borderSubtle, width: 0.5),
                  boxShadow: hasWorkout
                      ? [
                          BoxShadow(
                            color: tokens.kineticAccent.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
                child: hasWorkout
                    ? const Icon(Icons.check, size: 14, color: Colors.black)
                    : isToday
                        ? Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: tokens.kineticAccent,
                              ),
                            ),
                          )
                        : null,
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('E').format(day).substring(0, 1),
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isToday
                      ? tokens.kineticAccent
                      : hasWorkout
                          ? tokens.textPrimary
                          : tokens.textMuted,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Today Summary Row ─────────────────────────────────────────────────────────

class _TodaySummaryRow extends StatelessWidget {
  const _TodaySummaryRow({
    required this.workouts,
    required this.profile,
  });
  final List<Workout> workouts;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final lastWorkout = workouts.isNotEmpty ? workouts.first : null;
    final lastDate = lastWorkout != null
        ? DateFormat('MMM d').format(lastWorkout.date)
        : 'None';
    final calories = profile?.dailyCalorieTarget.toInt() ?? 2000;
    final weight = profile?.weightKg.toStringAsFixed(1) ?? '--';
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.fitness_center,
              label: 'Last Workout',
              value: lastDate,
              color: tokens.cyanAccent,
            ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.05),
          ),
          const SizedBox(width: AppSpacings.sm),
          Expanded(
            child: _SummaryCard(
              icon: Icons.local_fire_department,
              label: 'Calories',
              value: '$calories kcal',
              color: tokens.warning,
            ).animate().fadeIn(delay: 200.ms),
          ),
          const SizedBox(width: AppSpacings.sm),
          Expanded(
            child: _SummaryCard(
              icon: Icons.monitor_weight_outlined,
              label: 'Weight',
              value: '${weight}kg',
              color: tokens.kineticAccent,
            ).animate().fadeIn(delay: 250.ms).slideX(begin: 0.05),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacings.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: AppSpacings.xs),
          Text(
            value,
            style: AppTypography.tabularMetric(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              color: tokens.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Today's Program Directive Card ──────────────────────────────────────────

class _TodayDirectiveCard extends ConsumerWidget {
  const _TodayDirectiveCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProgramAsync = ref.watch(activeProgramProvider);
    final tokens = context.tokens;

    return activeProgramAsync.when(
      data: (activeProgram) {
        if (activeProgram == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacings.lg, vertical: AppSpacings.xs),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacings.md),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: tokens.card,
                      shape: BoxShape.circle,
                      border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5)),
                    ),
                    child: Icon(Icons.fitness_center_rounded, color: tokens.kineticAccent, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NO ACTIVE PROTOCOL',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: tokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Initialize an AI training split or load a program.',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 11,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.workoutProgramSelection),
                    child: Text(
                      'SETUP',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontWeight: FontWeight.w800,
                        color: tokens.kineticAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final isRest = activeProgram.isRestDay;
        final currentDay = activeProgram.currentDay;

        if (isRest) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacings.lg, vertical: AppSpacings.xs),
            child: Container(
              padding: const EdgeInsets.all(AppSpacings.md),
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(color: tokens.cyanAccent.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tokens.cyanAccent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: tokens.cyanAccent.withValues(alpha: 0.4)),
                    ),
                    child: Icon(Icons.bedtime_outlined, color: tokens.cyanAccent, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'RECOVERY DIRECTIVE',
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: tokens.cyanAccent,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: tokens.cyanAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(tokens.radiusXs),
                              ),
                              child: Text(
                                'REST DAY',
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: tokens.cyanAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Deep tissue recovery & neural adaptation active. Prioritize hydration & sleep.',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 11,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Active workout day
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacings.lg, vertical: AppSpacings.xs),
          child: Container(
            padding: const EdgeInsets.all(AppSpacings.md),
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: tokens.kineticAccent.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flash_on_rounded, color: tokens.kineticAccent, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'TODAY\'S PROTOCOL DIRECTIVE',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: tokens.kineticAccent,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'DAY ${activeProgram.currentDayIndex + 1} OF ${activeProgram.program.days.length}',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currentDay.name.toUpperCase(),
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${currentDay.exercises.length} Exercises Scheduled · ${activeProgram.program.name}',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12,
                    color: tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 42,
                  width: double.infinity,
                  child: AppButton(
                    label: 'EXECUTE TODAY\'S DIRECTIVE',
                    variant: AppButtonVariant.primary,
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    onPressed: () async {
                      AppHaptics.shared.selectionChanged();
                      await ref.read(workoutNotifierProvider.notifier).start();
                      if (context.mounted) context.go(AppRoutes.workoutActive);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

// ── Daily Fuel Telemetry Summary Bar ────────────────────────────────────────

class _DailyFuelSummaryBar extends ConsumerWidget {
  final AsyncValue<UserProfile?> profileAsync;
  const _DailyFuelSummaryBar({required this.profileAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final now = DateTime.now();
    final nutritionAsync = ref.watch(dailyNutritionSummaryProvider(now));

    final targetCalories = profileAsync.valueOrNull?.dailyCalorieTarget ?? 2000.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacings.lg, vertical: AppSpacings.xs),
      child: InkWell(
        onTap: () {
          AppHaptics.shared.selectionChanged();
          context.go(AppRoutes.nutrition);
        },
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacings.md),
          decoration: BoxDecoration(
            color: tokens.card,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            border: Border.all(color: tokens.borderSubtle, width: 1),
          ),
          child: nutritionAsync.when(
            data: (summary) {
              final consumed = summary.totalCalories;
              final progress = (consumed / targetCalories).clamp(0.0, 1.0);
              final protein = summary.totalProtein.round();
              final carbs = summary.totalCarbs.round();
              final fats = summary.totalFats.round();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.restaurant_menu_rounded, color: tokens.warning, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'DAILY FUEL TELEMETRY',
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: tokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'OPEN FUEL DOCK',
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: tokens.kineticAccent,
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 14, color: tokens.kineticAccent),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${consumed.toInt()}',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: tokens.textPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        ' / ${targetCalories.toInt()} KCAL',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: tokens.textMuted,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: tokens.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: tokens.panel,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress > 0.95 ? tokens.kineticAccent : tokens.warning,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _FuelMacroChip(label: 'P', value: '${protein}g', color: tokens.cyanAccent, tokens: tokens),
                      const SizedBox(width: 8),
                      _FuelMacroChip(label: 'C', value: '${carbs}g', color: tokens.warning, tokens: tokens),
                      const SizedBox(width: 8),
                      _FuelMacroChip(label: 'F', value: '${fats}g', color: tokens.violetAccent, tokens: tokens),
                    ],
                  ),
                ],
              );
            },
            loading: () => SizedBox(
              height: 48,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: tokens.warning),
                ),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

class _FuelMacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final AppThemeTokens tokens;

  const _FuelMacroChip({
    required this.label,
    required this.value,
    required this.color,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(tokens.radiusXs),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontWeight: FontWeight.w900,
              fontSize: 10,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              color: tokens.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Workout Actions ───────────────────────────────────────────────────

class _QuickWorkoutActions extends ConsumerWidget {
  final List<Workout> workouts;
  const _QuickWorkoutActions({required this.workouts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasRecentWorkout = workouts.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.xs,
      ),
      child: hasRecentWorkout
          ? Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: AppButton(
                      label: 'QUICK START',
                      variant: AppButtonVariant.ghost,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      onPressed: () async {
                        AppHaptics.shared.selectionChanged();
                        await ref.read(workoutNotifierProvider.notifier).start(initialExercises: const []);
                        if (context.mounted) context.go(AppRoutes.workoutActive);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: AppButton(
                      label: 'REPEAT LAST',
                      variant: AppButtonVariant.secondary,
                      icon: const Icon(Icons.replay_rounded, size: 18),
                      onPressed: () async {
                        AppHaptics.shared.selectionChanged();
                        await ref.read(workoutNotifierProvider.notifier).repeatWorkout(workouts.first);
                        if (context.mounted) context.go(AppRoutes.workoutActive);
                      },
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(
              height: 48,
              width: double.infinity,
              child: AppButton(
                label: 'QUICK START EMPTY WORKOUT',
                variant: AppButtonVariant.primary,
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                onPressed: () async {
                  AppHaptics.shared.selectionChanged();
                  await ref.read(workoutNotifierProvider.notifier).start(initialExercises: const []);
                  if (context.mounted) context.go(AppRoutes.workoutActive);
                },
              ),
            ),
    );
  }
}

// ── Suggestion Card ───────────────────────────────────────────────────────────

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.workouts, required this.profile});
  final List<Workout> workouts;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final suggestion = _buildSuggestion(tokens);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.sm,
      ),
      child: AppCard(
        onTap: () => context.go(AppRoutes.workoutActive),
        padding: const EdgeInsets.all(AppSpacings.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tokens.elevated,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                border: Border.all(color: tokens.borderSubtle, width: 0.8),
              ),
              child: Icon(suggestion.icon, color: suggestion.color, size: 20),
            ),
            const SizedBox(width: AppSpacings.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      color: tokens.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    suggestion.body,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      color: tokens.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: tokens.textMuted, size: 12),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.05);
  }

  _SuggestionData _buildSuggestion(AppThemeTokens tokens) {
    if (workouts.isEmpty) {
      return _SuggestionData(
        icon: Icons.rocket_launch,
        color: tokens.kineticAccent,
        title: 'Start your journey!',
        body: 'Log your first workout to unlock telemetry progression tracking.',
      );
    }
    final daysSince = DateTime.now().difference(workouts.first.date).inDays;
    if (daysSince >= 3) {
      return _SuggestionData(
        icon: Icons.warning_amber_rounded,
        color: tokens.warning,
        title: 'Time to train!',
        body: 'It\'s been $daysSince days since your last workout. Keep the momentum!',
      );
    }
    if (profile?.goal == FitnessGoal.gainMuscle) {
      return _SuggestionData(
        icon: Icons.trending_up,
        color: tokens.cyanAccent,
        title: 'Progressive Overload',
        body: 'Try adding 2.5kg to your main lifts this session.',
      );
    }
    return _SuggestionData(
      icon: Icons.local_fire_department,
      color: tokens.warning,
      title: 'Stay consistent!',
      body: 'Great work! Keep showing up and results will follow.',
    );
  }
}

class _SuggestionData {
  const _SuggestionData({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String body;
}

// ── Recent Workout Card ───────────────────────────────────────────────────────

class _RecentWorkoutCard extends ConsumerWidget {
  const _RecentWorkoutCard({required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('EEE, MMM d').format(workout.date);
    final h = workout.duration.inHours;
    final m = workout.duration.inMinutes.remainder(60);
    final duration = h > 0 ? '${h}h ${m}m' : '${m}m';
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.sm,
      ),
      child: AppCard(
        onTap: () => context.go(AppRoutes.workout),
        padding: const EdgeInsets.all(AppSpacings.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LAST WORKOUT',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    color: tokens.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    color: tokens.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacings.sm),
            Text(
              '${workout.exercises.length} Exercises Completed',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                color: tokens.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacings.md),
            Row(
              children: [
                _WorkoutStat(
                  icon: Icons.fitness_center,
                  value: '${workout.totalVolume.toStringAsFixed(0)} kg',
                  label: 'Volume',
                  accentColor: tokens.cyanAccent,
                ),
                const SizedBox(width: AppSpacings.xl),
                _WorkoutStat(
                  icon: Icons.timer_outlined,
                  value: duration,
                  label: 'Duration',
                  accentColor: tokens.kineticAccent,
                ),
                const SizedBox(width: AppSpacings.xl),
                _WorkoutStat(
                  icon: Icons.repeat,
                  value: '${workout.exercises.fold<int>(0, (s, e) => s + e.sets.length)}',
                  label: 'Total Sets',
                  accentColor: tokens.violetAccent,
                ),
              ],
            ),
            const SizedBox(height: AppSpacings.md),
            SizedBox(
              height: 38,
              width: double.infinity,
              child: AppButton(
                label: 'REPEAT THIS WORKOUT',
                variant: AppButtonVariant.secondary,
                icon: const Icon(Icons.replay_rounded, size: 18),
                onPressed: () async {
                  AppHaptics.shared.selectionChanged();
                  await ref.read(workoutNotifierProvider.notifier).repeatWorkout(workout);
                  if (context.mounted) context.go(AppRoutes.workoutActive);
                },
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05);
  }
}

class _WorkoutStat extends StatelessWidget {
  const _WorkoutStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.accentColor,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: accentColor),
        const SizedBox(width: AppSpacings.xs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTypography.tabularMetric(
                color: tokens.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                color: tokens.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Loading States ────────────────────────────────────────────────────────────

class _LoadingWeeklyActivity extends StatelessWidget {
  const _LoadingWeeklyActivity();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.sm,
      ),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacings.lg),
        child: Row(
          children: [
            const AppShimmer(width: 82, height: 82, isCircle: true),
            const SizedBox(width: AppSpacings.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  AppShimmer(width: 120, height: 14),
                  SizedBox(height: AppSpacings.sm),
                  AppShimmer(width: 180, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSummaryRow extends StatelessWidget {
  const _LoadingSummaryRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.xs,
      ),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 4,
                right: index == 2 ? 0 : 4,
              ),
              child: const AppCard(
                padding: EdgeInsets.all(AppSpacings.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppShimmer(width: 20, height: 20, isCircle: true),
                    SizedBox(height: AppSpacings.xs),
                    AppShimmer(width: 50, height: 14),
                    SizedBox(height: 4),
                    AppShimmer(width: 40, height: 10),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _LoadingWorkoutCard extends StatelessWidget {
  const _LoadingWorkoutCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.sm,
      ),
      child: const AppCard(
        padding: EdgeInsets.all(AppSpacings.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppShimmer(width: 100, height: 12),
            SizedBox(height: AppSpacings.sm),
            AppShimmer(width: 160, height: 18),
            SizedBox(height: AppSpacings.md),
            Row(
              children: [
                AppShimmer(width: 60, height: 14),
                SizedBox(width: AppSpacings.lg),
                AppShimmer(width: 60, height: 14),
                SizedBox(width: AppSpacings.lg),
                AppShimmer(width: 60, height: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error States ──────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.sm,
      ),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacings.xl),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: tokens.error, size: 44),
            const SizedBox(height: AppSpacings.md),
            Text(
              message,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                color: tokens.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacings.lg),
            AppButton(
              label: 'Retry',
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty States ──────────────────────────────────────────────────────────────

class _EmptyWorkoutCard extends StatelessWidget {
  const _EmptyWorkoutCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.sm,
      ),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacings.xl),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center_outlined,
              color: tokens.textMuted,
              size: 44,
            ),
            const SizedBox(height: AppSpacings.md),
            Text(
              'No workouts logged yet',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                color: tokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete your first workout session to view telemetry stats here.',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                color: tokens.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05);
  }
}

class _ProfileSetupPrompt extends StatelessWidget {
  const _ProfileSetupPrompt();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.sm,
      ),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacings.xl),
        child: Column(
          children: [
            Icon(Icons.person_outline, color: tokens.kineticAccent, size: 44),
            const SizedBox(height: AppSpacings.md),
            Text(
              'Complete your profile',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                color: tokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Set your weekly workout goal to track your telemetry progress.',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                color: tokens.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05);
  }
}
