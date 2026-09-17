import 'package:flutter/material.dart';

import '../../domain/entities/nutrition_targets.dart';

/// A reusable progress bar widget for displaying nutrition progress with color coding.
///
/// Color coding:
/// - Green: 80-120% of target (on target)
/// - Orange: 50-80% or 120-150% of target (moderate)
/// - Red: <50% or >150% of target (off target)
class NutritionProgressBar extends StatelessWidget {
  final String label;
  final double consumed;
  final double target;
  final String unit;
  final Color? customColor;

  const NutritionProgressBar({
    super.key,
    required this.label,
    required this.consumed,
    required this.target,
    required this.unit,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = target > 0 ? (consumed / target) * 100 : 0;
    final status = _getStatus(percentage);
    final statusColor = customColor ?? _getStatusColor(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              '${consumed.toStringAsFixed(1)} / ${target.toStringAsFixed(1)} $unit',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: statusColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  NutritionStatus _getStatus(double percentage) {
    if (percentage >= 80 && percentage <= 120) {
      return NutritionStatus.good;
    } else if ((percentage >= 50 && percentage < 80) ||
        (percentage > 120 && percentage <= 150)) {
      return NutritionStatus.moderate;
    } else {
      return NutritionStatus.poor;
    }
  }

  Color _getStatusColor(NutritionStatus status) {
    switch (status) {
      case NutritionStatus.good:
        return const Color(0xFF4CAF50); // Green
      case NutritionStatus.moderate:
        return const Color(0xFFFFA726); // Orange
      case NutritionStatus.poor:
        return const Color(0xFFEF5350); // Red
    }
  }
}
