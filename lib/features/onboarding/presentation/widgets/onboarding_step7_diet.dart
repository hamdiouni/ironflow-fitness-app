import 'package:flutter/material.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/diet_plan.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';
import 'package:progression_tracker/features/nutrition/domain/services/food_catalog.dart';
import 'package:progression_tracker/features/nutrition/domain/usecases/build_suggested_meal_plan_use_case.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

class OnboardingDietSuggestionCard extends StatelessWidget {
  const OnboardingDietSuggestionCard({
    super.key,
    required this.tokens,
    required this.tempProfile,
    required this.budget,
    required this.includeDietPlan,
    required this.onToggleDietPlan,
  });

  final AppThemeTokens tokens;
  final UserProfile tempProfile;
  final BudgetLevel budget;
  final bool includeDietPlan;
  final ValueChanged<bool> onToggleDietPlan;

  @override
  Widget build(BuildContext context) {
    if (!FoodCatalog.isLoaded) {
      return FutureBuilder<List<FoodItem>>(
        future: FoodCatalog.ensureLoaded(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Container(
              decoration: BoxDecoration(
                color: tokens.card,
                borderRadius: BorderRadius.circular(tokens.radiusMd),
                border: Border.all(color: tokens.borderSubtle),
              ),
              padding: const EdgeInsets.all(24),
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          return _buildCard(context);
        },
      );
    }
    return _buildCard(context);
  }

  Widget _buildCard(BuildContext context) {
    final plan = const BuildSuggestedMealPlanUseCase().call(tempProfile);
    final day1 = plan.days.isNotEmpty ? plan.days.first : null;

    return Container(
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSubtle),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: tokens.kineticAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.restaurant_menu_rounded, size: 22, color: tokens.kineticAccent),
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
                                'SUGGESTED MEAL PLAN',
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
                                  color: includeDietPlan
                                      ? tokens.kineticAccent.withValues(alpha: 0.15)
                                      : tokens.panel,
                                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                                ),
                                child: Text(
                                  includeDietPlan ? 'INCLUDED' : 'SKIPPED',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: includeDietPlan ? tokens.kineticAccent : tokens.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Based on your ${budget.displayName} budget',
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Accept / Skip toggle row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: tokens.canvas,
              borderRadius: BorderRadius.circular(tokens.radiusSm),
              border: Border.all(color: tokens.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  includeDietPlan ? 'Use this meal plan' : 'Skip meal plan for now',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: includeDietPlan ? tokens.textPrimary : tokens.textMuted,
                  ),
                ),
                Switch.adaptive(
                  key: const Key('diet_plan_toggle_switch'),
                  value: includeDietPlan,
                  activeThumbColor: tokens.kineticAccent,
                  onChanged: (val) {
                    AppHaptics.shared.selectionChanged();
                    onToggleDietPlan(val);
                  },
                ),
              ],
            ),
          ),

          if (includeDietPlan && day1 != null) ...[
            const SizedBox(height: 12),
            Text(
              'DAY 1 SAMPLE MEALS',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: tokens.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            ...day1.meals.map((meal) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: tokens.canvas,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(color: tokens.borderSubtle.withValues(alpha: 0.6)),
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
                              meal.mealType.displayName.toUpperCase(),
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: tokens.kineticAccent,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              meal.name,
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: tokens.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${meal.calories.toInt()} kcal',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 6),
            Text(
              'Uses verified USDA foods matching your budget. You can swap meals or log them with 1 tap in Fuel.',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 10.5,
                color: tokens.textMuted,
                height: 1.35,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'You chose to track on your own. You can still generate or view budget meal suggestions anytime in Fuel.',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 11,
                color: tokens.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
