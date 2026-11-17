/// Resolves legacy, colliding, or aliased exercise IDs and names to their
/// unique canonical `ExerciseDefinition.id` (Wave 3.4 & Addendum).
///
/// Historical context:
/// Prior to Wave 3.4, `ExerciseDatabase.all` contained 150 raw entries with
/// 27 duplicate IDs and 20 exact duplicate names (+ 1 `'Elliptical'` alias of
/// `'Elliptical Machine'`), yielding **129 unique canonical exercises**.
class ExerciseAliasResolver {
  const ExerciseAliasResolver._();

  /// Raw entry count prior to Wave 3.4 deduplication.
  static const int legacyRawEntryCount = 150;

  /// Canonical unique exercise count after deduplicating 21 duplicate entries.
  static const int canonicalExerciseCount = 129;

  /// IDs that only existed on duplicate entries and now unconditionally map
  /// to the canonical exercise ID of the primary entry.
  static const Map<String, String> retiredIdToCanonicalId = {
    'back_013': 'back_009', // Assisted Pull-Up
    'back_014': 'back_010', // Chin-Up
    'shoulders_010': 'shoulders_008', // Shrug
    'fullbody_003': 'specialty_001', // Kettlebell Swing
    'fullbody_004': 'specialty_002', // Battle Ropes
  };

  /// Distinct exercises from the second batch of `ExerciseDatabase` whose
  /// legacy IDs collided with an earlier exercise and were reassigned a unique
  /// canonical ID in Wave 3.4.
  ///
  /// Key format: `'${legacyId.toLowerCase()}::${normalizedExerciseName}'`.
  static const Map<String, String> collidingIdAndNameToCanonicalId = {
    // 11 distinct exercises reassigned to non-colliding canonical IDs
    'back_010::seal row': 'back_016',
    'back_011::inverted row': 'back_017',
    'legs_015::v-squat': 'legs_016',
    'shoulders_008::pike push-up': 'shoulders_011',
    'shoulders_009::upright row': 'shoulders_012',
    'cardio_008::swimming': 'cardio_010',
    'glutes_004::smith machine hip thrust': 'glutes_009',
    'glutes_005::banded hip thrust': 'glutes_010',
    'glutes_006::glute kickback': 'glutes_011',
    'glutes_007::cable pull-through': 'glutes_012',
    'glutes_008::single-leg hip thrust': 'glutes_013',

    // 6 duplicate-name exercises whose second occurrence had a swapped/colliding ID
    'abs_006::ab wheel rollout': 'abs_007',
    'abs_007::hanging leg raise': 'abs_006',
    'arms_010::dips': 'arms_011',
    'back_009::machine row': 'back_011',
    'glutes_003::leg press (glute focus)': 'glutes_006',
    'legs_014::smith machine squat': 'glutes_007',
  };

  /// Normalized exercise name aliases mapped to canonical exercise names
  /// (lowercase).
  static const Map<String, String> nameAliasesToCanonicalName = {
    'elliptical': 'elliptical machine',
    'elliptical trainer': 'elliptical machine',
    'barbell bench press': 'bench press',
    'flat barbell bench press': 'bench press',
    'flat bench press': 'bench press',
    'bb bench press': 'bench press',
    'barbell squat': 'squat',
    'back squat': 'squat',
    'pullup': 'pull-up',
    'pushup': 'push-up',
    'chin up': 'chin-up',
  };

  /// Normalizes an exercise name for deterministic lookup.
  static String normalizeName(String name) =>
      name.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Resolves a canonical exercise name (lowercase) from [rawName].
  static String resolveCanonicalName(String rawName) {
    final normalized = normalizeName(rawName);
    return nameAliasesToCanonicalName[normalized] ?? normalized;
  }

  /// Resolves the canonical `ExerciseDefinition.id` given a stored
  /// [storedDefinitionId] and/or [exerciseName], plus a [canonicalIdByName]
  /// lookup function from the catalog.
  static String? resolveCanonicalId({
    String? storedDefinitionId,
    String? exerciseName,
    String? Function(String canonicalLowerName)? canonicalIdByName,
  }) {
    final rawId = storedDefinitionId?.trim();
    final normName =
        exerciseName != null ? normalizeName(exerciseName) : null;

    // 1. Check explicit (legacyCollidingId, exerciseName) pair first
    if (rawId != null &&
        rawId.isNotEmpty &&
        normName != null &&
        normName.isNotEmpty) {
      final pairKey = '${rawId.toLowerCase()}::$normName';
      final reassigned = collidingIdAndNameToCanonicalId[pairKey];
      if (reassigned != null) {
        return reassigned;
      }
    }

    // 2. If name is provided and catalog lookup is available, verify if the
    //    name unambiguously identifies a canonical exercise (handles cases
    //    where a historical record had a colliding ID stamped).
    if (normName != null &&
        normName.isNotEmpty &&
        canonicalIdByName != null) {
      final canonicalName = resolveCanonicalName(normName);
      final byNameId = canonicalIdByName(canonicalName);
      if (byNameId != null) {
        return byNameId;
      }
    }

    // 3. Check retired duplicate IDs (e.g. back_013 -> back_009)
    if (rawId != null && rawId.isNotEmpty) {
      return retiredIdToCanonicalId[rawId.toLowerCase()] ?? rawId;
    }

    return null;
  }
}

