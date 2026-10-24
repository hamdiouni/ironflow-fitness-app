import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/presentation/components/app_button.dart';
import '../../../ai/domain/entities/insight.dart';
import '../../../ai/presentation/widgets/ai_entry_button.dart';
import '../../../ai/presentation/widgets/contextual_insight_banner.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../nutrition/domain/entities/diet_plan.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../providers/profile_data_provider.dart';

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
              'PROFILE & WORKOUT PLAN',
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
              'NO PROFILE FOUND',
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
              'Set up your body stats to personalize your workout and nutrition plans.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13,
                color: tokens.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'START SETUP',
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
    // Everything below is derived from this user's real records
    // (account, body entries, workouts, active program, saved diet
    // plan/targets, today's meals) — see profile_data_provider.dart.
    // Nothing is regenerated or hardcoded per build anymore.
    final data = ref.watch(profileDataProvider) ??
        buildProfileData(profile: profile);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _ProfileHeader(data: data, tokens: tokens)),
        SliverToBoxAdapter(child: _StatsRow(data: data, tokens: tokens)),
        SliverToBoxAdapter(child: _ActivityRow(data: data, tokens: tokens)),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ContextualInsightBanner(context: InsightContext.profile),
          ),
        ),
        SliverToBoxAdapter(
          child: _GoalCard(data: data, tokens: tokens),
        ),
        SliverToBoxAdapter(
          child: _DietPlanCard(data: data, tokens: tokens),
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
  const _ProfileHeader({required this.data, required this.tokens});
  final ProfileData data;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    final profile = data.profile;
    final photoUrl = data.accountUser?.photoUrl?.trim();
    final memberSince = data.accountUser?.createdAt;
    final memberSinceLabel =
        memberSince == null ? '' : ' · SINCE ${memberSince.year}';
    final protocolLabel = data.activeProgram != null
        ? 'DAY ${data.activeProgram!.currentDayIndex + 1} · '
            '${data.activeProgram!.program.daysPerWeek}X / WEEK'
        : '${profile.workoutDaysPerWeek} DAYS / WEEK TARGET';
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
                child: (photoUrl != null && photoUrl.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(tokens.radiusSm),
                        child: Image.network(
                          photoUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Text(
                            data.initials,
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              color: tokens.kineticAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        data.initials,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          color: tokens.kineticAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.displayName.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      color: tokens.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (data.email != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      data.email!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        color: tokens.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${profile.goal.emoji} ${profile.goal.displayName.toUpperCase()} · '
                    '${profile.fitnessLevel.displayName.toUpperCase()} · '
                    '${profile.equipment.displayName.toUpperCase()}'
                    '$memberSinceLabel',
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
                      protocolLabel,
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
  const _StatsRow({required this.data, required this.tokens});
  final ProfileData data;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    final profile = data.profile;
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
              // Latest logged body entry, not the frozen onboarding
              // weight (which is only the pre-logging fallback).
              value: data.currentWeightKg.toStringAsFixed(1),
              unit: data.latestBodyEntry == null ? 'KG' : 'KG · LATEST',
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
              value: data.bmi.toStringAsFixed(1),
              unit: 'INDEX',
              color: _bmiColor(data.bmi),
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

/// Real training totals for this user, computed from their workout
/// history (see [buildProfileData]) — replaces any stored/global
/// counters on this screen.
class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.data, required this.tokens});
  final ProfileData data;
  final AppThemeTokens tokens;

  String _volumeLabel(double kg) {
    if (kg >= 1000) return '${(kg / 1000).toStringAsFixed(1)}k';
    return kg.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'WORKOUTS',
              value: '${data.totalWorkouts}',
              unit: 'TOTAL',
              color: tokens.kineticAccent,
              tokens: tokens,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'THIS WEEK',
              value: '${data.workoutsThisWeek}',
              unit: 'SESSIONS',
              color: tokens.cyanAccent,
              tokens: tokens,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'STREAK',
              value: '${data.currentStreakDays}',
              unit: 'DAYS',
              color: tokens.violetAccent,
              tokens: tokens,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: 'VOLUME',
              value: _volumeLabel(data.totalVolumeKg),
              unit: 'KG LIFTED',
              color: tokens.warning,
              tokens: tokens,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 110.ms);
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
    required this.data,
    required this.tokens,
  });

  final ProfileData data;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    final profile = data.profile;
    final active = data.activeProgram;
    final program = active?.program;

    final String badge;
    final String title;
    final String description;
    final List<Widget> chips;

    if (active != null && program != null) {
      // The program this user actually has saved/active, with their
      // real progress — not a regenerated sample program.
      final currentDay = program.days.isEmpty
          ? null
          : program.days[
              active.currentDayIndex.clamp(0, program.days.length - 1).toInt()];
      badge = 'ACTIVE PROTOCOL';
      title = program.name;
      description = currentDay == null
          ? program.description
          : 'Next up: ${currentDay.name} · ${currentDay.focus}. '
              '${data.completedProgramDays} of ${program.days.length} days completed.';
      chips = [
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
          label: '${program.daysPerWeek}X / WEEK',
          tokens: tokens,
        ),
        _PlanChip(
          icon: Icons.flag_rounded,
          label: 'DAY ${active.currentDayIndex + 1} OF ${program.days.length}',
          tokens: tokens,
        ),
        if (data.lastWorkoutDate != null)
          _PlanChip(
            icon: Icons.history_rounded,
            label: 'LAST ${data.lastWorkoutDate!.day}/${data.lastWorkoutDate!.month}/${data.lastWorkoutDate!.year}',
            tokens: tokens,
          ),
      ];
    } else {
      badge = 'NO ACTIVE PROGRAM';
      title = 'No program started yet';
      description = 'Your goal is ${profile.goal.displayName}. Choose or start a '
          'program and your real plan and progress will appear here.';
      chips = [
        _PlanChip(
          icon: Icons.flag_rounded,
          label: profile.goal.displayName.toUpperCase(),
          tokens: tokens,
        ),
        _PlanChip(
          icon: Icons.repeat_rounded,
          label: '${profile.workoutDaysPerWeek} DAYS / WEEK TARGET',
          tokens: tokens,
        ),
        _PlanChip(
          icon: Icons.fitness_center_rounded,
          label: '${data.totalWorkouts} WORKOUTS LOGGED',
          tokens: tokens,
        ),
      ];
    }

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
                    badge,
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
              title,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                color: tokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                color: tokens.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            if (active != null) ...[
              const SizedBox(height: 12),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: tokens.card,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: data.programProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: tokens.kineticAccent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: chips,
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
  const _DietPlanCard({required this.data, required this.tokens});
  final ProfileData data;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    final savedPlan = data.savedDietPlan;
    final title = savedPlan?.name ?? data.nutritionTargetSourceLabel;
    final savedPlanDayName = data.savedDietPlanDayName;
    final savedPlanLabel = savedPlanDayName == null
        ? 'SAVED PLAN'
        : 'SAVED PLAN · ${savedPlanDayName.toUpperCase()}';

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
                    '${data.targetCalories.toInt()} KCAL / DAY',
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
              title,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                color: tokens.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'TODAY: ${data.consumedCaloriesToday.toInt()} / '
              '${data.targetCalories.toInt()} KCAL · '
              '${data.mealsLoggedToday} MEAL${data.mealsLoggedToday == 1 ? '' : 'S'} LOGGED',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                color: tokens.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 14),
            _MacroBar(
              label: 'PROTEIN',
              value: data.consumedProteinTodayG,
              total: data.targetProteinG,
              color: tokens.kineticAccent,
              unit: 'G',
              valueText:
                  '${data.consumedProteinTodayG.toInt()}/${data.targetProteinG.toInt()} G',
              tokens: tokens,
            ),
            const SizedBox(height: 8),
            _MacroBar(
              label: 'CARBS',
              value: data.consumedCarbsTodayG,
              total: data.targetCarbsG,
              color: tokens.cyanAccent,
              unit: 'G',
              valueText:
                  '${data.consumedCarbsTodayG.toInt()}/${data.targetCarbsG.toInt()} G',
              tokens: tokens,
            ),
            const SizedBox(height: 8),
            _MacroBar(
              label: 'FATS',
              value: data.consumedFatsTodayG,
              total: data.targetFatsG,
              color: tokens.violetAccent,
              unit: 'G',
              valueText:
                  '${data.consumedFatsTodayG.toInt()}/${data.targetFatsG.toInt()} G',
              tokens: tokens,
            ),
            const SizedBox(height: 18),
            if (data.savedDietPlanMeals.isNotEmpty) ...[
              Text(
                savedPlanLabel,
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: tokens.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              ...data.savedDietPlanMeals
                  .map((meal) => _MealRow(meal: meal, tokens: tokens)),
            ] else
              Text(
                savedPlan == null
                    ? 'No saved diet plan yet. Your logged meals and targets above are live.'
                    : 'Your saved diet plan has no meals for its first day yet.',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  color: tokens.textMuted,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
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
    this.valueText,
  });

  final String label;
  final double value;
  final double total;
  final Color color;
  final String unit;
  final String? valueText;
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
          width: 76,
          child: Text(
            valueText ?? '${value.toInt()} $unit',
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
          'LOG OUT',
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
          'Are you sure you want to log out? Your workouts, nutrition, and stats are saved on your device.',
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACCOUNT & PREFERENCES',
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
                  icon: Icons.edit_rounded,
                  label: 'Edit Body Stats & Goals',
                  onTap: () => context.go(AppRoutes.onboarding),
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _SettingsTile(
                  icon: Icons.calculate_outlined,
                  label: 'Fitness Calculators & Tools',
                  onTap: () => context.push(AppRoutes.tools),
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _SettingsTile(
                  icon: Icons.settings_outlined,
                  label: 'System Preferences & Data',
                  onTap: () => context.push(AppRoutes.settings),
                  tokens: tokens,
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                ListTile(
                  leading: Icon(
                    Icons.logout_rounded,
                    color: tokens.error,
                    size: 20,
                  ),
                  title: Text(
                    'LOG OUT',
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

