import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';

/// Simple mock user datasource for development
abstract class MockUserDataSource {
  Future<void> createUserProfile(UserProfile profile);
  Future<UserProfile?> getUserProfile(String userId);
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> deleteUserProfile(String userId);
}

class MockUserDataSourceImpl implements MockUserDataSource {
  // Simple in-memory storage
  static final Map<String, UserProfile> _profiles = {};

  @override
  Future<void> createUserProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _profiles[profile.userId] = profile;
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _profiles[userId];
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _profiles[profile.userId] = profile;
  }

  @override
  Future<void> deleteUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _profiles.remove(userId);
  }
}
