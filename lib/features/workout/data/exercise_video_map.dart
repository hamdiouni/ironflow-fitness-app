import 'exercise_database.dart';

/// Honest coverage report for exercise media mappings against the canonical catalog.
class ExerciseMediaCoverageReport {
  const ExerciseMediaCoverageReport({
    required this.totalCatalogExercises,
    required this.coach1CoveredCount,
    required this.coach2CoveredCount,
    required this.form3dLoopCoveredCount,
    required this.uniqueVerifiedYoutubeIds,
  });

  final int totalCatalogExercises;
  final int coach1CoveredCount;
  final int coach2CoveredCount;
  final int form3dLoopCoveredCount;
  final int uniqueVerifiedYoutubeIds;

  int get fallbackToStepsCount => totalCatalogExercises - coach1CoveredCount;
}

/// Maps exercise names to oEmbed-verified YouTube video IDs and optional 3D form loops.
///
/// Every YouTube ID in [_videoIds], [_secondaryVideoIds], and [verifiedOEmbedIds]
/// has been verified against `https://www.youtube.com/oembed` (HTTP 200).
/// Unverified or 404 IDs are never returned; unmapped exercises fall back to
/// step-by-step form instructions.
class ExerciseVideoMap {
  ExerciseVideoMap._();

  static String _normalize(String s) =>
      s.toLowerCase().trim().replaceAll('-', ' ').replaceAll('_', ' ');

  /// Returns the primary ("Coach 1") oEmbed-verified YouTube video ID for [exerciseName],
  /// or `null` if no verified video is mapped.
  static String? getVideoId(String exerciseName) {
    final rawKey = exerciseName.toLowerCase().trim();
    if (_videoIds.containsKey(rawKey)) {
      return _videoIds[rawKey];
    }

    final normKey = _normalize(exerciseName);
    for (final entry in _videoIds.entries) {
      if (_normalize(entry.key) == normKey) {
        return entry.value;
      }
    }

    // Check common equipment/exercise aliases
    final aliased = _aliases[normKey];
    if (aliased != null && _videoIds.containsKey(aliased)) {
      return _videoIds[aliased];
    }

    // Check exercise definition animationUrl only if it is in verifiedOEmbedIds
    final def = ExerciseDatabase.getByName(exerciseName);
    if (def != null &&
        def.animationUrl.isNotEmpty &&
        def.animationUrl.contains('youtube.com')) {
      final uri = Uri.tryParse(def.animationUrl);
      if (uri != null) {
        final segments = uri.pathSegments;
        final embedIdx = segments.indexOf('embed');
        if (embedIdx != -1 && embedIdx + 1 < segments.length) {
          final id = segments[embedIdx + 1];
          if (id.isNotEmpty && verifiedOEmbedIds.contains(id)) {
            return id;
          }
        }
      }
    }

    return null;
  }

  /// Returns the secondary ("Coach 2") oEmbed-verified YouTube video ID for [exerciseName],
  /// or `null` if no second angle/tutorial is curated.
  static String? getSecondaryVideoId(String exerciseName) {
    final primary = getVideoId(exerciseName);
    final rawKey = exerciseName.toLowerCase().trim();
    String? candidate = _secondaryVideoIds[rawKey];

    if (candidate == null) {
      final normKey = _normalize(exerciseName);
      for (final entry in _secondaryVideoIds.entries) {
        if (_normalize(entry.key) == normKey) {
          candidate = entry.value;
          break;
        }
      }
      if (candidate == null) {
        final aliased = _aliases[normKey];
        if (aliased != null) {
          candidate = _secondaryVideoIds[aliased];
        }
      }
    }

    if (candidate != null &&
        candidate != primary &&
        verifiedOEmbedIds.contains(candidate)) {
      return candidate;
    }
    return null;
  }

  /// Returns up to 2 curated, oEmbed-verified YouTube coaching IDs (`Coach 1`, `Coach 2`).
  static List<String> getCoachVideoIds(String exerciseName) {
    final primary = getVideoId(exerciseName);
    final secondary = getSecondaryVideoId(exerciseName);
    return [
      ?primary,
      if (secondary != null && secondary != primary) secondary,
    ];
  }

  /// Returns an optional "3D Form" loop asset path or URL when supplied in the manifest.
  /// Never fakes a loop when none is registered.
  static String? getFormLoopUrl(String exerciseName) {
    final normKey = _normalize(exerciseName);
    for (final entry in _formLoopUrls.entries) {
      if (_normalize(entry.key) == normKey) {
        return entry.value;
      }
    }
    final aliased = _aliases[normKey];
    if (aliased != null) {
      return _formLoopUrls[aliased];
    }
    return null;
  }

  /// Computes honest media coverage across [canonicalExerciseNames].
  static ExerciseMediaCoverageReport measureCoverage(
    Iterable<String> canonicalExerciseNames,
  ) {
    var total = 0;
    var coach1 = 0;
    var coach2 = 0;
    var form3d = 0;
    for (final name in canonicalExerciseNames) {
      total++;
      if (getVideoId(name) != null) coach1++;
      if (getSecondaryVideoId(name) != null) coach2++;
      if (getFormLoopUrl(name) != null) form3d++;
    }
    return ExerciseMediaCoverageReport(
      totalCatalogExercises: total,
      coach1CoveredCount: coach1,
      coach2CoveredCount: coach2,
      form3dLoopCoveredCount: form3d,
      uniqueVerifiedYoutubeIds: verifiedOEmbedIds.length,
    );
  }

  /// Returns all available exercise names that have verified primary video mappings.
  static List<String> getAllExerciseNames() {
    return _videoIds.keys.toList();
  }

  /// Returns a YouTube thumbnail URL for [exerciseName] (or [videoIdOverride]).
  /// Falls back to exercise database image or generic fitness image if not found.
  static String thumbnailUrl(String exerciseName, {String? videoIdOverride}) {
    final id = videoIdOverride ?? getVideoId(exerciseName);
    if (id != null && id.isNotEmpty) {
      return 'https://img.youtube.com/vi/$id/mqdefault.jpg';
    }
    final def = ExerciseDatabase.getByName(exerciseName);
    if (def != null && def.imageUrl.isNotEmpty) {
      return def.imageUrl;
    }
    return _fallbackImage;
  }

  /// Returns a YouTube watch URL for [exerciseName] (or [videoIdOverride]).
  static String? watchUrl(String exerciseName, {String? videoIdOverride}) {
    final id = videoIdOverride ?? getVideoId(exerciseName);
    if (id == null || id.isEmpty) return null;
    return 'https://www.youtube.com/watch?v=$id';
  }

  /// Returns a YouTube embed URL for [exerciseName] (or [videoIdOverride]).
  static String? videoUrl(String exerciseName, {String? videoIdOverride}) {
    final id = videoIdOverride ?? getVideoId(exerciseName);
    if (id == null || id.isEmpty) return null;
    return 'https://www.youtube.com/embed/$id';
  }

  static const String _fallbackImage =
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400';

  static const Map<String, String> _aliases = {
    'barbell bench press': 'bench press',
    'flat bench press': 'bench press',
    'barbell flat bench press': 'bench press',
    'barbell squat': 'squat',
    'back squat': 'squat',
    'barbell back squat': 'squat',
    'conventional deadlift': 'deadlift',
    'barbell deadlift': 'deadlift',
    'overhead barbell press': 'overhead press',
    'military press': 'overhead press',
    'standing overhead press': 'overhead press',
    'chin up': 'pull-up',
    'chin-up': 'pull-up',
    'pullup': 'pull-up',
    'pushup': 'push-up',
    'cable row': 'seated cable row',
    'seated row': 'seated cable row',
    'dumbbell bicep curl': 'bicep curl',
    'cable pushdown': 'tricep pushdown',
    'cable tricep pushdown': 'tricep pushdown',
    'lying leg curl': 'leg curl',
    'hamstring curl': 'leg curl',
    'standing calf raise': 'calf raise',
    'barbell hip thrust': 'hip thrust',
  };

  /// Optional owner-supplied 3D Form loops (`<exercise_key>: <asset_or_https_url>`).
  /// Empty until licensed loops are added to `assets/data/exercise_media_manifest.json`.
  static const Map<String, String> _formLoopUrls = {};

  /// Curated "Coach 2" secondary YouTube video IDs (oEmbed HTTP 200 verified).
  static const Map<String, String> _secondaryVideoIds = {
    'deadlift': 'r4MzxtBKyNE',
  };

  /// Curated "Coach 1" primary YouTube video IDs (44 keys / 39 unique IDs;
  /// all 10 dead 404 IDs removed after oEmbed verification).
  static const Map<String, String> _videoIds = {
    'bench press': 'rT7DgCr-3pg',
    'squat': 'ultWZbUMPL8',
    'deadlift': 'op9kVnSso6Q',
    'overhead press': 'F3QY5vMz_6I',
    'barbell row': '9efgcAjQe7E',
    'pull-up': 'eGo4IYlbE5g',
    'dip': '2z8JmcrW-As',
    'incline bench press': 'DbFgADa2PL8',
    'romanian deadlift': 'JCXUYuzwNrM',
    'leg press': 'IZxyjW7MPJQ',
    'lunges': 'QOVaHwm-Q6U',
    'bicep curl': 'ykJmrZ5v0Oo',
    'barbell curl': 'ykJmrZ5v0Oo',
    'dumbbell curl': 'ykJmrZ5v0Oo',
    'tricep pushdown': 'vB5OHsJ3EME',
    'lateral raise': 'XPPfnSEATJA',
    'face pull': 'rep-qVOkqgk',
    'running': 'brFHyOtTwH4',
    'crunch': 'Xyd_fa5zoEU',
    'leg raise': 'JB2oyawG9KI',
    'hip thrust': 'SEdqd1n0cvg',
    'glute bridge': 'OUgsJ8-Vi0E',
    'lat pulldown': 'CAwf7n6Luuc',
    'seated cable row': 'GZbfZ033f74',
    'dumbbell row': '6TSP1TRMUzs',
    'push-up': 'IODxDxX7oi4',
    'hammer curl': 'zC3nLlEvin4',
    'calf raise': 'gwLzBJYoWlI',
    'leg curl': 'ELOCsoDSmrg',
    'leg extension': 'YyvSfVjQeL0',
    'cable crossover': 'taI4XduLpTk',
    'pec deck': 'Z57CtFmRMxA',
    'chest dip': '2z8JmcrW-As',
    'dumbbell fly': 'eozdVDA78K0',
    'arnold press': '6Z15_WdXmVw',
    'front raise': 'hRJ6tR5-if0',
    'dumbbell shoulder press': 'qEwKCR5JCog',
    'overhead tricep extension': 'nRiJVZDpdL0',
    'preacher curl': 'fIWP-FRFNU0',
    't-bar row': 'j3Igk5nyZE4',
    'russian twist': 'wkD8rjkodUI',
    'cable crunch': 'Xyd_fa5zoEU',
    'jump rope': 'u3zgHI8QnqE',
    'hip thrust barbell': 'SEdqd1n0cvg',
  };

  /// Allowlist of all 40 YouTube video IDs verified as HTTP 200 via YouTube oEmbed.
  static const Set<String> verifiedOEmbedIds = {
    '2z8JmcrW-As',
    '6TSP1TRMUzs',
    '6Z15_WdXmVw',
    '9efgcAjQe7E',
    'CAwf7n6Luuc',
    'DbFgADa2PL8',
    'ELOCsoDSmrg',
    'F3QY5vMz_6I',
    'GZbfZ033f74',
    'IODxDxX7oi4',
    'IZxyjW7MPJQ',
    'JB2oyawG9KI',
    'JCXUYuzwNrM',
    'OUgsJ8-Vi0E',
    'QOVaHwm-Q6U',
    'SEdqd1n0cvg',
    'XPPfnSEATJA',
    'Xyd_fa5zoEU',
    'YyvSfVjQeL0',
    'Z57CtFmRMxA',
    'brFHyOtTwH4',
    'eGo4IYlbE5g',
    'eozdVDA78K0',
    'fIWP-FRFNU0',
    'gwLzBJYoWlI',
    'hRJ6tR5-if0',
    'j3Igk5nyZE4',
    'nRiJVZDpdL0',
    'op9kVnSso6Q',
    'qEwKCR5JCog',
    'r4MzxtBKyNE',
    'rT7DgCr-3pg',
    'rep-qVOkqgk',
    'taI4XduLpTk',
    'u3zgHI8QnqE',
    'ultWZbUMPL8',
    'vB5OHsJ3EME',
    'wkD8rjkodUI',
    'ykJmrZ5v0Oo',
    'zC3nLlEvin4',
  };
}
