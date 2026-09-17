# Bugfix Requirements Document

## Introduction

This document addresses three critical bugs in the IronFlow Flutter fitness app that are blocking core user functionality on mobile (Android). These bugs affect user authentication (logout), notification delivery, and video playback - all essential features for the mobile experience.

**Affected Platform**: Android (Medium_Phone_API_36.1 emulator)
**User Impact**: High - users cannot log out, miss scheduled reminders, and cannot watch exercise videos
**Previous Attempts**: Multiple fixes have been applied but issues persist

---

## Bug 1: Logout Stuck in Loading State

### Current Behavior (Defect)

1.1 WHEN user clicks the logout button in the profile screen THEN the system displays a loading dialog that never completes

1.2 WHEN the loading dialog is displayed THEN the user remains stuck in the loading state indefinitely

1.3 WHEN the logout operation times out (after 10 seconds) THEN the system shows a timeout message but the user remains logged in

1.4 WHEN the user tries to navigate away from the loading dialog THEN the dialog is non-dismissible (barrierDismissible: false)

### Expected Behavior (Correct)

2.1 WHEN user clicks the logout button THEN the system SHALL complete the logout operation within 2-3 seconds

2.2 WHEN the logout operation completes successfully THEN the system SHALL close the loading dialog automatically

2.3 WHEN the logout operation completes successfully THEN the system SHALL redirect the user to the login screen

2.4 WHEN the logout operation completes successfully THEN the system SHALL clear all authentication state (user session, tokens, cached data)

2.5 WHEN the logout operation fails THEN the system SHALL display a clear error message with a retry option

2.6 WHEN the logout operation times out THEN the system SHALL force navigation to login screen after showing the timeout message

### Unchanged Behavior (Regression Prevention)

3.1 WHEN user is not logged in THEN the system SHALL CONTINUE TO show the login screen

3.2 WHEN user successfully logs in THEN the system SHALL CONTINUE TO navigate to the home screen

3.3 WHEN user navigates to protected routes while authenticated THEN the system SHALL CONTINUE TO allow access

3.4 WHEN logout completes successfully THEN the system SHALL CONTINUE TO prevent back navigation to authenticated screens

---

## Bug 2: Notifications Not Delivered On Time

### Current Behavior (Defect)

2.1 WHEN user enables workout reminders and sets a scheduled time THEN the system does not deliver notifications at the scheduled time

2.2 WHEN user enables meal reminders (breakfast, lunch, dinner) and sets scheduled times THEN the system does not deliver notifications at the scheduled times

2.3 WHEN user enables streak reminders and sets a scheduled time THEN the system does not deliver notifications at the scheduled time

2.4 WHEN user clicks the "Test Notification" button THEN the system immediately shows a notification (proving notification permissions and basic functionality work)

2.5 WHEN scheduled notification times pass THEN the system fails to trigger the scheduled notifications

### Expected Behavior (Correct)

2.6 WHEN user enables workout reminders and sets a scheduled time THEN the system SHALL deliver the notification at the exact scheduled time (within 1 minute accuracy)

2.7 WHEN user enables meal reminders and sets scheduled times THEN the system SHALL deliver breakfast, lunch, and dinner notifications at their respective scheduled times

2.8 WHEN user enables streak reminders and sets a scheduled time THEN the system SHALL deliver the notification at the exact scheduled time

2.9 WHEN scheduled notifications are enabled THEN the system SHALL persist the schedules across app restarts and device reboots

2.10 WHEN the app is in the background or closed THEN the system SHALL still deliver scheduled notifications at the correct times

2.11 WHEN user disables a reminder type THEN the system SHALL cancel all scheduled notifications for that type

### Unchanged Behavior (Regression Prevention)

3.5 WHEN user clicks "Test Notification" button THEN the system SHALL CONTINUE TO show an immediate notification

3.6 WHEN user enables/disables notification settings THEN the system SHALL CONTINUE TO save the settings to local storage

3.7 WHEN user sets custom notification times THEN the system SHALL CONTINUE TO display the selected times in the UI

3.8 WHEN notification permissions are denied THEN the system SHALL CONTINUE TO show an error message

---

## Bug 3: YouTube Videos Failing on Android

### Current Behavior (Defect)

3.9 WHEN user opens an exercise detail screen with a YouTube video on Android THEN the video fails to play

3.10 WHEN the YouTube player attempts to load a video on Android THEN the player shows a loading state indefinitely

3.11 WHEN the YouTube player encounters an error on Android THEN the player may display error messages like "Video unavailable" or "Playback disabled"

3.12 WHEN the YouTube player fails on Android THEN the fallback image is displayed but the video never loads

### Expected Behavior (Correct)

2.12 WHEN user opens an exercise detail screen with a YouTube video on Android THEN the system SHALL load and play the video smoothly

2.13 WHEN the YouTube player initializes on Android THEN the system SHALL complete initialization within 3-5 seconds

2.14 WHEN the YouTube player loads a video on Android THEN the system SHALL display video controls (play/pause, mute/unmute, fullscreen)

2.15 WHEN the YouTube player encounters a network error THEN the system SHALL display a clear error message with a retry button

2.16 WHEN the YouTube player encounters a video-specific error (region-blocked, removed) THEN the system SHALL display the fallback image with an option to open in YouTube app

2.17 WHEN user clicks the retry button after a video error THEN the system SHALL attempt to reload the video

### Unchanged Behavior (Regression Prevention)

3.13 WHEN user opens an exercise detail screen with a YouTube video on Web THEN the system SHALL CONTINUE TO play videos successfully

3.14 WHEN a video is not available for an exercise THEN the system SHALL CONTINUE TO display the fallback thumbnail image

3.15 WHEN user clicks the "Open in YouTube" button THEN the system SHALL CONTINUE TO provide the YouTube URL

3.16 WHEN the YouTube player is disposed THEN the system SHALL CONTINUE TO properly clean up resources to prevent memory leaks

---

## Bug Condition Analysis

### Bug 1: Logout Stuck in Loading State

**Bug Condition Function:**
```pascal
FUNCTION isBugCondition_Logout(X)
  INPUT: X of type LogoutAttempt
  OUTPUT: boolean
  
  // Returns true when logout gets stuck
  RETURN (X.platform = "Android" OR X.platform = "Mobile") 
         AND X.logoutButtonClicked = true
         AND X.loadingDialogShown = true
END FUNCTION
```

**Property Specification:**
```pascal
// Property: Fix Checking - Logout Completes Successfully
FOR ALL X WHERE isBugCondition_Logout(X) DO
  result ← performLogout'(X)
  ASSERT result.completed = true 
         AND result.duration <= 3000ms
         AND result.redirectedToLogin = true
         AND result.authStateCleared = true
END FOR
```

**Preservation Goal:**
```pascal
// Property: Preservation Checking - Auth Flow Unchanged
FOR ALL X WHERE NOT isBugCondition_Logout(X) DO
  ASSERT performLogout(X) = performLogout'(X)
END FOR
```

### Bug 2: Notifications Not Delivered On Time

**Bug Condition Function:**
```pascal
FUNCTION isBugCondition_Notifications(X)
  INPUT: X of type NotificationSchedule
  OUTPUT: boolean
  
  // Returns true when scheduled notifications fail to deliver
  RETURN X.platform = "Android"
         AND X.notificationEnabled = true
         AND X.scheduledTime IS NOT NULL
         AND X.isScheduledNotification = true
         AND X.currentTime >= X.scheduledTime
END FUNCTION
```

**Property Specification:**
```pascal
// Property: Fix Checking - Notifications Delivered On Time
FOR ALL X WHERE isBugCondition_Notifications(X) DO
  result ← scheduleNotification'(X)
  ASSERT result.delivered = true
         AND ABS(result.deliveryTime - X.scheduledTime) <= 60000ms
         AND result.persistsAcrossRestarts = true
END FOR
```

**Preservation Goal:**
```pascal
// Property: Preservation Checking - Test Notifications Work
FOR ALL X WHERE NOT isBugCondition_Notifications(X) DO
  ASSERT scheduleNotification(X) = scheduleNotification'(X)
END FOR
```

### Bug 3: YouTube Videos Failing on Android

**Bug Condition Function:**
```pascal
FUNCTION isBugCondition_YouTubeVideo(X)
  INPUT: X of type VideoPlaybackAttempt
  OUTPUT: boolean
  
  // Returns true when YouTube videos fail on Android
  RETURN X.platform = "Android"
         AND X.videoId IS NOT NULL
         AND X.playerInitialized = true
         AND (X.videoState = "loading_forever" 
              OR X.videoState = "error" 
              OR X.videoState = "failed_to_load")
END FUNCTION
```

**Property Specification:**
```pascal
// Property: Fix Checking - Videos Play Successfully on Android
FOR ALL X WHERE isBugCondition_YouTubeVideo(X) DO
  result ← playYouTubeVideo'(X)
  ASSERT result.loaded = true
         AND result.loadTime <= 5000ms
         AND result.playbackStarted = true
         AND result.controlsVisible = true
END FOR
```

**Preservation Goal:**
```pascal
// Property: Preservation Checking - Web Videos Still Work
FOR ALL X WHERE NOT isBugCondition_YouTubeVideo(X) DO
  ASSERT playYouTubeVideo(X) = playYouTubeVideo'(X)
END FOR
```

---

## Root Cause Hypotheses

### Bug 1: Logout Stuck in Loading State

**Potential Root Causes:**
1. **Router Redirect Conflict**: The router's redirect logic may be interfering with navigation after logout, causing the loading dialog to remain visible
2. **Auth State Update Timing**: The auth state may not be updating synchronously, causing the router to not recognize the logout
3. **Dialog Context Issues**: The loading dialog may be losing its context before it can be dismissed
4. **Async State Race Condition**: Multiple async operations (signOut, state update, navigation) may be racing, causing incomplete cleanup

**Evidence from Code:**
- `profile_screen.dart` lines 680-750: Complex logout flow with multiple async operations and timeouts
- `app_router.dart` lines 40-80: Router redirect logic that reads auth state
- `auth_notifier.dart` lines 200-250: SignOut operation that updates state

### Bug 2: Notifications Not Delivered On Time

**Potential Root Causes:**
1. **Missing Exact Alarm Permission**: Android 12+ requires explicit permission for exact alarms, which may not be properly requested
2. **Incorrect Schedule Mode**: Using `AndroidScheduleMode.exactAllowWhileIdle` may not be sufficient for Android 13+
3. **Timezone Issues**: Timezone calculations may be incorrect, causing notifications to be scheduled at wrong times
4. **Background Restrictions**: Android battery optimization may be killing the notification service
5. **Notification Channel Configuration**: Channel importance/priority may be too low for reliable delivery

**Evidence from Code:**
- `notification_service.dart` lines 100-150: `requestExactAlarmPermission()` method exists but may not be called during initialization
- `notification_service.dart` lines 200-300: Scheduling logic uses `zonedSchedule` with `exactAllowWhileIdle`
- `AndroidManifest.xml`: Permissions are declared but exact alarm permission requires runtime request on Android 12+

### Bug 3: YouTube Videos Failing on Android

**Potential Root Causes:**
1. **WebView Configuration**: Android WebView may not be properly configured for YouTube iframe player
2. **Hybrid Composition Issues**: Flutter's platform view rendering may have issues with YouTube player on Android
3. **JavaScript Execution**: YouTube player requires JavaScript, which may be blocked or failing on Android
4. **Network/CORS Issues**: Android may have stricter network security policies affecting YouTube embeds
5. **Player Initialization Timing**: Player may be initializing before WebView is ready

**Evidence from Code:**
- `youtube_exercise_player.dart` lines 50-100: Player initialization with `enableJavaScript: true`
- `AndroidManifest.xml` line 45: `EnableImpeller` meta-data set to true (may affect rendering)
- `youtube_exercise_player.dart` lines 150-200: Error handling shows various error codes (150, 152)

---

## Counterexamples

### Bug 1: Logout Stuck in Loading State
**Concrete Example:**
```
Input: User clicks logout button on Android emulator
Expected: Logout completes in 2-3 seconds, redirects to login
Actual: Loading dialog shows indefinitely, user stuck, timeout after 10s but still logged in
```

### Bug 2: Notifications Not Delivered On Time
**Concrete Example:**
```
Input: User enables workout reminder for 2:00 PM, current time is 2:05 PM
Expected: Notification delivered at 2:00 PM (or within 1 minute)
Actual: No notification delivered, even though test notification works immediately
```

### Bug 3: YouTube Videos Failing on Android
**Concrete Example:**
```
Input: User opens "Bench Press" exercise detail on Android emulator
Expected: YouTube video loads and plays within 3-5 seconds
Actual: Video shows loading state indefinitely or displays "Video unavailable" error
```

---

## Testing Strategy

### Bug 1: Logout Testing
- **Fix Checking**: Verify logout completes within 3 seconds and redirects to login
- **Preservation Checking**: Verify login flow still works correctly
- **Edge Cases**: Test logout during network issues, test logout with active workout session

### Bug 2: Notification Testing
- **Fix Checking**: Schedule notifications for 1 minute in the future, verify delivery
- **Preservation Checking**: Verify test notifications still work immediately
- **Edge Cases**: Test notifications after app restart, test notifications after device reboot, test with battery optimization enabled

### Bug 3: YouTube Video Testing
- **Fix Checking**: Load exercise videos on Android, verify playback starts within 5 seconds
- **Preservation Checking**: Verify videos still work on Web platform
- **Edge Cases**: Test with slow network, test with region-blocked videos, test with removed videos

---

## Success Criteria

### Bug 1: Logout
- ✅ Logout completes within 3 seconds on Android
- ✅ User is redirected to login screen after logout
- ✅ Auth state is completely cleared (no cached session)
- ✅ Loading dialog closes automatically
- ✅ No timeout errors occur

### Bug 2: Notifications
- ✅ Scheduled notifications are delivered within 1 minute of scheduled time
- ✅ Notifications persist across app restarts
- ✅ Notifications persist across device reboots
- ✅ All three notification types work (workout, meal, streak)
- ✅ Test notifications continue to work immediately

### Bug 3: YouTube Videos
- ✅ Videos load and play within 5 seconds on Android
- ✅ Video controls are visible and functional
- ✅ Fallback image displays for unavailable videos
- ✅ Retry button works correctly
- ✅ Videos continue to work on Web platform
