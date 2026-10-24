import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/remote_data_purger.dart';

/// Concrete implementation of [RemoteDataPurger].
///
/// Purges Firestore and Firebase Storage remote records associated with [userId].
/// Covers the Phase 2 single cloud layout (flat collections keyed by the
/// `userId` field + the `users/{uid}` tree) so account deletion cannot
/// leave synced records behind.
class RemoteDataPurgerImpl implements RemoteDataPurger {
  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;

  RemoteDataPurgerImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore,
        _storage = storage;

  @override
  Future<void> purgeRemoteUserData(String userId) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError('userId cannot be empty when purging remote data');
    }

    try {
      // 1. Check if Firebase is initialized
      if (Firebase.apps.isEmpty) {
        if (kDebugMode) {
          AppLogger.debug('ℹ️ [RemoteDataPurger] Firebase is not initialized. Skipping remote cloud purge.');
        }
        return;
      }

      final firestore = _firestore ?? FirebaseFirestore.instance;
      final storage = _storage ?? FirebaseStorage.instance;

      if (kDebugMode) {
        AppLogger.debug('📊 [RemoteDataPurger] Purging remote Firestore documents for user: $userId');
      }

      // Purge profile subcollection document
      try {
        final profileDoc = firestore
            .collection('users')
            .doc(userId)
            .collection('profile')
            .doc('data');
        await profileDoc.delete();
      } catch (e) {
        if (kDebugMode) {
          AppLogger.debug('⚠️ [RemoteDataPurger] Firestore profile doc deletion note: $e');
        }
      }

      // Purge flat sync collections (Phase 2 layout): every document
      // whose `userId` field matches, plus the targets singleton whose
      // document id IS the user id. Without this, account deletion left
      // all synced workouts/meals/programs/body entries behind.
      for (final collection in const [
        'workouts',
        'programs',
        'nutrition',
        'body_progress',
      ]) {
        try {
          await _purgeCollectionByUserId(firestore, collection, userId);
        } catch (e) {
          if (kDebugMode) {
            AppLogger.debug('⚠️ [RemoteDataPurger] $collection purge note: $e');
          }
        }
      }
      try {
        await firestore.collection('nutrition_targets').doc(userId).delete();
      } catch (e) {
        if (kDebugMode) {
          AppLogger.debug('⚠️ [RemoteDataPurger] nutrition_targets purge note: $e');
        }
      }

      // Purge known users/{uid} subcollections (backups + any orphaned
      // pre-Phase-2 nutrition documents). Firestore does not cascade
      // deletes into subcollections when the parent document is removed.
      for (final subcollection in const ['backups', 'nutrition']) {
        try {
          final snapshot = await firestore
              .collection('users')
              .doc(userId)
              .collection(subcollection)
              .get();
          await _batchDelete(firestore, snapshot.docs.map((d) => d.reference));
        } catch (e) {
          if (kDebugMode) {
            AppLogger.debug('⚠️ [RemoteDataPurger] users/$subcollection purge note: $e');
          }
        }
      }

      // Purge main user document
      try {
        final userDoc = firestore.collection('users').doc(userId);
        await userDoc.delete();
      } catch (e) {
        if (kDebugMode) {
          AppLogger.debug('⚠️ [RemoteDataPurger] Firestore user doc deletion note: $e');
        }
      }

      // Purge storage bucket user assets (e.g. progress photos, avatar)
      try {
        final userStorageRef = storage.ref().child('users').child(userId);
        final listResult = await userStorageRef.listAll();
        for (final item in listResult.items) {
          await item.delete();
        }
      } catch (e) {
        if (kDebugMode) {
          AppLogger.debug('⚠️ [RemoteDataPurger] Storage user assets deletion note: $e');
        }
      }

      if (kDebugMode) {
        AppLogger.debug('✅ [RemoteDataPurger] Remote purge completed successfully for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('❌ [RemoteDataPurger] Remote purge failed: $e');
      }
      throw Exception('Remote data purge failed: $e');
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
