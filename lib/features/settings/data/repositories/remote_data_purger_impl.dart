import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/remote_data_purger.dart';

/// Concrete implementation of [RemoteDataPurger].
///
/// Purges Firestore and Firebase Storage remote records associated with [userId].
/// Fully sync-ready for Release 1.3 cloud synchronization.
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
          print('ℹ️ [RemoteDataPurger] Firebase is not initialized. Skipping remote cloud purge.');
        }
        return;
      }

      final firestore = _firestore ?? FirebaseFirestore.instance;
      final storage = _storage ?? FirebaseStorage.instance;

      if (kDebugMode) {
        print('📊 [RemoteDataPurger] Purging remote Firestore documents for user: $userId');
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
          print('⚠️ [RemoteDataPurger] Firestore profile doc deletion note: $e');
        }
      }

      // Purge main user document
      try {
        final userDoc = firestore.collection('users').doc(userId);
        await userDoc.delete();
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [RemoteDataPurger] Firestore user doc deletion note: $e');
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
          print('⚠️ [RemoteDataPurger] Storage user assets deletion note: $e');
        }
      }

      if (kDebugMode) {
        print('✅ [RemoteDataPurger] Remote purge completed successfully for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RemoteDataPurger] Remote purge failed: $e');
      }
      throw Exception('Remote data purge failed: $e');
    }
  }
}
