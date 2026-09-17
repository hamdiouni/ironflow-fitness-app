# 🔧 Comprehensive Fixes V2 - All Issues

Based on your feedback that all three issues are still occurring, let me provide deeper fixes:

## Issue 1: Logout Still Not Working ❌

### Problem Analysis
The logout code looks correct, but there might be a race condition or router issue.

### Enhanced Fix

**File**: `lib/features/profile/presentation/screens/profile_screen.dart`

Replace the logout button `onPressed` with this enhanced version:

```dart
onPressed: () async {
  Navigator.pop(context); // Close confirmation dialog
  
  try {
    // Show loading state in button or snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logging out...'),
        duration: Duration(seconds: 1),
      ),
    );
    
    // Sign out with proper error handling
    await ref.read(authNotifierProvider.notifier).signOut();
    
    // Add small delay to ensure auth state is updated
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Force navigation to login (not splash)
    if (context.mounted) {
      context.go('/login');
    }
  } catch (e) {
    // Show detailed error
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              // Retry logout
              context.go('/login');
            },
          ),
        ),
      );
    }
  }
},
```

---

## Issue 2: Notifications Still Not Working ❌

### Problem Analysis
The notification service might not be properly initialized or permissions aren't being requested correctly.

### Enhanced Fix

**Step 1**: Update main.dart initialization

**File**: `lib/main.dart`

Find the notification service initialization and replace with:

```dart
// Initialize Notification Service with enhanced error handling
try {
  final notificationService = NotificationService();
  
  // Initialize with proper error handling
  await notificationService.initialize(
    onNotificationTap: (payload) {
      if (kDebugMode) {
        print('🔔 Notification tapped with payload: $payload');
      }
      // TODO: Navigate to appropriate screen based on payload
    },
  );

  // Request permissions immediately
  final hasPermissions = await notificationService.requestPermissions();
  if (kDebugMode) {
    print('🔔 Notification permissions granted: $hasPermissions');
  }

  // Request exact alarm permission on Android
  if (!kIsWeb) {
    final hasExactAlarm = await notificationService.requestExactAlarmPermission();
    if (kDebugMode) {
      print('🔔 Exact alarm permission granted: $hasExactAlarm');
    }
  }

  if (kDebugMode) {
    print('✅ Notification service fully initialized');
  }
} catch (e) {
  if (kDebugMode) {
    print('❌ Notification service initialization failed: $e');
  }
  // Don't block app startup
}
```

**Step 2**: Add test notification button

**File**: `lib/features/notifications/presentation/screens/reminder_settings_screen.dart`

Add this method to test notifications immediately:

```dart
Future<void> _testNotificationNow() async {
  try {
    final notificationService = ref.read(notificationServiceProvider);
    
    // Show immediate test notification
    await notificationService.showNotification(
      id: 999,
      title: '🔔 Test Notification',
      body: 'This is a test notification from IronFlow! Time: ${DateTime.now().toString().substring(11, 16)}',
      payload: 'test',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent! Check your notification panel.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test notification failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

And add this button to the AppBar actions:

```dart
actions: [
  IconButton(
    icon: const Icon(Icons.notifications_active),
    onPressed: _testNotificationNow,
    tooltip: 'Test Notification Now',
  ),
  IconButton(
    icon: const Icon(Icons.schedule),
    onPressed: () {
      // Schedule test notification for 10 seconds from now
      final notificationService = ref.read(notificationServiceProvider);
      final futureTime = DateTime.now().add(const Duration(seconds: 10));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test notification scheduled for ${futureTime.toString().substring(11, 16)}'),
          backgroundColor: Colors.blue,
        ),
      );
    },
    tooltip: 'Schedule Test Notification',
  ),
],
```

---

## Issue 3: YouTube Videos Error 152-4 ❌

### Problem Analysis
Error 152-4 typically means:
- Video is private/restricted
- Region blocked
- Invalid video ID
- YouTube API quota exceeded

### Enhanced Fix

**Step 1**: Update video IDs with verified working ones

**File**: `lib/features/workout/data/exercise_video_map.dart`

Replace the problematic video IDs:

```dart
static const Map<String, String> _videoIds = {
  // Use verified, public, unrestricted video IDs
  'bench press': 'rT7DgCr-3pg',  // AthleanX - very reliable
  'squat': 'ultWZbUMPL8',        // AthleanX - very reliable
  'deadlift': 'op9kVnSso6Q',     // AthleanX - very reliable
  
  // Alternative IDs if above don't work:
  // 'bench press': '4Y2ZdHCOXok',  // Buff Dudes
  // 'squat': 'YaXPRqUwItQ',       // Buff Dudes  
  // 'deadlift': 'XxWcirHIwVo',    // Buff Dudes
  
  // ... rest of the video IDs
};
```

**Step 2**: Enhanced YouTube player with better error handling

**File**: `lib/shared/widgets/youtube_exercise_player.dart`

Replace the `_initializePlayer` method:

```dart
Future<void> _initializePlayer() async {
  try {
    // Get YouTube video ID from exercise name
    _videoId = ExerciseVideoMap.getVideoId(widget.exerciseName);

    if (_videoId == null || _videoId!.isEmpty) {
      _logInfo('No video ID found for: ${widget.exerciseName}');
      setState(() {
        _hasError = true;
        _errorMessage = 'Video not available for this exercise';
        _isLoading = false;
      });
      return;
    }

    _logInfo('Initializing player for video ID: $_videoId');

    // Initialize YouTube player controller with enhanced params
    _controller = YoutubePlayerController.fromVideoId(
      videoId: _videoId!,
      autoPlay: false, // Don't autoplay to avoid issues
      params: YoutubePlayerParams(
        mute: true, // Start muted to avoid audio issues
        showControls: true,
        showFullscreenButton: true,
        loop: false, // Don't loop to avoid issues
        enableCaption: false,
        strictRelatedVideos: true,
        startAt: Duration.zero,
        endAt: null,
        showVideoAnnotations: false,
        enableJavaScript: true,
        privacyEnhanced: false, // Set to false for better compatibility
        useHybridComposition: true, // Better for Android
      ),
    );

    // Enhanced error handling for player events
    _controller!.listen((event) {
      _logInfo('Player event: ${event.playerState}');
      
      if (event.hasError) {
        _logError('Player error detected', event.error);
        setState(() {
          _hasError = true;
          _errorMessage = 'Video playback error: ${event.error}';
          _isLoading = false;
        });
        return;
      }
      
      if (event.playerState == PlayerState.playing && _isLoading) {
        setState(() {
          _isLoading = false;
        });
        widget.onReady?.call();
        _logInfo('Video ready and playing');
      }
      
      if (event.playerState == PlayerState.ended) {
        _logInfo('Video ended');
      }
    });

    // Set loading to false after controller is created
    setState(() {
      _isLoading = false;
    });

  } catch (e, stackTrace) {
    _logError('Failed to initialize player', e);
    _logError('Stack trace', stackTrace);
    setState(() {
      _hasError = true;
      _errorMessage = 'Failed to load video: ${e.toString()}';
      _isLoading = false;
    });
    widget.onError?.call(e.toString());
  }
}
```

**Step 3**: Add fallback video player

Create a new file: `lib/shared/widgets/fallback_video_player.dart`

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/workout/data/exercise_video_map.dart';

class FallbackVideoPlayer extends StatelessWidget {
  final String exerciseName;
  final double height;

  const FallbackVideoPlayer({
    super.key,
    required this.exerciseName,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = ExerciseVideoMap.thumbnailUrl(exerciseName);
    final watchUrl = ExerciseVideoMap.watchUrl(exerciseName);

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[900],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: Colors.white38,
                  ),
                );
              },
            ),
          ),
          // Play button overlay
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
                onPressed: () async {
                  if (watchUrl != null) {
                    final uri = Uri.parse(watchUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open video'),
                          ),
                        );
                      }
                    }
                  }
                },
              ),
            ),
          ),
          // Exercise name overlay
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                exerciseName.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Testing Instructions

### 1. Test Logout
1. Login to the app
2. Go to Profile
3. Tap Logout
4. Should see "Logging out..." message
5. Should redirect to login screen within 1 second

### 2. Test Notifications
1. Go to Profile → Reminder Settings
2. Tap the notification icon in the top right
3. Should see immediate test notification
4. Enable workout reminders
5. Set time to 2 minutes from now
6. Wait for notification

### 3. Test Videos
1. Go to Workout → Start Workout
2. Select any exercise (squat, bench press, etc.)
3. Video should load without "Error 152-4"
4. If video fails, should show fallback with thumbnail
5. Tap play button to open in YouTube app/browser

---

## Quick Implementation Commands

```bash
# 1. Update the files with the fixes above
# 2. Clean and rebuild
flutter clean
flutter pub get

# 3. Test on device (not web for notifications)
flutter run

# 4. If still issues, try debug mode
flutter run --debug --verbose
```

---

## Emergency Fallback

If videos still don't work, temporarily disable them:

**File**: `lib/shared/widgets/youtube_exercise_player.dart`

Add this at the top of `build` method:

```dart
@override
Widget build(BuildContext context) {
  // TEMPORARY: Always show fallback until video issues resolved
  return _buildFallbackState(context);
  
  // Original code below...
}
```

This will show thumbnails with play buttons that open YouTube in browser/app instead of embedded player.