import 'package:freezed_annotation/freezed_annotation.dart';

part 'weight_data_point.freezed.dart';

/// A lightweight data point used for rendering weight trend graphs.
///
/// [date] is the date of the body entry.
/// [weight] is the recorded weight value.
@freezed
class WeightDataPoint with _$WeightDataPoint {
  const factory WeightDataPoint({
    required DateTime date,
    required double weight,
  }) = _WeightDataPoint;
}
