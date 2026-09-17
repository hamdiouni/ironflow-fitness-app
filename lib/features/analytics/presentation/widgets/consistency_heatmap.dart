import 'package:flutter/material.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/analytics/domain/entities/consistency_metrics.dart';

/// Heatmap widget for displaying workout consistency over weeks.
class ConsistencyHeatmap extends StatelessWidget {
  final List<WeeklyConsistency> weeklyData;

  const ConsistencyHeatmap({
    super.key,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    if (weeklyData.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day labels
        Padding(
          padding: const EdgeInsets.only(left: 40, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map((day) => SizedBox(
                      width: 32,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        // Heatmap grid
        ...weeklyData.asMap().entries.map((entry) {
          final index = entry.key;
          final week = entry.value;
          return _WeekRow(
            weekNumber: weeklyData.length - index,
            weekData: week,
          );
        }),
        const SizedBox(height: 16),
        // Legend
        _buildLegend(),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Less',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        _LegendBox(color: Colors.grey.withValues(alpha: 0.2)),
        const SizedBox(width: 4),
        _LegendBox(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
        const SizedBox(width: 4),
        _LegendBox(color: AppTheme.primaryColor.withValues(alpha: 0.6)),
        const SizedBox(width: 4),
        _LegendBox(color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        const Text(
          'More',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _WeekRow extends StatelessWidget {
  final int weekNumber;
  final WeeklyConsistency weekData;

  const _WeekRow({
    required this.weekNumber,
    required this.weekData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              'W$weekNumber',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
              ),
            ),
          ),
          ...weekData.dailyStatus.map((hasWorkout) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _DayBox(
                hasWorkout: hasWorkout,
                adherenceRate: weekData.adherenceRate,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DayBox extends StatelessWidget {
  final bool hasWorkout;
  final double adherenceRate;

  const _DayBox({
    required this.hasWorkout,
    required this.adherenceRate,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    if (!hasWorkout) {
      color = Colors.grey.withValues(alpha: 0.2);
    } else if (adherenceRate >= 0.8) {
      color = AppTheme.primaryColor;
    } else if (adherenceRate >= 0.6) {
      color = AppTheme.primaryColor.withValues(alpha: 0.6);
    } else {
      color = AppTheme.primaryColor.withValues(alpha: 0.3);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: hasWorkout
          ? const Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            )
          : null,
    );
  }
}

class _LegendBox extends StatelessWidget {
  final Color color;

  const _LegendBox({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
    );
  }
}
