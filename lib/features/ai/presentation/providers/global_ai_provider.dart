import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import 'package:progression_tracker/features/ai/data/services/ai_insights_engine_impl.dart';
import 'package:progression_tracker/features/ai/data/services/change_detection_service_impl.dart';
import 'package:progression_tracker/features/ai/data/services/insight_cache_service_impl.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/services/ai_insights_engine.dart';
import 'package:progression_tracker/features/ai/domain/services/change_detection_service.dart';
import 'package:progression_tracker/features/ai/domain/services/insight_cache_service.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_insight_helpers.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart'
    show currentUserIdProvider;
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/body/presentation/providers/body_providers.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';

// ---------------------------------------------------------------------------
// Service Providers
// ---------------------------------------------------------------------------

/// Provider for AI Insights Engine
final aiInsightsEngineProvider = Provider<AIInsightsEngine>((ref) {
  final workoutRepository = ref.watch(workoutRepositoryProvider);
  final nutritionRepository = ref.watch(nutritionRepositoryProvider);
  final bodyRepository = ref.watch(bodyRepositoryProvider);

  return AIInsightsEngineImpl(
    workoutRepository: workoutRepository,
    nutritionRepository: nutritionRepository,
    bodyRepository: bodyRepository,
  );
});

/// Provider for Insight Cache Service
final insightCacheServiceProvider = Provider<InsightCacheService>((ref) {
  final userId =
      ref.watch(currentUserIdProvider) ?? RecordOwnershipRules.guestUserId;
  return InsightCacheServiceImpl(userId: userId);
});

/// Provider for Change Detection Service
final changeDetectionServiceProvider = Provider<ChangeDetectionService>((ref) {
  final workoutRepository = ref.watch(workoutRepositoryProvider);
  final nutritionRepository = ref.watch(nutritionRepositoryProvider);
  final bodyRepository = ref.watch(bodyRepositoryProvider);

  return ChangeDetectionServiceImpl(
    workoutRepository: workoutRepository,
    nutritionRepository: nutritionRepository,
    bodyRepository: bodyRepository,
  );
});

/// Provider for Global AI Notifier
final globalAIProvider = NotifierProvider<GlobalAINotifier, GlobalAIState>(
  GlobalAINotifier.new,
);

// ---------------------------------------------------------------------------
// Global AI Notifier Class
// ---------------------------------------------------------------------------

/// Global AI Notifier that manages insight state across all contexts
/// (Home, Workout, Nutrition, Profile).
class GlobalAINotifier extends Notifier<GlobalAIState> {
  GlobalAINotifier({
    AIInsightsEngine? insightsEngine,
    InsightCacheService? cacheService,
    ChangeDetectionService? changeDetectionService,
    WorkoutRepository? workoutRepository,
    NutritionRepository? nutritionRepository,
    BodyRepository? bodyRepository,
  })  : _injectedInsightsEngine = insightsEngine,
        _injectedCacheService = cacheService,
        _injectedChangeDetectionService = changeDetectionService,
        _injectedWorkoutRepository = workoutRepository,
        _injectedNutritionRepository = nutritionRepository,
        _injectedBodyRepository = bodyRepository;

  final AIInsightsEngine? _injectedInsightsEngine;
  final InsightCacheService? _injectedCacheService;
  final ChangeDetectionService? _injectedChangeDetectionService;
  final WorkoutRepository? _injectedWorkoutRepository;
  final NutritionRepository? _injectedNutritionRepository;
  final BodyRepository? _injectedBodyRepository;

  late AIInsightsEngine _insightsEngine;
  late InsightCacheService _cacheService;
  late ChangeDetectionService _changeDetectionService;
  late WorkoutRepository _workoutRepository;
  late NutritionRepository _nutritionRepository;
  late BodyRepository _bodyRepository;

  /// Timer for batching multiple data changes within 5 seconds
  Timer? _batchTimer;

  /// Set of contexts pending refresh (used for batching)
  final Set<InsightContext> _pendingContexts = {};

  bool _buildFailed = false;
  bool _disposed = false;

  bool get _canMutate => !_buildFailed && !_disposed;

  @override
  GlobalAIState build() {
    _buildFailed = true;
    _disposed = false;
    _batchTimer?.cancel();
    _pendingContexts.clear();
    ref.onDispose(() {
      _disposed = true;
      _batchTimer?.cancel();
      AppLogger.debug('🧹 [GlobalAI] Batch timer cancelled during dispose');
    });

    _insightsEngine =
        _injectedInsightsEngine ?? ref.watch(aiInsightsEngineProvider);
    _cacheService =
        _injectedCacheService ?? ref.watch(insightCacheServiceProvider);
    _changeDetectionService = _injectedChangeDetectionService ??
        ref.watch(changeDetectionServiceProvider);
    _workoutRepository =
        _injectedWorkoutRepository ?? ref.watch(workoutRepositoryProvider);
    _nutritionRepository =
        _injectedNutritionRepository ?? ref.watch(nutritionRepositoryProvider);
    _bodyRepository =
        _injectedBodyRepository ?? ref.watch(bodyRepositoryProvider);

    _buildFailed = false;
    return const GlobalAIState();
  }

  /// Initialize the Global AI Provider and restore non-stale cached insights.
  Future<void> init() async {
    if (!_canMutate) return;
    try {
      AppLogger.debug('🚀 [GlobalAI] Initializing Global AI Provider...');
      await _cacheService.init();
      if (!_canMutate) return;
      AppLogger.debug('✅ [GlobalAI] Cache service initialized');

      final Map<InsightContext, List<Insight>> restoredInsights = {};
      final Map<InsightContext, DateTime> restoredTimestamps = {};

      for (final context in InsightContext.values) {
        try {
          final cachedInsights = await _cacheService.getCachedInsights(context);
          if (cachedInsights != null &&
              !_cacheService.isCacheStale(cachedInsights)) {
            restoredInsights[context] = cachedInsights.insights;
            restoredTimestamps[context] = cachedInsights.cachedAt;
          }
        } catch (e, stackTrace) {
          AppLogger.debug(
            '❌ [GlobalAI] Failed to restore cache for ${context.name}: $e',
          );
          AppLogger.debug('🔍 [GlobalAI] Stack trace: $stackTrace');
        }
      }

      if (!_canMutate) return;
      if (restoredInsights.isNotEmpty || restoredTimestamps.isNotEmpty) {
        state = state.copyWith(
          insights: restoredInsights,
          lastUpdated: restoredTimestamps,
        );
      }

      AppLogger.debug('🎉 [GlobalAI] Global AI Provider initialization complete');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [GlobalAI] Failed to initialize Global AI Provider: $e');
      AppLogger.debug('🔍 [GlobalAI] Stack trace: $stackTrace');
    }
  }

  /// Get insights for a specific context with multi-layer caching.
  Future<List<Insight>> getInsights(
    InsightContext context, {
    NutritionTargets? nutritionTargets,
  }) async {
    if (!_canMutate) return generateFallbackInsights(context);
    try {
      AppLogger.debug('🔍 [GlobalAI] Getting insights for context: ${context.name}');

      state = state.copyWith(
        isLoading: {...state.isLoading, context: true},
        errors: {...state.errors, context: null},
      );

      // 1. Check memory cache first
      final memoryInsights = state.insights[context];
      final lastUpdated = state.lastUpdated[context];

      if (memoryInsights != null &&
          memoryInsights.isNotEmpty &&
          lastUpdated != null) {
        final cacheAge = DateTime.now().difference(lastUpdated);
        if (cacheAge.inHours < 1) {
          final dataChanged =
              await GlobalAIInsightHelpers.hasDataChangedForContext(
            changeDetectionService: _changeDetectionService,
            context: context,
            since: lastUpdated,
          );
          if (!_canMutate) return memoryInsights;

          if (!dataChanged) {
            state = state.copyWith(
              isLoading: {...state.isLoading, context: false},
            );
            return memoryInsights;
          }
        }
      }

      // 2. Check Hive cache if memory miss or stale
      final cachedInsights = await _cacheService.getCachedInsights(context);
      if (!_canMutate) return generateFallbackInsights(context);
      if (cachedInsights != null &&
          !_cacheService.isCacheStale(cachedInsights)) {
        final dataChanged =
            await GlobalAIInsightHelpers.hasDataChangedForContext(
          changeDetectionService: _changeDetectionService,
          context: context,
          since: cachedInsights.cachedAt,
        );
        if (!_canMutate) return cachedInsights.insights;

        if (!dataChanged) {
          state = state.copyWith(
            insights: {...state.insights, context: cachedInsights.insights},
            lastUpdated: {...state.lastUpdated, context: cachedInsights.cachedAt},
            isLoading: {...state.isLoading, context: false},
          );
          return cachedInsights.insights;
        }
      }

      // 3. Generate fresh insights
      final freshInsights =
          await _generateFreshInsights(context, nutritionTargets);
      if (!_canMutate) return freshInsights;
      final now = DateTime.now();

      state = state.copyWith(
        insights: {...state.insights, context: freshInsights},
        lastUpdated: {...state.lastUpdated, context: now},
        isLoading: {...state.isLoading, context: false},
      );

      GlobalAIInsightHelpers.updateHiveCache(
        cacheService: _cacheService,
        changeDetectionService: _changeDetectionService,
        context: context,
        insights: freshInsights,
        cachedAt: now,
      ).catchError((Object e) {
        AppLogger.debug(
          '⚠️ [GlobalAI] Failed to update Hive cache for ${context.name}: $e',
        );
      });

      return freshInsights;
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [GlobalAI] Failed to get insights for ${context.name}: $e');
      AppLogger.debug('🔍 [GlobalAI] Stack trace: $stackTrace');

      final errorMessage = e is TimeoutException
          ? 'Insight generation timed out'
          : e.toString();
      return _handleInsightGenerationError(context, errorMessage);
    }
  }

  /// Generate fresh insights for a context with 5-second timeout handling.
  Future<List<Insight>> _generateFreshInsights(
    InsightContext context,
    NutritionTargets? nutritionTargets, {
    bool isRefresh = false,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      final generationContext =
          await GlobalAIInsightHelpers.buildInsightGenerationContext(
        context: context,
        workoutRepository: _workoutRepository,
        nutritionRepository: _nutritionRepository,
        bodyRepository: _bodyRepository,
        nutritionTargets: nutritionTargets,
      );

      final dataFetchMs = stopwatch.elapsedMilliseconds;
      final insights = await _insightsEngine
          .generateInsights(generationContext)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () async {
              if (isRefresh) {
                throw TimeoutException(
                  'Insight generation timed out',
                  const Duration(seconds: 5),
                );
              }
              final cachedInsights =
                  await _cacheService.getCachedInsights(context);
              if (cachedInsights != null && cachedInsights.insights.isNotEmpty) {
                return cachedInsights.insights;
              }
              return generateFallbackInsights(context);
            },
          );

      stopwatch.stop();
      final totalMs = stopwatch.elapsedMilliseconds;
      AppLogger.debug(
        '⏱️ [GlobalAI] Total generation for ${context.name}: ${totalMs}ms '
        '(data: ${dataFetchMs}ms, engine: ${totalMs - dataFetchMs}ms)',
      );
      return insights;
    } on TimeoutException {
      if (isRefresh) rethrow;
      final cachedInsights = await _cacheService.getCachedInsights(context);
      if (cachedInsights != null && cachedInsights.insights.isNotEmpty) {
        return cachedInsights.insights;
      }
      return generateFallbackInsights(context);
    }
  }

  Future<List<Insight>> _handleInsightGenerationError(
    InsightContext context,
    String errorMessage,
  ) async {
    if (!_canMutate) return generateFallbackInsights(context);
    state = state.copyWith(
      isLoading: {...state.isLoading, context: false},
      errors: {...state.errors, context: errorMessage},
    );

    try {
      final cachedInsights = await _cacheService.getCachedInsights(context);
      if (!_canMutate) return generateFallbackInsights(context);
      if (cachedInsights != null && cachedInsights.insights.isNotEmpty) {
        state = state.copyWith(
          insights: {...state.insights, context: cachedInsights.insights},
          lastUpdated: {...state.lastUpdated, context: cachedInsights.cachedAt},
        );
        return cachedInsights.insights;
      }
    } catch (e) {
      AppLogger.debug(
        '⚠️ [GlobalAI] Failed to retrieve cached insights as fallback: $e',
      );
    }

    return generateFallbackInsights(context);
  }

  /// Generate fallback insights when generation fails and no cache is available.
  @visibleForTesting
  List<Insight> generateFallbackInsights(InsightContext context) {
    return GlobalAIInsightHelpers.generateFallbackInsights(context);
  }

  /// Force refresh insights for a specific context regardless of cache state.
  Future<List<Insight>> refreshInsights(
    InsightContext context, {
    NutritionTargets? nutritionTargets,
  }) async {
    if (!_canMutate) return [];
    try {
      state = state.copyWith(
        isLoading: {...state.isLoading, context: true},
        errors: {...state.errors, context: null},
      );

      final updatedInsights =
          Map<InsightContext, List<Insight>>.from(state.insights);
      final updatedTimestamps =
          Map<InsightContext, DateTime>.from(state.lastUpdated);
      updatedInsights.remove(context);
      updatedTimestamps.remove(context);

      state = state.copyWith(
        insights: updatedInsights,
        lastUpdated: updatedTimestamps,
      );

      try {
        await _cacheService.invalidateCache(context);
      } catch (e) {
        AppLogger.debug(
          '⚠️ [GlobalAI] Failed to invalidate Hive cache for ${context.name}: $e',
        );
      }
      if (!_canMutate) return [];

      final freshInsights = await _generateFreshInsights(
        context,
        nutritionTargets,
        isRefresh: true,
      );
      if (!_canMutate) return freshInsights;
      final now = DateTime.now();

      state = state.copyWith(
        insights: {...state.insights, context: freshInsights},
        lastUpdated: {...state.lastUpdated, context: now},
        isLoading: {...state.isLoading, context: false},
      );

      GlobalAIInsightHelpers.updateHiveCache(
        cacheService: _cacheService,
        changeDetectionService: _changeDetectionService,
        context: context,
        insights: freshInsights,
        cachedAt: now,
      ).catchError((Object e) {
        AppLogger.debug(
          '⚠️ [GlobalAI] Failed to update Hive cache for ${context.name}: $e',
        );
      });

      return freshInsights;
    } catch (e, stackTrace) {
      AppLogger.debug(
        '❌ [GlobalAI] Failed to refresh insights for ${context.name}: $e',
      );
      AppLogger.debug('🔍 [GlobalAI] Stack trace: $stackTrace');

      if (!_canMutate) return [];
      final errorMessage = e is TimeoutException
          ? 'Insight generation timed out. Please try again.'
          : 'Failed to refresh insights: ${e.toString()}';

      state = state.copyWith(
        isLoading: {...state.isLoading, context: false},
        errors: {...state.errors, context: errorMessage},
      );
      return [];
    }
  }

  /// Handle workout completion event.
  Future<void> onWorkoutCompleted(Workout completedWorkout) async {
    if (!_canMutate) return;
    try {
      try {
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        final workoutHistory = await _workoutRepository.getWorkoutsByDateRange(
          thirtyDaysAgo,
          DateTime.now(),
        );
        final quickFeedback = await _insightsEngine.generateQuickFeedback(
          completedWorkout,
          workoutHistory,
        );
        if (_canMutate) {
          state = state.copyWith(quickFeedback: quickFeedback);
        }
      } catch (e, stackTrace) {
        AppLogger.debug('❌ [GlobalAI] Failed to generate quick feedback: $e');
        AppLogger.debug('🔍 [GlobalAI] Stack trace: $stackTrace');
      }

      if (_canMutate) {
        _scheduleBatchedRefresh([InsightContext.home, InsightContext.workout]);
      }
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [GlobalAI] Failed to handle workout completion: $e');
      AppLogger.debug('🔍 [GlobalAI] Stack trace: $stackTrace');
    }
  }

  Future<void> _invalidateContextCaches(List<InsightContext> contexts) async {
    await Future.wait(contexts.map((context) async {
      try {
        await _cacheService.invalidateCache(context);
      } catch (e) {
        AppLogger.debug(
          '⚠️ [GlobalAI] Failed to invalidate Hive cache for ${context.name}: $e',
        );
      }
    }));
  }

  /// Schedule contexts for batched refresh with 5-second debouncing.
  void _scheduleBatchedRefresh(List<InsightContext> contexts) {
    if (!_canMutate) return;
    _pendingContexts.addAll(contexts);
    _batchTimer?.cancel();

    _batchTimer = Timer(const Duration(seconds: 5), () async {
      if (!_canMutate) return;
      final contextsToRefresh = List<InsightContext>.from(_pendingContexts);
      _pendingContexts.clear();

      final updatedInsights =
          Map<InsightContext, List<Insight>>.from(state.insights);
      final updatedTimestamps =
          Map<InsightContext, DateTime>.from(state.lastUpdated);

      for (final context in contextsToRefresh) {
        updatedInsights.remove(context);
        updatedTimestamps.remove(context);
      }

      state = state.copyWith(
        insights: updatedInsights,
        lastUpdated: updatedTimestamps,
      );

      await _invalidateContextCaches(contextsToRefresh);
    });
  }

  /// Handle meal logged event.
  Future<void> onMealLogged() async {
    if (!_canMutate) return;
    try {
      _scheduleBatchedRefresh([InsightContext.home, InsightContext.nutrition]);
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [GlobalAI] Failed to handle meal logging: $e');
      AppLogger.debug('🔍 [GlobalAI] Stack trace: $stackTrace');
    }
  }

  /// Handle body weight recorded event.
  Future<void> onBodyWeightRecorded() async {
    if (!_canMutate) return;
    try {
      _scheduleBatchedRefresh([InsightContext.home, InsightContext.profile]);
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [GlobalAI] Failed to handle body weight recording: $e');
      AppLogger.debug('🔍 [GlobalAI] Stack trace: $stackTrace');
    }
  }

  /// Dismiss quick feedback by clearing it from state.
  void dismissQuickFeedback() {
    if (!_canMutate) return;
    state = state.copyWith(quickFeedback: null);
  }

  /// Seed state directly in unit tests.
  @visibleForTesting
  set debugState(GlobalAIState value) {
    state = value;
  }
}
