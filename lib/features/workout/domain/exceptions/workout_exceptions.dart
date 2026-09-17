/// Custom exception classes for workout feature error handling.
///
/// These exceptions provide specific error types for different workout-related
/// operations, enabling precise error handling and user-friendly error messages.

/// Exception thrown when an error occurs during active program operations.
///
/// This includes errors related to loading, saving, updating, or managing
/// the active workout program.
///
/// Example:
/// ```dart
/// try {
///   await activeProgramRepository.saveActiveProgram(program);
/// } on ActiveProgramException catch (e) {
///   print('Failed to save program: ${e.message}');
/// }
/// ```
class ActiveProgramException implements Exception {
  /// The error message describing what went wrong.
  final String message;

  /// The underlying cause of this exception, if any.
  final Exception? cause;

  /// The stack trace at the point where this exception was thrown.
  final StackTrace? stackTrace;

  /// Creates a new [ActiveProgramException].
  ///
  /// The [message] parameter is required and should describe the error.
  /// The [cause] and [stackTrace] parameters are optional and can be used
  /// for debugging and error reporting.
  ActiveProgramException({
    required this.message,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() => 'ActiveProgramException: $message';
}

/// Exception thrown when a storage error occurs during active program operations.
class ActiveProgramStorageException extends ActiveProgramException {
  ActiveProgramStorageException(String message)
      : super(message: 'Storage error: $message');
}

/// Exception thrown when program validation fails during editing.
///
/// This includes validation errors for invalid sets, reps, rest seconds,
/// or other program parameters that don't meet the required constraints.
///
/// Example:
/// ```dart
/// try {
///   validator.validateSets(sets);
/// } on ProgramValidationException catch (e) {
///   print('Validation failed: ${e.message}');
/// }
/// ```
class ProgramValidationException implements Exception {
  /// The error message describing the validation failure.
  final String message;

  /// The name of the field that failed validation, if applicable.
  final String? fieldName;

  /// The invalid value that was provided.
  final dynamic invalidValue;

  /// The underlying cause of this exception, if any.
  final Exception? cause;

  /// The stack trace at the point where this exception was thrown.
  final StackTrace? stackTrace;

  /// Creates a new [ProgramValidationException].
  ///
  /// The [message] parameter is required and should describe the validation error.
  /// The [fieldName] parameter can be used to identify which field failed validation.
  /// The [invalidValue] parameter stores the value that failed validation.
  /// The [cause] and [stackTrace] parameters are optional for debugging.
  ProgramValidationException({
    required this.message,
    this.fieldName,
    this.invalidValue,
    this.cause,
    this.stackTrace,
  });

  @override
  String toString() => 'ProgramValidationException: $message'
      '${fieldName != null ? ' (field: $fieldName)' : ''}';
}
