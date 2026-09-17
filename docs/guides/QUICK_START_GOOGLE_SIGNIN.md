# Quick Start: Google Sign-In in 5 Minutes

## The Problem
You're seeing: "Google Sign-In is not configured yet"

## The Solution
Add your Web Client ID to `web/index.html`

---

## Step 1: Get Web Client ID (3 minutes)

### Option A: Google Cloud Console (Recommended)
```
1. Go to https://console.cloud.google.com/
2. Click "Select a Project" → "NEW PROJECT"
3. Name: "IronFlow" → CREATE
4. Search for "Google+ API" → ENABLE
5. Go to "Credentials" → "+ CREATE CREDENTIALS"
6. Choose "OAuth client ID" → "Web application"
7. Name: "IronFlow Web"
8. Add authorized origins:
   - http://localhost:5000
   - http://localhost:5001
   - http://localhost:5002
9. CREATE
10. Copy the "Client ID" (looks like: 123456789-abc...apps.googleusercontent.com)
```

### Option B: Google Sign-In Console (Faster)
```
1. Go to https://developers.google.com/identity/sign-in/web/sign-in
2. Click "Get a configuration ID"
3. Follow the wizard
4. Copy the Client ID
```

---

## Step 2: Add to Your App (1 minute)

### Edit: `web/index.html`

**Find this line (around line 33):**
```html
<meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
```

**Replace `YOUR_WEB_CLIENT_ID` with your actual ID:**
```html
<meta name="google-signin-client_id" content="123456789-abc123def456.apps.googleusercontent.com">
```

**Save the file.**

---

## Step 3: Test (1 minute)

### Run on Web
```bash
flutter run -d chrome
```

### Test the Flow
1. Click "Continue with Google" button
2. Google Sign-In popup appears
3. Select your Google account
4. You're logged in! ✅

---

## Done! 🎉

Your Google Sign-In is now working!

---

## What If It Doesn't Work?

### Error: "Google Sign-In is not configured yet"
- ✅ Make sure you replaced `YOUR_WEB_CLIENT_ID` with your actual ID
- ✅ Make sure you saved the file
- ✅ Restart Flutter: `flutter run -d chrome`

### Error: "Invalid Client ID"
- ✅ Copy the full Client ID from Google Cloud Console
- ✅ Make sure it ends with `.apps.googleusercontent.com`
- ✅ No extra spaces or characters

### Error: "Redirect URI mismatch"
- ✅ Go to Google Cloud Console
- ✅ Edit the OAuth credential
- ✅ Add your localhost port to "Authorized JavaScript origins"
- ✅ Save and restart Flutter

### Button doesn't appear
- ✅ Run: `flutter clean && flutter pub get && flutter run -d chrome`

### Still not working?
- ✅ Open browser console: `F12` → Console tab
- ✅ Look for error messages
- ✅ Check if your Client ID is correct in `web/index.html`

---

## Cost
✅ **100% FREE** - No credit card needed

---

## Next Steps

### After Web Works
1. Configure Android (see `ANDROID_OAUTH_CONFIG.md`)
2. Configure iOS (similar to Android)

### For More Details
- Read `GOOGLE_SIGNIN_COMPLETE_GUIDE.md`
- Read `FAQ_GOOGLE_SIGNIN.md`

---

## That's It!

You now have Google Sign-In working in IronFlow! 🚀

Questions? Check `FAQ_GOOGLE_SIGNIN.md`
