import '../entities/entities.dart';
import '../repositories/nutrition_repository.dart';

/// Use case for retrieving paginated nutrition history.
///
/// Implements lazy loading pattern for efficient handling of large datasets.
/// Loads nutrition data in batches (default 20 days) to optimize performance.
///
/// **Validates: Requirements 8.1 (Lazy Loading)**
class GetNutritionHistoryPaginatedUseCase {
  final NutritionRepository _repository;

  GetNutritionHistoryPaginatedUseCase(this._repository);

  /// Get paginated nutrition history.
  ///
  /// [offset] - Number of days to skip (for pagination)
  /// [limit] - Maximum number of days to return (default 20)
  ///
  /// Returns list of [DailyNutritionSummary] sorted by date descending.
  Future<List<DailyNutritionSummary>> call({
    int offset = 0,
    int limit = 20,
  }) async {
    return await _repository.getNutritionHistoryPaginated(
      offset: offset,
      limit: limit,
    );
  }
}

/// Use case for getting total count of nutrition history days.
///
/// Used for pagination calculations and UI display.
///
/// **Validates: Requirements 8.1 (Lazy Loading)**
class GetNutritionHistoryCountUseCase {
  final NutritionRepository _repository;

  GetNutritionHistoryCountUseCase(this._repository);

  /// Get total count of days with nutrition data.
  ///
  /// Returns the total number of days that have at least one meal logged.
  Future<int> call() async {
    return await _repository.getNutritionHistoryCount();
  }
}
