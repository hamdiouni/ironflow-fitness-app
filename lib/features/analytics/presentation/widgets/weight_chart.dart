import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/analytics/domain/entities/weight_tracking.dart';

/// Chart widget for displaying weight tracking over time.
class WeightChart extends StatelessWidget {
  final WeightTracking tracking;
  final bool showGoalLine;

  const WeightChart({
    super.key,
    required this.tracking,
    this.showGoalLine = true,
  });

  @override
  Widget build(BuildContext context) {
    if (tracking.measurements.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= tracking.measurements.length) {
                    return const Text('');
                  }
                  final date = tracking.measurements[index].date;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${date.month}/${date.day}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()} kg',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          minX: 0,
          maxX: (tracking.measurements.length - 1).toDouble(),
          minY: _getMinY(),
          maxY: _getMaxY(),
          lineBarsData: _buildLineBars(),
          extraLinesData: showGoalLine ? _buildGoalLine() : null,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final measurement = tracking.measurements[spot.x.toInt()];
                  return LineTooltipItem(
                    '${measurement.weight.toStringAsFixed(1)} kg\n${measurement.date.month}/${measurement.date.day}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  List<LineChartBarData> _buildLineBars() {
    return [
      LineChartBarData(
        spots: tracking.measurements
            .asMap()
            .entries
            .map((e) => FlSpot(
                  e.key.toDouble(),
                  e.value.weight,
                ))
            .toList(),
        isCurved: true,
        color: AppTheme.accentColor,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: AppTheme.accentColor,
              strokeWidth: 2,
              strokeColor: AppTheme.backgroundColor,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: AppTheme.accentColor.withValues(alpha: 0.1),
        ),
      ),
    ];
  }

  ExtraLinesData _buildGoalLine() {
    return ExtraLinesData(
      horizontalLines: [
        HorizontalLine(
          y: tracking.goalWeight,
          color: AppTheme.primaryColor.withValues(alpha: 0.5),
          strokeWidth: 2,
          dashArray: [5, 5],
          label: HorizontalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(right: 8, bottom: 4),
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            labelResolver: (line) => 'Goal: ${line.y.toStringAsFixed(1)} kg',
          ),
        ),
      ],
    );
  }

  double _getMinY() {
    final weights = tracking.measurements.map((m) => m.weight).toList();
    if (showGoalLine) {
      weights.add(tracking.goalWeight);
    }
    final min = weights.reduce((a, b) => a < b ? a : b);
    return (min - 5).floorToDouble();
  }

  double _getMaxY() {
    final weights = tracking.measurements.map((m) => m.weight).toList();
    if (showGoalLine) {
      weights.add(tracking.goalWeight);
    }
    final max = weights.reduce((a, b) => a > b ? a : b);
    return (max + 5).ceilToDouble();
  }
}
