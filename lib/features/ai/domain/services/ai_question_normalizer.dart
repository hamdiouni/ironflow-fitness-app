import 'dart:collection';

/// Result of a question normalization and cache lookup.
class AiQuestionResolution {
  final String normalizedKey;
  final bool isCanonicalFaq;
  final String? cachedResponse;

  const AiQuestionResolution({
    required this.normalizedKey,
    required this.isCanonicalFaq,
    this.cachedResponse,
  });
}

/// Token and cost estimation utility for AI interactions (Wave 6.1 — AI-05).
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
/// detects high-frequency FAQs, and maintains an in-memory cache to save API costs
/// and deliver instant responses (Wave 6.1 — AI-05).
class AiQuestionNormalizer {
  AiQuestionNormalizer({int maxCacheEntries = 100})
      : _cache = _LruCache<String, _CachedAiEntry>(maxCacheEntries);

  final _LruCache<String, _CachedAiEntry> _cache;

  /// High-frequency canonical fitness FAQs with verified, evidence-based answers.
  /// These can be served instantly without remote LLM invocation.
  static const Map<String, String> canonicalFaqs = {
    'canonical:protein_intake':
        'For resistance training, evidence suggests consuming 1.6 to 2.2 grams of protein per kilogram of body weight (0.7–1.0 g/lb) daily to maximize muscle protein synthesis. Distribute intake across 3–5 balanced meals containing ~25–40g of high-quality protein each.',
    'canonical:progressive_overload':
        'Progressive overload is the gradual increase of stress placed upon the musculoskeletal system. You can apply it by: 1) Adding weight (even 1–2.5 kg), 2) Adding reps within your target rep bracket, 3) Adding sets, or 4) Improving execution control and tempo. Always prioritize form over load.',
    'canonical:rest_times':
        'Optimal rest intervals depend on exercise type and intensity:\n• Heavy compound lifts (Squat, Deadlift, Bench): 2.5–4 minutes to restore ATP and central nervous system output.\n• Hypertrophy/isolation movements (Curls, Lateral Raises, Leg Extensions): 1–2 minutes.\nRest long enough to perform the next set with equal intensity and solid form.',
    'canonical:rpe_guide':
        'RPE (Rate of Perceived Exertion) measures set intensity based on Repetitions in Reserve (RIR):\n• RPE 10: Absolute maximum effort, 0 reps in reserve.\n• RPE 9: 1 rep left before failure.\n• RPE 8: 2 reps left.\n• RPE 7: 3 reps left (good for volume/speed).\nMost hypertrophy training is most productive between RPE 7 and 9.',
    'canonical:creatine_usage':
        'Creatine monohydrate is one of the most researched sports supplements. A daily dose of 3–5 grams taken consistently at any time of day is sufficient to saturate muscle phosphocreatine stores. A loading phase is optional, not mandatory. Ensure adequate daily hydration.',
    'canonical:warmup_protocol':
        'An effective gym warm-up consists of:\n1. 3–5 minutes of light general cardio to elevate core temperature.\n2. Dynamic mobility drills for target joints (e.g., hip openers, arm circles, shoulder dislocates).\n3. Progressive warm-up sets on your first compound lift (e.g., empty bar, 40%, 60%, 80% of working weight for low reps).\nNever fatigue yourself on warm-up sets.',
  };

  /// Synonym and phrase mappings to canonical keys.
  static final List<(RegExp, String)> _synonymPatterns = [
    (
      RegExp(r'\b(how much|how many grams of)?\s*protein(\s*(intake|per day|per kg|should i eat|daily|needed))?\b'),
      'canonical:protein_intake',
    ),
    (
      RegExp(r'\b(what is|how to do|explain)?\s*progressive overload\b'),
      'canonical:progressive_overload',
    ),
    (
      RegExp(r'\b(how long to|how much)?\s*rest\s*(between sets|time|period)?\b'),
      'canonical:rest_times',
    ),
    (
      RegExp(r'\b(what is|explain)\s*rpe\b|\brate of perceived exertion\b|\breps in reserve\b'),
      'canonical:rpe_guide',
    ),
    (
      RegExp(r'\b(how to take|when to take|how much)?\s*creatine\s*(timing|dosage|loading)?\b'),
      'canonical:creatine_usage',
    ),
    (
      RegExp(r'\b(how to|proper|best)\s*warm\s*up(\s*routine|\s*protocol|\s*sets)?\b'),
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
        .replaceAll(RegExp(r"[^\w\s]"), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return cleaned;
  }

  /// Resolves a question against cached responses and optional canonical FAQs.
  AiQuestionResolution resolve(
    String rawQuestion, {
    bool includeCanonicalFaqs = true,
  }) {
    final key = normalize(rawQuestion);
    if (key.isEmpty) {
      return const AiQuestionResolution(
        normalizedKey: '',
        isCanonicalFaq: false,
        cachedResponse: null,
      );
    }

    // 1. Check LRU / TTL cache first (previously cached responses)
    final cachedEntry = _cache.get(key);
    if (cachedEntry != null && !cachedEntry.isExpired) {
      return AiQuestionResolution(
        normalizedKey: key,
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
          isCanonicalFaq: true,
          cachedResponse: canonicalAnswer,
        );
      }
    }

    return AiQuestionResolution(
      normalizedKey: key,
      isCanonicalFaq: false,
      cachedResponse: null,
    );
  }

  /// Caches a response for a normalized question key with an optional TTL (default: 24 hours).
  void cacheResponse(
    String rawQuestion,
    String response, {
    Duration ttl = const Duration(hours: 24),
  }) {
    final key = normalize(rawQuestion);
    if (key.isEmpty || response.trim().isEmpty) return;

    _cache.set(
      key,
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
