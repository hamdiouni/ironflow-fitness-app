import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/analytics/presentation/widgets/weight_chart.dart';
import 'package:progression_tracker/features/analytics/domain/entities/weight_tracking.dart';

/// Screen for displaying weight tracking analytics.
class WeightTrackingScreen extends ConsumerStatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  ConsumerState<WeightTrackingScreen> createState() =>
      _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends ConsumerState<WeightTrackingScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 90));
  DateTime _endDate = DateTime.now();
  bool _showGoalLine = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: FutureBuilder<WeightTracking>(
        future: _fetchWeightTracking(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final tracking = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            children: [
              _buildSummaryCard(tracking),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildProgressCard(tracking),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildChartControls(),
              const SizedBox(height: AppTheme.spacingMedium),
              AppTheme.glassmorphicCard(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: WeightChart(
                  tracking: tracking,
                  showGoalLine: _showGoalLine,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildMeasurementsList(tracking),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMeasurement,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(WeightTracking tracking) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weight Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Current',
                  '${tracking.currentWeight.toStringAsFixed(1)} kg',
                  AppTheme.primaryColor,
                ),
              ),
              Expanded(
                child: _buildMetric(
                  'Goal',
                  '${tracking.goalWeight.toStringAsFixed(1)} kg',
                  AppTheme.accentColor,
                ),
              ),
              Expanded(
                child: _buildMetric(
                  'Change',
                  '${tracking.totalChange >= 0 ? '+' : ''}${tracking.totalChange.toStringAsFixed(1)} kg',
                  tracking.totalChange >= 0
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(WeightTracking tracking) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTrendIndicator(tracking.trend),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          LinearProgressIndicator(
            value: tracking.progressPercentage / 100,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              tracking.isOnTrack ? AppTheme.successColor : AppTheme.warningColor,
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${tracking.progressPercentage.toStringAsFixed(1)}% to goal',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              if (tracking.projectedGoalDate != null)
                Text(
                  'ETA: ${tracking.projectedGoalDate!.month}/${tracking.projectedGoalDate!.day}/${tracking.projectedGoalDate!.year}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildWeeklyChange(tracking),
        ],
      ),
    );
  }

  Widget _buildWeeklyChange(WeightTracking tracking) {
    final isGaining = tracking.averageWeeklyChange > 0;
    final color = isGaining ? AppTheme.successColor : AppTheme.accentColor;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSmall),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isGaining ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Average: ${tracking.averageWeeklyChange.abs().toStringAsFixed(2)} kg/week',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendIndicator(WeightTrend trend) {
    IconData icon;
    Color color;
    String label;

    switch (trend) {
      case WeightTrend.increasing:
        icon = Icons.trending_up;
        color = AppTheme.successColor;
        label = 'Gaining';
        break;
      case WeightTrend.decreasing:
        icon = Icons.trending_down;
        color = AppTheme.accentColor;
        label = 'Losing';
        break;
      case WeightTrend.stable:
        icon = Icons.trending_flat;
        color = AppTheme.warningColor;
        label = 'Stable';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChartControls() {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: CheckboxListTile(
        title: const Text('Show Goal Line'),
        value: _showGoalLine,
        onChanged: (value) {
          setState(() => _showGoalLine = value ?? true);
        },
        dense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildMeasurementsList(WeightTracking tracking) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Measurements',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          ...tracking.measurements.reversed.take(10).map((measurement) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${measurement.date.month}/${measurement.date.day}/${measurement.date.year}',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  Text(
                    '${measurement.weight.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (measurement.bodyFatPercentage != null)
                    Text(
                      '${measurement.bodyFatPercentage!.toStringAsFixed(1)}% BF',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _addMeasurement() async {
    // TODO: Show dialog to add new measurement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add measurement dialog - TODO')),
    );
  }

  Future<WeightTracking> _fetchWeightTracking() async {
    // TODO: Replace with actual provider
    throw UnimplementedError('Provider not implemented');
  }
}
