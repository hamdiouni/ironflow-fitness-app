/// UUID generation utilities for entity identifiers
library;

import 'package:uuid/uuid.dart';

/// Utility class for generating unique identifiers
class UuidGenerator {
  static const Uuid _uuid = Uuid();

  /// Generates a new UUID v4 string
  static String generate() {
    return _uuid.v4();
  }

  /// Validates if a string is a valid UUID
  static bool isValid(String id) {
    return Uuid.isValidUUID(fromString: id);
  }
}
