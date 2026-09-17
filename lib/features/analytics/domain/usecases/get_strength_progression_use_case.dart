import 'package:progression_tracker/features/analytics/domain/entities/strength_progression.dart';
import 'package:progression_tracker/features/analytics/domain/repositories/analytics_repository.dart';

/// Use case for retrieving strength progression data for exercises.
///
/// Calculates progression metrics including 1RM estimates, volume trends,
/// and percentage improvements over time.
class GetStrengthProgressionUseCase {
  final AnalyticsRepository _repository;

  GetStrengthProgressionUseCase(this._repository);

  /// Gets strength progression for a specific exercise.
  ///
  /// [exerciseId] - The ID of the exercise to analyze
  /// [startDate] - Start date for the analysis period
  /// [endDate] - End date for the analysis period
  ///
  /// Returns [StrengthProgression] with calculated metrics.
  Future<StrengthProgression> call({
    required String exerciseId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _repository.getStrengthProgression(
      exerciseId: exerciseId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Gets strength progression for all exercises.
  ///
  /// [startDate] - Start date for the analysis period
  /// [endDate] - End date for the analysis period
  ///
  /// Returns list of [StrengthProgression] for all exercises.
  Future<List<StrengthProgression>> getAllProgressions({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _repository.getAllStrengthProgressions(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Gets top improving exercises.
  ///
  /// [limit] - Number of exercises to return (default: 5)
  /// [startDate] - Start date for the analysis period
  /// [endDate] - End date for the analysis period
  ///
  /// Returns list of [StrengthProgression] sorted by improvement percentage.
  Future<List<StrengthProgression>> getTopImproving({
    int limit = 5,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final allProgressions = await getAllProgressions(
      startDate: startDate,
      endDate: endDate,
    );

    // Sort by percentage change (descending)
    allProgressions.sort((a, b) => b.percentageChange.compareTo(a.percentageChange));

    // Return top N
    return allProgressions.take(limit).toList();
  }
}
