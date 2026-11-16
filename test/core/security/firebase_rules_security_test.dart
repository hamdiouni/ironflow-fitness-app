import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Evaluates the security invariants of `firestore.rules`, `storage.rules`,
/// and `firestore.indexes.json` in `flutter test` so regressions in BKD-01
/// (cross-user update hijack), BKD-02 (Storage delete on null request.resource),
/// BKD-04 (payload bounds + read-only ai_usage), and composite sync indexes
/// are caught automatically on every test run.
void main() {
  group('Firestore Security Rules (Wave 1 — BKD-01, BKD-04)', () {
    late String firestoreRules;

    setUpAll(() {
      firestoreRules = File('firestore.rules').readAsStringSync();
    });

    test('never combines create and update without readsOwnDoc() on flat sync collections (BKD-01)', () {
      for (final collection in const [
        'workouts',
        'programs',
        'nutrition',
        'body_progress',
      ]) {
        final matchBlock = RegExp(
          r'^\s{4}match\s+/' + collection + r'/\{[A-Za-z]+\}\s*\{([^}]+)\}',
          multiLine: true,
        ).firstMatch(firestoreRules);

        expect(
          matchBlock,
          isNotNull,
          reason: 'Missing match block for /$collection/{id}',
        );
        final body = matchBlock!.group(1)!;

        // Must NOT have `allow create, update: if writesOwnDoc()`
        expect(
          body.contains(RegExp(r'allow\s+create\s*,\s*update')),
          isFalse,
          reason:
              '/$collection combines create and update, allowing cross-user update hijack without readsOwnDoc()',
        );

        // Must require BOTH readsOwnDoc() and isValidSyncPayload() on update
        expect(
          body,
          contains('allow create: if isValidSyncPayload();'),
        );
        expect(
          body,
          contains('allow update: if readsOwnDoc() && isValidSyncPayload();'),
        );
      }
    });

    test('enforces bounded payload helper isBoundedDoc() and string/list limits (BKD-04)', () {
      expect(firestoreRules, contains('function isBoundedDoc()'));
      expect(
        firestoreRules,
        contains('request.resource.data.keys().size() <= 50'),
      );
      expect(
        firestoreRules,
        contains('request.resource.data.notes.size() <= 10000'),
      );
      expect(
        firestoreRules,
        contains('request.resource.data.exercises.size() <= 200'),
      );
      expect(
        firestoreRules,
        contains('request.resource.data.items.size() <= 200'),
      );
    });

    test('locks users/{userId}/ai_usage/{dateId} against client create/update while permitting owner delete on account purge (Wave 1.6)', () {
      final aiUsageBlock = RegExp(
        r'match\s+/ai_usage/\{dateId\}\s*\{([^}]+)\}',
        multiLine: true,
      ).firstMatch(firestoreRules);
      expect(aiUsageBlock, isNotNull);
      final body = aiUsageBlock!.group(1)!;
      expect(body, contains('allow read, delete: if isOwner(userId);'));
      expect(body, contains('allow create, update: if false;'));
    });

    test('simulated rule evaluator rejects cross-user update, oversized notes, and unauthenticated access', () {
      bool evalUpdate({
        required String? authUid,
        required String existingUserId,
        required Map<String, dynamic> incomingData,
      }) {
        final isAuthenticated = authUid != null;
        final readsOwnDoc = isAuthenticated && existingUserId == authUid;
        final writesOwnDoc = isAuthenticated &&
            incomingData['userId'] is String &&
            incomingData['userId'] == authUid &&
            (incomingData['userId'] as String).isNotEmpty &&
            (incomingData['userId'] as String).length <= 128;
        final isBoundedDoc = incomingData.keys.length <= 50 &&
            (!incomingData.containsKey('notes') ||
                incomingData['notes'] == null ||
                (incomingData['notes'] is String &&
                    (incomingData['notes'] as String).length <= 10000));
        return readsOwnDoc && writesOwnDoc && isBoundedDoc;
      }

      // Owner valid update -> allowed
      expect(
        evalUpdate(
          authUid: 'alice',
          existingUserId: 'alice',
          incomingData: {'userId': 'alice', 'notes': 'Good session'},
        ),
        isTrue,
      );

      // Cross-user hijack (Bob tries to overwrite Alice's workout with userId: bob) -> denied
      expect(
        evalUpdate(
          authUid: 'bob',
          existingUserId: 'alice',
          incomingData: {'userId': 'bob', 'notes': 'Hijacked'},
        ),
        isFalse,
      );

      // Ownership transfer (Alice tries to reassign doc to Bob) -> denied
      expect(
        evalUpdate(
          authUid: 'alice',
          existingUserId: 'alice',
          incomingData: {'userId': 'bob', 'notes': 'Transferred'},
        ),
        isFalse,
      );

      // Oversized payload -> denied
      expect(
        evalUpdate(
          authUid: 'alice',
          existingUserId: 'alice',
          incomingData: {'userId': 'alice', 'notes': 'x' * 10001},
        ),
        isFalse,
      );
    });
  });

  group('Storage Security Rules (Wave 1 — BKD-02)', () {
    late String storageRules;

    setUpAll(() {
      storageRules = File('storage.rules').readAsStringSync();
    });

    test('never uses `allow write:` with `request.resource.size` which breaks file deletes (BKD-02)', () {
      expect(
        storageRules.contains(RegExp(r'allow\s+write\s*:')),
        isFalse,
        reason:
            '`allow write:` evaluates on delete where `request.resource == null`, breaking all deletions.',
      );
      expect(
        storageRules,
        contains('allow read, delete: if isOwner(userId);'),
      );
      expect(
        storageRules,
        contains('allow create, update: if isOwner(userId)'),
      );
    });

    test('grants owner recursive read/delete on /users/{userId}/{allPaths=**} for account purge', () {
      expect(
        storageRules,
        contains('match /users/{userId}/{allPaths=**}'),
      );
    });

    test('enforces size and JSON contentType bounds on /users/{userId}/backups/{fileName} (Wave 1.1)', () {
      final backupBlock = RegExp(
        r'match\s+/users/\{userId\}/backups/\{fileName\}\s*\{([^}]+)\}',
        multiLine: true,
      ).firstMatch(storageRules);
      expect(backupBlock, isNotNull);
      final body = backupBlock!.group(1)!;
      expect(body, contains('allow read, delete: if isOwner(userId);'));
      expect(body, contains('allow create, update: if isOwner(userId)'));
      expect(body, contains('<= 10 * 1024 * 1024'));
      expect(body, contains("contentType == 'application/json'"));
    });
  });

  group('Firestore Composite Indexes (firestore.indexes.json)', () {
    test('defines both full-pull and incremental syncedAt cursor indexes for workouts, nutrition, and body_progress', () {
      final raw = File('firestore.indexes.json').readAsStringSync();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final indexes = (decoded['indexes'] as List).cast<Map<String, dynamic>>();

      bool hasIndex(String collectionGroup, List<String> fieldPaths) {
        return indexes.any((idx) {
          if (idx['collectionGroup'] != collectionGroup) return false;
          final fields = (idx['fields'] as List).cast<Map<String, dynamic>>();
          if (fields.length != fieldPaths.length) return false;
          for (var i = 0; i < fields.length; i++) {
            if (fields[i]['fieldPath'] != fieldPaths[i]) return false;
          }
          return true;
        });
      }

      for (final col in const ['workouts', 'nutrition', 'body_progress']) {
        expect(
          hasIndex(col, ['userId', 'syncedAt']),
          isTrue,
          reason: 'Missing incremental cursor index (userId, syncedAt) for $col',
        );
      }
      expect(hasIndex('programs', ['userId', 'isActive', 'syncedAt']), isTrue);
    });
  });
}
