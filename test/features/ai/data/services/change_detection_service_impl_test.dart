import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:progression_tracker/features/ai/data/services/change_detection_service_impl.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/entities.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/entities/measurement_type.dart';

import 'change_detection_service_impl_test.mocks.dart';

void main() {
  group('ChangeDetectionServiceImpl', () {
    late ChangeDetectionServiceImpl service;
    late MockWorkoutRepository mockWorkoutRepository;
    late MockNutritionRepository mockNutritionRepository;
    late MockBodyRepository mockBodyRepository;

    setUp(() {
      mockWorkoutRepository = MockWorkoutRepository();
      mockNutritionRepository = MockNutritionRepository();
      mockBodyRepository = MockBodyRepository();
      
      service = ChangeDetectionServiceImpl(
        workoutRepository: mockWorkoutRepository,
        nutritionRepository: mockNutritionRepository,
        bodyRepository: mockBodyRepository,
      );
    });

    group('hasWorkoutDataChanged', () {
      test('should return false when no workouts exist', () async {
        when(mockWorkoutRepository.getWorkoutsPaginated(offset: 0, limit: 1))
            .thenAnswer((_) async => []);

        final lastGenerated = DateTime(2024, 1, 15, 10, 0);
        final hasChanged = await service.hasWorkoutDataChanged(lastGenerated);

        expect(hasChanged, isFalse);
        verify(mockWorkoutRepository.getWorkoutsPaginated(offset: 0, limit: 1)).called(1);
      });

      test('should return false when latest workout is older than last generated', () async {
        final workout = Workout(
          id: 'workout-1',
          date: DateTime(2024, 1, 14, 10, 0), // Before last generated
          exercises: [],
          duration: const Duration(hours: 1),
          totalVolume: 100.0,
        );

        when(mockWorkoutRepository.getWorkoutsPaginated(offset: 0, limit: 1))
            .thenAnswer((_) async => [workout]);

        final lastGenerated = DateTime(2024, 1, 15, 10, 0);
        final hasChanged = await service.hasWorkoutDataChanged(lastGenerated);

        expect(hasChanged, isFalse);
      });

      test('should return true when latest workout is newer than last generated', () async {
        final workout = Workout(
          id: 'workout-1',
          date: DateTime(2024, 1, 16, 10, 0), // After last generated
          exercises: [],
          duration: const Duration(hours: 1),
          totalVolume: 100.0,
        );

        when(mockWorkoutRepository.getWorkoutsPaginated(offset: 0, limit: 1))
            .thenAnswer((_) async => [workout]);

        final lastGenerated = DateTime(2024, 1, 15, 10, 0);
        final hasChanged = await service.hasWorkoutDataChanged(lastGenerated);

        expect(hasChanged, isTrue);
      });

      test('should return true on error', () async {
        when(mockWorkoutRepository.getWorkoutsPaginated(offset: 0, limit: 1))
            .thenThrow(Exception('Database error'));

        final lastGenerated = DateTime(2024, 1, 15, 10, 0);
        final hasChanged = await service.hasWorkoutDataChanged(lastGenerated);

        expect(hasChanged, isTrue);
      });
    });

    group('hasNutritionDataChanged', () {
      test('should return false when no nutrition data exists', () async {
        when(mockNutritionRepository.getNutritionHistoryPaginated(offset: 0, limit: 1))
            .thenAnswer((_) async => []);

        final lastGenerated = DateTime(2024, 1, 15, 10, 0);
        final hasChanged = await service.hasNutritionDataChanged(lastGenerated);

        expect(hasChanged, isFalse);
        verify(mockNutritionRepository.getNutritionHistoryPaginated(offset: 0, limit: 1)).called(1);
      });

      test('should return false when latest meal is older than last generated', () async {
        final meal = Meal(
          id: 'meal-1',
          name: 'Breakfast',
          macros: const MealMacros(calories: 300, protein: 20, carbs: 30, fats: 10),
          micros: const MealMicros(fiber: 5, sugar: 10, sodium: 200, potassium: 300),
          vitamins: const MealVitamins(vitaminA: 100, vitaminB: 50, vitaminC: 80, vitaminD: 25, vitaminE: 15),
          minerals: const MealMinerals(calcium: 200, iron: 10, magnesium: 50, zinc: 8),
          timestamp: DateTime(2024, 1, 14, 12, 0), // Before last generated
        );

        final summary = DailyNutritionSummary(
          date: DateTime(2024, 1, 14),
          meals: [meal],
          target: null,
        );

        when(mockNutritionRepository.getNutritionHistoryPaginated(offset: 0, limit: 1))
            .thenAnswer((_) async => [summary]);

        final lastGenerated = DateTime(2024, 1, 15, 10, 0);
        final hasChanged = await service.hasNutritionDataChanged(lastGenerated);

        expect(hasChanged, isFalse);
      });

      test('should return true when latest meal is newer than last generated', () async {
        final meal = Meal(
          id: 'meal-1',
          name: 'Breakfast',
          macros: const MealMacros(calories: 300, protein: 20, carbs: 30, fats: 10),
          micros: const MealMicros(fiber: 5, sugar: 10, sodium: 200, potassium: 300),
          vitamins: const MealVitamins(vitaminA: 100, vitaminB: 50, vitaminC: 80, vitaminD: 25, vitaminE: 15),
          minerals: const MealMinerals(calcium: 200, iron: 10, magnesium: 50, zinc: 8),
          timestamp: DateTime(2024, 1, 16, 12, 0), // After last generated
        );

        final summary = DailyNutritionSummary(
          date: DateTime(2024, 1, 16),
          meals: [meal],
          target: null,
        );

        when(mockNutritionRepository.getNutritionHistoryPaginated(offset: 0, limit: 1))
            .thenAnswer((_) async => [summary]);

        final lastGenerated = DateTime(2024, 1, 15, 10, 0);
        final hasChanged = await service.hasNutritionDataChanged(lastGenerated);

        expect(hasChanged, isTrue);
      });

      test('should use day date as fallback when no meals', () async {
        final summary = DailyNutritionSummary(
          date: DateTime(2024, 1, 16), // After last generated
          meals: [], // No meals
          target: null,
        );

        when(mockNutritionRepository.getNutritionHistoryPaginated(offset: 0, limit: 1))
            .thenAnswer((_) async => [summary]);

        final lastGenerated = DateTime(2024, 1, 15, 10, 0);
        final hasChanged = await service.hasNutritionDataChanged(lastGenerated);

        expect(hasChanged, isTrue);
      });

      test('should return true on error', () async {
        when(mockNutritionRepository.getNutritionHistoryPaginated(offset: 0, limit: 1))
            .thenThrow(Exception('Database error'));

        final lastGenerated = DateTime(2024, 1, 15, 10, 0);
        final hasChanged = await service.hasNutritionDataChanged(lastGenerated);

        expect(hasChanged, isTrue);
      });
    });

    group('hasBodyDataChanged', () {
      test('should return false when no body entries exist', () async {
        when(mockBodyRepository.getAllBodyEntries())
            .thenAnswer((_) async => []);

        final lastGenerated = DateTime(2024, 1, 15, 10, 0);
        final hasChanged = await service.hasBodyDataChanged(lastGenerated);

        expect(hasChanged, isFalse);
        verify(mockBodyRepository.getAllBodyEntries()).called(1);
      });

      test('should return false when latest entry is older than last generated', () async {
        final bodyEntry = BodyEntry(
          id: 'body-1',
          date: DateTime(2024, 1, 14, 8, 0), // Before last generated
          weight: 70.5,
          measurements: {MeasurementType.waist: 80.0},
        );

        when(mockBodyRepository.getAllBodyEntries())
            .thenAnswer((_) async => [bodyEntry]);

        final lastGenerated = DateTime(2024, 1, 15, 10, 0);
        final hasChanged = await service.hasBodyDataChanged(lastGenerated);

        expect(hasChanged, isFalse);
      });

      test('should return true when latest entry is newer than last generated', () async {
        final bodyEntry = BodyEntry(
          id: 'body-1',
          date: DateTime(2024, 1, 16, 8, 0), // After last generated
          weight: 70.5,
          measurements: {MeasurementType.waist: 80.0},
        );

        when(mockBodyRepository.getAllBodyEntries())
            .thenAnswer((_) async => [bodyEntry]);

        final lastGenerated = DateTime(2024, 1, 15, 10, 0);
        final hasChanged = await service.hasBodyDataChanged(lastGenerated);

        expect(hasChanged, isTrue);
      });

      test('should return true on error', () async {
        when(mockBodyRepository.getAllBodyEntries())
            .thenThrow(Exception('Database error'));

        final lastGenerated = DateTime(2024, 1, 15, 10, 0);
        final hasChanged = await service.hasBodyDataChanged(lastGenerated);

        expect(hasChanged, isTrue);
      });
    });

    group('getLastDataChange', () {
      test('should return null when no data exists for any context', () async {
        when(mockWorkoutRepository.getWorkoutsPaginated(offset: 0, limit: 1))
            .thenAnswer((_) async => []);
        when(mockNutritionRepository.getNutritionHistoryPaginated(offset: 0, limit: 1))
            .thenAnswer((_) async => []);
        when(mockBodyRepository.getAllBodyEntries())
            .thenAnswer((_) async => []);

        final lastChange = await service.getLastDataChange(InsightContext.home);

        expect(lastChange, isNull);
      });

      test('should return most recent timestamp for home context (all data)', () async {
        final workout = Workout(
          id: 'workout-1',
          date: DateTime(2024, 1, 15, 10, 0), // 10:00
          exercises: [],
          duration: const Duration(hours: 1),
          totalVolume: 100.0,
        );

        final meal = Meal(
          id: 'meal-1',
          name: 'Lunch',
          macros: const MealMacros(calories: 400, protein: 25, carbs: 40, fats: 15),
          micros: const MealMicros(fiber: 8, sugar: 12, sodium: 250, potassium: 400),
          vitamins: const MealVitamins(vitaminA: 120, vitaminB: 60, vitaminC: 90, vitaminD: 30, vitaminE: 18),
          minerals: const MealMinerals(calcium: 250, iron: 12, magnesium: 60, zinc: 10),
          timestamp: DateTime(2024, 1, 15, 18, 0), // 18:00 (most recent)
        );

        final summary = DailyNutritionSummary(
          date: DateTime(2024, 1, 15),
          meals: [meal],
          target: null,
        );

        final bodyEntry = BodyEntry(
          id: 'body-1',
          date: DateTime(2024, 1, 15, 8, 0), // 08:00
          weight: 70.5,
          measurements: {MeasurementType.waist: 80.0},
        );

        when(mockWorkoutRepository.getWorkoutsPaginated(offset: 0, limit: 1))
            .thenAnswer((_) async => [workout]);
        when(mockNutritionRepository.getNutritionHistoryPaginated(offset: 0, limit: 1))
            .thenAnswer((_) async => [summary]);
        when(mockBodyRepository.getAllBodyEntries())
            .thenAnswer((_) async => [bodyEntry]);

        final lastChange = await service.getLastDataChange(InsightContext.home);

        expect(lastChange, equals(DateTime(2024, 1, 15, 18, 0))); // Most recent meal
      });

      test('should return workout timestamp for workout context', () async {
        final workout = Workout(
          id: 'workout-1',
          date: DateTime(2024, 1, 15, 20, 0), // 20:00
          exercises: [],
          duration: const Duration(hours: 1),
          totalVolume: 100.0,
        );

        when(mockWorkoutRepository.getWorkoutsPaginated(offset: 0, limit: 1))
            .thenAnswer((_) async => [workout]);

        final lastChange = await service.getLastDataChange(InsightContext.workout);

        expect(lastChange, equals(DateTime(2024, 1, 15, 20, 0)));
        // Should not call other repositories for workout context
        verifyNever(mockNutritionRepository.getNutritionHistoryPaginated(offset: 0, limit: 1));
        verifyNever(mockBodyRepository.getAllBodyEntries());
      });

      test('should return nutrition timestamp for nutrition context', () async {
        final meal = Meal(
          id: 'meal-1',
          name: 'Dinner',
          macros: const MealMacros(calories: 500, protein: 30, carbs: 50, fats: 20),
          micros: const MealMicros(fiber: 10, sugar: 15, sodium: 300, potassium: 500),
          vitamins: const MealVitamins(vitaminA: 150, vitaminB: 70, vitaminC: 100, vitaminD: 35, vitaminE: 20),
          minerals: const MealMinerals(calcium: 300, iron: 15, magnesium: 70, zinc: 12),
          timestamp: DateTime(2024, 1, 15, 19, 0), // 19:00
        );

        final summary = DailyNutritionSummary(
          date: DateTime(2024, 1, 15),
          meals: [meal],
          target: null,
        );

        when(mockNutritionRepository.getNutritionHistoryPaginated(offset: 0, limit: 1))
            .thenAnswer((_) async => [summary]);

        final lastChange = await service.getLastDataChange(InsightContext.nutrition);

        expect(lastChange, equals(DateTime(2024, 1, 15, 19, 0)));
        // Should not call other repositories for nutrition context
        verifyNever(mockWorkoutRepository.getWorkoutsPaginated(offset: 0, limit: 1));
        verifyNever(mockBodyRepository.getAllBodyEntries());
      });

      test('should return most recent timestamp for profile context (body + workout)', () async {
        final workout = Workout(
          id: 'workout-1',
          date: DateTime(2024, 1, 15, 10, 0), // 10:00
          exercises: [],
          duration: const Duration(hours: 1),
          totalVolume: 100.0,
        );

        final bodyEntry = BodyEntry(
          id: 'body-1',
          date: DateTime(2024, 1, 15, 22, 0), // 22:00 (most recent)
          weight: 70.5,
          measurements: {MeasurementType.waist: 80.0},
        );

        when(mockWorkoutRepository.getWorkoutsPaginated(offset: 0, limit: 1))
            .thenAnswer((_) async => [workout]);
        when(mockBodyRepository.getAllBodyEntries())
            .thenAnswer((_) async => [bodyEntry]);

        final lastChange = await service.getLastDataChange(InsightContext.profile);

        expect(lastChange, equals(DateTime(2024, 1, 15, 22, 0))); // Most recent body entry
        // Should not call nutrition repository for profile context
        verifyNever(mockNutritionRepository.getNutritionHistoryPaginated(offset: 0, limit: 1));
      });

      test('should return null on error', () async {
        when(mockWorkoutRepository.getWorkoutsPaginated(offset: 0, limit: 1))
            .thenThrow(Exception('Database error'));
        when(mockNutritionRepository.getNutritionHistoryPaginated(offset: 0, limit: 1))
            .thenThrow(Exception('Database error'));
        when(mockBodyRepository.getAllBodyEntries())
            .thenThrow(Exception('Database error'));

        final lastChange = await service.getLastDataChange(InsightContext.home);

        expect(lastChange, isNull);
      });
    });

    group('edge cases', () {
      test('should handle multiple meals and find the most recent', () async {
        final meal1 = Meal(
          id: 'meal-1',
          name: 'Breakfast',
          macros: const MealMacros(calories: 300, protein: 20, carbs: 30, fats: 10),
          micros: const MealMicros(fiber: 5, sugar: 10, sodium: 200, potassium: 300),
          vitamins: const MealVitamins(vitaminA: 100, vitaminB: 50, vitaminC: 80, vitaminD: 25, vitaminE: 15),
          minerals: const MealMinerals(calcium: 200, iron: 10, magnesium: 50, zinc: 8),
          timestamp: DateTime(2024, 1, 15, 8, 0), // 08:00
        );

        final meal2 = Meal(
          id: 'meal-2',
          name: 'Lunch',
          macros: const MealMacros(calories: 400, protein: 25, carbs: 40, fats: 15),
          micros: const MealMicros(fiber: 8, sugar: 12, sodium: 250, potassium: 400),
          vitamins: const MealVitamins(vitaminA: 120, vitaminB: 60, vitaminC: 90, vitaminD: 30, vitaminE: 18),
          minerals: const MealMinerals(calcium: 250, iron: 12, magnesium: 60, zinc: 10),
          timestamp: DateTime(2024, 1, 15, 18, 0), // 18:00 (later)
        );

        final meal3 = Meal(
          id: 'meal-3',
          name: 'Snack',
          macros: const MealMacros(calories: 150, protein: 5, carbs: 20, fats: 5),
          micros: const MealMicros(fiber: 3, sugar: 15, sodium: 100, potassium: 200),
          vitamins: const MealVitamins(vitaminA: 50, vitaminB: 25, vitaminC: 40, vitaminD: 10, vitaminE: 8),
          minerals: const MealMinerals(calcium: 100, iron: 5, magnesium: 25, zinc: 4),
          timestamp: DateTime(2024, 1, 15, 12, 0), // 12:00 (middle)
        );

        final summary = DailyNutritionSummary(
          date: DateTime(2024, 1, 15),
          meals: [meal1, meal2, meal3], // Mixed order
          target: null,
        );

        when(mockNutritionRepository.getNutritionHistoryPaginated(offset: 0, limit: 1))
            .thenAnswer((_) async => [summary]);

        final lastGenerated = DateTime(2024, 1, 15, 10, 0);
        final hasChanged = await service.hasNutritionDataChanged(lastGenerated);

        // Should use the latest meal timestamp (18:00) which is after lastGenerated (10:00)
        expect(hasChanged, isTrue);
      });
    });
  });
}