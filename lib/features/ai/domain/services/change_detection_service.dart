import 'package:progression_tracker/features/ai/domain/entities/insight.dart';

/// Service interface for detecting changes in user data
///
/// The ChangeDetectionService determines if data has changed since the last
/// insight generation, enabling intelligent cache invalidation and avoiding
/// unnecessary regeneration of insights.
///
/// **Strategy:**
/// - Tracks last update timestamps for each data source
/// - Compares current data timestamps with cached insight timestamps
/// - Returns boolean indicating if regeneration is needed
///
/// **Requirements:**
/// - 4.4: Use Change Detection to avoid recalculating insights when data unchanged
/// - 4.5: Do not regenerate insights on every screen load
/// - 11.5: Compare data timestamps to cache timestamps
abstract class ChangeDetectionService {
  /// Check if workout data has changed since last generation
  ///
  /// Compares the timestamp of the most recent workout with the
  /// last generation timestamp to determine if new workout data exists.
  ///
  /// **Parameters:**
  /// - [lastGenerated]: Timestamp of the last insight generation
  ///
  /// **Returns:**
  /// True if workout data has changed, false otherwise
  ///
  /// **Requirements:**
  /// - 4.4: Use Change Detection to avoid recalculating insights
  /// - 11.5: Compare data timestamps to cache timestamps
  Future<bool> hasWorkoutDataChanged(DateTime lastGenerated);

  /// Check if nutrition data has changed since last generation
  ///
  /// Compares the timestamp of the most recent nutrition entry with the
  /// last generation timestamp to determine if new nutrition data exists.
  ///
  /// **Parameters:**
  /// - [lastGenerated]: Timestamp of the last insight generation
  ///
  /// **Returns:**
  /// True if nutrition data has changed, false otherwise
  ///
  /// **Requirements:**
  /// - 4.4: Use Change Detection to avoid recalculating insights
  /// - 11.5: Compare data timestamps to cache timestamps
  Future<bool> hasNutritionDataChanged(DateTime lastGenerated);

  /// Check if body data has changed since last generation
  ///
  /// Compares the timestamp of the most recent body entry with the
  /// last generation timestamp to determine if new body data exists.
  ///
  /// **Parameters:**
  /// - [lastGenerated]: Timestamp of the last insight generation
  ///
  /// **Returns:**
  /// True if body data has changed, false otherwise
  ///
  /// **Requirements:**
  /// - 4.4: Use Change Detection to avoid recalculating insights
  /// - 11.5: Compare data timestamps to cache timestamps
  Future<bool> hasBodyDataChanged(DateTime lastGenerated);

  /// Get timestamp of last data change for a context
  ///
  /// Returns the most recent timestamp of data changes relevant to the
  /// given context. This helps determine if cached insights are still valid.
  ///
  /// **Context-specific data sources:**
  /// - Home: All data sources (workout, nutrition, body)
  /// - Workout: Workout data only
  /// - Nutrition: Nutrition data only
  /// - Profile: Body data and workout data
  ///
  /// **Parameters:**
  /// - [context]: The insight context to check
  ///
  /// **Returns:**
  /// The timestamp of the last data change, or null if no data exists
  ///
  /// **Requirements:**
  /// - 3.3: Track the last update timestamp for each Context
  /// - 4.4: Use Change Detection to avoid recalculating insights
  /// - 11.5: Compare data timestamps to cache timestamps
  Future<DateTime?> getLastDataChange(InsightContext context);
}
