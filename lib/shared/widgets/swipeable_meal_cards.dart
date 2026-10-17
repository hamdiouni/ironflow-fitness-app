import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_theme.dart';
import '../../features/nutrition/domain/entities/meal.dart';
import 'empty_state_widget.dart';

/// A pure UI widget that displays a scrollable, swipeable list of meal cards.
///
/// Each card can be dismissed (swiped left) to trigger deletion. Cards animate
/// in with a staggered fadeIn + slideX effect (50ms delay per item).
///
/// Requirements: 6.6, 10.2
class SwipeableMealCards extends StatelessWidget {
  final List<Meal> meals;
  final Function(String mealId) onDelete;
  final Function(Meal meal)? onSwap;

  const SwipeableMealCards({
    required this.meals,
    required this.onDelete,
    this.onSwap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) {
      return EmptyStates.meals(
        onLogMeal: () {
          // Navigation logic can be implemented here
        },
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        final delay = (index * 50).ms;

        return Dismissible(
          key: Key(meal.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDelete(meal.id),
          background: _DeleteBackground(),
          child: MealCard(meal: meal, onSwap: onSwap),
        )
            .animate()
            .fadeIn(delay: delay, duration: 300.ms, curve: Curves.easeOut)
            .slideX(
              begin: 0.2,
              end: 0,
              delay: delay,
              duration: 300.ms,
              curve: Curves.easeOut,
            );
      },
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: tokens.error.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.error, width: 1),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppTheme.spacingLarge),
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
    );
  }
}

/// A monolithic telemetry card displaying a single meal's nutritional info.
///
/// Requirements: 6.6, 13.2
class MealCard extends StatelessWidget {
  final Meal meal;
  final Function(Meal meal)? onSwap;

  const MealCard({required this.meal, this.onSwap, super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: tokens.card,
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
              Expanded(
                child: Text(
                  meal.name,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: tokens.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tokens.panel,
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  border: Border.all(color: tokens.borderSubtle, width: 1),
                ),
                child: Text(
                  '${meal.calories.toStringAsFixed(0)} KCAL',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              if (onSwap != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: PopupMenuButton<String>(
                    color: tokens.panel,
                    icon: Icon(Icons.more_vert, color: tokens.textMuted, size: 18),
                    onSelected: (value) {
                      if (value == 'swap') {
                        onSwap!(meal);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'swap',
                        child: Row(
                          children: [
                            Icon(Icons.swap_horiz, size: 18, color: tokens.cyanAccent),
                            const SizedBox(width: 8),
                            Text(
                              'Swap Meal',
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                fontSize: 13,
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
          const SizedBox(height: 10),
          Row(
            children: [
              _MacroChip(
                label: 'PROTEIN',
                value: meal.protein,
                color: tokens.protein,
                tokens: tokens,
              ),
              const SizedBox(width: 8),
              _MacroChip(
                label: 'CARBS',
                value: meal.carbs,
                color: tokens.carbs,
                tokens: tokens,
              ),
              const SizedBox(width: 8),
              _MacroChip(
                label: 'FATS',
                value: meal.fats,
                color: tokens.fats,
                tokens: tokens,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final AppThemeTokens tokens;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: color,
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)}g',
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
