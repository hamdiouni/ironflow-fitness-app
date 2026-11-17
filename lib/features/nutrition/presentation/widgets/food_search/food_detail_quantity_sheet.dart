import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/core/theme/app_typography.dart';
import 'package:progression_tracker/shared/presentation/components/app_button.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart' show BudgetLevel;
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';
import 'package:progression_tracker/features/nutrition/domain/usecases/get_budget_food_alternatives_use_case.dart';
import 'food_detail_micros_and_alternatives.dart';

class FoodDetailAndQuantitySheet extends ConsumerStatefulWidget {
  const FoodDetailAndQuantitySheet({
    super.key,
    required this.food,
    required this.onConfirm,
  });

  final FoodItem food;
  final void Function(FoodItem food, double grams) onConfirm;

  @override
  ConsumerState<FoodDetailAndQuantitySheet> createState() =>
      _FoodDetailAndQuantitySheetState();
}

class _FoodDetailAndQuantitySheetState
    extends ConsumerState<FoodDetailAndQuantitySheet> {
  bool _isServingMode = true;
  double _servings = 1.0;
  double _grams = 100.0;
  late FoodItem _currentFood;
  late final TextEditingController _gramsController;

  @override
  void initState() {
    super.initState();
    _currentFood = widget.food;
    _grams = _currentFood.servingWeightGrams;
    _gramsController = TextEditingController(text: _grams.toInt().toString());
  }

  @override
  void dispose() {
    _gramsController.dispose();
    super.dispose();
  }

  void _setServings(double s) {
    AppHaptics.shared.selectionChanged();
    setState(() {
      _servings = s;
      _grams = (s * _currentFood.servingWeightGrams).roundToDouble();
      _gramsController.text = _grams.toInt().toString();
    });
  }

  void _setGrams(double g) {
    AppHaptics.shared.selectionChanged();
    setState(() {
      _grams = g;
      _servings = _currentFood.servingWeightGrams > 0
          ? double.parse((g / _currentFood.servingWeightGrams).toStringAsFixed(2))
          : 1.0;
      _gramsController.text = g.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final isUsda = _currentFood.id.startsWith('usda_') || _currentFood.fdcId != null;
    final macros = _currentFood.macrosForGrams(_grams);
    final micros = _currentFood.microsForGrams(_grams);

    final profileAsync = ref.watch(userProfileProvider);
    final userBudget = profileAsync.value?.budget ?? BudgetLevel.low;

    final alternatives = const GetBudgetFoodAlternativesUseCase().getAlternativesForFood(
      _currentFood,
      preferredBudget: userBudget,
      limit: 2,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: tokens.canvas,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: tokens.borderSubtle, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: tokens.cyanAccent.withValues(alpha: 0.08),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              // Sheet Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: tokens.borderSubtle,
                      borderRadius: BorderRadius.circular(tokens.radiusPill),
                    ),
                  ),
                ),
              ),

              // Scrollable Sheet Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
                  children: [
                    // Header title & badges
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(tokens.radiusMd),
                          child: CachedNetworkImage(
                            imageUrl: _currentFood.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              width: 60,
                              height: 60,
                              color: tokens.panel,
                              child: Icon(Icons.restaurant_rounded, color: tokens.cyanAccent),
                            ),
                            errorWidget: (_, _, _) => Container(
                              width: 60,
                              height: 60,
                              color: tokens.panel,
                              child: Icon(Icons.restaurant_rounded, color: tokens.cyanAccent),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (isUsda)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      margin: const EdgeInsets.only(right: 6),
                                      decoration: BoxDecoration(
                                        color: tokens.cyanAccent.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(tokens.radiusPill),
                                        border: Border.all(
                                          color: tokens.cyanAccent.withValues(alpha: 0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'USDA FDC #${_currentFood.fdcId ?? "VERIFIED"}',
                                        style: TextStyle(
                                          fontFamily: AppTypography.displayFontFamily,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                          color: tokens.cyanAccent,
                                        ),
                                      ),
                                    ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: tokens.panel,
                                      borderRadius: BorderRadius.circular(tokens.radiusPill),
                                      border: Border.all(color: tokens.borderSubtle, width: 1),
                                    ),
                                    child: Text(
                                      _currentFood.category.displayName.toUpperCase(),
                                      style: TextStyle(
                                        fontFamily: AppTypography.displayFontFamily,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: tokens.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _currentFood.name,
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                  color: tokens.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Factual Scientific Description Card
                    if (_currentFood.description.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tokens.panel,
                          borderRadius: BorderRadius.circular(tokens.radiusLg),
                          border: Border.all(color: tokens.borderSubtle, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline_rounded, size: 14, color: tokens.cyanAccent),
                                const SizedBox(width: 6),
                                Text(
                                  'SCIENTIFIC PROFILE & BIOAVAILABILITY',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: tokens.cyanAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _currentFood.description,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.45,
                                color: tokens.textSecondary,
                              ),
                            ),
                            if (_currentFood.source.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Data Provenance: ${_currentFood.source}',
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: tokens.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // Portion Control Engine (Mode toggle: By Serving / By Grams)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              AppHaptics.shared.selectionChanged();
                              setState(() => _isServingMode = true);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                color: _isServingMode
                                    ? tokens.cyanAccent.withValues(alpha: 0.15)
                                    : tokens.panel,
                                borderRadius: BorderRadius.circular(tokens.radiusPill),
                                border: Border.all(
                                  color: _isServingMode ? tokens.cyanAccent : tokens.borderSubtle,
                                  width: _isServingMode ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'BY STANDARD SERVING',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: _isServingMode ? tokens.cyanAccent : tokens.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              AppHaptics.shared.selectionChanged();
                              setState(() => _isServingMode = false);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                color: !_isServingMode
                                    ? tokens.cyanAccent.withValues(alpha: 0.15)
                                    : tokens.panel,
                                borderRadius: BorderRadius.circular(tokens.radiusPill),
                                border: Border.all(
                                  color: !_isServingMode ? tokens.cyanAccent : tokens.borderSubtle,
                                  width: !_isServingMode ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'CUSTOM GRAM WEIGHT',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: !_isServingMode ? tokens.cyanAccent : tokens.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Portion Selectors
                    if (_isServingMode) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tokens.panel,
                          borderRadius: BorderRadius.circular(tokens.radiusLg),
                          border: Border.all(color: tokens.borderSubtle, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'PORTION DEFINITION',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.textSecondary,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                Text(
                                  '${_grams.toInt()}g total',
                                  style: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.cyanAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _currentFood.servingDescription,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: tokens.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [0.5, 1.0, 1.5, 2.0, 3.0].map((s) {
                                final isSelected = (_servings - s).abs() < 0.05;
                                return GestureDetector(
                                  onTap: () => _setServings(s),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? tokens.cyanAccent
                                          : tokens.card,
                                      borderRadius: BorderRadius.circular(tokens.radiusPill),
                                      border: Border.all(
                                        color: isSelected ? tokens.cyanAccent : tokens.borderSubtle,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      '${s}x',
                                      style: TextStyle(
                                        fontFamily: AppTypography.displayFontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? Colors.black : tokens.textPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: tokens.panel,
                                borderRadius: BorderRadius.circular(tokens.radiusPill),
                                border: Border.all(color: tokens.borderSubtle, width: 1),
                              ),
                              child: TextField(
                                controller: _gramsController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'WEIGHT IN GRAMS',
                                  labelStyle: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontSize: 10,
                                    color: tokens.textMuted,
                                    letterSpacing: 0.6,
                                  ),
                                  suffixText: 'g',
                                  suffixStyle: TextStyle(
                                    fontFamily: AppTypography.displayFontFamily,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.cyanAccent,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                onChanged: (v) {
                                  final parsed = double.tryParse(v);
                                  if (parsed != null && parsed > 0) {
                                    setState(() {
                                      _grams = parsed;
                                      _servings = _currentFood.servingWeightGrams > 0
                                          ? double.parse(
                                              (parsed / _currentFood.servingWeightGrams)
                                                  .toStringAsFixed(2))
                                          : 1.0;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ...[50.0, 100.0, 150.0, 200.0].map((g) {
                            final isSel = (_grams - g).abs() < 1.0;
                            return Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: GestureDetector(
                                onTap: () => _setGrams(g),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isSel ? tokens.cyanAccent : tokens.panel,
                                    borderRadius: BorderRadius.circular(tokens.radiusPill),
                                    border: Border.all(
                                      color: isSel ? tokens.cyanAccent : tokens.borderSubtle,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${g.toInt()}g',
                                    style: TextStyle(
                                      fontFamily: AppTypography.displayFontFamily,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isSel ? Colors.black : tokens.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Scaled Macro Telemetry Gauges (Live)
                    Text(
                      'SCALED MACROS (${_grams.toInt()}G)',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        MacroGaugeCard(
                          title: 'CALORIES',
                          value: macros.calories.toStringAsFixed(0),
                          unit: 'kcal',
                          color: const Color(0xFFFFD54F),
                        ),
                        const SizedBox(width: 8),
                        MacroGaugeCard(
                          title: 'PROTEIN',
                          value: macros.protein.toStringAsFixed(1),
                          unit: 'g',
                          color: tokens.protein,
                        ),
                        const SizedBox(width: 8),
                        MacroGaugeCard(
                          title: 'CARBS',
                          value: macros.carbs.toStringAsFixed(1),
                          unit: 'g',
                          color: tokens.carbs,
                        ),
                        const SizedBox(width: 8),
                        MacroGaugeCard(
                          title: 'FATS',
                          value: macros.fat.toStringAsFixed(1),
                          unit: 'g',
                          color: tokens.fats,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Authoritative Micronutrient Matrix
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: tokens.panel,
                        borderRadius: BorderRadius.circular(tokens.radiusLg),
                        border: Border.all(color: tokens.borderSubtle, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'MICRONUTRIENT BREAKDOWN',
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: tokens.cyanAccent,
                                ),
                              ),
                              Text(
                                'USDA AUTHORITATIVE',
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w600,
                                  color: tokens.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Missing measurements are explicitly flagged as "-- No data" rather than fake zeros.',
                            style: TextStyle(
                              fontSize: 10,
                              color: tokens.textMuted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FoodMicrosGrid(tokens: tokens, micros: micros),
                        ],
                      ),
                    ),

                    // Smart Budget Alternatives
                    if (alternatives.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      BudgetAlternativesSheetSection(
                        alternatives: alternatives,
                        tokens: tokens,
                        onSelectAlternative: (alt) {
                          AppHaptics.shared.selectionChanged();
                          setState(() {
                            _currentFood = alt.food;
                            _grams = alt.scaledGrams;
                            _servings = alt.scaledServings;
                            _gramsController.text = _grams.toInt().toString();
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 26),

                    // Log Action Button
                    AppButton(
                      label: 'LOG ${_grams.toInt()}G (${macros.calories.toInt()} KCAL)',
                      icon: const Icon(Icons.check_circle_rounded, size: 20),
                      isFullWidth: true,
                      onPressed: () {
                        AppHaptics.shared.buttonPress();
                        widget.onConfirm(_currentFood, _grams);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
