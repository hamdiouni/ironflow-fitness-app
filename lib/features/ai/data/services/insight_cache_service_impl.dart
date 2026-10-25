import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/insight.dart';
import '../../domain/entities/insight_cache.dart';
import '../../domain/services/insight_cache_service.dart';
import '../models/insight_cache_model.dart';

/// Implementation of InsightCacheService using Hive for local storage
///
/// This service provides persistent caching of AI-generated insights using
/// the established Hive pattern with Box<Map> and JSON serialization.
///
/// **Cache Strategy:**
/// - Uses Hive Box<Map> with JSON serialization (following existing pattern)
/// - Context-based keys for efficient retrieval
/// - 1-hour TTL for cache staleness detection
/// - Graceful error handling with logging
///
/// **Requirements:**
/// - 3.6: Cache insights until underlying data changes
/// - 4.7: Persist insight cache to local storage
/// - 11.2: Cache generated insights in memory
/// - 11.3: Persist insight cache to local storage using Hive
/// - 11.4: Return cached insights if less than 1 hour old and data unchanged
/// - 13.1: Log errors without failing operations
/// - 13.4: Wrap Hive operations in try-catch blocks
class InsightCacheServiceImpl implements InsightCacheService {
  static const String boxName = 'insight_cache';
  static const Duration cacheTTL = Duration(hours: 1);

  /// Account that owns cached insights read/written by this instance.
  /// Existing constructions without a user keep legacy context keys.
  final String? userId;

  InsightCacheServiceImpl({this.userId});

  Box<Map>? _box;

  String? get _scopeUserId =>
      RecordOwnershipRules.storageScope(userId);

  /// Recursively casts a [Map<dynamic, dynamic>] (as returned by Hive) to
  /// [Map<String, dynamic>] so that json_serializable can deserialize it.
  Map<String, dynamic> _deepCast(Map<dynamic, dynamic> map) {
    return map.map((key, value) {
      if (value is Map) {
        return MapEntry(key.toString(), _deepCast(value));
      } else if (value is List) {
        return MapEntry(key.toString(), _deepCastList(value));
      }
      return MapEntry(key.toString(), value);
    });
  }

  List<dynamic> _deepCastList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map) return _deepCast(item);
      if (item is List) return _deepCastList(item);
      return item;
    }).toList();
  }

  @override
  Future<void> init() async {
    try {
      AppLogger.debug('📊 [InsightCache] Initializing insight cache service...');
      
      if (_box?.isOpen == true) {
        AppLogger.debug('✅ [InsightCache] Box already open');
        return;
      }
      
      _box = await Hive.openBox<Map>(boxName);
      
      AppLogger.debug('✅ [InsightCache] Insight cache service initialized successfully');
      AppLogger.debug('🔍 [InsightCache] Box opened: $boxName (isOpen: ${_box!.isOpen})');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [InsightCache] Failed to initialize insight cache service: $e');
      AppLogger.debug('🔍 [InsightCache] Stack trace: $stackTrace');
      throw Exception('Failed to initialize insight cache service: $e');
    }
  }

  Future<Map?> _cachedDataFor(InsightContext context) async {
    final scopedKey = _getContextKey(context);
    final scopedData = _box!.get(scopedKey);
    if (scopedData != null || _scopeUserId == null) return scopedData;

    final legacyKey = _legacyContextKey(context);
    final legacyData = _box!.get(legacyKey);
    if (legacyData == null) return null;

    // One-time adoption of a pre-scoping cache entry, only when no
    // account-scoped entry exists for this context. Insight cache
    // records carry no owner field, so the legacy entry cannot be
    // attributed safely after scoped entries have been created.
    final hasScopedContext = _box!.keys.any(
      (key) => key.toString().startsWith('${legacyKey}_'),
    );
    if (hasScopedContext) return null;

    await _box!.put(scopedKey, legacyData);
    await _box!.delete(legacyKey);
    return legacyData;
  }

  @override
  Future<InsightCache?> getCachedInsights(InsightContext context) async {
    try {
      AppLogger.debug('📊 [InsightCache] Getting cached insights for context: ${context.name}');
      
      if (_box?.isOpen != true) {
        AppLogger.debug('⚠️ [InsightCache] Box not open, initializing...');
        await init();
      }
      
      final cachedData = await _cachedDataFor(context);
      
      if (cachedData == null) {
        AppLogger.debug('🔍 [InsightCache] No cache found for context: ${context.name}');
        return null;
      }
      
      AppLogger.debug('🔍 [InsightCache] Deserializing cached data...');
      final cacheModel = InsightCacheModel.fromJson(_deepCast(cachedData));
      final cache = cacheModel.toDomain();
      
      AppLogger.debug('✅ [InsightCache] Cached insights retrieved successfully');
      AppLogger.debug('🔍 [InsightCache] Context: ${context.name}, Insights: ${cache.insights.length}, Cached at: ${cache.cachedAt}');
      
      return cache;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [InsightCache] Failed to get cached insights for context ${context.name}: $e');
      AppLogger.debug('🔍 [InsightCache] Stack trace: $stackTrace');
      // Return null on cache read failures (graceful degradation)
      return null;
    }
  }

  @override
  Future<void> cacheInsights(InsightCache cache) async {
    try {
      AppLogger.debug('📊 [InsightCache] Caching insights for context: ${cache.context.name}');
      AppLogger.debug('🔍 [InsightCache] Insights count: ${cache.insights.length}');
      
      if (_box?.isOpen != true) {
        AppLogger.debug('⚠️ [InsightCache] Box not open, initializing...');
        await init();
      }
      
      final key = _getContextKey(cache.context);
      final cacheModel = InsightCacheModel.fromDomain(cache);
      
      await _box!.put(key, cacheModel.toJson());
      
      AppLogger.debug('✅ [InsightCache] Insights cached successfully');
      AppLogger.debug('🔍 [InsightCache] Context: ${cache.context.name}, Cached at: ${cache.cachedAt}');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [InsightCache] Failed to cache insights for context ${cache.context.name}: $e');
      AppLogger.debug('🔍 [InsightCache] Stack trace: $stackTrace');
      // Don't rethrow - log error but don't fail the operation
    }
  }

  @override
  Future<void> invalidateCache(InsightContext context) async {
    try {
      AppLogger.debug('📊 [InsightCache] Invalidating cache for context: ${context.name}');
      
      if (_box?.isOpen != true) {
        AppLogger.debug('⚠️ [InsightCache] Box not open, initializing...');
        await init();
      }
      
      final key = _getContextKey(context);
      await _box!.delete(key);
      
      AppLogger.debug('✅ [InsightCache] Cache invalidated successfully');
      AppLogger.debug('🔍 [InsightCache] Context: ${context.name}');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [InsightCache] Failed to invalidate cache for context ${context.name}: $e');
      AppLogger.debug('🔍 [InsightCache] Stack trace: $stackTrace');
      // Don't rethrow - log error but don't fail the operation
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      AppLogger.debug('📊 [InsightCache] Clearing all cached insights...');
      
      if (_box?.isOpen != true) {
        AppLogger.debug('⚠️ [InsightCache] Box not open, initializing...');
        await init();
      }
      
      final scopeUserId = _scopeUserId;
      if (scopeUserId == null) {
        await _box!.clear();
      } else {
        final scopedSuffix = '_$scopeUserId';
        final keysToDelete = _box!.keys
            .where((key) => key.toString().endsWith(scopedSuffix))
            .toList();
        for (final key in keysToDelete) {
          await _box!.delete(key);
        }
      }

      AppLogger.debug('✅ [InsightCache] All cached insights cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [InsightCache] Failed to clear all cached insights: $e');
      AppLogger.debug('🔍 [InsightCache] Stack trace: $stackTrace');
      // Don't rethrow - log error but don't fail the operation
    }
  }

  @override
  bool isCacheStale(InsightCache cache) {
    try {
      final now = DateTime.now();
      final cacheAge = now.difference(cache.cachedAt);
      final isStale = cacheAge >= cacheTTL;
      
      AppLogger.debug('🔍 [InsightCache] Cache staleness check for context: ${cache.context.name}');
      AppLogger.debug('🔍 [InsightCache] Cache age: ${cacheAge.inMinutes} minutes, TTL: ${cacheTTL.inMinutes} minutes, Is stale: $isStale');
      
      return isStale;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [InsightCache] Failed to check cache staleness: $e');
      AppLogger.debug('🔍 [InsightCache] Stack trace: $stackTrace');
      // Return true (stale) on error to force regeneration
      return true;
    }
  }

  String _legacyContextKey(InsightContext context) {
    return 'insights_${context.name}';
  }

  /// Generate the account-scoped cache key for a specific context.
  String _getContextKey(InsightContext context) {
    final scopeUserId = _scopeUserId;
    final legacyKey = _legacyContextKey(context);
    return scopeUserId == null ? legacyKey : '${legacyKey}_$scopeUserId';
  }
}