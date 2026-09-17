# Quick Start: Firebase Authentication

## 🚀 Get Your App Running with Firebase in 30 Minutes

### Step 1: Create Firebase Project (5 min)

1. Go to https://console.firebase.google.com/
2. Click **"Add project"**
3. Enter project name: `ironflow-fitness`
4. Disable Google Analytics (optional)
5. Click **"Create project"**

### Step 2: Add Web App (5 min)

1. In Firebase Console, click **"Add app"** → **Web icon** (</>)
2. Enter app nickname: `IronFlow Web`
3. Click **"Register app"**
4. **Copy the Firebase config object**
5. Open `lib/firebase_options.dart`
6. Replace the `web` section with your values:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIza...', // Your API key
  appId: '1:123...', // Your App ID
  messagingSenderId: '123...', // Your Sender ID
  projectId: 'ironflow-fitness', // Your Project ID
  authDomain: 'ironflow-fitness.firebaseapp.com',
  storageBucket: 'ironflow-fitness.appspot.com',
  measurementId: 'G-...', // Your Measurement ID
);
```

### Step 3: Enable Authentication (3 min)

1. In Firebase Console, go to **"Authentication"**
2. Click **"Get started"**
3. Click **"Sign-in method"** tab
4. Enable **"Email/Password"**:
   - Click "Email/Password"
   - Toggle "Enable"
   - Click "Save"
5. Enable **"Google"**:
   - Click "Google"
   - Toggle "Enable"
   - Add support email (your email)
   - Click "Save"

### Step 4: Create Firestore Database (5 min)

1. In Firebase Console, go to **"Firestore Database"**
2. Click **"Create database"**
3. Select **"Start in production mode"**
4. Choose location (closest to your users)
5. Click **"Enable"**
6. Go to **"Rules"** tab
7. Replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

8. Click **"Publish"**

### Step 5: Run Your App (2 min)

```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Run on web
flutter run -d chrome
```

### Step 6: Test Authentication (10 min)

1. **Sign Up**:
   - Enter name, email, password
   - Click "Sign Up"
   - Should navigate to onboarding

2. **Sign Out**:
   - Go to Profile tab
   - Click "Sign Out"
   - Should return to login

3. **Sign In**:
   - Enter email, password
   - Click "Sign In"
   - Should navigate to home

4. **Google Sign-In**:
   - Click "Continue with Google"
   - Select Google account
   - Should navigate to home

5. **Session Persistence**:
   - Close and reopen app
   - Should stay logged in

### ✅ Done!

Your app now has:
- ✅ Email/password authentication
- ✅ Google Sign-In
- ✅ User profiles in Firestore
- ✅ Persistent login sessions
- ✅ Route protection

---

## 🐛 Troubleshooting

### "Firebase initialization failed"
- Check `firebase_options.dart` has correct values
- Verify you copied the entire config object
- Run `flutter clean` and try again

### "Google Sign-In cancelled"
- This is normal if user closes the Google picker
- Try again and select an account

### "Permission denied" in Firestore
- Check security rules are published
- Verify user is signed in
- Check Firebase Console → Firestore → Rules

### App shows blank screen
- Check browser console for errors (F12)
- Verify Firebase is initialized (check console logs)
- Try `flutter run -d chrome --web-port=8080`

---

## 📱 Android Setup (Optional)

If you want to test on Android:

1. In Firebase Console, click **"Add app"** → **Android icon**
2. Enter package name: `com.progressiontracker.progression_tracker`
3. Download `google-services.json`
4. Place in `android/app/google-services.json`
5. Run: `flutter run -d <your-android-device>`

---

## 📚 Next Steps

- Read `FIREBASE_ARCHITECTURE.md` for detailed architecture
- Read `FIREBASE_SETUP_INSTRUCTIONS.md` for advanced setup
- Add email verification
- Implement password reset
- Write tests

---

## 🎉 Success!

You now have a fully functional authentication system!

**Questions?** Check the documentation files:
- `FIREBASE_IMPLEMENTATION_COMPLETE.md` - Full implementation details
- `FIREBASE_ARCHITECTURE.md` - Architecture and flows
- `FIREBASE_SETUP_INSTRUCTIONS.md` - Detailed setup guide
