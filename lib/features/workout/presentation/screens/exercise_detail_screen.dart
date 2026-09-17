import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_theme.dart';
import '../../../../core/utils/chart_data_sampler.dart';
import '../../../../shared/widgets/exercise_video_player.dart';
import '../../domain/entities/entities.dart';
import '../providers/workout_providers.dart';

/// A data point representing a single exercise performance entry.
class _PerformancePoint {
  const _PerformancePoint({
    required this.date,
    required this.weight,
    required this.reps,
    required this.volume,
  });

  final DateTime date;
  final double weight;
  final int reps;
  final double volume;
}

/// Screen that shows weight/reps progression over time for a given exercise.
///
/// Requirements: 4.2, 4.3
class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Failed to load history',
              style: TextStyle(color: theme.colorScheme.error)),
        ),
        data: (workouts) {
          final points = _buildPerformancePoints(workouts);
          return _ExerciseDetailBody(exerciseName: name, points: points);
        },
      ),
    );
  }

  /// Extracts the best set (by volume) per workout session for this exercise.
  List<_PerformancePoint> _buildPerformancePoints(List<Workout> workouts) {
    final points = <_PerformancePoint>[];

    // workouts are already sorted date-descending; reverse for chronological order
    for (final workout in workouts.reversed) {
      for (final exercise in workout.exercises) {
        if (exercise.name.toLowerCase() == name.toLowerCase() &&
            exercise.sets.isNotEmpty) {
          // Pick the best set by volume for this session
          final best = exercise.sets.reduce((a, b) =>
              (a.weight * a.reps) >= (b.weight * b.reps) ? a : b);
          points.add(_PerformancePoint(
            date: workout.date,
            weight: best.weight,
            reps: best.reps,
            volume: best.weight * best.reps,
          ));
          break; // one entry per workout session
        }
      }
    }

    return points;
  }
}

// ---------------------------------------------------------------------------
// Body widget (stateless, receives pre-computed data)
// ---------------------------------------------------------------------------

class _ExerciseDetailBody extends StatelessWidget {
  const _ExerciseDetailBody({
    required this.exerciseName,
    required this.points,
  });

  final String exerciseName;
  final List<_PerformancePoint> points;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video preview
          ExerciseVideoPlayer(exerciseName: exerciseName, height: 200),
          const SizedBox(height: AppTheme.spacingLarge),
          _SectionLabel(label: 'Weight Progression'),
          const SizedBox(height: AppTheme.spacingSmall),
          _PerformanceGraph(points: points, valueSelector: (p) => p.weight),
          const SizedBox(height: AppTheme.spacingLarge),
          _SectionLabel(label: 'Reps Progression'),
          const SizedBox(height: AppTheme.spacingSmall),
          _PerformanceGraph(
            points: points,
            valueSelector: (p) => p.reps.toDouble(),
            lineColor: AppTheme.primaryColor,
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          _SectionLabel(label: 'Recent Performances'),
          const SizedBox(height: AppTheme.spacingSmall),
          _PerformanceTable(points: points),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Performance graph (animated line chart)
// ---------------------------------------------------------------------------

class _PerformanceGraph extends StatelessWidget {
  const _PerformanceGraph({
    required this.points,
    required this.valueSelector,
    this.lineColor = AppTheme.accentColor,
  });

  final List<_PerformancePoint> points;
  final double Function(_PerformancePoint) valueSelector;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: points.isEmpty ? _buildEmpty(context) : _buildChart(context),
    )
        .animate()
        .fadeIn(duration: 350.ms, curve: Curves.easeOut)
        .slideY(begin: 0.12, end: 0.0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Text(
        'No data yet',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final dotStroke = Theme.of(context).colorScheme.surface;

    final sampledPoints = ChartDataSampler.sample(points);
    final values = sampledPoints.map(valueSelector).toList();
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final padding = (maxVal - minVal) < 1 ? 1.0 : (maxVal - minVal) * 0.15;
    final minY = (minVal - padding).clamp(0.0, double.infinity);
    final maxY = maxVal + padding;

    final spots = sampledPoints.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), valueSelector(e.value));
    }).toList();

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: secondary.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: (maxY - minY) / 4,
              getTitlesWidget: (value, _) => Text(
                value.toStringAsFixed(1),
                style: TextStyle(color: secondary, fontSize: 10),
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
                    style: TextStyle(color: secondary, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: lineColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: lineColor,
                strokeWidth: 2,
                strokeColor: dotStroke,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  lineColor.withValues(alpha: 0.3),
                  lineColor.withValues(alpha: 0.0),
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

// ---------------------------------------------------------------------------
// Recent performances table
// ---------------------------------------------------------------------------

class _PerformanceTable extends StatelessWidget {
  const _PerformanceTable({required this.points});

  final List<_PerformancePoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
        child: Text(
          'No performances recorded yet.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    // Show most recent first (up to 20 entries)
    final recent = points.reversed.take(20).toList();

    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingSmall),
      child: Column(
        children: [
          _TableHeader(),
          const Divider(color: AppTheme.textDisabled, height: 1),
          ...recent.asMap().entries.map((entry) {
            return _TableRow(
              point: entry.value,
              isEven: entry.key.isEven,
            )
                .animate(delay: (entry.key * 40).ms)
                .fadeIn(duration: 250.ms)
                .slideX(begin: 0.05, end: 0.0, duration: 250.ms);
          }),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    const headerStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSmall,
        vertical: AppTheme.spacingSmall,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text('Date',
                style: headerStyle.copyWith(color: secondary)),
          ),
          Expanded(
            flex: 2,
            child: Text('Weight',
                textAlign: TextAlign.center,
                style: headerStyle.copyWith(color: secondary)),
          ),
          Expanded(
            flex: 2,
            child: Text('Reps',
                textAlign: TextAlign.center,
                style: headerStyle.copyWith(color: secondary)),
          ),
          Expanded(
            flex: 2,
            child: Text('Volume',
                textAlign: TextAlign.right,
                style: headerStyle.copyWith(color: secondary)),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({required this.point, required this.isEven});

  final _PerformancePoint point;
  final bool isEven;

  @override
  Widget build(BuildContext context) {
    final date = point.date;
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surfaceVariant = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      color: isEven ? surfaceVariant.withValues(alpha: 0.3) : Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSmall,
        vertical: AppTheme.spacingSmall,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              dateStr,
              style: TextStyle(color: onSurface, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${point.weight.toStringAsFixed(1)} kg',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.accentColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${point.reps}',
              textAlign: TextAlign.center,
              style: TextStyle(color: onSurface, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${point.volume.toStringAsFixed(0)} kg',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
