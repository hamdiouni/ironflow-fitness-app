import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
// import 'package:google_sign_in/google_sign_in.dart'; // Temporarily disabled
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';

abstract class FirebaseAuthDataSource {
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

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  // final GoogleSignIn? _googleSignIn; // Temporarily disabled

  FirebaseAuthDataSourceImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    // GoogleSignIn? googleSignIn, // Temporarily disabled
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;
        // _googleSignIn = googleSignIn; // Temporarily disabled

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('User creation failed');
      }

      return _mapFirebaseUserToUser(firebaseUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Sign in failed');
      }

      return _mapFirebaseUserToUser(firebaseUser);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  @override
  Future<User> signInWithGoogle() async {
    // TODO: Fix GoogleSignIn API compatibility with google_sign_in 7.x
    throw Exception('Google Sign-In is temporarily disabled. Please use email/password authentication.');
    
    /* Temporarily disabled - needs google_sign_in 7.x API update
    try {
      if (_googleSignIn == null) {
        throw Exception('Google Sign-In is temporarily disabled. Please use email/password authentication.');
      }
      
      final googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Google sign in failed');
      }

      return _mapFirebaseUserToUser(firebaseUser);
    } catch (e) {
      throw Exception('Google sign in error: $e');
    }
    */
  }

  @override
  Future<User> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = firebase_auth.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Apple sign in failed');
      }

      return _mapFirebaseUserToUser(firebaseUser);
    } catch (e) {
      throw Exception('Apple sign in error: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      // Google Sign-In temporarily disabled
      // if (_googleSignIn != null) {
      //   await _googleSignIn!.signOut();
      // }
    } catch (e) {
      throw Exception('Sign out error: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return null;
      }
      return _mapFirebaseUserToUser(firebaseUser);
    } catch (e) {
      throw Exception('Get current user error: $e');
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return _firebaseAuth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } catch (e) {
      throw Exception('Delete account error: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Reset password error: $e');
    }
  }

  User _mapFirebaseUserToUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Exception _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('The password provided is too weak.');
      case 'email-already-in-use':
        return Exception('The account already exists for that email.');
      case 'invalid-email':
        return Exception('The email address is not valid.');
      case 'user-not-found':
        return Exception('No user found for that email.');
      case 'wrong-password':
        return Exception('Wrong password provided for that user.');
      default:
        return Exception('Authentication error: ${e.message}');
    }
  }
}
