import 'dart:convert';
import 'dart:io';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:progression_tracker/features/workout/domain/entities/active_program.dart';

/// Result of a program import operation.
class ImportResult {
  final bool success;
  final String message;
  final String? programId;
  final List<String> errors;
  final List<String> warnings;

  const ImportResult({
    required this.success,
    required this.message,
    this.programId,
    required this.errors,
    required this.warnings,
  });

  factory ImportResult.success(String programId, [List<String>? warnings]) => ImportResult(
    success: true,
    message: 'Program imported successfully',
    programId: programId,
    errors: [],
    warnings: warnings ?? [],
  );

  factory ImportResult.failure(String message, [List<String>? errors]) => ImportResult(
    success: false,
    message: message,
    errors: errors ?? [],
    warnings: [],
  );
}

/// Supported program import formats.
enum ImportFormat {
  ironflowJson,
  strongAppCsv,
  jefit,
  genericJson,
}

/// Use case for importing workout programs from various formats.
class ImportProgramUseCase {
  final WorkoutRepository _workoutRepository;

  ImportProgramUseCase(this._workoutRepository);

  /// Imports a program from a JSON file.
  ///
  /// [filePath] - Path to the JSON file
  /// [setAsActive] - Whether to set the imported program as active (default: false)
  ///
  /// Returns an ImportResult with success status and details.
  Future<ImportResult> importFromJsonFile(
    String filePath, {
    bool setAsActive = false,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ImportResult.failure('File not found: $filePath');
      }

      final jsonContent = await file.readAsString();
      return await importFromJsonString(jsonContent, setAsActive: setAsActive);
    } catch (e) {
      return ImportResult.failure('Failed to read file: $e');
    }
  }

  /// Imports a program from a JSON string.
  ///
  /// [jsonData] - JSON string containing program data
  /// [setAsActive] - Whether to set the imported program as active (default: false)
  ///
  /// Returns an ImportResult with success status and details.
  Future<ImportResult> importFromJsonString(
    String jsonData, {
    bool setAsActive = false,
  }) async {
    try {
      final programData = jsonDecode(jsonData) as Map<String, dynamic>;
      
      // Detect format and validate
      final format = _detectFormat(programData);
      final validationResult = _validateProgramData(programData, format);
      
      if (!validationResult.success) {
        return validationResult;
      }

      // Convert to ActiveProgram
      final program = _convertToActiveProgram(programData, format);
      
      // Save program
      final savedProgram = await _workoutRepository.saveProgram(program);
      
      // Set as active if requested
      if (setAsActive) {
        await _workoutRepository.setActiveProgram(savedProgram.id);
      }

      return ImportResult.success(
        savedProgram.id,
        validationResult.warnings,
      );
    } catch (e) {
      return ImportResult.failure('Failed to import program: $e');
    }
  }

  /// Imports a program from a CSV file (Strong app format).
  ///
  /// [filePath] - Path to the CSV file
  /// [programName] - Name for the imported program
  /// [setAsActive] - Whether to set the imported program as active (default: false)
  ///
  /// Returns an ImportResult with success status and details.
  Future<ImportResult> importFromCsvFile(
    String filePath,
    String programName, {
    bool setAsActive = false,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ImportResult.failure('File not found: $filePath');
      }

      final csvContent = await file.readAsString();
      return await importFromCsvString(csvContent, programName, setAsActive: setAsActive);
    } catch (e) {
      return ImportResult.failure('Failed to read CSV file: $e');
    }
  }

  /// Imports a program from a CSV string (Strong app format).
  ///
  /// [csvData] - CSV string containing program data
  /// [programName] - Name for the imported program
  /// [setAsActive] - Whether to set the imported program as active (default: false)
  ///
  /// Returns an ImportResult with success status and details.
  Future<ImportResult> importFromCsvString(
    String csvData,
    String programName, {
    bool setAsActive = false,
  }) async {
    try {
      final program = _convertCsvToProgram(csvData, programName);
      
      // Save program
      final savedProgram = await _workoutRepository.saveProgram(program);
      
      // Set as active if requested
      if (setAsActive) {
        await _workoutRepository.setActiveProgram(savedProgram.id);
      }

      return ImportResult.success(savedProgram.id);
    } catch (e) {
      return ImportResult.failure('Failed to import CSV program: $e');
    }
  }

  /// Gets a preview of what would be imported from a file.
  ///
  /// [filePath] - Path to the program file
  ///
  /// Returns a map with program details that would be imported.
  Future<Map<String, dynamic>> getImportPreview(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      final content = await file.readAsString();
      
      // Try to parse as JSON first
      try {
        final programData = jsonDecode(content) as Map<String, dynamic>;
        return _generateJsonPreview(programData);
      } catch (e) {
        // If JSON parsing fails, try CSV
        return _generateCsvPreview(content);
      }
    } catch (e) {
      throw Exception('Failed to preview file: $e');
    }
  }

  /// Validates a program file without importing it.
  ///
  /// [filePath] - Path to the program file
  ///
  /// Returns an ImportResult indicating validation success or failure.
  Future<ImportResult> validateProgramFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return ImportResult.failure('File not found: $filePath');
      }

      final content = await file.readAsString();
      
      // Try to parse as JSON first
      try {
        final programData = jsonDecode(content) as Map<String, dynamic>;
        final format = _detectFormat(programData);
        return _validateProgramData(programData, format);
      } catch (e) {
        // If JSON parsing fails, try CSV validation
        return _validateCsvData(content);
      }
    } catch (e) {
      return ImportResult.failure('Failed to validate file: $e');
    }
  }

  ImportFormat _detectFormat(Map<String, dynamic> data) {
    // Check for IronFlow format
    if (data.containsKey('export_info') || data.containsKey('ironflow_version')) {
      return ImportFormat.ironflowJson;
    }
    
    // Check for Jefit format
    if (data.containsKey('jefit_program') || data.containsKey('workout_plan')) {
      return ImportFormat.jefit;
    }
    
    // Default to generic JSON
    return ImportFormat.genericJson;
  }

  ImportResult _validateProgramData(Map<String, dynamic> data, ImportFormat format) {
    final errors = <String>[];
    final warnings = <String>[];

    switch (format) {
      case ImportFormat.ironflowJson:
        return _validateIronFlowFormat(data);
      case ImportFormat.jefit:
        return _validateJefitFormat(data);
      case ImportFormat.genericJson:
        return _validateGenericFormat(data);
      case ImportFormat.strongAppCsv:
        // CSV validation is handled separately
        break;
    }

    if (errors.isNotEmpty) {
      return ImportResult.failure('Validation failed', errors);
    }

    return ImportResult.success('', warnings);
  }

  ImportResult _validateIronFlowFormat(Map<String, dynamic> data) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check required fields
    if (!data.containsKey('name')) {
      errors.add('Missing program name');
    }

    if (!data.containsKey('days') && !data.containsKey('workouts')) {
      errors.add('Missing workout days/workouts');
    }

    // Validate days structure
    if (data.containsKey('days')) {
      final days = data['days'];
      if (days is! Map) {
        errors.add('Days must be a map/object');
      } else {
        for (final dayEntry in days.entries) {
          final dayData = dayEntry.value;
          if (dayData is! Map || !dayData.containsKey('exercises')) {
            errors.add('Day ${dayEntry.key} missing exercises');
          }
        }
      }
    }

    if (errors.isNotEmpty) {
      return ImportResult.failure('IronFlow format validation failed', errors);
    }

    return ImportResult.success('', warnings);
  }

  ImportResult _validateJefitFormat(Map<String, dynamic> data) {
    final errors = <String>[];
    final warnings = <String>[];

    // Add Jefit-specific validation logic here
    warnings.add('Jefit format support is experimental');

    if (errors.isNotEmpty) {
      return ImportResult.failure('Jefit format validation failed', errors);
    }

    return ImportResult.success('', warnings);
  }

  ImportResult _validateGenericFormat(Map<String, dynamic> data) {
    final errors = <String>[];
    final warnings = <String>[];

    // Basic validation for generic JSON format
    if (!data.containsKey('name') && !data.containsKey('title')) {
      warnings.add('No program name found, will use default name');
    }

    warnings.add('Generic format detected, some features may not be imported correctly');

    if (errors.isNotEmpty) {
      return ImportResult.failure('Generic format validation failed', errors);
    }

    return ImportResult.success('', warnings);
  }

  ImportResult _validateCsvData(String csvData) {
    final errors = <String>[];
    final warnings = <String>[];

    final lines = csvData.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    if (lines.isEmpty) {
      errors.add('CSV file is empty');
    } else if (lines.length < 2) {
      errors.add('CSV file must have at least a header and one data row');
    }

    // Check for common CSV headers
    final header = lines.first.toLowerCase();
    if (!header.contains('exercise') && !header.contains('workout')) {
      warnings.add('CSV format may not be supported, expected exercise or workout columns');
    }

    if (errors.isNotEmpty) {
      return ImportResult.failure('CSV validation failed', errors);
    }

    return ImportResult.success('', warnings);
  }

  ActiveProgram _convertToActiveProgram(Map<String, dynamic> data, ImportFormat format) {
    switch (format) {
      case ImportFormat.ironflowJson:
        return _convertIronFlowFormat(data);
      case ImportFormat.jefit:
        return _convertJefitFormat(data);
      case ImportFormat.genericJson:
        return _convertGenericFormat(data);
      case ImportFormat.strongAppCsv:
        throw Exception('CSV conversion should use _convertCsvToProgram');
    }
  }

  ActiveProgram _convertIronFlowFormat(Map<String, dynamic> data) {
    // TODO: Implement conversion from IronFlow JSON format to ActiveProgram
    // This would parse the specific structure of IronFlow exports
    throw UnimplementedError('IronFlow format conversion not implemented');
  }

  ActiveProgram _convertJefitFormat(Map<String, dynamic> data) {
    // TODO: Implement conversion from Jefit format to ActiveProgram
    throw UnimplementedError('Jefit format conversion not implemented');
  }

  ActiveProgram _convertGenericFormat(Map<String, dynamic> data) {
    // TODO: Implement conversion from generic JSON format to ActiveProgram
    throw UnimplementedError('Generic format conversion not implemented');
  }

  ActiveProgram _convertCsvToProgram(String csvData, String programName) {
    // TODO: Implement conversion from CSV (Strong app format) to ActiveProgram
    throw UnimplementedError('CSV conversion not implemented');
  }

  Map<String, dynamic> _generateJsonPreview(Map<String, dynamic> data) {
    final preview = <String, dynamic>{};
    
    preview['name'] = data['name'] ?? data['title'] ?? 'Unknown Program';
    preview['format'] = _detectFormat(data).toString();
    
    // Count exercises and days
    int exerciseCount = 0;
    int dayCount = 0;
    
    if (data.containsKey('days')) {
      final days = data['days'] as Map<String, dynamic>?;
      if (days != null) {
        dayCount = days.length;
        for (final dayData in days.values) {
          if (dayData is Map && dayData.containsKey('exercises')) {
            final exercises = dayData['exercises'];
            if (exercises is Map) {
              exerciseCount += exercises.length;
            } else if (exercises is List) {
              exerciseCount += exercises.length;
            }
          }
        }
      }
    }
    
    preview['day_count'] = dayCount;
    preview['exercise_count'] = exerciseCount;
    
    return preview;
  }

  Map<String, dynamic> _generateCsvPreview(String csvData) {
    final lines = csvData.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    return {
      'name': 'Imported CSV Program',
      'format': 'CSV',
      'row_count': lines.length - 1, // Exclude header
      'estimated_exercises': (lines.length - 1) ~/ 3, // Rough estimate
    };
  }
}