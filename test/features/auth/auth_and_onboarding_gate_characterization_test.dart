import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/features/auth/data/datasources/mock_auth_datasource.dart';
import 'package:progression_tracker/features/auth/data/datasources/mock_user_datasource.dart';
import 'package:progression_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_in_with_apple_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_in_with_email_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_in_with_google_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_up_with_email_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/update_profile_use_case.dart';

class InMemoryMockAuthDataSource implements MockAuthDataSource {
  User? _currentUser;
  final Map<String, String> _passwords = {};
  final Map<String, User> _usersByEmail = {};
  bool reauthenticatedWithPassword = false;
  bool reauthenticatedWithGoogle = false;
  String? lastResetEmail;

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (_usersByEmail.containsKey(email)) {
      throw Exception('Email already in use');
    }
    final effectiveName = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : email.split('@').first;
    final user = User(
      id: 'uid_${_usersByEmail.length + 1}',
      email: email,
      displayName: effectiveName,
      photoUrl: null,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    _usersByEmail[email] = user;
    _passwords[email] = password;
    _currentUser = user;
    return user;
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final user = _usersByEmail[email];
    if (user == null || _passwords[email] != password) {
      throw Exception('Invalid credentials');
    }
    _currentUser = user;
    return user;
  }

  @override
  Future<User> signInWithGoogle() async {
    final user = User(
      id: 'uid_google_1',
      email: 'google@example.com',
      displayName: 'Google Athlete',
      photoUrl: null,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    _usersByEmail[user.email] = user;
    _currentUser = user;
    return user;
  }

  @override
  Future<User> signInWithApple() async {
    final user = User(
      id: 'uid_apple_1',
      email: 'apple@example.com',
      displayName: 'Apple Athlete',
      photoUrl: null,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
    _usersByEmail[user.email] = user;
    _currentUser = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async => _currentUser;

  @override
  Future<bool> isAuthenticated() async => _currentUser != null;

  @override
  Future<void> deleteAccount() async {
    if (_currentUser != null) {
      _usersByEmail.remove(_currentUser!.email);
      _passwords.remove(_currentUser!.email);
      _currentUser = null;
    }
  }

  @override
  Future<void> reauthenticateWithPassword(String password) async {
    if (_currentUser == null || _passwords[_currentUser!.email] != password) {
      throw Exception('Wrong password');
    }
    reauthenticatedWithPassword = true;
  }

  @override
  Future<void> reauthenticateWithGoogle() async {
    reauthenticatedWithGoogle = true;
  }

  @override
  Future<void> resetPassword(String email) async {
    lastResetEmail = email;
  }
}

class InMemoryMockUserDataSource implements MockUserDataSource {
  final Map<String, UserProfile> profiles = {};

  @override
  Future<void> createUserProfile(UserProfile profile) async {
    profiles[profile.userId] = profile;
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async => profiles[userId];

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    profiles[profile.userId] = profile;
  }

  @override
  Future<void> deleteUserProfile(String userId) async {
    profiles.remove(userId);
  }
}

void main() {
  group('Wave 2.1 — Auth Repository, UseCases & Onboarding Gate Characterization', () {
    late InMemoryMockAuthDataSource authDs;
    late InMemoryMockUserDataSource userDs;
    late AuthRepositoryImpl repo;

    setUp(() {
      authDs = InMemoryMockAuthDataSource();
      userDs = InMemoryMockUserDataSource();
      repo = AuthRepositoryImpl(
        authDataSource: authDs,
        userDataSource: userDs,
      );
    });

    test('signUpWithEmail creates user and default UserProfile, and SignIn/SignOut use cases work', () async {
      final signUp = SignUpWithEmailUseCase(repo);
      final signIn = SignInWithEmailUseCase(repo);
      final getCurrent = GetCurrentUserUseCase(repo);
      final signOut = SignOutUseCase(repo);

      final created = await signUp(
        email: 'athlete@ironflow.app',
        password: 'Password123!',
        confirmPassword: 'Password123!',
      );
      expect(created.email, 'athlete@ironflow.app');
      expect(await repo.isAuthenticated(), isTrue);

      // Default profile was created automatically
      final profile = await repo.getUserProfile(created.id);
      expect(profile, isNotNull);
      expect(profile!.email, 'athlete@ironflow.app');

      // Sign out and sign back in via use cases
      await signOut();
      expect(await getCurrent(), isNull);

      final signedIn = await signIn(
        email: 'athlete@ironflow.app',
        password: 'Password123!',
      );
      expect(signedIn.id, created.id);
      expect((await repo.authStateChanges.first)?.id, created.id);
    });

    test('Google and Apple sign-in create profile only if missing and preserve existing profile', () async {
      final googleSignIn = SignInWithGoogleUseCase(repo);
      final appleSignIn = SignInWithAppleUseCase(repo);
      final updateProfile = UpdateProfileUseCase(repo);

      final gUser = await googleSignIn();
      expect(userDs.profiles.containsKey(gUser.id), isTrue);

      // Update profile with onboarding data
      final updated = userDs.profiles[gUser.id]!.copyWith(
        age: 29,
        fitnessLevel: 'intermediate',
        goals: const ['hypertrophy'],
      );
      await updateProfile(updated);

      // Signing in again with Google does NOT overwrite the existing profile
      await googleSignIn();
      final afterSecondSignIn = await repo.getUserProfile(gUser.id);
      expect(afterSecondSignIn?.age, 29);
      expect(afterSecondSignIn?.fitnessLevel, 'intermediate');

      // Apple sign-in also creates profile on first login
      final aUser = await appleSignIn();
      expect(userDs.profiles.containsKey(aUser.id), isTrue);
    });

    test('SignUpWithEmailUseCase validates inputs and legacy SignUpUseCase/SignInUseCase delegate to repository', () async {
      final validatedSignUp = SignUpWithEmailUseCase(repo);
      final legacySignUp = SignUpUseCase(repo);
      final legacySignIn = SignInUseCase(repo);

      await expectLater(
        validatedSignUp(
          email: 'invalid-email',
          password: 'Password123!',
          confirmPassword: 'Password123!',
        ),
        throwsException,
      );
      await expectLater(
        validatedSignUp(
          email: 'valid@ironflow.app',
          password: '123',
          confirmPassword: '123',
        ),
        throwsException,
      );

      final user = await legacySignUp(
        email: 'valid@ironflow.app',
        password: 'Password123!',
      );
      expect(user.email, 'valid@ironflow.app');

      final signedIn = await legacySignIn(
        email: 'valid@ironflow.app',
        password: 'Password123!',
      );
      expect(signedIn.id, user.id);
    });

    test('reauthentication, password reset, and deleteAccount clean up both profile and auth user', () async {
      final user = await repo.signUpWithEmail(
        email: 'delete_me@ironflow.app',
        password: 'SecretPassword99!',
      );
      expect(userDs.profiles.containsKey(user.id), isTrue);

      await repo.reauthenticateWithPassword('SecretPassword99!');
      expect(authDs.reauthenticatedWithPassword, isTrue);

      await repo.reauthenticateWithGoogle();
      expect(authDs.reauthenticatedWithGoogle, isTrue);

      await repo.resetPassword('delete_me@ironflow.app');
      expect(authDs.lastResetEmail, 'delete_me@ironflow.app');

      await repo.deleteAccount();
      expect(await repo.getCurrentUser(), isNull);
      expect(userDs.profiles.containsKey(user.id), isFalse);
    });

    test('AppRoutes.resolvePostAuthRedirect enforces safe post-auth destination and blocks open redirects', () {
      // Valid internal deep links are preserved
      expect(
        AppRoutes.resolvePostAuthRedirect('/workout/history'),
        '/workout/history',
      );
      expect(
        AppRoutes.resolvePostAuthRedirect('/nutrition?tab=meals'),
        '/nutrition?tab=meals',
      );

      // Null, empty, external, or auth/onboarding/dev-preview paths fall back to home
      expect(AppRoutes.resolvePostAuthRedirect(null), AppRoutes.home);
      expect(AppRoutes.resolvePostAuthRedirect(''), AppRoutes.home);
      expect(
        AppRoutes.resolvePostAuthRedirect('https://evil.example.com'),
        AppRoutes.home,
      );
      expect(
        AppRoutes.resolvePostAuthRedirect('//evil.example.com'),
        AppRoutes.home,
      );
      expect(
        AppRoutes.resolvePostAuthRedirect(AppRoutes.login),
        AppRoutes.home,
      );
      expect(
        AppRoutes.resolvePostAuthRedirect(AppRoutes.onboarding),
        AppRoutes.home,
      );
      expect(
        AppRoutes.resolvePostAuthRedirect(AppRoutes.designPreview),
        AppRoutes.home,
      );
    });
  });
}
