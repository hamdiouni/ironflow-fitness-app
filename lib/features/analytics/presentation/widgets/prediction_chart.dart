import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/analytics/domain/entities/performance_prediction.dart';

/// Chart widget for displaying performance predictions.
class PredictionChart extends StatelessWidget {
  final List<ExercisePrediction> predictions;

  const PredictionChart({
    super.key,
    required this.predictions,
  });

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) {
      return const Center(
        child: Text('No predictions available'),
      );
    }

    // Take top 5 predictions
    final topPredictions = predictions.take(5).toList();

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(topPredictions),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final prediction = topPredictions[group.x.toInt()];
                return BarTooltipItem(
                  '${prediction.exerciseName}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: rodIndex == 0
                          ? 'Current: ${prediction.currentOneRepMax.toStringAsFixed(1)} kg'
                          : 'Predicted: ${prediction.predictedOneRepMax.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
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
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= topPredictions.length) {
                    return const Text('');
                  }
                  final prediction = topPredictions[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      width: 60,
                      child: Text(
                        prediction.exerciseName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                        ),
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
          barGroups: topPredictions.asMap().entries.map((entry) {
            final index = entry.key;
            final prediction = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: prediction.currentOneRepMax,
                  color: AppTheme.accentColor,
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: prediction.predictedOneRepMax,
                  color: AppTheme.primaryColor,
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
        ),
      ),
    );
  }

  double _getMaxY(List<ExercisePrediction> predictions) {
    final maxValues = predictions.map((p) {
      return p.predictedOneRepMax > p.currentOneRepMax
          ? p.predictedOneRepMax
          : p.currentOneRepMax;
    }).toList();

    if (maxValues.isEmpty) return 100;

    final max = maxValues.reduce((a, b) => a > b ? a : b);
    return (max * 1.2).ceilToDouble();
  }
}

/// Widget for displaying prediction legend.
class PredictionLegend extends StatelessWidget {
  const PredictionLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: AppTheme.accentColor,
          label: 'Current',
        ),
        const SizedBox(width: 24),
        _LegendItem(
          color: AppTheme.primaryColor,
          label: 'Predicted',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
