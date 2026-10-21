/// Encodes local Hive keys so one authenticated account cannot read another
/// account's locally cached feature records.
///
/// Unscoped legacy keys remain visible only to the signed-out/local-only
/// context (`userId == null`). They are never implicitly assigned to the first
/// account that signs in.
class UserScopedHiveKey {
  UserScopedHiveKey._();

  static const String separator = '::';

  static String encode(String? userId, String recordId) {
    if (userId == null) return recordId;
    if (userId.trim().isEmpty ||
        userId.contains(separator) ||
        userId.contains('/')) {
      throw ArgumentError.value(userId, 'userId', 'must be a valid user ID');
    }
    return '$userId$separator$recordId';
  }

  static bool belongsTo(Object? key, String? userId) {
    if (key is! String) return false;
    if (userId == null) return !key.contains(separator);
    return key.startsWith('$userId$separator');
  }
}
