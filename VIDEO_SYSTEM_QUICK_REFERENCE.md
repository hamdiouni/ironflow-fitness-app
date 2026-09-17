# 🎬 Video System Quick Reference Guide

## 🚀 Quick Start

### Display a Video
```dart
ExerciseVideoPlayer(
  exerciseName: 'bench press',
)
```

That's it! The system handles everything else automatically.

## 📋 Common Use Cases

### 1. Basic Video Display
```dart
ExerciseVideoPlayer(
  exerciseName: 'squat',
  height: 200,
)
```

### 2. With Error Handling
```dart
ExerciseVideoPlayer(
  exerciseName: 'deadlift',
  onError: (error) {
    print('Video error: $error');
  },
)
```

### 3. Custom Configuration
```dart
YouTubeExercisePlayer(
  exerciseName: 'overhead press',
  height: 250,
  autoPlay: false,
  muted: true,
  onReady: () => print('Ready!'),
  onError: (error) => print('Error: $error'),
)
```

## 🔍 Check if Video Exists

```dart
final videoId = ExerciseVideoMap.getVideoId('bench press');
if (videoId != null) {
  // Video exists
} else {
  // No video mapped
}
```

## 🖼️ Get Thumbnail URL

```dart
final thumbnailUrl = ExerciseVideoMap.thumbnailUrl('bench press');
// Returns: https://img.youtube.com/vi/rT7DgCr-3pg/mqdefault.jpg
```

## ➕ Add New Exercise Video

1. Find YouTube video
2. Extract video ID from URL
3. Add to map:

```dart
// In lib/features/workout/data/exercise_video_map.dart
static const Map<String, String> _videoIds = {
  'new exercise': 'YouTube_Video_ID',
};
```

## 🎯 Video States

### Loading
- Shows circular progress indicator
- Displays "Loading video..." text

### Playing
- YouTube player with controls
- Mute/unmute button overlay

### Error/No Video
- Shows thumbnail image
- "Video not available" message
- Retry button

## 🔧 Troubleshooting

### Video Not Loading?
1. Check exercise name spelling
2. Verify video ID in ExerciseVideoMap
3. Check internet connection
4. Try retry button

### Video ID Not Found?
```dart
// Check all available exercises
final exercises = ExerciseVideoMap.getAllExerciseNames();
print(exercises);
```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Desktop (Windows, macOS, Linux)

## 🎨 Customization

### Change Height
```dart
ExerciseVideoPlayer(
  exerciseName: 'bench press',
  height: 300,  // Default: 200
)
```

### Auto-play
```dart
YouTubeExercisePlayer(
  exerciseName: 'squat',
  autoPlay: true,  // Default: false
)
```

### Start Unmuted
```dart
YouTubeExercisePlayer(
  exerciseName: 'deadlift',
  muted: false,  // Default: true
)
```

## 🚨 Important Rules

### DO:
- ✅ Use exercise names (not URLs)
- ✅ Handle errors gracefully
- ✅ Test with different exercises

### DON'T:
- ❌ Use video URLs directly
- ❌ Forget error handling
- ❌ Preload all videos

## 📊 Available Exercises

50+ exercises mapped including:
- bench press
- squat
- deadlift
- overhead press
- barbell row
- pull-up
- dip
- and many more...

See `ExerciseVideoMap._videoIds` for complete list.

## 🔗 Related Files

- `lib/shared/widgets/youtube_exercise_player.dart` - Core player
- `lib/shared/widgets/exercise_video_player.dart` - Simple wrapper
- `lib/features/workout/data/exercise_video_map.dart` - Video mappings

## 📚 Full Documentation

See `VIDEO_SYSTEM_ARCHITECTURE.md` for complete documentation.

---

**Quick Tip**: Just use `ExerciseVideoPlayer(exerciseName: 'exercise name')` and let the system handle the rest!
