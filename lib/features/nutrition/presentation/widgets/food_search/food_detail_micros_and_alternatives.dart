import 'package:flutter/material.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/core/theme/app_typography.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';
import 'package:progression_tracker/features/nutrition/domain/usecases/get_budget_food_alternatives_use_case.dart';

class FoodMicrosGrid extends StatelessWidget {
  const FoodMicrosGrid({
    super.key,
    required this.tokens,
    required this.micros,
  });

  final AppThemeTokens tokens;
  final FoodMicros? micros;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MicroRow(
                label: 'Dietary Fiber',
                amount: micros?.fiberGrams,
                unit: 'g',
                tokens: tokens,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MicroRow(
                label: 'Total Sugars',
                amount: micros?.sugarGrams,
                unit: 'g',
                tokens: tokens,
              ),
            ),
          ],
        ),
        const Divider(height: 14, color: Colors.white10),
        Row(
          children: [
            Expanded(
              child: _MicroRow(
                label: 'Sodium',
                amount: micros?.sodiumMg,
                unit: 'mg',
                tokens: tokens,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MicroRow(
                label: 'Potassium',
                amount: micros?.potassiumMg,
                unit: 'mg',
                tokens: tokens,
              ),
            ),
          ],
        ),
        const Divider(height: 14, color: Colors.white10),
        Row(
          children: [
            Expanded(
              child: _MicroRow(
                label: 'Calcium',
                amount: micros?.calciumMg,
                unit: 'mg',
                tokens: tokens,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MicroRow(
                label: 'Iron',
                amount: micros?.ironMg,
                unit: 'mg',
                decimals: 2,
                tokens: tokens,
              ),
            ),
          ],
        ),
        const Divider(height: 14, color: Colors.white10),
        Row(
          children: [
            Expanded(
              child: _MicroRow(
                label: 'Vitamin D',
                amount: micros?.vitaminDMcg,
                unit: 'mcg',
                decimals: 1,
                tokens: tokens,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MicroRow(
                label: 'Saturated Fat',
                amount: micros?.saturatedFatGrams,
                unit: 'g',
                decimals: 1,
                tokens: tokens,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MicroRow extends StatelessWidget {
  const _MicroRow({
    required this.label,
    required this.amount,
    required this.unit,
    required this.tokens,
    this.decimals = 0,
  });

  final String label;
  final double? amount;
  final String unit;
  final AppThemeTokens tokens;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    final hasData = amount != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: tokens.textSecondary,
          ),
        ),
        Text(
          hasData
              ? '${decimals == 0 ? amount!.toStringAsFixed(0) : amount!.toStringAsFixed(decimals)} $unit'
              : '-- No data',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 10.5,
            fontWeight: hasData ? FontWeight.w700 : FontWeight.w500,
            color: hasData ? tokens.textPrimary : tokens.textMuted,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class BudgetAlternativesSheetSection extends StatelessWidget {
  const BudgetAlternativesSheetSection({
    super.key,
    required this.alternatives,
    required this.tokens,
    required this.onSelectAlternative,
  });

  final List<BudgetFoodAlternative> alternatives;
  final AppThemeTokens tokens;
  final void Function(BudgetFoodAlternative) onSelectAlternative;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        border: Border.all(
          color: const Color(0xFF00E676).withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz_rounded, size: 16, color: const Color(0xFF00E676)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SMART BUDGET-ALIGNED ALTERNATIVES',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: const Color(0xFF00E676),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Budget-friendly meal swaps with balanced macros.',
            style: TextStyle(
              fontSize: 10.5,
              color: tokens.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          ...alternatives.map((alt) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: tokens.card,
                borderRadius: BorderRadius.circular(tokens.radiusLg),
                border: Border.all(color: tokens.borderSubtle, width: 1),
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
                            fontSize: 12,
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
                  const SizedBox(height: 4),
                  Text(
                    'Portion: ${alt.scaledGrams.toInt()}g (${alt.scaledServings}x) • ${alt.scaledMacros.calories.toInt()} kcal • ${alt.scaledMacros.protein.toStringAsFixed(1)}g P',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: tokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alt.rationale,
                    style: TextStyle(
                      fontSize: 10,
                      color: tokens.textMuted,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => onSelectAlternative(alt),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: tokens.cyanAccent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(tokens.radiusPill),
                          border: Border.all(
                            color: tokens.cyanAccent.withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded, size: 12, color: tokens.cyanAccent),
                            const SizedBox(width: 4),
                            Text(
                              'SWITCH TO THIS FOOD',
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: tokens.cyanAccent,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class MacroGaugeCard extends StatelessWidget {
  const MacroGaugeCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String title;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: tokens.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: color,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

