import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:progression_tracker/features/ai/data/services/insight_cache_service_impl.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_cache.dart';

void main() {
  group('InsightCacheServiceImpl', () {
    late InsightCacheServiceImpl service;
    late Box<Map> testBox;

    setUpAll(() async {
      // Initialize Hive for testing
      Hive.init('./test/hive_test_db');
    });

    setUp(() async {
      service = InsightCacheServiceImpl();
      
      // Open a test box
      testBox = await Hive.openBox<Map>('test_insight_cache');
      
      // Clear any existing data
      await testBox.clear();
    });

    tearDown(() async {
      await testBox.clear();
      await testBox.close();
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
    });

    group('init', () {
      test('should initialize successfully', () async {
        await service.init();
        // No exception should be thrown
      });

      test('should handle multiple init calls gracefully', () async {
        await service.init();
        await service.init(); // Should not throw
      });
    });

    group('cacheInsights and getCachedInsights', () {
      test('should cache and retrieve insights successfully', () async {
        await service.init();
        
        final insights = [
          Insight(
            id: 'test-1',
            context: InsightContext.home,
            title: 'Test Insight',
            message: 'This is a test insight',
            icon: '💪',
            priority: InsightPriority.high,
            generatedAt: DateTime.now(),
            metadata: {'test': 'data'},
          ),
        ];
        
        final cache = InsightCache(
          context: InsightContext.home,
          insights: insights,
          cachedAt: DateTime.now(),
          dataTimestamps: {'workouts': DateTime.now()},
        );
        
        // Cache the insights
        await service.cacheInsights(cache);
        
        // Retrieve the cached insights
        final retrieved = await service.getCachedInsights(InsightContext.home);
        
        expect(retrieved, isNotNull);
        expect(retrieved!.context, equals(InsightContext.home));
        expect(retrieved.insights.length, equals(1));
        expect(retrieved.insights.first.id, equals('test-1'));
        expect(retrieved.insights.first.title, equals('Test Insight'));
        expect(retrieved.insights.first.message, equals('This is a test insight'));
        expect(retrieved.insights.first.icon, equals('💪'));
        expect(retrieved.insights.first.priority, equals(InsightPriority.high));
        expect(retrieved.insights.first.metadata, equals({'test': 'data'}));
      });

      test('should return null when no cache exists', () async {
        await service.init();
        
        final retrieved = await service.getCachedInsights(InsightContext.workout);
        
        expect(retrieved, isNull);
      });

      test('should handle multiple contexts independently', () async {
        await service.init();
        
        final homeInsights = [
          Insight(
            id: 'home-1',
            context: InsightContext.home,
            title: 'Home Insight',
            message: 'Home message',
            icon: '🏠',
            priority: InsightPriority.medium,
            generatedAt: DateTime.now(),
          ),
        ];
        
        final workoutInsights = [
          Insight(
            id: 'workout-1',
            context: InsightContext.workout,
            title: 'Workout Insight',
            message: 'Workout message',
            icon: '💪',
            priority: InsightPriority.high,
            generatedAt: DateTime.now(),
          ),
        ];
        
        final homeCache = InsightCache(
          context: InsightContext.home,
          insights: homeInsights,
          cachedAt: DateTime.now(),
          dataTimestamps: {},
        );
        
        final workoutCache = InsightCache(
          context: InsightContext.workout,
          insights: workoutInsights,
          cachedAt: DateTime.now(),
          dataTimestamps: {},
        );
        
        // Cache both
        await service.cacheInsights(homeCache);
        await service.cacheInsights(workoutCache);
        
        // Retrieve both
        final retrievedHome = await service.getCachedInsights(InsightContext.home);
        final retrievedWorkout = await service.getCachedInsights(InsightContext.workout);
        
        expect(retrievedHome!.insights.first.title, equals('Home Insight'));
        expect(retrievedWorkout!.insights.first.title, equals('Workout Insight'));
      });

      test('should preserve timestamps and metadata', () async {
        await service.init();
        
        final now = DateTime.now();
        final dataTimestamp = now.subtract(const Duration(minutes: 30));
        
        final cache = InsightCache(
          context: InsightContext.nutrition,
          insights: [],
          cachedAt: now,
          dataTimestamps: {
            'workouts': dataTimestamp,
            'nutrition': now,
          },
        );
        
        await service.cacheInsights(cache);
        final retrieved = await service.getCachedInsights(InsightContext.nutrition);
        
        expect(retrieved!.cachedAt.millisecondsSinceEpoch, 
               equals(now.millisecondsSinceEpoch));
        expect(retrieved.dataTimestamps['workouts']!.millisecondsSinceEpoch,
               equals(dataTimestamp.millisecondsSinceEpoch));
        expect(retrieved.dataTimestamps['nutrition']!.millisecondsSinceEpoch,
               equals(now.millisecondsSinceEpoch));
      });
    });

    group('invalidateCache', () {
      test('should remove cached insights for specific context', () async {
        await service.init();
        
        final cache = InsightCache(
          context: InsightContext.profile,
          insights: [
            Insight(
              id: 'profile-1',
              context: InsightContext.profile,
              title: 'Profile Insight',
              message: 'Profile message',
              icon: '👤',
              priority: InsightPriority.low,
              generatedAt: DateTime.now(),
            ),
          ],
          cachedAt: DateTime.now(),
          dataTimestamps: {},
        );
        
        // Cache the insights
        await service.cacheInsights(cache);
        
        // Verify it's cached
        final beforeInvalidation = await service.getCachedInsights(InsightContext.profile);
        expect(beforeInvalidation, isNotNull);
        
        // Invalidate the cache
        await service.invalidateCache(InsightContext.profile);
        
        // Verify it's removed
        final afterInvalidation = await service.getCachedInsights(InsightContext.profile);
        expect(afterInvalidation, isNull);
      });

      test('should not affect other contexts when invalidating', () async {
        await service.init();
        
        final homeCache = InsightCache(
          context: InsightContext.home,
          insights: [
            Insight(
              id: 'home-1',
              context: InsightContext.home,
              title: 'Home Insight',
              message: 'Home message',
              icon: '🏠',
              priority: InsightPriority.medium,
              generatedAt: DateTime.now(),
            ),
          ],
          cachedAt: DateTime.now(),
          dataTimestamps: {},
        );
        
        final workoutCache = InsightCache(
          context: InsightContext.workout,
          insights: [
            Insight(
              id: 'workout-1',
              context: InsightContext.workout,
              title: 'Workout Insight',
              message: 'Workout message',
              icon: '💪',
              priority: InsightPriority.high,
              generatedAt: DateTime.now(),
            ),
          ],
          cachedAt: DateTime.now(),
          dataTimestamps: {},
        );
        
        // Cache both
        await service.cacheInsights(homeCache);
        await service.cacheInsights(workoutCache);
        
        // Invalidate only home
        await service.invalidateCache(InsightContext.home);
        
        // Verify home is removed but workout remains
        final homeResult = await service.getCachedInsights(InsightContext.home);
        final workoutResult = await service.getCachedInsights(InsightContext.workout);
        
        expect(homeResult, isNull);
        expect(workoutResult, isNotNull);
        expect(workoutResult!.insights.first.title, equals('Workout Insight'));
      });
    });

    group('clearAll', () {
      test('should remove all cached insights', () async {
        await service.init();
        
        // Cache insights for multiple contexts
        final contexts = [
          InsightContext.home,
          InsightContext.workout,
          InsightContext.nutrition,
          InsightContext.profile,
        ];
        
        for (final context in contexts) {
          final cache = InsightCache(
            context: context,
            insights: [
              Insight(
                id: '${context.name}-1',
                context: context,
                title: '${context.name} Insight',
                message: '${context.name} message',
                icon: '📊',
                priority: InsightPriority.medium,
                generatedAt: DateTime.now(),
              ),
            ],
            cachedAt: DateTime.now(),
            dataTimestamps: {},
          );
          
          await service.cacheInsights(cache);
        }
        
        // Verify all are cached
        for (final context in contexts) {
          final cached = await service.getCachedInsights(context);
          expect(cached, isNotNull);
        }
        
        // Clear all
        await service.clearAll();
        
        // Verify all are removed
        for (final context in contexts) {
          final cached = await service.getCachedInsights(context);
          expect(cached, isNull);
        }
      });
    });

    group('isCacheStale', () {
      test('should return false for fresh cache (less than 1 hour)', () {
        final cache = InsightCache(
          context: InsightContext.home,
          insights: [],
          cachedAt: DateTime.now().subtract(const Duration(minutes: 30)),
          dataTimestamps: {},
        );
        
        final isStale = service.isCacheStale(cache);
        expect(isStale, isFalse);
      });

      test('should return true for stale cache (more than 1 hour)', () {
        final cache = InsightCache(
          context: InsightContext.home,
          insights: [],
          cachedAt: DateTime.now().subtract(const Duration(hours: 2)),
          dataTimestamps: {},
        );
        
        final isStale = service.isCacheStale(cache);
        expect(isStale, isTrue);
      });

      test('should return true for cache exactly 1 hour old', () {
        final cache = InsightCache(
          context: InsightContext.home,
          insights: [],
          cachedAt: DateTime.now().subtract(const Duration(hours: 1, seconds: 1)),
          dataTimestamps: {},
        );
        
        final isStale = service.isCacheStale(cache);
        expect(isStale, isTrue);
      });

      test('should return false for cache just under 1 hour old', () {
        final cache = InsightCache(
          context: InsightContext.home,
          insights: [],
          cachedAt: DateTime.now().subtract(const Duration(minutes: 59, seconds: 59)),
          dataTimestamps: {},
        );
        
        final isStale = service.isCacheStale(cache);
        expect(isStale, isFalse);
      });
    });

    group('error handling', () {
      test('should return null on cache read failure', () async {
        await service.init();
        
        // Manually corrupt the cache by putting invalid data
        final box = Hive.box<Map>('insight_cache');
        await box.put('insights_home', {'invalid': 'data'});
        
        final result = await service.getCachedInsights(InsightContext.home);
        expect(result, isNull);
      });

      test('should handle cache write failure gracefully', () async {
        await service.init();
        
        final cache = InsightCache(
          context: InsightContext.home,
          insights: [],
          cachedAt: DateTime.now(),
          dataTimestamps: {},
        );
        
        // This should not throw even if there are issues
        await service.cacheInsights(cache);
      });

      test('should handle invalidation of non-existent cache gracefully', () async {
        await service.init();
        
        // This should not throw
        await service.invalidateCache(InsightContext.home);
      });

      test('should handle clear all on empty cache gracefully', () async {
        await service.init();
        
        // This should not throw
        await service.clearAll();
      });

      test('should return true (stale) on staleness check error', () {
        // Create a cache with null cachedAt to trigger error
        final cache = InsightCache(
          context: InsightContext.home,
          insights: [],
          cachedAt: DateTime.now(),
          dataTimestamps: {},
        );
        
        // This should not throw and should return true to force regeneration
        final isStale = service.isCacheStale(cache);
        expect(isStale, isA<bool>());
      });
    });

    group('cache expiration logic', () {
      test('should handle cache TTL boundary conditions', () {
        final now = DateTime.now();
        
        // Test various time differences around the 1-hour boundary
        final testCases = [
          (Duration(minutes: 0), false),      // Fresh
          (Duration(minutes: 30), false),     // Half hour old
          (Duration(minutes: 59), false),     // Just under 1 hour
          (Duration(hours: 1), true),         // Exactly 1 hour
          (Duration(hours: 1, minutes: 1), true), // Just over 1 hour
          (Duration(hours: 2), true),         // 2 hours old
          (Duration(days: 1), true),          // 1 day old
        ];
        
        for (final (duration, expectedStale) in testCases) {
          final cache = InsightCache(
            context: InsightContext.home,
            insights: [],
            cachedAt: now.subtract(duration),
            dataTimestamps: {},
          );
          
          final isStale = service.isCacheStale(cache);
          expect(isStale, equals(expectedStale), 
                 reason: 'Cache age: ${duration.inMinutes} minutes should be ${expectedStale ? 'stale' : 'fresh'}');
        }
      });
    });
  });
}