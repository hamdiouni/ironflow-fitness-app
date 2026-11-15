import 'package:hive/hive.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../datasources/auth_session_storage.dart';
import '../services/local_sample_data_seeder.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authDataSource;
  final UserProfileRemoteDataSource _userDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource authDataSource,
    required UserProfileRemoteDataSource userDataSource,
  })  : _authDataSource = authDataSource,
        _userDataSource = userDataSource;

  Future<void> _saveLocalSessionBestEffort(User user) async {
    try {
      if (Hive.isBoxOpen('auth_session')) {
        await AuthSessionStorage().saveSession(user);
      }
    } catch (_) {}
  }

  Future<void> _clearLocalSessionBestEffort() async {
    try {
      if (Hive.isBoxOpen('auth_session')) {
        await AuthSessionStorage().clearSession();
      }
    } catch (_) {}
  }

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final user = await _authDataSource.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Best-effort cloud profile creation so a newly created Auth account
      // is never stranded if Firestore is offline or restricted.
      try {
        final effectiveName = displayName?.trim().isNotEmpty == true
            ? displayName!.trim()
            : user.displayName;
        final profile = UserProfile(
          userId: user.id,
          email: user.email,
          name: effectiveName,
          age: null,
          gender: null,
          fitnessLevel: null,
          goals: null,
          equipment: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _userDataSource.createUserProfile(profile);
      } catch (_) {}

      final effectiveUser = (user.displayName == null &&
              displayName?.trim().isNotEmpty == true)
          ? user.copyWith(displayName: displayName!.trim())
          : user;

      await _saveLocalSessionBestEffort(effectiveUser);
      return effectiveUser;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final user = await _authDataSource.signInWithEmail(
      email: email,
      password: password,
    );
    await _saveLocalSessionBestEffort(user);
    return user;
  }

  @override
  Future<User> signInWithGoogle() async {
    final user = await _authDataSource.signInWithGoogle();

    try {
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
    } catch (_) {}

    await _saveLocalSessionBestEffort(user);
    return user;
  }

  @override
  Future<User> signInWithApple() async {
    final user = await _authDataSource.signInWithApple();

    try {
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
    } catch (_) {}

    await _saveLocalSessionBestEffort(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await _clearLocalSessionBestEffort();
    try {
      await _authDataSource.signOut();
    } catch (_) {}
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final remoteUser = await _authDataSource.getCurrentUser();
      if (remoteUser != null) return remoteUser;
    } catch (_) {}

    try {
      if (Hive.isBoxOpen('auth_session')) {
        final localUser = await AuthSessionStorage().loadSession();
        if (localUser != null && isLocalOnlyUserId(localUser.id)) {
          return localUser;
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<bool> isAuthenticated() async {
    final current = await getCurrentUser();
    return current != null;
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
  Future<void> reauthenticateWithPassword(String password) async {
    await _authDataSource.reauthenticateWithPassword(password);
  }

  @override
  Future<void> reauthenticateWithGoogle() async {
    await _authDataSource.reauthenticateWithGoogle();
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
