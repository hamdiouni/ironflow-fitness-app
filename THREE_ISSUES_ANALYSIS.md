# Three Issues Analysis & Fixes

## Issue 1: Logout Stuck Loading ⏳

### Problem
The logout button shows a loading spinner that never closes, and the user is not redirected to the login screen.

### Root Cause
The loading dialog is shown, but the navigation to splash screen happens while the dialog is still open, causing a navigation conflict.

### Solution
Simplify the logout flow by removing the manual loading dialog and relying on the auth state change to trigger navigation automatically.

**File**: `lib/features/profile/presentation/screens/profile_screen.dart`

**Current Code** (lines 700-740):
```dart
onPressed: () async {
  Navigator.pop(context);
  
  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );
  
  try {
    // Sign out
    await ref.read(authNotifierProvider.notifier).signOut();
    
    // Close loading indicator
    if (context.mounted) {
      Navigator.pop(context);
    }
    
    // Navigate to splash which will redirect to login
    if (context.mounted) {
      context.go(AppRoutes.splash);
    }
  } catch (e) {
    // Close loading indicator
    if (context.mounted) {
      Navigator.pop(context);
    }
    
    // Show error
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
},
```

**Fixed Code**:
```dart
onPressed: () async {
  Navigator.pop(context); // Close confirmation dialog
  
  try {
    // Sign out (this will update auth state)
    await ref.read(authNotifierProvider.notifier).signOut();
    
    // Navigate to splash which will redirect to login
    if (context.mounted) {
      context.go(AppRoutes.splash);
    }
  } catch (e) {
    // Show error
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: AppTheme.errorColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
},
```

---

## Issue 2: Notifications Not Delivered on Android 📱

### Problem
User can set reminders in the app, but notifications are not delivered at the scheduled time on Android.

### Root Causes
1. **Missing Android Permissions**: Android 13+ requires explicit notification permission
2. **Missing Alarm Permission**: Exact alarms require special permission on Android 12+
3. **Missing AndroidManifest Configuration**: Notification channels and permissions not declared

### Solution

#### Step 1: Add Permissions to AndroidManifest.xml

**File**: `android/app/src/main/AndroidManifest.xml`

Add these permissions inside the `<manifest>` tag (before `<application>`):

```xml
<!-- Notification permissions -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

Add this inside the `<application>` tag:

```xml
<!-- Boot receiver to reschedule notifications after device restart -->
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"
    android:exported="false">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>

<!-- Notification receiver -->
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"
    android:exported="false" />
```

#### Step 2: Request Exact Alarm Permission

**File**: `lib/features/notifications/domain/services/notification_service.dart`

Add this method:

```dart
/// Request exact alarm permission (Android 12+)
Future<bool> requestExactAlarmPermission() async {
  if (kIsWeb) return false;
  if (!_initialized) return false;

  try {
    // On Android 12+, we need to request exact alarm permission
    if (Platform.isAndroid) {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        // Check if exact alarms are allowed
        final canScheduleExactAlarms = await androidPlugin.canScheduleExactNotifications();
        
        if (canScheduleExactAlarms == null || !canScheduleExactAlarms) {
          // Request permission by opening settings
          await androidPlugin.requestExactAlarmsPermission();
          
          // Check again after user returns
          final granted = await androidPlugin.canScheduleExactNotifications();
          return granted ?? false;
        }
        
        return true;
      }
    }
    
    return true;
  } catch (e) {
    if (kDebugMode) {
      print('❌ [Notifications] Failed to request exact alarm permission: $e');
    }
    return false;
  }
}
```

#### Step 3: Update Reminder Settings Screen

When user enables reminders, request exact alarm permission first.

**File**: `lib/features/notifications/presentation/screens/reminder_settings_screen.dart`

Before scheduling notifications, add:

```dart
// Request exact alarm permission on Android
final hasExactAlarmPermission = await notificationService.requestExactAlarmPermission();

if (!hasExactAlarmPermission) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exact alarm permission is required for reliable notifications'),
        duration: Duration(seconds: 3),
      ),
    );
  }
  return;
}
```

#### Step 4: Add Platform Import

**File**: `lib/features/notifications/domain/services/notification_service.dart`

Add at the top:

```dart
import 'dart:io' show Platform;
```

---

## Issue 3: YouTube Videos Not Working on Android 📹

### Problem
YouTube videos play fine on Web but don't work on Android app.

### Root Causes
1. **Missing Internet Permission**: Android requires explicit internet permission
2. **WebView Configuration**: YouTube requires proper WebView setup
3. **Hybrid Composition**: Android WebView needs hybrid composition mode

### Solution

#### Step 1: Add Internet Permission

**File**: `android/app/src/main/AndroidManifest.xml`

Add this permission inside the `<manifest>` tag:

```xml
<!-- Internet permission for video playback -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

#### Step 2: Enable Hybrid Composition

**File**: `android/app/src/main/AndroidManifest.xml`

Inside the `<application>` tag, add:

```xml
<!-- Enable hybrid composition for better WebView performance -->
<meta-data
    android:name="io.flutter.embedding.android.EnableImpeller"
    android:value="true" />
```

#### Step 3: Update YouTube Player Configuration

**File**: Check your YouTube player widget (likely in workout exercise screen)

Ensure the YouTube player is configured for Android:

```dart
YoutubePlayerController(
  initialVideoId: videoId,
  flags: const YoutubePlayerFlags(
    autoPlay: false,
    mute: false,
    enableCaption: true,
    // Important for Android
    forceHD: false,
    useHybridComposition: true, // Enable hybrid composition
  ),
)
```

#### Step 4: Add ProGuard Rules (if using release build)

**File**: `android/app/proguard-rules.pro`

Create this file if it doesn't exist and add:

```proguard
# Keep YouTube player classes
-keep class com.pierfrancescosoffritti.androidyoutubeplayer.** { *; }
-dontwarn com.pierfrancescosoffritti.androidyoutubeplayer.**

# Keep WebView classes
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
}
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String);
}
```

Then update `android/app/build.gradle.kts`:

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

---

## Summary of Files to Modify

### Issue 1: Logout (1 file)
- ✏️ `lib/features/profile/presentation/screens/profile_screen.dart`

### Issue 2: Notifications (3 files)
- ✏️ `android/app/src/main/AndroidManifest.xml`
- ✏️ `lib/features/notifications/domain/services/notification_service.dart`
- ✏️ `lib/features/notifications/presentation/screens/reminder_settings_screen.dart`

### Issue 3: YouTube Videos (3-4 files)
- ✏️ `android/app/src/main/AndroidManifest.xml`
- ✏️ YouTube player widget file (find with search)
- ➕ `android/app/proguard-rules.pro` (create if needed)
- ✏️ `android/app/build.gradle.kts` (if using ProGuard)

---

## Testing Checklist

### Logout
- [ ] Click logout button
- [ ] Confirm logout in dialog
- [ ] Verify redirect to splash/login screen
- [ ] Verify no stuck loading spinner
- [ ] Try logout on both Web and Android

### Notifications
- [ ] Enable workout reminders
- [ ] Set reminder time to 2 minutes from now
- [ ] Wait for notification to appear
- [ ] Tap notification and verify app opens
- [ ] Test meal reminders
- [ ] Test streak reminders
- [ ] Verify notifications persist after app restart
- [ ] Verify notifications work after device reboot

### YouTube Videos
- [ ] Open exercise with YouTube video
- [ ] Verify video player loads
- [ ] Verify video plays when tapped
- [ ] Test on Web (should work)
- [ ] Test on Android (should work after fix)
- [ ] Test video controls (play, pause, seek)
- [ ] Test fullscreen mode

---

## Priority Order

1. **Fix Logout First** (5 minutes) - Critical UX issue
2. **Fix Notifications** (30 minutes) - Core feature not working
3. **Fix YouTube Videos** (20 minutes) - Important for workout experience

Total estimated time: ~1 hour
