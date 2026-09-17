# 🧪 Test Google Sign-In - Quick Guide

## ✅ Configuration Complete

Your Client IDs are configured:
- **Web**: ✅ Added to `web/index.html`
- **Android**: ✅ Configured in Google Cloud Console

---

## 🚀 Test Now (2 minutes)

### Option 1: Test on Web (Easiest)

```bash
flutter run -d chrome --web-port=8080
```

**What to do**:
1. App opens in Chrome
2. Click "Continue with Google"
3. Google popup appears
4. Select your Google account
5. ✅ You're logged in!

---

### Option 2: Test on Android

```bash
flutter run -d android
```

**What to do**:
1. App opens on Android device/emulator
2. Click "Continue with Google"
3. Google account picker appears
4. Select your Google account
5. ✅ You're logged in!

---

## 🎯 What You Should See

### Success Flow:

1. **Click "Continue with Google"**
   - Button shows loading spinner

2. **Google Sign-In appears**
   - Web: Popup window
   - Android: Account picker

3. **Select account**
   - Choose your Google account
   - Grant permissions

4. **Logged in!**
   - Redirects to onboarding (first time)
   - Redirects to home (returning user)
   - Profile shows your name/photo

### Console Logs (Success):
```
📊 [Auth] Starting Google Sign-In...
✅ [Auth] Google account selected: your-email@gmail.com
✅ [Auth] Got authentication tokens
📊 [AuthSession] Saving user session...
✅ [AuthSession] Session saved successfully
✅ [Auth] Google Sign-In successful
🔍 [Auth] User: Your Name
```

---

## ❌ Common Issues & Fixes

### Issue 1: "Unauthorized client" (Web)

**Cause**: Authorized origins not configured

**Fix**:
1. Go to: https://console.cloud.google.com/apis/credentials
2. Click your Web Client ID
3. Add to "Authorized JavaScript origins":
   ```
   http://localhost
   http://localhost:8080
   ```
4. Click "SAVE"
5. Wait 5 minutes
6. Try again

---

### Issue 2: "Error 10" or "Developer error" (Android)

**Cause**: SHA-1 fingerprint doesn't match

**Fix**:
1. Get your SHA-1:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Copy the SHA1 under "Variant: debug"
3. Go to: https://console.cloud.google.com/apis/credentials
4. Click your Android Client ID
5. Update SHA-1 certificate fingerprint
6. Click "SAVE"
7. Wait 5 minutes
8. Try again

---

### Issue 3: Popup blocked (Web)

**Fix**:
1. Allow popups for localhost in Chrome
2. Click the popup icon in address bar
3. Select "Always allow popups from localhost"
4. Try again

---

### Issue 4: "Sign in cancelled" immediately

**Cause**: OAuth consent screen not configured or test user not added

**Fix**:
1. Go to: https://console.cloud.google.com/apis/credentials/consent
2. Make sure OAuth consent screen is configured
3. Add your email as a test user
4. Try again

---

## 🔍 Debug Mode

### Enable Detailed Logs

The app already has detailed logging. Check your console for:

- 📊 INFO messages
- ✅ SUCCESS messages
- ❌ ERROR messages
- 🔍 DEBUG details

### Check Browser Console (Web)

1. Open Chrome DevTools (F12)
2. Go to Console tab
3. Look for errors
4. Check Network tab for failed requests

### Check Logcat (Android)

```bash
adb logcat | grep -i "auth\|google"
```

---

## ✅ Verification Steps

### After Successful Sign-In:

1. **Check Profile**
   - Go to Profile tab
   - Should show your Google name
   - Should show your Google photo

2. **Check Session Persistence**
   - Close the app
   - Reopen the app
   - Should auto-login (no login screen)

3. **Check Logout**
   - Click logout
   - Should go to login screen
   - Session should be cleared

---

## 🎉 Success Checklist

- [ ] Google Sign-In button visible
- [ ] Clicking button shows loading
- [ ] Google popup/picker appears
- [ ] Can select Google account
- [ ] Redirects to home/onboarding
- [ ] Profile shows Google name/photo
- [ ] Session persists after app restart
- [ ] Logout works correctly

---

## 📱 Test on Multiple Platforms

### Web (Chrome)
```bash
flutter run -d chrome --web-port=8080
```

### Android (Device/Emulator)
```bash
flutter run -d android
```

### iOS (If configured)
```bash
flutter run -d ios
```

---

## 🆘 Still Not Working?

### 1. Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter run -d chrome --web-port=8080
```

### 2. Check Google Cloud Console
- Verify Web Client ID is correct
- Verify Android Client ID has correct SHA-1
- Verify authorized origins include localhost
- Verify OAuth consent screen is configured

### 3. Wait and Retry
- Google changes take 5-10 minutes to propagate
- Wait a bit and try again

### 4. Check Configuration Files
- `web/index.html` - Has correct Web Client ID
- `android/app/src/main/AndroidManifest.xml` - Has Google Play Services metadata

---

## 💡 Pro Tips

### For Faster Testing
- Use Web (Chrome) first - it's fastest
- Android requires device/emulator setup
- iOS requires Mac and Xcode

### For Better Debugging
- Keep Chrome DevTools open
- Watch console logs
- Check Network tab for API calls

### For Production
- Test on real devices
- Test with different Google accounts
- Test slow network conditions

---

## 📖 Full Documentation

For complete setup guide, see:
- `GOOGLE_SIGNIN_SETUP_GUIDE.md` - Full setup instructions
- `YOUR_GOOGLE_SIGNIN_CONFIG.md` - Your specific configuration

---

## 🚀 Ready to Test?

Run this command now:

```bash
flutter run -d chrome --web-port=8080
```

Then click "Continue with Google" and see the magic! ✨

---

**Expected time**: 2 minutes
**Expected result**: Logged in with Google account
**Cost**: $0 (FREE)
