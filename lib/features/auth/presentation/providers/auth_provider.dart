import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_email_use_case.dart';
import '../../domain/usecases/sign_up_with_email_use_case.dart';
import '../../domain/usecases/sign_in_with_google_use_case.dart';
import '../../domain/usecases/sign_in_with_apple_use_case.dart';
import '../../domain/usecases/sign_out_use_case.dart';
import '../../domain/usecases/get_current_user_use_case.dart';
import '../../domain/usecases/sign_up_use_case.dart';
import '../../domain/usecases/sign_in_use_case.dart';
// Mock datasources
import '../../data/datasources/mock_auth_datasource.dart';
import '../../data/datasources/mock_user_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/firebase_auth_repository_impl.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/firestore_user_datasource.dart';

// Firebase Auth is the production default so Firestore rules receive a real
// request.auth.uid. Use --dart-define=IRONFLOW_USE_MOCK_AUTH=true for a local
// demo; tests without an initialized Firebase app also fall back to mocks.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  const forceMockAuth = bool.fromEnvironment('IRONFLOW_USE_MOCK_AUTH');
  if (forceMockAuth || Firebase.apps.isEmpty) {
    return AuthRepositoryImpl(
      authDataSource: MockAuthDataSourceImpl(),
      userDataSource: MockUserDataSourceImpl(),
    );
  }

  return FirebaseAuthRepositoryImpl(
    authDataSource: FirebaseAuthDataSourceImpl(
      firebaseAuth: firebase_auth.FirebaseAuth.instance,
    ),
    userDataSource: FirestoreUserDataSourceImpl(),
    firebaseAuth: firebase_auth.FirebaseAuth.instance,
  );
});

// Use Case Providers
final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) {
  return SignInWithEmailUseCase(ref.watch(authRepositoryProvider));
});

final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmailUseCase>((ref) {
  return SignUpWithEmailUseCase(ref.watch(authRepositoryProvider));
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) {
  return SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));
});

final signInWithAppleUseCaseProvider = Provider<SignInWithAppleUseCase>((ref) {
  return SignInWithAppleUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

// Generic use case providers for auth notifier
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

// Auth state changes drive session-dependent repositories and sync wiring.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// Current user is the same auth-state stream; consumers that need a one-time
// value can use `.future`.
final currentUserProvider = authStateProvider;

// User Profile Provider
final userProfileProvider = FutureProvider.family<UserProfile?, String>((ref, userId) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.getUserProfile(userId);
});

// Is Authenticated Provider
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.isAuthenticated();
});
