import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/presentation/components/components.dart';
import '../../../../shared/widgets/ironflow_logo.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../ai/presentation/widgets/ai_coach_hero_card.dart';
import '../../../ai/presentation/widgets/ai_entry_button.dart';
import '../../domain/entities/workout.dart';
import '../providers/home_workout_provider.dart';

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
            // Refresh both providers
            ref.invalidate(homeWorkoutDataProvider);
            ref.invalidate(userProfileProvider);
            // Wait for data to load
            await Future.wait([
              ref.read(homeWorkoutDataProvider.future),
              ref.read(userProfileProvider.future),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header - always visible
              SliverToBoxAdapter(
                child: _HomeHeader(profileAsync: profileAsync),
              ),

              // Weekly Activity Section
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

              // AI Coach Hero Card
              const SliverToBoxAdapter(
                child: AiCoachHeroCard(),
              ),

              // Today Summary Row
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

              // Start Workout CTA
              const SliverToBoxAdapter(child: _StartWorkoutCTA()),

              // Suggestion Card
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

              // Recent Workout Card
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
            label: 'Open Profile',
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: InkWell(
                onTap: () => context.go(AppRoutes.profile),
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
          const SizedBox(width: AppSpacings.xs),
          Consumer(
            builder: (context, ref, child) {
              return Semantics(
                button: true,
                label: 'Toggle Light and Dark Theme',
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  child: InkWell(
                    onTap: () {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
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
                        child: Icon(
                          tokens.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                          color: tokens.kineticAccent,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.05);
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

// ── Start Workout CTA ─────────────────────────────────────────────────────────

class _StartWorkoutCTA extends StatelessWidget {
  const _StartWorkoutCTA();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacings.lg,
        AppSpacings.md,
        AppSpacings.lg,
        AppSpacings.sm,
      ),
      child: Semantics(
        button: true,
        label: 'Start Workout',
        child: InkWell(
          onTap: () => context.go(AppRoutes.workoutActive),
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: tokens.kineticAccent,
              borderRadius: BorderRadius.circular(tokens.radiusSm),
              boxShadow: [
                BoxShadow(
                  color: tokens.kineticAccent.withValues(
                    alpha: tokens.isDark ? 0.35 : 0.2,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 26),
                const SizedBox(width: AppSpacings.sm),
                Text(
                  'START WORKOUT',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.97, 0.97));
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

class _RecentWorkoutCard extends StatelessWidget {
  const _RecentWorkoutCard({required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
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
