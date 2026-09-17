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

  Box<Map>? _box;

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
      print('📊 [InsightCache] Initializing insight cache service...');
      
      if (_box?.isOpen == true) {
        print('✅ [InsightCache] Box already open');
        return;
      }
      
      _box = await Hive.openBox<Map>(boxName);
      
      print('✅ [InsightCache] Insight cache service initialized successfully');
      print('🔍 [InsightCache] Box opened: $boxName (isOpen: ${_box!.isOpen})');
    } catch (e, stackTrace) {
      print('❌ [InsightCache] Failed to initialize insight cache service: $e');
      print('🔍 [InsightCache] Stack trace: $stackTrace');
      throw Exception('Failed to initialize insight cache service: $e');
    }
  }

  @override
  Future<InsightCache?> getCachedInsights(InsightContext context) async {
    try {
      print('📊 [InsightCache] Getting cached insights for context: ${context.name}');
      
      if (_box?.isOpen != true) {
        print('⚠️ [InsightCache] Box not open, initializing...');
        await init();
      }
      
      final key = _getContextKey(context);
      final cachedData = _box!.get(key);
      
      if (cachedData == null) {
        print('🔍 [InsightCache] No cache found for context: ${context.name}');
        return null;
      }
      
      print('🔍 [InsightCache] Deserializing cached data...');
      final cacheModel = InsightCacheModel.fromJson(_deepCast(cachedData));
      final cache = cacheModel.toDomain();
      
      print('✅ [InsightCache] Cached insights retrieved successfully');
      print('🔍 [InsightCache] Context: ${context.name}, Insights: ${cache.insights.length}, Cached at: ${cache.cachedAt}');
      
      return cache;
    } catch (e, stackTrace) {
      print('❌ [InsightCache] Failed to get cached insights for context ${context.name}: $e');
      print('🔍 [InsightCache] Stack trace: $stackTrace');
      // Return null on cache read failures (graceful degradation)
      return null;
    }
  }

  @override
  Future<void> cacheInsights(InsightCache cache) async {
    try {
      print('📊 [InsightCache] Caching insights for context: ${cache.context.name}');
      print('🔍 [InsightCache] Insights count: ${cache.insights.length}');
      
      if (_box?.isOpen != true) {
        print('⚠️ [InsightCache] Box not open, initializing...');
        await init();
      }
      
      final key = _getContextKey(cache.context);
      final cacheModel = InsightCacheModel.fromDomain(cache);
      
      await _box!.put(key, cacheModel.toJson());
      
      print('✅ [InsightCache] Insights cached successfully');
      print('🔍 [InsightCache] Context: ${cache.context.name}, Cached at: ${cache.cachedAt}');
    } catch (e, stackTrace) {
      print('❌ [InsightCache] Failed to cache insights for context ${cache.context.name}: $e');
      print('🔍 [InsightCache] Stack trace: $stackTrace');
      // Don't rethrow - log error but don't fail the operation
    }
  }

  @override
  Future<void> invalidateCache(InsightContext context) async {
    try {
      print('📊 [InsightCache] Invalidating cache for context: ${context.name}');
      
      if (_box?.isOpen != true) {
        print('⚠️ [InsightCache] Box not open, initializing...');
        await init();
      }
      
      final key = _getContextKey(context);
      await _box!.delete(key);
      
      print('✅ [InsightCache] Cache invalidated successfully');
      print('🔍 [InsightCache] Context: ${context.name}');
    } catch (e, stackTrace) {
      print('❌ [InsightCache] Failed to invalidate cache for context ${context.name}: $e');
      print('🔍 [InsightCache] Stack trace: $stackTrace');
      // Don't rethrow - log error but don't fail the operation
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      print('📊 [InsightCache] Clearing all cached insights...');
      
      if (_box?.isOpen != true) {
        print('⚠️ [InsightCache] Box not open, initializing...');
        await init();
      }
      
      await _box!.clear();
      
      print('✅ [InsightCache] All cached insights cleared successfully');
    } catch (e, stackTrace) {
      print('❌ [InsightCache] Failed to clear all cached insights: $e');
      print('🔍 [InsightCache] Stack trace: $stackTrace');
      // Don't rethrow - log error but don't fail the operation
    }
  }

  @override
  bool isCacheStale(InsightCache cache) {
    try {
      final now = DateTime.now();
      final cacheAge = now.difference(cache.cachedAt);
      final isStale = cacheAge > cacheTTL;
      
      print('🔍 [InsightCache] Cache staleness check for context: ${cache.context.name}');
      print('🔍 [InsightCache] Cache age: ${cacheAge.inMinutes} minutes, TTL: ${cacheTTL.inMinutes} minutes, Is stale: $isStale');
      
      return isStale;
    } catch (e, stackTrace) {
      print('❌ [InsightCache] Failed to check cache staleness: $e');
      print('🔍 [InsightCache] Stack trace: $stackTrace');
      // Return true (stale) on error to force regeneration
      return true;
    }
  }

  /// Generate cache key for a specific context
  String _getContextKey(InsightContext context) {
    return 'insights_${context.name}';
  }
}