/// Utility class for macro calculations and scaling
/// 
/// Provides methods for:
/// - Scaling macros from per-100g to actual grams
/// - Validating macro values
/// - Calculating macro percentages
class MacroCalculator {
  // Private constructor to prevent instantiation
  MacroCalculator._();
  
  // ---------------------------------------------------------------------------
  // Scaling Methods
  // ---------------------------------------------------------------------------
  
  /// Scale macros from per-100g to actual grams
  /// 
  /// Example:
  /// - Food: 100 kcal per 100g, 10g protein per 100g
  /// - User enters: 200g
  /// - Result: 200 kcal, 20g protein
  /// 
  /// Formula: actualValue = valuePer100g * (grams / 100)
  static ({
    double calories,
    double protein,
    double carbs,
    double fats,
  }) scaleMacros({
    required double caloriesPer100g,
    required double proteinPer100g,
    required double carbsPer100g,
    required double fatsPer100g,
    required double grams,
  }) {
    // Calculate scaling factor
    final factor = grams / 100.0;
    
    return (
      calories: caloriesPer100g * factor,
      protein: proteinPer100g * factor,
      carbs: carbsPer100g * factor,
      fats: fatsPer100g * factor,
    );
  }
  
  /// Scale a single macro value from per-100g to actual grams
  /// 
  /// Example:
  /// - Value per 100g: 10g
  /// - Actual grams: 200g
  /// - Result: 20g
  static double scaleSingleMacro({
    required double valuePer100g,
    required double grams,
  }) {
    return valuePer100g * (grams / 100.0);
  }
  
  /// Calculate per-100g value from actual grams
  /// 
  /// Example:
  /// - Actual value: 20g
  /// - Actual grams: 200g
  /// - Result: 10g per 100g
  static double calculatePer100g({
    required double actualValue,
    required double actualGrams,
  }) {
    if (actualGrams == 0) return 0;
    return actualValue * (100.0 / actualGrams);
  }
  
  // ---------------------------------------------------------------------------
  // Validation Methods
  // ---------------------------------------------------------------------------
  
  /// Validate macro values
  /// 
  /// Checks that all values are:
  /// - Not negative
  /// - Not NaN
  /// - Not infinite
  static bool isValid({
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
  }) {
    return _isValidNumber(calories) &&
           _isValidNumber(protein) &&
           _isValidNumber(carbs) &&
           _isValidNumber(fats) &&
           calories >= 0 &&
           protein >= 0 &&
           carbs >= 0 &&
           fats >= 0;
  }
  
  /// Validate a single macro value
  static bool isValidSingleMacro(double value) {
    return _isValidNumber(value) && value >= 0;
  }
  
  /// Check if a number is valid (not NaN, not infinite)
  static bool _isValidNumber(double value) {
    return !value.isNaN && !value.isInfinite;
  }
  
  // ---------------------------------------------------------------------------
  // Calculation Methods
  // ---------------------------------------------------------------------------
  
  /// Calculate calories from macros
  /// 
  /// Formula:
  /// - Protein: 4 kcal/g
  /// - Carbs: 4 kcal/g
  /// - Fats: 9 kcal/g
  static double calculateCaloriesFromMacros({
    required double protein,
    required double carbs,
    required double fats,
  }) {
    return (protein * 4) + (carbs * 4) + (fats * 9);
  }
  
  /// Calculate macro percentages
  /// 
  /// Returns percentage of each macro relative to total calories
  static ({
    double proteinPercent,
    double carbsPercent,
    double fatsPercent,
  }) calculateMacroPercentages({
    required double protein,
    required double carbs,
    required double fats,
  }) {
    final totalCalories = calculateCaloriesFromMacros(
      protein: protein,
      carbs: carbs,
      fats: fats,
    );
    
    if (totalCalories == 0) {
      return (
        proteinPercent: 0.0,
        carbsPercent: 0.0,
        fatsPercent: 0.0,
      );
    }
    
    return (
      proteinPercent: ((protein * 4) / totalCalories) * 100,
      carbsPercent: ((carbs * 4) / totalCalories) * 100,
      fatsPercent: ((fats * 9) / totalCalories) * 100,
    );
  }
  
  /// Calculate remaining macros
  /// 
  /// Returns how much is left to reach targets
  static ({
    double calories,
    double protein,
    double carbs,
    double fats,
  }) calculateRemaining({
    required double targetCalories,
    required double targetProtein,
    required double targetCarbs,
    required double targetFats,
    required double consumedCalories,
    required double consumedProtein,
    required double consumedCarbs,
    required double consumedFats,
  }) {
    return (
      calories: targetCalories - consumedCalories,
      protein: targetProtein - consumedProtein,
      carbs: targetCarbs - consumedCarbs,
      fats: targetFats - consumedFats,
    );
  }
  
  /// Calculate progress (0.0 to 1.0+)
  /// 
  /// Returns how much of the target has been consumed
  /// Values > 1.0 indicate over-consumption
  static ({
    double calories,
    double protein,
    double carbs,
    double fats,
  }) calculateProgress({
    required double targetCalories,
    required double targetProtein,
    required double targetCarbs,
    required double targetFats,
    required double consumedCalories,
    required double consumedProtein,
    required double consumedCarbs,
    required double consumedFats,
  }) {
    return (
      calories: targetCalories > 0 ? consumedCalories / targetCalories : 0.0,
      protein: targetProtein > 0 ? consumedProtein / targetProtein : 0.0,
      carbs: targetCarbs > 0 ? consumedCarbs / targetCarbs : 0.0,
      fats: targetFats > 0 ? consumedFats / targetFats : 0.0,
    );
  }
  
  // ---------------------------------------------------------------------------
  // Rounding Methods
  // ---------------------------------------------------------------------------
  
  /// Round macros to specified decimal places
  static ({
    double calories,
    double protein,
    double carbs,
    double fats,
  }) roundMacros({
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
    int decimalPlaces = 1,
  }) {
    final factor = _pow10(decimalPlaces);
    
    return (
      calories: _roundToFactor(calories, factor),
      protein: _roundToFactor(protein, factor),
      carbs: _roundToFactor(carbs, factor),
      fats: _roundToFactor(fats, factor),
    );
  }
  
  /// Round a single value to specified decimal places
  static double roundSingleMacro(double value, {int decimalPlaces = 1}) {
    final factor = _pow10(decimalPlaces);
    return _roundToFactor(value, factor);
  }
  
  /// Helper: Calculate 10^n
  static double _pow10(int n) {
    double result = 1.0;
    for (int i = 0; i < n; i++) {
      result *= 10.0;
    }
    return result;
  }
  
  /// Helper: Round to factor
  static double _roundToFactor(double value, double factor) {
    return (value * factor).roundToDouble() / factor;
  }
  
  // ---------------------------------------------------------------------------
  // Comparison Methods
  // ---------------------------------------------------------------------------
  
  /// Check if macros are within tolerance of target
  /// 
  /// Tolerance is a percentage (e.g., 0.1 = 10%)
  static bool isWithinTolerance({
    required double target,
    required double actual,
    required double tolerance,
  }) {
    if (target == 0) return actual == 0;
    
    final difference = (actual - target).abs();
    final allowedDifference = target * tolerance;
    
    return difference <= allowedDifference;
  }
  
  /// Check if all macros are within tolerance of targets
  static bool areAllMacrosWithinTolerance({
    required double targetCalories,
    required double targetProtein,
    required double targetCarbs,
    required double targetFats,
    required double actualCalories,
    required double actualProtein,
    required double actualCarbs,
    required double actualFats,
    required double tolerance,
  }) {
    return isWithinTolerance(
             target: targetCalories,
             actual: actualCalories,
             tolerance: tolerance,
           ) &&
           isWithinTolerance(
             target: targetProtein,
             actual: actualProtein,
             tolerance: tolerance,
           ) &&
           isWithinTolerance(
             target: targetCarbs,
             actual: actualCarbs,
             tolerance: tolerance,
           ) &&
           isWithinTolerance(
             target: targetFats,
             actual: actualFats,
             tolerance: tolerance,
           );
  }
}
