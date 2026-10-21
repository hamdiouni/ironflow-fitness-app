import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/config/firestore_paths.dart';
import '../../domain/entities/user_profile.dart';

abstract class FirestoreUserDataSource {
  Future<UserProfile?> getUserProfile(String userId);
  Future<void> saveUserProfile(UserProfile profile);
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> deleteUserProfile(String userId);
}

class FirestoreUserDataSourceImpl implements FirestoreUserDataSource {
  final FirebaseFirestore _firestore;

  FirestoreUserDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await FirestorePaths.userDocument(
        _firestore,
        userId,
        FirestorePaths.profile,
        'data',
      ).get();

      if (!doc.exists) return null;

      return UserProfile.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await FirestorePaths.userDocument(
        _firestore,
        profile.userId,
        FirestorePaths.profile,
        'data',
      ).set(profile.toJson());
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await FirestorePaths.userDocument(
        _firestore,
        profile.userId,
        FirestorePaths.profile,
        'data',
      ).update(profile.toJson());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> deleteUserProfile(String userId) async {
    try {
      await FirestorePaths.userDocument(
        _firestore,
        userId,
        FirestorePaths.profile,
        'data',
      ).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }
}
