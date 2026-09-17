import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/analytics/presentation/widgets/strength_chart.dart';
import 'package:progression_tracker/features/analytics/domain/usecases/get_strength_progression_use_case.dart';
import 'package:progression_tracker/features/analytics/domain/entities/strength_progression.dart';

/// Screen for displaying strength progression analytics.
class StrengthProgressionScreen extends ConsumerStatefulWidget {
  final String? exerciseId;

  const StrengthProgressionScreen({
    super.key,
    this.exerciseId,
  });

  @override
  ConsumerState<StrengthProgressionScreen> createState() =>
      _StrengthProgressionScreenState();
}

class _StrengthProgressionScreenState
    extends ConsumerState<StrengthProgressionScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 90));
  DateTime _endDate = DateTime.now();
  bool _show1RM = true;
  bool _showVolume = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strength Progression'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: widget.exerciseId != null
          ? _buildSingleExerciseView()
          : _buildAllExercisesView(),
    );
  }

  Widget _buildSingleExerciseView() {
    return FutureBuilder<StrengthProgression>(
      future: _fetchProgression(widget.exerciseId!),
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

        final progression = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          children: [
            _buildProgressionCard(progression),
            const SizedBox(height: AppTheme.spacingMedium),
            _buildChartControls(),
            const SizedBox(height: AppTheme.spacingMedium),
            AppTheme.glassmorphicCard(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: StrengthChart(
                progression: progression,
                show1RM: _show1RM,
                showVolume: _showVolume,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            _buildDataPointsList(progression),
          ],
        );
      },
    );
  }

  Widget _buildAllExercisesView() {
    return FutureBuilder<List<StrengthProgression>>(
      future: _fetchAllProgressions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final progressions = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          itemCount: progressions.length,
          itemBuilder: (context, index) {
            final progression = progressions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
              child: _buildProgressionCard(progression),
            );
          },
        );
      },
    );
  }

  Widget _buildProgressionCard(StrengthProgression progression) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      progression.exerciseName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progression.muscleGroup,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildTrendIndicator(progression.trend),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Current 1RM',
                  '${progression.currentOneRepMax.toStringAsFixed(1)} kg',
                  AppTheme.primaryColor,
                ),
              ),
              Expanded(
                child: _buildMetric(
                  'Change',
                  '${progression.percentageChange >= 0 ? '+' : ''}${progression.percentageChange.toStringAsFixed(1)}%',
                  progression.percentageChange >= 0
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

  Widget _buildTrendIndicator(ProgressionTrend trend) {
    IconData icon;
    Color color;

    switch (trend) {
      case ProgressionTrend.increasing:
        icon = Icons.trending_up;
        color = AppTheme.successColor;
        break;
      case ProgressionTrend.decreasing:
        icon = Icons.trending_down;
        color = AppTheme.errorColor;
        break;
      case ProgressionTrend.stable:
        icon = Icons.trending_flat;
        color = AppTheme.warningColor;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChartControls() {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Row(
        children: [
          Expanded(
            child: CheckboxListTile(
              title: const Text('Show 1RM'),
              value: _show1RM,
              onChanged: (value) {
                setState(() => _show1RM = value ?? true);
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: CheckboxListTile(
              title: const Text('Show Volume'),
              value: _showVolume,
              onChanged: (value) {
                setState(() => _showVolume = value ?? false);
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPointsList(StrengthProgression progression) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Sessions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          ...progression.dataPoints.reversed.take(5).map((point) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${point.date.month}/${point.date.day}/${point.date.year}',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  Text(
                    '${point.weight.toStringAsFixed(1)} kg × ${point.reps} × ${point.sets}',
                  ),
                  Text(
                    '1RM: ${point.estimatedOneRepMax.toStringAsFixed(1)} kg',
                    style: const TextStyle(color: AppTheme.primaryColor),
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

  Future<StrengthProgression> _fetchProgression(String exerciseId) async {
    // TODO: Replace with actual provider
    throw UnimplementedError('Provider not implemented');
  }

  Future<List<StrengthProgression>> _fetchAllProgressions() async {
    // TODO: Replace with actual provider
    throw UnimplementedError('Provider not implemented');
  }
}
