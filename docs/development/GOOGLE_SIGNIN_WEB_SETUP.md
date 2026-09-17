# Google Sign-In Web Configuration Guide

## Current Status
✅ Google Sign-In package installed (`google_sign_in: ^6.2.1`)
✅ Google Sign-In button visible in login/signup screens
✅ Error handling implemented with user-friendly messages
⚠️ **Web Client ID not yet configured** - This is why you're seeing the error

## The Error You're Seeing
```
❌ [Auth] Google sign in failed: Exception: Google Sign-In is not configured yet. 
Please use email/password to sign in.
```

**Why?** The `web/index.html` file needs your Web Client ID from Google Cloud Console.

---

## Step-by-Step Setup (FREE - No Credit Card Needed)

### Step 1: Create a Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click **"Select a Project"** at the top
3. Click **"NEW PROJECT"**
4. Enter project name: `IronFlow` (or any name you prefer)
5. Click **"CREATE"**
6. Wait for the project to be created (takes ~30 seconds)

### Step 2: Enable Google Sign-In API

1. In Google Cloud Console, search for **"Google+ API"** in the search bar
2. Click on **"Google+ API"** from results
3. Click **"ENABLE"**
4. Wait for it to enable

### Step 3: Create OAuth 2.0 Credentials

1. In Google Cloud Console, go to **"Credentials"** (left sidebar)
2. Click **"+ CREATE CREDENTIALS"** at the top
3. Select **"OAuth client ID"**
4. If prompted to create a consent screen first:
   - Click **"CREATE CONSENT SCREEN"**
   - Select **"External"** user type
   - Click **"CREATE"**
   - Fill in the form:
     - App name: `IronFlow`
     - User support email: Your email
     - Developer contact: Your email
   - Click **"SAVE AND CONTINUE"**
   - Skip scopes (click **"SAVE AND CONTINUE"**)
   - Skip test users (click **"SAVE AND CONTINUE"**)
   - Click **"BACK TO DASHBOARD"**

5. Now create the OAuth client ID:
   - Go back to **"Credentials"**
   - Click **"+ CREATE CREDENTIALS"**
   - Select **"OAuth client ID"**
   - Choose **"Web application"**
   - Name: `IronFlow Web`
   - Under **"Authorized JavaScript origins"**, add:
     - `http://localhost:5000`
     - `http://localhost:5001`
     - `http://localhost:5002`
     - `http://127.0.0.1:5000`
   - Under **"Authorized redirect URIs"**, add:
     - `http://localhost:5000/`
     - `http://localhost:5001/`
     - `http://localhost:5002/`
   - Click **"CREATE"**

6. A popup will show your credentials:
   - **Copy the "Client ID"** (looks like: `123456789-abc...apps.googleusercontent.com`)
   - This is your **Web Client ID**

### Step 4: Add Web Client ID to Your App

1. Open `web/index.html` in your project
2. Find this line:
   ```html
   <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
   ```
3. Replace `YOUR_WEB_CLIENT_ID` with your actual Client ID from Step 3
4. Example:
   ```html
   <meta name="google-signin-client_id" content="123456789-abc123def456.apps.googleusercontent.com">
   ```

### Step 5: Test on Web

1. Run your app on web:
   ```bash
   flutter run -d chrome
   ```

2. Go to the login screen
3. Click **"Continue with Google"**
4. You should see the Google Sign-In popup
5. Sign in with your Google account
6. You should be logged in! ✅

---

## For Android Setup (When Ready)

You'll also need to:
1. Get your Android SHA-1 fingerprint:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Add it to Google Cloud Console under Android OAuth credentials
3. Add the Android Client ID to `android/app/build.gradle.kts`

See `ANDROID_OAUTH_CONFIG.md` for detailed Android setup.

---

## For iOS Setup (When Ready)

You'll need to:
1. Create an iOS OAuth credential in Google Cloud Console
2. Add the iOS Client ID to `ios/Runner/Info.plist`

---

## Troubleshooting

### "Google Sign-In is not configured yet"
- ✅ Make sure you added the Web Client ID to `web/index.html`
- ✅ Make sure you replaced `YOUR_WEB_CLIENT_ID` with your actual ID
- ✅ Restart your Flutter app after making changes

### "Invalid Client ID"
- ✅ Double-check you copied the full Client ID correctly
- ✅ Make sure it ends with `.apps.googleusercontent.com`

### "Redirect URI mismatch"
- ✅ Make sure you added `http://localhost:5000` to "Authorized JavaScript origins" in Google Cloud Console
- ✅ If you're running on a different port, add that port too

### Still not working?
- ✅ Clear browser cache: `Ctrl+Shift+Delete`
- ✅ Restart Flutter: `flutter run -d chrome`
- ✅ Check browser console for errors: `F12` → Console tab

---

## Cost
✅ **100% FREE** - Google Sign-In is completely free. No credit card needed.

---

## Next Steps
1. ✅ Complete this Web setup
2. ⏭️ Then configure Android (see `ANDROID_OAUTH_CONFIG.md`)
3. ⏭️ Then configure iOS (similar to Android)
4. ⏭️ Test on all platforms
