import 'dart:collection';

/// Result of a question normalization and cache lookup.
class AiQuestionResolution {
  final String normalizedKey;
  final String compositeCacheKey;
  final bool isCanonicalFaq;
  final String? cachedResponse;

  const AiQuestionResolution({
    required this.normalizedKey,
    this.compositeCacheKey = '',
    required this.isCanonicalFaq,
    this.cachedResponse,
  });
}

/// Token and cost estimation utility for AI interactions (Wave 6.1 & Wave 7.5 — AI-05).
class AiCostEstimator {
  const AiCostEstimator();

  /// Gemini 2.5 Flash pricing (per 1 million tokens):
  /// Input: $0.075 / 1M tokens ($0.000000075 / token)
  /// Output: $0.30 / 1M tokens ($0.00000030 / token)
  static const double inputCostPerToken = 0.000000075;
  static const double outputCostPerToken = 0.00000030;

  /// Approximates token count for text using standard ~4 chars/token heuristic.
  static int estimateTokenCount(String text) {
    if (text.trim().isEmpty) return 0;
    final trimmed = text.trim();
    // Words + punctuation approximation for English/multilingual text
    final words = trimmed.split(RegExp(r'\s+')).length;
    final charEstimate = (trimmed.length / 3.8).ceil();
    return words > charEstimate ? words : charEstimate;
  }

  /// Calculates cost in USD for a given input and output token count.
  static double calculateCostUsd({
    required int inputTokens,
    required int outputTokens,
  }) {
    final inputCost = inputTokens * inputCostPerToken;
    final outputCost = outputTokens * outputCostPerToken;
    return inputCost + outputCost;
  }

  /// Formats cost into human-readable string.
  static String formatCostUsd(double costUsd) {
    if (costUsd <= 0.0) return '\$0.00';
    if (costUsd < 0.0001) return '<\$0.0001';
    return '\$${costUsd.toStringAsFixed(4)}';
  }
}

/// Service that normalizes gym/fitness questions into canonical representations,
/// detects high-frequency FAQs, and maintains a context-scoped LRU cache keyed by
/// `(question, locale, units, hasConsent, dataEpoch)` (Wave 7.2 & 7.5).
class AiQuestionNormalizer {
  AiQuestionNormalizer({int maxCacheEntries = 100})
      : _cache = _LruCache<String, _CachedAiEntry>(maxCacheEntries);

  final _LruCache<String, _CachedAiEntry> _cache;

  /// High-frequency canonical fitness FAQs with verified, evidence-based answers.
  /// These can be served instantly without remote LLM invocation.
  static const Map<String, String> canonicalFaqs = {
    'canonical:protein_intake':
        'For resistance training, evidence suggests consuming 1.6 to 2.2 grams of protein per kilogram of body weight (0.7–1.0 g/lb) daily to maximize muscle protein synthesis. Distribute intake across 3–5 balanced meals containing ~25–40g of high-quality protein each.\n\n**Next Step:** Log your next meal in the Fuel tab and aim for at least 30g of protein.',
    'canonical:progressive_overload':
        'Progressive overload is the gradual increase of stress placed upon the musculoskeletal system:\n• Add 1–2.5 kg (2.5–5 lbs) once you hit the top of your rep range.\n• Add 1–2 reps per set with the same load.\n• Add 1 working set for lagging muscle groups.\n\n**Next Step:** Review your last session in the Train tab and target +1 rep on your primary compound lift today.',
    'canonical:rest_times':
        'Optimal rest intervals depend on exercise type and intensity:\n• Heavy compound lifts (Squat, Deadlift, Bench): 2.5–4 minutes to restore ATP and CNS output.\n• Hypertrophy/isolation movements (Curls, Lateral Raises, Leg Extensions): 1–2 minutes.\n\n**Next Step:** Set your in-workout rest timer to 180s for compounds and 90s for accessories.',
    'canonical:rpe_guide':
        'RPE (Rate of Perceived Exertion) measures set intensity based on Repetitions in Reserve (RIR):\n• RPE 10: Maximum effort, 0 reps in reserve.\n• RPE 8–9: 1–2 reps left in the tank (ideal hypertrophy zone).\n• RPE 7: 3 reps left (speed/technique work).\n\n**Next Step:** Log an RPE between 7 and 9 on your working sets during today\'s workout.',
    'canonical:creatine_usage':
        'Creatine monohydrate is one of the most researched sports supplements. A daily dose of 3–5 grams taken consistently at any time of day saturates muscle phosphocreatine stores. A loading phase is optional.\n\n**Next Step:** Take 5g of creatine monohydrate daily with a meal or post-workout shake and stay hydrated.',
    'canonical:warmup_protocol':
        'An effective gym warm-up consists of:\n• 3–5 minutes of light cardio to raise core temperature.\n• Dynamic joint mobility for the muscles you are training today.\n• 2–3 ramp-up sets on your first compound lift (50%, 70%, 85% of working weight for low reps).\n\n**Next Step:** Complete 2 ramp-up warm-up sets before your first working set today.',
  };

  /// Synonym and phrase mappings to canonical keys.
  static final List<(RegExp, String)> _synonymPatterns = [
    (
      RegExp(
          r'\b(how much|how many grams of)?\s*protein(\s*(intake|per day|per kg|should i eat|daily|needed))?\b'),
      'canonical:protein_intake',
    ),
    (
      RegExp(r'\b(what is|how to do|explain)?\s*progressive overload\b'),
      'canonical:progressive_overload',
    ),
    (
      RegExp(
          r'\b(how long to|how much)?\s*rest\s*(between sets|time|period)?\b'),
      'canonical:rest_times',
    ),
    (
      RegExp(
          r'\b(what is|explain)\s*rpe\b|\brate of perceived exertion\b|\breps in reserve\b'),
      'canonical:rpe_guide',
    ),
    (
      RegExp(
          r'\b(how to take|when to take|how much)?\s*creatine\s*(timing|dosage|loading)?\b'),
      'canonical:creatine_usage',
    ),
    (
      RegExp(
          r'\b(how to|proper|best)\s*warm\s*up(\s*routine|\s*protocol|\s*sets)?\b'),
      'canonical:warmup_protocol',
    ),
  ];

  /// Normalizes a user question by trimming, lowercasing, stripping punctuation,
  /// collapsing spaces, and matching against canonical synonym patterns.
  String normalize(String rawQuestion) {
    if (rawQuestion.trim().isEmpty) return '';

    final lower = rawQuestion.toLowerCase().trim();

    // Check synonym patterns first for semantic normalization
    for (final (regex, canonicalKey) in _synonymPatterns) {
      if (regex.hasMatch(lower)) {
        return canonicalKey;
      }
    }

    // Generic normalization: strip non-alphanumeric (keep spaces), collapse whitespace
    final cleaned = lower
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return cleaned;
  }

  /// Builds a context-isolated cache key from the normalized question, locale,
  /// unit system, personalization consent state, and user data epoch (Wave 7.2).
  String buildCacheKey(
    String rawQuestion, {
    String locale = 'en',
    String units = 'metric',
    bool hasConsent = false,
    int dataEpoch = 0,
  }) {
    final normalized = normalize(rawQuestion);
    if (normalized.isEmpty) return '';
    final cleanLocale = locale.trim().isEmpty ? 'en' : locale.trim().toLowerCase();
    final cleanUnits = units.trim().isEmpty ? 'metric' : units.trim().toLowerCase();
    final effectiveEpoch = hasConsent ? dataEpoch : 0;
    return '$normalized|loc:$cleanLocale|u:$cleanUnits|c:${hasConsent ? 1 : 0}|e:$effectiveEpoch';
  }

  /// Resolves a question against cached responses and optional canonical FAQs.
  AiQuestionResolution resolve(
    String rawQuestion, {
    bool includeCanonicalFaqs = true,
    String locale = 'en',
    String units = 'metric',
    bool hasConsent = false,
    int dataEpoch = 0,
  }) {
    final key = normalize(rawQuestion);
    if (key.isEmpty) {
      return const AiQuestionResolution(
        normalizedKey: '',
        compositeCacheKey: '',
        isCanonicalFaq: false,
        cachedResponse: null,
      );
    }

    final compositeKey = buildCacheKey(
      rawQuestion,
      locale: locale,
      units: units,
      hasConsent: hasConsent,
      dataEpoch: dataEpoch,
    );

    // 1. Check LRU / TTL cache first using the composite context key
    final cachedEntry = _cache.get(compositeKey);
    if (cachedEntry != null && !cachedEntry.isExpired) {
      return AiQuestionResolution(
        normalizedKey: key,
        compositeCacheKey: compositeKey,
        isCanonicalFaq: false,
        cachedResponse: cachedEntry.response,
      );
    }

    // 2. Check canonical FAQ dictionary if enabled (offline/instant fallback)
    if (includeCanonicalFaqs) {
      final canonicalAnswer = canonicalFaqs[key];
      if (canonicalAnswer != null) {
        return AiQuestionResolution(
          normalizedKey: key,
          compositeCacheKey: compositeKey,
          isCanonicalFaq: true,
          cachedResponse: canonicalAnswer,
        );
      }
    }

    return AiQuestionResolution(
      normalizedKey: key,
      compositeCacheKey: compositeKey,
      isCanonicalFaq: false,
      cachedResponse: null,
    );
  }

  /// Caches a response for a normalized question + context key with an optional TTL.
  void cacheResponse(
    String rawQuestion,
    String response, {
    Duration ttl = const Duration(hours: 24),
    String locale = 'en',
    String units = 'metric',
    bool hasConsent = false,
    int dataEpoch = 0,
  }) {
    final compositeKey = buildCacheKey(
      rawQuestion,
      locale: locale,
      units: units,
      hasConsent: hasConsent,
      dataEpoch: dataEpoch,
    );
    if (compositeKey.isEmpty || response.trim().isEmpty) return;

    _cache.set(
      compositeKey,
      _CachedAiEntry(
        response: response,
        expiresAt: DateTime.now().add(ttl),
      ),
    );
  }

  /// Clears in-memory cached responses.
  void clearCache() {
    _cache.clear();
  }

  /// Number of entries currently in cache.
  int get cachedEntriesCount => _cache.length;
}

class _CachedAiEntry {
  final String response;
  final DateTime expiresAt;

  const _CachedAiEntry({
    required this.response,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Simple LRU cache implementation using LinkedHashMap.
class _LruCache<K, V> {
  final int capacity;
  final LinkedHashMap<K, V> _map = LinkedHashMap<K, V>();

  _LruCache(this.capacity);

  V? get(K key) {
    final value = _map.remove(key);
    if (value != null) {
      _map[key] = value;
    }
    return value;
  }

  void set(K key, V value) {
    if (_map.containsKey(key)) {
      _map.remove(key);
    } else if (_map.length >= capacity) {
      _map.remove(_map.keys.first);
    }
    _map[key] = value;
  }

  void clear() => _map.clear();

  int get length => _map.length;
}
