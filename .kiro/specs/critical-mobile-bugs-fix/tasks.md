# Implementation Plan - Critical Mobile Bugs Fix

This implementation plan addresses three critical bugs affecting the IronFlow Flutter fitness app on Android mobile devices. The plan follows the exploratory bugfix workflow: Explore → Preserve → Implement → Validate.

---

## Bug 1: Logout Stuck in Loading State

### Phase 1: Exploration

- [x] 1.1 Write bug condition exploration test
  - **Property 1: Bug Condition** - Logout Loading Dialog Never Completes
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bug exists
  - **Scoped PBT Approach**: Scope the property to the concrete failing case - user clicks logout button on Android and loading dialog appears
  - Test that logout completes within 3 seconds for all logout attempts on Android/Mobile
  - Test that loading dialog closes automatically after logout completes
  - Test that user is redirected to login screen after logout
  - Test that auth state is cleared (isAuthenticated = false, user = null)
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (this is correct - it proves the bug exists)
  - Document counterexamples found: loading dialog never closes, timeout occurs, user remains authenticated
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

### Phase 2: Preservation

- [-] 1.2 Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Auth Flow Unchanged for Non-Logout Operations
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-logout operations:
    - Email/password login flow works correctly
    - Google Sign-In flow works correctly
    - Navigation to protected routes while authenticated works correctly
    - Session persistence across app restarts works correctly
  - Write property-based tests capturing observed behavior patterns:
    - For all login attempts (email/password, Google), authentication succeeds and navigates to home
    - For all navigation attempts to protected routes while authenticated, access is granted
    - For all app restarts with valid session, user remains authenticated
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

### Phase 3: Implementation

- [~] 1.3 Fix logout stuck in loading state

  - [ ] 1.3.1 Simplify logout flow in profile_screen.dart
    - Open `lib/features/profile/presentation/screens/profile_screen.dart`
    - Locate `_showLogoutDialog` method (lines 680-750)
    - Remove the 1-second delay after `signOut()` completes (unnecessary complexity)
    - Change `Navigator.pop(context)` to `Navigator.of(context, rootNavigator: true).pop()` to force dialog dismissal from root navigator
    - Perform navigation immediately after `signOut()` completes using `context.go('/login')`
    - Remove timeout complexity - rely on signOut operation to complete quickly
    - Add state verification: check `isAuthenticated = false` before navigation
    - _Bug_Condition: isBugCondition_Logout(input) where input.platform = "Android" OR "Mobile" AND input.logoutButtonClicked = true AND input.loadingDialogShown = true_
    - _Expected_Behavior: Logout completes within 3 seconds, dialog closes automatically, redirects to login, clears auth state_
    - _Preservation: Login flow, navigation to protected routes, auth state management remain unchanged_
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 3.1, 3.2, 3.3, 3.4_

  - [ ] 1.3.2 Improve router redirect logic in app_router.dart
    - Open `lib/core/router/app_router.dart`
    - Locate `redirect` callback (lines 40-80)
    - Ensure immediate redirect when `isAuthenticated = false` and user is on protected route
    - Add debug logging to track when redirects occur and why
    - Verify redirect logic reads auth state directly using `ref.read(authNotifierProvider)`
    - _Bug_Condition: Router redirect conflicts causing loading dialog to remain visible_
    - _Expected_Behavior: Immediate redirect to login when isAuthenticated = false_
    - _Preservation: Existing redirect logic for authenticated users remains unchanged_
    - _Requirements: 2.1, 2.2, 2.3_

  - [ ] 1.3.3 Verify synchronous state update in auth_notifier.dart
    - Open `lib/features/auth/presentation/providers/auth_notifier.dart`
    - Locate `signOut` method (lines 300-350)
    - Verify state update is synchronous after `signOutUseCase.call()` completes
    - Ensure no async operations block the state update
    - Consider adding completion callback for UI to await
    - _Bug_Condition: Async state race condition causing incomplete cleanup_
    - _Expected_Behavior: State updates synchronously, UI can await completion_
    - _Preservation: Existing auth state management remains unchanged_
    - _Requirements: 2.4_

  - [ ] 1.3.4 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Logout Completes Successfully
    - **IMPORTANT**: Re-run the SAME test from task 1.1 - do NOT write a new test
    - The test from task 1.1 encodes the expected behavior
    - When this test passes, it confirms the expected behavior is satisfied
    - Run bug condition exploration test from step 1.1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
    - Verify logout completes within 3 seconds
    - Verify loading dialog closes automatically
    - Verify user is redirected to login screen
    - Verify auth state is cleared
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [ ] 1.3.5 Verify preservation tests still pass
    - **Property 2: Preservation** - Auth Flow Unchanged
    - **IMPORTANT**: Re-run the SAME tests from task 1.2 - do NOT write new tests
    - Run preservation property tests from step 1.2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Verify login flow still works correctly
    - Verify navigation to protected routes still works correctly
    - Verify session persistence still works correctly
    - Confirm all tests still pass after fix (no regressions)

- [~] 1.4 Checkpoint - Ensure all Bug 1 tests pass
  - Run all Bug 1 tests (exploration + preservation)
  - Verify logout completes successfully on Android
  - Verify no regressions in auth flow
  - Ask user if questions arise

---

## Bug 2: Notifications Not Delivered On Time

### Phase 1: Exploration

- [~] 2.1 Write bug condition exploration test
  - **Property 1: Bug Condition** - Scheduled Notifications Not Delivered
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bug exists
  - **Scoped PBT Approach**: Scope the property to concrete failing cases - scheduled notifications for 1 minute in future on Android
  - Test that workout reminders are delivered within 1 minute of scheduled time
  - Test that meal reminders (breakfast, lunch, dinner) are delivered within 1 minute of scheduled times
  - Test that streak reminders are delivered within 1 minute of scheduled time
  - Test that notifications persist across app restarts
  - Check if exact alarm permission is granted using `canScheduleExactNotifications()`
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (this is correct - it proves the bug exists)
  - Document counterexamples found: notifications not delivered, exact alarm permission likely false
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 2.1, 2.2, 2.3, 2.5_

### Phase 2: Preservation

- [~] 2.2 Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Test Notifications and Settings Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-scheduled operations:
    - Test notifications work immediately when "Test Notification" button is clicked
    - Notification settings are saved correctly to local storage
    - Notification permission requests work correctly
    - Notification channels and importance levels work correctly
  - Write property-based tests capturing observed behavior patterns:
    - For all test notification requests, notification appears immediately
    - For all settings changes, settings persist correctly
    - For all permission requests, permission flow works correctly
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.5, 3.6, 3.7, 3.8_

### Phase 3: Implementation

- [~] 2.3 Fix notifications not delivered on time

  - [ ] 2.3.1 Request exact alarm permission during initialization
    - Open `lib/features/notifications/domain/services/notification_service.dart`
    - Locate `initialize` method (lines 50-100)
    - After requesting basic notification permissions, immediately call `requestExactAlarmPermission()`
    - Store the result of `requestExactAlarmPermission()` and log whether permission was granted
    - Add error handling if permission request fails
    - _Bug_Condition: isBugCondition_Notifications(input) where input.platform = "Android" AND input.notificationEnabled = true AND input.scheduledTime IS NOT NULL_
    - _Expected_Behavior: Exact alarm permission requested and granted during initialization_
    - _Preservation: Basic notification permissions and initialization remain unchanged_
    - _Requirements: 2.6, 2.7, 2.8_

  - [ ] 2.3.2 Check exact alarm permission before scheduling
    - Open `lib/features/notifications/domain/services/notification_service.dart`
    - Locate scheduling methods: `scheduleWorkoutReminder`, `scheduleMealReminders`, `scheduleStreakReminder` (lines 150-400)
    - Before calling `zonedSchedule`, check if exact alarm permission is granted using `canScheduleExactNotifications()`
    - If not granted, request it using `requestExactAlarmPermission()`
    - Show user-friendly error if permission is denied, explaining Android 12+ requirement
    - Provide button to open settings if permission is denied
    - _Bug_Condition: Permission not checked before scheduling, causing silent failures_
    - _Expected_Behavior: Permission checked and requested before every schedule operation_
    - _Preservation: Scheduling logic for granted permissions remains unchanged_
    - _Requirements: 2.6, 2.7, 2.8, 2.9, 2.10_

  - [ ] 2.3.3 Add permission status indicator in UI
    - Open `lib/features/notifications/presentation/screens/reminder_settings_screen.dart`
    - Add permission status indicator showing current exact alarm permission status
    - Display clear message if exact alarm permission is not granted
    - Add prominent button to request permission if not granted
    - Explain why exact alarm permission is needed for scheduled notifications
    - _Bug_Condition: Users unaware that permission is missing_
    - _Expected_Behavior: Clear UI feedback about permission status_
    - _Preservation: Existing notification settings UI remains unchanged_
    - _Requirements: 2.6, 2.7, 2.8_

  - [ ] 2.3.4 Verify AndroidManifest.xml permissions
    - Open `android/app/src/main/AndroidManifest.xml`
    - Verify `SCHEDULE_EXACT_ALARM` permission is declared (should be at line 7)
    - Verify `USE_EXACT_ALARM` permission is declared (should be at line 8)
    - Confirm permissions are correctly declared for Android 12+ (API 31+)
    - _Bug_Condition: Permissions declared but not requested at runtime_
    - _Expected_Behavior: Permissions declared in manifest for runtime request_
    - _Preservation: Other manifest permissions remain unchanged_
    - _Requirements: 2.6, 2.7, 2.8_

  - [ ] 2.3.5 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Notifications Delivered On Time
    - **IMPORTANT**: Re-run the SAME test from task 2.1 - do NOT write a new test
    - The test from task 2.1 encodes the expected behavior
    - When this test passes, it confirms the expected behavior is satisfied
    - Run bug condition exploration test from step 2.1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
    - Verify scheduled notifications are delivered within 1 minute
    - Verify notifications persist across app restarts
    - Verify exact alarm permission is granted
    - _Requirements: 2.6, 2.7, 2.8, 2.9, 2.10_

  - [ ] 2.3.6 Verify preservation tests still pass
    - **Property 2: Preservation** - Test Notifications Work
    - **IMPORTANT**: Re-run the SAME tests from task 2.2 - do NOT write new tests
    - Run preservation property tests from step 2.2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Verify test notifications still work immediately
    - Verify notification settings still save correctly
    - Verify permission requests still work correctly
    - Confirm all tests still pass after fix (no regressions)

- [~] 2.4 Checkpoint - Ensure all Bug 2 tests pass
  - Run all Bug 2 tests (exploration + preservation)
  - Verify scheduled notifications are delivered on time on Android
  - Verify no regressions in test notifications and settings
  - Ask user if questions arise

---

## Bug 3: YouTube Videos Failing on Android

### Phase 1: Exploration

- [~] 3.1 Write bug condition exploration test
  - **Property 1: Bug Condition** - YouTube Videos Fail to Load on Android
  - **CRITICAL**: This test MUST FAIL on unfixed code - failure confirms the bug exists
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: This test encodes the expected behavior - it will validate the fix when it passes after implementation
  - **GOAL**: Surface counterexamples that demonstrate the bug exists
  - **Scoped PBT Approach**: Scope the property to concrete failing cases - open exercise detail with YouTube video on Android
  - Test that videos load within 5 seconds on Android
  - Test that video controls are visible and functional
  - Test that playback starts successfully
  - Capture error codes (150, 152, etc.) to understand failure reasons
  - Compare with Web platform (should work correctly, proving video IDs are valid)
  - Run test on UNFIXED code
  - **EXPECTED OUTCOME**: Test FAILS (this is correct - it proves the bug exists)
  - Document counterexamples found: videos show loading forever, error messages appear, WebView not ready
  - Mark task complete when test is written, run, and failure is documented
  - _Requirements: 3.9, 3.10, 3.11, 3.12_

### Phase 2: Preservation

- [~] 3.2 Write preservation property tests (BEFORE implementing fix)
  - **Property 2: Preservation** - Web Videos and Fallbacks Unchanged
  - **IMPORTANT**: Follow observation-first methodology
  - Observe behavior on UNFIXED code for non-Android operations:
    - YouTube videos load and play correctly on Web platform
    - Fallback images display correctly for unavailable videos
    - "Open in YouTube" button provides correct YouTube URL
    - Player disposal and resource cleanup work correctly
  - Write property-based tests capturing observed behavior patterns:
    - For all video playback attempts on Web, videos load and play successfully
    - For all unavailable videos, fallback images display correctly
    - For all player disposal operations, resources are cleaned up properly
  - Property-based testing generates many test cases for stronger guarantees
  - Run tests on UNFIXED code
  - **EXPECTED OUTCOME**: Tests PASS (this confirms baseline behavior to preserve)
  - Mark task complete when tests are written, run, and passing on unfixed code
  - _Requirements: 3.13, 3.14, 3.15, 3.16_

### Phase 3: Implementation

- [~] 3.3 Fix YouTube videos failing on Android

  - [ ] 3.3.1 Add platform-specific initialization delay
    - Open `lib/shared/widgets/youtube_exercise_player.dart`
    - Locate `_initializePlayer` method (lines 60-150)
    - Add `Platform.isAndroid` check at the beginning
    - If Android, add 100-200ms delay before initializing player to ensure WebView is ready
    - Use `await Future.delayed(Duration(milliseconds: 150))` before player initialization
    - Add debug logging to track initialization timing
    - _Bug_Condition: isBugCondition_YouTubeVideo(input) where input.platform = "Android" AND input.videoId IS NOT NULL AND input.playerInitialized = true_
    - _Expected_Behavior: Player initializes after WebView is ready, videos load within 5 seconds_
    - _Preservation: Web platform initialization remains unchanged (no delay)_
    - _Requirements: 2.12, 2.13, 2.14_

  - [ ] 3.3.2 Configure hybrid composition for Android
    - Open `lib/shared/widgets/youtube_exercise_player.dart`
    - Locate `YoutubePlayerController` initialization
    - Add platform-specific configuration for Android to enable hybrid composition mode
    - Add Android-specific params to controller initialization
    - Ensure `enableJavaScript: true` is set (should already be at line 70)
    - _Bug_Condition: Hybrid composition issues causing WebView rendering failures_
    - _Expected_Behavior: Hybrid composition enabled for better WebView rendering_
    - _Preservation: Web platform configuration remains unchanged_
    - _Requirements: 2.12, 2.13, 2.14_

  - [ ] 3.3.3 Improve error handling for Android
    - Open `lib/shared/widgets/youtube_exercise_player.dart`
    - Locate error handling code (lines 120-150)
    - Distinguish between WebView initialization errors and video-specific errors
    - Add specific error messages for Android WebView issues
    - Improve retry button functionality to reinitialize player
    - Add fallback to "Open in YouTube" button for persistent errors
    - _Bug_Condition: Error handling doesn't distinguish between error types_
    - _Expected_Behavior: Clear error messages and effective retry mechanism_
    - _Preservation: Existing error handling for Web remains unchanged_
    - _Requirements: 2.15, 2.16, 2.17_

  - [ ] 3.3.4 Configure WebView in MainActivity (if needed)
    - Open `android/app/src/main/kotlin/com/example/progression_tracker/MainActivity.kt`
    - Add WebView configuration to enable hardware acceleration
    - Enable mixed content mode for YouTube embeds
    - Explicitly enable hybrid composition mode for platform views
    - Add Flutter engine configuration for WebView
    - _Bug_Condition: WebView not properly configured for YouTube iframe player_
    - _Expected_Behavior: WebView configured with proper settings for YouTube_
    - _Preservation: Other MainActivity configuration remains unchanged_
    - _Requirements: 2.12, 2.13, 2.14_

  - [ ] 3.3.5 Verify AndroidManifest.xml configuration
    - Open `android/app/src/main/AndroidManifest.xml`
    - Verify `EnableImpeller` meta-data (line 45) is not conflicting with WebView
    - Consider adding network security configuration for YouTube domains if needed
    - Verify internet permission is declared
    - _Bug_Condition: Manifest configuration may conflict with WebView rendering_
    - _Expected_Behavior: Manifest properly configured for WebView and YouTube_
    - _Preservation: Other manifest settings remain unchanged_
    - _Requirements: 2.12, 2.13, 2.14_

  - [ ] 3.3.6 Verify bug condition exploration test now passes
    - **Property 1: Expected Behavior** - Videos Play Successfully on Android
    - **IMPORTANT**: Re-run the SAME test from task 3.1 - do NOT write a new test
    - The test from task 3.1 encodes the expected behavior
    - When this test passes, it confirms the expected behavior is satisfied
    - Run bug condition exploration test from step 3.1
    - **EXPECTED OUTCOME**: Test PASSES (confirms bug is fixed)
    - Verify videos load within 5 seconds on Android
    - Verify video controls are visible and functional
    - Verify playback starts successfully
    - _Requirements: 2.12, 2.13, 2.14, 2.15, 2.16, 2.17_

  - [ ] 3.3.7 Verify preservation tests still pass
    - **Property 2: Preservation** - Web Videos Still Work
    - **IMPORTANT**: Re-run the SAME tests from task 3.2 - do NOT write new tests
    - Run preservation property tests from step 3.2
    - **EXPECTED OUTCOME**: Tests PASS (confirms no regressions)
    - Verify videos still work correctly on Web platform
    - Verify fallback images still display correctly
    - Verify player disposal still works correctly
    - Confirm all tests still pass after fix (no regressions)

- [~] 3.4 Checkpoint - Ensure all Bug 3 tests pass
  - Run all Bug 3 tests (exploration + preservation)
  - Verify YouTube videos play successfully on Android
  - Verify no regressions in Web videos and fallbacks
  - Ask user if questions arise

---

## Final Checkpoint

- [~] 4. Final validation across all three bugs
  - Run complete test suite for all three bugs
  - Verify all exploration tests pass (bugs are fixed)
  - Verify all preservation tests pass (no regressions)
  - Test on Android emulator (Medium_Phone_API_36.1)
  - Test edge cases: network issues, battery optimization, device reboots
  - Document any remaining issues or limitations
  - Prepare summary report for user

---

## Notes

### Testing Approach
- **Exploration Phase**: Write tests BEFORE fix to surface counterexamples and confirm root cause
- **Preservation Phase**: Observe unfixed code behavior, then write tests to preserve it
- **Implementation Phase**: Apply fixes, then verify both exploration and preservation tests pass
- **Property-Based Testing**: Recommended for preservation to generate many test cases automatically

### Key Principles
- Tests encode expected behavior - they validate the fix when they pass
- Exploration tests MUST FAIL on unfixed code (confirms bug exists)
- Preservation tests MUST PASS on unfixed code (confirms baseline behavior)
- Re-run the SAME tests after fix - do NOT write new tests
- Mark tasks complete when tests are written, run, and results documented

### Success Criteria
- ✅ All exploration tests pass after fix (bugs resolved)
- ✅ All preservation tests pass after fix (no regressions)
- ✅ Logout completes within 3 seconds on Android
- ✅ Scheduled notifications delivered within 1 minute
- ✅ YouTube videos load and play within 5 seconds on Android
