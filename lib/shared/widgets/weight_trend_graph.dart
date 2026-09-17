import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/chart_data_sampler.dart';
import '../../features/body/domain/entities/weight_data_point.dart';

/// Animated weight trend line chart — theme-adaptive (dark + light).
class WeightTrendGraph extends StatelessWidget {
  final List<WeightDataPoint> dataPoints;

  const WeightTrendGraph({required this.dataPoints, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: dataPoints.isEmpty ? _buildEmpty(context) : _buildChart(context),
    )
        .animate()
        .fadeIn(duration: 350.ms, curve: Curves.easeOut)
        .slideY(begin: 0.15, end: 0.0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Text(
        'No weight data yet.\nLog your first weight entry!',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use theme-adaptive colors
    final gridColor = theme.dividerColor;
    final labelColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final dotStrokeColor = theme.scaffoldBackgroundColor;

    final sampledPoints = ChartDataSampler.sample(dataPoints);
    final spots = sampledPoints.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    final weights = dataPoints.map((p) => p.weight).toList();
    final minY = weights.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = weights.reduce((a, b) => a > b ? a : b) + 2;
    final interval = ((maxY - minY) / 4).clamp(0.1, double.infinity);

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) => FlLine(
            color: gridColor,
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: interval,
              getTitlesWidget: (value, _) => Text(
                value.toStringAsFixed(1),
                style: TextStyle(color: labelColor, fontSize: 11),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: _xInterval(spots.length),
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= sampledPoints.length) {
                  return const SizedBox.shrink();
                }
                final date = sampledPoints[index].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${date.month}/${date.day}',
                    style: TextStyle(color: labelColor, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppTheme.accentColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4,
                color: AppTheme.accentColor,
                strokeWidth: 2,
                strokeColor: dotStrokeColor,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentColor.withValues(alpha: isDark ? 0.35 : 0.15),
                  AppTheme.accentColor.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _xInterval(int count) {
    if (count <= 5) return 1;
    if (count <= 10) return 2;
    return (count / 5).ceilToDouble();
  }
}
