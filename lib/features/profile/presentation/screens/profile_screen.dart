import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/components/app_button.dart';
import '../../../ai/domain/entities/insight.dart';
import '../../../ai/presentation/widgets/ai_entry_button.dart';
import '../../../ai/presentation/widgets/contextual_insight_banner.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../nutrition/domain/entities/diet_plan.dart';
import '../../../nutrition/domain/usecases/generate_diet_plan_use_case.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../workout/domain/entities/workout_program.dart';
import '../../../workout/domain/usecases/generate_workout_program_use_case.dart';

/// Monolithic Sci-Fi Profile & Settings screen.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        backgroundColor: tokens.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PROFILE',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: tokens.textPrimary,
              ),
            ),
            Text(
              'BIOMETRIC ID & DIRECTIVES',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: tokens.textMuted,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        actions: [
          const AiEntryButton(),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: profileAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: tokens.kineticAccent),
          ),
          error: (error, _) => Center(
            child: Text(
              'Error loading profile telemetry: $error',
              style: TextStyle(color: tokens.error),
            ),
          ),
          data: (profile) => profile == null
              ? _NoProfileView(tokens: tokens)
              : _ProfileBody(profile: profile, tokens: tokens),
        ),
      ),
    );
  }
}

class _NoProfileView extends StatelessWidget {
  const _NoProfileView({required this.tokens});
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.radiusLg),
                border: Border.all(color: tokens.borderSubtle, width: 1),
              ),
              child: Icon(Icons.person_outline, size: 48, color: tokens.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              'NO PROFILE DETECTED',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Calibrate biometric telemetry to initialize personalized AI protocols.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13,
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'INITIALIZE ONBOARDING',
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              onPressed: () => context.go(AppRoutes.onboarding),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile, required this.tokens});
  final UserProfile profile;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = GenerateWorkoutProgramUseCase().call(userProfile: profile);
    final dietPlan = GenerateDietPlanUseCase().call(profile);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _ProfileHeader(profile: profile, tokens: tokens)),
        SliverToBoxAdapter(child: _StatsRow(profile: profile, tokens: tokens)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ContextualInsightBanner(context: InsightContext.profile),
          ),
        ),
        SliverToBoxAdapter(
          child: _GoalCard(profile: profile, program: program, tokens: tokens),
        ),
        SliverToBoxAdapter(
          child: _DietPlanCard(dietPlan: dietPlan, tokens: tokens),
        ),
        SliverToBoxAdapter(
          child: _DietTipsCard(tips: dietPlan.tips, tokens: tokens),
        ),
        SliverToBoxAdapter(
          child: _SettingsSection(ref: ref, tokens: tokens),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile, required this.tokens});
  final UserProfile profile;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderSubtle, width: 1),
        ),
        child: Row(
          children: [
            // Monolithic Avatar Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: tokens.card,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                border: Border.all(color: tokens.borderSubtle, width: 1),
              ),
              child: Center(
                child: Text(
                  profile.goal.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.goal.displayName.toUpperCase(),
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      color: tokens.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile.fitnessLevel.displayName.toUpperCase()} · ${profile.equipment.displayName.toUpperCase()}',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      color: tokens.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tokens.kineticAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      border: Border.all(
                        color: tokens.kineticAccent.withValues(alpha: 0.35),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${profile.workoutDaysPerWeek} DAYS / WEEK PROTOCOL',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        color: tokens.kineticAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms);
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile, required this.tokens});
  final UserProfile profile;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'AGE',
              value: '${profile.age}',
              unit: 'YRS',
              color: tokens.cyanAccent,
              tokens: tokens,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'WEIGHT',
              value: profile.weightKg.toStringAsFixed(1),
              unit: 'KG',
              color: tokens.kineticAccent,
              tokens: tokens,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'HEIGHT',
              value: profile.heightCm.toStringAsFixed(0),
              unit: 'CM',
              color: tokens.violetAccent,
              tokens: tokens,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'BMI',
              value: profile.bmi.toStringAsFixed(1),
              unit: 'INDEX',
              color: _bmiColor(profile.bmi),
              tokens: tokens,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 80.ms);
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return tokens.cyanAccent;
    if (bmi < 25) return tokens.kineticAccent;
    if (bmi < 30) return tokens.warning;
    return tokens.error;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.tokens,
  });

  final String label;
  final String value;
  final String unit;
  final Color color;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              color: tokens.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              color: tokens.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Goal Card ─────────────────────────────────────────────────────────────────

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.profile,
    required this.program,
    required this.tokens,
  });

  final UserProfile profile;
  final WorkoutProgram program;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderSubtle, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'WORKOUT PROGRAM',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: tokens.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tokens.card,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(color: tokens.borderSubtle, width: 1),
                  ),
                  child: Text(
                    'ACTIVE PROTOCOL',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: tokens.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              program.name,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                color: tokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              program.description,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                color: tokens.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _PlanChip(
                  icon: Icons.calendar_today_rounded,
                  label: '${program.durationWeeks} WEEKS',
                  tokens: tokens,
                ),
                _PlanChip(
                  icon: Icons.fitness_center_rounded,
                  label: program.difficulty.toUpperCase(),
                  tokens: tokens,
                ),
                _PlanChip(
                  icon: Icons.repeat_rounded,
                  label: '${profile.workoutDaysPerWeek}X / WEEK',
                  tokens: tokens,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 150.ms);
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({
    required this.icon,
    required this.label,
    required this.tokens,
  });

  final IconData icon;
  final String label;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: tokens.kineticAccent),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              color: tokens.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Diet Plan Card ────────────────────────────────────────────────────────────

class _DietPlanCard extends StatelessWidget {
  const _DietPlanCard({required this.dietPlan, required this.tokens});
  final DietPlan dietPlan;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    final totalMacros = dietPlan.proteinG + dietPlan.carbsG + dietPlan.fatsG;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderSubtle, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'NUTRITION PROTOCOL',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: tokens.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tokens.card,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(color: tokens.borderSubtle, width: 1),
                  ),
                  child: Text(
                    '${dietPlan.dailyCalories.toInt()} KCAL / DAY',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      color: tokens.kineticAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              dietPlan.name,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                color: tokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            _MacroBar(
              label: 'PROTEIN',
              value: dietPlan.proteinG,
              total: totalMacros,
              color: tokens.kineticAccent,
              unit: 'G',
              tokens: tokens,
            ),
            const SizedBox(height: 8),
            _MacroBar(
              label: 'CARBS',
              value: dietPlan.carbsG,
              total: totalMacros,
              color: tokens.cyanAccent,
              unit: 'G',
              tokens: tokens,
            ),
            const SizedBox(height: 8),
            _MacroBar(
              label: 'FATS',
              value: dietPlan.fatsG,
              total: totalMacros,
              color: tokens.violetAccent,
              unit: 'G',
              tokens: tokens,
            ),
            const SizedBox(height: 18),
            Text(
              'SAMPLE CYCLE MEALS',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: tokens.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            if (dietPlan.days.isNotEmpty)
              ...dietPlan.days.first.meals
                  .map((meal) => _MealRow(meal: meal, tokens: tokens)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.value,
    required this.total,
    required this.color,
    required this.unit,
    required this.tokens,
  });

  final String label;
  final double value;
  final double total;
  final Color color;
  final String unit;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              color: tokens.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: tokens.card,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 50,
          child: Text(
            '${value.toInt()} $unit',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.meal, required this.tokens});
  final DietMeal meal;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      child: Row(
        children: [
          Text(meal.mealType.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    color: tokens.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  meal.ingredients.take(3).join(', '),
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    color: tokens.textMuted,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${meal.calories.toInt()} KCAL',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              color: tokens.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Diet Tips ─────────────────────────────────────────────────────────────────

class _DietTipsCard extends StatelessWidget {
  const _DietTipsCard({required this.tips, required this.tokens});
  final List<String> tips;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderSubtle, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'OPERATIONAL DIRECTIVES / NUTRITION',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: tokens.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tokens.kineticAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tip,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            color: tokens.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 250.ms);
  }
}

// ── Settings Section ──────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.ref, required this.tokens});
  final WidgetRef ref;
  final AppThemeTokens tokens;

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          side: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        icon: Icon(
          Icons.logout_rounded,
          size: 40,
          color: tokens.error,
        ),
        title: Text(
          'TERMINATE SESSION',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: tokens.textPrimary,
          ),
        ),
        content: Text(
          'Confirm session termination. All local encrypted records and cache are safely stored and synced upon reactivation.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 13,
            color: tokens.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontWeight: FontWeight.w700,
                      color: tokens.textMuted,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AppButton(
                  label: 'LOGOUT',
                  onPressed: () async {
                    final rootNavigator =
                        Navigator.of(context, rootNavigator: true);
                    final router = GoRouter.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    rootNavigator.pop();

                    bool dialogOpen = true;
                    showDialog(
                      context: context,
                      useRootNavigator: true,
                      barrierDismissible: false,
                      builder: (dialogContext) => AlertDialog(
                        backgroundColor: tokens.panel,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(tokens.radiusMd),
                          side: BorderSide(color: tokens.borderSubtle, width: 1),
                        ),
                        content: Row(
                          children: [
                            CircularProgressIndicator(
                              color: tokens.kineticAccent,
                            ),
                            const SizedBox(width: 18),
                            Text(
                              'Terminating session...',
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                color: tokens.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).then((_) {
                      dialogOpen = false;
                    });

                    void dismissLoadingDialog() {
                      if (dialogOpen) {
                        dialogOpen = false;
                        rootNavigator.pop();
                      }
                    }

                    try {
                      await ref
                          .read(authNotifierProvider.notifier)
                          .signOut()
                          .timeout(const Duration(seconds: 3));

                      dismissLoadingDialog();
                      router.go('/login');
                    } on TimeoutException {
                      dismissLoadingDialog();
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: const Text(
                              'Logout is taking longer than expected. Redirecting...'),
                          backgroundColor: tokens.warning,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      router.go('/login');
                    } catch (e) {
                      dismissLoadingDialog();
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text('Logout error: ${e.toString()}'),
                          backgroundColor: tokens.error,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    _showDocumentDialog(
      context,
      title: 'TERMS OF SERVICE',
      content: '''By using IronFlow, you agree to the following terms:

1. ACCEPTANCE OF TERMS
By downloading, installing, or using IronFlow, you agree to be bound by these Terms of Service.

2. HEALTH DISCLAIMER
IronFlow is NOT a medical device and does NOT provide medical advice. Always consult with a healthcare professional before starting any fitness or nutrition program.

3. USER RESPONSIBILITIES
- You are responsible for assessing your fitness level
- Use proper form and technique during exercises
- Listen to your body and stop if you feel pain
- Ensure a safe workout environment

4. AI COACH LIMITATIONS
Our AI-powered fitness coach provides general guidance only and should not replace professional coaching or medical advice.

5. DATA AND PRIVACY
- We do NOT sell your personal data
- Your workout data is stored securely
- You can export or delete your data anytime
- We use encryption to protect your information

6. ACCEPTABLE USE
You agree to use the app for lawful purposes only and not to:
- Violate any laws or regulations
- Attempt to hack or compromise the app
- Harass, abuse, or harm others

7. LIMITATION OF LIABILITY
IronFlow shall not be liable for any indirect, incidental, or consequential damages arising from use of the app.

For the complete Terms of Service, visit:
https://ironflow.app/terms

Last Updated: May 13, 2026''',
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    _showDocumentDialog(
      context,
      title: 'PRIVACY POLICY',
      content: '''IronFlow Privacy Policy

INFORMATION WE COLLECT
- Account info: Email, name, password
- Profile data: Age, gender, fitness goals
- Usage data: Workouts, nutrition logs, progress

HOW WE USE YOUR DATA
- Provide and maintain the app
- Store your workout and nutrition data
- Sync data across devices
- Provide AI-powered coaching
- Improve app features

DATA STORAGE & SECURITY
- Local storage on your device (Hive)
- Cloud storage via Firebase (if enabled)
- Encrypted in transit and at rest
- Industry-standard security measures

WE DO NOT SELL YOUR DATA
We do not sell, trade, or rent your personal information to third parties.

YOUR RIGHTS
- Access and view your data
- Update your profile anytime
- Delete your account and data
- Export your workout data
- Use the app offline

THIRD-PARTY SERVICES
- Google Firebase (storage, auth, analytics)
- Google Gemini AI (coaching)
- Google Sign-In / Apple Sign-In

CHILDREN'S PRIVACY
IronFlow is not intended for children under 13.

DATA RETENTION
- Active accounts: Data retained while active
- Deleted accounts: Data deleted within 30 days

CONTACT US
Email: privacy@ironflow.app
Website: https://ironflow.app/privacy

Last Updated: May 13, 2026''',
    );
  }

  void _showDocumentDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          side: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: tokens.textPrimary,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              content,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 12,
                color: tokens.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CLOSE',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontWeight: FontWeight.w700,
                color: tokens.kineticAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SYSTEM & PREFERENCES',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Column(
              children: [
                // Logout Tile (Red)
                ListTile(
                  leading: Icon(
                    Icons.logout_rounded,
                    color: tokens.error,
                    size: 20,
                  ),
                  title: Text(
                    'TERMINATE SESSION',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      color: tokens.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: tokens.error,
                    size: 14,
                  ),
                  onTap: () => _showLogoutDialog(context),
                  dense: true,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                if (kDebugMode) ...[
                  _SettingsTile(
                    icon: Icons.bug_report_outlined,
                    label: 'AI Diagnostic Test (Debug Only)',
                    onTap: () => context.push(AppRoutes.aiTest),
                    tokens: tokens,
                  ),
                  Divider(color: tokens.borderSubtle, height: 1),
                  _SettingsTile(
                    icon: Icons.palette_outlined,
                    label: 'Design System Gallery (Debug Only)',
                    onTap: () => context.push(AppRoutes.designGallery),
                    tokens: tokens,
                  ),
                  Divider(color: tokens.borderSubtle, height: 1),
                ],
                // Theme Toggle
                ListTile(
                  leading: Icon(
                    isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    color: tokens.kineticAccent,
                    size: 20,
                  ),
                  title: Text(
                    isDark ? 'LIGHT MODE' : 'DARK MODE',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      color: tokens.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (_) {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                    activeColor: tokens.kineticAccent,
                  ),
                  dense: true,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _SettingsTile(
                  icon: Icons.edit_rounded,
                  label: 'Edit Profile & Goals',
                  onTap: () => context.go(AppRoutes.onboarding),
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _SettingsTile(
                  icon: Icons.history_rounded,
                  label: 'Workout History',
                  onTap: () => context.go(AppRoutes.workoutHistory),
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _SettingsTile(
                  icon: Icons.search_rounded,
                  label: 'Exercise Catalog',
                  onTap: () => context.go(AppRoutes.workoutCatalog),
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _SettingsTile(
                  icon: Icons.settings_outlined,
                  label: 'System Settings & Data',
                  onTap: () => context.push(AppRoutes.settings),
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  label: 'Reminder Settings',
                  onTap: () => context.go(AppRoutes.reminderSettings),
                  tokens: tokens,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Legal Section
          Text(
            'LEGAL & COMPLIANCE',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.description_outlined,
                  label: 'Terms of Service',
                  onTap: () => _showTermsOfService(context),
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () => _showPrivacyPolicy(context),
                  tokens: tokens,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Documentation & Audits Section
          Text(
            'SYSTEM AUDITS & TELEMETRY',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: tokens.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: tokens.panel,
              borderRadius: BorderRadius.circular(tokens.radiusMd),
              border: Border.all(color: tokens.borderSubtle, width: 1),
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.analytics_outlined,
                  label: 'Current State Audit Report',
                  onTap: () => _showDocumentDialog(
                    context,
                    title: 'CURRENT STATE AUDIT REPORT',
                    content: '''CURRENT STATE AUDIT REPORT

This audit provides a comprehensive analysis of IronFlow's current implementation status.

KEY FINDINGS:
✅ Core Features: 100% Complete
✅ Firebase Integration: Complete
✅ AI Coach: Fully Functional
✅ Analytics: 30+ Events Tracked
✅ Navigation: All Bugs Fixed
✅ Terms Acceptance: Implemented

TECHNICAL STACK:
- Flutter 3.10.7
- Firebase (Auth, Firestore, Analytics, Crashlytics)
- Google Gemini AI
- Riverpod State Management
- Go Router Navigation

QUALITY METRICS:
- Code Quality: High
- Test Coverage: 90%
- Performance: Good
- User Experience: Professional

STATUS: Production Ready ✅

For full report, see: CURRENT_STATE_AUDIT_REPORT.md''',
                  ),
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _SettingsTile(
                  icon: Icons.assessment_outlined,
                  label: 'Product Audit Report',
                  onTap: () => _showDocumentDialog(
                    context,
                    title: 'PRODUCT AUDIT REPORT',
                    content: '''BRUTAL PRODUCT AUDIT

An honest assessment of IronFlow's strengths and areas for improvement.

STRENGTHS:
✅ Comprehensive Feature Set
✅ AI-Powered Coaching (FREE!)
✅ Offline-First Architecture
✅ Clean, Modern UI
✅ Professional Code Quality

AREAS FOR IMPROVEMENT:
⚠️ AI Response Time (37s - optimization opportunity)
⚠️ Loading Skeletons (optional enhancement)
⚠️ App Icon (needs design)
⚠️ Screenshots (needs capture)

COMPETITIVE ADVANTAGES:
- 100% Free (no subscriptions)
- AI Coach included
- Voice-guided workouts
- Privacy-focused
- Data ownership

MARKET POSITION:
Strong competitor to MyFitnessPal, Fitbod, and Strong.

For full report, see: BRUTAL_PRODUCT_AUDIT.md''',
                  ),
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _SettingsTile(
                  icon: Icons.smart_toy_outlined,
                  label: 'AI & Notifications Audit',
                  onTap: () => _showDocumentDialog(
                    context,
                    title: 'AI & NOTIFICATIONS AUDIT REPORT',
                    content: '''AI AND NOTIFICATIONS AUDIT REPORT

Comprehensive audit of AI features and notification system.

AI COACH STATUS:
✅ Google Gemini Integration: Working
✅ Context-Aware Responses: Implemented
✅ Workout Analysis: Functional
✅ Nutrition Guidance: Available
✅ Voice Personas: 9 Options
✅ TTS Integration: Working

NOTIFICATIONS STATUS:
✅ Local Notifications: Implemented
✅ Workout Reminders: Functional
✅ Streak Tracking: Working
✅ Permission Handling: Proper
✅ Scheduling: Reliable

PERFORMANCE:
- AI Response Time: 37s (acceptable)
- Notification Delivery: Instant
- TTS Quality: Good
- Voice Speed: Adjustable

For full report, see: AI_AND_NOTIFICATIONS_AUDIT_REPORT.md''',
                  ),
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _SettingsTile(
                  icon: Icons.rocket_launch_outlined,
                  label: 'Phase 1 Implementation Plan',
                  onTap: () => _showDocumentDialog(
                    context,
                    title: 'PHASE 1 IMPLEMENTATION PLAN',
                    content: '''PHASE 1: CRITICAL FEATURES IMPLEMENTATION

Goal: Get IronFlow ready for App Store/Play Store submission
Timeline: 1-2 weeks
Status: 99% COMPLETE ✅

COMPLETED:
✅ REST TIMER - Fully integrated
✅ Firebase Crashlytics - Production ready
✅ Firebase Analytics - 30+ events tracked
✅ Navigation System - All bugs fixed
✅ Web Platform - Running smoothly
✅ Android APK - Built and ready (170MB)
✅ Empty States - Improved UX
✅ Terms Acceptance - Complete!

REMAINING (1%):
1. Legal Document Hosting (30 min)
2. App Icon Design (2-4 hours)
3. App Screenshots (3-4 hours)

TIMELINE TO APP STORE:
- This Week: Legal hosting, icon design
- Next Week: Screenshots, final testing
- Week 3: App Store submission 🎉

For full plan, see: PHASE_1_IMPLEMENTATION_PLAN.md''',
                  ),
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _SettingsTile(
                  icon: Icons.check_circle_outline,
                  label: 'Terms Acceptance Implementation',
                  onTap: () => _showDocumentDialog(
                    context,
                    title: 'TERMS ACCEPTANCE IMPLEMENTATION',
                    content: '''TERMS ACCEPTANCE IMPLEMENTATION

Status: ✅ COMPLETE & PRODUCTION READY

FEATURES IMPLEMENTED:
✅ Mandatory checkbox in sign-up form
✅ Clickable Terms of Service link
✅ Clickable Privacy Policy link
✅ Validation before sign-up
✅ Warning messages
✅ Professional UI design

APP STORE COMPLIANCE:
✅ Apple App Store requirements met
✅ Google Play Store requirements met
✅ GDPR compliance (explicit consent)
✅ CCPA compliance (data rights)

USER EXPERIENCE:
- Clear checkbox with state management
- Highlighted border when checked
- Full-screen dialogs with scrollable content
- Theme-aware styling (light/dark mode)

VALIDATION:
- Email sign-up blocked without acceptance
- Google sign-up blocked without acceptance
- Clear warning message displayed

For full report, see: TERMS_ACCEPTANCE_IMPLEMENTED.md''',
                  ),
                  tokens: tokens,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.tokens,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: tokens.kineticAccent, size: 20),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          color: tokens.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: tokens.textMuted,
        size: 13,
      ),
      onTap: onTap,
      dense: true,
    );
  }
}
