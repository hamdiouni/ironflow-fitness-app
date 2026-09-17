/// Utility class for sampling chart data points to improve rendering performance.
///
/// When displaying graphs with large datasets, rendering every data point can
/// be expensive. This sampler reduces the number of points to a manageable
/// maximum while preserving the overall shape of the data.
///
/// Requirements: 16.2
class ChartDataSampler {
  ChartDataSampler._();

  /// Returns a sampled subset of [data] with at most [maxPoints] elements.
  ///
  /// - If [data.length] <= [maxPoints], the original list is returned unchanged.
  /// - Otherwise, [maxPoints] items are evenly selected across the full range,
  ///   always including the first and last elements to preserve boundaries.
  ///
  /// Example:
  /// ```dart
  /// final sampled = ChartDataSampler.sample(myPoints, maxPoints: 100);
  /// ```
  static List<T> sample<T>(List<T> data, {int maxPoints = 100}) {
    if (data.length <= maxPoints) return data;

    final result = <T>[];
    final step = (data.length - 1) / (maxPoints - 1);

    for (var i = 0; i < maxPoints; i++) {
      final index = (i * step).round().clamp(0, data.length - 1);
      result.add(data[index]);
    }

    return result;
  }
}
