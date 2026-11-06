import '../domain/entities/exercise_definition.dart';
import '../domain/services/exercise_catalog.dart';

/// Backward-compatible data-layer facade delegating to [ExerciseCatalog].
class ExerciseDatabase {
  ExerciseDatabase._();

  /// Historical raw entry count before Wave 3.4 deduplication (150).
  static const int legacyRawCount = ExerciseCatalog.legacyRawCount;

  /// All 129 unique canonical exercises.
  static const List<ExerciseDefinition> all = ExerciseCatalog.all;

  /// Find exercise definition by canonical or legacy ID.
  static ExerciseDefinition? getById(String id, {String? exerciseName}) =>
      ExerciseCatalog.getById(id, exerciseName: exerciseName);

  /// Find exercise definition by name or alias (case-insensitive).
  static ExerciseDefinition? getByName(String name) =>
      ExerciseCatalog.getByName(name);

  /// Filter exercises by muscle group (primary or secondary).
  static List<ExerciseDefinition> getByMuscleGroup(MuscleGroup group) =>
      ExerciseCatalog.getByMuscleGroup(group);

  /// Filter exercises by equipment.
  static List<ExerciseDefinition> getByEquipment(Equipment equipment) =>
      ExerciseCatalog.getByEquipment(equipment);

  /// Search exercises by name, muscle, or sub-muscle.
  static List<ExerciseDefinition> search(String query) =>
      ExerciseCatalog.search(query);
}
