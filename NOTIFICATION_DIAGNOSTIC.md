# Notification System Diagnostic & Fix Guide

**Date**: 2026-05-17  
**App**: IronFlow  
**Issue**: Notification system problems

---

## Common Notification Issues & Solutions

### Issue 1: Notifications Not Showing on Web

**Problem**: Flutter Local Notifications doesn't work on Web platform

**Solution**: Notifications are only supported on mobile (Android/iOS)

**Fix**:
```dart
// In notification_service.dart, add platform check
import 'package:flutter/foundation.dart';

Future<void> initialize({required Function(String?) onNotificationTap}) async {
  if (kIsWeb) {
    print('⚠️ Notifications not supported on Web platform');
    _initialized = true;
    return;
  }
  
  // Rest of initialization code...
}
```

---

### Issue 2: Permission Denied on Android 13+

**Problem**: Android 13+ requires explicit runtime permission for notifications

**Solution**: Request permissions properly

**Check**: In `main.dart`, permissions are requested:
```dart
await notificationService.requestPermissions();
```

**Fix if missing**: Add permission request in AndroidManifest.xml:
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
</manifest>
```

---

### Issue 3: Timezone Not Initialized

**Problem**: `tz.initializeTimeZones()` not called before scheduling

**Current Code**: ✅ Already handled in `notification_service.dart`:
```dart
// Initialize timezone database
tz.initializeTimeZones();
```

**If Error Persists**: Add timezone location:
```dart
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

tz.initializeTimeZones();
tz.setLocalLocation(tz.getLocation('America/New_York')); // Or your timezone
```

---

### Issue 4: Notifications Not Persisting After App Restart

**Problem**: Scheduled notifications are lost when app closes

**Solution**: This is expected behavior. Notifications need to be rescheduled on app start.

**Fix**: Add to `main.dart` after initialization:
```dart
// Reschedule notifications on app start
final reminderSettings = await ref.read(reminderSettingsRepositoryProvider).getSettings();
if (reminderSettings != null) {
  if (reminderSettings.workoutReminderEnabled) {
    await notificationService.scheduleWorkoutReminder(
      reminderSettings.workoutReminderTime,
      enabled: true,
    );
  }
  // Same for meal and streak reminders...
}
```

---

### Issue 5: Icon Not Found (@mipmap/ic_launcher)

**Problem**: Notification icon not found on Android

**Solution**: Use default icon or add custom icon

**Fix Option 1** - Use default:
```dart
const AndroidNotificationDetails(
  'channel_id',
  'Channel Name',
  // Remove icon parameter to use default
)
```

**Fix Option 2** - Add custom icon:
1. Create icon: `android/app/src/main/res/drawable/notification_icon.png`
2. Update code:
```dart
icon: 'notification_icon',  // Without @mipmap/ prefix
```

---

### Issue 6: Exact Alarms Not Working on Android 12+

**Problem**: `AndroidScheduleMode.exactAllowWhileIdle` requires permission

**Solution**: Add permission to AndroidManifest.xml:
```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```

---

### Issue 7: Notifications Not Showing in Foreground (iOS)

**Problem**: iOS doesn't show notifications when app is in foreground by default

**Solution**: Already handled with:
```dart
iOS: DarwinNotificationDetails(
  presentAlert: true,  // ✅ Show in foreground
  presentBadge: true,
  presentSound: true,
),
```

---

### Issue 8: Duplicate Notifications

**Problem**: Multiple notifications with same ID

**Solution**: Use unique IDs for each notification type

**Current Implementation**: ✅ Already using unique IDs:
```dart
static const int workoutReminderId = 1;
static const int breakfastReminderId = 2;
static const int lunchReminderId = 3;
static const int dinnerReminderId = 4;
static const int streakReminderId = 5;
```

---

## Platform-Specific Fixes

### Android Fixes

#### 1. Update AndroidManifest.xml

**File**: `android/app/src/main/AndroidManifest.xml`

Add these permissions:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Notification permissions -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    
    <application>
        <!-- Existing application config -->
    </application>
</manifest>
```

#### 2. Add Notification Icon

Create a simple notification icon:
1. Go to: https://romannurik.github.io/AndroidAssetStudio/icons-notification.html
2. Create a white icon on transparent background
3. Download and place in: `android/app/src/main/res/drawable/`

---

### iOS Fixes

#### 1. Update Info.plist

**File**: `ios/Runner/Info.plist`

Add notification permissions:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

### Web Fixes

#### 1. Disable Notifications on Web

**File**: `lib/features/notifications/domain/services/notification_service.dart`

Add platform check at the beginning of each method:
```dart
import 'package:flutter/foundation.dart';

Future<void> initialize({required Function(String?) onNotificationTap}) async {
  if (kIsWeb) {
    print('⚠️ [Notifications] Not supported on Web platform');
    _initialized = true;
    return;
  }
  
  // Rest of code...
}

Future<void> scheduleWorkoutReminder(TimeOfDayModel time, {bool enabled = true}) async {
  if (kIsWeb) {
    print('⚠️ [Notifications] Not supported on Web platform');
    return;
  }
  
  // Rest of code...
}
```

---

## Testing Checklist

### Test on Android:

- [ ] Run app on Android device/emulator
- [ ] Go to Settings → Reminder Settings
- [ ] Enable workout reminder
- [ ] Set time to 1 minute from now
- [ ] Wait for notification
- [ ] Check if notification appears
- [ ] Tap notification
- [ ] Verify app opens to correct screen

### Test on iOS:

- [ ] Run app on iOS device/simulator
- [ ] Go to Settings → Reminder Settings
- [ ] Enable workout reminder
- [ ] Set time to 1 minute from now
- [ ] Wait for notification
- [ ] Check if notification appears
- [ ] Tap notification
- [ ] Verify app opens to correct screen

### Test on Web:

- [ ] Run app on Chrome
- [ ] Go to Settings → Reminder Settings
- [ ] Verify notification settings are disabled or show warning
- [ ] No errors in console

---

## Debug Commands

### Check Scheduled Notifications (Android):

```bash
adb shell dumpsys notification
```

### Check App Permissions (Android):

```bash
adb shell dumpsys package com.progressiontracker.progression_tracker | grep permission
```

### View Logs:

```bash
flutter logs
```

---

## Quick Fix Implementation

Let me create an updated notification service with all fixes:

**File**: `lib/features/notifications/domain/services/notification_service.dart`

Key changes:
1. ✅ Add platform check for Web
2. ✅ Better error handling
3. ✅ Fallback for missing icons
4. ✅ Debug logging

---

## Common Error Messages & Solutions

### Error: "PlatformException(PERMISSION_DENIED)"

**Solution**: Request permissions in AndroidManifest.xml and at runtime

### Error: "MissingPluginException"

**Solution**: Run `flutter clean && flutter pub get`

### Error: "Invalid notification icon"

**Solution**: Remove icon parameter or add valid icon resource

### Error: "Timezone not initialized"

**Solution**: Call `tz.initializeTimeZones()` before scheduling

### Error: "Exact alarm permission denied"

**Solution**: Add `SCHEDULE_EXACT_ALARM` permission to AndroidManifest.xml

---

## Recommended Implementation

### Step 1: Update notification_service.dart

Add platform checks and better error handling.

### Step 2: Update AndroidManifest.xml

Add all required permissions.

### Step 3: Test on Real Device

Emulators may not show notifications correctly.

### Step 4: Add Debug Logging

Add print statements to track notification scheduling.

---

## Need Help?

**What specific issue are you experiencing?**

1. Notifications not showing at all?
2. Notifications showing but not at scheduled time?
3. Notifications not working on specific platform?
4. Permission errors?
5. App crashing when scheduling notifications?
6. Other issue?

**Please provide**:
- Platform (Android/iOS/Web)
- Error message (if any)
- When the issue occurs
- What you've tried

---

**Created**: 2026-05-17  
**App**: IronFlow  
**Status**: Diagnostic Guide Ready
