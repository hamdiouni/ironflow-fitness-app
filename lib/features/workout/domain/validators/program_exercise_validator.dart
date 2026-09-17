import '../../../../core/error/exceptions.dart';
import '../exceptions/workout_exceptions.dart';

/// Validator for program exercise parameters
class ProgramExerciseValidator {
  /// Validates exercise parameters for a workout program
  /// 
  /// Throws [ProgramValidationException] if validation fails
  static void validate({
    required int sets,
    required String reps,
    required int restSeconds,
  }) {
    // Validate sets (must be positive integer)
    if (sets <= 0) {
      throw ProgramValidationException(
        message: 'Sets must be positive',
        fieldName: 'sets',
        invalidValue: sets,
      );
    }
    
    // Validate rest seconds (must be non-negative integer)
    if (restSeconds < 0) {
      throw ProgramValidationException(
        message: 'Rest seconds cannot be negative',
        fieldName: 'restSeconds',
        invalidValue: restSeconds,
      );
    }
    
    // Validate reps format (e.g., "8-12" or "15")
    if (!_isValidRepsFormat(reps)) {
      throw ProgramValidationException(
        message: 'Invalid reps format',
        fieldName: 'reps',
        invalidValue: reps,
      );
    }
  }
  
  /// Checks if the reps format is valid
  /// 
  /// Valid formats:
  /// - Single positive integer: "15"
  /// - Range format: "8-12" (start must be less than end)
  static bool _isValidRepsFormat(String reps) {
    // Single number (must be positive)
    final singleNumber = int.tryParse(reps);
    if (singleNumber != null) {
      return singleNumber > 0;
    }
    
    // Range format (e.g., "8-12")
    final parts = reps.split('-');
    if (parts.length == 2) {
      final start = int.tryParse(parts[0]);
      final end = int.tryParse(parts[1]);
      return start != null && end != null && start > 0 && end > 0 && start < end;
    }
    
    return false;
  }
}
