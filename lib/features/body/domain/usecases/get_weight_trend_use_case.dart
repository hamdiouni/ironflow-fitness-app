import '../entities/weight_data_point.dart';
import '../repositories/body_repository.dart';

/// Retrieves body entries within a date range and maps them to
/// [WeightDataPoint] values suitable for chart rendering.
class GetWeightTrendUseCase {
  final BodyRepository repository;

  GetWeightTrendUseCase(this.repository);

  Future<List<WeightDataPoint>> call(DateTime start, DateTime end) async {
    final entries = await repository.getBodyEntriesByDateRange(start, end);
    return entries
        .map((entry) => WeightDataPoint(date: entry.date, weight: entry.weight))
        .toList();
  }
}
