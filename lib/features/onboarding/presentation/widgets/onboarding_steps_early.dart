import 'package:flutter/material.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

import 'onboarding_shared_widgets.dart';

class OnboardingStep1Goal extends StatelessWidget {
  const OnboardingStep1Goal({
    super.key,
    required this.tokens,
    required this.goal,
    required this.onGoalChanged,
  });

  final AppThemeTokens tokens;
  final FitnessGoal? goal;
  final ValueChanged<FitnessGoal> onGoalChanged;

  @override
  Widget build(BuildContext context) {
    return OnboardingStepContentLayout(
      stepTitle: 'PRIMARY GOAL',
      whyWeAsk: 'Calibrates your daily energy expenditure baseline and macronutrient ratio.',
      children: [
        OnboardingSelectableCard<FitnessGoal>(
          tokens: tokens,
          value: FitnessGoal.loseWeight,
          groupValue: goal,
          code: 'GOAL 01',
          title: 'LOSE FAT',
          subtitle: 'Moderate caloric deficit designed to maximize fat oxidation while preserving lean muscle.',
          icon: Icons.local_fire_department_rounded,
          onSelect: (g) {
            onGoalChanged(g);
          },
        ),
        const SizedBox(height: 12),
        OnboardingSelectableCard<FitnessGoal>(
          tokens: tokens,
          value: FitnessGoal.gainMuscle,
          groupValue: goal,
          code: 'GOAL 02',
          title: 'GAIN MUSCLE',
          subtitle: 'Targeted caloric surplus optimized for hypertrophy, strength gains, and recovery.',
          icon: Icons.fitness_center_rounded,
          onSelect: (g) {
            onGoalChanged(g);
          },
        ),
        const SizedBox(height: 12),
        OnboardingSelectableCard<FitnessGoal>(
          tokens: tokens,
          value: FitnessGoal.maintain,
          groupValue: goal,
          code: 'GOAL 03',
          title: 'MAINTAIN',
          subtitle: 'Nutritional equilibrium to sustain current body composition, health, and fitness.',
          icon: Icons.balance_rounded,
          onSelect: (g) {
            onGoalChanged(g);
          },
        ),
      ],
    );
  }
}

class OnboardingStep2AboutYou extends StatelessWidget {
  const OnboardingStep2AboutYou({
    super.key,
    required this.tokens,
    required this.sex,
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.isImperial,
    required this.goal,
    required this.onSexChanged,
    required this.onImperialChanged,
    required this.onAgeChanged,
    required this.onHeightCmChanged,
    required this.onWeightKgChanged,
  });

  final AppThemeTokens tokens;
  final BiologicalSex sex;
  final int age;
  final double weightKg;
  final double heightCm;
  final bool isImperial;
  final FitnessGoal? goal;
  final ValueChanged<BiologicalSex> onSexChanged;
  final ValueChanged<bool> onImperialChanged;
  final ValueChanged<int> onAgeChanged;
  final ValueChanged<double> onHeightCmChanged;
  final ValueChanged<double> onWeightKgChanged;

  @override
  Widget build(BuildContext context) {
    final displayWeight = isImperial
        ? (weightKg * 2.20462).round().toDouble()
        : weightKg.round().toDouble();
    final weightUnit = isImperial ? 'LBS' : 'KG';

    final displayHeight = isImperial
        ? (heightCm / 2.54).round().toDouble()
        : heightCm.round().toDouble();
    final heightUnit = isImperial ? 'IN' : 'CM';

    final bmi = weightKg / ((heightCm / 100) * (heightCm / 100));
    final isUnderweight = bmi < 18.5;
    final isMinor = age < 18;

    return OnboardingStepContentLayout(
      stepTitle: 'ABOUT YOU',
      whyWeAsk: 'Powers the Mifflin-St Jeor metabolic expenditure equation for exact targets.',
      children: [
        // Biological Sex Selection
        OnboardingContainerBox(
          tokens: tokens,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BIOLOGICAL SEX (FOR BMR CALCULATION)',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: tokens.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OnboardingUnitChip(
                      tokens: tokens,
                      label: 'MALE',
                      isSelected: sex == BiologicalSex.male,
                      onTap: () {
                        AppHaptics.shared.selectionChanged();
                        onSexChanged(BiologicalSex.male);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OnboardingUnitChip(
                      tokens: tokens,
                      label: 'FEMALE',
                      isSelected: sex == BiologicalSex.female,
                      onTap: () {
                        AppHaptics.shared.selectionChanged();
                        onSexChanged(BiologicalSex.female);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OnboardingUnitChip(
                      tokens: tokens,
                      label: 'PREFER NOT TO SAY',
                      isSelected: sex == BiologicalSex.preferNotToSay,
                      onTap: () {
                        AppHaptics.shared.selectionChanged();
                        onSexChanged(BiologicalSex.preferNotToSay);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Measurement System Toggle
        OnboardingContainerBox(
          tokens: tokens,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MEASUREMENT SYSTEM',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: tokens.textSecondary,
                ),
              ),
              Row(
                children: [
                  OnboardingUnitChip(tokens: tokens, label: 'METRIC', isSelected: !isImperial, onTap: () {
                    AppHaptics.shared.selectionChanged();
                    onImperialChanged(false);
                  }),
                  const SizedBox(width: 6),
                  OnboardingUnitChip(tokens: tokens, label: 'IMPERIAL', isSelected: isImperial, onTap: () {
                    AppHaptics.shared.selectionChanged();
                    onImperialChanged(true);
                  }),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Age, Height, Weight Controls
        OnboardingContainerBox(
          tokens: tokens,
          child: Column(
            children: [
              OnboardingMetricSlider(
                tokens: tokens,
                label: 'AGE',
                valueText: '$age YEARS',
                value: age.toDouble(),
                min: 14,
                max: 90,
                divisions: 76,
                onChanged: (val) {
                  onAgeChanged(val.toInt());
                },
              ),
              Divider(color: tokens.borderSubtle, height: 20),
              OnboardingMetricSlider(
                tokens: tokens,
                label: 'HEIGHT',
                valueText: '${displayHeight.toInt()} $heightUnit',
                value: displayHeight,
                min: isImperial ? 47 : 120, // 47in (~120cm) to 87in (~220cm)
                max: isImperial ? 87 : 220,
                divisions: isImperial ? 40 : 100,
                onChanged: (val) {
                  onHeightCmChanged(isImperial ? val * 2.54 : val);
                },
              ),
              Divider(color: tokens.borderSubtle, height: 20),
              OnboardingMetricSlider(
                tokens: tokens,
                label: 'WEIGHT',
                valueText: '${displayWeight.toInt()} $weightUnit',
                value: displayWeight,
                min: isImperial ? 66 : 35,
                max: isImperial ? 440 : 200,
                divisions: isImperial ? 187 : 165,
                onChanged: (val) {
                  onWeightKgChanged(isImperial ? val / 2.20462 : val);
                },
              ),
            ],
          ),
        ),

        // Safety notes if applicable
        if (isMinor) ...[
          const SizedBox(height: 12),
          OnboardingSafetyNotice(
            tokens: tokens,
            icon: Icons.info_outline_rounded,
            title: 'ADOLESCENT SAFETY GUARD',
            message: 'Users under 18 receive maintenance targets to support healthy biological growth. Always consult a guardian or healthcare professional.',
          ),
        ],

        if (isUnderweight && goal == FitnessGoal.loseWeight) ...[
          const SizedBox(height: 12),
          OnboardingSafetyNotice(
            tokens: tokens,
            icon: Icons.shield_outlined,
            title: 'BMI HEALTH SAFEGUARD',
            message: 'Your current BMI is in the underweight range (<18.5). Calorie deficit has been clamped to maintenance for your safety.',
          ),
        ],
      ],
    );
  }
}

class OnboardingStep3TrainingPlace extends StatelessWidget {
  const OnboardingStep3TrainingPlace({
    super.key,
    required this.tokens,
    required this.equipment,
    required this.homeEquipment,
    required this.onEquipmentChanged,
    required this.onHomeEquipmentChanged,
  });

  final AppThemeTokens tokens;
  final EquipmentType equipment;
  final String homeEquipment;
  final ValueChanged<EquipmentType> onEquipmentChanged;
  final ValueChanged<String> onHomeEquipmentChanged;

  @override
  Widget build(BuildContext context) {
    return OnboardingStepContentLayout(
      stepTitle: 'TRAINING PLACE',
      whyWeAsk: 'Configures exercise movements and equipment matching what you have available.',
      children: [
        OnboardingSelectableCard<EquipmentType>(
          tokens: tokens,
          value: EquipmentType.gym,
          groupValue: equipment,
          code: 'ENVIRONMENT // 01',
          title: 'COMMERCIAL GYM',
          subtitle: 'Full access to barbells, racks, dumbbells, cable columns, and machines.',
          icon: Icons.domain_rounded,
          onSelect: (e) {
            onEquipmentChanged(e);
          },
        ),
        const SizedBox(height: 12),
        OnboardingSelectableCard<EquipmentType>(
          tokens: tokens,
          value: EquipmentType.home,
          groupValue: equipment,
          code: 'ENVIRONMENT // 02',
          title: 'HOME TRAINING',
          subtitle: 'Bodyweight, dumbbells, and resistance bands suitable for home workouts.',
          icon: Icons.home_rounded,
          onSelect: (e) {
            onEquipmentChanged(e);
          },
        ),
        if (equipment == EquipmentType.home) ...[
          const SizedBox(height: 16),
          OnboardingContainerBox(
            tokens: tokens,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AVAILABLE HOME GEAR',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: tokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OnboardingUnitChip(
                        tokens: tokens,
                        label: 'BODYWEIGHT',
                        isSelected: homeEquipment == 'none',
                        onTap: () {
                          onHomeEquipmentChanged('none');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OnboardingUnitChip(
                        tokens: tokens,
                        label: 'DUMBBELLS',
                        isSelected: homeEquipment == 'dumbbells',
                        onTap: () {
                          onHomeEquipmentChanged('dumbbells');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OnboardingUnitChip(
                        tokens: tokens,
                        label: 'BANDS',
                        isSelected: homeEquipment == 'bands',
                        onTap: () {
                          onHomeEquipmentChanged('bands');
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
