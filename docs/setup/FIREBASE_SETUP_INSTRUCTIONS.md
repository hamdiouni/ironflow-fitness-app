# Firebase Setup Instructions for IronFlow

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `ironflow-fitness` (or your preferred name)
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Add Android App

1. In Firebase Console, click "Add app" → Android icon
2. Enter Android package name: `com.progressiontracker.progression_tracker`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`
5. Follow Firebase instructions to update `android/build.gradle.kts` and `android/app/build.gradle.kts`

## Step 3: Add iOS App (if needed)

1. Click "Add app" → iOS icon
2. Enter iOS bundle ID: `com.progressiontracker.progressionTracker`
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`

## Step 4: Add Web App

1. Click "Add app" → Web icon
2. Enter app nickname: `IronFlow Web`
3. Copy the Firebase config object
4. Update `lib/firebase_options.dart` with the values

## Step 5: Enable Authentication Methods

1. In Firebase Console, go to "Authentication" → "Sign-in method"
2. Enable:
   - **Email/Password**: Click "Enable" → Save
   - **Google**: Click "Enable" → Add support email → Save
   - **Apple** (optional): Follow Apple setup instructions

## Step 6: Create Firestore Database

1. Go to "Firestore Database" → "Create database"
2. Choose "Start in production mode"
3. Select location (choose closest to your users)
4. Click "Enable"

## Step 7: Set Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profiles - users can only read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Workouts - users can only read/write their own workouts
    match /workouts/{workoutId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Programs - users can only read/write their own programs
    match /programs/{programId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Nutrition logs - users can only read/write their own logs
    match /nutrition/{logId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Public exercise database - read-only for all authenticated users
    match /exercises/{exerciseId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can write (via Firebase Console)
    }
    
    // Public food database - read-only for all authenticated users
    match /foods/{foodId} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can write (via Firebase Console)
    }
  }
}
```

## Step 8: Update firebase_options.dart

Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase config:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_WEB_API_KEY',
  appId: 'YOUR_ACTUAL_WEB_APP_ID',
  messagingSenderId: 'YOUR_ACTUAL_MESSAGING_SENDER_ID',
  projectId: 'YOUR_ACTUAL_PROJECT_ID',
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  measurementId: 'YOUR_ACTUAL_MEASUREMENT_ID',
);
```

## Step 9: Configure Google Sign-In (Android)

1. In Firebase Console, go to "Authentication" → "Sign-in method" → "Google"
2. Copy the "Web client ID"
3. Update `android/app/src/main/res/values/strings.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_web_client_id">YOUR_WEB_CLIENT_ID</string>
</resources>
```

## Step 10: Test Firebase Connection

1. Run the app: `flutter run`
2. Check console for: `✅ Firebase initialized successfully`
3. Try signing up with email/password
4. Check Firebase Console → Authentication → Users to see new user

## Firestore Collections Schema

### users/{userId}
```json
{
  "userId": "string",
  "email": "string",
  "name": "string",
  "goal": "string", // "strength", "hypertrophy", "endurance", "weight-loss"
  "experience": "string", // "beginner", "intermediate", "advanced"
  "equipment": ["string"], // ["barbell", "dumbbell", "machine", "bodyweight"]
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### workouts/{workoutId}
```json
{
  "id": "string",
  "userId": "string",
  "date": "timestamp",
  "exercises": [
    {
      "id": "string",
      "name": "string",
      "sets": [
        {
          "id": "string",
          "reps": "number",
          "weight": "number",
          "rpe": "number",
          "timestamp": "string"
        }
      ]
    }
  ],
  "duration": "number", // seconds
  "totalVolume": "number",
  "createdAt": "timestamp"
}
```

### programs/{programId}
```json
{
  "id": "string",
  "userId": "string",
  "name": "string",
  "split": "string", // "full-body", "upper-lower", "ppl", etc.
  "days": [
    {
      "name": "string",
      "focus": "string",
      "exercises": [
        {
          "exerciseName": "string",
          "sets": "number",
          "reps": "string",
          "restSeconds": "number"
        }
      ]
    }
  ],
  "currentDayIndex": "number",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### nutrition/{logId}
```json
{
  "id": "string",
  "userId": "string",
  "date": "timestamp",
  "meals": [
    {
      "id": "string",
      "foodName": "string",
      "quantity": "number",
      "macros": {
        "calories": "number",
        "protein": "number",
        "carbs": "number",
        "fats": "number"
      }
    }
  ],
  "createdAt": "timestamp"
}
```

## Troubleshooting

### Firebase initialization fails
- Check that `google-services.json` is in `android/app/`
- Verify package name matches in Firebase Console and `android/app/build.gradle.kts`
- Run `flutter clean` and rebuild

### Google Sign-In fails
- Verify SHA-1 fingerprint is added in Firebase Console
- Get SHA-1: `cd android && ./gradlew signingReport`
- Add SHA-1 in Firebase Console → Project Settings → Your apps → Android app

### Firestore permission denied
- Check security rules in Firebase Console
- Verify user is authenticated before accessing Firestore
- Check that `userId` in document matches `request.auth.uid`

## Next Steps

After Firebase is configured:
1. Test email/password signup
2. Test Google Sign-In
3. Verify user profile is created in Firestore
4. Test data sync across devices
5. Enable offline persistence (already configured in code)
