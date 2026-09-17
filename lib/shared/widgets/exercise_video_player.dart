import 'package:flutter/material.dart';
import 'youtube_exercise_player.dart';

/// Exercise video player widget that displays YouTube videos for exercises.
///
/// This widget wraps the YouTubeExercisePlayer and provides a simple interface
/// for displaying exercise demonstration videos. It automatically handles:
/// - YouTube video loading
/// - Fallback to thumbnail images
/// - Error states
/// - Loading indicators
///
/// The video URLs are managed by ExerciseVideoMap which maps exercise names
/// to YouTube video IDs.
class ExerciseVideoPlayer extends StatelessWidget {
  const ExerciseVideoPlayer({
    super.key,
    required this.exerciseName,
    this.height = 200,
  });

  final String exerciseName;
  final double height;

  @override
  Widget build(BuildContext context) {
    return YouTubeExercisePlayer(
      exerciseName: exerciseName,
      height: height,
      autoPlay: false,
      muted: true,
      onError: (error) {
        debugPrint('Video player error for $exerciseName: $error');
      },
    );
  }
}
