import '../entities/exercise_definition.dart';
import 'exercise_alias_resolver.dart';
import 'exercise_catalog_lower.dart';
import 'exercise_catalog_upper.dart';

/// Domain-layer canonical exercise catalog and O(1) lookup index (Wave 3.4).
///
/// Deduplicated from 150 raw entries (which had 27 duplicate IDs and 20
/// duplicate names) to 129 unique canonical exercises, while resolving all
/// historical/colliding IDs and name aliases via [ExerciseAliasResolver].
class ExerciseCatalog {
  const ExerciseCatalog._();

  /// Historical raw entry count prior to Wave 3.4 deduplication.
  static const int legacyRawCount = ExerciseAliasResolver.legacyRawEntryCount;

  /// All 129 unique canonical exercises.
  static const List<ExerciseDefinition> all = [
    ...kCanonicalExercisesPart1,
    ...kCanonicalExercisesPart2,
  ];

  static final Map<String, ExerciseDefinition> _byId = {
    for (final e in all) e.id.toLowerCase(): e,
  };

  static final Map<String, ExerciseDefinition> _byNormalizedName = {
    for (final e in all) ExerciseAliasResolver.normalizeName(e.name): e,
  };

  /// Finds an [ExerciseDefinition] by canonical or legacy/aliased [id].
  ///
  /// When [exerciseName] is also supplied (e.g. from a logged workout set),
  /// colliding legacy IDs (such as `back_010` used for both `Chin-Up` and
  /// `Seal Row`) are disambiguated deterministically.
  static ExerciseDefinition? getById(String id, {String? exerciseName}) {
    final resolvedId = ExerciseAliasResolver.resolveCanonicalId(
      storedDefinitionId: id,
      exerciseName: exerciseName,
      canonicalIdByName: (normName) => _byNormalizedName[normName]?.id,
    );
    if (resolvedId == null) return null;
    return _byId[resolvedId.toLowerCase()];
  }

  /// Finds an [ExerciseDefinition] by case-insensitive name or alias.
  static ExerciseDefinition? getByName(String name) {
    final canonicalName = ExerciseAliasResolver.resolveCanonicalName(name);
    if (canonicalName.isEmpty) return null;
    return _byNormalizedName[canonicalName];
  }

  /// Filters exercises by primary or secondary [MuscleGroup].
  static List<ExerciseDefinition> getByMuscleGroup(MuscleGroup group) {
    return all
        .where((e) =>
            e.muscleGroup == group ||
            e.primaryMuscles.contains(group) ||
            e.secondaryMuscles.contains(group))
        .toList();
  }

  /// Filters exercises by [Equipment].
  static List<ExerciseDefinition> getByEquipment(Equipment equipment) {
    return all.where((e) => e.equipment == equipment).toList();
  }

  /// Searches exercises by name, subMuscle, or muscle group.
  static List<ExerciseDefinition> search(String query) {
    if (query.trim().isEmpty) return all;
    final q = query.toLowerCase().trim();
    final aliasResolved = ExerciseAliasResolver.resolveCanonicalName(q);
    return all
        .where((e) =>
            e.name.toLowerCase().contains(q) ||
            e.name.toLowerCase().contains(aliasResolved) ||
            e.subMuscle.toLowerCase().contains(q) ||
            e.muscleGroup.name.toLowerCase().contains(q))
        .toList();
  }
}
