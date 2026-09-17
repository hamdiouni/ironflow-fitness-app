import 'package:freezed_annotation/freezed_annotation.dart';

part 'performance_prediction.freezed.dart';
part 'performance_prediction.g.dart';

/// Represents AI-powered performance predictions.
///
/// Uses historical data to predict future performance and suggest goals.
@freezed
class PerformancePrediction with _$PerformancePrediction {
  const factory PerformancePrediction({
    /// User ID
    required String userId,

    /// Exercise-specific predictions
    required List<ExercisePrediction> exercisePredictions,

    /// Overall strength prediction
    required OverallPrediction overallStrength,

    /// Weight goal prediction
    OverallPrediction? weightGoal,

    /// Consistency prediction
    required OverallPrediction consistency,

    /// Confidence level (0.0 to 1.0)
    required double confidenceLevel,

    /// Date when prediction was generated
    required DateTime generatedAt,

    /// Prediction timeframe (e.g., 30, 60, 90 days)
    required int predictionDays,
  }) = _PerformancePrediction;

  factory PerformancePrediction.fromJson(Map<String, dynamic> json) =>
      _$PerformancePredictionFromJson(json);

  const PerformancePrediction._();

  /// Gets prediction date (generated + prediction days)
  DateTime get predictionDate =>
      generatedAt.add(Duration(days: predictionDays));

  /// Checks if prediction is reliable (confidence > 0.7)
  bool get isReliable => confidenceLevel >= 0.7;
}

/// Prediction for a specific exercise.
@freezed
class ExercisePrediction with _$ExercisePrediction {
  const factory ExercisePrediction({
    /// Exercise ID
    required String exerciseId,

    /// Exercise name
    required String exerciseName,

    /// Current 1RM
    required double currentOneRepMax,

    /// Predicted 1RM
    required double predictedOneRepMax,

    /// Expected improvement percentage
    required double improvementPercentage,

    /// Suggested training approach
    required String trainingRecommendation,

    /// Confidence in this prediction (0.0 to 1.0)
    required double confidence,

    /// Historical data points used for prediction
    required int dataPointsUsed,
  }) = _ExercisePrediction;

  factory ExercisePrediction.fromJson(Map<String, dynamic> json) =>
      _$ExercisePredictionFromJson(json);

  const ExercisePrediction._();

  /// Gets the absolute improvement
  double get absoluteImprovement => predictedOneRepMax - currentOneRepMax;
}

/// Overall prediction for a metric.
@freezed
class OverallPrediction with _$OverallPrediction {
  const factory OverallPrediction({
    /// Current value
    required double currentValue,

    /// Predicted value
    required double predictedValue,

    /// Change from current to predicted
    required double change,

    /// Percentage change
    required double percentageChange,

    /// Trend direction
    required PredictionTrend trend,

    /// Recommendation text
    required String recommendation,

    /// Confidence level (0.0 to 1.0)
    required double confidence,
  }) = _OverallPrediction;

  factory OverallPrediction.fromJson(Map<String, dynamic> json) =>
      _$OverallPredictionFromJson(json);

  const OverallPrediction._();

  /// Checks if prediction shows improvement
  bool get showsImprovement => change > 0;
}

/// Trend direction for predictions.
enum PredictionTrend {
  strongIncrease,
  increase,
  stable,
  decrease,
  strongDecrease,
}
