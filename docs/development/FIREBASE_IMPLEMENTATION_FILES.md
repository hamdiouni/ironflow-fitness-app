# Firebase Implementation - Complete File List

**Status**: ✅ Core files created, remaining files documented below

---

## ✅ Files Created

1. `lib/features/auth/domain/repositories/auth_repository.dart`
2. `lib/features/auth/domain/usecases/sign_in_with_email_use_case.dart`
3. `lib/features/auth/domain/usecases/sign_up_with_email_use_case.dart`
4. `lib/features/auth/domain/usecases/sign_in_with_google_use_case.dart`
5. `lib/features/auth/domain/usecases/sign_in_with_apple_use_case.dart`
6. `lib/features/auth/domain/usecases/sign_out_use_case.dart`
7. `lib/features/auth/domain/usecases/get_current_user_use_case.dart`

---

## 📋 Remaining Files to Create

### Auth Data Layer

#### `lib/features/auth/data/datasources/firestore_user_datasource.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile.dart';

abstract class FirestoreUserDataSource {
  Future<UserProfile?> getUserProfile(String userId);
  Future<void> saveUserProfile(UserProfile profile);
  Future<void> updateUserProfile(UserProfile profile);
  Future<void> deleteUserProfile(String userId);
}

class FirestoreUserDataSourceImpl implements FirestoreUserDataSource {
  final FirebaseFirestore _firestore;

  FirestoreUserDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('data')
          .get();

      if (!doc.exists) return null;

      return UserProfile.fromJson(doc.data()!);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.userId)
          .collection('profile')
          .doc('data')
          .set(profile.toJson());
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.userId)
          .collection('profile')
          .doc('data')
          .update(profile.toJson());
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('profile')
          .doc('data')
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }
}
```

#### `lib/features/auth/data/repositories/auth_repository_impl.dart`

```dart
import '../../domain/entities/user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/firestore_user_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _authDataSource;
  final FirestoreUserDataSource _userDataSource;

  AuthRepositoryImpl({
    required FirebaseAuthDataSource authDataSource,
    required FirestoreUserDataSource userDataSource,
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

      await _userDataSource.saveUserProfile(profile);

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
    try {
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
        await _userDataSource.saveUserProfile(profile);
      }

      return user;
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  @override
  Future<User> signInWithApple() async {
    try {
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
        await _userDataSource.saveUserProfile(profile);
      }

      return user;
    } catch (e) {
      throw Exception('Apple sign in failed: $e');
    }
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
    await _userDataSource.saveUserProfile(profile);
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    await _userDataSource.updateUserProfile(profile);
  }

  @override
  Stream<User?> get authStateChanges {
    // Implement auth state changes stream
    // This would listen to Firebase auth state changes
    throw UnimplementedError('Auth state changes stream not implemented');
  }
}
```

### Auth Presentation Layer

#### `lib/features/auth/presentation/providers/auth_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_email_use_case.dart';
import '../../domain/usecases/sign_up_with_email_use_case.dart';
import '../../domain/usecases/sign_in_with_google_use_case.dart';
import '../../domain/usecases/sign_in_with_apple_use_case.dart';
import '../../domain/usecases/sign_out_use_case.dart';
import '../../domain/usecases/get_current_user_use_case.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/datasources/firestore_user_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authDataSource: FirebaseAuthDataSourceImpl(
      firebaseAuth: firebase_auth.FirebaseAuth.instance,
      googleSignIn: GoogleSignIn(),
    ),
    userDataSource: FirestoreUserDataSourceImpl(
      firestore: FirebaseFirestore.instance,
    ),
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

// Auth State Provider
final authStateProvider = StreamProvider<User?>((ref) async* {
  final authRepository = ref.watch(authRepositoryProvider);
  
  // Listen to Firebase auth state changes
  await for (final firebaseUser in firebase_auth.FirebaseAuth.instance.authStateChanges()) {
    if (firebaseUser == null) {
      yield null;
    } else {
      yield User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }
});

// Current User Provider
final currentUserProvider = FutureProvider<User?>((ref) async {
  final useCase = ref.watch(getCurrentUserUseCaseProvider);
  return await useCase();
});

// User Profile Provider
final userProfileProvider = FutureProvider.family<UserProfile?, String>((ref, userId) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.getUserProfile(userId);
});
```

---

## 🔄 Updated Sync Service Integration

The sync service needs to be updated to work with the auth system. Here's the key integration:

```dart
// In sync_provider.dart
final syncServiceProvider = Provider<SyncService>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return SyncService(
    syncQueue: HiveSyncQueueDataSource(),
    firestoreSync: FirestoreSyncDataSource(),
    hiveWorkouts: HiveWorkoutDataSource(),
    hivePrograms: HiveActiveProgramDataSource(),
  );
});

// Trigger sync when user logs in
final syncTriggerProvider = Provider<void Function()>((ref) {
  return () async {
    final authState = ref.read(authStateProvider);
    await authState.when(
      data: (user) async {
        if (user != null) {
          await ref.read(syncServiceProvider).syncAll(userId: user.id);
        }
      },
      loading: () {},
      error: (_, __) {},
    );
  };
});
```

---

## 🎯 Quick Start Commands

### 1. Generate Freezed Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Configure Firebase
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

### 3. Update Firebase Options
The `flutterfire configure` command will automatically update `lib/firebase_options.dart` with your project credentials.

### 4. Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### 5. Deploy Storage Rules
```bash
firebase deploy --only storage
```

---

## 🧪 Testing

### Test Auth Flow
```dart
// Test sign up
final user = await ref.read(signUpWithEmailUseCaseProvider)(
  email: 'test@example.com',
  password: 'password123',
  confirmPassword: 'password123',
);

// Test sign in
final user = await ref.read(signInWithEmailUseCaseProvider)(
  email: 'test@example.com',
  password: 'password123',
);

// Test Google sign in
final user = await ref.read(signInWithGoogleUseCaseProvider)();

// Test sign out
await ref.read(signOutUseCaseProvider)();
```

### Test Sync
```dart
// Trigger manual sync
ref.read(syncTriggerProvider)();

// Watch sync status
final syncStatus = ref.watch(syncStatusStreamProvider);
syncStatus.when(
  data: (status) => print('Syncing: ${status.isSyncing}'),
  loading: () => print('Loading...'),
  error: (e, _) => print('Error: $e'),
);
```

---

## ✅ Implementation Checklist

- [x] Auth domain layer (repositories, use cases, entities)
- [x] Auth data layer structure documented
- [x] Auth presentation layer structure documented
- [x] Firestore structure defined
- [x] Security rules defined
- [x] Storage rules defined
- [x] Sync integration documented
- [ ] Create remaining data layer files
- [ ] Create remaining presentation layer files
- [ ] Update existing screens with auth
- [ ] Test auth flow
- [ ] Test sync flow
- [ ] Deploy to Firebase

---

## 📚 Next Steps

1. **Create the remaining files** listed above
2. **Update existing screens** (login, signup, splash) to use new providers
3. **Test authentication** with all three methods
4. **Test sync** with real Firebase project
5. **Deploy Firestore and Storage rules**
6. **Monitor Firebase usage** in console

---

**Status**: Core architecture complete, ready for full implementation!
