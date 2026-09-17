# Google Sign-In Setup Guide - 100% FREE
## Complete Step-by-Step for Web & Mobile

**Cost: $0 | Time: ~30 minutes | No Credit Card Required**

---

## 📋 Prerequisites

- ✅ Google account (free)
- ✅ Flutter project (you have this)
- ✅ Internet connection

---

# PART 1: Google Cloud Console Setup (15 minutes)

## Step 1: Create Google Cloud Project

1. **Go to Google Cloud Console**
   - Open: https://console.cloud.google.com/
   - Sign in with your Google account

2. **Create New Project**
   - Click "Select a project" at the top
   - Click "NEW PROJECT"
   - Project name: `IronFlow` (or any name)
   - Click "CREATE"
   - Wait 10-20 seconds for project creation

3. **Select Your Project**
   - Click "Select a project" again
   - Choose "IronFlow" from the list

---

## Step 2: Enable Google Sign-In API

1. **Go to APIs & Services**
   - In left menu, click "APIs & Services" → "Library"
   - Or go to: https://console.cloud.google.com/apis/library

2. **Search for Google Sign-In**
   - In search box, type: `Google+ API`
   - Click on "Google+ API"
   - Click "ENABLE"
   - Wait for it to enable (~5 seconds)

---

## Step 3: Configure OAuth Consent Screen

1. **Go to OAuth Consent Screen**
   - Left menu: "APIs & Services" → "OAuth consent screen"
   - Or go to: https://console.cloud.google.com/apis/credentials/consent

2. **Choose User Type**
   - Select "External" (for public apps)
   - Click "CREATE"

3. **Fill App Information**
   - **App name**: `IronFlow`
   - **User support email**: Your email
   - **App logo**: (optional, skip for now)
   - **Application home page**: (optional, skip for now)
   - **Authorized domains**: (skip for now)
   - **Developer contact email**: Your email
   - Click "SAVE AND CONTINUE"

4. **Scopes**
   - Click "ADD OR REMOVE SCOPES"
   - Select:
     - ✅ `.../auth/userinfo.email`
     - ✅ `.../auth/userinfo.profile`
     - ✅ `openid`
   - Click "UPDATE"
   - Click "SAVE AND CONTINUE"

5. **Test Users** (Optional for development)
   - Click "ADD USERS"
   - Add your email address
   - Click "ADD"
   - Click "SAVE AND CONTINUE"

6. **Summary**
   - Review and click "BACK TO DASHBOARD"

---

## Step 4: Create OAuth 2.0 Credentials

### 4A: Web Client ID (for Chrome/Web)

1. **Go to Credentials**
   - Left menu: "APIs & Services" → "Credentials"
   - Or go to: https://console.cloud.google.com/apis/credentials

2. **Create Web Credentials**
   - Click "CREATE CREDENTIALS" → "OAuth client ID"
   - Application type: "Web application"
   - Name: `IronFlow Web`
   
3. **Add Authorized JavaScript Origins**
   - Click "ADD URI" under "Authorized JavaScript origins"
   - Add these URIs:
     ```
     http://localhost
     http://localhost:8080
     http://localhost:3000
     ```
   
4. **Add Authorized Redirect URIs**
   - Click "ADD URI" under "Authorized redirect URIs"
   - Add these URIs:
     ```
     http://localhost
     http://localhost:8080
     http://localhost:3000
     ```

5. **Create**
   - Click "CREATE"
   - **IMPORTANT**: Copy the "Client ID" (looks like: `123456789-abc.apps.googleusercontent.com`)
   - Save it in a text file - you'll need it later!
   - Click "OK"

### 4B: Android Client ID (for Android)

1. **Get SHA-1 Certificate Fingerprint**
   - Open terminal in your project folder
   - Run this command:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   - Look for "SHA1" under "Variant: debug"
   - Copy the SHA-1 fingerprint (looks like: `AA:BB:CC:DD:...`)

2. **Create Android Credentials**
   - Click "CREATE CREDENTIALS" → "OAuth client ID"
   - Application type: "Android"
   - Name: `IronFlow Android`
   - Package name: `com.example.progression_tracker` (check your `android/app/build.gradle`)
   - SHA-1 certificate fingerprint: Paste the SHA-1 you copied
   - Click "CREATE"
   - Click "OK"

### 4C: iOS Client ID (for iOS)

1. **Get iOS Bundle ID**
   - Open `ios/Runner.xcodeproj` in Xcode
   - Or check `ios/Runner/Info.plist` for `CFBundleIdentifier`
   - Usually: `com.example.progressionTracker`

2. **Create iOS Credentials**
   - Click "CREATE CREDENTIALS" → "OAuth client ID"
   - Application type: "iOS"
   - Name: `IronFlow iOS`
   - Bundle ID: Your iOS bundle ID
   - Click "CREATE"
   - **IMPORTANT**: Copy the "Client ID"
   - Save it in a text file
   - Click "OK"

---

# PART 2: Flutter Project Setup (10 minutes)

## Step 5: Add Google Sign-In Package

1. **Open `pubspec.yaml`**

2. **Add dependency**:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     google_sign_in: ^6.1.5  # Add this line
   ```

3. **Install package**:
   ```bash
   flutter pub get
   ```

---

## Step 6: Configure Web (Chrome)

1. **Open `web/index.html`**

2. **Add this line** inside the `<head>` section (before `</head>`):
   ```html
   <meta name="google-signin-client_id" content="YOUR-WEB-CLIENT-ID.apps.googleusercontent.com">
   ```
   
   Replace `YOUR-WEB-CLIENT-ID` with the Web Client ID you copied in Step 4A.

   **Example**:
   ```html
   <head>
     <meta charset="UTF-8">
     <title>IronFlow</title>
     <meta name="google-signin-client_id" content="123456789-abc.apps.googleusercontent.com">
   </head>
   ```

---

## Step 7: Configure Android

1. **No additional configuration needed!**
   - Android uses the SHA-1 fingerprint you provided
   - Google Sign-In will work automatically

2. **Optional: Add to `AndroidManifest.xml`** (for better compatibility)
   - Open `android/app/src/main/AndroidManifest.xml`
   - Add inside `<application>` tag:
   ```xml
   <meta-data
       android:name="com.google.android.gms.version"
       android:value="@integer/google_play_services_version" />
   ```

---

## Step 8: Configure iOS

1. **Open `ios/Runner/Info.plist`**

2. **Add this code** before the last `</dict>`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.YOUR-IOS-CLIENT-ID</string>
       </array>
     </dict>
   </array>
   ```
   
   Replace `YOUR-IOS-CLIENT-ID` with the iOS Client ID you copied in Step 4C.
   
   **Example**:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.987654321-xyz</string>
       </array>
     </dict>
   </array>
   ```

---

# PART 3: Update Flutter Code (5 minutes)

## Step 9: Update Mock Auth Datasource

I'll update the code for you now...



## Step 9: Install Google Sign-In Package

✅ **I've already updated your code!**

**What I did:**
1. ✅ Added `google_sign_in: ^6.1.5` to `pubspec.yaml`
2. ✅ Updated `mock_auth_datasource.dart` with real Google Sign-In code
3. ✅ Added proper error handling and logging

**Now run this command:**
```bash
flutter pub get
```

---

# PART 4: Testing (5 minutes)

## Step 10: Test on Web (Chrome)

1. **Run the app**:
   ```bash
   flutter run -d chrome --web-port=8080
   ```

2. **Test Google Sign-In**:
   - Open the app in Chrome
   - Click "Continue with Google"
   - Google Sign-In popup should appear
   - Select your Google account
   - You should be logged in!

3. **If it doesn't work**:
   - Check browser console for errors
   - Make sure you added the Web Client ID to `web/index.html`
   - Make sure `http://localhost:8080` is in authorized origins

---

## Step 11: Test on Android

1. **Build and run**:
   ```bash
   flutter run -d android
   ```

2. **Test Google Sign-In**:
   - Open the app on Android device/emulator
   - Click "Continue with Google"
   - Google account picker should appear
   - Select your Google account
   - You should be logged in!

3. **If it doesn't work**:
   - Make sure you added the correct SHA-1 fingerprint
   - Make sure package name matches
   - Try running `flutter clean` and rebuild

---

## Step 12: Test on iOS

1. **Build and run**:
   ```bash
   flutter run -d ios
   ```

2. **Test Google Sign-In**:
   - Open the app on iOS device/simulator
   - Click "Continue with Google"
   - Google Sign-In should open
   - Select your Google account
   - You should be logged in!

3. **If it doesn't work**:
   - Make sure you added the iOS Client ID to `Info.plist`
   - Make sure bundle ID matches
   - Try running `flutter clean` and rebuild

---

# Troubleshooting

## Common Issues

### Issue 1: "API not enabled"
**Solution**: Go back to Step 2 and enable Google+ API

### Issue 2: "Unauthorized client"
**Solution**: 
- Check that Client ID matches in `web/index.html`
- Check that authorized origins include your localhost URL
- Wait 5-10 minutes for changes to propagate

### Issue 3: "Sign in cancelled" immediately
**Solution**:
- Check OAuth consent screen is configured
- Add your email as a test user
- Make sure app is not in "Testing" mode with restricted users

### Issue 4: Android SHA-1 error
**Solution**:
```bash
cd android
./gradlew signingReport
```
Copy the SHA-1 and update in Google Cloud Console

### Issue 5: iOS Bundle ID mismatch
**Solution**:
- Check `ios/Runner/Info.plist` for `CFBundleIdentifier`
- Update in Google Cloud Console credentials

---

# Verification Checklist

## ✅ Google Cloud Console
- [ ] Project created
- [ ] Google+ API enabled
- [ ] OAuth consent screen configured
- [ ] Web Client ID created
- [ ] Android Client ID created (with SHA-1)
- [ ] iOS Client ID created (with Bundle ID)

## ✅ Flutter Project
- [ ] `google_sign_in` package added to `pubspec.yaml`
- [ ] `flutter pub get` run successfully
- [ ] Web Client ID added to `web/index.html`
- [ ] iOS Client ID added to `ios/Runner/Info.plist`
- [ ] Code updated in `mock_auth_datasource.dart`

## ✅ Testing
- [ ] Web: Google Sign-In works in Chrome
- [ ] Android: Google Sign-In works on device/emulator
- [ ] iOS: Google Sign-In works on device/simulator
- [ ] Session persists after app restart
- [ ] Logout works correctly

---

# What Happens Now

## User Flow

1. **User clicks "Continue with Google"**
   - Google Sign-In popup appears
   - User selects Google account
   - User grants permissions

2. **App receives user data**
   - Email
   - Display name
   - Profile photo
   - User ID

3. **Session is saved**
   - User data stored in Hive
   - User stays logged in

4. **User is redirected**
   - Goes to onboarding (first time)
   - Goes to home (returning user)

## Logs You'll See

```
📊 [Auth] Starting Google Sign-In...
✅ [Auth] Google account selected: user@gmail.com
✅ [Auth] Got authentication tokens
📊 [AuthSession] Saving user session...
✅ [AuthSession] Session saved successfully
✅ [Auth] Google Sign-In successful
🔍 [Auth] User: John Doe
```

---

# Cost Summary

| Service | Cost |
|---------|------|
| Google Cloud Project | **$0** |
| Google+ API | **$0** |
| OAuth 2.0 Credentials | **$0** |
| Google Sign-In SDK | **$0** |
| Unlimited Users | **$0** |
| **TOTAL** | **$0** ✅ |

**No credit card required!**
**No usage limits!**
**Free forever!**

---

# Next Steps

## After Google Sign-In Works

1. **Add Apple Sign-In** (optional)
   - Similar process
   - Also free
   - Better for iOS users

2. **Add Profile Photos**
   - Google provides profile photo URL
   - Display in app
   - Cache locally

3. **Add Email Verification** (optional)
   - Google emails are already verified
   - No need for additional verification

4. **Deploy to Production**
   - Add production domains to authorized origins
   - Update OAuth consent screen
   - Submit for verification (optional)

---

# Support

## If You Get Stuck

1. **Check the logs**
   - Look for error messages
   - Check browser console (Web)
   - Check Logcat (Android)
   - Check Xcode console (iOS)

2. **Common fixes**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Restart IDE
   - Wait 5-10 minutes for Google changes to propagate

3. **Google Cloud Console**
   - Double-check all Client IDs
   - Verify authorized origins
   - Check OAuth consent screen

4. **Ask for help**
   - Provide error messages
   - Provide platform (Web/Android/iOS)
   - Provide logs

---

# Summary

## What You Did

✅ Created Google Cloud project (FREE)
✅ Enabled Google Sign-In API (FREE)
✅ Configured OAuth consent screen (FREE)
✅ Created OAuth credentials (FREE)
✅ Added Google Sign-In to Flutter app (FREE)
✅ Configured for Web, Android, iOS (FREE)
✅ Tested on all platforms (FREE)

## What You Get

✅ Professional Google Sign-In
✅ No password management
✅ Trusted by users
✅ Works on all platforms
✅ Session persistence
✅ Auto-login
✅ Profile photos
✅ Verified emails

## Total Cost

**$0.00** 🎉

---

# Congratulations! 🎉

You now have Google Sign-In working on:
- ✅ Web (Chrome)
- ✅ Android
- ✅ iOS

**All for FREE!**

Your users can now sign in with their Google accounts in one click!

---

# Quick Reference

## Important URLs

- **Google Cloud Console**: https://console.cloud.google.com/
- **OAuth Credentials**: https://console.cloud.google.com/apis/credentials
- **OAuth Consent Screen**: https://console.cloud.google.com/apis/credentials/consent

## Important Files

- **Web**: `web/index.html`
- **Android**: `android/app/src/main/AndroidManifest.xml`
- **iOS**: `ios/Runner/Info.plist`
- **Code**: `lib/features/auth/data/datasources/mock_auth_datasource.dart`

## Important Commands

```bash
# Install packages
flutter pub get

# Run on Web
flutter run -d chrome --web-port=8080

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Get Android SHA-1
cd android && ./gradlew signingReport

# Clean project
flutter clean
```

---

**Need help? Check the Troubleshooting section above!**
