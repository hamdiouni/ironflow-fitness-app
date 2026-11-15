import '../../domain/entities/user.dart';
import '../../domain/entities/user_profile.dart';

/// Production contract for authentication data sources (Wave 3.5).
abstract class AuthRemoteDataSource {
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<User> signInWithEmail({
    required String email,
    required String password,
  });

  Future<User> signInWithGoogle();

  Future<User> signInWithApple();

  Future<void> signOut();

  Future<User?> getCurrentUser();

  Future<bool> isAuthenticated();

  Future<void> deleteAccount();

  Future<void> reauthenticateWithPassword(String password);

  Future<void> reauthenticateWithGoogle();

  Future<void> resetPassword(String email);
}

/// Production contract for remote user profile data sources (Wave 3.5).
abstract class UserProfileRemoteDataSource {
  Future<void> createUserProfile(UserProfile profile);
  Future<UserProfile?> getUserProfile(String userId);
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> deleteUserProfile(String userId);
}

