import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/providers/analytics_provider.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/core/services/analytics_service.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:progression_tracker/features/auth/presentation/screens/signup_screen.dart';
import 'package:progression_tracker/features/onboarding/data/user_profile_storage.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart'
    as onboarding;
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

class _InMemoryAuthRepo implements AuthRepository {
  User? currentUser;
  Object? signUpError;
  Object? googleError;
  int signUpCalls = 0;
  String? lastDisplayName;

  @override
  Future<User?> getCurrentUser() async => currentUser;

  @override
  Future<bool> isAuthenticated() async => currentUser != null;

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    signUpCalls++;
    lastDisplayName = displayName;
    if (signUpError != null) {
      throw signUpError!;
    }
    final user = User(
      id: 'uid-signup-1',
      email: email,
      displayName: displayName ?? email.split('@').first,
      photoUrl: null,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    currentUser = user;
    return user;
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<User> signInWithGoogle() async {
    if (googleError != null) {
      throw googleError!;
    }
    final user = User(
      id: 'uid-google-1',
      email: 'google@ironflow.test',
      displayName: 'Google Athlete',
      photoUrl: null,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    currentUser = user;
    return user;
  }

  @override
  Future<User> signInWithApple() async => throw UnimplementedError();

  @override
  Future<void> signOut() async {
    currentUser = null;
  }

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> deleteAccount() async {
    currentUser = null;
  }

  @override
  Future<void> reauthenticateWithPassword(String password) async {}

  @override
  Future<void> reauthenticateWithGoogle() async {}

  @override
  Future<UserProfile?> getUserProfile(String userId) async => UserProfile(
        userId: userId,
        email: '$userId@ironflow.test',
        name: 'Profile $userId',
        age: null,
        gender: null,
        fitnessLevel: null,
        goals: null,
        equipment: null,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

  @override
  Future<void> saveUserProfile(UserProfile profile) async {}

  @override
  Future<void> updateUserProfile(UserProfile profile) async {}

  @override
  Stream<User?> get authStateChanges => Stream.value(currentUser);
}

class _FakeProfileStorage extends UserProfileStorage {
  bool onboarded = false;

  @override
  Future<bool> isOnboarded({String? userId}) async => onboarded;

  @override
  Future<onboarding.UserProfile?> loadProfile({String? userId}) async => null;
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier(AuthRepository repo)
      : super(
          signUpUseCase: SignUpUseCase(repo),
          signInUseCase: SignInUseCase(repo),
          signOutUseCase: SignOutUseCase(repo),
        );
}

Widget _buildRouterApp({
  required _InMemoryAuthRepo authRepo,
  required _FakeProfileStorage profileStorage,
}) {
  final router = GoRouter(
    initialLocation: AppRoutes.signup,
    routes: [
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const Scaffold(body: Text('LOGIN SCREEN')),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) =>
            const Scaffold(body: Text('ONBOARDING SCREEN')),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const Scaffold(body: Text('HOME SCREEN')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(authRepo),
      authNotifierProvider.overrideWith(() => _TestAuthNotifier(authRepo)),
      userProfileStorageProvider.overrideWithValue(profileStorage),
      analyticsServiceProvider.overrideWithValue(
        AnalyticsService.forTesting(isAnalyticsEnabled: () async => false),
      ),
    ],
    child: MaterialApp.router(
      theme: ThemeData.dark().copyWith(extensions: [AppThemeTokens.dark]),
      routerConfig: router,
    ),
  );
}

void main() {
  setUp(() {
    AppHaptics.shared = AppHaptics(isEnabled: false);
  });

  group('Wave 2.2 — SignupScreen & AuthNotifier Characterization', () {
    testWidgets('validates empty fields and mismatched passwords before submit',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final authRepo = _InMemoryAuthRepo();
      await tester.pumpWidget(
        _buildRouterApp(
          authRepo: authRepo,
          profileStorage: _FakeProfileStorage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Start Your Journey'), findsOneWidget);

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
      expect(authRepo.signUpCalls, 0);

      // Mismatch password validation
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Jordan Athlete');
      await tester.enterText(fields.at(1), 'jordan@ironflow.test');
      await tester.enterText(fields.at(2), 'StrongPass1!');
      await tester.enterText(fields.at(3), 'DifferentPass!');

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(authRepo.signUpCalls, 0);
    });

    testWidgets(
        'submits valid signup with display name and routes new user to onboarding',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final authRepo = _InMemoryAuthRepo();
      final profileStorage = _FakeProfileStorage()..onboarded = false;
      await tester.pumpWidget(
        _buildRouterApp(
          authRepo: authRepo,
          profileStorage: profileStorage,
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Alex Mercer');
      await tester.enterText(fields.at(1), 'alex@ironflow.test');
      await tester.enterText(fields.at(2), 'Password123!');
      await tester.enterText(fields.at(3), 'Password123!');

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(authRepo.signUpCalls, 1);
      expect(authRepo.lastDisplayName, 'Alex Mercer');
      expect(find.text('ONBOARDING SCREEN'), findsOneWidget);
    });

    testWidgets('displays error banner when email signup fails', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final authRepo = _InMemoryAuthRepo()
        ..signUpError = Exception('email-already-in-use');
      await tester.pumpWidget(
        _buildRouterApp(
          authRepo: authRepo,
          profileStorage: _FakeProfileStorage(),
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(1), 'taken@ironflow.test');
      await tester.enterText(fields.at(2), 'Password123!');
      await tester.enterText(fields.at(3), 'Password123!');

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(
        find.text('This email is already registered. Try logging in instead.'),
        findsOneWidget,
      );
    });

    test('AuthNotifier handles Google cancel gracefully, sets friendly errors, and resolves authUserProfileProvider',
        () async {
      final repo = _InMemoryAuthRepo();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repo),
          authNotifierProvider.overrideWith(() => _TestAuthNotifier(repo)),
          analyticsServiceProvider.overrideWithValue(
            AnalyticsService.forTesting(isAnalyticsEnabled: () async => false),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Cancelled Google sign-in does not rethrow or populate error state.
      repo.googleError = Exception('popup-closed-by-user');
      await container.read(authNotifierProvider.notifier).signInWithGoogle();
      expect(container.read(authNotifierProvider).isAuthenticated, isFalse);
      expect(container.read(authNotifierProvider).error, isNull);

      // Non-cancel Google error sets error and clearError resets it.
      repo.googleError = Exception('network failure');
      await expectLater(
        () => container.read(authNotifierProvider.notifier).signInWithGoogle(),
        throwsException,
      );
      expect(
        container.read(authNotifierProvider).error,
        'Network error. Please check your connection.',
      );
      container.read(authNotifierProvider.notifier).clearError();
      expect(container.read(authNotifierProvider).error, isNull);

      // authUserProfileProvider fetches by user id cleanly.
      final profile = await container.read(authUserProfileProvider('u-99').future);
      expect(profile?.name, 'Profile u-99');
    });
  });
}
