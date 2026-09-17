import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/analytics/presentation/widgets/prediction_chart.dart';
import 'package:progression_tracker/features/analytics/domain/entities/performance_prediction.dart';

/// Screen for displaying AI-powered performance predictions.
class PerformancePredictionScreen extends ConsumerStatefulWidget {
  const PerformancePredictionScreen({super.key});

  @override
  ConsumerState<PerformancePredictionScreen> createState() =>
      _PerformancePredictionScreenState();
}

class _PerformancePredictionScreenState
    extends ConsumerState<PerformancePredictionScreen> {
  int _predictionDays = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Predictions'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (days) {
              setState(() => _predictionDays = days);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 30, child: Text('30 Days')),
              const PopupMenuItem(value: 60, child: Text('60 Days')),
              const PopupMenuItem(value: 90, child: Text('90 Days')),
            ],
          ),
        ],
      ),
      body: FutureBuilder<PerformancePrediction>(
        future: _fetchPrediction(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No predictions available'));
          }

          final prediction = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            children: [
              _buildConfidenceCard(prediction),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildOverallPredictionCard(prediction),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildChartCard(prediction),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildExercisePredictionsList(prediction),
            ],
          );
        },
      ),
    );
  }

  Widget _buildConfidenceCard(PerformancePrediction prediction) {
    final confidence = (prediction.confidenceLevel * 100).toStringAsFixed(0);
    final isReliable = prediction.isReliable;

    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isReliable ? AppTheme.successColor : AppTheme.warningColor)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isReliable ? Icons.verified : Icons.info_outline,
              color: isReliable ? AppTheme.successColor : AppTheme.warningColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$confidence% Confidence',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isReliable
                      ? 'Predictions are reliable'
                      : 'More data needed for accurate predictions',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallPredictionCard(PerformancePrediction prediction) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Strength Prediction',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Row(
            children: [
              Expanded(
                child: _buildPredictionMetric(
                  'Current',
                  prediction.overallStrength.currentValue.toStringAsFixed(0),
                  AppTheme.accentColor,
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: AppTheme.textSecondary,
              ),
              Expanded(
                child: _buildPredictionMetric(
                  'Predicted',
                  prediction.overallStrength.predictedValue.toStringAsFixed(0),
                  AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildTrendIndicator(prediction.overallStrength.trend),
          const SizedBox(height: AppTheme.spacingMedium),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    prediction.overallStrength.recommendation,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(PerformancePrediction prediction) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Predicted Improvements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          PredictionChart(predictions: prediction.exercisePredictions),
          const SizedBox(height: AppTheme.spacingMedium),
          const PredictionLegend(),
        ],
      ),
    );
  }

  Widget _buildExercisePredictionsList(PerformancePrediction prediction) {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exercise Predictions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          ...prediction.exercisePredictions.map((exercisePrediction) {
            return _buildExercisePredictionCard(exercisePrediction);
          }),
        ],
      ),
    );
  }

  Widget _buildExercisePredictionCard(ExercisePrediction prediction) {
    final improvement = prediction.improvementPercentage;
    final isPositive = improvement > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  prediction.exerciseName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (isPositive ? AppTheme.successColor : AppTheme.errorColor)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${improvement.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isPositive ? AppTheme.successColor : AppTheme.errorColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current 1RM',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '${prediction.currentOneRepMax.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Predicted 1RM',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '${prediction.predictedOneRepMax.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.tips_and_updates,
                  color: AppTheme.accentColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    prediction.trainingRecommendation,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionMetric(String label, String value, Color color) {
    return Column(
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
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendIndicator(PredictionTrend trend) {
    IconData icon;
    Color color;
    String label;

    switch (trend) {
      case PredictionTrend.strongIncrease:
        icon = Icons.trending_up;
        color = AppTheme.successColor;
        label = 'Strong Increase';
        break;
      case PredictionTrend.increase:
        icon = Icons.trending_up;
        color = AppTheme.primaryColor;
        label = 'Increase';
        break;
      case PredictionTrend.stable:
        icon = Icons.trending_flat;
        color = AppTheme.warningColor;
        label = 'Stable';
        break;
      case PredictionTrend.decrease:
        icon = Icons.trending_down;
        color = AppTheme.warningColor;
        label = 'Decrease';
        break;
      case PredictionTrend.strongDecrease:
        icon = Icons.trending_down;
        color = AppTheme.errorColor;
        label = 'Strong Decrease';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<PerformancePrediction> _fetchPrediction() async {
    // TODO: Replace with actual provider
    throw UnimplementedError('Provider not implemented');
  }
}
