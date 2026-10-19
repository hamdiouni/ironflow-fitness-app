import '../../entities/exercise_definition.dart';
import 'movement_pattern.dart';

/// Template defining a single training session's focus and movement slots.
class DayTemplate {
  const DayTemplate({
    required this.id,
    required this.name,
    required this.shortName,
    required this.focus,
    required this.primaryMuscles,
    this.secondaryMuscles = const [],
    required this.slots,
  });

  final String id;
  final String name;
  final String shortName;
  final String focus;
  final List<MuscleGroup> primaryMuscles;
  final List<MuscleGroup> secondaryMuscles;
  final List<SlotDefinition> slots;

  DayTemplate copyWith({
    String? id,
    String? name,
    String? shortName,
    String? focus,
    List<MuscleGroup>? primaryMuscles,
    List<MuscleGroup>? secondaryMuscles,
    List<SlotDefinition>? slots,
  }) {
    return DayTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      focus: focus ?? this.focus,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      slots: slots ?? this.slots,
    );
  }
}
