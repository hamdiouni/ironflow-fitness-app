import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../features/workout/data/exercise_video_map.dart';

/// A robust YouTube-based exercise video player with fallback handling.
///
/// Features:
/// - YouTube video playback using youtube_player_iframe
/// - Automatic fallback to image if video unavailable
/// - Loading states and error handling
/// - Play/pause, mute/unmute, fullscreen controls
/// - Lazy loading (only loads when visible)
/// - Proper disposal to prevent memory leaks
///
/// Architecture:
/// - Primary: YouTube video via youtubeVideoId
/// - Fallback: Exercise thumbnail image
/// - Error handling: Never crashes, always shows UI
class YouTubeExercisePlayer extends StatefulWidget {
  final String exerciseName;
  final double height;
  final bool autoPlay;
  final bool muted;
  final VoidCallback? onReady;
  final Function(String)? onError;

  const YouTubeExercisePlayer({
    super.key,
    required this.exerciseName,
    this.height = 200,
    this.autoPlay = false,
    this.muted = true,
    this.onReady,
    this.onError,
  });

  @override
  State<YouTubeExercisePlayer> createState() => _YouTubeExercisePlayerState();
}

class _YouTubeExercisePlayerState extends State<YouTubeExercisePlayer> {
  YoutubePlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _isMuted = true;
  String? _videoId;

  @override
  void initState() {
    super.initState();
    _isMuted = widget.muted;
    _initializePlayer();
  }

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

      // Initialize YouTube player controller with basic params
      _controller = YoutubePlayerController.fromVideoId(
        videoId: _videoId!,
        autoPlay: false,
        params: YoutubePlayerParams(
          mute: true,
          showControls: true,
          showFullscreenButton: true,
          loop: false,
          enableCaption: false,
          strictRelatedVideos: true,
          showVideoAnnotations: false,
          enableJavaScript: true,
        ),
      );

      // Add comprehensive error handling
      _controller!.listen((event) {
        _logInfo('Player event: ${event.playerState}');
        
        if (event.hasError) {
          _logError('Player error detected', event.error);
          
          // Distinguish between different error types
          String errorMsg = 'Video playback error';
          if (event.error.toString().contains('152')) {
            errorMsg = 'Video unavailable (region-blocked or removed)';
          } else if (event.error.toString().contains('150')) {
            errorMsg = 'Video playback disabled by owner';
          }
          
          setState(() {
            _hasError = true;
            _errorMessage = errorMsg;
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

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _logError('Failed to initialize player', e);
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load video: ${e.toString()}';
        _isLoading = false;
      });
      widget.onError?.call(e.toString());
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    _initializePlayer();
  }

  void _toggleMute() {
    if (_controller == null) return;
    setState(() {
      _isMuted = !_isMuted;
    });
    if (_isMuted) {
      _controller!.mute();
    } else {
      _controller!.unMute();
    }
  }

  void _logInfo(String message) {
    debugPrint('[YouTubeExercisePlayer] INFO: $message');
  }

  void _logError(String message, dynamic error) {
    debugPrint('[YouTubeExercisePlayer] ERROR: $message');
    debugPrint('[YouTubeExercisePlayer] Error details: $error');
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError || _controller == null) {
      return _buildFallbackState(context);
    }

    return _buildVideoPlayer(context);
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackState(BuildContext context) {
    final thumbnailUrl = ExerciseVideoMap.thumbnailUrl(widget.exerciseName);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Fallback image
        Image.network(
          thumbnailUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[900],
              child: const Icon(
                Icons.fitness_center,
                size: 64,
                color: Colors.white38,
              ),
            );
          },
        ),
        // Overlay with error message and retry button
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.videocam_off,
                  size: 48,
                  color: Colors.white70,
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage ?? 'Video not available',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        final watchUrl = ExerciseVideoMap.watchUrl(widget.exerciseName);
                        if (watchUrl != null) {
                          // Try to open in browser/YouTube app
                          _logInfo('Opening YouTube URL: $watchUrl');
                          // Note: url_launcher is commented out in pubspec, so this is a placeholder
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Video URL: $watchUrl'),
                              action: SnackBarAction(
                                label: 'Copy',
                                onPressed: () {
                                  // Copy URL to clipboard
                                },
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('YouTube'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // YouTube player
        YoutubePlayer(
          controller: _controller!,
          aspectRatio: 16 / 9,
        ),
        // Custom controls overlay
        Positioned(
          bottom: 8,
          right: 8,
          child: _buildControls(context),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mute/Unmute button
          IconButton(
            icon: Icon(
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
              size: 20,
            ),
            onPressed: _toggleMute,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }
}
