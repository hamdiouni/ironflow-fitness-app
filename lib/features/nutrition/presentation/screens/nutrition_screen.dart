import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../shared/widgets/macro_wheel_chart.dart';
import '../../../../shared/widgets/swipeable_meal_cards.dart';
import '../../../ai/domain/entities/insight.dart';
import '../../../ai/presentation/widgets/insight_widget.dart';
import '../../domain/entities/daily_nutrition_summary.dart';
import '../../domain/entities/diet_plan_state.dart';
import '../../domain/entities/food_item.dart';
import '../../domain/entities/meal.dart';
import '../../domain/exceptions/diet_plan_exceptions.dart';
import '../../domain/usecases/generate_diet_plan_use_case.dart';
import '../providers/diet_plan_providers.dart';
import '../providers/nutrition_providers.dart';
import '../../presentation/providers/nutrition_providers.dart' as nutrition_providers;
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import 'food_search_screen.dart';

/// Nutrition screen displaying daily macro summary, meal list, and log meal form.
///
/// Integrates with diet plan to show targets and suggested meals.
/// Updates the macro wheel within 200ms of any meal change (Requirement 6.6).
///
/// **Validates: Requirements 6.1, 6.2, 6.3, 6.5, 6.6, 12.3, 12.4, 18.1, 18.2, 18.3, 18.4, 18.5, 18.6**
class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = _todayDate();
    final summaryAsync = ref.watch(dailyNutritionSummaryProvider(today));
    final dietPlanAsync = ref.watch(dietPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            onPressed: () => context.go('/nutrition/history'),
            icon: const Icon(Icons.history),
            tooltip: 'Nutrition History',
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _NutritionErrorState(
          error: error,
          stackTrace: stackTrace,
          onRetry: () {
            ref.read(dailyNutritionSummaryProvider(today).notifier).refresh();
          },
        ),
        data: (summary) => _NutritionBody(
          summary: summary,
          dietPlanAsync: dietPlanAsync,
          onDeleteMeal: (mealId) async {
            try {
              if (kDebugMode) {
                print('📊 [Nutrition] Deleting meal: $mealId');
              }
              
              // Delete meal using notifier for instant UI update
              await ref.read(dailyNutritionSummaryProvider(today).notifier).deleteMeal(mealId);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Meal deleted'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
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
                print('📊 [Nutrition] Logging meal: ${meal.name}');
              }
              
              // Show loading indicator
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Adding meal...'),
                      ],
                    ),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
              
              // Add meal using notifier for instant UI update
              await ref.read(dailyNutritionSummaryProvider(today).notifier).addMeal(meal);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Meal added'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Nutrition Data',
            style: TextStyle(
              color: onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error.toString(),
              style: TextStyle(color: secondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body widget (extracted to keep build method clean)
// ---------------------------------------------------------------------------

class _NutritionBody extends StatelessWidget {
  const _NutritionBody({
    required this.summary,
    required this.dietPlanAsync,
    required this.onDeleteMeal,
    required this.onLogMeal,
  });

  final DailyNutritionSummary summary;
  final AsyncValue<DietPlanState?> dietPlanAsync;
  final Future<void> Function(String mealId) onDeleteMeal;
  final Future<void> Function(Meal meal) onLogMeal;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Targets section (diet plan or default)
          // 11.1 & 11.2: Default targets display or diet plan targets display
          dietPlanAsync.when(
            data: (dietPlan) {
              if (dietPlan != null) {
                return _DietPlanTargetsDisplay(dietPlan: dietPlan);
              } else {
                return _DefaultTargetsDisplay();
              }
            },
            loading: () => _DefaultTargetsDisplay(),
            error: (error, _) {
              // Show default targets on diet plan load error
              return _DefaultTargetsDisplay();
            },
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // 11.3: Macro wheel with current day totals
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
          const SizedBox(height: AppTheme.spacingMedium),

          // 11.4: Remaining macros display with progress bars
          _RemainingMacrosCard(summary: summary),
          const SizedBox(height: AppTheme.spacingMedium),

          // AI Insights Widget
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
            child: InsightWidget(context: InsightContext.nutrition),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // Logged meals
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
            ),
            child: Text(
              'Today\'s Meals',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          SwipeableMealCards(
            meals: summary.meals,
            onDelete: onDeleteMeal,
            // 11.5: Add meal swap functionality
            onSwap: (meal) => _showSwapMealDialog(context, meal),
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // Search & Log Food button
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
            ),
            child: ElevatedButton.icon(
              onPressed: () => _openFoodSearch(context),
              icon: const Icon(Icons.search),
              label: const Text('Search & Log Food'),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),

          // Log Custom Meal button (manual entry)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMedium,
            ),
            child: ElevatedButton.icon(
              onPressed: () => _showLogMealDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Log Custom Meal'),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
        ],
      ),
    );
  }

  void _openFoodSearch(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FoodSearchScreen(
        onFoodLogged: (FoodItem food, double grams) {
          final macros = food.macrosForGrams(grams);
          final meal = Meal.create(
            name: '${food.name} (${grams.toInt()}g)',
            macros: MealMacros(
              calories: macros.calories,
              protein: macros.protein,
              carbs: macros.carbs,
              fats: macros.fat,
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

  // 11.5: Add meal swap functionality (placeholder)
  void _showSwapMealDialog(BuildContext context, Meal originalMeal) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Swap Meal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Original: ${originalMeal.name}'),
            const SizedBox(height: 16),
            const Text('Alternative meals (placeholder):'),
            const SizedBox(height: 8),
            // Placeholder: Show a simple list of alternatives
            // In a full implementation, this would filter meals with similar macros
            ListTile(
              title: const Text('Alternative 1'),
              subtitle: const Text('Similar macros'),
              onTap: () {
                // Call swapDietMealUseCase
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Alternative 2'),
              subtitle: const Text('Similar macros'),
              onTap: () {
                // Call swapDietMealUseCase
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Default Targets Display
// ---------------------------------------------------------------------------

class _DefaultTargetsDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final userProfileAsync = ref.watch(userProfileProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Targets',
            style: TextStyle(
              color: onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          AppTheme.glassmorphicCard(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              children: [
                _TargetRow(label: 'Calories', value: '2000 kcal'),
                const SizedBox(height: 12),
                _TargetRow(label: 'Protein', value: '150g'),
                const SizedBox(height: 12),
                _TargetRow(label: 'Carbs', value: '200g'),
                const SizedBox(height: 12),
                _TargetRow(label: 'Fats', value: '60g'),
                // Show BMR if user profile is available
                userProfileAsync.when(
                  data: (profile) {
                    if (profile == null) return const SizedBox.shrink();
                    return Column(
                      children: [
                        const Divider(height: 24),
                        _TargetRow(
                          label: 'BMR (at rest)',
                          value: '${profile.bmr.toInt()} kcal',
                        ),
                        const SizedBox(height: 8),
                        _TargetRow(
                          label: 'TDEE (with activity)',
                          value: '${profile.tdee.toInt()} kcal',
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _GenerateDietPlanButton(),
        ],
      ),
    );
  }
}

// Generate Diet Plan Button Widget
class _GenerateDietPlanButton extends ConsumerStatefulWidget {
  const _GenerateDietPlanButton();

  @override
  ConsumerState<_GenerateDietPlanButton> createState() => _GenerateDietPlanButtonState();
}

class _GenerateDietPlanButtonState extends ConsumerState<_GenerateDietPlanButton> {
  bool _isLoading = false;

  Future<void> _generateDietPlan() async {
    setState(() => _isLoading = true);
    try {
      // Load user profile
      final userProfile = await ref.read(userProfileProvider.future);
      if (userProfile == null) {
        throw Exception('User profile not found');
      }

      // Generate diet plan
      final generateUseCase = GenerateDietPlanUseCase();
      final dietPlan = generateUseCase(userProfile);

      // Save diet plan
      final saveUseCase = ref.read(saveDietPlanUseCaseProvider);
      await saveUseCase(dietPlan);

      // Refresh provider to show new plan
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
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _generateDietPlan,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.add),
      label: const Text('Generate Diet Plan'),
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final userProfileAsync = ref.watch(userProfileProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 11.2: Diet plan name with edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dietPlan.plan.name,
                style: TextStyle(
                  color: onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.edit, color: secondary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 11.2: Show daily calories and macro targets
          AppTheme.glassmorphicCard(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              children: [
                _TargetRow(
                  label: 'Calories',
                  value: '${dietPlan.plan.dailyCalories.toInt()} kcal',
                ),
                const SizedBox(height: 12),
                _TargetRow(
                  label: 'Protein',
                  value: '${dietPlan.plan.proteinG.toInt()}g',
                ),
                const SizedBox(height: 12),
                _TargetRow(
                  label: 'Carbs',
                  value: '${dietPlan.plan.carbsG.toInt()}g',
                ),
                const SizedBox(height: 12),
                _TargetRow(
                  label: 'Fats',
                  value: '${dietPlan.plan.fatsG.toInt()}g',
                ),
                // Show BMR if user profile is available
                userProfileAsync.when(
                  data: (profile) {
                    if (profile == null) return const SizedBox.shrink();
                    return Column(
                      children: [
                        const Divider(height: 24),
                        _TargetRow(
                          label: 'BMR (at rest)',
                          value: '${profile.bmr.toInt()} kcal',
                        ),
                        const SizedBox(height: 8),
                        _TargetRow(
                          label: 'TDEE (with activity)',
                          value: '${profile.tdee.toInt()} kcal',
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetRow extends StatelessWidget {
  final String label;
  final String value;

  const _TargetRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: secondary, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
    final remaining = summary.remainingMacros;
    final proteinRemaining = (summary.target?.macros.protein ?? 0) - summary.totalProtein;
    final carbsRemaining = (summary.target?.macros.carbs ?? 0) - summary.totalCarbs;
    final fatsRemaining = (summary.target?.macros.fats ?? 0) - summary.totalFats;

    return AppTheme.glassmorphicCard(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Remaining',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          // 11.4: Protein progress bar
          _MacroProgressBar(
            label: 'Protein',
            remaining: proteinRemaining,
            color: AppTheme.proteinColor,
          ),
          const SizedBox(height: 12),
          // 11.4: Carbs progress bar
          _MacroProgressBar(
            label: 'Carbs',
            remaining: carbsRemaining,
            color: AppTheme.carbsColor,
          ),
          const SizedBox(height: 12),
          // 11.4: Fats progress bar
          _MacroProgressBar(
            label: 'Fats',
            remaining: fatsRemaining,
            color: AppTheme.fatsColor,
          ),
        ],
      ),
    );
  }
}

class _MacroProgressBar extends StatelessWidget {
  final String label;
  final double remaining;
  final Color color;

  const _MacroProgressBar({
    required this.label,
    required this.remaining,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // 11.4: Change color to red when remaining is negative
    final isNegative = remaining < 0;
    final displayColor = isNegative ? AppTheme.errorColor : color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${remaining.toStringAsFixed(0)}g',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: displayColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (remaining / 100).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: displayColor.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(displayColor),
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
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: const Text('Log Meal'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(_nameController, 'Meal name', isText: true),
              const SizedBox(height: AppTheme.spacingSmall),
              _buildField(_caloriesController, 'Calories (kcal)'),
              const SizedBox(height: AppTheme.spacingSmall),
              _buildField(_proteinController, 'Protein (g)'),
              const SizedBox(height: AppTheme.spacingSmall),
              _buildField(_carbsController, 'Carbs (g)'),
              const SizedBox(height: AppTheme.spacingSmall),
              _buildField(_fatsController, 'Fats (g)'),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool isText = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: isText ? TextInputType.text : TextInputType.number,
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
