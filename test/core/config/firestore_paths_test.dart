import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/config/firestore_paths.dart';

void main() {
  group('FirestorePaths', () {
    test('builds user collection paths below the owner UID', () {
      expect(
        FirestorePaths.userCollectionPath('uid-123', FirestorePaths.workouts),
        'users/uid-123/workouts',
      );
      expect(
        FirestorePaths.userCollectionPath('uid-123', FirestorePaths.nutrition),
        'users/uid-123/nutrition',
      );
    });

    test('builds user document paths consistently', () {
      expect(
        FirestorePaths.userDocumentPath(
          'uid-123',
          FirestorePaths.profile,
          'data',
        ),
        'users/uid-123/profile/data',
      );
    });

    test('rejects empty or slash-containing path segments', () {
      expect(
        () => FirestorePaths.userCollectionPath('', FirestorePaths.workouts),
        throwsArgumentError,
      );
      expect(
        () => FirestorePaths.userCollectionPath('uid-123', 'users/other'),
        throwsArgumentError,
      );
      expect(
        () => FirestorePaths.userDocumentPath(
          'uid-123',
          FirestorePaths.workouts,
          'bad/id',
        ),
        throwsArgumentError,
      );
    });
  });
}
