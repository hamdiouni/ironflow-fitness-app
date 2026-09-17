import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_cache.dart';

/// Service interface for caching and retrieving AI-generated insights
///
/// The InsightCacheService provides persistent storage for generated insights
/// using Hive for local storage. This enables:
/// - Fast retrieval of previously generated insights
/// - Reduced computation by avoiding unnecessary regeneration
/// - Insights that survive app restarts
///
/// **Cache Strategy:**
/// - Insights are cached with timestamps and context metadata
/// - Cache has a Time To Live (TTL) of 1 hour
/// - Cache is invalidated when underlying data changes
///
/// **Requirements:**
/// - 3.6: Cache insights until underlying data changes
/// - 4.7: Persist insight cache to local storage
/// - 11.2: Cache generated insights in memory
/// - 11.3: Persist insight cache to local storage using Hive
/// - 11.4: Return cached insights if less than 1 hour old and data unchanged
abstract class InsightCacheService {
  /// Initialize the cache service
  ///
  /// Opens the Hive box for storing insight cache data.
  /// This must be called before any other cache operations.
  ///
  /// **Returns:**
  /// A Future that completes when initialization is done
  ///
  /// **Requirements:**
  /// - 11.3: Persist insight cache to local storage using Hive
  Future<void> init();

  /// Get cached insights for a specific context
  ///
  /// Retrieves previously cached insights for the given context.
  /// Returns null if no cache exists for the context.
  ///
  /// **Parameters:**
  /// - [context]: The insight context to retrieve cache for
  ///
  /// **Returns:**
  /// The cached insights, or null if no cache exists
  ///
  /// **Requirements:**
  /// - 11.2: Cache generated insights in memory
  /// - 11.3: Persist insight cache to local storage using Hive
  /// - 11.4: Return cached insights if less than 1 hour old
  Future<InsightCache?> getCachedInsights(InsightContext context);

  /// Save insights to cache
  ///
  /// Stores the generated insights in the cache with timestamps
  /// and context metadata for later retrieval.
  ///
  /// **Parameters:**
  /// - [cache]: The insight cache to store
  ///
  /// **Returns:**
  /// A Future that completes when caching is done
  ///
  /// **Requirements:**
  /// - 3.6: Cache insights until underlying data changes
  /// - 11.2: Cache generated insights in memory
  /// - 11.3: Persist insight cache to local storage using Hive
  Future<void> cacheInsights(InsightCache cache);

  /// Invalidate cache for a specific context
  ///
  /// Removes cached insights for the given context, forcing
  /// regeneration on the next request.
  ///
  /// This is called when underlying data changes or when the user
  /// manually requests a refresh.
  ///
  /// **Parameters:**
  /// - [context]: The insight context to invalidate
  ///
  /// **Returns:**
  /// A Future that completes when invalidation is done
  ///
  /// **Requirements:**
  /// - 3.4: Mark affected Context insights as stale when data changes
  /// - 15.5: Invalidate related cached insights when user deletes data
  Future<void> invalidateCache(InsightContext context);

  /// Clear all cached insights
  ///
  /// Removes all cached insights from storage.
  /// This is typically called when the user logs out or deletes all data.
  ///
  /// **Returns:**
  /// A Future that completes when clearing is done
  ///
  /// **Requirements:**
  /// - 15.5: Invalidate related cached insights when user deletes data
  Future<void> clearAll();

  /// Check if cache is stale
  ///
  /// Determines if the cached insights are older than the TTL (1 hour)
  /// and should be regenerated.
  ///
  /// **Parameters:**
  /// - [cache]: The insight cache to check
  ///
  /// **Returns:**
  /// True if the cache is stale (older than 1 hour), false otherwise
  ///
  /// **Requirements:**
  /// - 11.4: Return cached insights if less than 1 hour old
  /// - 4.8: Check if cached insights are stale before regenerating
  bool isCacheStale(InsightCache cache);
}
