/// How a stored record relates to the user currently using the app.
enum RecordOwnership {
  /// The record carries the current user's exact user id.
  ownedByCurrentUser,

  /// The record predates reliable owner stamping, or was created through
  /// the signed-out guest path. It has no proven account owner yet.
  legacyUnowned,

  /// The record carries a different account's user id.
  foreignUser,

  /// There is no current user id to compare against.
  noCurrentUser,
}

/// Pure owner-id classification shared by local repositories, sync, and
/// presentation filters.
///
/// These rules only classify stored ids. They deliberately do not claim,
/// migrate, delete, or rewrite legacy records; callers decide what each
/// classification means for their operation.
class RecordOwnershipRules {
  const RecordOwnershipRules._();

  /// Placeholder stamped by signed-out/guest writers. It identifies a
  /// device-local bucket, not a real account.
  static const String guestUserId = 'local-user';

  /// Returns null for a missing or empty user id. Other values are kept
  /// exactly as stored; user ids are identifiers, not display text.
  static String? normalizeUserId(String? userId) {
    return (userId == null || userId.isEmpty) ? null : userId;
  }

  /// Whether [ownerId] has no proven account owner.
  static bool isLegacyUnownedOwner(String? ownerId) {
    final normalizedOwnerId = normalizeUserId(ownerId);
    return normalizedOwnerId == null || normalizedOwnerId == guestUserId;
  }

  /// Classifies [ownerId] against [currentUserId].
  ///
  /// The guest placeholder is classified as [RecordOwnership.legacyUnowned]
  /// even when the current local bucket also uses that placeholder. This
  /// keeps guest records distinct from records proven to belong to a real
  /// signed-in account.
  static RecordOwnership classify({
    required String? ownerId,
    required String? currentUserId,
  }) {
    final normalizedCurrentUserId = normalizeUserId(currentUserId);
    if (normalizedCurrentUserId == null) {
      return RecordOwnership.noCurrentUser;
    }
    if (isLegacyUnownedOwner(ownerId)) {
      return RecordOwnership.legacyUnowned;
    }
    return ownerId == normalizedCurrentUserId
        ? RecordOwnership.ownedByCurrentUser
        : RecordOwnership.foreignUser;
  }

  /// Whether the record is proven to belong to the current account.
  static bool isOwnedByCurrentUser({
    required String? ownerId,
    required String? currentUserId,
  }) {
    return classify(ownerId: ownerId, currentUserId: currentUserId) ==
        RecordOwnership.ownedByCurrentUser;
  }

  /// Whether the record is proven to belong to a different account.
  ///
  /// With no current user this returns false: there is not yet an account
  /// for the record to be foreign to. Callers that must fail closed while
  /// signed out should check [RecordOwnership.noCurrentUser] explicitly.
  static bool isForeignToCurrentUser({
    required String? ownerId,
    required String? currentUserId,
  }) {
    return classify(ownerId: ownerId, currentUserId: currentUserId) ==
        RecordOwnership.foreignUser;
  }

  /// Compatibility scope used by existing display/local filters.
  ///
  /// Exact-owned and legacy-unowned records are included. With no current
  /// user, records are also included so signed-out local use keeps its
  /// existing behaviour. Only a record proven to belong to another
  /// account is excluded.
  static bool belongsToCurrentUser({
    required String? ownerId,
    required String? currentUserId,
  }) {
    return classify(ownerId: ownerId, currentUserId: currentUserId) !=
        RecordOwnership.foreignUser;
  }
}
