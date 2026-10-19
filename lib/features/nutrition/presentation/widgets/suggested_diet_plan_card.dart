import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../shared/presentation/components/app_button.dart';
import '../../../../shared/presentation/services/app_haptics.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../domain/entities/diet_plan.dart';
import '../../domain/entities/diet_plan_state.dart';
import '../../domain/entities/meal.dart';
import '../../domain/usecases/build_suggested_meal_plan_use_case.dart';
import '../providers/diet_plan_providers.dart';

/// Interactive budget-aware suggested meal plan card for the Fuel tab.
///
/// Features:
/// - Displays 4 meals per day (Breakfast, Lunch, Dinner, Snack) built from verified USDA foods.
/// - Day selector (Day 1, Day 2, Day 3).
/// - One-tap "LOG TO TODAY" to instantly add the suggested meal into today's logged fuel.
/// - "SWAP" button to select budget-friendly alternatives.
/// - Clear/regenerate plan options.
/// - Clean invitation state if the user previously skipped the diet plan.
class SuggestedDietPlanCard extends ConsumerStatefulWidget {
  final Future<void> Function(Meal meal) onLogMeal;
  final void Function(Meal originalMeal)? onSwapMeal;

  const SuggestedDietPlanCard({
    required this.onLogMeal,
    this.onSwapMeal,
    super.key,
  });

  @override
  ConsumerState<SuggestedDietPlanCard> createState() => _SuggestedDietPlanCardState();
}

class _SuggestedDietPlanCardState extends ConsumerState<SuggestedDietPlanCard> {
  int _selectedDayIndex = 0;
  bool _isExpanded = true;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final dietPlanAsync = ref.watch(dietPlanProvider);

    return dietPlanAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (planState) {
        if (planState == null) {
          return _buildInvitationCard(context, tokens);
        }
        return _buildPlanCard(context, tokens, planState);
      },
    );
  }

  Widget _buildInvitationCard(BuildContext context, AppThemeTokens tokens) {
    final profileAsync = ref.watch(userProfileProvider);
    final budget = profileAsync.valueOrNull?.budget;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderSubtle, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: tokens.kineticAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                  ),
                  child: Icon(Icons.restaurant_rounded, size: 20, color: tokens.kineticAccent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OPTIONAL BUDGET MEAL PLAN',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: tokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        budget != null
                            ? 'Sample daily meals matched to your ${budget.displayName} budget'
                            : 'Sample daily meals matched to your calorie target',
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
            const SizedBox(height: 14),
            AppButton(
              label: _isGenerating ? 'GENERATING PLAN...' : 'GET BUDGET MEAL PLAN',
              icon: _isGenerating ? null : const Icon(Icons.auto_awesome_rounded, size: 16),
              isLoading: _isGenerating,
              isFullWidth: true,
              onPressed: _isGenerating ? null : _generatePlan,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, AppThemeTokens tokens, DietPlanState planState) {
    final days = planState.plan.days;
    final currentDay = days.isNotEmpty ? days[_selectedDayIndex % days.length] : null;
    final meals = currentDay != null ? planState.getMealsForDay(currentDay.dayName) : <DietMeal>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderSubtle, width: 1),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.restaurant_menu_rounded, size: 18, color: tokens.kineticAccent),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              planState.plan.name.toUpperCase(),
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: tokens.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${planState.plan.dailyCalories.toInt()} kcal • ${planState.plan.proteinG.toInt()}g P • Verified USDA Foods',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: tokens.textMuted, size: 20),
                  color: tokens.canvas,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    side: BorderSide(color: tokens.borderSubtle),
                  ),
                  onSelected: (val) {
                    if (val == 'regenerate') {
                      _generatePlan();
                    } else if (val == 'remove') {
                      _confirmRemovePlan(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'regenerate',
                      child: Row(
                        children: [
                          Icon(Icons.refresh_rounded, size: 16),
                          SizedBox(width: 8),
                          Text('Regenerate Plan', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                          SizedBox(width: 8),
                          Text('Remove Plan', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Day Selector Tabs
            Row(
              children: List.generate(days.length, (index) {
                final isSelected = index == _selectedDayIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      AppHaptics.shared.selectionChanged();
                      setState(() => _selectedDayIndex = index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? tokens.kineticAccent : tokens.card,
                        borderRadius: BorderRadius.circular(tokens.radiusSm),
                        border: Border.all(
                          color: isSelected ? tokens.kineticAccent : tokens.borderSubtle,
                        ),
                      ),
                      child: Text(
                        'Day ${index + 1}',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.black : tokens.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),

            // Meals List
            ...meals.map((meal) => _buildMealRow(context, tokens, meal, currentDay?.dayName ?? 'Day 1')),

            const SizedBox(height: 10),

            // Toggle Expand / Collapse Tips
            if (planState.plan.tips.isNotEmpty) ...[
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: tokens.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isExpanded ? 'Hide Budget Tips' : 'Show Budget Tips',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 6),
                ...planState.plan.tips.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: tokens.kineticAccent, fontSize: 12)),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 10.5,
                              color: tokens.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMealRow(BuildContext context, AppThemeTokens tokens, DietMeal meal, String dayName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meal.mealType.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          meal.mealType.displayName.toUpperCase(),
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: tokens.kineticAccent,
                          ),
                        ),
                        if (meal.prepTime != null)
                          Text(
                            meal.prepTime!,
                            style: TextStyle(
                              fontSize: 10,
                              color: tokens.textMuted,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meal.name,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${meal.calories.toInt()} kcal • ${meal.proteinG.toInt()}g P • ${meal.carbsG.toInt()}g C • ${meal.fatsG.toInt()}g F',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Ingredients list
          if (meal.ingredients.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tokens.canvas,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: meal.ingredients
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.5),
                        child: Text(
                          '• $item',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 10.5,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.onSwapMeal != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AppHaptics.shared.buttonPress();
                      widget.onSwapMeal!(meal.toMeal());
                    },
                    icon: Icon(Icons.swap_horiz_rounded, size: 14, color: tokens.textSecondary),
                    label: Text(
                      'SWAP',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: tokens.textSecondary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      side: BorderSide(color: tokens.borderSubtle),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ElevatedButton.icon(
                onPressed: () async {
                  AppHaptics.shared.buttonPress();
                  await widget.onLogMeal(meal.toMeal());
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logged ${meal.name} (${meal.calories.toInt()} kcal) to fuel!'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: tokens.panel,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.add_task_rounded, size: 14, color: Colors.black),
                label: const Text(
                  'LOG TO TODAY',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tokens.kineticAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);
    try {
      final profile = await ref.read(userProfileProvider.future);
      if (profile == null) throw Exception('Profile not found');

      final plan = const BuildSuggestedMealPlanUseCase().call(profile);
      await ref.read(saveDietPlanUseCaseProvider).call(plan);
      ref.invalidate(dietPlanProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget meal plan updated!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _confirmRemovePlan(BuildContext context) async {
    final tokens = AppThemeTokens.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.canvas,
        title: const Text('Remove Suggested Plan?'),
        content: const Text(
          'This will remove the current meal suggestions. You can regenerate a new plan anytime based on your budget.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('REMOVE', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(clearDietPlanUseCaseProvider).call();
      ref.invalidate(dietPlanProvider);
    }
  }
}
