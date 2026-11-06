import 'package:flutter/foundation.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';
import 'auth_datasource.dart';

/// Backward-compatible alias for [UserProfileRemoteDataSource].
typedef MockUserDataSource = UserProfileRemoteDataSource;

class MockUserDataSourceImpl implements UserProfileRemoteDataSource {
  MockUserDataSourceImpl() {
    if (kReleaseMode) {
      throw StateError(
        'MockUserDataSourceImpl is forbidden in release builds (SEC-02 / Wave 3.5).',
      );
    }
  }

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
