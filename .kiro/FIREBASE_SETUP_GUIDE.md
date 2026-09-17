# Firebase Setup Guide for IronFlow Platform Upgrade

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Enter project name: `ironflow-platform`
4. Accept terms and click "Create project"
5. Wait for project creation to complete

---

## Step 2: Enable Authentication

### Email/Password
1. In Firebase Console, go to **Authentication**
2. Click **Sign-in method**
3. Enable **Email/Password**
4. Save

### Google Sign-In
1. In **Sign-in method**, enable **Google**
2. Select a support email
3. Save

### Apple Sign-In
1. In **Sign-in method**, enable **Apple**
2. Save

---

## Step 3: Create Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Select **Start in production mode**
4. Choose region (e.g., `us-central1`)
5. Click **Create**

---

## Step 4: Set Up Security Rules

1. In Firestore, go to **Rules**
2. Replace with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - only user can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      // Subcollections
      match /{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
    }
    
    // Shared collections (exercises, foods) - anyone can read
    match /exercises/{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    
    match /foods/{document=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

3. Click **Publish**

---

## Step 5: Download Configuration Files

### For Android
1. In Firebase Console, go to **Project Settings**
2. Click **Your apps** → **Android**
3. Register app with package name: `com.example.progression_tracker`
4. Download `google-services.json`
5. Place in `android/app/`

### For iOS
1. In **Project Settings** → **Your apps** → **iOS**
2. Register app with bundle ID: `com.example.progressionTracker`
3. Download `GoogleService-Info.plist`
4. Open iOS project in Xcode
5. Drag `GoogleService-Info.plist` into Xcode
6. Select "Copy items if needed"

### For Web
1. In **Project Settings** → **Your apps** → **Web**
2. Register app
3. Copy the config object

---

## Step 6: Update firebase_options.dart

Replace the placeholder values in `lib/firebase_options.dart`:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',           // From Firebase config
  appId: 'YOUR_WEB_APP_ID',             // From Firebase config
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',  // From Firebase config
  projectId: 'ironflow-platform',       // Your project ID
  authDomain: 'ironflow-platform.firebaseapp.com',
  storageBucket: 'ironflow-platform.appspot.com',
  measurementId: 'YOUR_MEASUREMENT_ID', // Optional
);
```

Get these values from:
1. Firebase Console → Project Settings
2. Copy the config object
3. Extract the values

---

## Step 7: Configure Google Sign-In

### Android
1. Get your app's SHA-1 fingerprint:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
2. In Firebase Console → Project Settings → Your apps → Android
3. Add SHA-1 fingerprint
4. Download updated `google-services.json`

### iOS
1. In Firebase Console → Project Settings → Your apps → iOS
2. Add your app's bundle ID
3. Download updated `GoogleService-Info.plist`

---

## Step 8: Configure Apple Sign-In

### iOS
1. In Xcode, select your project
2. Go to **Signing & Capabilities**
3. Click **+ Capability**
4. Add **Sign in with Apple**
5. Select your team

### Firebase
1. In Firebase Console → Authentication → Sign-in method
2. Enable **Apple**
3. Add your Apple Team ID (from Apple Developer)

---

## Step 9: Test Configuration

Run the app:
```bash
flutter pub get
flutter pub run build_runner build
flutter run
```

Test:
1. [ ] Email/password signup
2. [ ] Email/password login
3. [ ] Google Sign-In (Android/iOS)
4. [ ] Apple Sign-In (iOS)
5. [ ] User profile saved to Firestore
6. [ ] Tokens stored securely

---

## Step 10: Set Up Cloud Storage (Optional)

For storing user photos:

1. In Firebase Console, go to **Storage**
2. Click **Get started**
3. Select region
4. Click **Done**

Update security rules:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

---

## Troubleshooting

### "Firebase app not initialized"
- Make sure `Firebase.initializeApp()` is called in `main.dart`
- Check that `firebase_options.dart` has correct credentials

### "Google Sign-In fails"
- Verify SHA-1 fingerprint is added to Firebase
- Check that Google Sign-In is enabled in Firebase Console

### "Apple Sign-In fails"
- Verify Apple Sign-In capability is added in Xcode
- Check that Apple Team ID is configured in Firebase

### "Firestore permission denied"
- Check security rules are published
- Verify user is authenticated
- Check that user ID matches in rules

---

## Environment Variables (Optional)

Create `.env` file:
```
FIREBASE_PROJECT_ID=ironflow-platform
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=ironflow-platform.firebaseapp.com
FIREBASE_STORAGE_BUCKET=ironflow-platform.appspot.com
```

Then use in code:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

final projectId = dotenv.env['FIREBASE_PROJECT_ID'];
```

---

## Next Steps

After Firebase is configured:
1. Run tests to verify authentication
2. Proceed to Phase 2: Sync System
3. Implement offline-first sync queue

---

**Firebase Setup Status**: Ready for Configuration

**Time to Complete**: 30-60 minutes

