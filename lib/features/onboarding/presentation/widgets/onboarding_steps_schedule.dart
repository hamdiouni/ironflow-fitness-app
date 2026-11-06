import 'package:flutter/material.dart' hide Split;
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/workout/domain/splits/services/split_catalog.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

import 'onboarding_shared_widgets.dart';

class OnboardingStep4Frequency extends StatelessWidget {
  const OnboardingStep4Frequency({
    super.key,
    required this.tokens,
    required this.daysPerWeek,
    required this.chosenSplitId,
    required this.onDaysChanged,
    required this.onSplitChosen,
  });

  final AppThemeTokens tokens;
  final int daysPerWeek;
  final String? chosenSplitId;
  final ValueChanged<int> onDaysChanged;
  final ValueChanged<String?> onSplitChosen;

  @override
  Widget build(BuildContext context) {
    return OnboardingStepContentLayout(
      stepTitle: 'WEEKLY FREQUENCY',
      whyWeAsk: 'Determines your workout split schedule and physical activity expenditure multiplier.',
      children: [
        OnboardingContainerBox(
          tokens: tokens,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DAYS PER WEEK',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: tokens.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tokens.kineticAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(tokens.radiusPill),
                      border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '$daysPerWeek DAYS',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: tokens.kineticAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [2, 3, 4, 5, 6].map((days) {
                  final isSelected = daysPerWeek == days;
                  return InkWell(
                    key: Key('frequency_day_$days'),
                    onTap: () {
                      AppHaptics.shared.selectionChanged();
                      onDaysChanged(days);
                    },
                    borderRadius: BorderRadius.circular(tokens.radiusPill),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 52,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? tokens.kineticAccent : tokens.canvas,
                        borderRadius: BorderRadius.circular(tokens.radiusPill),
                        border: Border.all(
                          color: isSelected ? tokens.kineticAccent : tokens.borderSubtle,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$days',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.black : tokens.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              Text(
                _getFrequencyAdvice(daysPerWeek),
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 12,
                  color: tokens.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildSplitSelectionSection(tokens),
      ],
    );
  }

  String _getFrequencyAdvice(int days) {
    switch (days) {
      case 2:
        return '2-Day Full Body Matrix. Optimized for busy lifestyles and maximum recovery.';
      case 3:
        return '3-Day Classic Full Body Split. Proven baseline for strength, muscle, and consistency.';
      case 4:
        return '4-Day Upper / Lower Split. Balanced recovery and hypertrophy progression.';
      case 5:
        return '5-Day Upper / Lower / PPL Hybrid Split. High stimulus for experienced lifters.';
      case 6:
        return '6-Day Push / Pull / Legs Split. Maximum volume frequency for dedicated trainees.';
      default:
        return 'Custom schedule.';
    }
  }

  Widget _buildSplitSelectionSection(AppThemeTokens tokens) {
    final recommendedSplit = SplitCatalog.getRecommendedSplitForDays(daysPerWeek);
    final isAuto = chosenSplitId == null;

    final availableSplits = [
      SplitCatalog.pushPullLegs,
      SplitCatalog.upperLower,
      SplitCatalog.fullBody,
      SplitCatalog.arnoldSplit,
      SplitCatalog.pplXUpperLower(),
      SplitCatalog.arnoldXUpperLower(),
    ];

    return OnboardingContainerBox(
      tokens: tokens,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WORKOUT SPLIT',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: tokens.textSecondary,
                ),
              ),
              if (isAuto)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: tokens.kineticAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(tokens.radiusPill),
                  ),
                  child: Text(
                    'AUTO-OPTIMIZED',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: tokens.kineticAccent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Option 1: Pick for me (Recommended)
          InkWell(
            key: const Key('split_pick_for_me'),
            onTap: () {
              AppHaptics.shared.selectionChanged();
              onSplitChosen(null);
            },
            borderRadius: BorderRadius.circular(tokens.radiusSm),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAuto
                    ? tokens.kineticAccent.withValues(alpha: 0.08)
                    : tokens.canvas,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                border: Border.all(
                  color: isAuto ? tokens.kineticAccent : tokens.borderSubtle,
                  width: isAuto ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isAuto ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                    color: isAuto ? tokens.kineticAccent : tokens.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pick for me: ${recommendedSplit.name}',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isAuto ? tokens.textPrimary : tokens.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Optimal muscle recovery and balance for $daysPerWeek days/week.',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 11,
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAuto)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: tokens.kineticAccent,
                        borderRadius: BorderRadius.circular(tokens.radiusPill),
                      ),
                      child: const Text(
                        'RECOMMENDED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'OR PICK ANY SPLIT',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: tokens.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableSplits.map((split) {
              final isSelected = !isAuto && chosenSplitId == split.id;
              final isHybrid = split.isHybrid;
              return InkWell(
                key: Key('split_option_${split.id}'),
                onTap: () {
                  AppHaptics.shared.selectionChanged();
                  onSplitChosen(split.id);
                },
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? tokens.kineticAccent.withValues(alpha: 0.15)
                        : tokens.canvas,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(
                      color: isSelected ? tokens.kineticAccent : tokens.borderSubtle,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isHybrid) ...[
                        Icon(Icons.hub_outlined, size: 12, color: isSelected ? tokens.kineticAccent : tokens.textMuted),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        split.name,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? tokens.kineticAccent : tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class OnboardingStep5Experience extends StatelessWidget {
  const OnboardingStep5Experience({
    super.key,
    required this.tokens,
    required this.fitnessLevel,
    required this.onLevelChanged,
  });

  final AppThemeTokens tokens;
  final FitnessLevel fitnessLevel;
  final ValueChanged<FitnessLevel> onLevelChanged;

  @override
  Widget build(BuildContext context) {
    return OnboardingStepContentLayout(
      stepTitle: 'EXPERIENCE LEVEL',
      whyWeAsk: 'Sets exercise volume, movement complexity, and progressive overload pacing.',
      children: [
        OnboardingSelectableCard<FitnessLevel>(
          tokens: tokens,
          value: FitnessLevel.beginner,
          groupValue: fitnessLevel,
          code: 'LEVEL // 01',
          title: 'BEGINNER',
          subtitle: 'Less than 1 year of consistent structured lifting. Focus on form and baseline strength.',
          icon: Icons.shield_outlined,
          onSelect: (l) {
            onLevelChanged(l);
          },
        ),
        const SizedBox(height: 12),
        OnboardingSelectableCard<FitnessLevel>(
          tokens: tokens,
          value: FitnessLevel.intermediate,
          groupValue: fitnessLevel,
          code: 'LEVEL // 02',
          title: 'INTERMEDIATE',
          subtitle: '1 to 3 years of progressive overload training. Familiar with compound lifts and recovery.',
          icon: Icons.verified_user_outlined,
          onSelect: (l) {
            onLevelChanged(l);
          },
        ),
        const SizedBox(height: 12),
        OnboardingSelectableCard<FitnessLevel>(
          tokens: tokens,
          value: FitnessLevel.advanced,
          groupValue: fitnessLevel,
          code: 'LEVEL // 03',
          title: 'EXPERT',
          subtitle: '3+ years of dedicated training. Advanced periodization and high training capacity.',
          icon: Icons.military_tech_outlined,
          onSelect: (l) {
            onLevelChanged(l);
          },
        ),
      ],
    );
  }
}

class OnboardingStep6Budget extends StatelessWidget {
  const OnboardingStep6Budget({
    super.key,
    required this.tokens,
    required this.budget,
    required this.onBudgetChanged,
  });

  final AppThemeTokens tokens;
  final BudgetLevel budget;
  final ValueChanged<BudgetLevel> onBudgetChanged;

  @override
  Widget build(BuildContext context) {
    return OnboardingStepContentLayout(
      stepTitle: 'NUTRITION BUDGET',
      whyWeAsk: 'Prioritizes food recommendations and meal suggestions in Fuel.',
      children: [
        OnboardingSelectableCard<BudgetLevel>(
          tokens: tokens,
          value: BudgetLevel.low,
          groupValue: budget,
          code: 'TIER // ECONOMIC',
          title: 'LOW BUDGET',
          subtitle: 'Simple, highly cost-effective staples: oats, eggs, canned tuna, rice, peanut butter, lentils.',
          icon: Icons.savings_outlined,
          onSelect: (b) {
            onBudgetChanged(b);
          },
        ),
        const SizedBox(height: 12),
        OnboardingSelectableCard<BudgetLevel>(
          tokens: tokens,
          value: BudgetLevel.medium,
          groupValue: budget,
          code: 'TIER // BALANCED',
          title: 'MEDIUM BUDGET',
          subtitle: 'Balanced variety: chicken breasts, greek yogurt, fresh fruits, vegetables, lean mince.',
          icon: Icons.shopping_bag_outlined,
          onSelect: (b) {
            onBudgetChanged(b);
          },
        ),
        const SizedBox(height: 12),
        OnboardingSelectableCard<BudgetLevel>(
          tokens: tokens,
          value: BudgetLevel.high,
          groupValue: budget,
          code: 'TIER // PREMIUM',
          title: 'HIGH BUDGET',
          subtitle: 'Premium foods: fresh salmon, sirloin steak, blueberries, whey isolate, avocado.',
          icon: Icons.diamond_outlined,
          onSelect: (b) {
            onBudgetChanged(b);
          },
        ),
      ],
    );
  }
}
