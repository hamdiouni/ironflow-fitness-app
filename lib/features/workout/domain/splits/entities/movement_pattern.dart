import '../../entities/exercise_definition.dart';

/// Movement pattern classification for exercise slots.
enum MovementPattern {
  horizontalPush,
  verticalPush,
  horizontalPull,
  verticalPull,
  kneeDominant,
  hipHinge,
  deltoidIsolation,
  bicepIsolation,
  tricepIsolation,
  calfIsolation,
  core,
  fullBodyCardio,
}

/// A slot within a [DayTemplate] representing a targeted biomechanical stimulus.
class SlotDefinition {
  const SlotDefinition({
    required this.id,
    required this.name,
    required this.pattern,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    this.isCompound = true,
    this.notes,
  });

  final String id;
  final String name;
  final MovementPattern pattern;
  final MuscleGroup primaryMuscle;
  final List<MuscleGroup> secondaryMuscles;
  final bool isCompound;
  final String? notes;
}
