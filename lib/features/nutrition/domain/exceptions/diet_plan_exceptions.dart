/// Custom exception classes for diet plan feature error handling.
///
/// These exceptions provide specific error types for different diet plan-related
/// operations, enabling precise error handling and user-friendly error messages.
library;

/// Exception thrown when an error occurs during diet plan operations.
///
/// This includes errors related to loading, saving, swapping meals,
/// or managing the active diet plan.
///
/// Example:
/// ```dart
/// try {
///   await dietPlanRepository.saveDietPlan(planState);
/// } on DietPlanException catch (e) {
///   print('Failed to save diet plan: ${e.message}');
/// }
/// ```
class DietPlanException implements Exception {
  /// The error message describing what went wrong.
  final String message;

  /// The underlying cause of this exception, if any.
  final Exception? cause;

  /// The stack trace at the point where this exception was thrown.
  final StackTrace? stackTrace;

  /// Creates a new [DietPlanException].
  ///
  /// The [message] parameter is required and should describe the error.
  /// The [cause] and [stackTrace] parameters are optional and can be used
  /// for debugging and error reporting.
  DietPlanException({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() => 'DietPlanException: $message';
}

/// Exception thrown when a storage error occurs during diet plan operations.
class DietPlanStorageException extends DietPlanException {
  DietPlanStorageException(String message)
      : super(message: 'Storage error: $message');
}
