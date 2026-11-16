import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/settings/data/repositories/remote_data_purger_impl.dart';
import 'package:progression_tracker/features/settings/domain/repositories/remote_data_purger.dart';
import 'package:progression_tracker/features/settings/domain/services/local_data_wiper.dart';
import 'package:progression_tracker/features/settings/domain/usecases/delete_account_use_case.dart';

class _FakeAuthRepository implements AuthRepository {
  bool deleteAccountCalled = false;

  @override
  Future<void> reauthenticateWithPassword(String password) async {}

  @override
  Future<void> deleteAccount() async {
    deleteAccountCalled = true;
  }

  @override
  Future<User?> getCurrentUser() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ThrowingRemotePurger implements RemoteDataPurger {
  @override
  Future<void> purgeRemoteUserData(String userId) async {
    throw Exception('Simulated Firestore/Storage failure');
  }
}

class _NoopLocalWiper extends LocalDataWiper {
  bool wipeCalled = false;

  @override
  Future<void> wipeAllUserData(String userId, {bool keepAuthSession = false}) async {
    wipeCalled = true;
  }
}

// --- Fakes for Firestore & Storage recursive deletion and error surfacing ---

class _FakeWriteBatch implements WriteBatch {
  final List<String> deletedPaths;
  _FakeWriteBatch(this.deletedPaths);

  @override
  void delete(DocumentReference document) {
    deletedPaths.add(document.path);
  }

  @override
  Future<void> commit() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class _FakeDocumentReference implements DocumentReference<Map<String, dynamic>> {
  @override
  final String path;
  final List<String> deletedPaths;
  final Set<String> failOnPaths;

  _FakeDocumentReference(this.path, this.deletedPaths, this.failOnPaths);

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return _FakeCollectionReference('$path/$collectionPath', deletedPaths, failOnPaths);
  }

  @override
  Future<void> delete() async {
    if (failOnPaths.contains(path)) {
      throw Exception('Simulated Firestore delete failure at $path');
    }
    deletedPaths.add(path);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class _FakeQueryDocumentSnapshot implements QueryDocumentSnapshot<Map<String, dynamic>> {
  @override
  final DocumentReference<Map<String, dynamic>> reference;
  _FakeQueryDocumentSnapshot(this.reference);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeQuerySnapshot implements QuerySnapshot<Map<String, dynamic>> {
  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  _FakeQuerySnapshot(this.docs);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ignore: subtype_of_sealed_class
class _FakeCollectionReference implements CollectionReference<Map<String, dynamic>> {
  @override
  final String path;
  final List<String> deletedPaths;
  final Set<String> failOnPaths;

  _FakeCollectionReference(this.path, this.deletedPaths, this.failOnPaths);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? docPath]) {
    return _FakeDocumentReference('$path/${docPath ?? "auto"}', deletedPaths, failOnPaths);
  }

  @override
  Query<Map<String, dynamic>> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    return this;
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    if (failOnPaths.contains(path)) {
      throw Exception('Simulated Firestore query failure at $path');
    }
    return _FakeQuerySnapshot([
      _FakeQueryDocumentSnapshot(
        _FakeDocumentReference('$path/doc_1', deletedPaths, failOnPaths),
      ),
    ]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFirebaseFirestore implements FirebaseFirestore {
  final List<String> deletedPaths = [];
  final Set<String> failOnPaths;

  _FakeFirebaseFirestore({this.failOnPaths = const {}});

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return _FakeCollectionReference(collectionPath, deletedPaths, failOnPaths);
  }

  @override
  WriteBatch batch() => _FakeWriteBatch(deletedPaths);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeListResult implements ListResult {
  @override
  final List<Reference> items;
  @override
  final List<Reference> prefixes;

  _FakeListResult({required this.items, required this.prefixes});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeStorageReference implements Reference {
  @override
  final String fullPath;
  final Map<String, List<String>> filesByPrefix;
  final Map<String, List<String>> subprefixesByPrefix;
  final List<String> deletedStoragePaths;
  final Set<String> failOnStoragePaths;

  _FakeStorageReference({
    required this.fullPath,
    required this.filesByPrefix,
    required this.subprefixesByPrefix,
    required this.deletedStoragePaths,
    required this.failOnStoragePaths,
  });

  @override
  Reference child(String path) {
    final nextPath = fullPath.isEmpty ? path : '$fullPath/$path';
    return _FakeStorageReference(
      fullPath: nextPath,
      filesByPrefix: filesByPrefix,
      subprefixesByPrefix: subprefixesByPrefix,
      deletedStoragePaths: deletedStoragePaths,
      failOnStoragePaths: failOnStoragePaths,
    );
  }

  @override
  Future<ListResult> listAll() async {
    if (failOnStoragePaths.contains(fullPath)) {
      throw Exception('Simulated Storage listAll failure at $fullPath');
    }
    final items = (filesByPrefix[fullPath] ?? const <String>[])
        .map((filePath) => _FakeStorageReference(
              fullPath: filePath,
              filesByPrefix: filesByPrefix,
              subprefixesByPrefix: subprefixesByPrefix,
              deletedStoragePaths: deletedStoragePaths,
              failOnStoragePaths: failOnStoragePaths,
            ))
        .toList();
    final prefixes = (subprefixesByPrefix[fullPath] ?? const <String>[])
        .map((prefixPath) => _FakeStorageReference(
              fullPath: prefixPath,
              filesByPrefix: filesByPrefix,
              subprefixesByPrefix: subprefixesByPrefix,
              deletedStoragePaths: deletedStoragePaths,
              failOnStoragePaths: failOnStoragePaths,
            ))
        .toList();
    return _FakeListResult(items: items, prefixes: prefixes);
  }

  @override
  Future<void> delete() async {
    if (failOnStoragePaths.contains(fullPath)) {
      throw Exception('Simulated Storage delete failure at $fullPath');
    }
    deletedStoragePaths.add(fullPath);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFirebaseStorage implements FirebaseStorage {
  final List<String> deletedStoragePaths = [];
  final Set<String> failOnStoragePaths;

  _FakeFirebaseStorage({this.failOnStoragePaths = const {}});

  @override
  Reference ref([String? path]) {
    return _FakeStorageReference(
      fullPath: path ?? '',
      filesByPrefix: const {
        'users/user_123': ['users/user_123/root_meta.json'],
        'users/user_123/profile': ['users/user_123/profile/avatar.jpg'],
        'users/user_123/workouts': [
          'users/user_123/workouts/clip1.mp4',
          'users/user_123/workouts/photo1.jpg',
        ],
        'users/user_123/progress': ['users/user_123/progress/front.jpg'],
        'users/user_123/progress/2026': ['users/user_123/progress/2026/oct.jpg'],
      },
      subprefixesByPrefix: const {
        'users/user_123': [
          'users/user_123/profile',
          'users/user_123/workouts',
          'users/user_123/progress',
        ],
        'users/user_123/progress': [
          'users/user_123/progress/2026',
        ],
      },
      deletedStoragePaths: deletedStoragePaths,
      failOnStoragePaths: failOnStoragePaths,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RemoteDataPurgerImpl & DeleteAccountUseCase (Wave 1 Step 4 — BKD-03)', () {
    test('characterization: throws ArgumentError when userId is empty', () async {
      final purger = RemoteDataPurgerImpl();
      await expectLater(
        () => purger.purgeRemoteUserData('   '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('characterization: skips safely when Firebase.apps is empty and no instances are injected', () async {
      final purger = RemoteDataPurgerImpl();
      await purger.purgeRemoteUserData('user_123');
    });

    test('characterization: DeleteAccountUseCase aborts Auth account deletion when RemoteDataPurger throws', () async {
      final authRepo = _FakeAuthRepository();
      final localWiper = _NoopLocalWiper();
      final useCase = DeleteAccountUseCase(
        authRepository: authRepo,
        remoteDataPurger: _ThrowingRemotePurger(),
        localDataWiper: localWiper,
      );

      final result = await useCase.call(
        userId: 'user_123',
        password: 'password123',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('Failed to purge cloud records'));
      expect(authRepo.deleteAccountCalled, isFalse);
      expect(localWiper.wipeCalled, isFalse);
    });

    test('recursively deletes all Storage prefixes (profile/, workouts/, progress/, nested) and all Firestore collections', () async {
      final fakeFirestore = _FakeFirebaseFirestore();
      final fakeStorage = _FakeFirebaseStorage();
      final purger = RemoteDataPurgerImpl(
        firestore: fakeFirestore,
        storage: fakeStorage,
      );

      await purger.purgeRemoteUserData('user_123');

      // Verify all Firestore collections and user tree documents were deleted
      expect(
        fakeFirestore.deletedPaths,
        containsAll([
          'users/user_123/profile/data',
          'workouts/doc_1',
          'programs/doc_1',
          'nutrition/doc_1',
          'body_progress/doc_1',
          'nutrition_targets/user_123',
          'users/user_123/backups/doc_1',
          'users/user_123/nutrition/doc_1',
          'users/user_123/consent/doc_1',
          'users/user_123/ai_usage/doc_1',
          'users/user_123',
        ]),
      );

      // Verify recursive Storage deletion across root + profile/ + workouts/ + progress/ + progress/2026/
      expect(
        fakeStorage.deletedStoragePaths,
        containsAll([
          'users/user_123/root_meta.json',
          'users/user_123/profile/avatar.jpg',
          'users/user_123/workouts/clip1.mp4',
          'users/user_123/workouts/photo1.jpg',
          'users/user_123/progress/front.jpg',
          'users/user_123/progress/2026/oct.jpg',
        ]),
      );
      expect(fakeStorage.deletedStoragePaths.length, equals(6));
    });

    test('surfaces Firestore purge errors as RemotePurgeException instead of swallowing them', () async {
      final fakeFirestore = _FakeFirebaseFirestore(
        failOnPaths: {'workouts'},
      );
      final fakeStorage = _FakeFirebaseStorage();
      final purger = RemoteDataPurgerImpl(
        firestore: fakeFirestore,
        storage: fakeStorage,
      );

      await expectLater(
        () => purger.purgeRemoteUserData('user_123'),
        throwsA(
          isA<RemotePurgeException>().having(
            (e) => e.toString(),
            'toString',
            contains('workouts:'),
          ),
        ),
      );
    });

    test('surfaces nested Storage deletion errors and causes DeleteAccountUseCase to abort Auth deletion', () async {
      final fakeFirestore = _FakeFirebaseFirestore();
      final fakeStorage = _FakeFirebaseStorage(
        failOnStoragePaths: {'users/user_123/progress/2026/oct.jpg'},
      );
      final purger = RemoteDataPurgerImpl(
        firestore: fakeFirestore,
        storage: fakeStorage,
      );
      final authRepo = _FakeAuthRepository();
      final localWiper = _NoopLocalWiper();
      final useCase = DeleteAccountUseCase(
        authRepository: authRepo,
        remoteDataPurger: purger,
        localDataWiper: localWiper,
      );

      final result = await useCase.call(
        userId: 'user_123',
        password: 'password123',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('users/user_123/progress/2026/oct.jpg'));
      expect(authRepo.deleteAccountCalled, isFalse);
      expect(localWiper.wipeCalled, isFalse);
    });
  });
}
