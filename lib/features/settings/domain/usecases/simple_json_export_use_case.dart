import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';

/// Simplified JSON export use case that works with current entities and repositories.
///
/// Provides JSON export functionality for:
/// - All workout data
/// - All nutrition data  
/// - Complete user data backup
///
/// **Validates: Requirements 8.1**
class SimpleJsonExportUseCase {
  final WorkoutRepository _workoutRepository;
  final NutritionRepository _nutritionRepository;
  final AuthRepository _authRepository;

  SimpleJsonExportUseCase(
    this._workoutRepository,
    this._nutritionRepository,
    this._authRepository,
  );

  /// Exports all workouts to JSON format.
  ///
  /// Returns the file path of the exported JSON file.
  Future<String> exportWorkoutsToJSON() async {
    final workouts = await _workoutRepository.getAllWorkouts();
    
    final exportData = {
      'export_info': {
        'export_date': DateTime.now().toIso8601String(),
        'export_version': '1.0',
        'export_type': 'workouts',
        'total_workouts': workouts.length,
      },
      'workouts': workouts.map((workout) => {
        'id': workout.id,
        'date': workout.date.toIso8601String(),
        'duration_minutes': workout.duration.inMinutes,
        'total_volume_kg': workout.totalVolume,
        'exercises': workout.exercises.map((exercise) => {
          'id': exercise.id,
          'name': exercise.name,
          'type': exercise.type.toString(),
          'sets': exercise.sets.map((set) => {
            'id': set.id,
            'reps': set.reps,
            'weight_kg': set.weight,
            'rpe': set.rpe,
            'timestamp': set.timestamp.toIso8601String(),
          }).toList(),
        }).toList(),
      }).toList(),
    };
    
    final jsonContent = const JsonEncoder.withIndent('  ').convert(exportData);
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/ironflow_workouts_export.json');
    await file.writeAsString(jsonContent);
    
    return file.path;
  }

  /// Exports nutrition data to JSON format.
  ///
  /// Returns the file path of the exported JSON file.
  Future<String> exportNutritionToJSON() async {
    // Get nutrition data for the last year
    final endDate = DateTime.now();
    final startDate = DateTime(endDate.year - 1, endDate.month, endDate.day);
    
    final nutritionHistory = await _nutritionRepository.getNutritionHistory(startDate, endDate);
    final nutritionTargets = await _nutritionRepository.getNutritionTargets();
    
    final exportData = {
      'export_info': {
        'export_date': DateTime.now().toIso8601String(),
        'export_version': '1.0',
        'export_type': 'nutrition',
        'total_days': nutritionHistory.length,
        'date_range': {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      },
      'nutrition_targets': nutritionTargets != null ? {
        'macros': {
          'calories': nutritionTargets.macros.calories,
          'protein': nutritionTargets.macros.protein,
          'carbs': nutritionTargets.macros.carbs,
          'fats': nutritionTargets.macros.fats,
        },
        'micros': {
          'fiber': nutritionTargets.micros.fiber,
          'sugar': nutritionTargets.micros.sugar,
          'sodium': nutritionTargets.micros.sodium,
          'potassium': nutritionTargets.micros.potassium,
        },
        'vitamins': {
          'vitamin_a': nutritionTargets.vitamins.vitaminA,
          'vitamin_b': nutritionTargets.vitamins.vitaminB,
          'vitamin_c': nutritionTargets.vitamins.vitaminC,
          'vitamin_d': nutritionTargets.vitamins.vitaminD,
          'vitamin_e': nutritionTargets.vitamins.vitaminE,
        },
        'minerals': {
          'calcium': nutritionTargets.minerals.calcium,
          'iron': nutritionTargets.minerals.iron,
          'magnesium': nutritionTargets.minerals.magnesium,
          'zinc': nutritionTargets.minerals.zinc,
        },
      } : null,
      'daily_nutrition': nutritionHistory.map((dailyNutrition) => {
        'date': dailyNutrition.date.toIso8601String(),
        'totals': {
          'calories': dailyNutrition.totalCalories,
          'protein': dailyNutrition.totalProtein,
          'carbs': dailyNutrition.totalCarbs,
          'fats': dailyNutrition.totalFats,
          'fiber': dailyNutrition.totalFiber,
          'sugar': dailyNutrition.totalSugar,
          'sodium': dailyNutrition.totalSodium,
          'potassium': dailyNutrition.totalPotassium,
          'vitamin_a': dailyNutrition.totalVitaminA,
          'vitamin_b': dailyNutrition.totalVitaminB,
          'vitamin_c': dailyNutrition.totalVitaminC,
          'vitamin_d': dailyNutrition.totalVitaminD,
          'vitamin_e': dailyNutrition.totalVitaminE,
          'calcium': dailyNutrition.totalCalcium,
          'iron': dailyNutrition.totalIron,
          'magnesium': dailyNutrition.totalMagnesium,
          'zinc': dailyNutrition.totalZinc,
        },
        'meals': dailyNutrition.meals.map((meal) => {
          'id': meal.id,
          'name': meal.name,
          'timestamp': meal.timestamp.toIso8601String(),
          'macros': {
            'calories': meal.macros.calories,
            'protein': meal.macros.protein,
            'carbs': meal.macros.carbs,
            'fats': meal.macros.fats,
          },
          'micros': {
            'fiber': meal.micros.fiber,
            'sugar': meal.micros.sugar,
            'sodium': meal.micros.sodium,
            'potassium': meal.micros.potassium,
          },
          'vitamins': {
            'vitamin_a': meal.vitamins.vitaminA,
            'vitamin_b': meal.vitamins.vitaminB,
            'vitamin_c': meal.vitamins.vitaminC,
            'vitamin_d': meal.vitamins.vitaminD,
            'vitamin_e': meal.vitamins.vitaminE,
          },
          'minerals': {
            'calcium': meal.minerals.calcium,
            'iron': meal.minerals.iron,
            'magnesium': meal.minerals.magnesium,
            'zinc': meal.minerals.zinc,
          },
        }).toList(),
      }).toList(),
    };
    
    final jsonContent = const JsonEncoder.withIndent('  ').convert(exportData);
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/ironflow_nutrition_export.json');
    await file.writeAsString(jsonContent);
    
    return file.path;
  }

  /// Exports all user data to a comprehensive JSON backup.
  ///
  /// Returns the file path of the exported JSON file.
  Future<String> exportAllDataToJSON() async {
    final user = await _authRepository.getCurrentUser();
    final workouts = await _workoutRepository.getAllWorkouts();
    
    // Get nutrition data for the last year
    final endDate = DateTime.now();
    final startDate = DateTime(endDate.year - 1, endDate.month, endDate.day);
    final nutritionHistory = await _nutritionRepository.getNutritionHistory(startDate, endDate);
    final nutritionTargets = await _nutritionRepository.getNutritionTargets();
    
    final exportData = {
      'export_info': {
        'export_date': DateTime.now().toIso8601String(),
        'export_version': '1.0',
        'app_version': '1.0.0',
        'export_type': 'complete_backup',
      },
      'user_profile': user != null ? {
        'id': user.id,
        'email': user.email,
        'display_name': user.displayName,
        'photo_url': user.photoUrl,
        'created_at': user.createdAt.toIso8601String(),
        'updated_at': user.updatedAt.toIso8601String(),
      } : null,
      'statistics': {
        'total_workouts': workouts.length,
        'total_nutrition_days': nutritionHistory.length,
        'date_range': {
          'first_workout': workouts.isNotEmpty 
              ? workouts.map((w) => w.date).reduce((a, b) => a.isBefore(b) ? a : b).toIso8601String()
              : null,
          'last_workout': workouts.isNotEmpty
              ? workouts.map((w) => w.date).reduce((a, b) => a.isAfter(b) ? a : b).toIso8601String()
              : null,
          'total_volume_kg': workouts.fold<double>(0, (sum, w) => sum + w.totalVolume),
          'total_workout_time_minutes': workouts.fold<int>(0, (sum, w) => sum + w.duration.inMinutes),
        },
      },
      'workouts': workouts.map((workout) => {
        'id': workout.id,
        'date': workout.date.toIso8601String(),
        'duration_minutes': workout.duration.inMinutes,
        'total_volume_kg': workout.totalVolume,
        'exercises': workout.exercises.map((exercise) => {
          'id': exercise.id,
          'name': exercise.name,
          'type': exercise.type.toString(),
          'sets': exercise.sets.map((set) => {
            'id': set.id,
            'reps': set.reps,
            'weight_kg': set.weight,
            'rpe': set.rpe,
            'timestamp': set.timestamp.toIso8601String(),
          }).toList(),
        }).toList(),
      }).toList(),
      'nutrition_targets': nutritionTargets != null ? {
        'macros': {
          'calories': nutritionTargets.macros.calories,
          'protein': nutritionTargets.macros.protein,
          'carbs': nutritionTargets.macros.carbs,
          'fats': nutritionTargets.macros.fats,
        },
        'micros': {
          'fiber': nutritionTargets.micros.fiber,
          'sugar': nutritionTargets.micros.sugar,
          'sodium': nutritionTargets.micros.sodium,
          'potassium': nutritionTargets.micros.potassium,
        },
        'vitamins': {
          'vitamin_a': nutritionTargets.vitamins.vitaminA,
          'vitamin_b': nutritionTargets.vitamins.vitaminB,
          'vitamin_c': nutritionTargets.vitamins.vitaminC,
          'vitamin_d': nutritionTargets.vitamins.vitaminD,
          'vitamin_e': nutritionTargets.vitamins.vitaminE,
        },
        'minerals': {
          'calcium': nutritionTargets.minerals.calcium,
          'iron': nutritionTargets.minerals.iron,
          'magnesium': nutritionTargets.minerals.magnesium,
          'zinc': nutritionTargets.minerals.zinc,
        },
      } : null,
      'daily_nutrition': nutritionHistory.map((dailyNutrition) => {
        'date': dailyNutrition.date.toIso8601String(),
        'totals': {
          'calories': dailyNutrition.totalCalories,
          'protein': dailyNutrition.totalProtein,
          'carbs': dailyNutrition.totalCarbs,
          'fats': dailyNutrition.totalFats,
          'fiber': dailyNutrition.totalFiber,
          'sugar': dailyNutrition.totalSugar,
          'sodium': dailyNutrition.totalSodium,
          'potassium': dailyNutrition.totalPotassium,
          'vitamin_a': dailyNutrition.totalVitaminA,
          'vitamin_b': dailyNutrition.totalVitaminB,
          'vitamin_c': dailyNutrition.totalVitaminC,
          'vitamin_d': dailyNutrition.totalVitaminD,
          'vitamin_e': dailyNutrition.totalVitaminE,
          'calcium': dailyNutrition.totalCalcium,
          'iron': dailyNutrition.totalIron,
          'magnesium': dailyNutrition.totalMagnesium,
          'zinc': dailyNutrition.totalZinc,
        },
        'meals': dailyNutrition.meals.map((meal) => {
          'id': meal.id,
          'name': meal.name,
          'timestamp': meal.timestamp.toIso8601String(),
          'macros': {
            'calories': meal.macros.calories,
            'protein': meal.macros.protein,
            'carbs': meal.macros.carbs,
            'fats': meal.macros.fats,
          },
          'micros': {
            'fiber': meal.micros.fiber,
            'sugar': meal.micros.sugar,
            'sodium': meal.micros.sodium,
            'potassium': meal.micros.potassium,
          },
          'vitamins': {
            'vitamin_a': meal.vitamins.vitaminA,
            'vitamin_b': meal.vitamins.vitaminB,
            'vitamin_c': meal.vitamins.vitaminC,
            'vitamin_d': meal.vitamins.vitaminD,
            'vitamin_e': meal.vitamins.vitaminE,
          },
          'minerals': {
            'calcium': meal.minerals.calcium,
            'iron': meal.minerals.iron,
            'magnesium': meal.minerals.magnesium,
            'zinc': meal.minerals.zinc,
          },
        }).toList(),
      }).toList(),
    };
    
    final jsonContent = const JsonEncoder.withIndent('  ').convert(exportData);
    
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    final file = File('${directory.path}/ironflow_complete_backup_$timestamp.json');
    await file.writeAsString(jsonContent);
    
    return file.path;
  }

  /// Gets export statistics without actually exporting.
  ///
  /// Returns a map with counts of each data type.
  Future<Map<String, int>> getExportStatistics() async {
    final workouts = await _workoutRepository.getAllWorkouts();
    
    // Get nutrition data for the last year
    final endDate = DateTime.now();
    final startDate = DateTime(endDate.year - 1, endDate.month, endDate.day);
    final nutritionHistory = await _nutritionRepository.getNutritionHistory(startDate, endDate);
    
    return {
      'workouts': workouts.length,
      'nutrition_days': nutritionHistory.length,
      'total_meals': nutritionHistory.fold<int>(0, (sum, day) => sum + day.meals.length),
      'total_exercises': workouts.fold<int>(0, (sum, workout) => sum + workout.exercises.length),
      'total_sets': workouts.fold<int>(0, (sum, workout) => 
          sum + workout.exercises.fold<int>(0, (exerciseSum, exercise) => exerciseSum + exercise.sets.length)),
    };
  }
}