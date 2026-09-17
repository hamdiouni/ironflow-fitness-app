import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import 'measurement_type.dart';

part 'body_entry.freezed.dart';

/// A single body-tracking snapshot recorded by the user.
///
/// Use [BodyEntry.create] to construct a validated instance. The default
/// constructor is available for deserialization only.
///
/// [id] is a UUID uniquely identifying this entry.
/// [date] is when the entry was recorded.
/// [weight] must be a positive number (in kg or lb, as chosen by the user).
/// [measurements] maps each [MeasurementType] to its value in cm or inches.
/// [photoPath] is an optional local file path to a progress photo.
@freezed
class BodyEntry with _$BodyEntry {
  const factory BodyEntry({
    required String id,
    required DateTime date,
    required double weight,
    required Map<MeasurementType, double> measurements,
    String? photoPath,
  }) = _BodyEntry;

  /// Factory constructor with validation
  factory BodyEntry.create({
    required double weight,
    Map<MeasurementType, double>? measurements,
    String? photoPath,
  }) {
    if (weight <= 0) throw InvalidWeightException();

    return BodyEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      weight: weight,
      measurements: measurements ?? {},
      photoPath: photoPath,
    );
  }
}
