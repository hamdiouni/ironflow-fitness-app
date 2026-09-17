# Critical Mobile Bugs Fix - Design Document

## Overview

This design document addresses three critical bugs affecting the IronFlow Flutter fitness app on Android mobile devices. These bugs block core user functionality: authentication (logout), notification delivery, and video playback. The fixes target specific root causes while preserving existing functionality.

**Bugs Addressed:**
1. **Logout Stuck in Loading State** - Router redirect conflicts and async state race conditions
2. **Notifications Not Delivered On Time** - Missing Android 12+ exact alarm permission
3. **YouTube Videos Failing on Android** - WebView configuration and hybrid composition issues

**Fix Approach:** Minimal, targeted changes to resolve root causes without introducing regressions.

---

## Glossary

### Bug 1: Logout Stuck in Loading State
- **Bug_Condition (C)**: User clicks logout button on Android/Mobile and loading dialog appears
- **Property (P)**: Logout completes within 3 seconds, redirects to login, clears auth state
- **Preservation**: Login flow, navigation to protected routes, and auth state management remain unchanged
- **Router Redirect**: The `go_router` redirect logic that checks auth state and determines navigation
- **Auth State**: The `AuthState` object managed by `AuthNotifier` containing user, isAuthenticated, isLoading
- **Loading Dialog**: The non-dismissible dialog shown during logout operation
- **Race Condition**: Multiple async operations (signOut, state update, navigation) executing concurrently

### Bug 2: Notifications Not Delivered On Time
- **Bug_Condition (C)**: User enables scheduled notifications (workout, meal, streak) on Android
- **Property (P)**: Notifications delivered at exact scheduled time (within 1 minute accuracy)
- **Preservation**: Test notifications, notification settings UI, and permission handling remain unchanged
- **Exact Alarm Permission**: Android 12+ runtime permission required for precise notification scheduling
- **AndroidScheduleMode**: The scheduling mode used by flutter_local_notifications (exactAllowWhileIdle)
- **NotificationService**: The service class in `lib/features/notifications/domain/services/notification_service.dart`
- **Scheduled Notification**: A notification scheduled for a specific future time using `zonedSchedule`

### Bug 3: YouTube Videos Failing on Android
- **Bug_Condition (C)**: User opens exercise detail screen with YouTube video on Android
- **Property (P)**: Video loads and plays within 5 seconds with visible controls
- **Preservation**: Web platform video playback, fallback images, and error handling remain unchanged
- **WebView**: The Android WebView component used by youtube_player_iframe to render videos
- **Hybrid Composition**: Flutter's platform view rendering mode for embedding native views
- **YouTubeExercisePlayer**: The widget in `lib/shared/widgets/youtube_exercise_player.dart`
- **Player Initialization**: The async process of creating and configuring the YoutubePlayerController

---

## Bug 1: Logout Stuck in Loading State

### Bug Details

#### Bug Condition

The bug manifests when a user clicks the logout button on Android/Mobile. The system displays a loading dialog that never completes, leaving the user stuck indefinitely. After a 10-second timeout, a message appears but the user remains logged in.

**Formal Specification:**
```
FUNCTION isBugCondition_Logout(input)
  INPUT: input of type LogoutAttempt
  OUTPUT: boolean
  
  RETURN (input.platform = "Android" OR input.platform = "Mobile")
         AND input.logoutButtonClicked = true
         AND input.loadingDialogShown = true
         AND (input.dialogNeverCloses = true OR input.timeoutOccurs = true)
END FUNCTION
```

#### Examples

- **Example 1**: User clicks "Logout" button → Loading dialog appears → Dialog stays visible for 10+ seconds → Timeout message shows but user still logged in
- **Example 2**: User clicks "Logout" button → Loading dialog appears → User waits indefinitely → No navigation occurs
- **Example 3**: User clicks "Logout" button → Loading dialog appears → Timeout occurs → User manually navigates away but remains authenticated
- **Edge Case**: User clicks "Logout" during active workout session → Loading dialog appears → Session data may be lost but logout still fails

### Expected Behavior

#### Preservation Requirements

**Unchanged Behaviors:**
- Login flow must continue to work correctly (email/password, Google Sign-In)
- Navigation to protected routes while authenticated must continue to work
- Auth state management for authenticated users must remain unchanged
- Back navigation prevention after successful logout must continue to work

**Scope:**
All inputs that do NOT involve the logout operation should be completely unaffected by this fix. This includes:
- User login attempts
- Auth state checks during app initialization
- Navigation between authenticated screens
- Session persistence across app restarts

### Hypothesized Root Cause

Based on the bug description and code analysis, the most likely issues are:

1. **Router Redirect Conflict**: The router's redirect logic (lines 40-80 in `app_router.dart`) reads auth state and may be interfering with navigation after logout. When `signOut()` completes and sets `isAuthenticated = false`, the router may not immediately recognize the state change, causing the loading dialog to remain visible while navigation is blocked.

2. **Async State Race Condition**: The logout flow in `profile_screen.dart` (lines 680-750) performs multiple async operations:
   - `signOut()` call (updates auth state)
   - 1-second delay (`Future.delayed`)
   - Dialog dismissal (`Navigator.pop`)
   - Navigation (`context.go('/login')`)
   
   These operations may be racing, causing the dialog to not close or navigation to fail.

3. **Dialog Context Loss**: The loading dialog may be losing its context before it can be dismissed, especially if the router is trying to redirect simultaneously.

4. **State Update Timing**: The `AuthNotifier.signOut()` method (lines 300-350 in `auth_notifier.dart`) updates state synchronously, but the router may not be listening to state changes properly, causing a delay in recognizing the logout.

### Correctness Properties

Property 1: Bug Condition - Logout Completes Successfully

_For any_ logout attempt where the user clicks the logout button on Android/Mobile and a loading dialog is shown, the fixed logout flow SHALL complete the operation within 3 seconds, close the loading dialog automatically, redirect the user to the login screen, and clear all authentication state (user session, tokens, cached data).

**Validates: Requirements 2.1, 2.2, 2.3, 2.4**

Property 2: Preservation - Auth Flow Unchanged

_For any_ authentication operation that is NOT a logout attempt (login with email/password, login with Google, navigation to protected routes, session persistence), the fixed code SHALL produce exactly the same behavior as the original code, preserving all existing authentication and navigation functionality.

**Validates: Requirements 3.1, 3.2, 3.3, 3.4**

### Fix Implementation

#### Changes Required

Assuming our root cause analysis is correct:

**File**: `lib/features/profile/presentation/screens/profile_screen.dart`

**Function**: `_showLogoutDialog` (lines 680-750)

**Specific Changes**:
1. **Simplify Async Flow**: Remove the 1-second delay after `signOut()` completes, as it adds unnecessary complexity and may contribute to race conditions.

2. **Force Dialog Dismissal**: Use `Navigator.of(context, rootNavigator: true).pop()` instead of `Navigator.pop(context)` to ensure the dialog is dismissed from the root navigator, preventing context loss issues.

3. **Immediate Navigation After State Update**: Instead of waiting for the dialog to close and then navigating, perform navigation immediately after `signOut()` completes and state is updated. Use `context.go('/login')` with `replace: true` semantics.

4. **Remove Timeout Complexity**: The current timeout logic shows a message but doesn't force navigation. Simplify by removing the timeout and relying on the signOut operation to complete quickly (it should be fast since it's just clearing local state).

5. **Add State Verification**: After `signOut()` completes, verify that `isAuthenticated = false` before attempting navigation to ensure state is properly updated.

**File**: `lib/core/router/app_router.dart`

**Function**: `redirect` callback (lines 40-80)

**Specific Changes**:
1. **Ensure Immediate Redirect**: The redirect logic already reads auth state directly (`ref.read(authNotifierProvider)`), which is correct. However, ensure that when `isAuthenticated = false` and the user is on a protected route, the redirect to login happens immediately without delay.

2. **Add Debug Logging**: Add more detailed logging to track when redirects occur and why, helping diagnose any remaining timing issues.

**File**: `lib/features/auth/presentation/providers/auth_notifier.dart`

**Function**: `signOut` (lines 300-350)

**Specific Changes**:
1. **Ensure Synchronous State Update**: The current implementation already updates state synchronously after `signOutUseCase.call()` completes. Verify that no async operations are blocking the state update.

2. **Add Completion Callback**: Consider adding a callback or future completion signal that the UI can await to ensure signOut is fully complete before attempting navigation.

### Testing Strategy

#### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bug on unfixed code, then verify the fix works correctly and preserves existing behavior.

#### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Confirm or refute the root cause analysis. If we refute, we will need to re-hypothesize.

**Test Plan**: Write integration tests that simulate the logout flow on Android emulator. Run these tests on the UNFIXED code to observe failures and understand the root cause.

**Test Cases**:
1. **Basic Logout Test**: Click logout button, observe loading dialog behavior (will fail on unfixed code - dialog never closes)
2. **Logout with Active Session**: Start a workout, then logout, observe behavior (will fail on unfixed code)
3. **Logout with Network Delay**: Simulate slow network, then logout (may fail on unfixed code)
4. **Rapid Logout Attempts**: Click logout multiple times rapidly (may fail on unfixed code)

**Expected Counterexamples**:
- Loading dialog remains visible indefinitely
- Timeout message appears but user remains authenticated
- Navigation to login screen fails
- Possible causes: router redirect conflict, async race condition, dialog context loss

#### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed function produces the expected behavior.

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition_Logout(input) DO
  result := performLogout_fixed(input)
  ASSERT result.completed = true
         AND result.duration <= 3000ms
         AND result.dialogClosed = true
         AND result.redirectedToLogin = true
         AND result.authStateCleared = true
END FOR
```

#### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL input WHERE NOT isBugCondition_Logout(input) DO
  ASSERT performAuth_original(input) = performAuth_fixed(input)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all non-logout operations

**Test Plan**: Observe behavior on UNFIXED code first for login and navigation, then write property-based tests capturing that behavior.

**Test Cases**:
1. **Login Preservation**: Observe that email/password login works correctly on unfixed code, then write test to verify this continues after fix
2. **Google Sign-In Preservation**: Observe that Google Sign-In works correctly on unfixed code, then write test to verify this continues after fix
3. **Navigation Preservation**: Observe that navigation to protected routes works correctly on unfixed code, then write test to verify this continues after fix
4. **Session Persistence Preservation**: Observe that session persistence across app restarts works correctly on unfixed code, then write test to verify this continues after fix

#### Unit Tests

- Test logout flow completes within 3 seconds
- Test loading dialog closes automatically
- Test navigation to login screen occurs
- Test auth state is cleared (isAuthenticated = false, user = null)
- Test edge cases (logout during active workout, logout with network issues)

#### Property-Based Tests

- Generate random user states and verify logout always completes successfully
- Generate random navigation scenarios and verify login/navigation continue to work
- Test that all non-logout auth operations produce identical results before and after fix

#### Integration Tests

- Test full logout flow from profile screen to login screen
- Test that user cannot navigate back to authenticated screens after logout
- Test that re-login works correctly after logout
- Test logout behavior across different Android versions

---

## Bug 2: Notifications Not Delivered On Time

### Bug Details

#### Bug Condition

The bug manifests when a user enables scheduled notifications (workout reminders, meal reminders, or streak reminders) on Android. The system schedules the notifications but they are not delivered at the scheduled time. Test notifications work immediately, proving that basic notification functionality and permissions are working.

**Formal Specification:**
```
FUNCTION isBugCondition_Notifications(input)
  INPUT: input of type NotificationSchedule
  OUTPUT: boolean
  
  RETURN input.platform = "Android"
         AND input.notificationEnabled = true
         AND input.scheduledTime IS NOT NULL
         AND input.isScheduledNotification = true
         AND input.currentTime >= input.scheduledTime
         AND input.notificationDelivered = false
END FUNCTION
```

#### Examples

- **Example 1**: User enables workout reminder for 2:00 PM → Current time is 2:05 PM → No notification delivered
- **Example 2**: User enables breakfast reminder for 8:00 AM → Next day at 8:00 AM → No notification delivered
- **Example 3**: User enables streak reminder for 9:00 PM → Current time is 9:15 PM → No notification delivered
- **Edge Case**: User clicks "Test Notification" button → Notification appears immediately (proving permissions work)

### Expected Behavior

#### Preservation Requirements

**Unchanged Behaviors:**
- Test notifications must continue to work immediately when "Test Notification" button is clicked
- Notification settings UI must continue to display and save user preferences correctly
- Notification permission requests must continue to work correctly
- Notification channels and importance levels must remain unchanged

**Scope:**
All inputs that do NOT involve scheduled notifications should be completely unaffected by this fix. This includes:
- Immediate notifications (test notifications, workout completion notifications)
- Notification permission handling
- Notification settings persistence
- Notification UI display

### Hypothesized Root Cause

Based on the bug description and code analysis, the most likely issues are:

1. **Missing Exact Alarm Permission Request**: Android 12+ (API 31+) requires explicit runtime permission for exact alarms (`SCHEDULE_EXACT_ALARM`). The `NotificationService` has a `requestExactAlarmPermission()` method (lines 100-150 in `notification_service.dart`), but this method may not be called during app initialization or when scheduling notifications. The permission is declared in `AndroidManifest.xml` but not requested at runtime.

2. **Permission Not Requested Before Scheduling**: The notification scheduling methods (`scheduleWorkoutReminder`, `scheduleMealReminders`, `scheduleStreakReminder`) do not check or request exact alarm permission before calling `zonedSchedule`. If the permission is not granted, Android silently fails to schedule the notification.

3. **Incorrect Schedule Mode**: The code uses `AndroidScheduleMode.exactAllowWhileIdle`, which is correct for Android 12+, but without the exact alarm permission, this mode is ineffective.

4. **Initialization Order**: The `NotificationService.initialize()` method requests basic notification permissions but does not request exact alarm permission. This means even if the user grants notification permissions, exact alarms may still be blocked.

### Correctness Properties

Property 1: Bug Condition - Notifications Delivered On Time

_For any_ notification schedule where the user enables a scheduled notification (workout, meal, or streak) on Android and sets a specific time, the fixed notification system SHALL deliver the notification at the exact scheduled time (within 1 minute accuracy), persist the schedule across app restarts and device reboots, and continue delivering notifications while the app is in the background or closed.

**Validates: Requirements 2.6, 2.7, 2.8, 2.9, 2.10**

Property 2: Preservation - Test Notifications and Settings Unchanged

_For any_ notification operation that is NOT a scheduled notification (test notifications, notification settings UI, permission requests), the fixed code SHALL produce exactly the same behavior as the original code, preserving all existing notification functionality for immediate notifications and settings management.

**Validates: Requirements 3.5, 3.6, 3.7, 3.8**

### Fix Implementation

#### Changes Required

Assuming our root cause analysis is correct:

**File**: `lib/features/notifications/domain/services/notification_service.dart`

**Function**: `initialize` (lines 50-100)

**Specific Changes**:
1. **Request Exact Alarm Permission During Initialization**: After requesting basic notification permissions, immediately call `requestExactAlarmPermission()` to ensure exact alarms are allowed before any scheduling occurs.

2. **Add Permission Check Result**: Store the result of `requestExactAlarmPermission()` and log whether the permission was granted. This helps diagnose issues.

**Function**: `scheduleWorkoutReminder`, `scheduleMealReminders`, `scheduleStreakReminder` (lines 150-400)

**Specific Changes**:
1. **Check Exact Alarm Permission Before Scheduling**: Before calling `zonedSchedule`, check if exact alarm permission is granted using `canScheduleExactNotifications()`. If not granted, request it.

2. **Show User-Friendly Error**: If exact alarm permission is denied, show a clear error message explaining that Android 12+ requires this permission for scheduled notifications and provide a button to open settings.

3. **Fallback to Inexact Scheduling**: If exact alarm permission is denied and the user doesn't want to grant it, consider falling back to inexact scheduling (though this may not meet the 1-minute accuracy requirement).

**File**: `lib/features/notifications/presentation/screens/reminder_settings_screen.dart`

**Specific Changes**:
1. **Add Permission Status Indicator**: Display the current exact alarm permission status in the UI so users know if their scheduled notifications will work.

2. **Add Permission Request Button**: If exact alarm permission is not granted, show a prominent button to request it, explaining why it's needed.

**File**: `android/app/src/main/AndroidManifest.xml`

**Verification**:
1. **Verify Permission Declaration**: Confirm that `SCHEDULE_EXACT_ALARM` and `USE_EXACT_ALARM` permissions are declared (they already are, lines 7-8).

### Testing Strategy

#### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bug on unfixed code, then verify the fix works correctly and preserves existing behavior.

#### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Confirm or refute the root cause analysis. If we refute, we will need to re-hypothesize.

**Test Plan**: Write integration tests that schedule notifications for 1 minute in the future on Android emulator (API 31+). Run these tests on the UNFIXED code to observe failures and understand the root cause.

**Test Cases**:
1. **Workout Reminder Test**: Schedule workout reminder for 1 minute in future, wait, observe no notification (will fail on unfixed code)
2. **Meal Reminder Test**: Schedule breakfast reminder for 1 minute in future, wait, observe no notification (will fail on unfixed code)
3. **Streak Reminder Test**: Schedule streak reminder for 1 minute in future, wait, observe no notification (will fail on unfixed code)
4. **Permission Check Test**: Check if exact alarm permission is granted (will likely return false on unfixed code)

**Expected Counterexamples**:
- Scheduled notifications are not delivered at the scheduled time
- `canScheduleExactNotifications()` returns false
- Possible causes: missing exact alarm permission request, permission not granted before scheduling

#### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed function produces the expected behavior.

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition_Notifications(input) DO
  result := scheduleNotification_fixed(input)
  ASSERT result.delivered = true
         AND ABS(result.deliveryTime - input.scheduledTime) <= 60000ms
         AND result.persistsAcrossRestarts = true
END FOR
```

#### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL input WHERE NOT isBugCondition_Notifications(input) DO
  ASSERT scheduleNotification_original(input) = scheduleNotification_fixed(input)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all non-scheduled notifications

**Test Plan**: Observe behavior on UNFIXED code first for test notifications and settings, then write property-based tests capturing that behavior.

**Test Cases**:
1. **Test Notification Preservation**: Observe that test notifications work immediately on unfixed code, then write test to verify this continues after fix
2. **Settings Persistence Preservation**: Observe that notification settings are saved correctly on unfixed code, then write test to verify this continues after fix
3. **Permission Handling Preservation**: Observe that basic notification permissions work correctly on unfixed code, then write test to verify this continues after fix

#### Unit Tests

- Test exact alarm permission is requested during initialization
- Test exact alarm permission is checked before scheduling
- Test scheduled notifications are delivered within 1 minute of scheduled time
- Test notifications persist across app restarts
- Test notifications persist across device reboots
- Test error handling when permission is denied

#### Property-Based Tests

- Generate random notification schedules and verify all are delivered on time
- Generate random app states (foreground, background, closed) and verify notifications still deliver
- Test that all non-scheduled notification operations produce identical results before and after fix

#### Integration Tests

- Test full notification flow from settings screen to notification delivery
- Test notification delivery after app restart
- Test notification delivery after device reboot
- Test notification delivery with battery optimization enabled
- Test exact alarm permission request flow

---

## Bug 3: YouTube Videos Failing on Android

### Bug Details

#### Bug Condition

The bug manifests when a user opens an exercise detail screen with a YouTube video on Android. The video fails to play, showing either a loading state indefinitely or error messages like "Video unavailable" or "Playback disabled". The fallback image is displayed but the video never loads.

**Formal Specification:**
```
FUNCTION isBugCondition_YouTubeVideo(input)
  INPUT: input of type VideoPlaybackAttempt
  OUTPUT: boolean
  
  RETURN input.platform = "Android"
         AND input.videoId IS NOT NULL
         AND input.playerInitialized = true
         AND (input.videoState = "loading_forever" 
              OR input.videoState = "error" 
              OR input.videoState = "failed_to_load")
END FUNCTION
```

#### Examples

- **Example 1**: User opens "Bench Press" exercise detail on Android → Video shows loading state indefinitely → Never starts playing
- **Example 2**: User opens "Squat" exercise detail on Android → Video shows "Video unavailable" error → Fallback image displayed
- **Example 3**: User opens "Deadlift" exercise detail on Android → Video shows "Playback disabled by owner" error → Retry button doesn't help
- **Edge Case**: User opens same exercise on Web platform → Video loads and plays successfully (proving video ID is correct)

### Expected Behavior

#### Preservation Requirements

**Unchanged Behaviors:**
- YouTube videos must continue to work correctly on Web platform
- Fallback images must continue to display when videos are not available
- "Open in YouTube" button must continue to provide the YouTube URL
- Player disposal and resource cleanup must continue to work correctly to prevent memory leaks

**Scope:**
All inputs that do NOT involve Android video playback should be completely unaffected by this fix. This includes:
- Web platform video playback
- Fallback image display
- Error handling for unavailable videos
- Player lifecycle management

### Hypothesized Root Cause

Based on the bug description and code analysis, the most likely issues are:

1. **WebView Configuration Issues**: Android WebView may not be properly configured for YouTube iframe player. The `youtube_player_iframe` package relies on WebView to render videos, and Android WebView has stricter security policies than Web browsers. The player initialization (lines 50-100 in `youtube_exercise_player.dart`) may need additional WebView configuration.

2. **Hybrid Composition Rendering**: The `AndroidManifest.xml` has `EnableImpeller` set to true (line 45), which enables Flutter's new rendering engine. This may conflict with the platform view rendering used by `youtube_player_iframe`. Hybrid composition mode may need to be explicitly enabled for WebView.

3. **JavaScript Execution Timing**: The YouTube player requires JavaScript to be enabled (which it is, line 70 in `youtube_exercise_player.dart`), but the JavaScript may be executing before the WebView is fully ready on Android. This could cause initialization failures.

4. **Network Security Configuration**: Android may have stricter network security policies that block YouTube iframe embeds. The app may need to configure network security to allow YouTube domains.

5. **Player Initialization Timing**: The player controller is initialized immediately in `initState` (line 60), but the WebView may not be ready yet on Android. Adding a delay or waiting for WebView ready signal may help.

### Correctness Properties

Property 1: Bug Condition - Videos Play Successfully on Android

_For any_ video playback attempt where the user opens an exercise detail screen with a YouTube video on Android and the video ID is valid, the fixed YouTube player SHALL load the video within 5 seconds, start playback successfully, display video controls (play/pause, mute/unmute, fullscreen), and handle errors gracefully with clear error messages and retry options.

**Validates: Requirements 2.12, 2.13, 2.14, 2.15, 2.16, 2.17**

Property 2: Preservation - Web Videos and Fallbacks Unchanged

_For any_ video playback operation that is NOT on Android platform (Web platform videos, fallback image display, unavailable video handling), the fixed code SHALL produce exactly the same behavior as the original code, preserving all existing video playback functionality for Web and error handling.

**Validates: Requirements 3.13, 3.14, 3.15, 3.16**

### Fix Implementation

#### Changes Required

Assuming our root cause analysis is correct:

**File**: `lib/shared/widgets/youtube_exercise_player.dart`

**Function**: `_initializePlayer` (lines 60-150)

**Specific Changes**:
1. **Add Platform-Specific Initialization**: Detect if running on Android and add a delay before initializing the player to ensure WebView is ready. Use `Platform.isAndroid` check.

2. **Configure Hybrid Composition**: Add platform-specific configuration for Android to enable hybrid composition mode for better WebView rendering. This may require updating the `YoutubePlayerController` initialization with Android-specific params.

3. **Add WebView Ready Check**: Before initializing the player, ensure the WebView is ready by adding a small delay (100-200ms) on Android only.

4. **Improve Error Handling**: The current error handling (lines 120-150) catches errors but may not distinguish between WebView initialization errors and video-specific errors. Add more specific error handling for Android WebView issues.

**File**: `android/app/src/main/AndroidManifest.xml`

**Specific Changes**:
1. **Add Network Security Configuration**: Create a network security configuration file to explicitly allow YouTube domains if needed.

2. **Verify Hybrid Composition**: Ensure that the `EnableImpeller` meta-data (line 45) is not conflicting with WebView rendering. Consider adding explicit hybrid composition configuration.

**File**: `android/app/src/main/kotlin/com/example/progression_tracker/MainActivity.kt`

**Specific Changes**:
1. **Configure WebView**: Add WebView configuration in MainActivity to enable hardware acceleration and mixed content mode for YouTube embeds.

2. **Enable Hybrid Composition**: Explicitly enable hybrid composition mode for platform views in the Flutter engine configuration.

**Alternative Approach (if WebView issues persist)**:
If WebView configuration doesn't resolve the issue, consider using a different YouTube player package that's more Android-friendly, such as:
- `youtube_player_flutter` (uses native Android YouTube player)
- `flutter_inappwebview` (more control over WebView configuration)

### Testing Strategy

#### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bug on unfixed code, then verify the fix works correctly and preserves existing behavior.

#### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate the bug BEFORE implementing the fix. Confirm or refute the root cause analysis. If we refute, we will need to re-hypothesize.

**Test Plan**: Write integration tests that open exercise detail screens with YouTube videos on Android emulator. Run these tests on the UNFIXED code to observe failures and understand the root cause.

**Test Cases**:
1. **Basic Video Load Test**: Open "Bench Press" exercise detail on Android, observe video loading behavior (will fail on unfixed code - loading forever)
2. **Multiple Video Test**: Open several different exercises with videos, observe if any load successfully (will likely all fail on unfixed code)
3. **Web Platform Test**: Open same exercises on Web platform, observe videos load successfully (should pass, proving video IDs are correct)
4. **Error Code Analysis**: Capture error codes from player (150, 152, etc.) to understand failure reasons (will show errors on unfixed code)

**Expected Counterexamples**:
- Videos show loading state indefinitely on Android
- Videos show error messages (150, 152) on Android
- Same videos work correctly on Web platform
- Possible causes: WebView not ready, hybrid composition issues, JavaScript timing

#### Fix Checking

**Goal**: Verify that for all inputs where the bug condition holds, the fixed function produces the expected behavior.

**Pseudocode:**
```
FOR ALL input WHERE isBugCondition_YouTubeVideo(input) DO
  result := playYouTubeVideo_fixed(input)
  ASSERT result.loaded = true
         AND result.loadTime <= 5000ms
         AND result.playbackStarted = true
         AND result.controlsVisible = true
END FOR
```

#### Preservation Checking

**Goal**: Verify that for all inputs where the bug condition does NOT hold, the fixed function produces the same result as the original function.

**Pseudocode:**
```
FOR ALL input WHERE NOT isBugCondition_YouTubeVideo(input) DO
  ASSERT playYouTubeVideo_original(input) = playYouTubeVideo_fixed(input)
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss
- It provides strong guarantees that behavior is unchanged for all non-Android video operations

**Test Plan**: Observe behavior on UNFIXED code first for Web videos and fallbacks, then write property-based tests capturing that behavior.

**Test Cases**:
1. **Web Video Preservation**: Observe that videos load and play correctly on Web platform on unfixed code, then write test to verify this continues after fix
2. **Fallback Image Preservation**: Observe that fallback images display correctly for unavailable videos on unfixed code, then write test to verify this continues after fix
3. **Error Handling Preservation**: Observe that error handling works correctly on unfixed code, then write test to verify this continues after fix
4. **Player Disposal Preservation**: Observe that player disposal and cleanup work correctly on unfixed code, then write test to verify this continues after fix

#### Unit Tests

- Test video loads within 5 seconds on Android
- Test video controls are visible and functional
- Test error handling for unavailable videos
- Test retry button functionality
- Test "Open in YouTube" button functionality
- Test player disposal and resource cleanup

#### Property-Based Tests

- Generate random exercise names with videos and verify all load successfully on Android
- Generate random platform configurations (Android, Web) and verify videos work on all platforms
- Test that all non-Android video operations produce identical results before and after fix

#### Integration Tests

- Test full video playback flow from exercise detail screen on Android
- Test video playback with slow network connection
- Test video playback with region-blocked videos
- Test video playback with removed videos
- Test video playback across different Android versions
- Test that Web platform videos continue to work correctly

---

## Summary

This design document provides comprehensive technical solutions for three critical mobile bugs:

1. **Logout Stuck in Loading State**: Simplify async flow, force dialog dismissal, and ensure immediate navigation after state update
2. **Notifications Not Delivered On Time**: Request exact alarm permission during initialization and before scheduling
3. **YouTube Videos Failing on Android**: Add platform-specific initialization delay and configure WebView for hybrid composition

Each fix is targeted, minimal, and designed to preserve existing functionality while resolving the root cause of the bug. The testing strategy ensures both fix correctness and preservation of unchanged behavior.
