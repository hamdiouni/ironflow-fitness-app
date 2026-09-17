import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/analytics/domain/entities/strength_progression.dart';

/// Chart widget for displaying strength progression over time.
class StrengthChart extends StatelessWidget {
  final StrengthProgression progression;
  final bool show1RM;
  final bool showVolume;

  const StrengthChart({
    super.key,
    required this.progression,
    this.show1RM = true,
    this.showVolume = false,
  });

  @override
  Widget build(BuildContext context) {
    if (progression.dataPoints.isEmpty) {
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
            horizontalInterval: 10,
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
                  if (index < 0 || index >= progression.dataPoints.length) {
                    return const Text('');
                  }
                  final date = progression.dataPoints[index].date;
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
                    value.toInt().toString(),
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
          maxX: (progression.dataPoints.length - 1).toDouble(),
          minY: _getMinY(),
          maxY: _getMaxY(),
          lineBarsData: _buildLineBars(),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final dataPoint = progression.dataPoints[spot.x.toInt()];
                  return LineTooltipItem(
                    show1RM
                        ? '1RM: ${dataPoint.estimatedOneRepMax.toStringAsFixed(1)} kg'
                        : 'Volume: ${dataPoint.volume.toStringAsFixed(0)} kg',
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
    final bars = <LineChartBarData>[];

    if (show1RM) {
      bars.add(LineChartBarData(
        spots: progression.dataPoints
            .asMap()
            .entries
            .map((e) => FlSpot(
                  e.key.toDouble(),
                  e.value.estimatedOneRepMax,
                ))
            .toList(),
        isCurved: true,
        color: AppTheme.primaryColor,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(
              radius: 4,
              color: AppTheme.primaryColor,
              strokeWidth: 2,
              strokeColor: AppTheme.backgroundColor,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
        ),
      ));
    }

    if (showVolume) {
      bars.add(LineChartBarData(
        spots: progression.dataPoints
            .asMap()
            .entries
            .map((e) => FlSpot(
                  e.key.toDouble(),
                  e.value.volume / 10, // Scale down for visibility
                ))
            .toList(),
        isCurved: true,
        color: AppTheme.accentColor,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
      ));
    }

    return bars;
  }

  double _getMinY() {
    if (show1RM) {
      final min = progression.dataPoints
          .map((p) => p.estimatedOneRepMax)
          .reduce((a, b) => a < b ? a : b);
      return (min * 0.9).floorToDouble();
    } else {
      final min = progression.dataPoints
          .map((p) => p.volume)
          .reduce((a, b) => a < b ? a : b);
      return (min * 0.9 / 10).floorToDouble();
    }
  }

  double _getMaxY() {
    if (show1RM) {
      final max = progression.dataPoints
          .map((p) => p.estimatedOneRepMax)
          .reduce((a, b) => a > b ? a : b);
      return (max * 1.1).ceilToDouble();
    } else {
      final max = progression.dataPoints
          .map((p) => p.volume)
          .reduce((a, b) => a > b ? a : b);
      return (max * 1.1 / 10).ceilToDouble();
    }
  }
}
