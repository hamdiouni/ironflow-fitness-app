import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_theme.dart';
import '../../core/utils/chart_data_sampler.dart';
import '../../features/body/domain/entities/weight_data_point.dart';

/// Animated weight trend line chart — theme-adaptive (dark + light).
///
/// Features:
/// - Daily entries with discrete dots and dashed connection
/// - Trailing 7-day moving average curve (smooth kinetic accent)
/// - Target weight goal line (horizontal dashed reference)
/// - Plain English trend summary directly below the chart
class WeightTrendGraph extends StatelessWidget {
  final List<WeightDataPoint> dataPoints;
  final double? targetWeight;
  final String unit;

  const WeightTrendGraph({
    required this.dataPoints,
    this.targetWeight,
    this.unit = 'kg',
    super.key,
  });

  /// Computes the trailing 7-day moving average for each sampled point.
  static List<FlSpot> calculateMovingAverageSpots({
    required List<WeightDataPoint> allPoints,
    required List<WeightDataPoint> sampledPoints,
    int daysWindow = 7,
  }) {
    if (allPoints.isEmpty || sampledPoints.isEmpty) return const [];

    final sortedAll = List<WeightDataPoint>.from(allPoints)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    for (int i = 0; i < sampledPoints.length; i++) {
      final cur = sampledPoints[i];
      final windowStart = cur.date.subtract(Duration(days: daysWindow));
      final windowPoints = sortedAll.where((p) {
        return !p.date.isBefore(windowStart) && !p.date.isAfter(cur.date);
      }).toList();

      final avg = windowPoints.isEmpty
          ? cur.weight
          : windowPoints.map((p) => p.weight).reduce((a, b) => a + b) /
              windowPoints.length;

      spots.add(FlSpot(i.toDouble(), avg));
    }
    return spots;
  }

  /// Generates a plain English summary of the user's weight trend.
  static String generateTrendSummary({
    required List<WeightDataPoint> points,
    double? targetWeight,
    String unit = 'kg',
  }) {
    if (points.isEmpty) {
      return 'No weight data logged yet. Log your first weigh-in!';
    }

    if (points.length == 1) {
      final p = points.first;
      if (targetWeight != null) {
        final dist = (p.weight - targetWeight).abs();
        final distStr = dist.toStringAsFixed(1);
        final goalStr = targetWeight.toStringAsFixed(1);
        if (dist <= 0.2) {
          return 'Current: ${p.weight.toStringAsFixed(1)} $unit • Target reached! 🎉';
        }
        return 'Current: ${p.weight.toStringAsFixed(1)} $unit • $distStr $unit to $goalStr $unit goal';
      }
      return 'Current: ${p.weight.toStringAsFixed(1)} $unit • Log another weigh-in to see your weekly trend.';
    }

    final sorted = List<WeightDataPoint>.from(points)
      ..sort((a, b) => a.date.compareTo(b.date));

    final latest = sorted.last;
    final sevenDaysAgo = latest.date.subtract(const Duration(days: 7));

    WeightDataPoint baseline = sorted.first;
    for (final p in sorted.reversed) {
      if (!p.date.isAfter(sevenDaysAgo)) {
        baseline = p;
        break;
      }
    }

    final diff = latest.weight - baseline.weight;
    final days = latest.date.difference(baseline.date).inDays;

    String trendPart;
    if (diff.abs() < 0.15) {
      final timeLabel = days <= 1
          ? 'today'
          : days < 7
              ? 'over the last $days days'
              : 'this week';
      trendPart = 'Stable ($timeLabel)';
    } else if (diff < 0) {
      final timeLabel = days < 5 && days > 0 ? 'over $days days' : 'this week';
      trendPart = 'Down ${(-diff).toStringAsFixed(1)} $unit $timeLabel';
    } else {
      final timeLabel = days < 5 && days > 0 ? 'over $days days' : 'this week';
      trendPart = 'Up ${diff.toStringAsFixed(1)} $unit $timeLabel';
    }

    if (targetWeight != null) {
      final distance = (latest.weight - targetWeight).abs();
      if (distance <= 0.2) {
        return '$trendPart • Goal reached! 🎉';
      } else {
        return '$trendPart • ${distance.toStringAsFixed(1)} $unit to ${targetWeight.toStringAsFixed(1)} $unit goal';
      }
    }

    return trendPart;
  }

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return SizedBox(
        height: 200,
        child: _buildEmpty(context),
      )
          .animate()
          .fadeIn(duration: 350.ms, curve: Curves.easeOut)
          .slideY(begin: 0.1, end: 0.0, duration: 400.ms, curve: Curves.easeOut);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegend(context),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: _buildChart(context),
        ),
        const SizedBox(height: 12),
        _buildTrendSummaryCard(context),
      ],
    )
        .animate()
        .fadeIn(duration: 350.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, end: 0.0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildEmpty(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    return Center(
      child: Text(
        'No weight data yet.\nLog your first weight entry!',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: tokens.textMuted,
          fontSize: 13,
          fontFamily: AppTypography.bodyFontFamily,
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _LegendItem(
          color: tokens.kineticAccent,
          label: '7-Day Trend',
          isLine: true,
          tokens: tokens,
        ),
        const SizedBox(width: 12),
        _LegendItem(
          color: tokens.textMuted,
          label: 'Daily Entry',
          isLine: false,
          tokens: tokens,
        ),
        if (targetWeight != null) ...[
          const SizedBox(width: 12),
          _LegendItem(
            color: tokens.kineticAccent.withValues(alpha: 0.7),
            label: 'Goal (${targetWeight!.toStringAsFixed(1)} $unit)',
            isLine: true,
            isDashed: true,
            tokens: tokens,
          ),
        ],
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final gridColor = tokens.borderSubtle;
    final labelColor = tokens.textMuted;
    final dotStrokeColor = tokens.panel;

    final sampledPoints = ChartDataSampler.sample(dataPoints);
    final rawSpots = sampledPoints.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    final maSpots = calculateMovingAverageSpots(
      allPoints: dataPoints,
      sampledPoints: sampledPoints,
    );

    final allY = dataPoints.map((p) => p.weight).toList();
    if (targetWeight != null) {
      allY.add(targetWeight!);
    }
    final minY = allY.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = allY.reduce((a, b) => a > b ? a : b) + 2;
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
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            if (targetWeight != null)
              HorizontalLine(
                y: targetWeight!,
                color: tokens.kineticAccent.withValues(alpha: 0.6),
                strokeWidth: 1.5,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 6, bottom: 2),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: tokens.kineticAccent,
                    fontFamily: AppTypography.displayFontFamily,
                  ),
                  labelResolver: (_) => 'Goal: ${targetWeight!.toStringAsFixed(1)} $unit',
                ),
              ),
          ],
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: interval,
              getTitlesWidget: (value, _) => Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  color: labelColor,
                  fontSize: 10,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: _xInterval(rawSpots.length),
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
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      color: labelColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          // Raw daily log line with subtle dashed connection and discrete dots
          LineChartBarData(
            spots: rawSpots,
            isCurved: true,
            curveSmoothness: 0.2,
            color: tokens.textMuted.withValues(alpha: 0.35),
            barWidth: 1.5,
            dashArray: [4, 4],
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                radius: 3,
                color: tokens.textMuted,
                strokeWidth: 1.5,
                strokeColor: dotStrokeColor,
              ),
            ),
            belowBarData: BarAreaData(show: false),
          ),
          // 7-day moving average curve (kinetic accent glow)
          LineChartBarData(
            spots: maSpots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: tokens.kineticAccent,
            barWidth: 2.8,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                radius: 4,
                color: tokens.kineticAccent,
                strokeWidth: 2,
                strokeColor: dotStrokeColor,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  tokens.kineticAccent.withValues(alpha: tokens.isDark ? 0.25 : 0.12),
                  tokens.kineticAccent.withValues(alpha: 0.0),
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

  Widget _buildTrendSummaryCard(BuildContext context) {
    final tokens = AppThemeTokens.of(context);
    final summary = generateTrendSummary(
      points: dataPoints,
      targetWeight: targetWeight,
      unit: unit,
    );

    IconData icon;
    Color iconColor;
    if (summary.contains('Down')) {
      icon = Icons.trending_down_rounded;
      iconColor = tokens.kineticAccent;
    } else if (summary.contains('Up')) {
      icon = Icons.trending_up_rounded;
      iconColor = tokens.isDark ? Colors.amberAccent : Colors.orange;
    } else if (summary.contains('Goal reached') || summary.contains('Target reached')) {
      icon = Icons.emoji_events_rounded;
      iconColor = tokens.kineticAccent;
    } else {
      icon = Icons.trending_flat_rounded;
      iconColor = tokens.textMuted;
    }

    return Container(
      key: const ValueKey('weight_trend_summary_card'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              summary,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                color: tokens.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
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

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.isLine,
    this.isDashed = false,
    required this.tokens,
  });

  final Color color;
  final String label;
  final bool isLine;
  final bool isDashed;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLine)
          Container(
            width: 14,
            height: isDashed ? 1.5 : 2.5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(1),
            ),
          )
        else
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: tokens.textMuted,
          ),
        ),
      ],
    );
  }
}
