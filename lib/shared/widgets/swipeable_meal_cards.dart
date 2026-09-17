import 'dart:ui';

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
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: AppTheme.errorColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppTheme.spacingLarge),
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
    );
  }
}

/// A glassmorphism-styled card displaying a single meal's nutritional info.
///
/// Requirements: 6.6, 13.2
class MealCard extends StatelessWidget {
  final Meal meal;
  final Function(Meal meal)? onSwap;

  const MealCard({required this.meal, this.onSwap, super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final surface = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingSmall,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppTheme.glassBlurSigma,
            sigmaY: AppTheme.glassBlurSigma,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              color: surface.withValues(alpha: 0.6),
              border: Border.all(
                color: onSurface.withValues(alpha: 0.08),
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
                        meal.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Text(
                      '${meal.calories.toStringAsFixed(0)} kcal',
                      style: TextStyle(fontSize: 14, color: secondary),
                    ),
                    if (onSwap != null)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'swap') {
                            onSwap!(meal);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'swap',
                            child: Text('Swap Meal'),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Row(
                  children: [
                    _MacroChip(label: 'P', value: meal.protein, color: AppTheme.proteinColor),
                    const SizedBox(width: AppTheme.spacingSmall),
                    _MacroChip(label: 'C', value: meal.carbs, color: AppTheme.carbsColor),
                    const SizedBox(width: AppTheme.spacingSmall),
                    _MacroChip(label: 'F', value: meal.fats, color: AppTheme.fatsColor),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSmall,
        vertical: AppTheme.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(0)}g',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
