import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/utils/error_handler.dart';
import 'package:progression_tracker/shared/presentation/components/app_button.dart';
import 'package:progression_tracker/shared/presentation/components/app_card.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/diet_plan_state.dart';
import 'package:progression_tracker/features/nutrition/domain/usecases/generate_diet_plan_use_case.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/diet_plan_providers.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';

class DefaultTargetsDisplay extends ConsumerWidget {
  const DefaultTargetsDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      child: AppCard(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: tokens.cyanAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: tokens.cyanAccent.withValues(alpha: 0.6),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'DAILY TARGET PROTOCOL',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tokens.elevated,
                    borderRadius: BorderRadius.circular(tokens.radiusPill),
                  ),
                  child: Text(
                    'STANDARD',
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
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _TargetTelemetryChip(
                    label: 'CALORIES',
                    value: '2000',
                    unit: 'KCAL',
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TargetTelemetryChip(
                    label: 'PROTEIN',
                    value: '150',
                    unit: 'G',
                    color: tokens.protein,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TargetTelemetryChip(
                    label: 'CARBS',
                    value: '200',
                    unit: 'G',
                    color: tokens.carbs,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TargetTelemetryChip(
                    label: 'FATS',
                    value: '60',
                    unit: 'G',
                    color: tokens.fats,
                  ),
                ),
              ],
            ),
            userProfileAsync.when(
              data: (profile) {
                if (profile == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      _TelemetryPill(
                        label: 'BMR',
                        value: '${profile.bmr.toInt()} kcal',
                      ),
                      const SizedBox(width: 8),
                      _TelemetryPill(
                        label: 'TDEE',
                        value: '${profile.tdee.toInt()} kcal',
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 14),
            const _GenerateDietPlanButton(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Diet Plan Targets Display
// ---------------------------------------------------------------------------

class DietPlanTargetsDisplay extends ConsumerWidget {
  final DietPlanState dietPlan;

  const DietPlanTargetsDisplay({super.key, required this.dietPlan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      child: AppCard(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: tokens.kineticAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: tokens.kineticAccent.withValues(alpha: 0.6),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dietPlan.plan.name.toUpperCase(),
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: tokens.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tokens.kineticAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(tokens.radiusPill),
                    border: Border.all(
                      color: tokens.kineticAccent.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'ACTIVE PLAN',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: tokens.kineticAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _TargetTelemetryChip(
                    label: 'CALORIES',
                    value: '${dietPlan.plan.dailyCalories.toInt()}',
                    unit: 'KCAL',
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TargetTelemetryChip(
                    label: 'PROTEIN',
                    value: '${dietPlan.plan.proteinG.toInt()}',
                    unit: 'G',
                    color: tokens.protein,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TargetTelemetryChip(
                    label: 'CARBS',
                    value: '${dietPlan.plan.carbsG.toInt()}',
                    unit: 'G',
                    color: tokens.carbs,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TargetTelemetryChip(
                    label: 'FATS',
                    value: '${dietPlan.plan.fatsG.toInt()}',
                    unit: 'G',
                    color: tokens.fats,
                  ),
                ),
              ],
            ),
            userProfileAsync.when(
              data: (profile) {
                if (profile == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      _TelemetryPill(
                        label: 'BMR',
                        value: '${profile.bmr.toInt()} kcal',
                      ),
                      const SizedBox(width: 8),
                      _TelemetryPill(
                        label: 'TDEE',
                        value: '${profile.tdee.toInt()} kcal',
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetTelemetryChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _TargetTelemetryChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: tokens.textMuted,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _TelemetryPill extends StatelessWidget {
  final String label;
  final String value;

  const _TelemetryPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tokens.elevated,
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: tokens.textMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Generate Diet Plan Button Widget
// ---------------------------------------------------------------------------

class _GenerateDietPlanButton extends ConsumerStatefulWidget {
  const _GenerateDietPlanButton();

  @override
  ConsumerState<_GenerateDietPlanButton> createState() =>
      _GenerateDietPlanButtonState();
}

class _GenerateDietPlanButtonState
    extends ConsumerState<_GenerateDietPlanButton> {
  bool _isLoading = false;

  Future<void> _generateDietPlan() async {
    setState(() => _isLoading = true);
    try {
      final userProfile = await ref.read(userProfileProvider.future);
      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      final generateUseCase = GenerateDietPlanUseCase();
      final dietPlan = generateUseCase(userProfile);

      final saveUseCase = ref.read(saveDietPlanUseCaseProvider);
      await saveUseCase(dietPlan);

      ref.invalidate(dietPlanProvider);

      if (mounted) {
        ErrorHandler.showSnackBar(context, 'Diet plan generated!');
      }
    } catch (e, s) {
      if (mounted) {
        ErrorHandler.handleError(context, e, s);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: _isLoading ? 'CALCULATING DIET PLAN...' : 'GENERATE DIET PLAN',
      icon: _isLoading ? null : const Icon(Icons.auto_awesome_rounded, size: 18),
      isLoading: _isLoading,
      isFullWidth: true,
      onPressed: _isLoading ? null : _generateDietPlan,
    );
  }
}

// ---------------------------------------------------------------------------
// Remaining macros card
// ---------------------------------------------------------------------------

class RemainingMacrosCard extends StatelessWidget {
  const RemainingMacrosCard({super.key, required this.summary});

  final DailyNutritionSummary summary;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    final targetProtein = summary.target?.macros.protein ?? 150;
    final targetCarbs = summary.target?.macros.carbs ?? 200;
    final targetFats = summary.target?.macros.fats ?? 60;

    final proteinRemaining = targetProtein - summary.totalProtein;
    final carbsRemaining = targetCarbs - summary.totalCarbs;
    final fatsRemaining = targetFats - summary.totalFats;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      child: AppCard(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'REMAINING FUEL',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: tokens.textMuted,
                  ),
                ),
                Text(
                  'DAILY BALANCE',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _MacroProgressBar(
              label: 'PROTEIN',
              remaining: proteinRemaining,
              target: targetProtein,
              current: summary.totalProtein,
              color: tokens.protein,
            ),
            const SizedBox(height: 12),
            _MacroProgressBar(
              label: 'CARBS',
              remaining: carbsRemaining,
              target: targetCarbs,
              current: summary.totalCarbs,
              color: tokens.carbs,
            ),
            const SizedBox(height: 12),
            _MacroProgressBar(
              label: 'FATS',
              remaining: fatsRemaining,
              target: targetFats,
              current: summary.totalFats,
              color: tokens.fats,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroProgressBar extends StatelessWidget {
  final String label;
  final double remaining;
  final double target;
  final double current;
  final Color color;

  const _MacroProgressBar({
    required this.label,
    required this.remaining,
    required this.target,
    required this.current,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final isNegative = remaining < 0;
    final displayColor = isNegative ? tokens.error : color;
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)}g',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11,
                    color: tokens.textMuted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            Text(
              isNegative
                  ? '+${(-remaining).toStringAsFixed(0)}g OVER'
                  : '${remaining.toStringAsFixed(0)}g REMAINING',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: displayColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(tokens.radiusPill),
          child: Container(
            height: 6,
            color: tokens.card,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(displayColor),
            ),
          ),
        ),
      ],
    );
  }
}

