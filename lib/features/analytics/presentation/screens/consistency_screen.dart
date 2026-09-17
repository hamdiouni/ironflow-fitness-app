import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/analytics/presentation/widgets/consistency_heatmap.dart';
import 'package:progression_tracker/features/analytics/domain/entities/consistency_metrics.dart';

/// Screen for displaying workout consistency analytics.
class ConsistencyScreen extends ConsumerStatefulWidget {
  const ConsistencyScreen({super.key});

  @override
  ConsumerState<ConsistencyScreen> createState() => _ConsistencyScreenState();
}

class _ConsistencyScreenState extends ConsumerState<ConsistencyScreen> {
  int _weeks = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Consistency'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (weeks) {
              setState(() => _weeks = weeks);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 4, child: Text('4 Weeks')),
              const PopupMenuItem(value: 8, child: Text('8 Weeks')),
              const PopupMenuItem(value: 12, child: Text('12 Weeks')),
              const PopupMenuItem(value: 24, child: Text('24 Weeks')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<ConsistencyMetrics>(
        future: _fetchConsistencyMetrics(),
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

          final metrics = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            children: [
              _buildOverviewCard(metrics),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildStreakCard(metrics),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildAdherenceCard(metrics),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildHeatmapCard(metrics),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildActivityPatternsCard(metrics),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewCard(ConsistencyMetrics metrics) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
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
                  'Total Workouts',
                  metrics.totalWorkouts.toString(),
                  AppTheme.primaryColor,
                  Icons.fitness_center,
                ),
              ),
              Expanded(
                child: _buildMetric(
                  'Avg/Week',
                  metrics.averageWorkoutsPerWeek.toStringAsFixed(1),
                  AppTheme.accentColor,
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(ConsistencyMetrics metrics) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Streaks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Row(
            children: [
              Expanded(
                child: _buildStreakMetric(
                  'Current',
                  metrics.currentStreak,
                  Colors.orange,
                  Icons.local_fire_department,
                ),
              ),
              Expanded(
                child: _buildStreakMetric(
                  'Longest',
                  metrics.longestStreak,
                  AppTheme.primaryColor,
                  Icons.emoji_events,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdherenceCard(ConsistencyMetrics metrics) {
    final percentage = (metrics.adherenceRate * 100).toStringAsFixed(0);
    final rating = metrics.rating;

    Color ratingColor;
    String ratingText;

    switch (rating) {
      case ConsistencyRating.excellent:
        ratingColor = AppTheme.successColor;
        ratingText = 'Excellent';
        break;
      case ConsistencyRating.good:
        ratingColor = AppTheme.primaryColor;
        ratingText = 'Good';
        break;
      case ConsistencyRating.fair:
        ratingColor = AppTheme.warningColor;
        ratingText = 'Fair';
        break;
      case ConsistencyRating.needsImprovement:
        ratingColor = AppTheme.errorColor;
        ratingText = 'Needs Improvement';
        break;
    }

    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Adherence Rate',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ratingColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  ratingText,
                  style: TextStyle(
                    color: ratingColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: ratingColor,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'of planned workouts',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          LinearProgressIndicator(
            value: metrics.adherenceRate,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(ratingColor),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapCard(ConsistencyMetrics metrics) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Heatmap',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          ConsistencyHeatmap(weeklyData: metrics.weeklyData),
        ],
      ),
    );
  }

  Widget _buildActivityPatternsCard(ConsistencyMetrics metrics) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Patterns',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildPatternRow(
            'Most Active Day',
            metrics.mostActiveDayName,
            AppTheme.successColor,
            Icons.trending_up,
          ),
          const SizedBox(height: 8),
          _buildPatternRow(
            'Least Active Day',
            metrics.leastActiveDayName,
            AppTheme.warningColor,
            Icons.trending_down,
          ),
          const SizedBox(height: 8),
          _buildPatternRow(
            'Avg Duration',
            '${metrics.averageDuration.toStringAsFixed(0)} min',
            AppTheme.accentColor,
            Icons.timer,
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakMetric(String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$label Streak',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternRow(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<ConsistencyMetrics> _fetchConsistencyMetrics() async {
    // TODO: Replace with actual provider
    throw UnimplementedError('Provider not implemented');
  }
}
