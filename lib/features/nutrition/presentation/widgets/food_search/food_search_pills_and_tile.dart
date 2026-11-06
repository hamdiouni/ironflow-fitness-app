import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/core/theme/app_typography.dart';
import 'package:progression_tracker/shared/presentation/components/app_card.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart' show BudgetLevel;
import 'package:progression_tracker/features/nutrition/domain/entities/food_item.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FILTER PILLS
// ─────────────────────────────────────────────────────────────────────────────

class FoodCategoryPill extends StatelessWidget {
  const FoodCategoryPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? tokens.cyanAccent.withValues(alpha: 0.15) : tokens.panel,
            borderRadius: BorderRadius.circular(tokens.radiusPill),
            border: Border.all(
              color: selected ? tokens.cyanAccent : tokens.borderSubtle,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 0.6,
                color: selected ? tokens.cyanAccent : tokens.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FoodBudgetPill extends StatelessWidget {
  const FoodBudgetPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.tier,
    this.isProfileMatch = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final BudgetLevel? tier;
  final bool isProfileMatch;

  Color _tierColor(AppThemeTokens tokens) {
    switch (tier) {
      case BudgetLevel.low:
        return const Color(0xFF00E676);
      case BudgetLevel.medium:
        return tokens.cyanAccent;
      case BudgetLevel.high:
        return const Color(0xFFFFB300);
      case null:
        return tokens.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final color = _tierColor(tokens);

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.15) : tokens.panel.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(tokens.radiusPill),
            border: Border.all(
              color: selected
                  ? color
                  : (isProfileMatch ? color.withValues(alpha: 0.4) : tokens.borderSubtle),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isProfileMatch && !selected) ...[
                Icon(Icons.star_rounded, size: 11, color: color),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 9.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: 0.5,
                  color: selected ? color : tokens.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FOOD LIST TILE
// ─────────────────────────────────────────────────────────────────────────────

class FoodListTile extends StatelessWidget {
  const FoodListTile({super.key, required this.food, required this.onTap});
  final FoodItem food;
  final VoidCallback onTap;

  IconData _categoryIcon(FoodCategory cat) {
    switch (cat) {
      case FoodCategory.protein:
        return Icons.fitness_center_rounded;
      case FoodCategory.carbs:
        return Icons.grain_rounded;
      case FoodCategory.fats:
        return Icons.opacity_rounded;
      case FoodCategory.vegetables:
        return Icons.eco_rounded;
      case FoodCategory.fruits:
        return Icons.apple_rounded;
      case FoodCategory.dairy:
        return Icons.egg_alt_rounded;
      case FoodCategory.snacks:
        return Icons.cookie_rounded;
      case FoodCategory.beverages:
        return Icons.local_cafe_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final isUsda = food.id.startsWith('usda_') || food.fdcId != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food Image / Icon container
                ClipRRect(
                  borderRadius: BorderRadius.circular(tokens.radiusMd),
                  child: CachedNetworkImage(
                    imageUrl: food.imageUrl,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      width: 58,
                      height: 58,
                      color: tokens.card,
                      child: Icon(_categoryIcon(food.category), color: tokens.cyanAccent, size: 24),
                    ),
                    errorWidget: (_, _, _) => Container(
                      width: 58,
                      height: 58,
                      color: tokens.card,
                      child: Icon(_categoryIcon(food.category), color: tokens.cyanAccent, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name, Provenance badges, and serving info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges row
                      Row(
                        children: [
                          if (isUsda)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: tokens.cyanAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(tokens.radiusPill),
                                border: Border.all(
                                  color: tokens.cyanAccent.withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded, size: 9, color: tokens.cyanAccent),
                                  const SizedBox(width: 3),
                                  Text(
                                    'USDA ${food.fdcId != null ? "#${food.fdcId}" : "VERIFIED"}',
                                    style: TextStyle(
                                      fontFamily: AppTypography.displayFontFamily,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                      color: tokens.cyanAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          _buildBudgetBadge(tokens, food.budgetTier),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Food Name
                      Text(
                        food.name,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: tokens.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),

                      // Serving description
                      Text(
                        food.servingDescription.isNotEmpty
                            ? food.servingDescription
                            : '${food.servingWeightGrams.toInt()}g per standard serving',
                        style: TextStyle(
                          fontSize: 11,
                          color: tokens.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Calories header badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${food.caloriesPer100g.toInt()}',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: tokens.textPrimary,
                      ),
                    ),
                    Text(
                      'KCAL / 100G',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Telemetry Macro Chips Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: tokens.card.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(tokens.radiusPill),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MacroTelemetryChip(
                    label: 'PROTEIN',
                    value: '${food.proteinPer100g.toStringAsFixed(1)}g',
                    color: tokens.protein,
                  ),
                  MacroTelemetryChip(
                    label: 'CARBS',
                    value: '${food.carbsPer100g.toStringAsFixed(1)}g',
                    color: tokens.carbs,
                  ),
                  MacroTelemetryChip(
                    label: 'FATS',
                    value: '${food.fatPer100g.toStringAsFixed(1)}g',
                    color: tokens.fats,
                  ),
                  Row(
                    children: [
                      Text(
                        'CONFIGURE',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: tokens.cyanAccent,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 14, color: tokens.cyanAccent),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetBadge(AppThemeTokens tokens, BudgetLevel tier) {
    Color color;
    String label;
    switch (tier) {
      case BudgetLevel.low:
        color = const Color(0xFF00E676);
        label = 'BUDGET \$';
        break;
      case BudgetLevel.medium:
        color = tokens.cyanAccent;
        label = 'MODERATE \$\$';
        break;
      case BudgetLevel.high:
        color = const Color(0xFFFFB300);
        label = 'PREMIUM \$\$\$';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(tokens.radiusPill),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.displayFontFamily,
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }
}

class MacroTelemetryChip extends StatelessWidget {
  const MacroTelemetryChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: tokens.textMuted,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTypography.displayFontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FOOD DETAIL & QUANTITY SHEET (PORTION ENGINE + MICRONUTRIENT MATRIX)
