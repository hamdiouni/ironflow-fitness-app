import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/body_entry.dart';
import '../../domain/entities/measurement_type.dart';

part 'body_entry_model.freezed.dart';
part 'body_entry_model.g.dart';

@freezed
class BodyEntryModel with _$BodyEntryModel {
  const factory BodyEntryModel({
    required String id,
    required String date, // ISO 8601 string
    required double weight,
    required Map<String, double> measurements, // MeasurementType.name → double
    String? photoPath,
    // Phase 1 schema v2 — nullable so pre-v2 stored JSON still loads.
    String? userId,
    // Phase 2: LWW key + tombstone (ISO 8601 strings).
    String? updatedAt,
    String? deletedAt,
  }) = _BodyEntryModel;

  factory BodyEntryModel.fromJson(Map<String, dynamic> json) =>
      _$BodyEntryModelFromJson(json);

  factory BodyEntryModel.fromEntity(BodyEntry entry) {
    return BodyEntryModel(
      id: entry.id,
      date: entry.date.toIso8601String(),
      weight: entry.weight,
      measurements: entry.measurements
          .map((type, value) => MapEntry(type.name, value)),
      photoPath: entry.photoPath,
      userId: entry.userId,
      updatedAt: entry.updatedAt?.toIso8601String(),
      deletedAt: entry.deletedAt?.toIso8601String(),
    );
  }
}

extension BodyEntryModelX on BodyEntryModel {
  BodyEntry toEntity() {
    return BodyEntry(
      id: id,
      date: DateTime.parse(date),
      weight: weight,
      measurements: measurements.map(
        (key, value) => MapEntry(
          MeasurementType.values.firstWhere((e) => e.name == key),
          value,
        ),
      ),
      photoPath: photoPath,
      userId: userId,
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      deletedAt: deletedAt != null ? DateTime.parse(deletedAt!) : null,
    );
  }
}
