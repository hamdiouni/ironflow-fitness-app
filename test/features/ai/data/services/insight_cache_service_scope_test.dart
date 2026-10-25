import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/ai/data/services/insight_cache_service_impl.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_cache.dart';

void main() {
  late Directory tempDir;
  late Box<Map> cacheBox;

  InsightCache cache(String id, InsightContext context) {
    return InsightCache(
      context: context,
      insights: <Insight>[
        Insight(
          id: id,
          context: context,
          title: 'Insight $id',
          message: 'Message $id',
          icon: 'i',
          priority: InsightPriority.medium,
          generatedAt: DateTime(2026, 1, 1, 12),
        ),
      ],
      cachedAt: DateTime(2026, 1, 1, 12),
      dataTimestamps: const <String, DateTime>{},
    );
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('insight_cache_scope_');
    Hive.init(tempDir.path);
    cacheBox = await Hive.openBox<Map>('insight_cache');
  });

  setUp(() async {
    await cacheBox.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('cached insights are stored separately for each user', () async {
    final aliceService = InsightCacheServiceImpl(userId: 'Alice');
    final bobService = InsightCacheServiceImpl(userId: 'bob');
    await aliceService.init();
    await bobService.init();

    await aliceService.cacheInsights(cache('Alice-home', InsightContext.home));
    await bobService.cacheInsights(cache('bob-home', InsightContext.home));

    expect(
      (await aliceService.getCachedInsights(InsightContext.home))
          ?.insights
          .single
          .id,
      'Alice-home',
    );
    expect(
      (await bobService.getCachedInsights(InsightContext.home))
          ?.insights
          .single
          .id,
      'bob-home',
    );
    expect(cacheBox.containsKey('insights_home_alice'), isTrue);
    expect(cacheBox.containsKey('insights_home_bob'), isTrue);
    expect(cacheBox.containsKey('insights_home'), isFalse);
  });

  test('legacy insight cache is adopted only by the first scoped user',
      () async {
    final legacyService = InsightCacheServiceImpl();
    await legacyService.init();
    await legacyService.cacheInsights(
      cache('legacy-home', InsightContext.home),
    );

    final aliceService = InsightCacheServiceImpl(userId: 'Alice');
    final bobService = InsightCacheServiceImpl(userId: 'bob');
    await aliceService.init();
    await bobService.init();

    expect(
      (await aliceService.getCachedInsights(InsightContext.home))
          ?.insights
          .single
          .id,
      'legacy-home',
    );
    expect(await bobService.getCachedInsights(InsightContext.home), isNull);
    expect(cacheBox.containsKey('insights_home_alice'), isTrue);
    expect(cacheBox.containsKey('insights_home'), isFalse);
  });

  test('invalidate and clearAll affect only the scoped user', () async {
    final aliceService = InsightCacheServiceImpl(userId: 'Alice');
    final bobService = InsightCacheServiceImpl(userId: 'bob');
    await aliceService.init();
    await bobService.init();
    await aliceService.cacheInsights(cache('Alice-home', InsightContext.home));
    await aliceService.cacheInsights(
      cache('Alice-workout', InsightContext.workout),
    );
    await bobService.cacheInsights(cache('bob-home', InsightContext.home));

    await aliceService.invalidateCache(InsightContext.home);
    expect(await aliceService.getCachedInsights(InsightContext.home), isNull);
    expect(
      (await bobService.getCachedInsights(InsightContext.home))
          ?.insights
          .single
          .id,
      'bob-home',
    );

    await aliceService.clearAll();
    expect(
      await aliceService.getCachedInsights(InsightContext.workout),
      isNull,
    );
    expect(
      (await bobService.getCachedInsights(InsightContext.home))
          ?.insights
          .single
          .id,
      'bob-home',
    );
  });
}
