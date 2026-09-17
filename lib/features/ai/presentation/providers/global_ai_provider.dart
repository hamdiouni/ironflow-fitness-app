import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_cache.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_generation_context.dart';
import 'package:progression_tracker/features/ai/domain/services/ai_insights_engine.dart';
import 'package:progression_tracker/features/ai/domain/services/insight_cache_service.dart';
import 'package:progression_tracker/features/ai/domain/services/change_detection_service.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/ai/data/services/ai_insights_engine_impl.dart';
import 'package:progression_tracker/features/ai/data/services/insight_cache_service_impl.dart';
import 'package:progression_tracker/features/ai/data/services/change_detection_service_impl.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:progression_tracker/features/body/presentation/providers/body_providers.dart';
import 'package:uuid/uuid.dart';

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
  return InsightCacheServiceImpl();
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
final globalAIProvider = StateNotifierProvider<GlobalAINotifier, GlobalAIState>((ref) {
  final insightsEngine = ref.watch(aiInsightsEngineProvider);
  final cacheService = ref.watch(insightCacheServiceProvider);
  final changeDetectionService = ref.watch(changeDetectionServiceProvider);
  final workoutRepository = ref.watch(workoutRepositoryProvider);
  final nutritionRepository = ref.watch(nutritionRepositoryProvider);
  final bodyRepository = ref.watch(bodyRepositoryProvider);
  
  return GlobalAINotifier(
    insightsEngine: insightsEngine,
    cacheService: cacheService,
    changeDetectionService: changeDetectionService,
    workoutRepository: workoutRepository,
    nutritionRepository: nutritionRepository,
    bodyRepository: bodyRepository,
  );
});

// ---------------------------------------------------------------------------
// Global AI Notifier Class
// ---------------------------------------------------------------------------

/// Global AI Notifier that manages insight state across all contexts
///
/// This notifier coordinates AI insight generation and caching for all main screens
/// (Home, Workout, Nutrition, Profile). It listens to data changes and automatically
/// updates insights when needed.
///
/// **Key Features:**
/// - Context-specific insight generation
/// - Multi-layer caching (memory + Hive)
/// - Change detection to avoid unnecessary regeneration
/// - Batching logic for multiple data changes
/// - Quick feedback system for workout completion
///
/// **Requirements:**
/// - 3.1: Maintain current insights for each Context
/// - 3.2: Expose methods to retrieve insights for a specific Context
/// - 3.5: Provide a method to manually refresh insights for a Context
class GlobalAINotifier extends StateNotifier<GlobalAIState> {
  GlobalAINotifier({
    required AIInsightsEngine insightsEngine,
    required InsightCacheService cacheService,
    required ChangeDetectionService changeDetectionService,
    required WorkoutRepository workoutRepository,
    required NutritionRepository nutritionRepository,
    required BodyRepository bodyRepository,
  })  : _insightsEngine = insightsEngine,
        _cacheService = cacheService,
        _changeDetectionService = changeDetectionService,
        _workoutRepository = workoutRepository,
        _nutritionRepository = nutritionRepository,
        _bodyRepository = bodyRepository,
        super(const GlobalAIState());

  final AIInsightsEngine _insightsEngine;
  final InsightCacheService _cacheService;
  final ChangeDetectionService _changeDetectionService;
  final WorkoutRepository _workoutRepository;
  final NutritionRepository _nutritionRepository;
  final BodyRepository _bodyRepository;

  /// Timer for batching multiple data changes within 5 seconds
  Timer? _batchTimer;
  
  /// Set of contexts pending refresh (used for batching)
  final Set<InsightContext> _pendingContexts = {};

  /// Initialize the Global AI Provider
  ///
  /// This method:
  /// 1. Initializes the cache service (opens Hive box)
  /// 2. Restores cached insights for all contexts
  /// 3. Updates state with restored insights and timestamps
  /// 4. Handles errors gracefully (logs but doesn't fail)
  ///
  /// **Requirements:**
  /// - 3.6: Cache insights until underlying data changes
  /// - 4.7: Persist insight cache to local storage
  /// - 4.8: Check if cached insights are stale before regenerating
  Future<void> init() async {
    try {
      print('🚀 [GlobalAI] Initializing Global AI Provider...');
      
      // 1. Initialize cache service (open Hive box)
      await _cacheService.init();
      print('✅ [GlobalAI] Cache service initialized');
      
      // 2. Restore cached insights for all contexts
      final Map<InsightContext, List<Insight>> restoredInsights = {};
      final Map<InsightContext, DateTime> restoredTimestamps = {};
      
      // Loop through all InsightContext values
      for (final context in InsightContext.values) {
        try {
          print('🔍 [GlobalAI] Restoring cache for context: ${context.name}');
          
          final cachedInsights = await _cacheService.getCachedInsights(context);
          
          if (cachedInsights != null) {
            // Check if cache is stale
            if (!_cacheService.isCacheStale(cachedInsights)) {
              // Cache is fresh, restore to state
              restoredInsights[context] = cachedInsights.insights;
              restoredTimestamps[context] = cachedInsights.cachedAt;
              
              print('✅ [GlobalAI] Restored ${cachedInsights.insights.length} insights for ${context.name}');
              print('🔍 [GlobalAI] Cache timestamp: ${cachedInsights.cachedAt}');
            } else {
              print('⚠️ [GlobalAI] Cache for ${context.name} is stale, will regenerate on next request');
            }
          } else {
            print('🔍 [GlobalAI] No cache found for ${context.name}');
          }
        } catch (e, stackTrace) {
          // Handle individual context restoration errors gracefully
          print('❌ [GlobalAI] Failed to restore cache for ${context.name}: $e');
          print('🔍 [GlobalAI] Stack trace: $stackTrace');
          // Continue with other contexts
        }
      }
      
      // 3. Update state with restored insights and timestamps
      if (restoredInsights.isNotEmpty || restoredTimestamps.isNotEmpty) {
        state = state.copyWith(
          insights: restoredInsights,
          lastUpdated: restoredTimestamps,
        );
        
        print('✅ [GlobalAI] State updated with restored insights');
        print('🔍 [GlobalAI] Restored contexts: ${restoredInsights.keys.map((c) => c.name).join(', ')}');
      }
      
      print('🎉 [GlobalAI] Global AI Provider initialization complete');
      
    } catch (e, stackTrace) {
      // Handle initialization errors gracefully - log but don't fail
      print('❌ [GlobalAI] Failed to initialize Global AI Provider: $e');
      print('🔍 [GlobalAI] Stack trace: $stackTrace');
      
      // Don't rethrow - the app should continue to work even if AI initialization fails
      // The provider will work with empty state and generate insights on demand
    }
  }

  /// Get insights for a specific context with multi-layer caching
  ///
  /// This method implements the core caching strategy:
  /// 1. Check memory cache (state.insights[context]) first
  /// 2. If memory miss, check Hive cache via _cacheService.getCachedInsights()
  /// 3. If cache miss or stale, use change detection to see if regeneration needed
  /// 4. Generate fresh insights if needed using _insightsEngine.generateInsights()
  /// 5. Update both memory and Hive cache after generation
  ///
  /// **Parameters:**
  /// - [context]: The insight context to retrieve insights for
  /// - [nutritionTargets]: Optional nutrition targets for nutrition-related insights
  ///
  /// **Returns:**
  /// A list of insights for the specified context
  ///
  /// **Requirements:**
  /// - 3.2: Expose methods to retrieve insights for a specific Context
  /// - 3.6: Cache insights until underlying data changes
  /// - 4.4: Use Change Detection to avoid recalculating insights when data unchanged
  /// - 4.5: Do not regenerate insights on every screen load
  /// - 11.2: Cache generated insights in memory
  /// - 11.4: Return cached insights if less than 1 hour old and data unchanged
  /// - 13.5: Return cached insights on generation failure, fallback insights if no cache
  Future<List<Insight>> getInsights(
    InsightContext context, {
    NutritionTargets? nutritionTargets,
  }) async {
    try {
      print('🔍 [GlobalAI] Getting insights for context: ${context.name}');
      
      // Set loading state to true at start
      state = state.copyWith(
        isLoading: {...state.isLoading, context: true},
        errors: {...state.errors, context: null}, // Clear any existing errors
      );

      // 1. Check memory cache first
      final memoryInsights = state.insights[context];
      final lastUpdated = state.lastUpdated[context];
      
      if (memoryInsights != null && memoryInsights.isNotEmpty && lastUpdated != null) {
        print('✅ [GlobalAI] Found ${memoryInsights.length} insights in memory cache for ${context.name}');
        
        // Check if memory cache is still fresh (less than 1 hour old)
        final cacheAge = DateTime.now().difference(lastUpdated);
        if (cacheAge.inHours < 1) {
          // Check if data has changed since last generation
          final dataChanged = await _hasDataChangedForContext(context, lastUpdated);
          
          if (!dataChanged) {
            print('✅ [GlobalAI] Memory cache is fresh and data unchanged, returning cached insights');
            
            // Set loading to false and return cached insights
            state = state.copyWith(
              isLoading: {...state.isLoading, context: false},
            );
            
            return memoryInsights;
          } else {
            print('🔄 [GlobalAI] Data has changed since last generation, need to regenerate');
          }
        } else {
          print('⏰ [GlobalAI] Memory cache is stale (${cacheAge.inHours} hours old), checking Hive cache');
        }
      } else {
        print('🔍 [GlobalAI] No insights found in memory cache for ${context.name}');
      }

      // 2. Check Hive cache if memory miss or stale
      final cachedInsights = await _cacheService.getCachedInsights(context);
      
      if (cachedInsights != null) {
        print('✅ [GlobalAI] Found cached insights in Hive for ${context.name}');
        
        // Check if Hive cache is stale
        if (!_cacheService.isCacheStale(cachedInsights)) {
          // Check if data has changed since cache was created
          final dataChanged = await _hasDataChangedForContext(context, cachedInsights.cachedAt);
          
          if (!dataChanged) {
            print('✅ [GlobalAI] Hive cache is fresh and data unchanged, restoring to memory');
            
            // Restore to memory cache and return
            state = state.copyWith(
              insights: {...state.insights, context: cachedInsights.insights},
              lastUpdated: {...state.lastUpdated, context: cachedInsights.cachedAt},
              isLoading: {...state.isLoading, context: false},
            );
            
            return cachedInsights.insights;
          } else {
            print('🔄 [GlobalAI] Data has changed since Hive cache was created, need to regenerate');
          }
        } else {
          print('⏰ [GlobalAI] Hive cache is stale, need to regenerate');
        }
      } else {
        print('🔍 [GlobalAI] No cached insights found in Hive for ${context.name}');
      }

      // 3. Generate fresh insights if cache miss or stale or data changed
      print('🚀 [GlobalAI] Generating fresh insights for ${context.name}');
      
      final freshInsights = await _generateFreshInsights(context, nutritionTargets);
      
      // 4. Update both memory and Hive cache after generation
      final now = DateTime.now();
      
      // Update memory cache
      state = state.copyWith(
        insights: {...state.insights, context: freshInsights},
        lastUpdated: {...state.lastUpdated, context: now},
        isLoading: {...state.isLoading, context: false},
      );
      
      // Update Hive cache (don't await to avoid blocking)
      _updateHiveCache(context, freshInsights, now).catchError((e) {
        print('⚠️ [GlobalAI] Failed to update Hive cache for ${context.name}: $e');
        // Don't rethrow - caching failure shouldn't affect the user experience
      });
      
      print('✅ [GlobalAI] Successfully generated and cached ${freshInsights.length} fresh insights for ${context.name}');
      
      return freshInsights;
      
    } catch (e, stackTrace) {
      print('❌ [GlobalAI] Failed to get insights for ${context.name}: $e');
      print('🔍 [GlobalAI] Stack trace: $stackTrace');
      
      // Handle errors with fallback to cached insights
      String errorMessage;
      if (e is TimeoutException) {
        errorMessage = 'Insight generation timed out';
        print('⏰ [GlobalAI] Timeout occurred during getInsights for ${context.name}');
      } else {
        errorMessage = e.toString();
      }
      
      return await _handleInsightGenerationError(context, errorMessage);
    }
  }

  /// Check if data has changed for a specific context since the given timestamp
  Future<bool> _hasDataChangedForContext(InsightContext context, DateTime since) async {
    try {
      switch (context) {
        case InsightContext.home:
          // Home context uses all data sources
          final workoutChanged = await _changeDetectionService.hasWorkoutDataChanged(since);
          final nutritionChanged = await _changeDetectionService.hasNutritionDataChanged(since);
          final bodyChanged = await _changeDetectionService.hasBodyDataChanged(since);
          return workoutChanged || nutritionChanged || bodyChanged;
          
        case InsightContext.workout:
          // Workout context only uses workout data
          return await _changeDetectionService.hasWorkoutDataChanged(since);
          
        case InsightContext.nutrition:
          // Nutrition context only uses nutrition data
          return await _changeDetectionService.hasNutritionDataChanged(since);
          
        case InsightContext.profile:
          // Profile context uses body data and workout data for performance comparison
          final workoutChanged = await _changeDetectionService.hasWorkoutDataChanged(since);
          final bodyChanged = await _changeDetectionService.hasBodyDataChanged(since);
          return workoutChanged || bodyChanged;
      }
    } catch (e) {
      print('⚠️ [GlobalAI] Failed to check data changes for ${context.name}: $e');
      // If change detection fails, assume data has changed to be safe
      return true;
    }
  }

  /// Generate fresh insights for a context with timeout handling
  Future<List<Insight>> _generateFreshInsights(
    InsightContext context,
    NutritionTargets? nutritionTargets, {
    bool isRefresh = false,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();

      // Fetch data for insight generation
      final generationContext = await _buildInsightGenerationContext(context, nutritionTargets);

      final dataFetchMs = stopwatch.elapsedMilliseconds;
      print('⏱️ [GlobalAI] Data fetch for ${context.name} took ${dataFetchMs}ms');

      // Generate insights using the insights engine with 5-second timeout
      final insights = await _insightsEngine.generateInsights(generationContext)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () async {
              print('⏰ [GlobalAI] Insight generation timed out for ${context.name}, attempting fallback');
              
              if (isRefresh) {
                // For refresh operations, throw TimeoutException to return empty list
                throw TimeoutException('Insight generation timed out', const Duration(seconds: 5));
              }
              
              // For getInsights, try to return cached insights on timeout
              final cachedInsights = await _cacheService.getCachedInsights(context);
              if (cachedInsights != null && cachedInsights.insights.isNotEmpty) {
                print('✅ [GlobalAI] Returning cached insights as timeout fallback for ${context.name}');
                return cachedInsights.insights;
              }
              
              // If no cached insights available, return fallback insights
              print('⚠️ [GlobalAI] No cached insights available, generating fallback insights for ${context.name}');
              return generateFallbackInsights(context);
            },
          );

      stopwatch.stop();
      final totalMs = stopwatch.elapsedMilliseconds;
      print('⏱️ [GlobalAI] Total generation for ${context.name}: ${totalMs}ms (data: ${dataFetchMs}ms, engine: ${totalMs - dataFetchMs}ms)');

      if (totalMs > 500) {
        print('⚠️ [GlobalAI] Insight generation exceeded 500ms target for ${context.name}: ${totalMs}ms');
      }

      return insights;
      
    } on TimeoutException catch (e) {
      print('⏰ [GlobalAI] TimeoutException caught for ${context.name}: $e');
      
      if (isRefresh) {
        // For refresh operations, rethrow to return empty list
        rethrow;
      }
      
      // For getInsights, try to return cached insights on timeout
      final cachedInsights = await _cacheService.getCachedInsights(context);
      if (cachedInsights != null && cachedInsights.insights.isNotEmpty) {
        print('✅ [GlobalAI] Returning cached insights as timeout fallback for ${context.name}');
        return cachedInsights.insights;
      }
      
      // If no cached insights available, return fallback insights
      print('⚠️ [GlobalAI] No cached insights available, generating fallback insights for ${context.name}');
      return generateFallbackInsights(context);
    }
  }

  /// Build InsightGenerationContext with required data
  ///
  /// Optimized to only fetch data sources needed for the specific context,
  /// reducing unnecessary database queries.
  ///
  /// **Requirements:**
  /// - 11.6: Limit data queries to date ranges needed
  /// - 11.7: Fetch data in parallel for performance
  Future<InsightGenerationContext> _buildInsightGenerationContext(
    InsightContext context,
    NutritionTargets? nutritionTargets,
  ) async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    // Determine which data sources are needed for this context
    // to avoid unnecessary database queries
    final needsWorkouts = context == InsightContext.home ||
        context == InsightContext.workout ||
        context == InsightContext.profile;
    final needsNutrition = context == InsightContext.home ||
        context == InsightContext.nutrition;
    final needsBody = context == InsightContext.home ||
        context == InsightContext.profile;

    try {
      // Fetch only required data in parallel for better performance
      final futures = <Future<dynamic>>[
        needsWorkouts
            ? _workoutRepository.getWorkoutsByDateRange(thirtyDaysAgo, now)
            : Future.value(<Workout>[]),
        needsNutrition
            ? _nutritionRepository.getNutritionHistory(sevenDaysAgo, now)
            : Future.value(<DailyNutritionSummary>[]),
        needsBody
            ? _bodyRepository.getBodyEntriesByDateRange(thirtyDaysAgo, now)
            : Future.value(<BodyEntry>[]),
      ];

      final results = await Future.wait(futures);

      final workouts = results[0] as List<Workout>;
      final nutrition = results[1] as List<DailyNutritionSummary>;
      final bodyEntries = results[2] as List<BodyEntry>;

      print('🔍 [GlobalAI] Fetched data for ${context.name}: ${workouts.length} workouts, ${nutrition.length} nutrition days, ${bodyEntries.length} body entries');

      return InsightGenerationContext(
        context: context,
        profile: null,
        recentWorkouts: workouts,
        nutritionHistory: nutrition,
        nutritionTargets: nutritionTargets,
        bodyEntries: bodyEntries,
        generatedAt: now,
      );
    } catch (e) {
      print('⚠️ [GlobalAI] Failed to fetch some data for ${context.name}: $e');
      
      // Return context with empty data rather than failing completely
      return InsightGenerationContext(
        context: context,
        profile: null,
        recentWorkouts: [],
        nutritionHistory: [],
        nutritionTargets: nutritionTargets,
        bodyEntries: [],
        generatedAt: now,
      );
    }
  }

  /// Update Hive cache with new insights
  Future<void> _updateHiveCache(
    InsightContext context,
    List<Insight> insights,
    DateTime cachedAt,
  ) async {
    try {
      // Get current data timestamps for change detection
      final dataTimestamps = <String, DateTime>{};
      
      final lastWorkoutChange = await _changeDetectionService.getLastDataChange(InsightContext.workout);
      if (lastWorkoutChange != null) {
        dataTimestamps['workout'] = lastWorkoutChange;
      }
      
      final lastNutritionChange = await _changeDetectionService.getLastDataChange(InsightContext.nutrition);
      if (lastNutritionChange != null) {
        dataTimestamps['nutrition'] = lastNutritionChange;
      }
      
      final lastBodyChange = await _changeDetectionService.getLastDataChange(InsightContext.profile);
      if (lastBodyChange != null) {
        dataTimestamps['body'] = lastBodyChange;
      }

      final cache = InsightCache(
        context: context,
        insights: insights,
        cachedAt: cachedAt,
        dataTimestamps: dataTimestamps,
      );

      await _cacheService.cacheInsights(cache);
      print('✅ [GlobalAI] Updated Hive cache for ${context.name}');
      
    } catch (e) {
      print('⚠️ [GlobalAI] Failed to update Hive cache for ${context.name}: $e');
      // Don't rethrow - caching failure shouldn't affect the user experience
    }
  }

  /// Handle insight generation errors with fallback logic
  Future<List<Insight>> _handleInsightGenerationError(
    InsightContext context,
    String errorMessage,
  ) async {
    print('🔄 [GlobalAI] Handling insight generation error for ${context.name}');
    
    // Set error state
    state = state.copyWith(
      isLoading: {...state.isLoading, context: false},
      errors: {...state.errors, context: errorMessage},
    );

    try {
      // Try to return cached insights as fallback
      final cachedInsights = await _cacheService.getCachedInsights(context);
      
      if (cachedInsights != null && cachedInsights.insights.isNotEmpty) {
        print('✅ [GlobalAI] Returning cached insights as fallback for ${context.name}');
        
        // Update memory cache with fallback insights
        state = state.copyWith(
          insights: {...state.insights, context: cachedInsights.insights},
          lastUpdated: {...state.lastUpdated, context: cachedInsights.cachedAt},
        );
        
        return cachedInsights.insights;
      }
    } catch (e) {
      print('⚠️ [GlobalAI] Failed to retrieve cached insights as fallback: $e');
    }

    // If no cached insights available, return fallback insights
    print('⚠️ [GlobalAI] No cached insights available for ${context.name}, generating fallback insights');
    return generateFallbackInsights(context);
  }

  /// Generate fallback insights when generation fails and no cache is available
  /// 
  /// These are generic motivational insights that encourage data entry and provide
  /// basic guidance when the AI engine cannot generate personalized insights.
  /// 
  /// **Parameters:**
  /// - [context]: The insight context to generate fallback insights for
  /// 
  /// **Returns:**
  /// A list of generic fallback insights appropriate for the context
  @visibleForTesting
  List<Insight> generateFallbackInsights(InsightContext context) {
    final uuid = const Uuid();
    final now = DateTime.now();
    
    switch (context) {
      case InsightContext.home:
        return [
          Insight(
            id: uuid.v4(),
            context: context,
            title: 'Welcome to Your Fitness Journey',
            message: 'Start logging workouts and meals to get personalized coaching insights that help you reach your goals faster.',
            icon: '🎯',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
          Insight(
            id: uuid.v4(),
            context: context,
            title: 'Consistency is Key',
            message: 'The most successful fitness journeys start with small, consistent actions. Log your first workout or meal today!',
            icon: '📈',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
        ];
        
      case InsightContext.workout:
        return [
          Insight(
            id: uuid.v4(),
            context: context,
            title: 'Track Your Progress',
            message: 'Log your workouts to see strength gains, volume trends, and get personalized training recommendations.',
            icon: '💪',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
          Insight(
            id: uuid.v4(),
            context: context,
            title: 'Progressive Overload',
            message: 'Gradually increase weight, reps, or sets each week to build strength and muscle effectively.',
            icon: '⬆️',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
        ];
        
      case InsightContext.nutrition:
        return [
          Insight(
            id: uuid.v4(),
            context: context,
            title: 'Fuel Your Goals',
            message: 'Track your meals to ensure you\'re eating enough protein and calories to support your training.',
            icon: '🍽️',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
          Insight(
            id: uuid.v4(),
            context: context,
            title: 'Protein Matters',
            message: 'Aim for 1.6-2.2g of protein per kg of body weight daily to maximize muscle growth and recovery.',
            icon: '🥩',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
        ];
        
      case InsightContext.profile:
        return [
          Insight(
            id: uuid.v4(),
            context: context,
            title: 'Your Journey Starts Here',
            message: 'Track your body weight and measurements to monitor progress toward your fitness goals.',
            icon: '📊',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
          Insight(
            id: uuid.v4(),
            context: context,
            title: 'Long-term Success',
            message: 'Focus on sustainable habits rather than quick fixes. Small changes compound into big results over time.',
            icon: '🌱',
            priority: InsightPriority.medium,
            generatedAt: now,
          ),
        ];
    }
  }

  /// Force refresh insights for a specific context regardless of cache state
  ///
  /// This method bypasses all cache checks and forces regeneration of insights.
  /// It's useful when the user manually requests a refresh or when we want to
  /// ensure the most up-to-date insights are displayed.
  ///
  /// **Process:**
  /// 1. Set loading state to true
  /// 2. Clear any existing errors for the context
  /// 3. Invalidate existing cache (both memory and Hive)
  /// 4. Generate fresh insights using the insight engine
  /// 5. Update both memory and Hive cache with new insights
  /// 6. Set loading state to false
  /// 7. Handle errors gracefully (return empty list if generation fails completely)
  ///
  /// **Parameters:**
  /// - [context]: The insight context to refresh insights for
  /// - [nutritionTargets]: Optional nutrition targets for nutrition-related insights
  ///
  /// **Returns:**
  /// A list of freshly generated insights for the specified context
  ///
  /// **Requirements:**
  /// - 3.5: Provide a method to manually refresh insights for a Context
  Future<List<Insight>> refreshInsights(
    InsightContext context, {
    NutritionTargets? nutritionTargets,
  }) async {
    try {
      print('🔄 [GlobalAI] Force refreshing insights for context: ${context.name}');
      
      // 1. Set loading state to true and clear errors
      state = state.copyWith(
        isLoading: {...state.isLoading, context: true},
        errors: {...state.errors, context: null}, // Clear any existing errors
      );

      // 2. Invalidate existing cache to ensure fresh generation
      print('🗑️ [GlobalAI] Invalidating cache for ${context.name}');
      
      // Clear memory cache for this context
      final updatedInsights = Map<InsightContext, List<Insight>>.from(state.insights);
      final updatedTimestamps = Map<InsightContext, DateTime>.from(state.lastUpdated);
      updatedInsights.remove(context);
      updatedTimestamps.remove(context);
      
      state = state.copyWith(
        insights: updatedInsights,
        lastUpdated: updatedTimestamps,
      );
      
      // Invalidate Hive cache (handle errors gracefully)
      try {
        await _cacheService.invalidateCache(context);
        print('✅ [GlobalAI] Successfully invalidated Hive cache for ${context.name}');
      } catch (e) {
        print('⚠️ [GlobalAI] Failed to invalidate Hive cache for ${context.name}: $e');
        // Don't rethrow - cache invalidation failure shouldn't stop refresh
      }

      // 3. Generate fresh insights (reuse existing helper method with timeout)
      print('🚀 [GlobalAI] Generating fresh insights for ${context.name} (forced refresh)');
      
      final freshInsights = await _generateFreshInsights(context, nutritionTargets, isRefresh: true);
      
      // 4. Update both memory and Hive cache after generation
      final now = DateTime.now();
      
      // Update memory cache
      state = state.copyWith(
        insights: {...state.insights, context: freshInsights},
        lastUpdated: {...state.lastUpdated, context: now},
        isLoading: {...state.isLoading, context: false},
      );
      
      // Update Hive cache (don't await to avoid blocking)
      _updateHiveCache(context, freshInsights, now).catchError((e) {
        print('⚠️ [GlobalAI] Failed to update Hive cache for ${context.name}: $e');
        // Don't rethrow - caching failure shouldn't affect the user experience
      });
      
      print('✅ [GlobalAI] Successfully force refreshed ${freshInsights.length} insights for ${context.name}');
      
      return freshInsights;
      
    } catch (e, stackTrace) {
      print('❌ [GlobalAI] Failed to refresh insights for ${context.name}: $e');
      print('🔍 [GlobalAI] Stack trace: $stackTrace');
      
      // Handle errors gracefully - set error state
      String errorMessage;
      if (e is TimeoutException) {
        errorMessage = 'Insight generation timed out. Please try again.';
        print('⏰ [GlobalAI] Timeout occurred during refresh for ${context.name}');
      } else {
        errorMessage = 'Failed to refresh insights: ${e.toString()}';
      }
      
      state = state.copyWith(
        isLoading: {...state.isLoading, context: false},
        errors: {...state.errors, context: errorMessage},
      );
      
      // For refresh operations, we don't fall back to cached insights since
      // the user explicitly requested fresh data. Return empty list instead.
      print('⚠️ [GlobalAI] Returning empty list due to refresh failure for ${context.name}');
      return [];
    }
  }

  /// Handle workout completion event
  ///
  /// This method is called when a user completes a workout. It:
  /// 1. Schedules refresh for Home and Workout contexts (invalidates cache)
  /// 2. Generates quick feedback using the insights engine
  /// 3. Updates quickFeedback state with the generated feedback
  /// 4. Handles errors gracefully (logs but doesn't fail)
  ///
  /// **Process:**
  /// - Fetch workout history for quick feedback generation (last 30 days)
  /// - Call _insightsEngine.generateQuickFeedback(completedWorkout, history)
  /// - Update state with the generated quick feedback
  /// - Invalidate cache for Home and Workout contexts to schedule refresh
  /// - Log the workout completion event for debugging
  ///
  /// **Parameters:**
  /// - [completedWorkout]: The workout that was just completed
  ///
  /// **Requirements:**
  /// - 3.7: Listen to workout completion events to trigger insight updates
  /// - 4.1: Regenerate insights for Home and Workout contexts when workout completed
  /// - 10.1: Display Quick_Feedback bottom sheet when workout completed
  /// - 10.2: Show bottom sheet within 1 second of workout completion
  Future<void> onWorkoutCompleted(Workout completedWorkout) async {
    try {
      print('🎉 [GlobalAI] Workout completed: ${completedWorkout.exercises.length} exercises on ${completedWorkout.date}');
      
      // 1. Generate quick feedback first (this is time-sensitive for user experience)
      print('🚀 [GlobalAI] Generating quick feedback for completed workout...');
      
      try {
        // Fetch workout history for quick feedback generation (last 30 days)
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        final workoutHistory = await _workoutRepository.getWorkoutsByDateRange(
          thirtyDaysAgo,
          DateTime.now(),
        );
        
        print('🔍 [GlobalAI] Fetched ${workoutHistory.length} workouts for quick feedback generation');
        
        // Generate quick feedback using the insights engine
        final quickFeedback = await _insightsEngine.generateQuickFeedback(
          completedWorkout,
          workoutHistory,
        );
        
        // Update quickFeedback state
        state = state.copyWith(quickFeedback: quickFeedback);
        
        print('✅ [GlobalAI] Quick feedback generated and updated in state');
        print('🔍 [GlobalAI] Quick feedback: ${quickFeedback.title} - ${quickFeedback.message}');
        
      } catch (e, stackTrace) {
        print('❌ [GlobalAI] Failed to generate quick feedback: $e');
        print('🔍 [GlobalAI] Stack trace: $stackTrace');
        
        // Don't fail the entire method if quick feedback generation fails
        // The user should still get cache invalidation for fresh insights
      }
      
      // 2. Schedule refresh for Home and Workout contexts by invalidating cache
      print('🔄 [GlobalAI] Scheduling refresh for Home and Workout contexts...');
      
      // Use batching logic to schedule refresh
      _scheduleBatchedRefresh([InsightContext.home, InsightContext.workout]);
      
      print('✅ [GlobalAI] Successfully scheduled batched refresh for Home and Workout contexts');
      print('🔍 [GlobalAI] Cache will be invalidated after 5-second batch window');
      
    } catch (e, stackTrace) {
      print('❌ [GlobalAI] Failed to handle workout completion: $e');
      print('🔍 [GlobalAI] Stack trace: $stackTrace');
      
      // Log error but don't rethrow - workout completion handling should never block the user
      // The workout is already saved, this is just for AI insights
    }
  }

  /// Helper method to invalidate Hive cache for multiple contexts
  Future<void> _invalidateContextCaches(List<InsightContext> contexts) async {
    final futures = contexts.map((context) async {
      try {
        await _cacheService.invalidateCache(context);
        print('✅ [GlobalAI] Invalidated Hive cache for ${context.name}');
      } catch (e) {
        print('⚠️ [GlobalAI] Failed to invalidate Hive cache for ${context.name}: $e');
        // Don't rethrow - individual cache invalidation failures shouldn't stop others
      }
    });
    
    await Future.wait(futures);
  }

  /// Schedule contexts for batched refresh with debouncing
  ///
  /// This method implements batching logic to avoid excessive insight regeneration
  /// when multiple data changes occur in quick succession (e.g., logging multiple meals).
  ///
  /// **Batching Strategy:**
  /// 1. Add contexts to pending set
  /// 2. Cancel existing timer if any
  /// 3. Start new 5-second timer
  /// 4. When timer expires, refresh all pending contexts in parallel
  /// 5. Clear pending set after refresh
  ///
  /// **Benefits:**
  /// - Reduces unnecessary insight regeneration
  /// - Improves performance when multiple changes occur
  /// - Ensures insights are eventually updated after changes settle
  ///
  /// **Parameters:**
  /// - [contexts]: List of contexts to schedule for refresh
  ///
  /// **Requirements:**
  /// - 4.6: Batch multiple data changes within 5 seconds
  /// - 11.7: Refresh all pending contexts in parallel after timer expires
  void _scheduleBatchedRefresh(List<InsightContext> contexts) {
    print('⏱️ [GlobalAI] Scheduling batched refresh for contexts: ${contexts.map((c) => c.name).join(', ')}');
    
    // 1. Add contexts to pending set
    _pendingContexts.addAll(contexts);
    print('🔍 [GlobalAI] Pending contexts: ${_pendingContexts.map((c) => c.name).join(', ')}');
    
    // 2. Cancel existing timer if any
    _batchTimer?.cancel();
    print('🔍 [GlobalAI] Cancelled existing batch timer');
    
    // 3. Start new 5-second timer
    _batchTimer = Timer(const Duration(seconds: 5), () async {
      print('⏰ [GlobalAI] Batch timer expired, refreshing ${_pendingContexts.length} pending contexts...');
      
      // 4. Refresh all pending contexts in parallel
      final contextsToRefresh = List<InsightContext>.from(_pendingContexts);
      
      // 5. Clear pending set before refresh (to allow new batches during refresh)
      _pendingContexts.clear();
      
      // Invalidate memory cache for all pending contexts
      final updatedInsights = Map<InsightContext, List<Insight>>.from(state.insights);
      final updatedTimestamps = Map<InsightContext, DateTime>.from(state.lastUpdated);
      
      for (final context in contextsToRefresh) {
        updatedInsights.remove(context);
        updatedTimestamps.remove(context);
      }
      
      state = state.copyWith(
        insights: updatedInsights,
        lastUpdated: updatedTimestamps,
      );
      
      // Invalidate Hive cache for all pending contexts in parallel
      await _invalidateContextCaches(contextsToRefresh);
      
      print('✅ [GlobalAI] Batched refresh completed for ${contextsToRefresh.length} contexts');
      print('🔍 [GlobalAI] Refreshed contexts: ${contextsToRefresh.map((c) => c.name).join(', ')}');
    });
    
    print('✅ [GlobalAI] Batch timer started (5 seconds)');
  }

  /// Handle meal logged event
  ///
  /// This method is called when a user logs a meal. It:
  /// 1. Schedules refresh for Home and Nutrition contexts (invalidates cache to force regeneration)
  /// 2. Handles errors gracefully (logs but doesn't fail)
  /// 3. Don't block the UI - handle operations asynchronously
  ///
  /// **Process:**
  /// - Log the meal logging event for debugging
  /// - Invalidate cache for Home and Nutrition contexts to schedule refresh
  /// - Use the existing _invalidateContextCaches() helper method
  /// - Handle errors gracefully without affecting the user experience
  ///
  /// **Note:**
  /// This is simpler than onWorkoutCompleted() since no quick feedback is needed.
  /// Just invalidate cache for Home and Nutrition contexts.
  ///
  /// **Requirements:**
  /// - 3.8: Listen to meal logging events to trigger insight updates
  /// - 4.2: Regenerate insights for Home and Nutrition contexts when meal logged
  Future<void> onMealLogged() async {
    try {
      print('🍽️ [GlobalAI] Meal logged, scheduling refresh for Home and Nutrition contexts...');
      
      // Use batching logic to schedule refresh
      _scheduleBatchedRefresh([InsightContext.home, InsightContext.nutrition]);
      
      print('✅ [GlobalAI] Successfully scheduled batched refresh for Home and Nutrition contexts');
      print('🔍 [GlobalAI] Cache will be invalidated after 5-second batch window');
      
    } catch (e, stackTrace) {
      print('❌ [GlobalAI] Failed to handle meal logging: $e');
      print('🔍 [GlobalAI] Stack trace: $stackTrace');
      
      // Log error but don't rethrow - meal logging handling should never block the user
      // The meal is already saved, this is just for AI insights
    }
  }

  /// Handle body weight recorded event
  ///
  /// This method is called when a user records their body weight. It:
  /// 1. Schedules refresh for Home and Profile contexts (invalidates cache to force regeneration)
  /// 2. Handles errors gracefully (logs but doesn't fail)
  /// 3. Don't block the UI - handle operations asynchronously
  ///
  /// **Process:**
  /// - Log the body weight recording event for debugging
  /// - Invalidate cache for Home and Profile contexts to schedule refresh
  /// - Use the existing _invalidateContextCaches() helper method
  /// - Handle errors gracefully without affecting the user experience
  ///
  /// **Note:**
  /// This is similar to onMealLogged() but affects Home and Profile contexts instead.
  /// No quick feedback is needed, just invalidate cache for the relevant contexts.
  ///
  /// **Requirements:**
  /// - 3.9: Listen to body weight recording events to trigger insight updates
  /// - 4.3: Regenerate insights for Home and Profile contexts when body weight recorded
  Future<void> onBodyWeightRecorded() async {
    try {
      print('⚖️ [GlobalAI] Body weight recorded, scheduling refresh for Home and Profile contexts...');
      
      // Use batching logic to schedule refresh
      _scheduleBatchedRefresh([InsightContext.home, InsightContext.profile]);
      
      print('✅ [GlobalAI] Successfully scheduled batched refresh for Home and Profile contexts');
      print('🔍 [GlobalAI] Cache will be invalidated after 5-second batch window');
      
    } catch (e, stackTrace) {
      print('❌ [GlobalAI] Failed to handle body weight recording: $e');
      print('🔍 [GlobalAI] Stack trace: $stackTrace');
      
      // Log error but don't rethrow - body weight recording handling should never block the user
      // The body weight is already saved, this is just for AI insights
    }
  }

  /// Dismiss quick feedback by clearing it from state
  ///
  /// This method is called when the user dismisses the quick feedback bottom sheet.
  /// It simply clears the quickFeedback from the state by setting it to null.
  ///
  /// **Process:**
  /// 1. Log the dismissal event for debugging
  /// 2. Update state to clear quickFeedback (set to null)
  /// 3. No error handling needed since it's just a state update
  ///
  /// **Note:**
  /// This is a simple synchronous method that just updates the state.
  /// No async operations or error handling are needed.
  ///
  /// **Requirements:**
  /// - 10.7: Clear quickFeedback from state when dismissed
  void dismissQuickFeedback() {
    print('👋 [GlobalAI] Dismissing quick feedback');
    
    // Clear quickFeedback from state
    state = state.copyWith(quickFeedback: null);
    
    print('✅ [GlobalAI] Quick feedback dismissed and cleared from state');
  }

  @override
  void dispose() {
    // Cancel batch timer to prevent memory leaks
    _batchTimer?.cancel();
    print('🧹 [GlobalAI] Batch timer cancelled during dispose');
    
    super.dispose();
  }
}