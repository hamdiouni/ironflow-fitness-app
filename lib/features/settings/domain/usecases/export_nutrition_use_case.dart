import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';

/// Use case for exporting nutrition data to various formats.
class ExportNutritionUseCase {
  final NutritionRepository _nutritionRepository;

  ExportNutritionUseCase(this._nutritionRepository);

  Future<List<DailyNutritionSummary>> _getAllNutritionLogs() {
    return _nutritionRepository.getNutritionHistory(
      DateTime(2000),
      DateTime.now().add(const Duration(days: 1)),
    );
  }

  /// Exports all nutrition logs to CSV format.
  ///
  /// Returns the file path of the exported CSV file.
  Future<String> exportToCSV() async {
    final nutritionLogs = await _getAllNutritionLogs();
    final csvContent = _generateCSV(nutritionLogs);
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/nutrition_export.csv');
    await file.writeAsString(csvContent);
    
    return file.path;
  }

  /// Exports all nutrition logs to JSON format.
  ///
  /// Returns the file path of the exported JSON file.
  Future<String> exportToJSON() async {
    final nutritionLogs = await _getAllNutritionLogs();
    final jsonContent = _generateJSON(nutritionLogs);
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/nutrition_export.json');
    await file.writeAsString(jsonContent);
    
    return file.path;
  }

  /// Exports nutrition logs within a date range to CSV.
  ///
  /// [startDate] - Start date for export range
  /// [endDate] - End date for export range
  ///
  /// Returns the file path of the exported CSV file.
  Future<String> exportDateRangeToCSV(DateTime startDate, DateTime endDate) async {
    final nutritionLogs = await _nutritionRepository.getNutritionHistory(
      startDate,
      endDate,
    );
    final csvContent = _generateCSV(nutritionLogs);
    
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'nutrition_${_formatDateForFilename(startDate)}_to_${_formatDateForFilename(endDate)}.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csvContent);
    
    return file.path;
  }

  /// Exports nutrition logs within a date range to JSON.
  ///
  /// [startDate] - Start date for export range
  /// [endDate] - End date for export range
  ///
  /// Returns the file path of the exported JSON file.
  Future<String> exportDateRangeToJSON(DateTime startDate, DateTime endDate) async {
    final nutritionLogs = await _nutritionRepository.getNutritionHistory(
      startDate,
      endDate,
    );
    final jsonContent = _generateJSON(nutritionLogs);
    
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'nutrition_${_formatDateForFilename(startDate)}_to_${_formatDateForFilename(endDate)}.json';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(jsonContent);
    
    return file.path;
  }

  /// Exports nutrition summary statistics to CSV.
  ///
  /// Returns the file path of the exported summary CSV file.
  Future<String> exportSummaryToCSV() async {
    final nutritionLogs = await _getAllNutritionLogs();
    final summaryContent = _generateSummaryCSV(nutritionLogs);
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/nutrition_summary.csv');
    await file.writeAsString(summaryContent);
    
    return file.path;
  }

  /// Exports macro trends to CSV for analysis.
  ///
  /// Returns the file path of the exported trends CSV file.
  Future<String> exportMacroTrendsToCSV() async {
    final nutritionLogs = await _getAllNutritionLogs();
    final trendsContent = _generateMacroTrendsCSV(nutritionLogs);
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/macro_trends.csv');
    await file.writeAsString(trendsContent);
    
    return file.path;
  }

  String _generateCSV(List<DailyNutritionSummary> nutritionLogs) {
    final buffer = StringBuffer();
    
    // CSV Header
    buffer.writeln('Date,Food,Quantity,Unit,Calories,Protein,Carbs,Fats,Fiber,Sugar,Sodium,Potassium,Vitamin A,Vitamin B,Vitamin C,Vitamin D,Vitamin E,Calcium,Iron,Magnesium,Zinc,Meal Type,Timestamp');
    
    // CSV Data
    for (final dailyLog in nutritionLogs) {
      final date = dailyLog.date.toIso8601String().split('T')[0];
      
      for (final meal in dailyLog.meals) {
        final foodName = meal.name.replaceAll(',', ';');
        const quantity = '';
        const unit = '';
        final calories = meal.macros.calories.toStringAsFixed(2);
        final protein = meal.macros.protein.toStringAsFixed(2);
        final carbs = meal.macros.carbs.toStringAsFixed(2);
        final fats = meal.macros.fats.toStringAsFixed(2);
        final fiber = meal.micros.fiber.toStringAsFixed(2);
        final sugar = meal.micros.sugar.toStringAsFixed(2);
        final sodium = meal.micros.sodium.toStringAsFixed(2);
        final potassium = meal.micros.potassium.toStringAsFixed(2);
        final vitaminA = meal.vitamins.vitaminA.toStringAsFixed(2);
        final vitaminB = meal.vitamins.vitaminB.toStringAsFixed(2);
        final vitaminC = meal.vitamins.vitaminC.toStringAsFixed(2);
        final vitaminD = meal.vitamins.vitaminD.toStringAsFixed(2);
        final vitaminE = meal.vitamins.vitaminE.toStringAsFixed(2);
        final calcium = meal.minerals.calcium.toStringAsFixed(2);
        final iron = meal.minerals.iron.toStringAsFixed(2);
        final magnesium = meal.minerals.magnesium.toStringAsFixed(2);
        final zinc = meal.minerals.zinc.toStringAsFixed(2);
        const mealType = '';
        final timestamp = meal.timestamp.toIso8601String();
        
        buffer.writeln('$date,$foodName,$quantity,$unit,$calories,$protein,$carbs,$fats,$fiber,$sugar,$sodium,$potassium,$vitaminA,$vitaminB,$vitaminC,$vitaminD,$vitaminE,$calcium,$iron,$magnesium,$zinc,$mealType,$timestamp');
      }
    }
    
    return buffer.toString();
  }

  String _generateJSON(List<DailyNutritionSummary> nutritionLogs) {
    final exportData = {
      'export_date': DateTime.now().toIso8601String(),
      'export_version': '1.0',
      'total_days': nutritionLogs.length,
      'nutrition_logs': nutritionLogs.map((dailyLog) => {
        'date': dailyLog.date.toIso8601String(),
        'total_calories': dailyLog.totalCalories,
        'total_protein': dailyLog.totalProtein,
        'total_carbs': dailyLog.totalCarbs,
        'total_fats': dailyLog.totalFats,
        'total_fiber': dailyLog.totalFiber,
        'total_sugar': dailyLog.totalSugar,
        'total_sodium': dailyLog.totalSodium,
        'total_potassium': dailyLog.totalPotassium,
        'meals': dailyLog.meals.map((meal) => {
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
    
    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  String _generateSummaryCSV(List<DailyNutritionSummary> nutritionLogs) {
    final buffer = StringBuffer();
    
    // Calculate summary statistics
    final totalDays = nutritionLogs.length;
    final averageCalories = totalDays > 0 ? nutritionLogs.fold<double>(0, (sum, log) => sum + log.totalCalories) / totalDays : 0.0;
    final averageProtein = totalDays > 0 ? nutritionLogs.fold<double>(0, (sum, log) => sum + log.totalProtein) / totalDays : 0.0;
    final averageCarbs = totalDays > 0 ? nutritionLogs.fold<double>(0, (sum, log) => sum + log.totalCarbs) / totalDays : 0.0;
    final averageFats = totalDays > 0 ? nutritionLogs.fold<double>(0, (sum, log) => sum + log.totalFats) / totalDays : 0.0;
    
    // Food frequency
    final foodFrequency = <String, int>{};
    for (final dailyLog in nutritionLogs) {
      for (final meal in dailyLog.meals) {
        final foodName = meal.name;
        foodFrequency[foodName] = (foodFrequency[foodName] ?? 0) + 1;
      }
    }
    
    // Monthly breakdown
    final monthlyBreakdown = <String, Map<String, double>>{};
    for (final dailyLog in nutritionLogs) {
      final monthKey = '${dailyLog.date.year}-${dailyLog.date.month.toString().padLeft(2, '0')}';
      if (!monthlyBreakdown.containsKey(monthKey)) {
        monthlyBreakdown[monthKey] = {'calories': 0, 'protein': 0, 'carbs': 0, 'fats': 0, 'days': 0};
      }
      monthlyBreakdown[monthKey]!['calories'] = (monthlyBreakdown[monthKey]!['calories']! + dailyLog.totalCalories);
      monthlyBreakdown[monthKey]!['protein'] = (monthlyBreakdown[monthKey]!['protein']! + dailyLog.totalProtein);
      monthlyBreakdown[monthKey]!['carbs'] = (monthlyBreakdown[monthKey]!['carbs']! + dailyLog.totalCarbs);
      monthlyBreakdown[monthKey]!['fats'] = (monthlyBreakdown[monthKey]!['fats']! + dailyLog.totalFats);
      monthlyBreakdown[monthKey]!['days'] = monthlyBreakdown[monthKey]!['days']! + 1;
    }
    
    // CSV Header and Summary
    buffer.writeln('Nutrition Summary Report');
    buffer.writeln('Generated on,${DateTime.now().toIso8601String().split('T')[0]}');
    buffer.writeln('');
    buffer.writeln('Overall Statistics');
    buffer.writeln('Total Days Logged,$totalDays');
    buffer.writeln('Average Calories,${averageCalories.toStringAsFixed(1)}');
    buffer.writeln('Average Protein,${averageProtein.toStringAsFixed(1)}g');
    buffer.writeln('Average Carbs,${averageCarbs.toStringAsFixed(1)}g');
    buffer.writeln('Average Fats,${averageFats.toStringAsFixed(1)}g');
    buffer.writeln('');
    
    // Food Frequency
    buffer.writeln('Most Logged Foods');
    buffer.writeln('Food,Count');
    final sortedFoods = foodFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (int i = 0; i < sortedFoods.length && i < 20; i++) {
      final entry = sortedFoods[i];
      buffer.writeln('${entry.key},${entry.value}');
    }
    buffer.writeln('');
    
    // Monthly Averages
    buffer.writeln('Monthly Averages');
    buffer.writeln('Month,Avg Calories,Avg Protein,Avg Carbs,Avg Fats,Days Logged');
    final sortedMonths = monthlyBreakdown.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    for (final entry in sortedMonths) {
      final month = entry.key;
      final data = entry.value;
      final days = data['days']!;
      final avgCalories = (data['calories']! / days).toStringAsFixed(1);
      final avgProtein = (data['protein']! / days).toStringAsFixed(1);
      final avgCarbs = (data['carbs']! / days).toStringAsFixed(1);
      final avgFats = (data['fats']! / days).toStringAsFixed(1);
      buffer.writeln('$month,$avgCalories,$avgProtein,$avgCarbs,$avgFats,${days.toInt()}');
    }
    
    return buffer.toString();
  }

  String _generateMacroTrendsCSV(List<DailyNutritionSummary> nutritionLogs) {
    final buffer = StringBuffer();
    
    // Sort by date
    final sortedLogs = List<DailyNutritionSummary>.from(nutritionLogs)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // CSV Header
    buffer.writeln('Date,Calories,Protein,Carbs,Fats,Fiber,Sugar,Sodium,Potassium');
    
    // CSV Data
    for (final dailyLog in sortedLogs) {
      final date = dailyLog.date.toIso8601String().split('T')[0];
      final calories = dailyLog.totalCalories.toStringAsFixed(1);
      final protein = dailyLog.totalProtein.toStringAsFixed(1);
      final carbs = dailyLog.totalCarbs.toStringAsFixed(1);
      final fats = dailyLog.totalFats.toStringAsFixed(1);
      final fiber = dailyLog.totalFiber.toStringAsFixed(1);
      final sugar = dailyLog.totalSugar.toStringAsFixed(1);
      final sodium = dailyLog.totalSodium.toStringAsFixed(1);
      final potassium = dailyLog.totalPotassium.toStringAsFixed(1);
      
      buffer.writeln('$date,$calories,$protein,$carbs,$fats,$fiber,$sugar,$sodium,$potassium');
    }
    
    return buffer.toString();
  }

  String _formatDateForFilename(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }
}