import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_theme.dart';
import '../presentation/components/app_card.dart';

/// A pure UI widget that displays an animated macro distribution pie chart
/// styled in the Monolithic Sci-Fi design system.
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
    final tokens = AppThemeTokens.of(context);

    return AppCard(
      backgroundColor: tokens.panel,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMedium,
        vertical: AppTheme.spacingLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _hasData ? _buildChart(context, tokens) : _buildEmptyChart(context, tokens),
                // Center Telemetry Readout
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'MACROS',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: tokens.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _hasData ? '${_total.toInt()}g' : '0g',
                      style: TextStyle(
                        fontFamily: AppTypography.displayFontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildLegend(context, tokens),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildChart(BuildContext context, AppThemeTokens tokens) {
    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 54,
        sections: _buildSections(context, tokens),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildEmptyChart(BuildContext context, AppThemeTokens tokens) {
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 54,
        sections: [
          PieChartSectionData(
            value: 1,
            color: tokens.card,
            radius: 36,
            showTitle: false,
          ),
        ],
        borderData: FlBorderData(show: false),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(BuildContext context, AppThemeTokens tokens) {
    final total = _total;
    return [
      if (protein > 0)
        _buildSection(
          value: protein,
          total: total,
          color: tokens.protein,
          label: 'P',
          labelColor: Colors.black,
        ),
      if (carbs > 0)
        _buildSection(
          value: carbs,
          total: total,
          color: tokens.carbs,
          label: 'C',
          labelColor: Colors.black,
        ),
      if (fats > 0)
        _buildSection(
          value: fats,
          total: total,
          color: tokens.fats,
          label: 'F',
          labelColor: Colors.black,
        ),
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
      radius: 36,
      title: '$percentage%',
      titleStyle: TextStyle(
        fontFamily: AppTypography.displayFontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: labelColor,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      titlePositionPercentageOffset: 0.55,
    );
  }

  Widget _buildLegend(BuildContext context, AppThemeTokens tokens) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _LegendItem(
          color: tokens.protein,
          label: 'PROTEIN',
          value: protein,
          tokens: tokens,
        ),
        _LegendItem(
          color: tokens.carbs,
          label: 'CARBS',
          value: carbs,
          tokens: tokens,
        ),
        _LegendItem(
          color: tokens.fats,
          label: 'FATS',
          value: fats,
          tokens: tokens,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final double value;
  final AppThemeTokens tokens;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: tokens.textMuted,
                ),
              ),
              Text(
                '${value.toStringAsFixed(0)}g',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: tokens.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
