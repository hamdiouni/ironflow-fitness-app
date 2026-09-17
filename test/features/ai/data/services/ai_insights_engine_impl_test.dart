import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:progression_tracker/features/ai/data/services/ai_insights_engine_impl.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight_generation_context.dart';
import 'package:progression_tracker/features/ai/domain/services/ai_insights_engine.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/nutrition_targets.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_type.dart';
import 'package:progression_tracker/features/workout/domain/entities/set_entry.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';

import 'ai_insights_engine_impl_test.mocks.dart';

/// Unit tests for AIInsightsEngineImpl
///
/// **Task 3.2: Implement workout analysis methods**
/// **Validates: Requirements 1.6, 1.7, 1.8, 7.2, 7.3, 7.4, 7.5**
///
/// This test suite verifies:
/// - Data fetching from workout, nutrition, and body repositories
/// - Context-specific data fetching (30 days for workouts/body, 7 days for nutrition)
/// - Parallel data fetching for performance
/// - Context-specific insight generation routing
/// - Workout analysis methods (volume calculation, progressive overload, PR detection)
@GenerateMocks([
  WorkoutRepository,
  NutritionRepository,
  BodyRepository,
])
void main() {
  late AIInsightsEngineImpl engine;
  late MockWorkoutRepository mockWorkoutRepo;
  late MockNutritionRepository mockNutritionRepo;
  late MockBodyRepository mockBodyRepo;

  setUp(() {
    mockWorkoutRepo = MockWorkoutRepository();
    mockNutritionRepo = MockNutritionRepository();
    mockBodyRepo = MockBodyRepository();

    engine = AIInsightsEngineImpl(
      workoutRepository: mockWorkoutRepo,
      nutritionRepository: mockNutritionRepo,
      bodyRepository: mockBodyRepo,
    );
  });

  group('AIInsightsEngineImpl - Data Fetching', () {
    group('Home Context', () {
      test('should fetch all data types for home context', () async {
        // ARRANGE
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        final sevenDaysAgo = now.subtract(const Duration(days: 7));

        final mockWorkouts = <Workout>[];
        final mockNutrition = <DailyNutritionSummary>[];
        final mockBodyEntries = <BodyEntry>[];

        when(mockWorkoutRepo.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => mockWorkouts);
        when(mockNutritionRepo.getNutritionHistory(any, any))
            .thenAnswer((_) async => mockNutrition);
        when(mockBodyRepo.getBodyEntriesByDateRange(any, any))
            .thenAnswer((_) async => mockBodyEntries);

        final context = InsightGenerationContext(
          context: InsightContext.home,
          recentWorkouts: [],
          nutritionHistory: [],
          bodyEntries: [],
          generatedAt: now,
        );

        // ACT
        await engine.generateInsights(context);

        // ASSERT - Verify all repositories were called
        verify(mockWorkoutRepo.getWorkoutsByDateRange(
          argThat(isA<DateTime>().having(
            (d) => d.difference(thirtyDaysAgo).inMinutes.abs(),
            'within 1 minute of 30 days ago',
            lessThan(1),
          )),
          argThat(isA<DateTime>().having(
            (d) => d.difference(now).inMinutes.abs(),
            'within 1 minute of now',
            lessThan(1),
          )),
        )).called(1);

        verify(mockNutritionRepo.getNutritionHistory(
          argThat(isA<DateTime>().having(
            (d) => d.difference(sevenDaysAgo).inMinutes.abs(),
            'within 1 minute of 7 days ago',
            lessThan(1),
          )),
          argThat(isA<DateTime>().having(
            (d) => d.difference(now).inMinutes.abs(),
            'within 1 minute of now',
            lessThan(1),
          )),
        )).called(1);

        verify(mockBodyRepo.getBodyEntriesByDateRange(
          argThat(isA<DateTime>().having(
            (d) => d.difference(thirtyDaysAgo).inMinutes.abs(),
            'within 1 minute of 30 days ago',
            lessThan(1),
          )),
          argThat(isA<DateTime>().having(
            (d) => d.difference(now).inMinutes.abs(),
            'within 1 minute of now',
            lessThan(1),
          )),
        )).called(1);
      });
    });

    group('Workout Context', () {
      test('should fetch only workout data for workout context', () async {
        // ARRANGE
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));

        final mockWorkouts = <Workout>[];

        when(mockWorkoutRepo.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => mockWorkouts);

        final context = InsightGenerationContext(
          context: InsightContext.workout,
          recentWorkouts: [],
          nutritionHistory: [],
          bodyEntries: [],
          generatedAt: now,
        );

        // ACT
        await engine.generateInsights(context);

        // ASSERT - Verify only workout repository was called
        verify(mockWorkoutRepo.getWorkoutsByDateRange(
          argThat(isA<DateTime>().having(
            (d) => d.difference(thirtyDaysAgo).inMinutes.abs(),
            'within 1 minute of 30 days ago',
            lessThan(1),
          )),
          argThat(isA<DateTime>().having(
            (d) => d.difference(now).inMinutes.abs(),
            'within 1 minute of now',
            lessThan(1),
          )),
        )).called(1);

        // Verify nutrition and body repositories were NOT called
        verifyNever(mockNutritionRepo.getNutritionHistory(any, any));
        verifyNever(mockBodyRepo.getBodyEntriesByDateRange(any, any));
      });
    });

    group('Nutrition Context', () {
      test('should fetch only nutrition data for nutrition context', () async {
        // ARRANGE
        final now = DateTime.now();
        final sevenDaysAgo = now.subtract(const Duration(days: 7));

        final mockNutrition = <DailyNutritionSummary>[];

        when(mockNutritionRepo.getNutritionHistory(any, any))
            .thenAnswer((_) async => mockNutrition);

        final context = InsightGenerationContext(
          context: InsightContext.nutrition,
          recentWorkouts: [],
          nutritionHistory: [],
          bodyEntries: [],
          generatedAt: now,
        );

        // ACT
        await engine.generateInsights(context);

        // ASSERT - Verify only nutrition repository was called
        verify(mockNutritionRepo.getNutritionHistory(
          argThat(isA<DateTime>().having(
            (d) => d.difference(sevenDaysAgo).inMinutes.abs(),
            'within 1 minute of 7 days ago',
            lessThan(1),
          )),
          argThat(isA<DateTime>().having(
            (d) => d.difference(now).inMinutes.abs(),
            'within 1 minute of now',
            lessThan(1),
          )),
        )).called(1);

        // Verify workout and body repositories were NOT called
        verifyNever(mockWorkoutRepo.getWorkoutsByDateRange(any, any));
        verifyNever(mockBodyRepo.getBodyEntriesByDateRange(any, any));
      });
    });

    group('Profile Context', () {
      test('should fetch workout and body data for profile context', () async {
        // ARRANGE
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));

        final mockWorkouts = <Workout>[];
        final mockBodyEntries = <BodyEntry>[];

        when(mockWorkoutRepo.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => mockWorkouts);
        when(mockBodyRepo.getBodyEntriesByDateRange(any, any))
            .thenAnswer((_) async => mockBodyEntries);

        final context = InsightGenerationContext(
          context: InsightContext.profile,
          recentWorkouts: [],
          nutritionHistory: [],
          bodyEntries: [],
          generatedAt: now,
        );

        // ACT
        await engine.generateInsights(context);

        // ASSERT - Verify workout and body repositories were called
        verify(mockWorkoutRepo.getWorkoutsByDateRange(
          argThat(isA<DateTime>().having(
            (d) => d.difference(thirtyDaysAgo).inMinutes.abs(),
            'within 1 minute of 30 days ago',
            lessThan(1),
          )),
          argThat(isA<DateTime>().having(
            (d) => d.difference(now).inMinutes.abs(),
            'within 1 minute of now',
            lessThan(1),
          )),
        )).called(1);

        verify(mockBodyRepo.getBodyEntriesByDateRange(
          argThat(isA<DateTime>().having(
            (d) => d.difference(thirtyDaysAgo).inMinutes.abs(),
            'within 1 minute of 30 days ago',
            lessThan(1),
          )),
          argThat(isA<DateTime>().having(
            (d) => d.difference(now).inMinutes.abs(),
            'within 1 minute of now',
            lessThan(1),
          )),
        )).called(1);

        // Verify nutrition repository was NOT called
        verifyNever(mockNutritionRepo.getNutritionHistory(any, any));
      });
    });

    group('Date Range Requirements', () {
      test('should use 30-day range for workout data', () async {
        // ARRANGE
        when(mockWorkoutRepo.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => []);

        final context = InsightGenerationContext(
          context: InsightContext.workout,
          recentWorkouts: [],
          nutritionHistory: [],
          bodyEntries: [],
          generatedAt: DateTime.now(),
        );

        // ACT
        await engine.generateInsights(context);

        // ASSERT
        final captured = verify(
          mockWorkoutRepo.getWorkoutsByDateRange(
            captureAny,
            captureAny,
          ),
        ).captured;

        final startDate = captured[0] as DateTime;
        final endDate = captured[1] as DateTime;

        // Verify the date range is approximately 30 days
        final daysDifference = endDate.difference(startDate).inDays;
        expect(
          daysDifference,
          greaterThanOrEqualTo(29),
          reason: 'Date range should be at least 29 days',
        );
        expect(
          daysDifference,
          lessThanOrEqualTo(31),
          reason: 'Date range should be at most 31 days',
        );
      });

      test('should use 7-day range for nutrition data', () async {
        // ARRANGE
        when(mockNutritionRepo.getNutritionHistory(any, any))
            .thenAnswer((_) async => []);

        final context = InsightGenerationContext(
          context: InsightContext.nutrition,
          recentWorkouts: [],
          nutritionHistory: [],
          bodyEntries: [],
          generatedAt: DateTime.now(),
        );

        // ACT
        await engine.generateInsights(context);

        // ASSERT
        final captured = verify(
          mockNutritionRepo.getNutritionHistory(
            captureAny,
            captureAny,
          ),
        ).captured;

        final startDate = captured[0] as DateTime;
        final endDate = captured[1] as DateTime;

        // Verify the date range is approximately 7 days
        final daysDifference = endDate.difference(startDate).inDays;
        expect(
          daysDifference,
          greaterThanOrEqualTo(6),
          reason: 'Date range should be at least 6 days',
        );
        expect(
          daysDifference,
          lessThanOrEqualTo(8),
          reason: 'Date range should be at most 8 days',
        );
      });

      test('should use 30-day range for body data', () async {
        // ARRANGE
        when(mockWorkoutRepo.getWorkoutsByDateRange(any, any))
            .thenAnswer((_) async => []);
        when(mockBodyRepo.getBodyEntriesByDateRange(any, any))
            .thenAnswer((_) async => []);

        final context = InsightGenerationContext(
          context: InsightContext.profile,
          recentWorkouts: [],
          nutritionHistory: [],
          bodyEntries: [],
          generatedAt: DateTime.now(),
        );

        // ACT
        await engine.generateInsights(context);

        // ASSERT
        final captured = verify(
          mockBodyRepo.getBodyEntriesByDateRange(
            captureAny,
            captureAny,
          ),
        ).captured;

        final startDate = captured[0] as DateTime;
        final endDate = captured[1] as DateTime;

        // Verify the date range is approximately 30 days
        final daysDifference = endDate.difference(startDate).inDays;
        expect(
          daysDifference,
          greaterThanOrEqualTo(29),
          reason: 'Date range should be at least 29 days',
        );
        expect(
          daysDifference,
          lessThanOrEqualTo(31),
          reason: 'Date range should be at most 31 days',
        );
      });
    });

    group('Error Handling', () {
      test('should handle repository errors gracefully', () async {
        // ARRANGE
        when(mockWorkoutRepo.getWorkoutsByDateRange(any, any))
            .thenThrow(Exception('Database error'));
        when(mockNutritionRepo.getNutritionHistory(any, any))
            .thenAnswer((_) async => []);
        when(mockBodyRepo.getBodyEntriesByDateRange(any, any))
            .thenAnswer((_) async => []);

        final context = InsightGenerationContext(
          context: InsightContext.home,
          recentWorkouts: [],
          nutritionHistory: [],
          bodyEntries: [],
          generatedAt: DateTime.now(),
        );

        // ACT & ASSERT
        expect(
          () => engine.generateInsights(context),
          throwsException,
        );
      });
    });
  });

  group('AIInsightsEngineImpl - Workout Analysis Methods', () {
    test('calculateVolume should calculate total volume correctly', () {
      // ARRANGE
      final workout = Workout(
        id: 'workout-1',
        date: DateTime.now(),
        exercises: [
          Exercise(
            id: 'exercise-1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [
              SetEntry(
                id: 'set-1',
                reps: 10,
                weight: 100.0,
                timestamp: DateTime.now(),
              ),
              SetEntry(
                id: 'set-2',
                reps: 8,
                weight: 105.0,
                timestamp: DateTime.now(),
              ),
            ],
          ),
          Exercise(
            id: 'exercise-2',
            name: 'Squat',
            type: ExerciseType.strength,
            sets: [
              SetEntry(
                id: 'set-3',
                reps: 12,
                weight: 80.0,
                timestamp: DateTime.now(),
              ),
            ],
          ),
        ],
        duration: const Duration(minutes: 60),
        totalVolume: 0,
      );

      // ACT
      final volume = engine.calculateVolume(workout);

      // ASSERT
      // (10 * 100) + (8 * 105) + (12 * 80) = 1000 + 840 + 960 = 2800
      expect(volume, equals(2800.0));
    });

    test('calculateVolume should return 0 for workout with no exercises', () {
      // ARRANGE
      final workout = Workout(
        id: 'workout-1',
        date: DateTime.now(),
        exercises: [],
        duration: const Duration(minutes: 60),
        totalVolume: 0,
      );

      // ACT
      final volume = engine.calculateVolume(workout);

      // ASSERT
      expect(volume, equals(0.0));
    });

    test('calculateVolume should handle exercises with no sets', () {
      // ARRANGE
      final workout = Workout(
        id: 'workout-1',
        date: DateTime.now(),
        exercises: [
          Exercise(
            id: 'exercise-1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [],
          ),
        ],
        duration: const Duration(minutes: 60),
        totalVolume: 0,
      );

      // ACT
      final volume = engine.calculateVolume(workout);

      // ASSERT
      expect(volume, equals(0.0));
    });

    test('calculateVolume should handle mixed exercise types', () {
      // ARRANGE
      final workout = Workout(
        id: 'workout-1',
        date: DateTime.now(),
        exercises: [
          Exercise(
            id: 'exercise-1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [
              SetEntry(
                id: 'set-1',
                reps: 10,
                weight: 100.0,
                timestamp: DateTime.now(),
              ),
            ],
          ),
          Exercise(
            id: 'exercise-2',
            name: 'Running',
            type: ExerciseType.cardio,
            sets: [
              SetEntry(
                id: 'set-2',
                reps: 1,
                weight: 0.0, // Cardio with no weight
                timestamp: DateTime.now(),
              ),
            ],
          ),
        ],
        duration: const Duration(minutes: 60),
        totalVolume: 0,
      );

      // ACT
      final volume = engine.calculateVolume(workout);

      // ASSERT
      expect(volume, equals(1000.0)); // Only strength exercise counts
    });

    test('detectProgressiveOverload should return true when volume increases', () {
      // ARRANGE
      final workouts = [
        // First half - lower volume
        Workout(
          id: 'workout-1',
          date: DateTime(2024, 1, 1),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 80.0,
                  timestamp: DateTime(2024, 1, 1),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 800,
        ),
        Workout(
          id: 'workout-2',
          date: DateTime(2024, 1, 3),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 85.0,
                  timestamp: DateTime(2024, 1, 3),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 850,
        ),
        // Second half - higher volume
        Workout(
          id: 'workout-3',
          date: DateTime(2024, 1, 5),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 100.0,
                  timestamp: DateTime(2024, 1, 5),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 1000,
        ),
        Workout(
          id: 'workout-4',
          date: DateTime(2024, 1, 7),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 105.0,
                  timestamp: DateTime(2024, 1, 7),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 1050,
        ),
      ];

      // ACT
      final hasProgressiveOverload = engine.detectProgressiveOverload(workouts);

      // ASSERT
      expect(hasProgressiveOverload, isTrue);
    });

    test('detectProgressiveOverload should return false when volume decreases', () {
      // ARRANGE
      final workouts = [
        // First half - higher volume
        Workout(
          id: 'workout-1',
          date: DateTime(2024, 1, 1),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 100.0,
                  timestamp: DateTime(2024, 1, 1),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 1000,
        ),
        Workout(
          id: 'workout-2',
          date: DateTime(2024, 1, 3),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 105.0,
                  timestamp: DateTime(2024, 1, 3),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 1050,
        ),
        // Second half - lower volume (deload)
        Workout(
          id: 'workout-3',
          date: DateTime(2024, 1, 5),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 80.0,
                  timestamp: DateTime(2024, 1, 5),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 800,
        ),
        Workout(
          id: 'workout-4',
          date: DateTime(2024, 1, 7),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 85.0,
                  timestamp: DateTime(2024, 1, 7),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 850,
        ),
      ];

      // ACT
      final hasProgressiveOverload = engine.detectProgressiveOverload(workouts);

      // ASSERT
      expect(hasProgressiveOverload, isFalse);
    });

    test('detectProgressiveOverload should return false with insufficient data', () {
      // ARRANGE
      final workouts = [
        Workout(
          id: 'workout-1',
          date: DateTime.now(),
          exercises: [],
          duration: const Duration(minutes: 60),
          totalVolume: 0,
        ),
      ];

      // ACT
      final hasProgressiveOverload = engine.detectProgressiveOverload(workouts);

      // ASSERT
      expect(hasProgressiveOverload, isFalse);
    });

    test('detectPR should return true when new PR achieved', () {
      // ARRANGE
      final workouts = [
        // Most recent workout with PR
        Workout(
          id: 'workout-1',
          date: DateTime(2024, 1, 7),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 120.0, // New PR
                  timestamp: DateTime(2024, 1, 7),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 1200,
        ),
        // Historical workouts
        Workout(
          id: 'workout-2',
          date: DateTime(2024, 1, 5),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 100.0, // Previous max
                  timestamp: DateTime(2024, 1, 5),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 1000,
        ),
      ];

      // ACT
      final hasPR = engine.detectPR(workouts);

      // ASSERT
      expect(hasPR, isTrue);
    });

    test('detectPR should return false when no PR achieved', () {
      // ARRANGE
      final workouts = [
        // Most recent workout with same weight
        Workout(
          id: 'workout-1',
          date: DateTime(2024, 1, 7),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 100.0, // Same as before
                  timestamp: DateTime(2024, 1, 7),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 1000,
        ),
        // Historical workouts
        Workout(
          id: 'workout-2',
          date: DateTime(2024, 1, 5),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 100.0, // Previous max
                  timestamp: DateTime(2024, 1, 5),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 1000,
        ),
      ];

      // ACT
      final hasPR = engine.detectPR(workouts);

      // ASSERT
      expect(hasPR, isFalse);
    });

    test('detectPR should return false for empty workout list', () {
      // ACT
      final hasPR = engine.detectPR([]);

      // ASSERT
      expect(hasPR, isFalse);
    });

    test('getPRDetails should return correct PR information', () {
      // ARRANGE
      final workouts = [
        // Most recent workout with multiple PRs
        Workout(
          id: 'workout-1',
          date: DateTime(2024, 1, 7),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 120.0, // New PR
                  timestamp: DateTime(2024, 1, 7),
                ),
              ],
            ),
            Exercise(
              id: 'exercise-2',
              name: 'Squat',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-2',
                  reps: 10,
                  weight: 150.0, // New PR
                  timestamp: DateTime(2024, 1, 7),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 2700,
        ),
        // Historical workouts
        Workout(
          id: 'workout-2',
          date: DateTime(2024, 1, 5),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 100.0, // Previous max
                  timestamp: DateTime(2024, 1, 5),
                ),
              ],
            ),
            Exercise(
              id: 'exercise-2',
              name: 'Squat',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-2',
                  reps: 10,
                  weight: 140.0, // Previous max
                  timestamp: DateTime(2024, 1, 5),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 2400,
        ),
      ];

      // ACT
      final prDetails = engine.getPRDetails(workouts);

      // ASSERT
      expect(prDetails.length, equals(2));
      expect(prDetails['Bench Press'], equals(120.0));
      expect(prDetails['Squat'], equals(150.0));
    });
  });

  group('AIInsightsEngineImpl - Nutrition Analysis Methods', () {
    test('calculateProteinDeficit should calculate deficit correctly', () {
      // ARRANGE
      final nutritionHistory = [
        DailyNutritionSummary(
          date: DateTime(2024, 1, 1),
          meals: [
            Meal(
              id: 'meal-1',
              name: 'Breakfast',
              timestamp: DateTime(2024, 1, 1, 8, 0),
              macros: const MealMacros(
                calories: 400,
                protein: 30,
                carbs: 40,
                fats: 15,
              ),
              micros: const MealMicros(
                fiber: 5,
                sugar: 10,
                sodium: 300,
                potassium: 400,
              ),
              vitamins: const MealVitamins(
                vitaminA: 100,
                vitaminB: 1,
                vitaminC: 20,
                vitaminD: 5,
                vitaminE: 3,
              ),
              minerals: const MealMinerals(
                calcium: 200,
                iron: 5,
                magnesium: 50,
                zinc: 3,
              ),
            ),
          ],
          target: null,
        ),
        DailyNutritionSummary(
          date: DateTime(2024, 1, 2),
          meals: [
            Meal(
              id: 'meal-2',
              name: 'Lunch',
              timestamp: DateTime(2024, 1, 2, 12, 0),
              macros: const MealMacros(
                calories: 500,
                protein: 40,
                carbs: 50,
                fats: 20,
              ),
              micros: const MealMicros(
                fiber: 8,
                sugar: 15,
                sodium: 400,
                potassium: 500,
              ),
              vitamins: const MealVitamins(
                vitaminA: 150,
                vitaminB: 1.5,
                vitaminC: 30,
                vitaminD: 8,
                vitaminE: 5,
              ),
              minerals: const MealMinerals(
                calcium: 300,
                iron: 8,
                magnesium: 80,
                zinc: 5,
              ),
            ),
          ],
          target: null,
        ),
      ];

      final targets = NutritionTargets(
        userId: 'user-1',
        macros: const MacroTargets(
          calories: 2000,
          protein: 150, // Target: 150g
          carbs: 200,
          fats: 70,
        ),
        micros: const MicroTargets(
          fiber: 30,
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

      // ACT
      final deficit = engine.calculateProteinDeficit(nutritionHistory, targets);

      // ASSERT
      // Average protein: (30 + 40) / 2 = 35g
      // Deficit: 150 - 35 = 115g
      expect(deficit, equals(115.0));
    });

    test('calculateProteinDeficit should return full target for empty data', () {
      // ARRANGE
      final targets = NutritionTargets(
        userId: 'user-1',
        macros: const MacroTargets(
          calories: 2000,
          protein: 150,
          carbs: 200,
          fats: 70,
        ),
        micros: const MicroTargets(
          fiber: 30,
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

      // ACT
      final deficit = engine.calculateProteinDeficit([], targets);

      // ASSERT
      expect(deficit, equals(150.0)); // Full target as deficit
    });

    test('calculateProteinDeficit should handle negative deficit (surplus)', () {
      // ARRANGE
      final nutritionHistory = [
        DailyNutritionSummary(
          date: DateTime(2024, 1, 1),
          meals: [
            Meal(
              id: 'meal-1',
              name: 'High Protein Meal',
              timestamp: DateTime(2024, 1, 1, 8, 0),
              macros: const MealMacros(
                calories: 800,
                protein: 160, // Above target
                carbs: 40,
                fats: 15,
              ),
              micros: const MealMicros(
                fiber: 5,
                sugar: 10,
                sodium: 300,
                potassium: 400,
              ),
              vitamins: const MealVitamins(
                vitaminA: 100,
                vitaminB: 1,
                vitaminC: 20,
                vitaminD: 5,
                vitaminE: 3,
              ),
              minerals: const MealMinerals(
                calcium: 200,
                iron: 5,
                magnesium: 50,
                zinc: 3,
              ),
            ),
          ],
          target: null,
        ),
      ];

      final targets = NutritionTargets(
        userId: 'user-1',
        macros: const MacroTargets(
          calories: 2000,
          protein: 150, // Target: 150g
          carbs: 200,
          fats: 70,
        ),
        micros: const MicroTargets(
          fiber: 30,
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

      // ACT
      final deficit = engine.calculateProteinDeficit(nutritionHistory, targets);

      // ASSERT
      // Deficit: 150 - 160 = -10g (surplus)
      expect(deficit, equals(-10.0));
    });

    test('calculateMacroAdherence should calculate adherence percentages correctly', () {
      // ARRANGE
      final nutritionHistory = [
        DailyNutritionSummary(
          date: DateTime(2024, 1, 1),
          meals: [
            Meal(
              id: 'meal-1',
              name: 'Breakfast',
              timestamp: DateTime(2024, 1, 1, 8, 0),
              macros: const MealMacros(
                calories: 1000,
                protein: 75, // 50% of target
                carbs: 100, // 50% of target
                fats: 35, // 50% of target
              ),
              micros: const MealMicros(
                fiber: 5,
                sugar: 10,
                sodium: 300,
                potassium: 400,
              ),
              vitamins: const MealVitamins(
                vitaminA: 100,
                vitaminB: 1,
                vitaminC: 20,
                vitaminD: 5,
                vitaminE: 3,
              ),
              minerals: const MealMinerals(
                calcium: 200,
                iron: 5,
                magnesium: 50,
                zinc: 3,
              ),
            ),
          ],
          target: null,
        ),
      ];

      final targets = NutritionTargets(
        userId: 'user-1',
        macros: const MacroTargets(
          calories: 2000,
          protein: 150,
          carbs: 200,
          fats: 70,
        ),
        micros: const MicroTargets(
          fiber: 30,
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

      // ACT
      final adherence = engine.calculateMacroAdherence(nutritionHistory, targets);

      // ASSERT
      expect(adherence['protein'], equals(50.0)); // 75/150 * 100 = 50%
      expect(adherence['carbs'], equals(50.0)); // 100/200 * 100 = 50%
      expect(adherence['fats'], equals(50.0)); // 35/70 * 100 = 50%
    });

    test('calculateMacroAdherence should cap adherence at 100%', () {
      // ARRANGE
      final nutritionHistory = [
        DailyNutritionSummary(
          date: DateTime(2024, 1, 1),
          meals: [
            Meal(
              id: 'meal-1',
              name: 'High Macro Meal',
              timestamp: DateTime(2024, 1, 1, 8, 0),
              macros: const MealMacros(
                calories: 3000,
                protein: 300, // 200% of target
                carbs: 400, // 200% of target
                fats: 140, // 200% of target
              ),
              micros: const MealMicros(
                fiber: 5,
                sugar: 10,
                sodium: 300,
                potassium: 400,
              ),
              vitamins: const MealVitamins(
                vitaminA: 100,
                vitaminB: 1,
                vitaminC: 20,
                vitaminD: 5,
                vitaminE: 3,
              ),
              minerals: const MealMinerals(
                calcium: 200,
                iron: 5,
                magnesium: 50,
                zinc: 3,
              ),
            ),
          ],
          target: null,
        ),
      ];

      final targets = NutritionTargets(
        userId: 'user-1',
        macros: const MacroTargets(
          calories: 2000,
          protein: 150,
          carbs: 200,
          fats: 70,
        ),
        micros: const MicroTargets(
          fiber: 30,
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

      // ACT
      final adherence = engine.calculateMacroAdherence(nutritionHistory, targets);

      // ASSERT
      expect(adherence['protein'], equals(100.0)); // Capped at 100%
      expect(adherence['carbs'], equals(100.0)); // Capped at 100%
      expect(adherence['fats'], equals(100.0)); // Capped at 100%
    });

    test('calculateTrackingAccuracy should calculate accuracy correctly', () {
      // ARRANGE
      final nutritionHistory = [
        DailyNutritionSummary(
          date: DateTime(2024, 1, 1),
          meals: [
            Meal(
              id: 'meal-1',
              name: 'Breakfast',
              timestamp: DateTime(2024, 1, 1, 8, 0),
              macros: const MealMacros(
                calories: 400,
                protein: 30,
                carbs: 40,
                fats: 15,
              ),
              micros: const MealMicros(
                fiber: 5,
                sugar: 10,
                sodium: 300,
                potassium: 400,
              ),
              vitamins: const MealVitamins(
                vitaminA: 100,
                vitaminB: 1,
                vitaminC: 20,
                vitaminD: 5,
                vitaminE: 3,
              ),
              minerals: const MealMinerals(
                calcium: 200,
                iron: 5,
                magnesium: 50,
                zinc: 3,
              ),
            ),
          ],
          target: null,
        ),
        DailyNutritionSummary(
          date: DateTime(2024, 1, 2),
          meals: [], // No meals logged
          target: null,
        ),
      ];

      // ACT
      final accuracy = engine.calculateTrackingAccuracy(nutritionHistory, 7);

      // ASSERT
      // 1 day with meals out of 7 total days = 14.3%
      expect(accuracy, closeTo(14.3, 0.1));
    });

    test('getProteinIntakePercentage should calculate percentage correctly', () {
      // ARRANGE
      final nutritionHistory = [
        DailyNutritionSummary(
          date: DateTime(2024, 1, 1),
          meals: [
            Meal(
              id: 'meal-1',
              name: 'Breakfast',
              timestamp: DateTime(2024, 1, 1, 8, 0),
              macros: const MealMacros(
                calories: 400,
                protein: 120, // 80% of target
                carbs: 40,
                fats: 15,
              ),
              micros: const MealMicros(
                fiber: 5,
                sugar: 10,
                sodium: 300,
                potassium: 400,
              ),
              vitamins: const MealVitamins(
                vitaminA: 100,
                vitaminB: 1,
                vitaminC: 20,
                vitaminD: 5,
                vitaminE: 3,
              ),
              minerals: const MealMinerals(
                calcium: 200,
                iron: 5,
                magnesium: 50,
                zinc: 3,
              ),
            ),
          ],
          target: null,
        ),
      ];

      final targets = NutritionTargets(
        userId: 'user-1',
        macros: const MacroTargets(
          calories: 2000,
          protein: 150, // Target: 150g
          carbs: 200,
          fats: 70,
        ),
        micros: const MicroTargets(
          fiber: 30,
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

      // ACT
      final percentage = engine.getProteinIntakePercentage(nutritionHistory, targets);

      // ASSERT
      expect(percentage, equals(80.0)); // 120/150 * 100 = 80%
    });

    test('getProteinFoodRecommendations should return recommendations when below 80%', () {
      // ACT
      final recommendations = engine.getProteinFoodRecommendations(75.0);

      // ASSERT
      expect(recommendations, isNotEmpty);
      expect(recommendations, contains(contains('Chicken breast')));
      expect(recommendations, contains(contains('Greek yogurt')));
      expect(recommendations, contains(contains('Eggs')));
    });

    test('getProteinFoodRecommendations should return empty list when above 80%', () {
      // ACT
      final recommendations = engine.getProteinFoodRecommendations(85.0);

      // ASSERT
      expect(recommendations, isEmpty);
    });
  });

  group('AIInsightsEngineImpl - Body Metrics Analysis Methods', () {
    test('analyzeWeightTrend should detect increasing trend', () {
      // ARRANGE
      final bodyEntries = [
        BodyEntry(
          id: 'entry-1',
          date: DateTime(2024, 1, 1),
          weight: 70.0,
          measurements: {},
        ),
        BodyEntry(
          id: 'entry-2',
          date: DateTime(2024, 1, 15),
          weight: 71.0,
          measurements: {},
        ),
      ];

      // ACT
      final trend = engine.analyzeWeightTrend(bodyEntries);

      // ASSERT
      expect(trend, equals(WeightTrend.increasing));
    });

    test('analyzeWeightTrend should detect decreasing trend', () {
      // ARRANGE
      final bodyEntries = [
        BodyEntry(
          id: 'entry-1',
          date: DateTime(2024, 1, 1),
          weight: 75.0,
          measurements: {},
        ),
        BodyEntry(
          id: 'entry-2',
          date: DateTime(2024, 1, 15),
          weight: 74.0,
          measurements: {},
        ),
      ];

      // ACT
      final trend = engine.analyzeWeightTrend(bodyEntries);

      // ASSERT
      expect(trend, equals(WeightTrend.decreasing));
    });

    test('analyzeWeightTrend should detect stable trend', () {
      // ARRANGE
      final bodyEntries = [
        BodyEntry(
          id: 'entry-1',
          date: DateTime(2024, 1, 1),
          weight: 70.0,
          measurements: {},
        ),
        BodyEntry(
          id: 'entry-2',
          date: DateTime(2024, 1, 15),
          weight: 70.2,
          measurements: {},
        ),
      ];

      // ACT
      final trend = engine.analyzeWeightTrend(bodyEntries);

      // ASSERT
      expect(trend, equals(WeightTrend.stable));
    });

    test('analyzeWeightTrend should return insufficient_data for single entry', () {
      // ARRANGE
      final bodyEntries = [
        BodyEntry(
          id: 'entry-1',
          date: DateTime(2024, 1, 1),
          weight: 70.0,
          measurements: {},
        ),
      ];

      // ACT
      final trend = engine.analyzeWeightTrend(bodyEntries);

      // ASSERT
      expect(trend, equals(WeightTrend.insufficient_data));
    });

    test('analyzeWeightTrend should return insufficient_data for empty list', () {
      // ACT
      final trend = engine.analyzeWeightTrend([]);

      // ASSERT
      expect(trend, equals(WeightTrend.insufficient_data));
    });

    test('calculateWeightChange should calculate positive change correctly', () {
      // ARRANGE
      final bodyEntries = [
        BodyEntry(
          id: 'entry-1',
          date: DateTime(2024, 1, 1),
          weight: 70.0,
          measurements: {},
        ),
        BodyEntry(
          id: 'entry-2',
          date: DateTime(2024, 1, 15),
          weight: 72.5,
          measurements: {},
        ),
      ];

      // ACT
      final change = engine.calculateWeightChange(bodyEntries);

      // ASSERT
      expect(change, equals(2.5)); // 72.5 - 70.0 = 2.5kg gained
    });

    test('calculateWeightChange should calculate negative change correctly', () {
      // ARRANGE
      final bodyEntries = [
        BodyEntry(
          id: 'entry-1',
          date: DateTime(2024, 1, 1),
          weight: 75.0,
          measurements: {},
        ),
        BodyEntry(
          id: 'entry-2',
          date: DateTime(2024, 1, 15),
          weight: 72.0,
          measurements: {},
        ),
      ];

      // ACT
      final change = engine.calculateWeightChange(bodyEntries);

      // ASSERT
      expect(change, equals(-3.0)); // 72.0 - 75.0 = -3.0kg lost
    });

    test('calculateWeightChange should return 0 for insufficient data', () {
      // ARRANGE
      final bodyEntries = [
        BodyEntry(
          id: 'entry-1',
          date: DateTime(2024, 1, 1),
          weight: 70.0,
          measurements: {},
        ),
      ];

      // ACT
      final change = engine.calculateWeightChange(bodyEntries);

      // ASSERT
      expect(change, equals(0.0));
    });

    test('calculateWeightChangeRate should calculate weekly rate correctly', () {
      // ARRANGE
      final bodyEntries = [
        BodyEntry(
          id: 'entry-1',
          date: DateTime(2024, 1, 1),
          weight: 70.0,
          measurements: {},
        ),
        BodyEntry(
          id: 'entry-2',
          date: DateTime(2024, 1, 15), // 14 days later
          weight: 72.0,
          measurements: {},
        ),
      ];

      // ACT
      final rate = engine.calculateWeightChangeRate(bodyEntries);

      // ASSERT
      // 2kg change over 14 days = 2/14 * 7 = 1kg per week
      expect(rate, equals(1.0));
    });

    test('isWeightChangeAlignedWithGoal should return true for aligned weight loss', () {
      // ARRANGE
      final bodyEntries = [
        BodyEntry(
          id: 'entry-1',
          date: DateTime(2024, 1, 1),
          weight: 75.0,
          measurements: {},
        ),
        BodyEntry(
          id: 'entry-2',
          date: DateTime(2024, 1, 15),
          weight: 74.0, // Lost 1kg
          measurements: {},
        ),
      ];

      // ACT
      final aligned = engine.isWeightChangeAlignedWithGoal(bodyEntries, 'lose_weight');

      // ASSERT
      expect(aligned, isTrue);
    });

    test('isWeightChangeAlignedWithGoal should return false for misaligned weight gain', () {
      // ARRANGE
      final bodyEntries = [
        BodyEntry(
          id: 'entry-1',
          date: DateTime(2024, 1, 1),
          weight: 70.0,
          measurements: {},
        ),
        BodyEntry(
          id: 'entry-2',
          date: DateTime(2024, 1, 15),
          weight: 71.0, // Gained 1kg
          measurements: {},
        ),
      ];

      // ACT
      final aligned = engine.isWeightChangeAlignedWithGoal(bodyEntries, 'lose_weight');

      // ASSERT
      expect(aligned, isFalse);
    });

    test('isWeightChangeAlignedWithGoal should return true for maintenance within threshold', () {
      // ARRANGE
      final bodyEntries = [
        BodyEntry(
          id: 'entry-1',
          date: DateTime(2024, 1, 1),
          weight: 70.0,
          measurements: {},
        ),
        BodyEntry(
          id: 'entry-2',
          date: DateTime(2024, 1, 15),
          weight: 70.3, // Small change within threshold
          measurements: {},
        ),
      ];

      // ACT
      final aligned = engine.isWeightChangeAlignedWithGoal(bodyEntries, 'maintain_weight');

      // ASSERT
      expect(aligned, isTrue);
    });
  });

  group('AIInsightsEngineImpl - Insight Prioritization and Formatting', () {
    test('prioritizeInsights should sort by priority correctly', () {
      // ARRANGE
      final insights = [
        Insight(
          id: 'low-1',
          context: InsightContext.workout,
          title: 'Low Priority',
          message: 'Low priority message',
          icon: '💪',
          priority: InsightPriority.low,
          generatedAt: DateTime.now(),
          metadata: {},
        ),
        Insight(
          id: 'high-1',
          context: InsightContext.workout,
          title: 'High Priority',
          message: 'High priority message',
          icon: '🔥',
          priority: InsightPriority.high,
          generatedAt: DateTime.now(),
          metadata: {},
        ),
        Insight(
          id: 'medium-1',
          context: InsightContext.workout,
          title: 'Medium Priority',
          message: 'Medium priority message',
          icon: '⚡',
          priority: InsightPriority.medium,
          generatedAt: DateTime.now(),
          metadata: {},
        ),
      ];

      // ACT
      final prioritized = engine.prioritizeInsights(insights);

      // ASSERT
      expect(prioritized.length, equals(3));
      expect(prioritized[0].priority, equals(InsightPriority.high));
      expect(prioritized[1].priority, equals(InsightPriority.medium));
      expect(prioritized[2].priority, equals(InsightPriority.low));
    });

    test('prioritizeInsights should limit to maxInsights', () {
      // ARRANGE
      final insights = List.generate(5, (index) => Insight(
        id: 'insight-$index',
        context: InsightContext.workout,
        title: 'Insight $index',
        message: 'Message $index',
        icon: '💪',
        priority: InsightPriority.medium,
        generatedAt: DateTime.now(),
        metadata: {},
      ));

      // ACT
      final prioritized = engine.prioritizeInsights(insights, maxInsights: 3);

      // ASSERT
      expect(prioritized.length, equals(3));
    });

    test('prioritizeInsights should return empty list for empty input', () {
      // ACT
      final prioritized = engine.prioritizeInsights([]);

      // ASSERT
      expect(prioritized, isEmpty);
    });

    test('formatInsight should format message correctly', () {
      // ARRANGE
      final numbers = {
        'volume': 2500.0,
        'workouts': 12,
        'percentage': 85.5,
      };

      // ACT
      final insight = engine.formatInsight(
        id: 'test-insight',
        context: InsightContext.workout,
        title: 'Test Insight',
        analysis: 'Your performance is improving.',
        numbers: numbers,
        actionPlan: 'Keep up the great work!',
        icon: '💪',
        priority: InsightPriority.high,
      );

      // ASSERT
      expect(insight.message, contains('Your performance is improving.'));
      expect(insight.message, contains('volume: 2500'));
      expect(insight.message, contains('workouts: 12'));
      expect(insight.message, contains('percentage: 85.5'));
      expect(insight.message, contains('Keep up the great work!'));
      expect(insight.metadata?['analysis'], equals('Your performance is improving.'));
      expect(insight.metadata?['actionPlan'], equals('Keep up the great work!'));
    });

    test('calculatePercentageChange should calculate positive change correctly', () {
      // ACT
      final change = engine.calculatePercentageChange(100.0, 120.0);

      // ASSERT
      expect(change, equals(20.0)); // 20% increase
    });

    test('calculatePercentageChange should calculate negative change correctly', () {
      // ACT
      final change = engine.calculatePercentageChange(100.0, 80.0);

      // ASSERT
      expect(change, equals(-20.0)); // 20% decrease
    });

    test('calculatePercentageChange should handle zero old value', () {
      // ACT
      final change = engine.calculatePercentageChange(0.0, 50.0);

      // ASSERT
      expect(change, equals(100.0)); // Special case for zero baseline
    });

    test('generateFallbackInsights should return appropriate onboarding insights', () {
      // ACT - Test all contexts
      final homeInsights = engine.generateFallbackInsights(InsightContext.home);
      final workoutInsights = engine.generateFallbackInsights(InsightContext.workout);
      final nutritionInsights = engine.generateFallbackInsights(InsightContext.nutrition);
      final profileInsights = engine.generateFallbackInsights(InsightContext.profile);

      // ASSERT
      expect(homeInsights.length, equals(1));
      expect(homeInsights.first.title, contains('Welcome'));
      expect(homeInsights.first.metadata?['type'], equals('onboarding'));

      expect(workoutInsights.length, equals(1));
      expect(workoutInsights.first.title, contains('Ready to Train'));
      expect(workoutInsights.first.metadata?['type'], equals('onboarding'));

      expect(nutritionInsights.length, equals(1));
      expect(nutritionInsights.first.title, contains('Track Your Nutrition'));
      expect(nutritionInsights.first.metadata?['type'], equals('onboarding'));

      expect(profileInsights.length, equals(1));
      expect(profileInsights.first.title, contains('Track Your Progress'));
      expect(profileInsights.first.metadata?['type'], equals('onboarding'));
    });

    test('createHighPriorityInsight should create insight with high priority', () {
      // ACT
      final insight = engine.createHighPriorityInsight(
        context: InsightContext.workout,
        title: 'Urgent Action',
        analysis: 'This needs immediate attention.',
        numbers: {'days': 7},
        actionPlan: 'Take action now!',
        icon: '🚨',
      );

      // ASSERT
      expect(insight.priority, equals(InsightPriority.high));
      expect(insight.title, equals('Urgent Action'));
      expect(insight.icon, equals('🚨'));
    });

    test('createMediumPriorityInsight should create insight with medium priority', () {
      // ACT
      final insight = engine.createMediumPriorityInsight(
        context: InsightContext.nutrition,
        title: 'Important Recommendation',
        analysis: 'This is worth considering.',
        numbers: {'percentage': 75},
        actionPlan: 'Consider this action.',
        icon: '⚡',
      );

      // ASSERT
      expect(insight.priority, equals(InsightPriority.medium));
      expect(insight.title, equals('Important Recommendation'));
      expect(insight.icon, equals('⚡'));
    });

    test('createLowPriorityInsight should create insight with low priority', () {
      // ACT
      final insight = engine.createLowPriorityInsight(
        context: InsightContext.profile,
        title: 'General Encouragement',
        analysis: 'You are doing well.',
        numbers: {'streak': 3},
        actionPlan: 'Keep it up!',
        icon: '👍',
      );

      // ASSERT
      expect(insight.priority, equals(InsightPriority.low));
      expect(insight.title, equals('General Encouragement'));
      expect(insight.icon, equals('👍'));
    });
  });

  group('AIInsightsEngineImpl - Quick Feedback Generation', () {
    test('generateQuickFeedback should return PR feedback when PR detected', () async {
      // ARRANGE
      final completedWorkout = Workout(
        id: 'workout-1',
        date: DateTime.now(),
        exercises: [
          Exercise(
            id: 'exercise-1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [
              SetEntry(
                id: 'set-1',
                reps: 10,
                weight: 120.0, // New PR
                timestamp: DateTime.now(),
              ),
            ],
          ),
        ],
        duration: const Duration(minutes: 60),
        totalVolume: 1200,
      );

      final history = [
        Workout(
          id: 'workout-2',
          date: DateTime.now().subtract(const Duration(days: 1)),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 100.0, // Previous max
                  timestamp: DateTime.now().subtract(const Duration(days: 1)),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 1000,
        ),
      ];

      // ACT
      final feedback = await engine.generateQuickFeedback(completedWorkout, history);

      // ASSERT
      expect(feedback.title, contains('Personal Record'));
      expect(feedback.message, contains('Bench Press'));
      expect(feedback.message, contains('120'));
      expect(feedback.priority, equals(InsightPriority.high));
      expect(feedback.metadata?['type'], equals('pr_achievement'));
    });

    test('generateQuickFeedback should return volume record feedback when 10%+ increase', () async {
      // ARRANGE
      final completedWorkout = Workout(
        id: 'workout-1',
        date: DateTime.now(),
        exercises: [
          Exercise(
            id: 'exercise-1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [
              SetEntry(
                id: 'set-1',
                reps: 11, // Increase reps instead of weight to avoid PR
                weight: 100.0,
                timestamp: DateTime.now(),
              ),
            ],
          ),
        ],
        duration: const Duration(minutes: 60),
        totalVolume: 1100, // 10% increase from 1000
      );

      final history = [
        Workout(
          id: 'workout-2',
          date: DateTime.now().subtract(const Duration(days: 1)),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 100.0,
                  timestamp: DateTime.now().subtract(const Duration(days: 1)),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 1000,
        ),
      ];

      // ACT
      final feedback = await engine.generateQuickFeedback(completedWorkout, history);

      // ASSERT
      expect(feedback.title, contains('Volume Record'));
      expect(feedback.message, contains('10%'));
      expect(feedback.priority, equals(InsightPriority.high));
      expect(feedback.metadata?['type'], equals('volume_record'));
    });

    test('generateQuickFeedback should return general encouragement for regular workouts', () async {
      // ARRANGE
      final completedWorkout = Workout(
        id: 'workout-1',
        date: DateTime.now(),
        exercises: [
          Exercise(
            id: 'exercise-1',
            name: 'Bench Press',
            type: ExerciseType.strength,
            sets: [
              SetEntry(
                id: 'set-1',
                reps: 10,
                weight: 100.0,
                timestamp: DateTime.now(),
              ),
            ],
          ),
        ],
        duration: const Duration(minutes: 60),
        totalVolume: 1000,
      );

      final history = [
        Workout(
          id: 'workout-2',
          date: DateTime.now().subtract(const Duration(days: 1)),
          exercises: [
            Exercise(
              id: 'exercise-1',
              name: 'Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(
                  id: 'set-1',
                  reps: 10,
                  weight: 100.0,
                  timestamp: DateTime.now().subtract(const Duration(days: 1)),
                ),
              ],
            ),
          ],
          duration: const Duration(minutes: 60),
          totalVolume: 1000,
        ),
      ];

      // ACT
      final feedback = await engine.generateQuickFeedback(completedWorkout, history);

      // ASSERT
      expect(feedback.title, contains('Great Workout'));
      expect(feedback.message, contains('1000'));
      expect(feedback.priority, equals(InsightPriority.medium));
      expect(feedback.metadata?['type'], equals('general_encouragement'));
    });
  });
}