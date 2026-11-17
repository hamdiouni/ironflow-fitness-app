import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/shared/presentation/components/components.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';
import 'package:progression_tracker/features/body/presentation/providers/body_map_providers.dart';

// ── Hero Readiness Banner (Direction 4) ──────────────────────────────────────

class HeroReadinessBanner extends ConsumerWidget {
  const HeroReadinessBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final readinessScore = ref.watch(overallBodyReadinessProvider);
    final percentInt = (readinessScore * 100).round();

    final String tierLabel;
    final String tierTitle;
    final String tierSubtitle;
    final Color tierColor;

    if (readinessScore >= 0.85) {
      tierLabel = 'PRIMED';
      tierTitle = 'Optimal Recovery';
      tierSubtitle = 'CNS and muscles primed for heavy compound lifts.';
      tierColor = tokens.kineticAccent;
    } else if (readinessScore >= 0.65) {
      tierLabel = 'RECOVERING';
      tierTitle = 'Moderate Fatigue';
      tierSubtitle = 'Good recovery state. Moderate to heavy volume suitable.';
      tierColor = tokens.cyanAccent;
    } else {
      tierLabel = 'FATIGUED';
      tierTitle = 'High Muscle Fatigue';
      tierSubtitle = 'Muscles need recovery. Consider light accessory or rest.';
      tierColor = tokens.warning;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacings.lg,
        vertical: AppSpacings.xs,
      ),
      child: AppCard(
        isGlowing: false,
        padding: const EdgeInsets.all(AppSpacings.md + 2),
        onTap: () {
          AppHaptics.shared.selectionChanged();
          context.go('${AppRoutes.progress}?tab=bodymap');
        },
        child: Row(
          children: [
            LiveMacroRing(
              progress: readinessScore,
              size: 58,
              strokeWidth: 6,
              primaryColor: tierColor,
              backgroundColor: tokens.elevated,
              centerChild: Text(
                '$percentInt%',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: tierColor,
                ),
              ),
            ),
            const SizedBox(width: AppSpacings.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          tierTitle,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: tokens.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tierColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(tokens.radiusPill),
                        ),
                        child: Text(
                          tierLabel,
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: tierColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tierSubtitle,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      color: tokens.textSecondary,
                      fontSize: 11.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: tokens.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.04);
  }
}

class TodayDirectiveCard extends ConsumerWidget {
  const TodayDirectiveCard({super.key});

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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: tokens.kineticAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(tokens.radiusPill),
                          ),
                          child: Text(
                            'TODAY\'S FOCUS',
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              color: tokens.kineticAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => context.go(AppRoutes.workoutProgramSelection),
                          icon: Icon(Icons.tune_rounded, size: 14, color: tokens.kineticAccent),
                          label: Text(
                            'SELECT PROGRAM',
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: tokens.kineticAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Full Body Training Session',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Open workout session • Log sets with live rest timer',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 12,
                      color: tokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 46,
                    width: double.infinity,
                    child: AppButton(
                      label: "START TODAY'S WORKOUT",
                      variant: AppButtonVariant.primary,
                      icon: const Icon(Icons.play_arrow_rounded, size: 20),
                      onPressed: () async {
                        AppHaptics.shared.selectionChanged();
                        await ref.read(workoutNotifierProvider.notifier).start(initialExercises: const []);
                        if (context.mounted) context.go(AppRoutes.workoutActive);
                      },
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
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacings.md),
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
                              'REST DAY',
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
                          'Rest and recovery day. Prioritize hydration, nutrition, and good sleep.',
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
          child: AppCard(
            padding: const EdgeInsets.all(AppSpacings.md),
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
                          'TODAY\'S WORKOUT',
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
                    label: 'START TODAY\'S WORKOUT',
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

class DailyFuelSummaryBar extends ConsumerWidget {
  final AsyncValue<UserProfile?> profileAsync;
  const DailyFuelSummaryBar({super.key, required this.profileAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    // The family is keyed by the yyyy-MM-dd day string (Phase 3), so this
    // widget shares the exact same provider instance/notifier as
    // NutritionScreen by construction. The old DateTime key let raw
    // DateTime.now() (with time-of-day) create a new, disconnected
    // notifier. See F-07 in docs/architecture/DATABASE_AND_SYNC_AUDIT.md.
    final nutritionAsync =
        ref.watch(dailyNutritionSummaryProvider(todayNutritionDayKey()));

    final targetCalories = profileAsync.valueOrNull?.dailyCalorieTarget ??
        UserProfileDefaults.referenceProfile.dailyCalorieTarget;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacings.lg, vertical: AppSpacings.xs),
      child: AppCard(
        onTap: () {
          AppHaptics.shared.selectionChanged();
          context.go(AppRoutes.nutrition);
        },
        padding: const EdgeInsets.all(AppSpacings.md),
        child: nutritionAsync.when(
          data: (summary) {
            final consumed = summary.totalCalories;
            final progress = (consumed / targetCalories).clamp(0.0, 1.0);
            final protein = summary.totalProtein.round();
            final carbs = summary.totalCarbs.round();
            final fats = summary.totalFats.round();

            return Row(
              children: [
                LiveMacroRing(
                  progress: progress,
                  size: 60,
                  strokeWidth: 6,
                  primaryColor: progress > 0.95 ? tokens.kineticAccent : tokens.warning,
                  backgroundColor: tokens.elevated,
                  centerChild: Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: tokens.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacings.md),
                Expanded(
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
                              'DAILY FUEL',
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: tokens.textMuted,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'VIEW FUEL',
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
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          Text(
                            '${consumed.toInt()}',
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: tokens.textPrimary,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          Text(
                            ' / ${targetCalories.toInt()} KCAL',
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: tokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _FuelMacroChip(label: 'P', value: '${protein}g', color: tokens.cyanAccent, tokens: tokens),
                          _FuelMacroChip(label: 'C', value: '${carbs}g', color: tokens.warning, tokens: tokens),
                          _FuelMacroChip(label: 'F', value: '${fats}g', color: tokens.violetAccent, tokens: tokens),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => SizedBox(
            height: 60,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: tokens.warning),
              ),
            ),
          ),
          error: (_, _) => const SizedBox.shrink(),
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

