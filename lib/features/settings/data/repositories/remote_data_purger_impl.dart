import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/remote_data_purger.dart';

/// Typed exception thrown when one or more remote cloud purge steps fail (BKD-03).
class RemotePurgeException implements Exception {
  final List<String> failures;

  const RemotePurgeException(this.failures);

  @override
  String toString() =>
      'Remote data purge failed (${failures.length} error(s)): ${failures.join("; ")}';
}

/// Concrete implementation of [RemoteDataPurger].
///
/// Purges Firestore and Firebase Storage remote records associated with [userId].
/// Covers the Phase 2 single cloud layout (flat collections keyed by the
/// `userId` field + the `users/{uid}` tree) and recursively deletes all
/// Storage prefixes (`profile/`, `workouts/`, `progress/`, etc.).
///
/// Wave 1 (BKD-03): Never swallows deletion errors; any failure across
/// Firestore or Storage is aggregated and thrown as a [RemotePurgeException]
/// so [DeleteAccountUseCase] aborts account deletion rather than leaving
/// orphaned user data in the cloud.
class RemoteDataPurgerImpl implements RemoteDataPurger {
  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;

  RemoteDataPurgerImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore,
        _storage = storage;

  static String _redactUserId(String userId) {
    final trimmed = userId.trim();
    if (trimmed.length <= 6) return '***';
    return '${trimmed.substring(0, 3)}...${trimmed.substring(trimmed.length - 3)}';
  }

  @override
  Future<void> purgeRemoteUserData(String userId) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('userId cannot be empty when purging remote data');
    }

    // 1. Check if Firebase is initialized when no test instances are injected
    if (_firestore == null && _storage == null && Firebase.apps.isEmpty) {
      if (kDebugMode) {
        AppLogger.debug(
          'ℹ️ [RemoteDataPurger] Firebase is not initialized. Skipping remote cloud purge.',
        );
      }
      return;
    }

    final firestore = _firestore ?? FirebaseFirestore.instance;
    final storage = _storage ?? FirebaseStorage.instance;
    final redactedUid = _redactUserId(userId);
    final failures = <String>[];

    if (kDebugMode) {
      AppLogger.debug(
        '📊 [RemoteDataPurger] Purging remote cloud records for user: $redactedUid',
      );
    }

    // 2. Purge profile subcollection document
    try {
      final profileDoc = firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('data');
      await profileDoc.delete();
    } catch (e) {
      failures.add('users/profile/data: $e');
    }

    // 3. Purge flat sync collections (Phase 2 layout)
    for (final collection in const [
      'workouts',
      'programs',
      'nutrition',
      'body_progress',
    ]) {
      try {
        await _purgeCollectionByUserId(firestore, collection, userId);
      } catch (e) {
        failures.add('$collection: $e');
      }
    }

    // 4. Purge nutrition_targets singleton
    try {
      await firestore.collection('nutrition_targets').doc(userId).delete();
    } catch (e) {
      failures.add('nutrition_targets: $e');
    }

    // 5. Purge known users/{uid} subcollections
    for (final subcollection in const ['backups', 'nutrition', 'consent']) {
      try {
        final snapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection(subcollection)
            .get();
        await _batchDelete(firestore, snapshot.docs.map((d) => d.reference));
      } catch (e) {
        failures.add('users/$subcollection: $e');
      }
    }

    // 6. Purge main user document
    try {
      final userDoc = firestore.collection('users').doc(userId);
      await userDoc.delete();
    } catch (e) {
      failures.add('users/root: $e');
    }

    // 7. Recursively purge Firebase Storage bucket user assets
    //    (root items + profile/, workouts/, progress/, and any nested prefixes)
    try {
      final userStorageRef = storage.ref().child('users').child(userId);
      await _deleteStorageReferenceRecursively(userStorageRef, failures);
    } catch (e) {
      failures.add('storage/users: $e');
    }

    if (failures.isNotEmpty) {
      if (kDebugMode) {
        AppLogger.debug(
          '❌ [RemoteDataPurger] Remote purge encountered ${failures.length} failure(s) for $redactedUid',
        );
      }
      throw RemotePurgeException(failures);
    }

    if (kDebugMode) {
      AppLogger.debug(
        '✅ [RemoteDataPurger] Remote purge completed successfully for user: $redactedUid',
      );
    }
  }

  /// Recursively deletes all files and nested folder prefixes under [ref].
  Future<void> _deleteStorageReferenceRecursively(
    Reference ref,
    List<String> failures,
  ) async {
    final ListResult listResult;
    try {
      listResult = await ref.listAll();
    } catch (e) {
      failures.add('storage listAll(${ref.fullPath}): $e');
      return;
    }

    for (final item in listResult.items) {
      try {
        await item.delete();
      } catch (e) {
        failures.add('storage delete(${item.fullPath}): $e');
      }
    }

    for (final prefix in listResult.prefixes) {
      await _deleteStorageReferenceRecursively(prefix, failures);
    }
  }

  /// Deletes every document in [collection] whose `userId` field matches.
  Future<void> _purgeCollectionByUserId(
    FirebaseFirestore firestore,
    String collection,
    String userId,
  ) async {
    final snapshot = await firestore
        .collection(collection)
        .where('userId', isEqualTo: userId)
        .get();
    await _batchDelete(firestore, snapshot.docs.map((d) => d.reference));
    if (kDebugMode) {
      AppLogger.debug(
        '📊 [RemoteDataPurger] Deleted ${snapshot.docs.length} docs from $collection',
      );
    }
  }

  /// Batch-deletes in chunks (Firestore batch limit is 500 operations).
  Future<void> _batchDelete(
    FirebaseFirestore firestore,
    Iterable<DocumentReference> refs,
  ) async {
    final list = refs.toList();
    for (var start = 0; start < list.length; start += 400) {
      final batch = firestore.batch();
      for (final ref in list.skip(start).take(400)) {
        batch.delete(ref);
      }
      await batch.commit();
    }
  }
}
