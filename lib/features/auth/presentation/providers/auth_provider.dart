import 'package:flutter_riverpod/flutter_riverpod.dart';
// Firebase - DISABLED
// import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart';

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
// Datasources
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/firestore_user_datasource.dart';
import '../../data/datasources/mock_auth_datasource.dart';
import '../../data/datasources/mock_user_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

/// Whether the app authenticates against real Firebase (Phase 1 seam).
///
/// Defaults to `false` (mock auth) so behavior is unchanged. Enable with
/// `--dart-define=USE_FIREBASE_AUTH=true` once the Firebase project is
/// configured and `firebase deploy --only firestore:rules,firestore:indexes`
/// has run. Before flipping the default, complete the platform OAuth setup
/// (Android SHA fingerprints, web client, iOS URL scheme/client IDs) and
/// decide the mock-id → Firebase-uid local-data migration story.
const bool kUseFirebaseAuth = bool.fromEnvironment(
  'USE_FIREBASE_AUTH',
  defaultValue: false,
);

// Repository Provider — mock by default, real Firebase behind the flag.
// Both Firebase implementations also implement the mock interfaces, so
// AuthRepositoryImpl is unaffected by the choice.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authDataSource:
        kUseFirebaseAuth ? FirebaseAuthDataSourceImpl() : MockAuthDataSourceImpl(),
    userDataSource:
        kUseFirebaseAuth ? FirestoreUserDataSourceImpl() : MockUserDataSourceImpl(),
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

// Auth State Provider - Returns current user without polling
final authStateProvider = StreamProvider<User?>((ref) async* {
  final repository = ref.watch(authRepositoryProvider);
  
  // Just return the current state once, no polling
  yield await repository.getCurrentUser();
});

// Current User Provider
final currentUserProvider = FutureProvider<User?>((ref) async {
  final useCase = ref.watch(getCurrentUserUseCaseProvider);
  return await useCase();
});

// User Profile Provider (auth account profile, keyed by user id).
//
// Renamed from `userProfileProvider` (Phase 3, F-10): that name
// belongs to the onboarding profile provider every screen actually
// uses; this auth-family one had zero callers but shadowed it in any
// file importing both.
final authUserProfileProvider = FutureProvider.family<UserProfile?, String>((ref, userId) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.getUserProfile(userId);
});

// Is Authenticated Provider
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.isAuthenticated();
});
