import 'package:flutter/material.dart';
import '../../../../shared/widgets/youtube_exercise_player.dart';
import '../../data/exercise_video_map.dart';

/// A video player widget for displaying exercise demonstration videos.
///
/// Features:
/// - YouTube video playback with youtube_player_iframe
/// - Automatic fallback to thumbnail images
/// - Loading indicator while buffering
/// - Play/pause, mute/unmute controls
/// - Fullscreen support
/// - Error handling with retry functionality
/// - Lazy loading (only loads when visible)
/// - Proper disposal to prevent memory leaks
///
/// This widget uses the new YouTube-based architecture that ensures
/// every exercise always has a working video source or fallback.
///
/// Validates: Requirements 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 14.1, 14.2, 14.3, 14.5, 14.6, 20.1, 20.2, 20.3, 20.4
class ExerciseVideoPlayer extends StatelessWidget {
  /// The URL of the video to play (deprecated - now uses exercise name)
  final String? videoUrl;

  /// The exercise name to look up the video
  final String? exerciseName;

  /// Callback when video is ready to play
  final VoidCallback? onReady;

  /// Callback when an error occurs
  final Function(String)? onError;

  /// Height of the video player
  final double height;

  /// Fallback image asset (deprecated - now uses YouTube thumbnails)
  final String? fallbackImageAsset;

  const ExerciseVideoPlayer({
    super.key,
    this.videoUrl,
    this.exerciseName,
    this.onReady,
    this.onError,
    this.height = 200,
    this.fallbackImageAsset,
  });

  @override
  Widget build(BuildContext context) {
    // Extract exercise name from videoUrl if exerciseName not provided
    String? name = exerciseName;
    
    if (name == null && videoUrl != null) {
      // Try to extract exercise name from URL or use a default
      // This is for backward compatibility
      name = _extractExerciseNameFromUrl(videoUrl!);
    }

    if (name == null) {
      return _buildErrorPlaceholder(context);
    }

    return YouTubeExercisePlayer(
      exerciseName: name,
      height: height,
      autoPlay: false,
      muted: true,
      onReady: onReady,
      onError: onError,
    );
  }

  String? _extractExerciseNameFromUrl(String url) {
    // Try to find a matching exercise name from the video map
    // This is a fallback for backward compatibility
    final allExercises = ExerciseVideoMap.getAllExerciseNames();
    
    for (final exercise in allExercises) {
      final videoId = ExerciseVideoMap.getVideoId(exercise);
      if (videoId != null && url.contains(videoId)) {
        return exercise;
      }
    }
    
    return null;
  }

  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 48,
              color: Colors.white38,
            ),
            SizedBox(height: 12),
            Text(
              'Video not available',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
