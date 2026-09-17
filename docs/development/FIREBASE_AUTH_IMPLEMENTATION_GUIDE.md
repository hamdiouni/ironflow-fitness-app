# Firebase Authentication Implementation Guide

## Overview
This guide provides a complete Firebase authentication implementation for IronFlow with email/password and Google Sign-In.

---

## 1. Firebase Configuration

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name: "IronFlow" (or your preferred name)
4. Enable Google Analytics (optional)
5. Create project

### Step 2: Add Android App
1. Click "Add app" → Android
2. Package name: `com.progressiontracker.progression_tracker`
3. Download `google-services.json`
4. Place in `android/app/google-services.json`

### Step 3: Add Web App
1. Click "Add app" → Web
2. App nickname: "IronFlow Web"
3. Copy the Firebase config

### Step 4: Enable Authentication Methods
1. Go to Authentication → Sign-in method
2. Enable:
   - Email/Password
   - Google
   - (Optional) Apple

### Step 5: Create Firestore Database
1. Go to Firestore Database
2. Click "Create database"
3. Start in production mode
4. Choose location (closest to users)

### Step 6: Set Firestore Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // User profiles collection
    match /user_profiles/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Workouts collection
    match /workouts/{workoutId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow write: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
    
    // Programs collection
    match /programs/{programId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow write: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
    
    // Nutrition logs collection
    match /nutrition_logs/{logId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow write: if request.auth != null && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## 2. Update firebase_options.dart

Replace the placeholder values with your actual Firebase config:

```dart
// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Replace with your actual Firebase config from Firebase Console
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    measurementId: 'YOUR_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.progressiontracker.progressionTracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.progressiontracker.progressionTracker.macos',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY',
    appId: 'YOUR_WINDOWS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );
}
```

---

## 3. Firestore Schema

### Collections Structure

```
firestore/
├── users/
│   └── {userId}/
│       ├── id: string
│       ├── email: string
│       ├── displayName: string?
│       ├── photoUrl: string?
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
├── user_profiles/
│   └── {userId}/
│       ├── userId: string
│       ├── email: string
│       ├── name: string?
│       ├── age: number?
│       ├── gender: string?
│       ├── fitnessLevel: string? (beginner|intermediate|advanced)
│       ├── goals: array<string>? (strength, hypertrophy, endurance, weight-loss)
│       ├── equipment: array<string>? (barbell, dumbbell, machine, bodyweight)
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
├── workouts/
│   └── {workoutId}/
│       ├── id: string
│       ├── userId: string
│       ├── date: timestamp
│       ├── exercises: array
│       ├── duration: number
│       ├── totalVolume: number
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
├── programs/
│   └── {programId}/
│       ├── id: string
│       ├── userId: string
│       ├── name: string
│       ├── days: array
│       ├── createdAt: timestamp
│       └── updatedAt: timestamp
│
└── nutrition_logs/
    └── {logId}/
        ├── id: string
        ├── userId: string
        ├── date: timestamp
        ├── meals: array
        ├── totalCalories: number
        ├── totalProtein: number
        ├── totalCarbs: number
        ├── totalFats: number
        ├── createdAt: timestamp
        └── updatedAt: timestamp
```

---

## 4. Architecture Overview

### Auth Flow
```
App Start
    ↓
Splash Screen (checks auth state)
    ↓
    ├─→ Not Authenticated → Auth Screen (Login/Signup)
    │                           ↓
    │                       Login Success
    │                           ↓
    └─→ Authenticated ──────→ Check Onboarding
                                ↓
                                ├─→ Not Onboarded → Onboarding Flow
                                │                       ↓
                                │                   Generate Program
                                │                       ↓
                                └─→ Onboarded ──────→ Home Screen
```

### Provider Structure
```
authStateProvider (StreamProvider)
    ↓
    ├─→ User? (Firebase auth state)
    │
currentUserProvider (FutureProvider)
    ↓
    ├─→ User? (domain entity)
    │
isAuthenticatedProvider (FutureProvider)
    ↓
    ├─→ bool
    │
authNotifierProvider (StateNotifierProvider)
    ↓
    ├─→ AuthState (idle, loading, authenticated, error)
    │
    └─→ Methods:
        ├─ signUpWithEmail()
        ├─ signInWithEmail()
        ├─ signInWithGoogle()
        ├─ signOut()
        └─ resetPassword()
```

---

## 5. Implementation Checklist

### Phase 1: Core Auth (2-3 hours)
- [x] Update firebase_options.dart with real config
- [ ] Create splash screen with auth check
- [ ] Implement login screen UI
- [ ] Implement signup screen UI
- [ ] Create auth notifier provider
- [ ] Update router with auth redirect logic
- [ ] Test email/password auth flow

### Phase 2: Google Sign-In (1 hour)
- [ ] Configure Google Sign-In in Firebase Console
- [ ] Add Google Sign-In button to login screen
- [ ] Test Google auth flow
- [ ] Handle Google sign-in errors

### Phase 3: Profile Integration (1-2 hours)
- [ ] Create Firestore user profile on signup
- [ ] Sync user profile to Firestore
- [ ] Load user profile on login
- [ ] Update onboarding to save profile to Firestore

### Phase 4: Error Handling & Polish (1 hour)
- [ ] Add loading states to auth screens
- [ ] Implement user-friendly error messages
- [ ] Add forgot password flow
- [ ] Add email verification (optional)
- [ ] Test all error scenarios

### Phase 5: Testing (1 hour)
- [ ] Test signup flow
- [ ] Test login flow
- [ ] Test Google Sign-In
- [ ] Test logout
- [ ] Test persistent login
- [ ] Test error handling

---

## 6. Testing Instructions

### Manual Testing Checklist

**Signup Flow**:
1. Open app → Should show splash → Auth screen
2. Tap "Sign Up"
3. Enter email, password, confirm password
4. Tap "Sign Up"
5. Should create account and navigate to onboarding
6. Complete onboarding
7. Should navigate to home screen

**Login Flow**:
1. Sign out
2. Open app → Should show auth screen
3. Tap "Login"
4. Enter email and password
5. Tap "Login"
6. Should navigate to home screen (skip onboarding if already done)

**Google Sign-In**:
1. Sign out
2. Open app → Auth screen
3. Tap "Sign in with Google"
4. Select Google account
5. Should navigate to onboarding (first time) or home (returning user)

**Persistent Login**:
1. Login to app
2. Close app completely
3. Reopen app
4. Should go directly to home screen (no auth screen)

**Error Handling**:
1. Try signup with existing email → Should show "Email already in use"
2. Try login with wrong password → Should show "Wrong password"
3. Try login with non-existent email → Should show "No user found"
4. Try signup with weak password → Should show "Password too weak"

---

## 7. Common Issues & Solutions

### Issue: Firebase not initialized
**Solution**: Ensure Firebase.initializeApp() is called in main() before runApp()

### Issue: Google Sign-In not working
**Solution**: 
1. Check SHA-1 fingerprint is added to Firebase Console
2. Download latest google-services.json
3. Rebuild app

### Issue: "User not found" on valid credentials
**Solution**: Check Firestore rules allow read/write for authenticated users

### Issue: App crashes on auth state change
**Solution**: Wrap auth state listeners in try-catch and handle null states

### Issue: Persistent login not working
**Solution**: Check secure storage permissions and Firebase session persistence

---

## 8. Next Steps After Implementation

1. **Add Email Verification**: Send verification email on signup
2. **Add Phone Authentication**: SMS-based login
3. **Add Biometric Auth**: Fingerprint/Face ID for quick login
4. **Add Social Logins**: Facebook, Twitter, etc.
5. **Add Multi-Factor Authentication**: Extra security layer
6. **Add Account Linking**: Link multiple auth providers
7. **Add Anonymous Auth**: Let users try app before signup

---

## 9. Security Best Practices

1. **Never store passwords in plain text**
2. **Use HTTPS for all API calls**
3. **Implement rate limiting for auth attempts**
4. **Add CAPTCHA for signup (prevent bots)**
5. **Validate email format on client and server**
6. **Enforce strong password requirements**
7. **Log auth events for security monitoring**
8. **Implement session timeout**
9. **Add device tracking for suspicious activity**
10. **Regular security audits**

---

## 10. Monitoring & Analytics

### Firebase Analytics Events to Track:
- `sign_up` - User creates account
- `login` - User logs in
- `sign_up_method` - Email, Google, Apple
- `login_method` - Email, Google, Apple
- `logout` - User logs out
- `password_reset` - User requests password reset
- `auth_error` - Authentication errors

### Crashlytics Integration:
- Log auth errors to Crashlytics
- Track auth-related crashes
- Monitor auth success/failure rates

---

## Resources

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
- [Sign in with Apple Flutter](https://pub.dev/packages/sign_in_with_apple)
- [Firebase Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

