import 'package:freezed_annotation/freezed_annotation.dart';

part 'weight_tracking.freezed.dart';
part 'weight_tracking.g.dart';

/// Represents body weight tracking data over time.
///
/// Tracks weight changes, trends, and goals.
@freezed
class WeightTracking with _$WeightTracking {
  const factory WeightTracking({
    /// User ID
    required String userId,

    /// List of weight measurements over time
    required List<WeightMeasurement> measurements,

    /// Current weight (most recent measurement)
    required double currentWeight,

    /// Starting weight (first measurement)
    required double startingWeight,

    /// Goal weight
    required double goalWeight,

    /// Weight change from start to current
    required double totalChange,

    /// Average weekly change
    required double averageWeeklyChange,

    /// Projected date to reach goal (if trend continues)
    DateTime? projectedGoalDate,

    /// Date range for this tracking data
    required DateTime startDate,
    required DateTime endDate,
  }) = _WeightTracking;

  factory WeightTracking.fromJson(Map<String, dynamic> json) =>
      _$WeightTrackingFromJson(json);

  const WeightTracking._();

  /// Checks if user is on track to reach goal
  bool get isOnTrack {
    if (goalWeight > startingWeight) {
      // Gaining weight
      return currentWeight > startingWeight && averageWeeklyChange > 0;
    } else {
      // Losing weight
      return currentWeight < startingWeight && averageWeeklyChange < 0;
    }
  }

  /// Gets the progress percentage towards goal
  double get progressPercentage {
    final totalNeeded = (goalWeight - startingWeight).abs();
    final achieved = (currentWeight - startingWeight).abs();
    return (achieved / totalNeeded * 100).clamp(0.0, 100.0);
  }

  /// Gets the trend direction
  WeightTrend get trend {
    if (averageWeeklyChange > 0.2) return WeightTrend.increasing;
    if (averageWeeklyChange < -0.2) return WeightTrend.decreasing;
    return WeightTrend.stable;
  }
}

/// Individual weight measurement.
@freezed
class WeightMeasurement with _$WeightMeasurement {
  const factory WeightMeasurement({
    /// Date of measurement
    required DateTime date,

    /// Weight in kg or lbs
    required double weight,

    /// Optional note about the measurement
    String? note,

    /// Body fat percentage (optional)
    double? bodyFatPercentage,

    /// Muscle mass (optional)
    double? muscleMass,
  }) = _WeightMeasurement;

  factory WeightMeasurement.fromJson(Map<String, dynamic> json) =>
      _$WeightMeasurementFromJson(json);
}

/// Trend direction for weight.
enum WeightTrend {
  increasing,
  stable,
  decreasing,
}
