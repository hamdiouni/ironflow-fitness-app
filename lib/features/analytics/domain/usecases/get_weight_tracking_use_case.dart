import 'package:progression_tracker/features/analytics/domain/entities/weight_tracking.dart';
import 'package:progression_tracker/features/analytics/domain/repositories/analytics_repository.dart';

/// Use case for retrieving weight tracking data.
///
/// Provides weight trends, goal progress, and projections.
class GetWeightTrackingUseCase {
  final AnalyticsRepository _repository;

  GetWeightTrackingUseCase(this._repository);

  /// Gets weight tracking data for a user.
  ///
  /// [userId] - The ID of the user
  /// [startDate] - Start date for the tracking period
  /// [endDate] - End date for the tracking period
  ///
  /// Returns [WeightTracking] with measurements and trends.
  Future<WeightTracking> call({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _repository.getWeightTracking(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Gets recent weight measurements.
  ///
  /// [userId] - The ID of the user
  /// [limit] - Number of recent measurements to return (default: 30)
  ///
  /// Returns list of recent [WeightMeasurement]s.
  Future<List<WeightMeasurement>> getRecentMeasurements({
    required String userId,
    int limit = 30,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: limit));

    final tracking = await call(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    return tracking.measurements.take(limit).toList();
  }

  /// Calculates estimated time to reach goal weight.
  ///
  /// [userId] - The ID of the user
  ///
  /// Returns estimated [DateTime] when goal will be reached,
  /// or null if not on track or insufficient data.
  Future<DateTime?> estimateGoalDate({
    required String userId,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 90));

    final tracking = await call(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    return tracking.projectedGoalDate;
  }
}
