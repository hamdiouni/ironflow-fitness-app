import '../error/exceptions.dart';

/// Utility class for validating data before saving to storage.
class DataValidator {
  /// Validates a workout before saving.
  static void validateWorkout({
    required String name,
    required List<Map<String, dynamic>> exercises,
    required double totalVolume,
    required Duration duration,
  }) {
    if (name.isEmpty) {
      throw ValidationException('Workout name cannot be empty');
    }

    if (exercises.isEmpty) {
      throw ValidationException('Workout must have at least one exercise');
    }

    if (totalVolume < 0) {
      throw ValidationException('Total volume cannot be negative');
    }

    if (duration.inSeconds <= 0) {
      throw ValidationException('Workout duration must be greater than 0');
    }

    // Validate each exercise
    for (final exercise in exercises) {
      _validateExercise(exercise);
    }
  }

  /// Validates an exercise.
  static void _validateExercise(Map<String, dynamic> exercise) {
    final name = exercise['name'] as String?;
    final sets = exercise['sets'] as int?;
    final reps = exercise['reps'] as dynamic;
    final weight = exercise['weight'] as double?;

    if (name == null || name.isEmpty) {
      throw ValidationException('Exercise name cannot be empty');
    }

    if (sets == null || sets <= 0) {
      throw ValidationException('Sets must be greater than 0');
    }

    if (reps == null) {
      throw ValidationException('Reps cannot be empty');
    }

    if (weight == null || weight < 0 || weight > 500) {
      throw ValidationException('Weight must be between 0 and 500 kg');
    }
  }

  /// Validates a diet plan before saving.
  static void validateDietPlan({
    required String name,
    required double targetCalories,
    required double targetProtein,
    required double targetCarbs,
    required double targetFat,
  }) {
    if (name.isEmpty) {
      throw ValidationException('Diet plan name cannot be empty');
    }

    if (targetCalories <= 0 || targetCalories > 10000) {
      throw ValidationException('Target calories must be between 1 and 10,000');
    }

    if (targetProtein < 0 || targetProtein > 500) {
      throw ValidationException('Target protein must be between 0 and 500g');
    }

    if (targetCarbs < 0 || targetCarbs > 500) {
      throw ValidationException('Target carbs must be between 0 and 500g');
    }

    if (targetFat < 0 || targetFat > 500) {
      throw ValidationException('Target fat must be between 0 and 500g');
    }
  }

  /// Validates a user profile before saving.
  static void validateUserProfile({
    required String name,
    required int age,
    required double height,
    required double weight,
    required String goal,
  }) {
    if (name.isEmpty || name.length < 2) {
      throw ValidationException('Name must be at least 2 characters');
    }

    if (age < 13 || age > 120) {
      throw ValidationException('Age must be between 13 and 120');
    }

    if (height < 100 || height > 250) {
      throw ValidationException('Height must be between 100 and 250 cm');
    }

    if (weight < 30 || weight > 300) {
      throw ValidationException('Weight must be between 30 and 300 kg');
    }

    if (goal.isEmpty) {
      throw ValidationException('Fitness goal cannot be empty');
    }
  }

  /// Validates a food item before saving.
  static void validateFoodItem({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) {
    if (name.isEmpty) {
      throw ValidationException('Food name cannot be empty');
    }

    if (calories < 0 || calories > 10000) {
      throw ValidationException('Calories must be between 0 and 10,000');
    }

    if (protein < 0 || protein > 500) {
      throw ValidationException('Protein must be between 0 and 500g');
    }

    if (carbs < 0 || carbs > 500) {
      throw ValidationException('Carbs must be between 0 and 500g');
    }

    if (fat < 0 || fat > 500) {
      throw ValidationException('Fat must be between 0 and 500g');
    }
  }
}

/// Exception thrown when data validation fails.
class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => message;
}
