import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/shared/presentation/components/components.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

// ── Quick Workout Actions ───────────────────────────────────────────────────

class QuickWorkoutActions extends ConsumerWidget {
  final List<Workout> workouts;
  const QuickWorkoutActions({super.key, required this.workouts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final hasRecentWorkout = workouts.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.xs,
      ),
      child: Row(
        children: [
          // 1. Quick Start
          Expanded(
            child: AnimatedScaleButton(
              onPressed: () async {
                AppHaptics.shared.selectionChanged();
                await ref.read(workoutNotifierProvider.notifier).start(initialExercises: const []);
                if (context.mounted) context.go(AppRoutes.workoutActive);
              },
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: tokens.elevated,
                  borderRadius: BorderRadius.circular(tokens.radiusLg),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 16, color: tokens.kineticAccent),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'START',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 2. Log Fuel
          Expanded(
            child: AnimatedScaleButton(
              onPressed: () {
                AppHaptics.shared.selectionChanged();
                context.go(AppRoutes.nutrition);
              },
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: tokens.elevated,
                  borderRadius: BorderRadius.circular(tokens.radiusLg),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.restaurant_menu_rounded, size: 15, color: tokens.warning),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'FUEL',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // 3. Repeat Last / Programs
          Expanded(
            child: AnimatedScaleButton(
              onPressed: () async {
                AppHaptics.shared.selectionChanged();
                if (hasRecentWorkout) {
                  await ref.read(workoutNotifierProvider.notifier).repeatWorkout(workouts.first);
                  if (context.mounted) context.go(AppRoutes.workoutActive);
                } else {
                  context.go(AppRoutes.workoutProgramSelection);
                }
              },
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: tokens.elevated,
                  borderRadius: BorderRadius.circular(tokens.radiusLg),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasRecentWorkout ? Icons.replay_rounded : Icons.tune_rounded,
                      size: 15,
                      color: tokens.cyanAccent,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        hasRecentWorkout ? 'REPEAT' : 'PLANS',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Suggestion Card ───────────────────────────────────────────────────────────

class HomeSuggestionCard extends StatelessWidget {
  const HomeSuggestionCard({super.key, required this.workouts, required this.profile});
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
        body: 'Log your first workout to start tracking your progress.',
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

class RecentWorkoutCard extends ConsumerWidget {
  const RecentWorkoutCard({super.key, required this.workout});
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
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
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
            Wrap(
              spacing: AppSpacings.lg,
              runSpacing: AppSpacings.xs,
              children: [
                _WorkoutStat(
                  icon: Icons.fitness_center,
                  value: '${workout.totalVolume.toStringAsFixed(0)} kg',
                  label: 'Volume',
                  accentColor: tokens.cyanAccent,
                ),
                _WorkoutStat(
                  icon: Icons.timer_outlined,
                  value: duration,
                  label: 'Duration',
                  accentColor: tokens.kineticAccent,
                ),
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

class LoadingWeeklyActivity extends StatelessWidget {
  const LoadingWeeklyActivity({super.key});

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

class LoadingSummaryRow extends StatelessWidget {
  const LoadingSummaryRow({super.key});

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

class LoadingWorkoutCard extends StatelessWidget {
  const LoadingWorkoutCard({super.key});

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

class HomeErrorCard extends StatelessWidget {
  const HomeErrorCard({
    super.key,
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

class EmptyWorkoutCard extends StatelessWidget {
  const EmptyWorkoutCard({super.key});

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
              'Complete your first workout session to view your stats here.',
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

class ProfileSetupPrompt extends StatelessWidget {
  const ProfileSetupPrompt({super.key});

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
              'Set your weekly workout goal to track your progress.',
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
