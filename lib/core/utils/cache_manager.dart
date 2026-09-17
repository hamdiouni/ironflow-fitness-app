import 'package:flutter/foundation.dart';

/// Simple in-memory cache manager for frequently accessed data.
class CacheManager<K, V> {
  final Map<K, _CacheEntry<V>> _cache = {};
  final Duration _defaultTTL;
  final int _maxSize;

  CacheManager({
    Duration defaultTTL = const Duration(minutes: 5),
    int maxSize = 100,
  })  : _defaultTTL = defaultTTL,
        _maxSize = maxSize;

  /// Gets a value from cache.
  V? get(K key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Check if expired
    if (DateTime.now().isAfter(entry.expiresAt)) {
      _cache.remove(key);
      return null;
    }

    // Update last accessed time
    entry.lastAccessed = DateTime.now();
    return entry.value;
  }

  /// Sets a value in cache.
  void set(K key, V value, {Duration? ttl}) {
    // Remove oldest entry if cache is full
    if (_cache.length >= _maxSize) {
      _removeOldestEntry();
    }

    _cache[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl ?? _defaultTTL),
      lastAccessed: DateTime.now(),
    );
  }

  /// Removes a value from cache.
  void remove(K key) {
    _cache.remove(key);
  }

  /// Clears all cache.
  void clear() {
    _cache.clear();
  }

  /// Gets cache size.
  int get size => _cache.length;

  /// Removes the oldest entry (LRU).
  void _removeOldestEntry() {
    if (_cache.isEmpty) return;

    K? oldestKey;
    DateTime? oldestTime;

    _cache.forEach((key, entry) {
      if (oldestTime == null || entry.lastAccessed.isBefore(oldestTime!)) {
        oldestKey = key;
        oldestTime = entry.lastAccessed;
      }
    });

    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }

  /// Cleans up expired entries.
  void cleanup() {
    final now = DateTime.now();
    _cache.removeWhere((_, entry) => now.isAfter(entry.expiresAt));
  }
}

class _CacheEntry<V> {
  final V value;
  final DateTime expiresAt;
  DateTime lastAccessed;

  _CacheEntry({
    required this.value,
    required this.expiresAt,
    required this.lastAccessed,
  });
}

/// Global cache managers for common data types.
final exerciseCache = CacheManager<String, Map<String, dynamic>>();
final foodCache = CacheManager<String, Map<String, dynamic>>();
final workoutHistoryCache = CacheManager<String, List<dynamic>>();
final analyticsCache = CacheManager<String, Map<String, dynamic>>();

/// Decorator for caching async function results.
Future<T> cachedAsync<T>(
  String cacheKey,
  Future<T> Function() fn, {
  Duration ttl = const Duration(minutes: 5),
  CacheManager<String, T>? cache,
}) async {
  final cacheManager = cache ?? CacheManager<String, T>();

  // Check cache first
  final cached = cacheManager.get(cacheKey);
  if (cached != null) {
    debugPrint('Cache hit: $cacheKey');
    return cached;
  }

  // Fetch and cache
  debugPrint('Cache miss: $cacheKey');
  final result = await fn();
  cacheManager.set(cacheKey, result, ttl: ttl);
  return result;
}
