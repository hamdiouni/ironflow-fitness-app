import 'package:flutter/material.dart';

/// A structured exercise from the preloaded exercise database.
///
/// This is distinct from [Exercise] (which represents a logged exercise in a
/// workout session). [ExerciseDefinition] is the catalogue entry.
class ExerciseDefinition {
  const ExerciseDefinition({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.subMuscle,
    required this.equipment,
    required this.difficulty,
    required this.imageUrl,
    required this.animationUrl,
    required this.instructions,
    required this.primaryMuscles,
    this.secondaryMuscles = const [],
    this.primaryRegions = const [],
    this.secondaryRegions = const [],
    this.provenance = 'IronFlow Exercise Catalog v2',
    this.license = 'First-Party / Original',
  });

  final String id;
  final String name;
  final MuscleGroup muscleGroup;
  final String subMuscle;
  final Equipment equipment;
  final Difficulty difficulty;

  /// Network URL for the exercise demonstration image.
  final String imageUrl;

  /// Network URL for the Lottie animation JSON (exercise movement demo).
  final String animationUrl;

  /// Short instruction text shown on the exercise detail screen.
  final String instructions;

  /// List of muscles highlighted on the body diagram.
  final List<MuscleGroup> primaryMuscles;

  /// Secondary coarse muscle groups engaged by this exercise.
  final List<MuscleGroup> secondaryMuscles;

  /// Canonical anatomical primary muscle region IDs for the Body Map (Wave 4).
  final List<String> primaryRegions;

  /// Canonical anatomical secondary muscle region IDs for the Body Map (Wave 4).
  final List<String> secondaryRegions;

  /// Data provenance and license metadata (Wave 3.4).
  final String provenance;
  final String license;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'muscleGroup': muscleGroup.name,
        'subMuscle': subMuscle,
        'equipment': equipment.name,
        'difficulty': difficulty.name,
        'imageUrl': imageUrl,
        'animationUrl': animationUrl,
        'instructions': instructions,
        'primaryMuscles': primaryMuscles.map((m) => m.name).toList(),
        'secondaryMuscles': secondaryMuscles.map((m) => m.name).toList(),
        'primaryRegions': primaryRegions,
        'secondaryRegions': secondaryRegions,
        'provenance': provenance,
        'license': license,
      };

  factory ExerciseDefinition.fromJson(Map<String, dynamic> json) {
    MuscleGroup parseMuscle(String raw) => MuscleGroup.values.firstWhere(
          (m) => m.name == raw,
          orElse: () => MuscleGroup.fullBody,
        );
    return ExerciseDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      muscleGroup: parseMuscle(json['muscleGroup'] as String? ?? 'fullBody'),
      subMuscle: json['subMuscle'] as String? ?? '',
      equipment: Equipment.values.firstWhere(
        (e) => e.name == (json['equipment'] as String? ?? 'bodyweight'),
        orElse: () => Equipment.bodyweight,
      ),
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == (json['difficulty'] as String? ?? 'intermediate'),
        orElse: () => Difficulty.intermediate,
      ),
      imageUrl: json['imageUrl'] as String? ?? '',
      animationUrl: json['animationUrl'] as String? ?? '',
      instructions: json['instructions'] as String? ?? '',
      primaryMuscles: (json['primaryMuscles'] as List<dynamic>? ?? const [])
          .map((e) => parseMuscle(e.toString()))
          .toList(),
      secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>? ?? const [])
          .map((e) => parseMuscle(e.toString()))
          .toList(),
      primaryRegions: (json['primaryRegions'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      secondaryRegions: (json['secondaryRegions'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      provenance:
          json['provenance'] as String? ?? 'IronFlow Exercise Catalog v2',
      license: json['license'] as String? ?? 'First-Party / Original',
    );
  }
}

enum MuscleGroup {
  chest,
  back,
  legs,
  shoulders,
  arms,
  abs,
  glutes,
  cardio,
  fullBody,
}

enum Equipment {
  barbell,
  dumbbell,
  machine,
  bodyweight,
  cable,
  kettlebell,
  band,
}

enum Difficulty { beginner, intermediate, advanced }

extension MuscleGroupX on MuscleGroup {
  String get displayName => switch (this) {
        MuscleGroup.chest => 'Chest',
        MuscleGroup.back => 'Back',
        MuscleGroup.legs => 'Legs',
        MuscleGroup.shoulders => 'Shoulders',
        MuscleGroup.arms => 'Arms',
        MuscleGroup.abs => 'Abs',
        MuscleGroup.glutes => 'Glutes',
        MuscleGroup.cardio => 'Cardio',
        MuscleGroup.fullBody => 'Full Body',
      };

  Color get color => switch (this) {
        MuscleGroup.chest => const Color(0xFF4FC3F7),
        MuscleGroup.back => const Color(0xFF81C784),
        MuscleGroup.legs => const Color(0xFFFFB74D),
        MuscleGroup.shoulders => const Color(0xFFBA68C8),
        MuscleGroup.arms => const Color(0xFFFF8A65),
        MuscleGroup.abs => const Color(0xFFFFD54F),
        MuscleGroup.glutes => const Color(0xFFF06292),
        MuscleGroup.cardio => const Color(0xFF4DB6AC),
        MuscleGroup.fullBody => const Color(0xFF90A4AE),
      };
}

extension EquipmentX on Equipment {
  String get displayName => switch (this) {
        Equipment.barbell => 'Barbell',
        Equipment.dumbbell => 'Dumbbell',
        Equipment.machine => 'Machine',
        Equipment.bodyweight => 'Bodyweight',
        Equipment.cable => 'Cable',
        Equipment.kettlebell => 'Kettlebell',
        Equipment.band => 'Band',
      };
}

extension DifficultyX on Difficulty {
  int get level => switch (this) {
        Difficulty.beginner => 1,
        Difficulty.intermediate => 2,
        Difficulty.advanced => 3,
      };

  Color get color => switch (this) {
        Difficulty.beginner => const Color(0xFF81C784),
        Difficulty.intermediate => const Color(0xFFFFB74D),
        Difficulty.advanced => const Color(0xFFEF5350),
      };
}
