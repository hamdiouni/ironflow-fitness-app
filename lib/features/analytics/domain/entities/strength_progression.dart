import 'package:freezed_annotation/freezed_annotation.dart';

part 'strength_progression.freezed.dart';
part 'strength_progression.g.dart';

/// Represents strength progression data for a specific exercise.
///
/// Tracks weight, reps, and volume over time to show progress.
@freezed
class StrengthProgression with _$StrengthProgression {
  const factory StrengthProgression({
    /// Exercise ID
    required String exerciseId,

    /// Exercise name
    required String exerciseName,

    /// Muscle group targeted
    required String muscleGroup,

    /// List of data points over time
    required List<StrengthDataPoint> dataPoints,

    /// Current one-rep max (1RM) estimate
    required double currentOneRepMax,

    /// Previous one-rep max for comparison
    required double previousOneRepMax,

    /// Percentage change in 1RM
    required double percentageChange,

    /// Total volume lifted (weight × reps × sets)
    required double totalVolume,

    /// Date range for this progression data
    required DateTime startDate,
    required DateTime endDate,
  }) = _StrengthProgression;

  factory StrengthProgression.fromJson(Map<String, dynamic> json) =>
      _$StrengthProgressionFromJson(json);

  const StrengthProgression._();

  /// Checks if there's positive progression
  bool get hasProgressed => percentageChange > 0;

  /// Gets the trend direction
  ProgressionTrend get trend {
    if (percentageChange > 5) return ProgressionTrend.increasing;
    if (percentageChange < -5) return ProgressionTrend.decreasing;
    return ProgressionTrend.stable;
  }
}

/// Individual data point in strength progression.
@freezed
class StrengthDataPoint with _$StrengthDataPoint {
  const factory StrengthDataPoint({
    /// Date of the workout
    required DateTime date,

    /// Weight lifted (in kg or lbs)
    required double weight,

    /// Number of reps performed
    required int reps,

    /// Number of sets performed
    required int sets,

    /// Calculated volume (weight × reps × sets)
    required double volume,

    /// Estimated 1RM for this session
    required double estimatedOneRepMax,
  }) = _StrengthDataPoint;

  factory StrengthDataPoint.fromJson(Map<String, dynamic> json) =>
      _$StrengthDataPointFromJson(json);
}

/// Trend direction for progression.
enum ProgressionTrend {
  increasing,
  stable,
  decreasing,
}
