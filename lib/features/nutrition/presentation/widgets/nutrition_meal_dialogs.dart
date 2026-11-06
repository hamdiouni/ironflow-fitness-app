import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/utils/error_handler.dart';
import 'package:progression_tracker/shared/presentation/components/app_button.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/domain/exceptions/diet_plan_exceptions.dart';
import 'package:progression_tracker/features/nutrition/domain/usecases/get_budget_food_alternatives_use_case.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';

// ---------------------------------------------------------------------------
// Smart Budget-Aware Meal Swap Dialog
// ---------------------------------------------------------------------------

class SwapMealDialog extends ConsumerWidget {
  const SwapMealDialog({
    super.key,
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
      backgroundColor: tokens.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        side: BorderSide(color: tokens.borderSubtle, width: 1),
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
                  color: tokens.elevated,
                  borderRadius: BorderRadius.circular(tokens.radiusLg),
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
                      borderRadius: BorderRadius.circular(tokens.radiusLg),
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
                                borderRadius: BorderRadius.circular(tokens.radiusPill),
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
                                  foodItemId: alt.food.id,
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
                                  borderRadius: BorderRadius.circular(tokens.radiusPill),
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

// ---------------------------------------------------------------------------
// Log Meal dialog
// ---------------------------------------------------------------------------

class LogMealDialog extends StatefulWidget {
  const LogMealDialog({super.key, required this.onSave});

  final Future<void> Function(Meal meal) onSave;

  @override
  State<LogMealDialog> createState() => _LogMealDialogState();
}

class _LogMealDialogState extends State<LogMealDialog> {
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
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        side: BorderSide(color: tokens.borderSubtle, width: 1),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: tokens.kineticAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(tokens.radiusPill),
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
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
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

