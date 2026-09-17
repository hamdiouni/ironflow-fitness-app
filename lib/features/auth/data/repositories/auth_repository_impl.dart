import '../../domain/entities/user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
// Firebase datasources - DISABLED
// import '../datasources/firebase_auth_datasource.dart';
// import '../datasources/firestore_user_datasource.dart';
// Mock datasources for development
import '../datasources/mock_auth_datasource.dart';
import '../datasources/mock_user_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final MockAuthDataSource _authDataSource;
  final MockUserDataSource _userDataSource;

  AuthRepositoryImpl({
    required MockAuthDataSource authDataSource,
    required MockUserDataSource userDataSource,
  })  : _authDataSource = authDataSource,
        _userDataSource = userDataSource;

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authDataSource.signUpWithEmail(
        email: email,
        password: password,
      );

      // Create default user profile
      final profile = UserProfile(
        userId: user.id,
        email: user.email,
        name: user.displayName,
        age: null,
        gender: null,
        fitnessLevel: null,
        goals: null,
        equipment: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _userDataSource.createUserProfile(profile);

      return user;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _authDataSource.signInWithEmail(
      email: email,
      password: password,
    );
  }

  @override
  Future<User> signInWithGoogle() async {
    // Don't wrap the exception - let the original error message pass through
    final user = await _authDataSource.signInWithGoogle();

    // Check if profile exists, create if not
    final existingProfile = await _userDataSource.getUserProfile(user.id);
    if (existingProfile == null) {
      final profile = UserProfile(
        userId: user.id,
        email: user.email,
        name: user.displayName,
        age: null,
        gender: null,
        fitnessLevel: null,
        goals: null,
        equipment: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _userDataSource.createUserProfile(profile);
    }

    return user;
  }

  @override
  Future<User> signInWithApple() async {
    // Don't wrap the exception - let the original error message pass through
    final user = await _authDataSource.signInWithApple();

    // Check if profile exists, create if not
    final existingProfile = await _userDataSource.getUserProfile(user.id);
    if (existingProfile == null) {
      final profile = UserProfile(
        userId: user.id,
        email: user.email,
        name: user.displayName,
        age: null,
        gender: null,
        fitnessLevel: null,
        goals: null,
        equipment: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _userDataSource.createUserProfile(profile);
    }

    return user;
  }

  @override
  Future<void> signOut() async {
    await _authDataSource.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await _authDataSource.getCurrentUser();
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _authDataSource.isAuthenticated();
  }

  @override
  Future<void> deleteAccount() async {
    final user = await getCurrentUser();
    if (user != null) {
      await _userDataSource.deleteUserProfile(user.id);
      await _authDataSource.deleteAccount();
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    await _authDataSource.resetPassword(email);
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    return await _userDataSource.getUserProfile(userId);
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    await _userDataSource.createUserProfile(profile);
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await _userDataSource.updateUserProfile(profile);
  }

  @override
  Stream<User?> get authStateChanges {
    // Simple stream that emits current user
    return Stream.value(_authDataSource.getCurrentUser()).asyncMap((future) => future);
  }
}
