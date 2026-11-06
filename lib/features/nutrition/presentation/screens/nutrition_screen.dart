import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/utils/error_handler.dart';
import 'package:progression_tracker/shared/presentation/components/app_button.dart';
import 'package:progression_tracker/shared/widgets/macro_wheel_chart.dart';
import 'package:progression_tracker/shared/widgets/swipeable_meal_cards.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/ai_entry_button.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/contextual_insight_banner.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/diet_plan_state.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/domain/exceptions/diet_plan_exceptions.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/diet_plan_providers.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:progression_tracker/features/nutrition/presentation/widgets/suggested_diet_plan_card.dart';
import 'package:progression_tracker/features/nutrition/presentation/screens/food_search_screen.dart';
import '../widgets/nutrition_meal_dialogs.dart';
import '../widgets/nutrition_targets_and_macros.dart';
import '../widgets/recent_foods_quick_add.dart';

/// Nutrition screen displaying daily macro summary, meal list, and log meal form.
///
/// Upgraded to Direction 4 (Soft & Layered).
///
/// **Validates: Requirements 6.1, 6.2, 6.3, 6.5, 6.6, 12.3, 12.4, 18.1, 18.2, 18.3, 18.4, 18.5, 18.6**
class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final today = _todayDate();
    final summaryAsync = ref.watch(dailyNutritionSummaryProvider(nutritionDayKey(today)));
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
              'DAILY FUEL & MACROS',
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
          const AiEntryButton(contextScreen: 'fuel'),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              decoration: BoxDecoration(
                color: tokens.elevated,
                borderRadius: BorderRadius.circular(tokens.radiusPill),
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
            ref.read(dailyNutritionSummaryProvider(nutritionDayKey(today)).notifier).refresh();
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
                  .read(dailyNutritionSummaryProvider(nutritionDayKey(today)).notifier)
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
                  .read(dailyNutritionSummaryProvider(nutritionDayKey(today)).notifier)
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
              'NUTRITION OFFLINE',
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
              label: 'RETRY',
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
                return DietPlanTargetsDisplay(dietPlan: dietPlan);
              } else {
                return const DefaultTargetsDisplay();
              }
            },
            loading: () => const DefaultTargetsDisplay(),
            error: (error, _) => const DefaultTargetsDisplay(),
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
          RemainingMacrosCard(summary: summary),
          const SizedBox(height: 12),

          // 5. Budget-Aware Suggested Diet Plan (Outcome 3)
          SuggestedDietPlanCard(
            onLogMeal: onLogMeal,
            onSwapMeal: (meal) => _showSwapMealDialog(context, meal),
          ),
          const SizedBox(height: 16),

          // 6. Recent foods quick-add chips (Batch 5)
          RecentFoodsQuickAdd(
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
                        borderRadius: BorderRadius.circular(tokens.radiusPill),
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
            foodItemId: food.id,
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
      builder: (_) => LogMealDialog(onSave: onLogMeal),
    );
  }

  void _showSwapMealDialog(BuildContext context, Meal originalMeal) {
    showDialog<void>(
      context: context,
      builder: (_) => SwapMealDialog(
        originalMeal: originalMeal,
        onDeleteMeal: onDeleteMeal,
        onLogMeal: onLogMeal,
      ),
    );
  }
}
