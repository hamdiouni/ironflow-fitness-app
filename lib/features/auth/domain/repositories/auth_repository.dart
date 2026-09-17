import '../entities/user.dart';
import '../entities/user_profile.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Sign up with email and password
  Future<User> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with email and password
  Future<User> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with Google
  Future<User> signInWithGoogle();

  /// Sign in with Apple
  Future<User> signInWithApple();

  /// Sign out
  Future<void> signOut();

  /// Get current authenticated user
  Future<User?> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Delete user account
  Future<void> deleteAccount();

  /// Reset password
  Future<void> resetPassword(String email);

  /// Get user profile from Firestore
  Future<UserProfile?> getUserProfile(String userId);

  /// Save user profile to Firestore
  Future<void> saveUserProfile(UserProfile profile);

  /// Update user profile in Firestore
  Future<void> updateUserProfile(UserProfile profile);

  /// Stream of auth state changes
  Stream<User?> get authStateChanges;
}
