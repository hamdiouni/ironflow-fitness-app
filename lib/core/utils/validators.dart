/// Validation utilities for entity data
library;

/// Utility class for validating entity data
class Validators {
  /// Validates that weight is non-negative (0 is valid for bodyweight exercises)
  static bool isValidWeight(double weight) {
    return weight >= 0;
  }

  /// Validates that reps is a positive integer
  static bool isValidReps(int reps) {
    return reps > 0;
  }

  /// Validates that RPE is within 1-10 range
  static bool isValidRPE(int? rpe) {
    if (rpe == null) return true;
    return rpe >= 1 && rpe <= 10;
  }

  /// Validates that macro value is non-negative
  static bool isValidMacro(double macro) {
    return macro >= 0;
  }

  /// Validates that calories is non-negative
  static bool isValidCalories(double calories) {
    return calories >= 0;
  }

  /// Validates that a string is not empty
  static bool isNotEmpty(String value) {
    return value.trim().isNotEmpty;
  }

  /// Validates that a measurement value is positive
  static bool isValidMeasurement(double measurement) {
    return measurement > 0;
  }
}
