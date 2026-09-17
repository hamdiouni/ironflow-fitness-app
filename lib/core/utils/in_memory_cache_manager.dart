import 'dart:async';

/// Generic in-memory cache manager for optimizing app performance.
///
/// Provides fast access to frequently used data by caching it in memory.
/// Supports TTL (time-to-live) for automatic cache invalidation.
///
/// **Validates: Requirements 8.2 (Caching)**
class InMemoryCacheManager<T> {
  final Map<String, _CacheEntry<T>> _cache = {};
  final Duration? _defaultTTL;

  InMemoryCacheManager({Duration? defaultTTL}) : _defaultTTL = defaultTTL;

  /// Get a value from the cache.
  ///
  /// Returns null if the key doesn't exist or the entry has expired.
  T? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Check if expired
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    return entry.value;
  }

  /// Put a value in the cache.
  ///
  /// [key] - Unique identifier for the cached value
  /// [value] - The value to cache
  /// [ttl] - Optional time-to-live, overrides default TTL
  void put(String key, T value, {Duration? ttl}) {
    final expiresAt = ttl != null || _defaultTTL != null
        ? DateTime.now().add(ttl ?? _defaultTTL!)
        : null;

    _cache[key] = _CacheEntry(
      value: value,
      expiresAt: expiresAt,
    );
  }

  /// Remove a specific key from the cache.
  void remove(String key) {
    _cache.remove(key);
  }

  /// Clear all cached values.
  void clear() {
    _cache.clear();
  }

  /// Get all keys in the cache.
  List<String> get keys => _cache.keys.toList();

  /// Get the number of items in the cache.
  int get size => _cache.length;

  /// Check if a key exists and is not expired.
  bool contains(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  /// Remove all expired entries from the cache.
  void cleanExpired() {
    final expiredKeys = <String>[];
    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }
    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }

  /// Get cache statistics.
  CacheStats get stats {
    int expired = 0;
    for (final entry in _cache.values) {
      if (entry.isExpired) expired++;
    }
    return CacheStats(
      totalEntries: _cache.length,
      expiredEntries: expired,
      activeEntries: _cache.length - expired,
    );
  }
}

/// Internal cache entry with expiration support.
class _CacheEntry<T> {
  final T value;
  final DateTime? expiresAt;

  _CacheEntry({
    required this.value,
    this.expiresAt,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}

/// Cache statistics for monitoring.
class CacheStats {
  final int totalEntries;
  final int expiredEntries;
  final int activeEntries;

  CacheStats({
    required this.totalEntries,
    required this.expiredEntries,
    required this.activeEntries,
  });

  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, active: $activeEntries, expired: $expiredEntries)';
  }
}

/// Singleton cache manager for user profile data.
///
/// Caches user profile to avoid repeated database queries.
/// Cache expires after 5 minutes or when explicitly invalidated.
class UserProfileCache {
  static final _cache = InMemoryCacheManager<dynamic>(
    defaultTTL: const Duration(minutes: 5),
  );

  static const String _profileKey = 'user_profile';

  static dynamic get profile => _cache.get(_profileKey);

  static void setProfile(dynamic profile) {
    _cache.put(_profileKey, profile);
  }

  static void invalidate() {
    _cache.remove(_profileKey);
  }

  static void clear() {
    _cache.clear();
  }
}

/// Singleton cache manager for active workout program.
///
/// Caches the active program to avoid repeated database queries.
/// Cache expires after 10 minutes or when explicitly invalidated.
class ActiveProgramCache {
  static final _cache = InMemoryCacheManager<dynamic>(
    defaultTTL: const Duration(minutes: 10),
  );

  static const String _programKey = 'active_program';

  static dynamic get program => _cache.get(_programKey);

  static void setProgram(dynamic program) {
    _cache.put(_programKey, program);
  }

  static void invalidate() {
    _cache.remove(_programKey);
  }

  static void clear() {
    _cache.clear();
  }
}

/// Singleton cache manager for exercise database.
///
/// Caches all exercises to avoid repeated database queries.
/// Cache expires after 1 hour or when explicitly invalidated.
class ExerciseDatabaseCache {
  static final _cache = InMemoryCacheManager<List<dynamic>>(
    defaultTTL: const Duration(hours: 1),
  );

  static const String _exercisesKey = 'all_exercises';

  static List<dynamic>? get exercises => _cache.get(_exercisesKey);

  static void setExercises(List<dynamic> exercises) {
    _cache.put(_exercisesKey, exercises);
  }

  static void invalidate() {
    _cache.remove(_exercisesKey);
  }

  static void clear() {
    _cache.clear();
  }
}

/// Singleton cache manager for food database.
///
/// Caches all foods to avoid repeated database queries.
/// Cache expires after 1 hour or when explicitly invalidated.
class FoodDatabaseCache {
  static final _cache = InMemoryCacheManager<List<dynamic>>(
    defaultTTL: const Duration(hours: 1),
  );

  static const String _foodsKey = 'all_foods';

  static List<dynamic>? get foods => _cache.get(_foodsKey);

  static void setFoods(List<dynamic> foods) {
    _cache.put(_foodsKey, foods);
  }

  static void invalidate() {
    _cache.remove(_foodsKey);
  }

  static void clear() {
    _cache.clear();
  }
}

/// Global cache manager for clearing all caches.
///
/// Useful for logout or data reset scenarios.
class GlobalCacheManager {
  static void clearAll() {
    UserProfileCache.clear();
    ActiveProgramCache.clear();
    ExerciseDatabaseCache.clear();
    FoodDatabaseCache.clear();
  }

  static void invalidateAll() {
    UserProfileCache.invalidate();
    ActiveProgramCache.invalidate();
    ExerciseDatabaseCache.invalidate();
    FoodDatabaseCache.invalidate();
  }

  static CacheStats getStats() {
    // Aggregate stats from all caches
    return CacheStats(
      totalEntries: 0, // Would need to aggregate from all caches
      expiredEntries: 0,
      activeEntries: 0,
    );
  }
}
