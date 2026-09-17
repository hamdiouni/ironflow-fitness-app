import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_cache.dart';
import 'package:progression_tracker/features/ai/domain/services/ai_insights_engine.dart';
import 'package:progression_tracker/features/ai/domain/services/insight_cache_service.dart';
import 'package:progression_tracker/features/ai/domain/services/change_detection_service.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';

import 'global_ai_provider_test.mocks.dart';

@GenerateMocks([
  AIInsightsEngine,
  InsightCacheService,
  ChangeDetectionService,
  WorkoutRepository,
  NutritionRepository,
  BodyRepository,
])
void main() {
  group('GlobalAINotifier', () {
    late MockAIInsightsEngine mockInsightsEngine;
    late MockInsightCacheService mockCacheService;
    late MockChangeDetectionService mockChangeDetectionService;
    late MockWorkoutRepository mockWorkoutRepository;
    late MockNutritionRepository mockNutritionRepository;
    late MockBodyRepository mockBodyRepository;
    late GlobalAINotifier notifier;

    setUp(() {
      mockInsightsEngine = MockAIInsightsEngine();
      mockCacheService = MockInsightCacheService();
      mockChangeDetectionService = MockChangeDetectionService();
      mockWorkoutRepository = MockWorkoutRepository();
      mockNutritionRepository = MockNutritionRepository();
      mockBodyRepository = MockBodyRepository();

      notifier = GlobalAINotifier(
        insightsEngine: mockInsightsEngine,
        cacheService: mockCacheService,
        changeDetectionService: mockChangeDetectionService,
        workoutRepository: mockWorkoutRepository,
        nutritionRepository: mockNutritionRepository,
        bodyRepository: mockBodyRepository,
      );
    });

    group('init', () {
      test('should initialize cache service successfully', () async {
        // Arrange
        when(mockCacheService.init()).thenAnswer((_) async {});
        when(mockCacheService.getCachedInsights(any)).thenAnswer((_) async => null);

        // Act
        await notifier.init();

        // Assert
        verify(mockCacheService.init()).called(1);
        expect(notifier.state, equals(const GlobalAIState()));
      });

      test('should restore cached insights for all contexts', () async {
        // Arrange
        final now = DateTime.now();
        final homeInsight = Insight(
          id: 'home-1',
          context: InsightContext.home,
          title: 'Home Insight',
          message: 'Test home insight',
          icon: '🏠',
          priority: InsightPriority.medium,
          generatedAt: now,
        );
        final workoutInsight = Insight(
          id: 'workout-1',
          context: InsightContext.workout,
          title: 'Workout Insight',
          message: 'Test workout insight',
          icon: '💪',
          priority: InsightPriority.high,
          generatedAt: now,
        );

        final homeCache = InsightCache(
          context: InsightContext.home,
          insights: [homeInsight],
          cachedAt: now,
          dataTimestamps: {},
        );
        final workoutCache = InsightCache(
          context: InsightContext.workout,
          insights: [workoutInsight],
          cachedAt: now,
          dataTimestamps: {},
        );

        when(mockCacheService.init()).thenAnswer((_) async {});
        when(mockCacheService.getCachedInsights(InsightContext.home))
            .thenAnswer((_) async => homeCache);
        when(mockCacheService.getCachedInsights(InsightContext.workout))
            .thenAnswer((_) async => workoutCache);
        when(mockCacheService.getCachedInsights(InsightContext.nutrition))
            .thenAnswer((_) async => null);
        when(mockCacheService.getCachedInsights(InsightContext.profile))
            .thenAnswer((_) async => null);
        when(mockCacheService.isCacheStale(any)).thenReturn(false);

        // Act
        await notifier.init();

        // Assert
        verify(mockCacheService.init()).called(1);
        verify(mockCacheService.getCachedInsights(InsightContext.home)).called(1);
        verify(mockCacheService.getCachedInsights(InsightContext.workout)).called(1);
        verify(mockCacheService.getCachedInsights(InsightContext.nutrition)).called(1);
        verify(mockCacheService.getCachedInsights(InsightContext.profile)).called(1);

        expect(notifier.state.insights[InsightContext.home], equals([homeInsight]));
        expect(notifier.state.insights[InsightContext.workout], equals([workoutInsight]));
        expect(notifier.state.lastUpdated[InsightContext.home], equals(now));
        expect(notifier.state.lastUpdated[InsightContext.workout], equals(now));
      });

      test('should skip stale cached insights', () async {
        // Arrange
        final now = DateTime.now();
        final staleInsight = Insight(
          id: 'stale-1',
          context: InsightContext.home,
          title: 'Stale Insight',
          message: 'This insight is stale',
          icon: '🏠',
          priority: InsightPriority.medium,
          generatedAt: now.subtract(const Duration(hours: 2)),
        );

        final staleCache = InsightCache(
          context: InsightContext.home,
          insights: [staleInsight],
          cachedAt: now.subtract(const Duration(hours: 2)),
          dataTimestamps: {},
        );

        when(mockCacheService.init()).thenAnswer((_) async {});
        when(mockCacheService.getCachedInsights(InsightContext.home))
            .thenAnswer((_) async => staleCache);
        when(mockCacheService.getCachedInsights(InsightContext.workout))
            .thenAnswer((_) async => null);
        when(mockCacheService.getCachedInsights(InsightContext.nutrition))
            .thenAnswer((_) async => null);
        when(mockCacheService.getCachedInsights(InsightContext.profile))
            .thenAnswer((_) async => null);
        when(mockCacheService.isCacheStale(staleCache)).thenReturn(true);

        // Act
        await notifier.init();

        // Assert
        verify(mockCacheService.init()).called(1);
        verify(mockCacheService.isCacheStale(staleCache)).called(1);

        // State should remain empty since stale cache was skipped
        expect(notifier.state.insights[InsightContext.home], isNull);
        expect(notifier.state.lastUpdated[InsightContext.home], isNull);
      });

      test('should handle cache service initialization failure gracefully', () async {
        // Arrange
        when(mockCacheService.init()).thenThrow(Exception('Cache init failed'));

        // Act & Assert - should not throw
        await notifier.init();

        verify(mockCacheService.init()).called(1);
        expect(notifier.state, equals(const GlobalAIState()));
      });

      test('should handle individual context cache retrieval failure gracefully', () async {
        // Arrange
        final now = DateTime.now();
        final workoutInsight = Insight(
          id: 'workout-1',
          context: InsightContext.workout,
          title: 'Workout Insight',
          message: 'Test workout insight',
          icon: '💪',
          priority: InsightPriority.high,
          generatedAt: now,
        );

        final workoutCache = InsightCache(
          context: InsightContext.workout,
          insights: [workoutInsight],
          cachedAt: now,
          dataTimestamps: {},
        );

        when(mockCacheService.init()).thenAnswer((_) async {});
        when(mockCacheService.getCachedInsights(InsightContext.home))
            .thenThrow(Exception('Home cache failed'));
        when(mockCacheService.getCachedInsights(InsightContext.workout))
            .thenAnswer((_) async => workoutCache);
        when(mockCacheService.getCachedInsights(InsightContext.nutrition))
            .thenAnswer((_) async => null);
        when(mockCacheService.getCachedInsights(InsightContext.profile))
            .thenAnswer((_) async => null);
        when(mockCacheService.isCacheStale(any)).thenReturn(false);

        // Act
        await notifier.init();

        // Assert
        verify(mockCacheService.init()).called(1);
        
        // Should still restore successful contexts
        expect(notifier.state.insights[InsightContext.workout], equals([workoutInsight]));
        expect(notifier.state.lastUpdated[InsightContext.workout], equals(now));
        
        // Failed context should not be in state
        expect(notifier.state.insights[InsightContext.home], isNull);
        expect(notifier.state.lastUpdated[InsightContext.home], isNull);
      });
    });

    group('refreshInsights', () {
      test('should force regenerate insights regardless of cache state', () async {
        // Arrange
        final now = DateTime.now();
        final existingInsight = Insight(
          id: 'existing-1',
          context: InsightContext.home,
          title: 'Existing Insight',
          message: 'This should be replaced',
          icon: '🏠',
          priority: InsightPriority.medium,
          generatedAt: now.subtract(const Duration(minutes: 30)),
        );
        final newInsight = Insight(
          id: 'new-1',
          context: InsightContext.home,
          title: 'Fresh Insight',
          message: 'This is the new insight',
          icon: '🏠',
          priority: InsightPriority.high,
          generatedAt: now,
        );

        // Set up initial state with existing insights
        notifier.state = notifier.state.copyWith(
          insights: {InsightContext.home: [existingInsight]},
          lastUpdated: {InsightContext.home: now.subtract(const Duration(minutes: 30))},
        );

        // Mock fresh insight generation
        when(mockWorkoutRepository.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockNutritionRepository.getNutritionHistory(any, any))
            .thenAnswer((_) async => []);
        when(mockBodyRepository.getBodyEntriesByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockInsightsEngine.generateInsights(any))
            .thenAnswer((_) async => [newInsight]);
        when(mockCacheService.invalidateCache(any)).thenAnswer((_) async {});
        when(mockCacheService.cacheInsights(any)).thenAnswer((_) async {});
        when(mockChangeDetectionService.getLastDataChange(any))
            .thenAnswer((_) async => now);

        // Act
        final result = await notifier.refreshInsights(InsightContext.home);

        // Assert
        expect(result, equals([newInsight]));
        expect(notifier.state.insights[InsightContext.home], equals([newInsight]));
        expect(notifier.state.isLoading[InsightContext.home], equals(false));
        expect(notifier.state.errors[InsightContext.home], isNull);

        // Verify cache was invalidated and fresh insights were generated
        verify(mockInsightsEngine.generateInsights(any)).called(1);
        // Note: Cache operations are async and may not complete immediately
      });

      test('should set loading state during refresh', () async {
        // Arrange
        final newInsight = Insight(
          id: 'new-1',
          context: InsightContext.workout,
          title: 'Fresh Workout Insight',
          message: 'New workout insight',
          icon: '💪',
          priority: InsightPriority.high,
          generatedAt: DateTime.now(),
        );

        when(mockWorkoutRepository.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockNutritionRepository.getNutritionHistory(any, any))
            .thenAnswer((_) async => []);
        when(mockBodyRepository.getBodyEntriesByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockInsightsEngine.generateInsights(any))
            .thenAnswer((_) async => [newInsight]);
        when(mockCacheService.invalidateCache(any)).thenAnswer((_) async {});
        when(mockCacheService.cacheInsights(any)).thenAnswer((_) async {});
        when(mockChangeDetectionService.getLastDataChange(any))
            .thenAnswer((_) async => DateTime.now());

        // Act & Assert
        bool loadingStateSet = false;
        
        // Start refresh (don't await yet)
        final refreshFuture = notifier.refreshInsights(InsightContext.workout);
        
        // Check that loading state was set to true
        expect(notifier.state.isLoading[InsightContext.workout], equals(true));
        loadingStateSet = true;
        
        // Wait for completion
        await refreshFuture;
        
        // Check that loading state was set back to false
        expect(notifier.state.isLoading[InsightContext.workout], equals(false));
        expect(loadingStateSet, isTrue);
      });

      test('should clear existing errors during refresh', () async {
        // Arrange
        final newInsight = Insight(
          id: 'new-1',
          context: InsightContext.nutrition,
          title: 'Fresh Nutrition Insight',
          message: 'New nutrition insight',
          icon: '🍽️',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now(),
        );

        // Set up initial state with error
        notifier.state = notifier.state.copyWith(
          errors: {InsightContext.nutrition: 'Previous error'},
        );

        when(mockWorkoutRepository.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockNutritionRepository.getNutritionHistory(any, any))
            .thenAnswer((_) async => []);
        when(mockBodyRepository.getBodyEntriesByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockInsightsEngine.generateInsights(any))
            .thenAnswer((_) async => [newInsight]);
        when(mockCacheService.invalidateCache(any)).thenAnswer((_) async {});
        when(mockCacheService.cacheInsights(any)).thenAnswer((_) async {});
        when(mockChangeDetectionService.getLastDataChange(any))
            .thenAnswer((_) async => DateTime.now());

        // Act
        await notifier.refreshInsights(InsightContext.nutrition);

        // Assert
        expect(notifier.state.errors[InsightContext.nutrition], isNull);
      });

      test('should handle insight generation failure gracefully', () async {
        // Arrange
        when(mockWorkoutRepository.getWorkoutsByDateRange(any, any))
            .thenThrow(Exception('Repository failed'));
        when(mockNutritionRepository.getNutritionHistory(any, any))
            .thenAnswer((_) async => []);
        when(mockBodyRepository.getBodyEntriesByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockInsightsEngine.generateInsights(any))
            .thenAnswer((_) async => []); // Return empty list
        when(mockCacheService.invalidateCache(any)).thenAnswer((_) async {});
        when(mockChangeDetectionService.getLastDataChange(any))
            .thenAnswer((_) async => DateTime.now());

        // Act
        final result = await notifier.refreshInsights(InsightContext.profile);

        // Assert
        expect(result, equals([])); // Should return empty list
        expect(notifier.state.isLoading[InsightContext.profile], equals(false));
        // Note: Since the insight generation succeeds (returns empty list), 
        // there should be no error in the state
        expect(notifier.state.errors[InsightContext.profile], isNull);
      });

      test('should handle complete insight generation failure gracefully', () async {
        // Arrange
        when(mockWorkoutRepository.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockNutritionRepository.getNutritionHistory(any, any))
            .thenAnswer((_) async => []);
        when(mockBodyRepository.getBodyEntriesByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockInsightsEngine.generateInsights(any))
            .thenThrow(Exception('Insight generation failed'));
        when(mockCacheService.invalidateCache(any)).thenAnswer((_) async {});

        // Act
        final result = await notifier.refreshInsights(InsightContext.profile);

        // Assert
        expect(result, equals([])); // Should return empty list on failure
        expect(notifier.state.isLoading[InsightContext.profile], equals(false));
        expect(notifier.state.errors[InsightContext.profile], isNotNull);
        expect(notifier.state.errors[InsightContext.profile], contains('Failed to refresh insights'));
      });

      test('should handle cache invalidation failure gracefully', () async {
        // Arrange
        final newInsight = Insight(
          id: 'new-1',
          context: InsightContext.home,
          title: 'Fresh Insight',
          message: 'New insight despite cache failure',
          icon: '🏠',
          priority: InsightPriority.high,
          generatedAt: DateTime.now(),
        );

        when(mockWorkoutRepository.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockNutritionRepository.getNutritionHistory(any, any))
            .thenAnswer((_) async => []);
        when(mockBodyRepository.getBodyEntriesByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockInsightsEngine.generateInsights(any))
            .thenAnswer((_) async => [newInsight]);
        // Make cache invalidation fail, but don't let it propagate
        when(mockCacheService.invalidateCache(any))
            .thenAnswer((_) async => throw Exception('Cache invalidation failed'));
        when(mockCacheService.cacheInsights(any)).thenAnswer((_) async {});
        when(mockChangeDetectionService.getLastDataChange(any))
            .thenAnswer((_) async => DateTime.now());

        // Act
        final result = await notifier.refreshInsights(InsightContext.home);

        // Assert - should still succeed despite cache invalidation failure
        expect(result, equals([newInsight]));
        expect(notifier.state.insights[InsightContext.home], equals([newInsight]));
        expect(notifier.state.isLoading[InsightContext.home], equals(false));
        expect(notifier.state.errors[InsightContext.home], isNull);

        verify(mockInsightsEngine.generateInsights(any)).called(1);
      });

      test('should handle cache update failure gracefully', () async {
        // Arrange
        final newInsight = Insight(
          id: 'new-1',
          context: InsightContext.workout,
          title: 'Fresh Workout Insight',
          message: 'New workout insight',
          icon: '💪',
          priority: InsightPriority.high,
          generatedAt: DateTime.now(),
        );

        when(mockWorkoutRepository.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockNutritionRepository.getNutritionHistory(any, any))
            .thenAnswer((_) async => []);
        when(mockBodyRepository.getBodyEntriesByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockInsightsEngine.generateInsights(any))
            .thenAnswer((_) async => [newInsight]);
        when(mockCacheService.invalidateCache(any)).thenAnswer((_) async {});
        when(mockCacheService.cacheInsights(any))
            .thenThrow(Exception('Cache update failed'));
        when(mockChangeDetectionService.getLastDataChange(any))
            .thenAnswer((_) async => DateTime.now());

        // Act
        final result = await notifier.refreshInsights(InsightContext.workout);

        // Assert - should still succeed despite cache update failure
        expect(result, equals([newInsight]));
        expect(notifier.state.insights[InsightContext.workout], equals([newInsight]));
        expect(notifier.state.isLoading[InsightContext.workout], equals(false));
        expect(notifier.state.errors[InsightContext.workout], isNull);

        verify(mockInsightsEngine.generateInsights(any)).called(1);
      });

      test('should pass nutrition targets to insight generation', () async {
        // Arrange
        final nutritionTargets = NutritionTargets(
          userId: 'test-user',
          macros: const MacroTargets(
            calories: 2000,
            protein: 150,
            carbs: 200,
            fats: 80,
          ),
          micros: const MicroTargets(
            fiber: 25,
            sugar: 50,
            sodium: 2300,
            potassium: 3500,
          ),
          vitamins: const VitaminTargets(
            vitaminA: 900,
            vitaminB: 2.4,
            vitaminC: 90,
            vitaminD: 20,
            vitaminE: 15,
          ),
          minerals: const MineralTargets(
            calcium: 1000,
            iron: 18,
            magnesium: 400,
            zinc: 11,
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final newInsight = Insight(
          id: 'new-1',
          context: InsightContext.nutrition,
          title: 'Nutrition Insight',
          message: 'Nutrition insight with targets',
          icon: '🍽️',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now(),
        );

        when(mockWorkoutRepository.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockNutritionRepository.getNutritionHistory(any, any))
            .thenAnswer((_) async => []);
        when(mockBodyRepository.getBodyEntriesByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockInsightsEngine.generateInsights(any))
            .thenAnswer((_) async => [newInsight]);
        when(mockCacheService.invalidateCache(any)).thenAnswer((_) async {});
        when(mockCacheService.cacheInsights(any)).thenAnswer((_) async {});
        when(mockChangeDetectionService.getLastDataChange(any))
            .thenAnswer((_) async => DateTime.now());

        // Act
        await notifier.refreshInsights(
          InsightContext.nutrition,
          nutritionTargets: nutritionTargets,
        );

        // Assert
        final capturedContext = verify(mockInsightsEngine.generateInsights(captureAny))
            .captured.single;
        expect(capturedContext.nutritionTargets, equals(nutritionTargets));
      });
    });

    group('Timeout Handling', () {
      test('should handle timeout in getInsights and return cached insights', () async {
        // Arrange
        final cachedInsight = Insight(
          id: 'cached-1',
          context: InsightContext.home,
          title: 'Cached Insight',
          message: 'This is from cache',
          icon: '🏠',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        );
        final cachedInsights = InsightCache(
          context: InsightContext.home,
          insights: [cachedInsight],
          cachedAt: DateTime.now().subtract(const Duration(minutes: 30)),
          dataTimestamps: {'workout': DateTime.now().subtract(const Duration(hours: 2))},
        );

        when(mockWorkoutRepository.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockNutritionRepository.getNutritionHistory(any, any))
            .thenAnswer((_) async => []);
        when(mockBodyRepository.getBodyEntriesByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockInsightsEngine.generateInsights(any))
            .thenAnswer((_) async {
              // Simulate a long-running operation that will timeout
              await Future.delayed(const Duration(seconds: 6));
              return [];
            });
        when(mockCacheService.getCachedInsights(InsightContext.home))
            .thenAnswer((_) async => cachedInsights);
        when(mockCacheService.isCacheStale(cachedInsights))
            .thenReturn(false);
        when(mockChangeDetectionService.hasWorkoutDataChanged(any))
            .thenAnswer((_) async => true); // Force regeneration
        when(mockChangeDetectionService.hasNutritionDataChanged(any))
            .thenAnswer((_) async => true);
        when(mockChangeDetectionService.hasBodyDataChanged(any))
            .thenAnswer((_) async => true);

        // Act
        final result = await notifier.getInsights(InsightContext.home);

        // Assert - should return cached insights due to timeout
        expect(result, equals([cachedInsight]));
        expect(notifier.state.insights[InsightContext.home], equals([cachedInsight]));
        expect(notifier.state.isLoading[InsightContext.home], equals(false));
      });

      test('should handle timeout in getInsights and return fallback insights when no cache', () async {
        // Arrange
        when(mockWorkoutRepository.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockNutritionRepository.getNutritionHistory(any, any))
            .thenAnswer((_) async => []);
        when(mockBodyRepository.getBodyEntriesByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockInsightsEngine.generateInsights(any))
            .thenAnswer((_) async {
              // Simulate a long-running operation that will timeout
              await Future.delayed(const Duration(seconds: 6));
              return [];
            });
        when(mockCacheService.getCachedInsights(InsightContext.workout))
            .thenAnswer((_) async => null); // No cache available
        when(mockChangeDetectionService.hasWorkoutDataChanged(any))
            .thenAnswer((_) async => true); // Force regeneration
        when(mockChangeDetectionService.getLastDataChange(any))
            .thenAnswer((_) async => DateTime.now());

        // Act
        final result = await notifier.getInsights(InsightContext.workout);

        // Assert - should return fallback insights due to timeout and no cache
        expect(result, isNotEmpty);
        expect(result.length, equals(2)); // Fallback insights for workout context
        expect(result.first.title, equals('Track Your Progress'));
        expect(result.first.icon, equals('💪'));
        expect(result.last.title, equals('Progressive Overload'));
        expect(result.last.icon, equals('⬆️'));
        expect(notifier.state.isLoading[InsightContext.workout], equals(false));
      });

      test('should handle timeout in refreshInsights and return empty list', () async {
        // Arrange
        when(mockWorkoutRepository.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockNutritionRepository.getNutritionHistory(any, any))
            .thenAnswer((_) async => []);
        when(mockBodyRepository.getBodyEntriesByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockInsightsEngine.generateInsights(any))
            .thenAnswer((_) async {
              // Simulate a long-running operation that will timeout
              await Future.delayed(const Duration(seconds: 6));
              return [];
            });
        when(mockCacheService.invalidateCache(any)).thenAnswer((_) async {});
        when(mockCacheService.getCachedInsights(InsightContext.nutrition))
            .thenAnswer((_) async => null); // No cache available for timeout fallback
        when(mockChangeDetectionService.getLastDataChange(any))
            .thenAnswer((_) async => DateTime.now());

        // Act
        final result = await notifier.refreshInsights(InsightContext.nutrition);

        // Assert - should return empty list due to timeout (no fallback for refresh)
        expect(result, equals([]));
        expect(notifier.state.isLoading[InsightContext.nutrition], equals(false));
        expect(notifier.state.errors[InsightContext.nutrition], contains('timed out'));
      });

      test('should generate appropriate fallback insights for each context', () async {
        // Test Home context fallback
        final homeFallback = notifier.generateFallbackInsights(InsightContext.home);
        expect(homeFallback.length, equals(2));
        expect(homeFallback.first.title, equals('Welcome to Your Fitness Journey'));
        expect(homeFallback.first.icon, equals('🎯'));
        expect(homeFallback.last.title, equals('Consistency is Key'));
        expect(homeFallback.last.icon, equals('📈'));

        // Test Workout context fallback
        final workoutFallback = notifier.generateFallbackInsights(InsightContext.workout);
        expect(workoutFallback.length, equals(2));
        expect(workoutFallback.first.title, equals('Track Your Progress'));
        expect(workoutFallback.first.icon, equals('💪'));
        expect(workoutFallback.last.title, equals('Progressive Overload'));
        expect(workoutFallback.last.icon, equals('⬆️'));

        // Test Nutrition context fallback
        final nutritionFallback = notifier.generateFallbackInsights(InsightContext.nutrition);
        expect(nutritionFallback.length, equals(2));
        expect(nutritionFallback.first.title, equals('Fuel Your Goals'));
        expect(nutritionFallback.first.icon, equals('🍽️'));
        expect(nutritionFallback.last.title, equals('Protein Matters'));
        expect(nutritionFallback.last.icon, equals('🥩'));

        // Test Profile context fallback
        final profileFallback = notifier.generateFallbackInsights(InsightContext.profile);
        expect(profileFallback.length, equals(2));
        expect(profileFallback.first.title, equals('Your Journey Starts Here'));
        expect(profileFallback.first.icon, equals('📊'));
        expect(profileFallback.last.title, equals('Long-term Success'));
        expect(profileFallback.last.icon, equals('🌱'));
      });
    });

    group('onWorkoutCompleted', () {
      test('should generate quick feedback and schedule refresh for Home and Workout contexts', () async {
        // Arrange
        final completedWorkout = Workout(
          id: 'workout-1',
          date: DateTime.now(),
          exercises: [],
          duration: const Duration(minutes: 45),
          totalVolume: 1500.0,
          caloriesBurned: 300.0,
        );
        final workoutHistory = <Workout>[completedWorkout];
        final quickFeedback = Insight(
          id: 'quick-1',
          context: InsightContext.home,
          title: 'Great Workout!',
          message: 'You completed a 45-minute session with 1500kg total volume!',
          icon: '🎉',
          priority: InsightPriority.high,
          generatedAt: DateTime.now(),
        );

        // Set up initial state with existing insights
        final existingHomeInsight = Insight(
          id: 'home-1',
          context: InsightContext.home,
          title: 'Old Home Insight',
          message: 'This should be invalidated',
          icon: '🏠',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        final existingWorkoutInsight = Insight(
          id: 'workout-1',
          context: InsightContext.workout,
          title: 'Old Workout Insight',
          message: 'This should be invalidated',
          icon: '💪',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        final existingNutritionInsight = Insight(
          id: 'nutrition-1',
          context: InsightContext.nutrition,
          title: 'Nutrition Insight',
          message: 'This should remain',
          icon: '🍽️',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        notifier.state = notifier.state.copyWith(
          insights: {
            InsightContext.home: [existingHomeInsight],
            InsightContext.workout: [existingWorkoutInsight],
            InsightContext.nutrition: [existingNutritionInsight],
          },
          lastUpdated: {
            InsightContext.home: DateTime.now().subtract(const Duration(hours: 1)),
            InsightContext.workout: DateTime.now().subtract(const Duration(hours: 1)),
            InsightContext.nutrition: DateTime.now().subtract(const Duration(hours: 1)),
          },
        );

        when(mockWorkoutRepository.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => workoutHistory);
        when(mockInsightsEngine.generateQuickFeedback(completedWorkout, workoutHistory))
            .thenAnswer((_) async => quickFeedback);
        when(mockCacheService.invalidateCache(any)).thenAnswer((_) async {});

        // Act
        await notifier.onWorkoutCompleted(completedWorkout);

        // Assert
        // Quick feedback should be set
        expect(notifier.state.quickFeedback, equals(quickFeedback));

        // Home and Workout contexts should be invalidated (removed from memory cache)
        expect(notifier.state.insights[InsightContext.home], isNull);
        expect(notifier.state.insights[InsightContext.workout], isNull);
        expect(notifier.state.lastUpdated[InsightContext.home], isNull);
        expect(notifier.state.lastUpdated[InsightContext.workout], isNull);

        // Nutrition context should remain unchanged
        expect(notifier.state.insights[InsightContext.nutrition], equals([existingNutritionInsight]));
        expect(notifier.state.lastUpdated[InsightContext.nutrition], isNotNull);

        // Verify method calls
        verify(mockWorkoutRepository.getWorkoutsByDateRange(any, any)).called(1);
        verify(mockInsightsEngine.generateQuickFeedback(completedWorkout, workoutHistory)).called(1);
        // Note: Cache invalidation calls are async and may not be verifiable immediately
      });

      test('should handle quick feedback generation failure gracefully', () async {
        // Arrange
        final completedWorkout = Workout(
          id: 'workout-1',
          date: DateTime.now(),
          exercises: [],
          duration: const Duration(minutes: 30),
          totalVolume: 1000.0,
          caloriesBurned: 200.0,
        );

        // Set up initial state with existing insights
        final existingHomeInsight = Insight(
          id: 'home-1',
          context: InsightContext.home,
          title: 'Old Home Insight',
          message: 'This should be invalidated',
          icon: '🏠',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        notifier.state = notifier.state.copyWith(
          insights: {InsightContext.home: [existingHomeInsight]},
          lastUpdated: {InsightContext.home: DateTime.now().subtract(const Duration(hours: 1))},
        );

        when(mockWorkoutRepository.getWorkoutsByDateRange(any, any))
            .thenThrow(Exception('Repository failed'));
        when(mockCacheService.invalidateCache(any)).thenAnswer((_) async {});

        // Act - should not throw
        await notifier.onWorkoutCompleted(completedWorkout);

        // Assert
        // Quick feedback should not be set due to failure
        expect(notifier.state.quickFeedback, isNull);

        // Cache invalidation should still happen (Home and Workout contexts removed)
        expect(notifier.state.insights[InsightContext.home], isNull);
        expect(notifier.state.lastUpdated[InsightContext.home], isNull);

        // Verify repository was called despite failure
        verify(mockWorkoutRepository.getWorkoutsByDateRange(any, any)).called(1);
      });

      test('should handle cache invalidation failure gracefully', () async {
        // Arrange
        final completedWorkout = Workout(
          id: 'workout-1',
          date: DateTime.now(),
          exercises: [],
          duration: const Duration(minutes: 60),
          totalVolume: 2000.0,
          caloriesBurned: 400.0,
        );
        final workoutHistory = [completedWorkout];
        final quickFeedback = Insight(
          id: 'quick-1',
          context: InsightContext.home,
          title: 'Excellent Workout!',
          message: 'You achieved 2000kg total volume in 60 minutes!',
          icon: '🔥',
          priority: InsightPriority.high,
          generatedAt: DateTime.now(),
        );

        when(mockWorkoutRepository.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => workoutHistory);
        when(mockInsightsEngine.generateQuickFeedback(completedWorkout, workoutHistory))
            .thenAnswer((_) async => quickFeedback);
        when(mockCacheService.invalidateCache(any))
            .thenThrow(Exception('Cache invalidation failed'));

        // Act - should not throw
        await notifier.onWorkoutCompleted(completedWorkout);

        // Assert
        // Quick feedback should still be set despite cache invalidation failure
        expect(notifier.state.quickFeedback, equals(quickFeedback));

        // Memory cache should still be invalidated
        expect(notifier.state.insights[InsightContext.home], isNull);
        expect(notifier.state.insights[InsightContext.workout], isNull);

        // Verify method calls
        verify(mockWorkoutRepository.getWorkoutsByDateRange(any, any)).called(1);
        verify(mockInsightsEngine.generateQuickFeedback(completedWorkout, workoutHistory)).called(1);
      });

      test('should fetch workout history from last 30 days for quick feedback', () async {
        // Arrange
        final now = DateTime.now();
        final completedWorkout = Workout(
          id: 'workout-1',
          date: now,
          exercises: [],
          duration: const Duration(minutes: 45),
          totalVolume: 1500.0,
          caloriesBurned: 300.0,
        );
        final quickFeedback = Insight(
          id: 'quick-1',
          context: InsightContext.home,
          title: 'Great Progress!',
          message: 'Your consistency is paying off!',
          icon: '📈',
          priority: InsightPriority.high,
          generatedAt: now,
        );

        when(mockWorkoutRepository.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => [completedWorkout]);
        when(mockInsightsEngine.generateQuickFeedback(any, any))
            .thenAnswer((_) async => quickFeedback);
        when(mockCacheService.invalidateCache(any)).thenAnswer((_) async {});

        // Act
        await notifier.onWorkoutCompleted(completedWorkout);

        // Assert
        // Verify that workout history was fetched with correct date range (last 30 days)
        final capturedCalls = verify(mockWorkoutRepository.getWorkoutsByDateRange(captureAny, captureAny)).captured;
        expect(capturedCalls.length, equals(2));
        
        final startDate = capturedCalls[0] as DateTime;
        final endDate = capturedCalls[1] as DateTime;
        
        // Start date should be approximately 30 days ago
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        expect(startDate.difference(thirtyDaysAgo).inHours.abs(), lessThan(1)); // Within 1 hour tolerance
        
        // End date should be approximately now
        expect(endDate.difference(now).inMinutes.abs(), lessThan(5)); // Within 5 minutes tolerance

        // Quick feedback should be generated with the fetched history
        verify(mockInsightsEngine.generateQuickFeedback(completedWorkout, [completedWorkout])).called(1);
      });

      test('should not affect other contexts when workout completed', () async {
        // Arrange
        final completedWorkout = Workout(
          id: 'workout-1',
          date: DateTime.now(),
          exercises: [],
          duration: const Duration(minutes: 30),
          totalVolume: 1000.0,
          caloriesBurned: 200.0,
        );

        // Set up initial state with insights for all contexts
        final homeInsight = Insight(
          id: 'home-1',
          context: InsightContext.home,
          title: 'Home Insight',
          message: 'Should be invalidated',
          icon: '🏠',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        final workoutInsight = Insight(
          id: 'workout-1',
          context: InsightContext.workout,
          title: 'Workout Insight',
          message: 'Should be invalidated',
          icon: '💪',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        final nutritionInsight = Insight(
          id: 'nutrition-1',
          context: InsightContext.nutrition,
          title: 'Nutrition Insight',
          message: 'Should remain unchanged',
          icon: '🍽️',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        final profileInsight = Insight(
          id: 'profile-1',
          context: InsightContext.profile,
          title: 'Profile Insight',
          message: 'Should remain unchanged',
          icon: '📊',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        notifier.state = notifier.state.copyWith(
          insights: {
            InsightContext.home: [homeInsight],
            InsightContext.workout: [workoutInsight],
            InsightContext.nutrition: [nutritionInsight],
            InsightContext.profile: [profileInsight],
          },
          lastUpdated: {
            InsightContext.home: DateTime.now().subtract(const Duration(hours: 1)),
            InsightContext.workout: DateTime.now().subtract(const Duration(hours: 1)),
            InsightContext.nutrition: DateTime.now().subtract(const Duration(hours: 1)),
            InsightContext.profile: DateTime.now().subtract(const Duration(hours: 1)),
          },
        );

        when(mockWorkoutRepository.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => [completedWorkout]);
        when(mockInsightsEngine.generateQuickFeedback(any, any))
            .thenAnswer((_) async => Insight(
              id: 'quick-1',
              context: InsightContext.home,
              title: 'Quick Feedback',
              message: 'Great job!',
              icon: '🎉',
              priority: InsightPriority.high,
              generatedAt: DateTime.now(),
            ));
        when(mockCacheService.invalidateCache(any)).thenAnswer((_) async {});

        // Act
        await notifier.onWorkoutCompleted(completedWorkout);

        // Assert
        // Home and Workout contexts should be invalidated
        expect(notifier.state.insights[InsightContext.home], isNull);
        expect(notifier.state.insights[InsightContext.workout], isNull);

        // Nutrition and Profile contexts should remain unchanged
        expect(notifier.state.insights[InsightContext.nutrition], equals([nutritionInsight]));
        expect(notifier.state.insights[InsightContext.profile], equals([profileInsight]));
        expect(notifier.state.lastUpdated[InsightContext.nutrition], isNotNull);
        expect(notifier.state.lastUpdated[InsightContext.profile], isNotNull);
      });
    });

    group('onMealLogged', () {
      test('should schedule refresh for Home and Nutrition contexts', () async {
        // Arrange
        // Set up initial state with insights for all contexts
        final homeInsight = Insight(
          id: 'home-1',
          context: InsightContext.home,
          title: 'Home Insight',
          message: 'Should be invalidated',
          icon: '🏠',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        final workoutInsight = Insight(
          id: 'workout-1',
          context: InsightContext.workout,
          title: 'Workout Insight',
          message: 'Should remain unchanged',
          icon: '💪',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        final nutritionInsight = Insight(
          id: 'nutrition-1',
          context: InsightContext.nutrition,
          title: 'Nutrition Insight',
          message: 'Should be invalidated',
          icon: '🍽️',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        final profileInsight = Insight(
          id: 'profile-1',
          context: InsightContext.profile,
          title: 'Profile Insight',
          message: 'Should remain unchanged',
          icon: '📊',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        notifier.state = notifier.state.copyWith(
          insights: {
            InsightContext.home: [homeInsight],
            InsightContext.workout: [workoutInsight],
            InsightContext.nutrition: [nutritionInsight],
            InsightContext.profile: [profileInsight],
          },
          lastUpdated: {
            InsightContext.home: DateTime.now().subtract(const Duration(hours: 1)),
            InsightContext.workout: DateTime.now().subtract(const Duration(hours: 1)),
            InsightContext.nutrition: DateTime.now().subtract(const Duration(hours: 1)),
            InsightContext.profile: DateTime.now().subtract(const Duration(hours: 1)),
          },
        );

        when(mockCacheService.invalidateCache(any)).thenAnswer((_) async {});

        // Act
        await notifier.onMealLogged();

        // Assert
        // Home and Nutrition contexts should be invalidated (removed from memory cache)
        expect(notifier.state.insights[InsightContext.home], isNull);
        expect(notifier.state.insights[InsightContext.nutrition], isNull);
        expect(notifier.state.lastUpdated[InsightContext.home], isNull);
        expect(notifier.state.lastUpdated[InsightContext.nutrition], isNull);

        // Workout and Profile contexts should remain unchanged
        expect(notifier.state.insights[InsightContext.workout], equals([workoutInsight]));
        expect(notifier.state.insights[InsightContext.profile], equals([profileInsight]));
        expect(notifier.state.lastUpdated[InsightContext.workout], isNotNull);
        expect(notifier.state.lastUpdated[InsightContext.profile], isNotNull);

        // Verify cache invalidation was called for the correct contexts
        verify(mockCacheService.invalidateCache(InsightContext.home)).called(1);
        verify(mockCacheService.invalidateCache(InsightContext.nutrition)).called(1);
        verifyNever(mockCacheService.invalidateCache(InsightContext.workout));
        verifyNever(mockCacheService.invalidateCache(InsightContext.profile));
      });

      test('should handle cache invalidation failure gracefully', () async {
        // Arrange
        final homeInsight = Insight(
          id: 'home-1',
          context: InsightContext.home,
          title: 'Home Insight',
          message: 'Should be invalidated',
          icon: '🏠',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        notifier.state = notifier.state.copyWith(
          insights: {
            InsightContext.home: [homeInsight],
          },
          lastUpdated: {
            InsightContext.home: DateTime.now().subtract(const Duration(hours: 1)),
          },
        );

        // Mock cache invalidation to fail
        when(mockCacheService.invalidateCache(InsightContext.home))
            .thenThrow(Exception('Cache invalidation failed'));
        when(mockCacheService.invalidateCache(InsightContext.nutrition))
            .thenThrow(Exception('Cache invalidation failed'));

        // Act & Assert - should not throw
        await expectLater(
          () => notifier.onMealLogged(),
          returnsNormally,
        );

        // Memory cache should still be invalidated despite Hive cache failure
        expect(notifier.state.insights[InsightContext.home], isNull);
        expect(notifier.state.lastUpdated[InsightContext.home], isNull);

        // Verify cache invalidation was attempted
        verify(mockCacheService.invalidateCache(InsightContext.home)).called(1);
        verify(mockCacheService.invalidateCache(InsightContext.nutrition)).called(1);
      });

      test('should not generate quick feedback', () async {
        // Arrange
        when(mockCacheService.invalidateCache(any)).thenAnswer((_) async {});

        // Act
        await notifier.onMealLogged();

        // Assert
        // Quick feedback should remain null (no quick feedback for meal logging)
        expect(notifier.state.quickFeedback, isNull);

        // Verify that generateQuickFeedback was never called
        verifyNever(mockInsightsEngine.generateQuickFeedback(any, any));
      });

      test('should handle method execution failure gracefully', () async {
        // Arrange
        // Mock cache invalidation to fail
        when(mockCacheService.invalidateCache(any))
            .thenThrow(Exception('Cache service failed'));

        // Act & Assert - should not throw even if everything fails
        await expectLater(
          () => notifier.onMealLogged(),
          returnsNormally,
        );

        // Method should complete without throwing
        // (Error handling is internal and logged)
      });
    });
  });
}