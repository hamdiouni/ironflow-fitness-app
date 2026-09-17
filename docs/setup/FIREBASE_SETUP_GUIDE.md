# Firebase Configuration Guide - Web & Android

Complete step-by-step guide to configure Firebase for IronFlow app on Web and Android platforms.

---

## Prerequisites

- Google account
- Flutter project (IronFlow)
- Internet connection
- Terminal/Command Prompt access

---

## Part 1: Create Firebase Project (If You Don't Have One)

### Step 1.1: Go to Firebase Console
1. Open your browser
2. Go to: https://console.firebase.google.com/
3. Sign in with your Google account

### Step 1.2: Create New Project
1. Click **"Add project"** or **"Create a project"**
2. Enter project name: `IronFlow` (or your preferred name)
3. Click **Continue**
4. **Google Analytics**: Toggle ON (recommended) or OFF
5. If ON, select or create Analytics account
6. Click **Create project**
7. Wait for project creation (30-60 seconds)
8. Click **Continue** when ready

---

## Part 2: Configure Web App

### Step 2.1: Add Web App to Firebase Project
1. In Firebase Console, you should see your project dashboard
2. Look for the **"Get started by adding Firebase to your app"** section
3. Click the **Web icon** `</>` (looks like `</>`  code brackets)
4. **Register app** dialog appears

### Step 2.2: Register Web App
1. **App nickname**: Enter `IronFlow Web` (or any name you prefer)
2. **Firebase Hosting**: Check this box if you want to deploy to Firebase Hosting (optional)
3. Click **Register app**

### Step 2.3: Copy Web Configuration
You'll see a code snippet like this:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyC...",
  authDomain: "ironflow-xxxxx.firebaseapp.com",
  projectId: "ironflow-xxxxx",
  storageBucket: "ironflow-xxxxx.appspot.com",
  messagingSenderId: "123456789012",
  appId: "1:123456789012:web:abcdef123456",
  measurementId: "G-XXXXXXXXXX"
};
```

**IMPORTANT**: Keep this window open or copy these values to a text file. You'll need them in Step 2.4.

### Step 2.4: Update firebase_options.dart (Web Section)

Open your project in VS Code and update `lib/firebase_options.dart`:

Replace the `web` section with your actual values:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyC...',  // Copy from firebaseConfig.apiKey
  appId: '1:123456789012:web:abcdef123456',  // Copy from firebaseConfig.appId
  messagingSenderId: '123456789012',  // Copy from firebaseConfig.messagingSenderId
  projectId: 'ironflow-xxxxx',  // Copy from firebaseConfig.projectId
  authDomain: 'ironflow-xxxxx.firebaseapp.com',  // Copy from firebaseConfig.authDomain
  storageBucket: 'ironflow-xxxxx.appspot.com',  // Copy from firebaseConfig.storageBucket
  measurementId: 'G-XXXXXXXXXX',  // Copy from firebaseConfig.measurementId (optional)
);
```

### Step 2.5: Enable Authentication for Web
1. In Firebase Console, click **Authentication** in left sidebar
2. Click **Get started** (if first time)
3. Go to **Sign-in method** tab
4. Click **Google** provider
5. Toggle **Enable** switch to ON
6. **Project support email**: Select your email from dropdown
7. Click **Save**

### Step 2.6: Add Authorized Domain for Web
1. Still in **Authentication** → **Settings** tab
2. Scroll to **Authorized domains** section
3. You should see:
   - `localhost` (for local development)
   - `your-project.firebaseapp.com` (for Firebase Hosting)
4. If testing on a different domain, click **Add domain** and enter it

---

## Part 3: Configure Android App

### Step 3.1: Get Your Android Package Name
1. Open `android/app/build.gradle` in your Flutter project
2. Find the line: `applicationId "com.example.progression_tracker"`
3. Copy this package name (e.g., `com.example.progression_tracker`)

**IMPORTANT**: This is your Android package name. You'll need it in the next step.

### Step 3.2: Add Android App to Firebase Project
1. Go back to Firebase Console
2. Click the **gear icon** ⚙️ next to "Project Overview"
3. Click **Project settings**
4. Scroll down to **"Your apps"** section
5. Click the **Android icon** (Android robot)

### Step 3.3: Register Android App
1. **Android package name**: Paste your package name from Step 3.1
   - Example: `com.example.progression_tracker`
2. **App nickname** (optional): Enter `IronFlow Android`
3. **Debug signing certificate SHA-1** (optional for now, required for Google Sign-In):
   - Leave blank for now, we'll add it later
4. Click **Register app**

### Step 3.4: Download google-services.json
1. Click **Download google-services.json** button
2. Save the file to your computer
3. **CRITICAL**: Move this file to your Flutter project:
   - Place it in: `android/app/google-services.json`
   - The path should be: `your-project/android/app/google-services.json`

### Step 3.5: Verify google-services.json Location
Make sure the file structure looks like this:
```
your-project/
├── android/
│   ├── app/
│   │   ├── google-services.json  ← File should be here
│   │   ├── build.gradle
│   │   └── src/
│   ├── build.gradle
│   └── settings.gradle
```

### Step 3.6: Update firebase_options.dart (Android Section)

Open `google-services.json` and find these values:

```json
{
  "project_info": {
    "project_id": "ironflow-xxxxx",
    "storage_bucket": "ironflow-xxxxx.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789012:android:abcdef123456",
        "android_client_info": {
          "package_name": "com.example.progression_tracker"
        }
      },
      "api_key": [
        {
          "current_key": "AIzaSyD..."
        }
      ]
    }
  ],
  "configuration_version": "1"
}
```

Update `lib/firebase_options.dart` Android section:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyD...',  // From google-services.json → client[0].api_key[0].current_key
  appId: '1:123456789012:android:abcdef123456',  // From google-services.json → client[0].client_info.mobilesdk_app_id
  messagingSenderId: '123456789012',  // From google-services.json → project_info.project_number
  projectId: 'ironflow-xxxxx',  // From google-services.json → project_info.project_id
  storageBucket: 'ironflow-xxxxx.appspot.com',  // From google-services.json → project_info.storage_bucket
);
```

### Step 3.7: Get SHA-1 Certificate for Google Sign-In (Android)

This is required for Google Sign-In to work on Android.

**Option A: Debug SHA-1 (For Development)**

Run this command in your terminal:

```bash
cd android
./gradlew signingReport
```

Or on Windows:
```bash
cd android
gradlew.bat signingReport
```

Look for output like:
```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:...
SHA1: AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD
SHA-256: ...
```

Copy the **SHA1** value (the long string with colons).

**Option B: Manual Method (If gradlew doesn't work)**

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

On Windows:
```bash
keytool -list -v -keystore "C:\Users\YourName\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### Step 3.8: Add SHA-1 to Firebase
1. Go to Firebase Console
2. Click **gear icon** ⚙️ → **Project settings**
3. Scroll to **Your apps** section
4. Find your Android app
5. Click **Add fingerprint** button
6. Paste your SHA-1 certificate
7. Click **Save**

### Step 3.9: Download Updated google-services.json
1. After adding SHA-1, download the updated `google-services.json`
2. Replace the old file in `android/app/google-services.json`

---

## Part 4: Enable Firestore Database

### Step 4.1: Create Firestore Database
1. In Firebase Console, click **Firestore Database** in left sidebar
2. Click **Create database**
3. **Secure rules for Cloud Firestore**:
   - Select **Start in test mode** (for development)
   - Click **Next**
4. **Cloud Firestore location**:
   - Choose closest region (e.g., `us-central`, `europe-west`, `asia-southeast`)
   - Click **Enable**
5. Wait for database creation (30-60 seconds)

### Step 4.2: Update Firestore Security Rules (Important!)

After testing, update rules for production:

1. Go to **Firestore Database** → **Rules** tab
2. Replace with these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // User's workouts
      match /workouts/{workoutId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // User's nutrition data
      match /nutrition/{nutritionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      // User's progress
      match /progress/{progressId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

3. Click **Publish**

---

## Part 5: Verify Configuration

### Step 5.1: Check Your firebase_options.dart

Your final `lib/firebase_options.dart` should look like this (with real values):

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
      case TargetPlatform.linux:
        throw UnsupportedError('Linux is not supported');
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC...',  // Your actual web API key
    appId: '1:123456789012:web:abcdef123456',
    messagingSenderId: '123456789012',
    projectId: 'ironflow-xxxxx',
    authDomain: 'ironflow-xxxxx.firebaseapp.com',
    storageBucket: 'ironflow-xxxxx.appspot.com',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD...',  // Your actual Android API key
    appId: '1:123456789012:android:abcdef123456',
    messagingSenderId: '123456789012',
    projectId: 'ironflow-xxxxx',
    storageBucket: 'ironflow-xxxxx.appspot.com',
  );

  // iOS, macOS, Windows configurations (if needed later)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosBundleId: 'com.example.progressionTracker',
  );
}
```

### Step 5.2: Test Web App
1. Run your Flutter web app:
   ```bash
   flutter run -d chrome
   ```
2. Try to sign in with Google
3. Check Firebase Console → **Authentication** → **Users** tab
4. You should see your user appear after successful sign-in

### Step 5.3: Test Android App
1. Connect Android device or start emulator
2. Run your Flutter Android app:
   ```bash
   flutter run -d android
   ```
3. Try to sign in with Google
4. Check Firebase Console → **Authentication** → **Users** tab

---

## Part 6: Troubleshooting

### Issue: "API key not valid" Error
**Solution**: Double-check that you copied the correct API key from Firebase Console to `firebase_options.dart`

### Issue: Google Sign-In doesn't work on Android
**Solution**: 
1. Make sure you added SHA-1 certificate (Step 3.7-3.8)
2. Download updated `google-services.json` after adding SHA-1
3. Rebuild the app: `flutter clean && flutter run`

### Issue: "Project ID mismatch" Error
**Solution**: Make sure `projectId` in `firebase_options.dart` matches your Firebase project

### Issue: Firestore permission denied
**Solution**: 
1. Check Firestore rules (Step 4.2)
2. Make sure user is authenticated before accessing Firestore
3. Check that rules allow the operation you're trying to perform

### Issue: Web app works but Android doesn't
**Solution**:
1. Verify `google-services.json` is in correct location: `android/app/`
2. Check that package name in Firebase matches `android/app/build.gradle`
3. Rebuild: `flutter clean && flutter build apk`

---

## Part 7: Alternative Method - FlutterFire CLI (Automatic)

If you prefer automatic configuration, you can use FlutterFire CLI:

### Step 7.1: Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Step 7.2: Login to Firebase
```bash
firebase login
```

### Step 7.3: Configure Firebase
```bash
flutterfire configure
```

This will:
- Show list of your Firebase projects
- Let you select platforms (Web, Android, iOS, etc.)
- Automatically generate `firebase_options.dart` with correct values
- Download `google-services.json` for Android
- Download `GoogleService-Info.plist` for iOS

### Step 7.4: Follow Prompts
1. Select your Firebase project (or create new one)
2. Select platforms: Web, Android (use arrow keys and space to select)
3. Press Enter
4. FlutterFire CLI will generate all configuration files

---

## Summary Checklist

### Web Configuration ✓
- [ ] Created Firebase project
- [ ] Added Web app to Firebase
- [ ] Copied Web config to `firebase_options.dart`
- [ ] Enabled Google Authentication
- [ ] Added authorized domains

### Android Configuration ✓
- [ ] Added Android app to Firebase
- [ ] Downloaded `google-services.json`
- [ ] Placed `google-services.json` in `android/app/`
- [ ] Updated `firebase_options.dart` Android section
- [ ] Generated SHA-1 certificate
- [ ] Added SHA-1 to Firebase Console
- [ ] Downloaded updated `google-services.json`

### Database Configuration ✓
- [ ] Created Firestore database
- [ ] Set up security rules
- [ ] Tested read/write operations

### Testing ✓
- [ ] Web app runs without Firebase errors
- [ ] Android app runs without Firebase errors
- [ ] Google Sign-In works on Web
- [ ] Google Sign-In works on Android
- [ ] Firestore read/write works

---

## Next Steps

After completing this setup:

1. **Test thoroughly**: Try all authentication flows
2. **Update security rules**: Move from test mode to production rules
3. **Set up Firebase Hosting** (optional): Deploy web app
4. **Configure iOS** (if needed): Follow similar steps for iOS
5. **Enable Firebase Analytics**: Track user behavior
6. **Set up Cloud Functions** (optional): Backend logic

---

## Need Help?

- Firebase Documentation: https://firebase.google.com/docs
- FlutterFire Documentation: https://firebase.flutter.dev/
- Firebase Console: https://console.firebase.google.com/
- Stack Overflow: Search for "FlutterFire" or "Firebase Flutter"

---

**Created**: 2026-05-17  
**App**: IronFlow  
**Platforms**: Web, Android
