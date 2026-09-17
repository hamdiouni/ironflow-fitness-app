# Google Sign-In Complete Setup Guide for IronFlow

## Overview

You have successfully:
- ✅ Installed `google_sign_in` package
- ✅ Implemented Google Sign-In button in login/signup screens
- ✅ Added error handling with user-friendly messages
- ✅ Configured web/index.html with placeholder for Web Client ID

Now you need to add your actual credentials from Google Cloud Console.

---

## Current Status

### What's Working
- ✅ Google Sign-In button is visible
- ✅ Button shows loading state
- ✅ Error messages are user-friendly
- ✅ Session persistence works (auto-login)
- ✅ Onboarding flow works after signup

### What's Not Working Yet
- ❌ Web: Needs Web Client ID in `web/index.html`
- ❌ Android: Needs SHA-1 fingerprint configuration
- ❌ iOS: Needs iOS Client ID configuration

---

## Quick Start (Web Only)

### 1. Get Web Client ID (5 minutes)

**Option A: Using Google Cloud Console (Recommended)**

1. Go to https://console.cloud.google.com/
2. Create new project: `IronFlow`
3. Enable Google+ API
4. Create OAuth 2.0 credentials (Web application)
5. Add authorized origins:
   - `http://localhost:5000`
   - `http://localhost:5001`
   - `http://localhost:5002`
6. Copy the Client ID

**Option B: Using Google Sign-In Console (Faster)**

1. Go to https://developers.google.com/identity/sign-in/web/sign-in
2. Click "Get a configuration ID"
3. Follow the wizard
4. Copy the Client ID

### 2. Add to Your App

Edit `web/index.html`:

```html
<meta name="google-signin-client_id" content="YOUR_CLIENT_ID.apps.googleusercontent.com">
```

Replace `YOUR_CLIENT_ID` with your actual ID.

### 3. Test

```bash
flutter run -d chrome
```

Click "Continue with Google" → Sign in → Done! ✅

---

## Complete Setup (All Platforms)

### Phase 1: Web Setup (Do This First)
- Follow "Quick Start" above
- Test on web
- Verify login works

### Phase 2: Android Setup
1. Get SHA-1 fingerprint:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Add to Google Cloud Console
3. Add Android Client ID to `android/app/build.gradle.kts`
4. Test: `flutter run -d android`

### Phase 3: iOS Setup
1. Create iOS OAuth credential in Google Cloud Console
2. Add iOS Client ID to `ios/Runner/Info.plist`
3. Test: `flutter run -d ios`

---

## File Locations

### Web Configuration
- **File**: `web/index.html`
- **What to change**: Replace `YOUR_WEB_CLIENT_ID` with your actual Client ID
- **Example**:
  ```html
  <meta name="google-signin-client_id" content="123456789-abc123def456.apps.googleusercontent.com">
  ```

### Android Configuration
- **File**: `android/app/build.gradle.kts`
- **Already configured**: ✅ No changes needed (uses Flutter defaults)

### iOS Configuration
- **File**: `ios/Runner/Info.plist`
- **What to add**: iOS Client ID (when ready)

---

## Troubleshooting

### Error: "Google Sign-In is not configured yet"
**Cause**: Web Client ID not added to `web/index.html`

**Fix**:
1. Open `web/index.html`
2. Find: `<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID...`
3. Replace `YOUR_WEB_CLIENT_ID` with your actual Client ID
4. Restart Flutter: `flutter run -d chrome`

### Error: "Invalid Client ID"
**Cause**: Client ID is incorrect or incomplete

**Fix**:
1. Go to Google Cloud Console
2. Copy the full Client ID (should end with `.apps.googleusercontent.com`)
3. Paste it exactly into `web/index.html`

### Error: "Redirect URI mismatch"
**Cause**: Your localhost port is not in authorized origins

**Fix**:
1. Go to Google Cloud Console → Credentials
2. Edit the OAuth 2.0 credential
3. Add your port to "Authorized JavaScript origins"
   - If running on port 5000: add `http://localhost:5000`
   - If running on port 5001: add `http://localhost:5001`
4. Save and restart Flutter

### Button doesn't appear
**Cause**: Usually a build issue

**Fix**:
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### Still not working?
1. Clear browser cache: `Ctrl+Shift+Delete`
2. Check browser console: `F12` → Console tab
3. Look for error messages
4. Restart Flutter completely

---

## Cost
✅ **100% FREE** - Google Sign-In is completely free. No credit card required.

---

## What Happens After Sign-In

1. User clicks "Continue with Google"
2. Google Sign-In popup appears
3. User selects their Google account
4. App receives user info (email, name, photo)
5. Session is saved locally (Hive storage)
6. User is redirected to home screen
7. Session persists across app restarts (auto-login)

---

## Security Notes

- ✅ Passwords are NOT stored (Google handles authentication)
- ✅ Session tokens are stored securely in Hive
- ✅ No sensitive data is logged
- ✅ All communication is encrypted (HTTPS)

---

## Next Steps

1. **Right now**: Add Web Client ID to `web/index.html`
2. **Test on web**: `flutter run -d chrome`
3. **When ready**: Configure Android (see `ANDROID_OAUTH_CONFIG.md`)
4. **When ready**: Configure iOS (similar to Android)

---

## Support

If you get stuck:
1. Check the error message carefully
2. Look in the troubleshooting section above
3. Check browser console for detailed errors
4. Verify your Client ID is correct
5. Make sure you're using the right file (`web/index.html`)

Good luck! 🚀
