import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/validators.dart';

part 'set_entry.freezed.dart';

/// Represents a single set performed during an exercise.
///
/// Use [SetEntry.create] to construct a validated instance. The default
/// constructor is available for deserialization only.
///
/// [id] is a UUID uniquely identifying this set.
/// [reps] must be a positive integer.
/// [weight] must be a positive number (in kg or lb, as chosen by the user).
/// [rpe] is an optional Rate of Perceived Exertion value (1–10).
/// [timestamp] records when the set was logged.
@freezed
class SetEntry with _$SetEntry {
  const factory SetEntry({
    required String id,
    required int reps,
    required double weight,
    int? rpe,
    required DateTime timestamp,
  }) = _SetEntry;

  /// Factory constructor with validation
  factory SetEntry.create({
    required int reps,
    required double weight,
    int? rpe,
  }) {
    if (!Validators.isValidReps(reps)) {
      throw InvalidRepsException();
    }
    if (!Validators.isValidWeight(weight)) {
      throw InvalidWeightException();
    }
    if (!Validators.isValidRPE(rpe)) {
      throw InvalidRPEException();
    }

    return SetEntry(
      id: const Uuid().v4(),
      reps: reps,
      weight: weight,
      rpe: rpe,
      timestamp: DateTime.now(),
    );
  }
}
