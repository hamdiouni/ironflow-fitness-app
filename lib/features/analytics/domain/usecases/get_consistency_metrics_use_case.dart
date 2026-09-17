import 'package:progression_tracker/features/analytics/domain/entities/consistency_metrics.dart';
import 'package:progression_tracker/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';

/// Use case for retrieving workout consistency metrics.
///
/// Analyzes workout frequency, adherence, streaks, and patterns.
class GetConsistencyMetricsUseCase {
  final AnalyticsRepository _repository;

  GetConsistencyMetricsUseCase(this._repository);

  /// Gets consistency metrics for a user.
  ///
  /// [userId] - The ID of the user
  /// [userProfile] - The user's profile containing workoutDaysPerWeek
  /// [startDate] - Start date for the analysis period
  /// [endDate] - End date for the analysis period
  ///
  /// Returns [ConsistencyMetrics] with calculated metrics.
  Future<ConsistencyMetrics> call({
    required String userId,
    required UserProfile? userProfile,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _repository.getConsistencyMetrics(
      userId: userId,
      userProfile: userProfile,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Gets consistency metrics for the last N weeks.
  ///
  /// [userId] - The ID of the user
  /// [userProfile] - The user's profile containing workoutDaysPerWeek
  /// [weeks] - Number of weeks to analyze (default: 12)
  ///
  /// Returns [ConsistencyMetrics] for the specified period.
  Future<ConsistencyMetrics> getLastNWeeks({
    required String userId,
    required UserProfile? userProfile,
    int weeks = 12,
  }) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: weeks * 7));

    return await call(
      userId: userId,
      userProfile: userProfile,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Gets weekly consistency data for heatmap visualization.
  ///
  /// [userId] - The ID of the user
  /// [userProfile] - The user's profile containing workoutDaysPerWeek
  /// [weeks] - Number of weeks to include (default: 12)
  ///
  /// Returns list of [WeeklyConsistency] for heatmap.
  Future<List<WeeklyConsistency>> getWeeklyData({
    required String userId,
    required UserProfile? userProfile,
    int weeks = 12,
  }) async {
    final metrics = await getLastNWeeks(
      userId: userId,
      userProfile: userProfile,
      weeks: weeks,
    );

    return metrics.weeklyData;
  }

  /// Checks if user is meeting their consistency goals.
  ///
  /// [userId] - The ID of the user
  /// [userProfile] - The user's profile containing workoutDaysPerWeek
  /// [targetAdherence] - Target adherence rate (default: 0.75)
  ///
  /// Returns true if user meets or exceeds target adherence.
  Future<bool> isConsistent({
    required String userId,
    required UserProfile? userProfile,
    double targetAdherence = 0.75,
  }) async {
    final metrics = await getLastNWeeks(
      userId: userId,
      userProfile: userProfile,
      weeks: 4,
    );
    return metrics.adherenceRate >= targetAdherence;
  }
}
