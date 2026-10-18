import 'exercise_database.dart';

/// Maps exercise names to YouTube video IDs for demo previews.
/// These are short, publicly available exercise tutorial videos.
class ExerciseVideoMap {
  ExerciseVideoMap._();

  static String _normalize(String s) =>
      s.toLowerCase().trim().replaceAll('-', ' ').replaceAll('_', ' ');

  /// Returns the YouTube video ID for the given exercise name.
  /// Returns null if no video is mapped for this exercise.
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

    // Check exercise definition animationUrl in database
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
          if (id.isNotEmpty && id != 'dQw4w9WgXcQ') {
            return id;
          }
        }
      }
    }

    return null;
  }

  /// Returns all available exercise names that have video mappings.
  static List<String> getAllExerciseNames() {
    return _videoIds.keys.toList();
  }

  /// Returns a YouTube thumbnail URL for the given exercise name.
  /// Falls back to exercise database image or generic fitness image if not found.
  static String thumbnailUrl(String exerciseName) {
    final id = getVideoId(exerciseName);
    if (id != null) {
      return 'https://img.youtube.com/vi/$id/mqdefault.jpg';
    }
    final def = ExerciseDatabase.getByName(exerciseName);
    if (def != null && def.imageUrl.isNotEmpty) {
      return def.imageUrl;
    }
    return _fallbackImage;
  }

  /// Returns a YouTube watch URL for the given exercise name.
  static String? watchUrl(String exerciseName) {
    final id = getVideoId(exerciseName);
    if (id == null) return null;
    return 'https://www.youtube.com/watch?v=$id';
  }

  /// Returns a YouTube video URL for embedding/streaming the given exercise name.
  static String? videoUrl(String exerciseName) {
    final id = getVideoId(exerciseName);
    if (id == null) return null;
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
    'cycling': 'mmq5zGIFqoI',
    'plank': 'ASdvSXt_IIo',
    'crunch': 'Xyd_fa5zoEU',
    'leg raise': 'JB2oyawG9KI',
    'hip thrust': 'SEdqd1n0cvg',
    'glute bridge': 'OUgsJ8-Vi0E',
    'lat pulldown': 'CAwf7n6Luuc',
    'seated cable row': 'GZbfZ033f74',
    'dumbbell row': '6TSP1TRMUzs',
    'push-up': 'IODxDxX7oi4',
    'hammer curl': 'zC3nLlEvin4',
    'skull crusher': 'NIKnFMKHHKA',
    'calf raise': 'gwLzBJYoWlI',
    'hack squat': 'EdtPAT0oCqQ',
    'bulgarian split squat': 'vEAuMFNFHFQ',
    'leg curl': 'ELOCsoDSmrg',
    'leg extension': 'YyvSfVjQeL0',
    'cable crossover': 'taI4XduLpTk',
    'pec deck': 'Z57CtFmRMxA',
    'chest dip': '2z8JmcrW-As',
    'dumbbell fly': 'eozdVDA78K0',
    'arnold press': '6Z15_WdXmVw',
    'front raise': 'hRJ6tR5-if0',
    'reverse fly': 'ttvAXjsOTME',
    'dumbbell shoulder press': 'qEwKCR5JCog',
    'overhead tricep extension': 'nRiJVZDpdL0',
    'close grip bench press': 'nEF0bv2FW7s',
    'preacher curl': 'fIWP-FRFNU0',
    't-bar row': 'j3Igk5nyZE4',
    'sumo deadlift': 'WIs_-s4XTFU',
    'russian twist': 'wkD8rjkodUI',
    'cable crunch': 'Xyd_fa5zoEU',
    'jump rope': 'u3zgHI8QnqE',
    'rowing machine': 'H0r_D6OhGDs',
    'stair climber': 'Iy_72HDnCdY',
    'hip thrust barbell': 'SEdqd1n0cvg',
  };
}
