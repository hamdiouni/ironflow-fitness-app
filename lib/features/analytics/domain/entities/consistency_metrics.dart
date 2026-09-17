import 'package:freezed_annotation/freezed_annotation.dart';

part 'consistency_metrics.freezed.dart';
part 'consistency_metrics.g.dart';

/// Represents workout consistency metrics.
///
/// Tracks workout frequency, adherence, and patterns.
@freezed
class ConsistencyMetrics with _$ConsistencyMetrics {
  const factory ConsistencyMetrics({
    /// User ID
    required String userId,

    /// Total number of workouts in period
    required int totalWorkouts,

    /// Number of weeks in the tracking period
    required int totalWeeks,

    /// Average workouts per week
    required double averageWorkoutsPerWeek,

    /// Current streak (consecutive days with workouts)
    required int currentStreak,

    /// Longest streak achieved
    required int longestStreak,

    /// Adherence rate (0.0 to 1.0)
    /// Based on planned vs completed workouts
    required double adherenceRate,

    /// Weekly consistency data for heatmap
    required List<WeeklyConsistency> weeklyData,

    /// Most active day of week (0 = Monday, 6 = Sunday)
    required int mostActiveDay,

    /// Least active day of week
    required int leastActiveDay,

    /// Average workout duration in minutes
    required double averageDuration,

    /// Date range for these metrics
    required DateTime startDate,
    required DateTime endDate,
  }) = _ConsistencyMetrics;

  factory ConsistencyMetrics.fromJson(Map<String, dynamic> json) =>
      _$ConsistencyMetricsFromJson(json);

  const ConsistencyMetrics._();

  /// Gets consistency rating
  ConsistencyRating get rating {
    if (adherenceRate >= 0.9) return ConsistencyRating.excellent;
    if (adherenceRate >= 0.75) return ConsistencyRating.good;
    if (adherenceRate >= 0.5) return ConsistencyRating.fair;
    return ConsistencyRating.needsImprovement;
  }

  /// Checks if user is consistent (>75% adherence)
  bool get isConsistent => adherenceRate >= 0.75;

  /// Gets the day name for most active day
  String get mostActiveDayName => _getDayName(mostActiveDay);

  /// Gets the day name for least active day
  String get leastActiveDayName => _getDayName(leastActiveDay);

  String _getDayName(int day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[day % 7];
  }
}

/// Weekly consistency data for a specific week.
@freezed
class WeeklyConsistency with _$WeeklyConsistency {
  const factory WeeklyConsistency({
    /// Week start date
    required DateTime weekStart,

    /// Number of workouts completed this week
    required int workoutsCompleted,

    /// Number of workouts planned this week
    required int workoutsPlanned,

    /// Daily workout status (7 days, true = workout done)
    required List<bool> dailyStatus,

    /// Total volume for the week
    required double totalVolume,

    /// Adherence rate for this week (0.0 to 1.0)
    required double adherenceRate,
  }) = _WeeklyConsistency;

  factory WeeklyConsistency.fromJson(Map<String, dynamic> json) =>
      _$WeeklyConsistencyFromJson(json);
}

/// Consistency rating levels.
enum ConsistencyRating {
  excellent,
  good,
  fair,
  needsImprovement,
}
