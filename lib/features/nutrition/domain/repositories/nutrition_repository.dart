import '../entities/entities.dart';

/// Abstract repository interface for nutrition data persistence.
///
/// Implementations live in the data layer; the domain layer depends only
/// on this abstraction (Dependency Inversion Principle).
///
/// Supports offline-first pattern with cloud sync:
/// - Local operations saved to Hive immediately
/// - Cloud sync happens when online
/// - Conflict resolution uses last-write-wins strategy
abstract class NutritionRepository {
  /// Get daily nutrition totals for a specific date.
  ///
  /// Returns aggregated nutrition data including:
  /// - Total macros (calories, protein, carbs, fats)
  /// - Total micros (fiber, sugar, sodium, potassium)
  /// - Total vitamins (A, B, C, D, E)
  /// - Total minerals (calcium, iron, magnesium, zinc)
  /// - All meals logged for that day
  Future<DailyNutritionSummary> getDailyNutrition(DateTime date);

  /// Save a meal entry to local storage and queue for cloud sync.
  ///
  /// The meal is immediately saved to Hive for offline access.
  /// If online, it's also synced to Firestore.
  /// If offline, it's queued for sync when online.
  Future<void> saveMealEntry(Meal meal);

  /// Get nutrition history for a date range.
  ///
  /// Returns all daily nutrition summaries between [startDate] and [endDate].
  /// Useful for analytics and trend analysis.
  Future<List<DailyNutritionSummary>> getNutritionHistory(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get nutrition history with pagination support (lazy loading).
  ///
  /// Returns daily nutrition summaries in batches for efficient loading.
  /// [offset] - Number of days to skip
  /// [limit] - Maximum number of days to return (default 20)
  /// Returns summaries sorted by date descending.
  Future<List<DailyNutritionSummary>> getNutritionHistoryPaginated({
    int offset = 0,
    int limit = 20,
  });

  /// Get total count of days with nutrition data.
  ///
  /// Used for pagination to know total available items.
  Future<int> getNutritionHistoryCount();

  /// Get the user's nutrition targets.
  ///
  /// Returns the current nutrition targets for macros, micros, vitamins, and minerals.
  /// Returns null if targets haven't been set yet.
  Future<NutritionTargets?> getNutritionTargets();

  /// Save nutrition targets.
  ///
  /// Updates the user's daily nutrition targets.
  /// Targets are used to track progress and provide feedback.
  Future<void> saveNutritionTargets(NutritionTargets targets);

  /// Delete a meal entry by ID.
  ///
  /// Removes the meal from local storage and queues deletion for cloud sync.
  Future<void> deleteMealEntry(String mealId);

  /// Get all meals for a specific date.
  ///
  /// Returns all meal entries logged for the given date.
  Future<List<Meal>> getMealsByDate(DateTime date);

  /// Clear all local nutrition data.
  ///
  /// Used for logout or data reset.
  Future<void> clearAllData();
}
