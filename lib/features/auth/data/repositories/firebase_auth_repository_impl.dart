import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart' as domain;
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/firestore_user_datasource.dart';

/// Production authentication repository backed by Firebase Auth and Firestore.
///
/// The Auth UID is the identity used by FirestorePaths and the security rules.
/// The mock repository remains available for tests and explicit demo builds.
class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _authDataSource;
  final FirestoreUserDataSource _userDataSource;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthRepositoryImpl({
    FirebaseAuthDataSource? authDataSource,
    FirestoreUserDataSource? userDataSource,
    firebase_auth.FirebaseAuth? firebaseAuth,
  })  : _authDataSource = authDataSource ?? FirebaseAuthDataSourceImpl(),
        _userDataSource = userDataSource ?? FirestoreUserDataSourceImpl(),
        _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  @override
  Future<domain.User> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final user = await _authDataSource.signUpWithEmail(
      email: email,
      password: password,
    );
    await _ensureProfile(user);
    return user;
  }

  @override
  Future<domain.User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final user = await _authDataSource.signInWithEmail(
      email: email,
      password: password,
    );
    await _ensureProfile(user);
    return user;
  }

  @override
  Future<domain.User> signInWithGoogle() async {
    final user = await _authDataSource.signInWithGoogle();
    await _ensureProfile(user);
    return user;
  }

  @override
  Future<domain.User> signInWithApple() async {
    final user = await _authDataSource.signInWithApple();
    await _ensureProfile(user);
    return user;
  }

  Future<void> _ensureProfile(domain.User user) async {
    try {
      if (await _userDataSource.getUserProfile(user.id) != null) return;
      await _userDataSource.saveUserProfile(
        UserProfile(
          userId: user.id,
          email: user.email,
          name: user.displayName,
          age: null,
          gender: null,
          fitnessLevel: null,
          goals: null,
          equipment: null,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
        ),
      );
    } catch (error) {
      // Authentication must not fail only because profile persistence is
      // temporarily unavailable. Profile reads/writes can be retried later.
      if (kDebugMode) {
        debugPrint('Could not initialize Firestore profile for ${user.id}: $error');
      }
    }
  }

  @override
  Future<void> signOut() => _authDataSource.signOut();

  @override
  Future<domain.User?> getCurrentUser() async {
    final user = await _authDataSource.getCurrentUser();
    if (user != null) return user;
    final firebaseUser = _firebaseAuth.currentUser;
    return firebaseUser == null ? null : _mapFirebaseUser(firebaseUser);
  }

  @override
  Future<bool> isAuthenticated() => _authDataSource.isAuthenticated();

  @override
  Future<void> deleteAccount() async {
    final user = await getCurrentUser();
    if (user != null) {
      try {
        await _userDataSource.deleteUserProfile(user.id);
      } catch (error) {
        if (kDebugMode) {
          debugPrint('Could not delete Firestore profile: $error');
        }
      }
    }
    await _authDataSource.deleteAccount();
  }

  @override
  Future<void> resetPassword(String email) =>
      _authDataSource.resetPassword(email);

  @override
  Future<UserProfile?> getUserProfile(String userId) =>
      _userDataSource.getUserProfile(userId);

  @override
  Future<void> saveUserProfile(UserProfile profile) =>
      _userDataSource.saveUserProfile(profile);

  @override
  Future<void> updateUserProfile(UserProfile profile) =>
      _userDataSource.updateUserProfile(profile);

  @override
  Stream<domain.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(
            (user) => user == null ? null : _mapFirebaseUser(user),
          );

  domain.User _mapFirebaseUser(firebase_auth.User user) {
    final now = DateTime.now();
    return domain.User(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? now,
      updatedAt: user.metadata.lastSignInTime ?? now,
    );
  }
}
