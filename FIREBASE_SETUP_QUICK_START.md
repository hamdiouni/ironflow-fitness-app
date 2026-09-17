# Firebase Setup - Quick Start Guide

## 🚀 Get Your App Running with Firebase in 30 Minutes

Follow these steps exactly to configure Firebase for your IronFlow app.

---

## Step 1: Create Firebase Project (5 minutes)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: **"IronFlow"** (or your preferred name)
4. Click **Continue**
5. (Optional) Enable Google Analytics → Click **Continue**
6. Select Analytics account or create new → Click **Create project**
7. Wait for project creation → Click **Continue**

---

## Step 2: Add Android App (10 minutes)

### 2.1 Register Android App
1. In Firebase Console, click **"Add app"** → Select **Android**
2. Enter Android package name: `com.progressiontracker.progression_tracker`
3. (Optional) Enter app nickname: "IronFlow Android"
4. (Optional) Enter SHA-1 certificate (required for Google Sign-In):
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Copy the SHA-1 from the output
5. Click **"Register app"**

### 2.2 Download google-services.json
1. Click **"Download google-services.json"**
2. Move the file to: `android/app/google-services.json`
3. Click **"Next"** → **"Next"** → **"Continue to console"**

---

## Step 3: Add Web App (5 minutes)

### 3.1 Register Web App
1. In Firebase Console, click **"Add app"** → Select **Web** (</> icon)
2. Enter app nickname: "IronFlow Web"
3. (Optional) Check "Also set up Firebase Hosting"
4. Click **"Register app"**

### 3.2 Copy Web Config
1. Copy the Firebase configuration object:
   ```javascript
   const firebaseConfig = {
     apiKey: "AIza...",
     authDomain: "ironflow-xxxxx.firebaseapp.com",
     projectId: "ironflow-xxxxx",
     storageBucket: "ironflow-xxxxx.appspot.com",
     messagingSenderId: "123456789",
     appId: "1:123456789:web:abcdef",
     measurementId: "G-XXXXXXXXXX"
   };
   ```
2. Keep this handy for Step 6

---

## Step 4: Enable Authentication (5 minutes)

### 4.1 Enable Email/Password
1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Click **"Email/Password"**
3. Toggle **"Enable"** → Click **"Save"**

### 4.2 Enable Google Sign-In
1. Click **"Google"**
2. Toggle **"Enable"**
3. Enter project support email
4. Click **"Save"**

### 4.3 Configure OAuth Consent Screen (for Google Sign-In)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Go to **APIs & Services** → **OAuth consent screen**
4. Select **"External"** → Click **"Create"**
5. Fill in:
   - App name: "IronFlow"
   - User support email: your email
   - Developer contact: your email
6. Click **"Save and Continue"** → **"Save and Continue"** → **"Back to Dashboard"**

---

## Step 5: Create Firestore Database (5 minutes)

### 5.1 Create Database
1. In Firebase Console, go to **Firestore Database**
2. Click **"Create database"**
3. Select **"Start in production mode"** → Click **"Next"**
4. Choose location (closest to your users) → Click **"Enable"**

### 5.2 Set Security Rules
1. Go to **Firestore Database** → **Rules** tab
2. Replace the rules with:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Users collection
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       
       // User profiles collection
       match /user_profiles/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
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
3. Click **"Publish"**

---

## Step 6: Update firebase_options.dart (5 minutes)

Open `lib/firebase_options.dart` and replace the placeholder values with your actual Firebase config:

```dart
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

  // Replace with your Web config from Step 3
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',              // From firebaseConfig.apiKey
    appId: 'YOUR_WEB_APP_ID',                // From firebaseConfig.appId
    messagingSenderId: 'YOUR_SENDER_ID',     // From firebaseConfig.messagingSenderId
    projectId: 'YOUR_PROJECT_ID',            // From firebaseConfig.projectId
    authDomain: 'YOUR_AUTH_DOMAIN',          // From firebaseConfig.authDomain
    storageBucket: 'YOUR_STORAGE_BUCKET',    // From firebaseConfig.storageBucket
    measurementId: 'YOUR_MEASUREMENT_ID',    // From firebaseConfig.measurementId
  );

  // For Android, you can find these in google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',          // From google-services.json → client[0].api_key[0].current_key
    appId: 'YOUR_ANDROID_APP_ID',            // From google-services.json → client[0].client_info.mobilesdk_app_id
    messagingSenderId: 'YOUR_SENDER_ID',     // From google-services.json → project_info.project_number
    projectId: 'YOUR_PROJECT_ID',            // From google-services.json → project_info.project_id
    storageBucket: 'YOUR_STORAGE_BUCKET',    // From google-services.json → project_info.storage_bucket
  );

  // iOS config (if you add iOS app later)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosBundleId: 'com.progressiontracker.progressionTracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosBundleId: 'com.progressiontracker.progressionTracker.macos',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY',
    appId: 'YOUR_WINDOWS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
  );
}
```

### How to Find Values in google-services.json:
```json
{
  "project_info": {
    "project_number": "123456789",           // → messagingSenderId
    "project_id": "ironflow-xxxxx",          // → projectId
    "storage_bucket": "ironflow-xxxxx.appspot.com"  // → storageBucket
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123:android:abc"  // → appId
      },
      "api_key": [
        {
          "current_key": "AIza..."           // → apiKey
        }
      ]
    }
  ]
}
```

---

## Step 7: Test the App (10 minutes)

### 7.1 Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### 7.2 Run on Device/Emulator
```bash
# For Android
flutter run

# For Web
flutter run -d chrome
```

### 7.3 Test Auth Flow
1. **App opens** → Should show splash screen with IronFlow logo
2. **After 2 seconds** → Should show auth screen with Login/Sign Up tabs
3. **Tap "Sign Up" tab**
4. **Enter email**: test@example.com
5. **Enter password**: password123
6. **Enter confirm password**: password123
7. **Tap "Sign Up"** → Should create account
8. **Should navigate to onboarding** → Complete onboarding
9. **Should navigate to home screen** → Success!

### 7.4 Test Login
1. **Sign out** from profile screen
2. **App should show auth screen**
3. **Tap "Login" tab**
4. **Enter email**: test@example.com
5. **Enter password**: password123
6. **Tap "Login"** → Should navigate to home screen

### 7.5 Test Google Sign-In
1. **Sign out**
2. **Tap "Continue with Google"**
3. **Select Google account**
4. **Should navigate to onboarding (first time) or home (returning)**

### 7.6 Test Persistent Login
1. **Login to app**
2. **Close app completely**
3. **Reopen app**
4. **Should show splash → home** (no auth screen)

---

## Step 8: Verify Firestore Data (5 minutes)

1. Go to Firebase Console → **Firestore Database**
2. You should see collections:
   - `users/` → Contains user documents with uid, email, etc.
   - `user_profiles/` → Contains profile documents with fitness data
3. Click on a user document to verify data structure

---

## 🎉 Success Checklist

- [ ] Firebase project created
- [ ] Android app registered
- [ ] google-services.json downloaded and placed in android/app/
- [ ] Web app registered
- [ ] Email/Password authentication enabled
- [ ] Google Sign-In enabled
- [ ] OAuth consent screen configured
- [ ] Firestore database created
- [ ] Security rules set
- [ ] firebase_options.dart updated with real config
- [ ] App rebuilt and tested
- [ ] Sign up flow works
- [ ] Login flow works
- [ ] Google Sign-In works
- [ ] Persistent login works
- [ ] Firestore data created

---

## 🐛 Common Issues

### Issue: "Default FirebaseApp is not initialized"
**Solution**: Make sure `Firebase.initializeApp()` is called in `main()` before `runApp()`. This is already done in your app.

### Issue: Google Sign-In shows "PlatformException"
**Solution**: 
1. Make sure SHA-1 is added to Firebase Console
2. Download new `google-services.json`
3. Run: `flutter clean && flutter pub get && flutter build apk`

### Issue: "Permission denied" in Firestore
**Solution**: Check security rules allow authenticated users to read/write their own data

### Issue: App crashes on startup
**Solution**: Check `firebase_options.dart` has correct values (no "YOUR_" placeholders)

---

## 📞 Need Help?

If you encounter issues:
1. Check Firebase Console → **Authentication** → **Users** tab (should show registered users)
2. Check Firebase Console → **Firestore Database** (should show user documents)
3. Check Android Studio Logcat for error messages
4. Verify all config values are correct (no placeholders)

---

## 🚀 Next Steps

After Firebase is working:
1. **Add Forgot Password** - Implement password reset flow
2. **Add Email Verification** - Send verification email on signup
3. **Add Profile Picture Upload** - Use Firebase Storage
4. **Add Apple Sign-In** - For iOS users
5. **Add Phone Authentication** - SMS-based login

---

**Estimated Total Time**: 30-45 minutes

**Status**: Ready to configure Firebase and test!
