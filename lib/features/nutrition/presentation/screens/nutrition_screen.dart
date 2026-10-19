import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../shared/presentation/components/app_button.dart';
import '../../../../shared/presentation/services/app_haptics.dart';
import '../../../../shared/widgets/macro_wheel_chart.dart';
import '../../../../shared/widgets/swipeable_meal_cards.dart';
import '../../../ai/domain/entities/insight.dart';
import '../../../ai/presentation/widgets/ai_entry_button.dart';
import '../../../ai/presentation/widgets/contextual_insight_banner.dart';
import '../../domain/entities/daily_nutrition_summary.dart';
import '../../domain/entities/diet_plan_state.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/meal.dart';
import '../../domain/exceptions/diet_plan_exceptions.dart';
import '../../domain/usecases/generate_diet_plan_use_case.dart';
import '../../domain/usecases/get_budget_food_alternatives_use_case.dart';
import '../providers/diet_plan_providers.dart';
import '../providers/nutrition_providers.dart';
import '../widgets/suggested_diet_plan_card.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import 'food_search_screen.dart';

/// Nutrition screen displaying daily macro summary, meal list, and log meal form.
///
/// Upgraded to the Monolithic Sci-Fi design system (Direction 3).
///
/// **Validates: Requirements 6.1, 6.2, 6.3, 6.5, 6.6, 12.3, 12.4, 18.1, 18.2, 18.3, 18.4, 18.5, 18.6**
class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final today = _todayDate();
    final summaryAsync = ref.watch(dailyNutritionSummaryProvider(today));
    final dietPlanAsync = ref.watch(dietPlanProvider);

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
              'NUTRITION',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: tokens.textPrimary,
              ),
            ),
            Text(
              'PROTOCOL & TARGET TELEMETRY',
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
        actions: [
          const AiEntryButton(),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                border: Border.all(color: tokens.borderSubtle, width: 1),
              ),
              child: IconButton(
                onPressed: () => context.go('/nutrition/history'),
                icon: Icon(Icons.history_rounded, color: tokens.textPrimary, size: 20),
                tooltip: 'Nutrition History',
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            color: tokens.kineticAccent,
            strokeWidth: 2.5,
          ),
        ),
        error: (error, stackTrace) => _NutritionErrorState(
          error: error,
          stackTrace: stackTrace,
          onRetry: () {
            ref.read(dailyNutritionSummaryProvider(today).notifier).refresh();
          },
        ),
        data: (summary) => _NutritionBody(
          today: today,
          summary: summary,
          dietPlanAsync: dietPlanAsync,
          onDeleteMeal: (mealId) async {
            try {
              if (kDebugMode) {
                AppLogger.debug('📊 [Nutrition] Deleting meal: $mealId');
              }
              await ref
                  .read(dailyNutritionSummaryProvider(today).notifier)
                  .deleteMeal(mealId);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Meal deleted'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: tokens.panel,
                  ),
                );
              }
            } on DietPlanException catch (e) {
              if (context.mounted) {
                ErrorHandler.handleError(context, e, null);
              }
            } catch (e, stack) {
              if (context.mounted) {
                ErrorHandler.handleError(context, e, stack);
              }
            }
          },
          onLogMeal: (meal) async {
            try {
              if (kDebugMode) {
                AppLogger.debug('📊 [Nutrition] Logging meal: ${meal.name}');
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(tokens.kineticAccent),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Adding meal...'),
                      ],
                    ),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: tokens.panel,
                  ),
                );
              }

              await ref
                  .read(dailyNutritionSummaryProvider(today).notifier)
                  .addMeal(meal);

              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Meal added successfully'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: tokens.success,
                  ),
                );
              }
            } on DietPlanException catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ErrorHandler.handleError(context, e, null);
              }
            } catch (e, stack) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ErrorHandler.handleError(context, e, stack);
              }
            }
          },
        ),
      ),
    );
  }

  /// Returns today's date with time zeroed out for consistent provider keying.
  DateTime _todayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

// ---------------------------------------------------------------------------
// Error state widget
// ---------------------------------------------------------------------------

class _NutritionErrorState extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;

  const _NutritionErrorState({
    required this.error,
    this.stackTrace,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 56,
              color: tokens.error,
            ),
            const SizedBox(height: 16),
            Text(
              'TELEMETRY OFFLINE',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                color: tokens.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(color: tokens.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'RETRY CONNECTION',
              icon: const Icon(Icons.refresh_rounded, size: 18),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body widget
// ---------------------------------------------------------------------------

class _NutritionBody extends StatelessWidget {
  const _NutritionBody({
    required this.today,
    required this.summary,
    required this.dietPlanAsync,
    required this.onDeleteMeal,
    required this.onLogMeal,
  });

  final DateTime today;
  final DailyNutritionSummary summary;
  final AsyncValue<DietPlanState?> dietPlanAsync;
  final Future<void> Function(String mealId) onDeleteMeal;
  final Future<void> Function(Meal meal) onLogMeal;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Contextual AI Banner
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
            child: ContextualInsightBanner(context: InsightContext.nutrition),
          ),
          const SizedBox(height: 12),

          // 2. Targets section (diet plan or default)
          dietPlanAsync.when(
            data: (dietPlan) {
              if (dietPlan != null) {
                return _DietPlanTargetsDisplay(dietPlan: dietPlan);
              } else {
                return const _DefaultTargetsDisplay();
              }
            },
            loading: () => const _DefaultTargetsDisplay(),
            error: (error, _) => const _DefaultTargetsDisplay(),
          ),
          const SizedBox(height: 12),

          // 3. Macro wheel chart with current day totals
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
            ),
            child: MacroWheelChart(
              protein: summary.totalProtein,
              carbs: summary.totalCarbs,
              fats: summary.totalFats,
            ),
          ),
          const SizedBox(height: 12),

          // 4. Remaining macros display with progress bars
          _RemainingMacrosCard(summary: summary),
          const SizedBox(height: 12),

          // 5. Budget-Aware Suggested Diet Plan (Outcome 3)
          SuggestedDietPlanCard(
            onLogMeal: onLogMeal,
            onSwapMeal: (meal) => _showSwapMealDialog(context, meal),
          ),
          const SizedBox(height: 16),

          // 6. Recent foods quick-add chips (Batch 5)
          _RecentFoodsQuickAdd(
            today: today,
          ),

          // 6. Logged meals section
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'TODAY\'S FUEL',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: summary.meals.isNotEmpty
                            ? tokens.kineticAccent.withValues(alpha: 0.12)
                            : tokens.card,
                        borderRadius: BorderRadius.circular(tokens.radiusSm),
                        border: Border.all(
                          color: summary.meals.isNotEmpty
                              ? tokens.kineticAccent.withValues(alpha: 0.35)
                              : tokens.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${summary.meals.length} LOGGED',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: summary.meals.isNotEmpty
                              ? tokens.kineticAccent
                              : tokens.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SwipeableMealCards(
            meals: summary.meals,
            onDelete: onDeleteMeal,
            onSwap: (meal) => _showSwapMealDialog(context, meal),
          ),
          const SizedBox(height: 20),

          // 6. Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
            ),
            child: Column(
              children: [
                AppButton(
                  label: 'SEARCH & LOG FOOD',
                  icon: const Icon(Icons.search_rounded, size: 18),
                  isFullWidth: true,
                  onPressed: () => _openFoodSearch(context),
                ),
                const SizedBox(height: 10),
                AppButton(
                  label: 'LOG CUSTOM MEAL',
                  variant: AppButtonVariant.secondary,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  isFullWidth: true,
                  onPressed: () => _showLogMealDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _openFoodSearch(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FoodSearchScreen(
        onFoodLogged: (FoodItem food, double grams) {
          final macros = food.macrosForGrams(grams);
          final micros = food.microsForGrams(grams);
          final meal = Meal.create(
            name: '${food.name} (${grams.toInt()}g)',
            macros: MealMacros(
              calories: macros.calories,
              protein: macros.protein,
              carbs: macros.carbs,
              fats: macros.fat,
            ),
            micros: MealMicros(
              fiber: micros?.fiberGrams ?? 0,
              sugar: micros?.sugarGrams ?? 0,
              sodium: micros?.sodiumMg ?? 0,
              potassium: micros?.potassiumMg ?? 0,
            ),
            vitamins: MealVitamins(
              vitaminA: 0,
              vitaminB: 0,
              vitaminC: 0,
              vitaminD: micros?.vitaminDMcg ?? 0,
              vitaminE: 0,
            ),
            minerals: MealMinerals(
              calcium: micros?.calciumMg ?? 0,
              iron: micros?.ironMg ?? 0,
              magnesium: 0,
              zinc: 0,
            ),
          );
          onLogMeal(meal);
          Navigator.of(context).pop();
        },
      ),
    ));
  }

  void _showLogMealDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _LogMealDialog(onSave: onLogMeal),
    );
  }

  void _showSwapMealDialog(BuildContext context, Meal originalMeal) {
    showDialog<void>(
      context: context,
      builder: (_) => _SwapMealDialog(
        originalMeal: originalMeal,
        onDeleteMeal: onDeleteMeal,
        onLogMeal: onLogMeal,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Smart Budget-Aware Meal Swap Dialog
// ---------------------------------------------------------------------------

class _SwapMealDialog extends ConsumerWidget {
  const _SwapMealDialog({
    required this.originalMeal,
    required this.onDeleteMeal,
    required this.onLogMeal,
  });

  final Meal originalMeal;
  final Future<void> Function(String mealId) onDeleteMeal;
  final Future<void> Function(Meal meal) onLogMeal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final profileAsync = ref.watch(userProfileProvider);
    final userBudget = profileAsync.valueOrNull?.budget;

    final alternatives = const GetBudgetFoodAlternativesUseCase().getAlternativesForMeal(
      originalMeal,
      preferredBudget: userBudget,
      limit: 4,
    );

    return AlertDialog(
      backgroundColor: tokens.canvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        side: BorderSide(color: tokens.borderGlow.withValues(alpha: 0.5), width: 1.5),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz_rounded, color: tokens.cyanAccent, size: 22),
              const SizedBox(width: 8),
              Text(
                'SMART MEAL SWAP',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: tokens.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'BUDGET-OPTIMIZED EQUI-MACRO ALTERNATIVES',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: tokens.cyanAccent,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Original meal card
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  border: Border.all(color: tokens.borderSubtle, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CURRENT LOGGED MEAL',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: tokens.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      originalMeal.name,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${originalMeal.macros.calories.toInt()} kcal  •  ${originalMeal.macros.protein.toStringAsFixed(1)}g P  •  ${originalMeal.macros.carbs.toStringAsFixed(1)}g C  •  ${originalMeal.macros.fats.toStringAsFixed(1)}g F',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 10,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'RECOMMENDED ALTERNATIVES',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: tokens.cyanAccent,
                ),
              ),
              const SizedBox(height: 8),

              if (alternatives.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No direct equi-macro alternatives found. Try logging from the full Fuel catalog.',
                    style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                  ),
                )
              else
                ...alternatives.map((alt) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: tokens.panel,
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      border: Border.all(
                        color: alt.savingsBadge.contains('SAVE')
                            ? const Color(0xFF00E676).withValues(alpha: 0.4)
                            : tokens.borderSubtle,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                alt.food.name,
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: alt.savingsBadge.contains('SAVE')
                                    ? const Color(0xFF00E676).withValues(alpha: 0.15)
                                    : tokens.cyanAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                alt.savingsBadge,
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: alt.savingsBadge.contains('SAVE')
                                      ? const Color(0xFF00E676)
                                      : tokens.cyanAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Portion: ${alt.scaledGrams.toInt()}g (${alt.scaledServings}x serving)',
                          style: TextStyle(
                            fontSize: 11,
                            color: tokens.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          alt.rationale,
                          style: TextStyle(
                            fontSize: 10,
                            color: tokens.textMuted,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${alt.scaledMacros.calories.toInt()} kcal • ${alt.scaledMacros.protein.toStringAsFixed(1)}g P',
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: tokens.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                AppHaptics.shared.buttonPress();
                                final messenger = ScaffoldMessenger.of(context);
                                Navigator.of(context).pop();

                                // Delete original
                                await onDeleteMeal(originalMeal.id);

                                // Log replacement
                                final replacement = Meal.create(
                                  name: '${alt.food.name} (${alt.scaledGrams.toInt()}g)',
                                  macros: MealMacros(
                                    calories: alt.scaledMacros.calories,
                                    protein: alt.scaledMacros.protein,
                                    carbs: alt.scaledMacros.carbs,
                                    fats: alt.scaledMacros.fat,
                                  ),
                                  micros: MealMicros(
                                    fiber: alt.scaledMicros?.fiberGrams ?? 0,
                                    sugar: alt.scaledMicros?.sugarGrams ?? 0,
                                    sodium: alt.scaledMicros?.sodiumMg ?? 0,
                                    potassium: alt.scaledMicros?.potassiumMg ?? 0,
                                  ),
                                  vitamins: MealVitamins(
                                    vitaminA: 0,
                                    vitaminB: 0,
                                    vitaminC: 0,
                                    vitaminD: alt.scaledMicros?.vitaminDMcg ?? 0,
                                    vitaminE: 0,
                                  ),
                                  minerals: MealMinerals(
                                    calcium: alt.scaledMicros?.calciumMg ?? 0,
                                    iron: alt.scaledMicros?.ironMg ?? 0,
                                    magnesium: 0,
                                    zinc: 0,
                                  ),
                                );
                                await onLogMeal(replacement);

                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('Swapped to ${alt.food.name}!'),
                                    backgroundColor: tokens.panel,
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: tokens.cyanAccent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'SWAP',
                                  style: TextStyle(
                                    fontFamily: 'SpaceGrotesk',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'CANCEL',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontWeight: FontWeight.w700,
              color: tokens.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Default Targets Display
// ---------------------------------------------------------------------------

class _DefaultTargetsDisplay extends ConsumerWidget {
  const _DefaultTargetsDisplay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderSubtle, width: 1),
        ),
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
                    color: tokens.card,
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
                    border: Border.all(color: tokens.borderSubtle, width: 1),
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

class _DietPlanTargetsDisplay extends ConsumerWidget {
  final DietPlanState dietPlan;

  const _DietPlanTargetsDisplay({required this.dietPlan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final userProfileAsync = ref.watch(userProfileProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderSubtle, width: 1),
        ),
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
                    borderRadius: BorderRadius.circular(tokens.radiusSm),
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
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: tokens.borderSubtle, width: 1),
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
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: tokens.borderSubtle, width: 1),
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
      label: _isLoading ? 'CALCULATING PROTOCOL...' : 'GENERATE DIET PLAN',
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

class _RemainingMacrosCard extends StatelessWidget {
  const _RemainingMacrosCard({required this.summary});

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
      child: Container(
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          border: Border.all(color: tokens.borderSubtle, width: 1),
        ),
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

// ---------------------------------------------------------------------------
// Log Meal dialog
// ---------------------------------------------------------------------------

class _LogMealDialog extends StatefulWidget {
  const _LogMealDialog({required this.onSave});

  final Future<void> Function(Meal meal) onSave;

  @override
  State<_LogMealDialog> createState() => _LogMealDialogState();
}

class _LogMealDialogState extends State<_LogMealDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final meal = Meal.create(
        name: _nameController.text.trim(),
        macros: MealMacros(
          calories: double.parse(_caloriesController.text),
          protein: double.parse(_proteinController.text),
          carbs: double.parse(_carbsController.text),
          fats: double.parse(_fatsController.text),
        ),
        micros: MealMicros(
          fiber: 0,
          sugar: 0,
          sodium: 0,
          potassium: 0,
        ),
        vitamins: MealVitamins(
          vitaminA: 0,
          vitaminB: 0,
          vitaminC: 0,
          vitaminD: 0,
          vitaminE: 0,
        ),
        minerals: MealMinerals(
          calcium: 0,
          iron: 0,
          magnesium: 0,
          zinc: 0,
        ),
      );
      await widget.onSave(meal);
      if (mounted) Navigator.of(context).pop();
    } on DietPlanException catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e, null);
      }
    } catch (e, stack) {
      if (mounted) {
        ErrorHandler.handleError(context, e, stack);
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return AlertDialog(
      backgroundColor: tokens.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        side: BorderSide(color: tokens.borderSubtle, width: 1),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: tokens.kineticAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(tokens.radiusSm),
            ),
            child: Icon(
              Icons.restaurant_rounded,
              color: tokens.kineticAccent,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'LOG CUSTOM MEAL',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: tokens.textPrimary,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField('Meal Name', _nameController, isText: true, tokens: tokens),
              const SizedBox(height: 10),
              _buildField('Calories (kcal)', _caloriesController, tokens: tokens),
              const SizedBox(height: 10),
              _buildField('Protein (g)', _proteinController, tokens: tokens),
              const SizedBox(height: 10),
              _buildField('Carbs (g)', _carbsController, tokens: tokens),
              const SizedBox(height: 10),
              _buildField('Fats (g)', _fatsController, tokens: tokens),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(
            'CANCEL',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontWeight: FontWeight.w700,
              color: tokens.textMuted,
            ),
          ),
        ),
        AppButton(
          label: _saving ? 'SAVING...' : 'SAVE MEAL',
          isLoading: _saving,
          onPressed: _saving ? null : _save,
        ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool isText = false,
    required AppThemeTokens tokens,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        fontFamily: AppTypography.bodyFontFamily,
        fontSize: 14,
        color: tokens.textPrimary,
        fontFeatures: isText ? null : const [FontFeature.tabularFigures()],
      ),
      keyboardType: isText ? TextInputType.text : TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          fontSize: 12,
          color: tokens.textMuted,
        ),
        filled: true,
        fillColor: tokens.card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          borderSide: BorderSide(color: tokens.kineticAccent, width: 1.5),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Required';
        if (!isText) {
          final n = double.tryParse(value);
          if (n == null || n < 0) return 'Enter a valid number';
        }
        return null;
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Recent foods quick-add widget (Batch 5)
// ---------------------------------------------------------------------------

class _RecentFoodsQuickAdd extends ConsumerWidget {
  const _RecentFoodsQuickAdd({
    required this.today,
  });

  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentFoodsProvider);
    final tokens = AppThemeTokens.of(context);

    return recentAsync.when(
      data: (foods) {
        if (foods.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMedium,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 15,
                      color: tokens.kineticAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'QUICK RE-LOG RECENT',
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
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMedium,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: foods.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final meal = foods[index];
                    return _RecentFoodChip(
                      meal: meal,
                      tokens: tokens,
                      onTap: () => _logRecentMeal(context, ref, meal),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Future<void> _logRecentMeal(
    BuildContext context,
    WidgetRef ref,
    Meal recentMeal,
  ) async {
    AppHaptics.shared.selectionChanged();
    final newMeal = Meal.create(
      name: recentMeal.name,
      macros: recentMeal.macros,
      micros: recentMeal.micros,
      vitamins: recentMeal.vitamins,
      minerals: recentMeal.minerals,
    );

    try {
      await ref
          .read(dailyNutritionSummaryProvider(today).notifier)
          .addMeal(newMeal);

      if (context.mounted) {
        final tokens = AppThemeTokens.of(context);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Re-logged ${newMeal.name}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: tokens.panel,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: tokens.kineticAccent,
              onPressed: () async {
                AppHaptics.shared.buttonPress();
                await ref
                    .read(dailyNutritionSummaryProvider(today).notifier)
                    .deleteMeal(newMeal.id);
                ref.invalidate(recentFoodsProvider);
              },
            ),
          ),
        );
      }
    } catch (e, stack) {
      if (context.mounted) {
        ErrorHandler.handleError(context, e, stack);
      }
    }
  }
}

class _RecentFoodChip extends StatelessWidget {
  const _RecentFoodChip({
    required this.meal,
    required this.tokens,
    required this.onTap,
  });

  final Meal meal;
  final AppThemeTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: tokens.card,
            borderRadius: BorderRadius.circular(tokens.radiusSm),
            border: Border.all(
              color: tokens.borderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: tokens.kineticAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 14,
                  color: tokens.kineticAccent,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                      meal.name,
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tokens.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${meal.calories.round()} kcal • ${meal.protein.round()}g P',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: tokens.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
