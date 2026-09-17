import 'package:flutter/material.dart';

import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/food_item.dart';

/// Displays a food item with macro breakdown and comparison to target.
class FoodItemCard extends StatelessWidget {
  final FoodItem food;
  final double targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;
  final VoidCallback onSelect;

  const FoodItemCard({
    required this.food,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.onSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final calorieMatch = _calculateMatch(food.calories, targetCalories);
    final proteinMatch = _calculateMatch(food.protein, targetProtein);
    final carbsMatch = _calculateMatch(food.carbs, targetCarbs);
    final fatMatch = _calculateMatch(food.fat, targetFat);

    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food name and category
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      food.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Overall match score
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getMatchColor(calorieMatch).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(calorieMatch * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getMatchColor(calorieMatch),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // Macro breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MacroComparison(
                label: 'Calories',
                actual: food.calories,
                target: targetCalories,
                unit: 'kcal',
                match: calorieMatch,
              ),
              _MacroComparison(
                label: 'Protein',
                actual: food.protein,
                target: targetProtein,
                unit: 'g',
                match: proteinMatch,
              ),
              _MacroComparison(
                label: 'Carbs',
                actual: food.carbs,
                target: targetCarbs,
                unit: 'g',
                match: carbsMatch,
              ),
              _MacroComparison(
                label: 'Fat',
                actual: food.fat,
                target: targetFat,
                unit: 'g',
                match: fatMatch,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // Select button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSelect,
              child: const Text('Select'),
            ),
          ),
        ],
      ),
    );
  }

  /// Calculates match percentage (0.0 to 1.0).
  double _calculateMatch(double actual, double target) {
    if (target == 0) return 1.0;
    final diff = (actual - target).abs();
    final tolerance = target * 0.1; // 10% tolerance
    if (diff <= tolerance) return 1.0;
    return (1.0 - (diff / target)).clamp(0.0, 1.0);
  }

  /// Gets color based on match percentage.
  Color _getMatchColor(double match) {
    if (match >= 0.9) return Colors.green;
    if (match >= 0.7) return Colors.orange;
    return Colors.red;
  }
}

class _MacroComparison extends StatelessWidget {
  final String label;
  final double actual;
  final double target;
  final String unit;
  final double match;

  const _MacroComparison({
    required this.label,
    required this.actual,
    required this.target,
    required this.unit,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    final color = match >= 0.9
        ? Colors.green
        : match >= 0.7
            ? Colors.orange
            : Colors.red;

    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            actual.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '/ ${target.toStringAsFixed(1)} $unit',
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
