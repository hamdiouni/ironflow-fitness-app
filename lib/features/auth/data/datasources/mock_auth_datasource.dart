import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'auth_session_storage.dart';

/// Simple mock authentication datasource for development
/// No Firebase, no external dependencies - just works!
abstract class MockAuthDataSource {
  Future<User> signUpWithEmail({
    required String email,
    required String password,
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

  Future<void> resetPassword(String email);
}

class MockAuthDataSourceImpl implements MockAuthDataSource {
  final AuthSessionStorage _sessionStorage = AuthSessionStorage();
  
  // Simple in-memory storage for passwords
  static final Map<String, String> _users = {
    'demo@ironflow.com': 'password123',
  };

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (_users.containsKey(email)) {
      throw Exception('Account already exists for that email.');
    }

    _users[email] = password;
    
    final user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: email.split('@')[0],
      photoUrl: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save session
    await _sessionStorage.saveSession(user);
    
    return user;
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (!_users.containsKey(email)) {
      throw Exception('No user found for that email.');
    }

    if (_users[email] != password) {
      throw Exception('Wrong password provided for that user.');
    }

    final user = User(
      id: 'user_${email.hashCode}',
      email: email,
      displayName: email.split('@')[0],
      photoUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );

    // Save session
    await _sessionStorage.saveSession(user);
    
    return user;
  }

  @override
  Future<User> signInWithGoogle() async {
    if (kDebugMode) {
      print('📊 [Auth] Starting Google Sign-In...');
    }

    try {
      // Initialize GoogleSignIn with proper configuration
      // For web: requires Web Client ID in web/index.html
      // For Android: requires SHA-1 fingerprint configured in Google Cloud Console
      // For iOS: requires iOS Client ID in ios/Runner/Info.plist
      
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
      );

      // NOTE: Using signIn() method which is deprecated on web
      // The recommended approach is to use renderButton() for web
      // However, signIn() still works and provides a consistent API across platforms
      // TODO: Migrate to renderButton() for web-specific implementation
      // See: https://pub.dev/packages/google_sign_in_web#migrating-to-v011-and-v012-google-identity-services
      
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        if (kDebugMode) {
          print('⚠️ [Auth] User cancelled Google Sign-In');
        }
        throw Exception('Sign in cancelled');
      }

      if (kDebugMode) {
        print('✅ [Auth] Google account selected: ${googleUser.email}');
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (kDebugMode) {
        print('✅ [Auth] Got authentication tokens');
      }

      // Create user from Google account
      final user = User(
        id: 'google_${googleUser.id}',
        email: googleUser.email,
        displayName: googleUser.displayName ?? googleUser.email.split('@')[0],
        photoUrl: googleUser.photoUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save session
      await _sessionStorage.saveSession(user);
      
      if (kDebugMode) {
        print('✅ [Auth] Google Sign-In successful');
        print('🔍 [Auth] User: ${user.displayName}');
      }

      return user;
    } on Exception catch (e) {
      if (kDebugMode) {
        print('❌ [Auth] Google Sign-In failed: $e');
        print('🔍 [Auth] Stack trace: ${StackTrace.current}');
      }
      
      // Provide helpful error messages based on the error
      final errorMessage = e.toString();
      if (errorMessage.contains('not configured')) {
        throw Exception(
          'Google Sign-In is not configured yet. '
          'Please add your Web Client ID to web/index.html and configure Android/iOS credentials.'
        );
      }
      
      rethrow;
    }
  }

  @override
  Future<User> signInWithApple() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Throw a user-friendly error
    throw Exception('Apple Sign-In is not configured yet. Please use email/password to sign in.');
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Clear session
    await _sessionStorage.clearSession();
  }

  @override
  Future<User?> getCurrentUser() async {
    // Load from session storage
    return await _sessionStorage.loadSession();
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _sessionStorage.isLoggedIn();
  }

  @override
  Future<void> deleteAccount() async {
    final user = await getCurrentUser();
    if (user != null) {
      _users.remove(user.email);
      await _sessionStorage.clearSession();
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!_users.containsKey(email)) {
      throw Exception('No user found for that email.');
    }
    // In a real app, this would send an email
    print('Password reset email sent to $email (mock)');
  }
}
