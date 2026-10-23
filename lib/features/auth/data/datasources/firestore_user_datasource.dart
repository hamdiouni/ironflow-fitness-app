import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';
import 'mock_user_datasource.dart';

abstract class FirestoreUserDataSource {
  Future<UserProfile?> getUserProfile(String userId);
  Future<void> saveUserProfile(UserProfile profile);
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> deleteUserProfile(String userId);
}

/// Firestore-backed user profiles.
///
/// Phase 1: also implements [MockUserDataSource] (identical surface; only
/// `createUserProfile` vs `saveUserProfile` differ in name) so it can be
/// swapped in behind the `USE_FIREBASE_AUTH` flag.
class FirestoreUserDataSourceImpl
    implements FirestoreUserDataSource, MockUserDataSource {
  final FirebaseFirestore _firestore;

  FirestoreUserDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('data')
          .get();

      if (!doc.exists) return null;

      return UserProfile.fromJson(doc.data()!);
    } catch (e) {
      AppLogger.debug('Error getting user profile: $e');
      return null;
    }
  }

  /// MockUserDataSource alias — profile creation is an upsert here.
  @override
  Future<void> createUserProfile(UserProfile profile) =>
      saveUserProfile(profile);

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.userId)
          .collection('profile')
          .doc('data')
          .set(profile.toJson());
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.userId)
          .collection('profile')
          .doc('data')
          .update(profile.toJson());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('data')
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }
}
