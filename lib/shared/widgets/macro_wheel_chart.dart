import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_theme.dart';

/// A pure UI widget that displays an animated macro distribution pie chart.
///
/// Requirements: 6.3, 13.6
class MacroWheelChart extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fats;

  const MacroWheelChart({
    required this.protein,
    required this.carbs,
    required this.fats,
    super.key,
  });

  double get _total => protein + carbs + fats;
  bool get _hasData => _total > 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          child: _hasData ? _buildChart(context) : _buildEmptyChart(context),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        _buildLegend(context),
      ],
    )
        .animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.85, 0.85),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildChart(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        sections: _buildSections(context),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surfaceContainerHighest;
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 50,
        sections: [
          PieChartSectionData(
            value: 1,
            color: surface,
            radius: 40,
            showTitle: false,
          ),
        ],
        borderData: FlBorderData(show: false),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(BuildContext context) {
    final labelColor = Theme.of(context).colorScheme.onSurface;
    final total = _total;
    return [
      if (protein > 0)
        _buildSection(value: protein, total: total, color: AppTheme.proteinColor, label: 'P', labelColor: labelColor),
      if (carbs > 0)
        _buildSection(value: carbs, total: total, color: AppTheme.carbsColor, label: 'C', labelColor: labelColor),
      if (fats > 0)
        _buildSection(value: fats, total: total, color: AppTheme.fatsColor, label: 'F', labelColor: labelColor),
    ];
  }

  PieChartSectionData _buildSection({
    required double value,
    required double total,
    required Color color,
    required String label,
    required Color labelColor,
  }) {
    final percentage = (value / total * 100).round();
    return PieChartSectionData(
      value: value,
      color: color,
      radius: 40,
      title: '$percentage%',
      titleStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: labelColor,
      ),
      titlePositionPercentageOffset: 0.6,
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: AppTheme.proteinColor, label: 'Protein', value: protein),
        const SizedBox(width: AppTheme.spacingMedium),
        _LegendItem(color: AppTheme.carbsColor, label: 'Carbs', value: carbs),
        const SizedBox(width: AppTheme.spacingMedium),
        _LegendItem(color: AppTheme.fatsColor, label: 'Fats', value: fats),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppTheme.spacingXSmall),
        Text(
          '$label ${value.toStringAsFixed(0)}g',
          style: TextStyle(fontSize: 12, color: secondary),
        ),
      ],
    );
  }
}
