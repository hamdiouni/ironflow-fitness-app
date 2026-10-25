import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';

void main() {
  group('RecordOwnershipRules.normalizeUserId', () {
    test('treats null and empty ids as missing', () {
      expect(RecordOwnershipRules.normalizeUserId(null), isNull);
      expect(RecordOwnershipRules.normalizeUserId(''), isNull);
    });

    test('preserves non-empty ids exactly', () {
      expect(RecordOwnershipRules.normalizeUserId('Alice'), 'Alice');
      expect(RecordOwnershipRules.normalizeUserId(' Alice '), ' Alice ');
      expect(
        RecordOwnershipRules.normalizeUserId(
          RecordOwnershipRules.guestUserId,
        ),
        'local-user',
      );
    });
  });

  group('RecordOwnershipRules.isLegacyUnownedOwner', () {
    test('recognizes missing and guest owner ids', () {
      expect(RecordOwnershipRules.isLegacyUnownedOwner(null), isTrue);
      expect(RecordOwnershipRules.isLegacyUnownedOwner(''), isTrue);
      expect(
        RecordOwnershipRules.isLegacyUnownedOwner(
          RecordOwnershipRules.guestUserId,
        ),
        isTrue,
      );
    });

    test('does not treat real or historical account ids as unowned', () {
      expect(RecordOwnershipRules.isLegacyUnownedOwner('Alice'), isFalse);
      expect(RecordOwnershipRules.isLegacyUnownedOwner('test-user'), isFalse);
      expect(RecordOwnershipRules.isLegacyUnownedOwner(' '), isFalse);
    });
  });

  group('RecordOwnershipRules.classify', () {
    test('reports no current user before comparing owners', () {
      for (final currentUserId in <String?>[null, '']) {
        expect(
          RecordOwnershipRules.classify(
            ownerId: 'Alice',
            currentUserId: currentUserId,
          ),
          RecordOwnership.noCurrentUser,
        );
        expect(
          RecordOwnershipRules.classify(
            ownerId: null,
            currentUserId: currentUserId,
          ),
          RecordOwnership.noCurrentUser,
        );
      }
    });

    test('classifies records for a signed-in account', () {
      expect(
        RecordOwnershipRules.classify(
          ownerId: 'Alice',
          currentUserId: 'Alice',
        ),
        RecordOwnership.ownedByCurrentUser,
      );
      expect(
        RecordOwnershipRules.classify(
          ownerId: null,
          currentUserId: 'Alice',
        ),
        RecordOwnership.legacyUnowned,
      );
      expect(
        RecordOwnershipRules.classify(ownerId: '', currentUserId: 'Alice'),
        RecordOwnership.legacyUnowned,
      );
      expect(
        RecordOwnershipRules.classify(
          ownerId: RecordOwnershipRules.guestUserId,
          currentUserId: 'Alice',
        ),
        RecordOwnership.legacyUnowned,
      );
      expect(
        RecordOwnershipRules.classify(ownerId: 'bob', currentUserId: 'Alice'),
        RecordOwnership.foreignUser,
      );
      expect(
        RecordOwnershipRules.classify(
          ownerId: 'test-user',
          currentUserId: 'Alice',
        ),
        RecordOwnership.foreignUser,
      );
    });

    test('keeps the guest bucket distinct from a real account', () {
      expect(
        RecordOwnershipRules.classify(
          ownerId: RecordOwnershipRules.guestUserId,
          currentUserId: RecordOwnershipRules.guestUserId,
        ),
        RecordOwnership.legacyUnowned,
      );
      expect(
        RecordOwnershipRules.classify(
          ownerId: 'Alice',
          currentUserId: RecordOwnershipRules.guestUserId,
        ),
        RecordOwnership.foreignUser,
      );
    });
  });

  group('RecordOwnershipRules predicates', () {
    test('strict ownership requires an exact current-account match', () {
      expect(
        RecordOwnershipRules.isOwnedByCurrentUser(
          ownerId: 'Alice',
          currentUserId: 'Alice',
        ),
        isTrue,
      );
      expect(
        RecordOwnershipRules.isOwnedByCurrentUser(
          ownerId: null,
          currentUserId: 'Alice',
        ),
        isFalse,
      );
      expect(
        RecordOwnershipRules.isOwnedByCurrentUser(
          ownerId: RecordOwnershipRules.guestUserId,
          currentUserId: RecordOwnershipRules.guestUserId,
        ),
        isFalse,
      );
      expect(
        RecordOwnershipRules.isOwnedByCurrentUser(
          ownerId: 'Alice',
          currentUserId: null,
        ),
        isFalse,
      );
    });

    test('foreign requires a proven different account', () {
      expect(
        RecordOwnershipRules.isForeignToCurrentUser(
          ownerId: 'bob',
          currentUserId: 'Alice',
        ),
        isTrue,
      );
      expect(
        RecordOwnershipRules.isForeignToCurrentUser(
          ownerId: null,
          currentUserId: 'Alice',
        ),
        isFalse,
      );
      expect(
        RecordOwnershipRules.isForeignToCurrentUser(
          ownerId: 'Alice',
          currentUserId: 'Alice',
        ),
        isFalse,
      );
      expect(
        RecordOwnershipRules.isForeignToCurrentUser(
          ownerId: 'bob',
          currentUserId: null,
        ),
        isFalse,
      );
    });

    test('belongsToCurrentUser preserves the existing local scope', () {
      expect(
        RecordOwnershipRules.belongsToCurrentUser(
          ownerId: 'Alice',
          currentUserId: 'Alice',
        ),
        isTrue,
      );
      expect(
        RecordOwnershipRules.belongsToCurrentUser(
          ownerId: null,
          currentUserId: 'Alice',
        ),
        isTrue,
      );
      expect(
        RecordOwnershipRules.belongsToCurrentUser(
          ownerId: RecordOwnershipRules.guestUserId,
          currentUserId: 'Alice',
        ),
        isTrue,
      );
      expect(
        RecordOwnershipRules.belongsToCurrentUser(
          ownerId: 'bob',
          currentUserId: 'Alice',
        ),
        isFalse,
      );
      expect(
        RecordOwnershipRules.belongsToCurrentUser(
          ownerId: 'bob',
          currentUserId: null,
        ),
        isTrue,
      );
    });
  });
}
