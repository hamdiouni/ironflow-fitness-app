import 'package:flutter/material.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout_program.dart';

import 'onboarding_shared_widgets.dart';
import 'onboarding_step7_diet.dart';

class OnboardingStep7Summary extends StatelessWidget {
  const OnboardingStep7Summary({
    super.key,
    required this.tokens,
    required this.tempProfile,
    required this.program,
    required this.includeDietPlan,
    required this.synthesisError,
    required this.onSwapExercise,
    required this.onToggleDietPlan,
  });

  final AppThemeTokens tokens;
  final UserProfile tempProfile;
  final WorkoutProgram program;
  final bool includeDietPlan;
  final String? synthesisError;
  final void Function(ProgramDay day, int exerciseIndex, ProgramExercise currentEx)
      onSwapExercise;
  final ValueChanged<bool> onToggleDietPlan;

  @override
  Widget build(BuildContext context) {
    final dailyCalories = tempProfile.dailyCalorieTarget.round();
    final proteinGrams = tempProfile.dailyProteinTargetGrams.round();
    final fatGrams = tempProfile.dailyFatTargetGrams.round();
    final carbGrams = tempProfile.dailyCarbTargetGrams.round();

    return OnboardingStepContentLayout(
      stepTitle: 'PLAN READY',
      whyWeAsk: 'Review your personalized training & nutrition plan before starting.',
      children: [
        // Caloric Target HUD
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tokens.panel,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: tokens.kineticAccent.withValues(alpha: 0.08),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DAILY TARGET',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: tokens.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: tokens.kineticAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(tokens.radiusPill),
                    ),
                    child: Text(
                      tempProfile.goal.displayName.toUpperCase(),
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
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$dailyCalories',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'KCAL / DAY',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: tokens.kineticAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Mifflin-St Jeor BMR: ${tempProfile.bmr.round()} kcal • TDEE: ${tempProfile.tdee.round()} kcal',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 11,
                  color: tokens.textMuted,
                ),
              ),
              const SizedBox(height: 14),
              Divider(color: tokens.borderSubtle, height: 1),
              const SizedBox(height: 14),
              // Macro targets
              Row(
                children: [
                  Expanded(
                    child: _buildMacroPill(
                      tokens,
                      label: 'PROTEIN',
                      grams: '${proteinGrams}g',
                      color: const Color(0xFF4FC3F7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMacroPill(
                      tokens,
                      label: 'CARBS',
                      grams: '${carbGrams}g',
                      color: const Color(0xFFFFB74D),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMacroPill(
                      tokens,
                      label: 'FATS',
                      grams: '${fatGrams}g',
                      color: const Color(0xFFF06292),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Ready-to-start Program Preview with Live Exercises
        _OnboardingProgramPreviewCard(
          tokens: tokens,
          program: program,
          equipment: tempProfile.equipment,
          fitnessLevel: tempProfile.fitnessLevel,
          onSwapExercise: onSwapExercise,
        ),

        const SizedBox(height: 14),

        // Optional Budget Meal Suggestion (Outcome 3)
        OnboardingDietSuggestionCard(
          tokens: tokens,
          tempProfile: tempProfile,
          budget: tempProfile.budget,
          includeDietPlan: includeDietPlan,
          onToggleDietPlan: onToggleDietPlan,
        ),

        const SizedBox(height: 14),

        // Disclaimer
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: tokens.canvas,
            borderRadius: BorderRadius.circular(tokens.radiusSm),
            border: Border.all(color: tokens.borderSubtle),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: tokens.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Estimates are mathematical projections and not medical advice. All nutrition and workout targets can be fine-tuned anytime in Profile.',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11,
                    color: tokens.textMuted,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (synthesisError != null) ...[
          const SizedBox(height: 12),
          Text(
            'Error: $synthesisError',
            style: const TextStyle(color: Colors.redAccent, fontSize: 11),
          ),
        ],
      ],
    );
  }

  Widget _buildMacroPill(
    AppThemeTokens tokens, {
    required String label,
    required String grams,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(tokens.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            grams,
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: tokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingProgramPreviewCard extends StatelessWidget {
  const _OnboardingProgramPreviewCard({
    required this.tokens,
    required this.program,
    required this.equipment,
    required this.fitnessLevel,
    required this.onSwapExercise,
  });

  final AppThemeTokens tokens;
  final WorkoutProgram program;
  final EquipmentType equipment;
  final FitnessLevel fitnessLevel;
  final void Function(ProgramDay day, int exerciseIndex, ProgramExercise currentEx)
      onSwapExercise;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: tokens.kineticAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.fitness_center_rounded, size: 22, color: tokens.kineticAccent),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'READY-TO-START PROGRAM',
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: tokens.textSecondary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: tokens.kineticAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(tokens.radiusPill),
                            ),
                            child: Text(
                              'READY',
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: tokens.kineticAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        program.name,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${program.daysPerWeek} Days/Wk • ${equipment.displayName} • ${fitnessLevel.displayName}',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 11,
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: tokens.borderSubtle, height: 1),
          // Reassurance Note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: tokens.panel.withValues(alpha: 0.5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline_rounded, size: 16, color: tokens.kineticAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Exercises are chosen and ready. Swapping is 100% optional — tap any exercise to swap it, or start now and change exercises anytime.',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 11,
                      color: tokens.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: tokens.borderSubtle, height: 1),
          // Days List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: program.days.length,
            separatorBuilder: (context, index) => Divider(color: tokens.borderSubtle.withValues(alpha: 0.5), height: 1),
            itemBuilder: (context, dayIdx) {
              final day = program.days[dayIdx];
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          day.name.toUpperCase(),
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: tokens.kineticAccent,
                          ),
                        ),
                        Text(
                          day.focus,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 11,
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...day.exercises.asMap().entries.map((entry) {
                      final exIdx = entry.key;
                      final ex = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          key: Key('swap_exercise_${day.dayNumber}_$exIdx'),
                          onTap: () => onSwapExercise(day, exIdx, ex),
                          borderRadius: BorderRadius.circular(tokens.radiusSm),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: tokens.canvas,
                              borderRadius: BorderRadius.circular(tokens.radiusSm),
                              border: Border.all(color: tokens.borderSubtle.withValues(alpha: 0.6)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ex.exerciseName,
                                        style: TextStyle(
                                          fontFamily: AppTypography.bodyFontFamily,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: tokens.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${ex.sets} sets × ${ex.reps} reps',
                                        style: TextStyle(
                                          fontFamily: AppTypography.bodyFontFamily,
                                          fontSize: 11,
                                          color: tokens.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: tokens.panel,
                                    borderRadius: BorderRadius.circular(tokens.radiusPill),
                                    border: Border.all(color: tokens.borderSubtle),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.swap_horiz_rounded, size: 14, color: tokens.kineticAccent),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Swap',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: tokens.kineticAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
