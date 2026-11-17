import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/diet_plan.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/profile/presentation/providers/profile_data_provider.dart';

// ── Goal Card ─────────────────────────────────────────────────────────────────

class ProfileGoalCard extends StatelessWidget {
  const ProfileGoalCard({
    super.key,
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
      badge = 'ACTIVE PLAN';
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
                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: data.programProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: tokens.kineticAccent,
                      borderRadius: BorderRadius.circular(tokens.radiusPill),
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

class ProfileDietPlanCard extends StatelessWidget {
  const ProfileDietPlanCard({super.key, required this.data, required this.tokens});
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
                    'NUTRITION PLAN',
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
              borderRadius: BorderRadius.circular(tokens.radiusPill),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fraction,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(tokens.radiusPill),
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
