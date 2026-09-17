# Clear Onboarding Data - Testing Instructions

## Problem
If you're testing the onboarding flow and it's not working correctly, you might have old data in Hive storage from previous testing sessions.

## Solution: Clear Browser Storage (Web)

### Option 1: Clear All Site Data (Recommended)
1. Open your app in the browser
2. Open Developer Tools (F12 or Right-click → Inspect)
3. Go to the **Application** tab (Chrome) or **Storage** tab (Firefox)
4. In the left sidebar, find **Storage** section
5. Click **Clear site data** button
6. Refresh the page

### Option 2: Clear IndexedDB Manually
1. Open Developer Tools (F12)
2. Go to **Application** tab (Chrome) or **Storage** tab (Firefox)
3. In the left sidebar, expand **IndexedDB**
4. Find and delete the `user_profile` database
5. Refresh the page

### Option 3: Use Browser Console
1. Open Developer Tools (F12)
2. Go to **Console** tab
3. Run this command:
```javascript
indexedDB.deleteDatabase('user_profile');
```
4. Refresh the page

## Solution: Clear App Data (Mobile)

### Android
1. Go to Settings → Apps
2. Find your app (Progression Tracker)
3. Tap **Storage**
4. Tap **Clear Data** or **Clear Storage**
5. Restart the app

### iOS
1. Uninstall the app
2. Reinstall the app

## Testing the Fix

After clearing the data:

1. **Sign up with a new account** (email or Google)
2. You should see these logs in the console:
   ```
   ✅ [Auth] Sign up successful
   📊 [Signup] Checking onboarding status...
   📊 [Onboarding] Checking onboarding status: false
   📊 [Signup] Onboarding status: false
   📊 [Signup] User needs onboarding, navigating to /onboarding
   ```
3. You should be redirected to the **onboarding screen**
4. Complete the onboarding flow
5. You should see:
   ```
   ✅ [Onboarding] User marked as onboarded
   ```
6. You should be redirected to the **home screen**

## If It Still Doesn't Work

If after clearing storage you still see `isOnboarded: true` for a new user, there might be a code issue. Check:

1. Is there any code that automatically marks users as onboarded?
2. Is there a migration script that sets onboarded to true?
3. Is there a default value somewhere that's set to true?

## Debug Logs to Watch For

**Expected for NEW user:**
```
📊 [Signup] Checking onboarding status...
📊 [Onboarding] Checking onboarding status: false  ← Should be FALSE
📊 [Signup] Onboarding status: false
📊 [Signup] User needs onboarding, navigating to /onboarding
```

**Expected for RETURNING user (already onboarded):**
```
📊 [Signup] Checking onboarding status...
📊 [Onboarding] Checking onboarding status: true  ← Should be TRUE
📊 [Signup] Onboarding status: true
✅ [Signup] User already onboarded, navigating to /home
```
