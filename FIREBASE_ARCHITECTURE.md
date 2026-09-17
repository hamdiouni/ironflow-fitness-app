# Firebase Authentication Architecture - IronFlow

## Overview

This document describes the complete Firebase authentication implementation for IronFlow, including architecture, data flow, and integration points.

---

## Architecture Layers

### 1. Presentation Layer
**Location**: `lib/features/auth/presentation/`

#### Screens
- **SplashScreen** (`splash_screen.dart`)
  - Checks authentication status on app launch
  - Shows loading animation
  - Redirects to login or home based on auth state

- **LoginScreen** (`login_screen.dart`)
  - Email/password login form
  - Google Sign-In button
  - Form validation
  - Error handling
  - Navigation to signup

- **SignupScreen** (`signup_screen.dart`)
  - Email/password registration form
  - Name input
  - Password confirmation
  - Google Sign-In button
  - Form validation
  - Navigation to login

#### State Management
- **AuthNotifier** (`auth_notifier.dart`)
  - Manages authentication state
  - Handles sign up, sign in, sign out
  - Provides user-friendly error messages
  - State: `AuthState` (isLoading, user, error, isAuthenticated)

- **Providers** (`auth_provider.dart`)
  - `authNotifierProvider`: Main auth state notifier
  - `authStateProvider`: Stream of Firebase auth changes
  - `currentUserProvider`: Current authenticated user
  - `isAuthenticatedProvider`: Boolean auth status

---

### 2. Domain Layer
**Location**: `lib/features/auth/domain/`

#### Entities
- **User** (`user.dart`)
  ```dart
  class User {
    String id;
    String email;
    String? displayName;
    String? photoUrl;
    DateTime createdAt;
    DateTime updatedAt;
  }
  ```

- **UserProfile** (`user_profile.dart`)
  ```dart
  class UserProfile {
    String userId;
    String email;
    String? name;
    int? age;
    String? gender;
    String? fitnessLevel; // beginner, intermediate, advanced
    List<String>? goals; // strength, hypertrophy, endurance, weight-loss
    List<String>? equipment; // barbell, dumbbell, machine, bodyweight
    DateTime createdAt;
    DateTime updatedAt;
  }
  ```

#### Repository Interface
- **AuthRepository** (`auth_repository.dart`)
  - Abstract interface for authentication operations
  - Methods:
    - `signUpWithEmail(email, password)`
    - `signInWithEmail(email, password)`
    - `signInWithGoogle()`
    - `signInWithApple()`
    - `signOut()`
    - `getCurrentUser()`
    - `isAuthenticated()`
    - `updateProfile(profile)`
    - `getUserProfile(userId)`
    - `deleteAccount()`
    - `resetPassword(email)`

#### Use Cases
- **SignUpUseCase** - Handles user registration
- **SignInUseCase** - Handles user login
- **SignOutUseCase** - Handles user logout
- **UpdateProfileUseCase** - Updates user profile in Firestore

---

### 3. Data Layer
**Location**: `lib/features/auth/data/`

#### Data Sources
- **FirebaseAuthDataSource** (`firebase_auth_datasource.dart`)
  - Interfaces with Firebase Authentication
  - Handles email/password auth
  - Handles Google Sign-In
  - Handles Apple Sign-In
  - Maps Firebase User to domain User entity
  - Provides user-friendly error messages

- **FirestoreUserDataSource** (`firestore_user_datasource.dart`)
  - Interfaces with Cloud Firestore
  - CRUD operations for user profiles
  - Collection: `users/{userId}`

#### Repository Implementation
- **AuthRepositoryImpl** (`auth_repository_impl.dart`)
  - Implements AuthRepository interface
  - Coordinates between auth and Firestore data sources
  - Handles data transformation

---

## Authentication Flow

### 1. App Launch Flow
```
App Start
  ↓
SplashScreen
  ↓
Check Auth Status (authStateProvider)
  ↓
┌─────────────┬─────────────┐
│ Authenticated│ Not Auth    │
└─────────────┴─────────────┘
       ↓              ↓
  Check Onboarding  LoginScreen
       ↓
┌──────────┬──────────┐
│ Complete │ Incomplete│
└──────────┴──────────┘
     ↓          ↓
  HomeScreen  OnboardingScreen
```

### 2. Sign Up Flow
```
SignupScreen
  ↓
User enters: name, email, password
  ↓
Form Validation
  ↓
AuthNotifier.signUpWithEmail()
  ↓
SignUpUseCase
  ↓
AuthRepository.signUpWithEmail()
  ↓
FirebaseAuthDataSource.signUpWithEmail()
  ↓
Firebase Authentication (creates user)
  ↓
Create UserProfile in Firestore
  ↓
Update AuthState (authenticated)
  ↓
Navigate to OnboardingScreen
```

### 3. Sign In Flow
```
LoginScreen
  ↓
User enters: email, password
  ↓
Form Validation
  ↓
AuthNotifier.signInWithEmail()
  ↓
SignInUseCase
  ↓
AuthRepository.signInWithEmail()
  ↓
FirebaseAuthDataSource.signInWithEmail()
  ↓
Firebase Authentication (verifies credentials)
  ↓
Fetch UserProfile from Firestore
  ↓
Update AuthState (authenticated)
  ↓
Navigate to HomeScreen
```

### 4. Google Sign-In Flow
```
LoginScreen/SignupScreen
  ↓
User taps "Continue with Google"
  ↓
AuthNotifier.signInWithGoogle()
  ↓
GoogleSignIn.signIn() (opens Google picker)
  ↓
User selects Google account
  ↓
Get Google auth tokens
  ↓
Firebase Authentication (with Google credential)
  ↓
Check if UserProfile exists in Firestore
  ↓
┌──────────┬──────────┐
│ Exists   │ Not Exists│
└──────────┴──────────┘
     ↓          ↓
  Fetch     Create Profile
     ↓          ↓
Update AuthState (authenticated)
  ↓
Navigate to HomeScreen or OnboardingScreen
```

### 5. Sign Out Flow
```
ProfileScreen
  ↓
User taps "Sign Out"
  ↓
AuthNotifier.signOut()
  ↓
SignOutUseCase
  ↓
AuthRepository.signOut()
  ↓
FirebaseAuthDataSource.signOut()
  ↓
Firebase Authentication (signs out)
  ↓
GoogleSignIn.signOut() (if used)
  ↓
Update AuthState (unauthenticated)
  ↓
Navigate to LoginScreen
```

---

## Router Integration

### Route Protection
The `GoRouter` uses `redirect` to protect routes based on auth state:

```dart
redirect: (context, state) {
  final authState = authStateAsync.valueOrNull;
  final isOnboarded = isOnboardedAsync.valueOrNull ?? false;
  
  // Not authenticated → redirect to login
  if (authState == null && !isAuthRoute) {
    return AppRoutes.login;
  }
  
  // Authenticated but not onboarded → redirect to onboarding
  if (authState != null && !isOnboarded && !isOnboardingRoute) {
    return AppRoutes.onboarding;
  }
  
  // Authenticated and onboarded → allow access
  return null;
}
```

### Routes
- `/` - SplashScreen (checks auth, redirects)
- `/login` - LoginScreen (public)
- `/signup` - SignupScreen (public)
- `/onboarding` - OnboardingScreen (requires auth)
- `/home` - HomeScreen (requires auth + onboarding)
- All other routes require auth + onboarding

---

## Firestore Schema

### users/{userId}
```json
{
  "userId": "string (Firebase Auth UID)",
  "email": "string",
  "name": "string",
  "age": "number (optional)",
  "gender": "string (optional)",
  "fitnessLevel": "string (beginner|intermediate|advanced)",
  "goals": ["string"] (strength, hypertrophy, endurance, weight-loss),
  "equipment": ["string"] (barbell, dumbbell, machine, bodyweight),
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### Security Rules
```javascript
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

---

## Error Handling

### User-Friendly Error Messages
The `AuthNotifier` converts technical Firebase errors to user-friendly messages:

| Firebase Error | User Message |
|----------------|--------------|
| `weak-password` | "Password is too weak. Use at least 6 characters." |
| `email-already-in-use` | "This email is already registered. Try logging in instead." |
| `invalid-email` | "Please enter a valid email address." |
| `user-not-found` | "No account found with this email. Please sign up first." |
| `wrong-password` | "Incorrect password. Please try again." |
| `cancelled` | "Sign in was cancelled." |
| `network` | "Network error. Please check your connection." |
| Other | "An error occurred. Please try again." |

### Error Display
- Errors are shown in a red banner at the top of the form
- Includes an error icon for visual clarity
- Automatically cleared when user retries

---

## State Management

### AuthState
```dart
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;
  final bool isAuthenticated;
}
```

### State Transitions
```
Initial State
  ↓
Loading (isLoading: true)
  ↓
┌─────────────┬─────────────┐
│ Success     │ Error       │
└─────────────┴─────────────┘
       ↓              ↓
Authenticated    Error State
(user: User)     (error: String)
```

---

## Testing Strategy

### Unit Tests
- Test use cases with mocked repositories
- Test repository with mocked data sources
- Test data sources with mocked Firebase

### Widget Tests
- Test login screen UI
- Test signup screen UI
- Test form validation
- Test error display

### Integration Tests
- Test complete sign up flow
- Test complete sign in flow
- Test Google Sign-In flow
- Test sign out flow
- Test route protection

---

## Security Considerations

### 1. Password Security
- Minimum 6 characters enforced
- Passwords never stored locally
- Firebase handles password hashing

### 2. Token Management
- Firebase handles token refresh automatically
- Tokens stored securely by Firebase SDK
- No manual token management needed

### 3. Data Privacy
- User profiles only accessible by owner (Firestore rules)
- Email/password never logged
- Sensitive data encrypted in transit (HTTPS)

### 4. Session Management
- Sessions persist across app restarts
- Automatic token refresh
- Sign out clears all session data

---

## Performance Optimizations

### 1. Lazy Loading
- Auth state loaded only when needed
- User profile fetched after authentication
- Firestore queries optimized with indexes

### 2. Caching
- Firebase SDK caches auth state
- Firestore offline persistence enabled
- Reduces network requests

### 3. Error Recovery
- Automatic retry for network errors
- Graceful degradation when offline
- Clear error messages for user action

---

## Future Enhancements

### 1. Additional Auth Methods
- Apple Sign-In (already implemented, needs testing)
- Facebook Login
- Phone number authentication

### 2. Security Features
- Two-factor authentication
- Email verification
- Password strength meter
- Biometric authentication

### 3. User Management
- Account deletion
- Password reset
- Email change
- Profile picture upload

### 4. Analytics
- Track sign up conversion
- Monitor auth errors
- Measure session duration

---

## Troubleshooting

### Common Issues

**1. Firebase not initialized**
- Ensure `Firebase.initializeApp()` is called in `main.dart`
- Check `firebase_options.dart` has correct credentials
- Verify `google-services.json` is in `android/app/`

**2. Google Sign-In fails**
- Check SHA-1 fingerprint is added in Firebase Console
- Verify Google Sign-In is enabled in Firebase Console
- Ensure `google-services.json` is up to date

**3. Firestore permission denied**
- Check security rules in Firebase Console
- Verify user is authenticated before accessing Firestore
- Ensure `userId` matches `request.auth.uid`

**4. Navigation issues**
- Check `GoRouter` redirect logic
- Verify auth state is being watched correctly
- Ensure routes are defined correctly

---

## Dependencies

```yaml
dependencies:
  firebase_core: ^3.1.0
  firebase_auth: ^5.1.0
  cloud_firestore: ^5.0.0
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.1
  flutter_riverpod: ^2.6.1
  go_router: ^14.6.2
  freezed_annotation: ^2.4.4
```

---

## Summary

The Firebase authentication system is fully implemented with:
- ✅ Email/password authentication
- ✅ Google Sign-In
- ✅ Apple Sign-In (needs testing)
- ✅ User profile management in Firestore
- ✅ Persistent login sessions
- ✅ Route protection
- ✅ Error handling
- ✅ Loading states
- ✅ Modern UI screens

**Next Steps**:
1. Configure Firebase project (follow FIREBASE_SETUP_INSTRUCTIONS.md)
2. Test authentication flows
3. Verify Firestore security rules
4. Test on multiple devices
5. Enable offline persistence
