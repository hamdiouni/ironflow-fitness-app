/// Core exception types for the application
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Domain layer exceptions
class InvalidRepsException extends AppException {
  InvalidRepsException() : super('Reps must be a positive integer');
}

class InvalidWeightException extends AppException {
  InvalidWeightException() : super('Weight must be a non-negative number');
}

class InvalidRPEException extends AppException {
  InvalidRPEException() : super('RPE must be between 1 and 10');
}

class InvalidMacroException extends AppException {
  InvalidMacroException() : super('Macro values must be non-negative');
}

class EntityNotFoundException extends AppException {
  EntityNotFoundException(String entityType, String id)
      : super('$entityType with id $id not found');
}

/// Data layer exceptions
class StorageException extends AppException {
  StorageException(super.message) : super(code: 'STORAGE_ERROR');
}

class SerializationException extends AppException {
  SerializationException(super.message)
      : super(code: 'SERIALIZATION_ERROR');
}
