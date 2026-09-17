import 'package:progression_tracker/features/analytics/domain/entities/consistency_metrics.dart';
import 'package:progression_tracker/features/analytics/domain/entities/performance_prediction.dart';
import 'package:progression_tracker/features/analytics/domain/entities/strength_progression.dart';
import 'package:progression_tracker/features/analytics/domain/entities/weight_tracking.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';

/// Repository interface for analytics data.
///
/// Provides methods to retrieve and analyze workout, nutrition, and body metrics.
abstract class AnalyticsRepository {
  /// Gets strength progression for a specific exercise.
  ///
  /// [exerciseId] - The ID of the exercise to analyze
  /// [startDate] - Start date for the analysis period
  /// [endDate] - End date for the analysis period
  ///
  /// Returns [StrengthProgression] with calculated metrics.
  Future<StrengthProgression> getStrengthProgression({
    required String exerciseId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Gets strength progression for all exercises.
  ///
  /// [startDate] - Start date for the analysis period
  /// [endDate] - End date for the analysis period
  ///
  /// Returns list of [StrengthProgression] for all exercises.
  Future<List<StrengthProgression>> getAllStrengthProgressions({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Gets weight tracking data for a user.
  ///
  /// [userId] - The ID of the user
  /// [startDate] - Start date for the tracking period
  /// [endDate] - End date for the tracking period
  ///
  /// Returns [WeightTracking] with measurements and trends.
  Future<WeightTracking> getWeightTracking({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Gets consistency metrics for a user.
  ///
  /// [userId] - The ID of the user
  /// [userProfile] - The user's profile containing workoutDaysPerWeek
  /// [startDate] - Start date for the analysis period
  /// [endDate] - End date for the analysis period
  ///
  /// Returns [ConsistencyMetrics] with calculated metrics.
  Future<ConsistencyMetrics> getConsistencyMetrics({
    required String userId,
    required UserProfile? userProfile,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Generates performance predictions for a user.
  ///
  /// [userId] - The ID of the user
  /// [predictionDays] - Number of days to predict ahead
  ///
  /// Returns [PerformancePrediction] with exercise and overall predictions.
  Future<PerformancePrediction> predictPerformance({
    required String userId,
    required int predictionDays,
  });
}
