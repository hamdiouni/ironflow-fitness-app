import 'package:progression_tracker/features/analytics/domain/entities/performance_prediction.dart';
import 'package:progression_tracker/features/analytics/domain/repositories/analytics_repository.dart';

/// Use case for generating AI-powered performance predictions.
///
/// Uses historical data and machine learning to predict future performance.
class PredictPerformanceUseCase {
  final AnalyticsRepository _repository;

  PredictPerformanceUseCase(this._repository);

  /// Generates performance predictions for a user.
  ///
  /// [userId] - The ID of the user
  /// [predictionDays] - Number of days to predict ahead (default: 30)
  ///
  /// Returns [PerformancePrediction] with exercise and overall predictions.
  Future<PerformancePrediction> call({
    required String userId,
    int predictionDays = 30,
  }) async {
    return await _repository.predictPerformance(
      userId: userId,
      predictionDays: predictionDays,
    );
  }

  /// Gets predictions for a specific exercise.
  ///
  /// [userId] - The ID of the user
  /// [exerciseId] - The ID of the exercise
  /// [predictionDays] - Number of days to predict ahead (default: 30)
  ///
  /// Returns [ExercisePrediction] for the specified exercise,
  /// or null if insufficient data.
  Future<ExercisePrediction?> getExercisePrediction({
    required String userId,
    required String exerciseId,
    int predictionDays = 30,
  }) async {
    final prediction = await call(
      userId: userId,
      predictionDays: predictionDays,
    );

    try {
      return prediction.exercisePredictions.firstWhere(
        (p) => p.exerciseId == exerciseId,
      );
    } catch (e) {
      return null;
    }
  }

  /// Gets top predicted improvements.
  ///
  /// [userId] - The ID of the user
  /// [limit] - Number of exercises to return (default: 5)
  /// [predictionDays] - Number of days to predict ahead (default: 30)
  ///
  /// Returns list of [ExercisePrediction] sorted by improvement percentage.
  Future<List<ExercisePrediction>> getTopPredictedImprovements({
    required String userId,
    int limit = 5,
    int predictionDays = 30,
  }) async {
    final prediction = await call(
      userId: userId,
      predictionDays: predictionDays,
    );

    // Sort by improvement percentage (descending)
    final sorted = List<ExercisePrediction>.from(prediction.exercisePredictions);
    sorted.sort((a, b) => b.improvementPercentage.compareTo(a.improvementPercentage));

    // Return top N
    return sorted.take(limit).toList();
  }

  /// Checks if predictions are reliable.
  ///
  /// [userId] - The ID of the user
  /// [predictionDays] - Number of days to predict ahead (default: 30)
  ///
  /// Returns true if confidence level is >= 0.7.
  Future<bool> arePredictionsReliable({
    required String userId,
    int predictionDays = 30,
  }) async {
    final prediction = await call(
      userId: userId,
      predictionDays: predictionDays,
    );

    return prediction.isReliable;
  }
}
