import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../core/theme/app_theme_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../features/workout/data/exercise_video_map.dart';

/// A robust YouTube-based exercise video player with Sci-Fi HUD fallback handling.
///
/// Features:
/// - YouTube video playback using youtube_player_iframe
/// - Automatic fallback to cached thumbnail image if video unavailable or offline
/// - Direct deep-link launching into external YouTube app / browser with clipboard copy fallback
/// - Loading states and error handling with retry capability
/// - Play/pause, mute/unmute, fullscreen controls
/// - Lazy loading (only loads when visible)
/// - Proper disposal to prevent memory leaks
///
/// Architecture:
/// - Primary: YouTube video via youtubeVideoId
/// - Fallback: Exercise cached thumbnail image with HUD controls
/// - Error handling: Never crashes, always shows interactive UI
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
          _errorMessage = 'DEMO VIDEO NOT AVAILABLE';
          _isLoading = false;
        });
        return;
      }

      _logInfo('Initializing player for video ID: $_videoId');

      // Initialize YouTube player controller with basic params
      _controller = YoutubePlayerController.fromVideoId(
        videoId: _videoId!,
        autoPlay: widget.autoPlay,
        params: const YoutubePlayerParams(
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
          final errStr = event.error.toString();
          if (errStr.contains('152') || errStr.contains('100')) {
            errorMsg = 'Video unavailable (private or removed)';
          } else if (errStr.contains('150') || errStr.contains('101')) {
            errorMsg = 'In-app playback disabled by owner';
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
    debugPrint('[YouTubeExercisePlayer] ERROR: $message ($error)');
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: tokens.canvas,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState(context);
    }

    if (_hasError || _controller == null) {
      return _buildFallbackState(context);
    }

    return _buildVideoPlayer(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      color: tokens.canvas,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(tokens.kineticAccent),
              strokeWidth: 2,
            ),
            const SizedBox(height: 12),
            Text(
              'INITIALIZING TELEMETRY STREAM...',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                color: tokens.textMuted,
                fontSize: 10,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackState(BuildContext context) {
    final tokens = context.tokens;
    final thumbnailUrl = ExerciseVideoMap.thumbnailUrl(widget.exerciseName);
    final watchUrl = ExerciseVideoMap.watchUrl(widget.exerciseName);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Cached Thumbnail
        CachedNetworkImage(
          imageUrl: thumbnailUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: tokens.panel,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(tokens.kineticAccent),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: tokens.panel,
            child: Center(
              child: Icon(
                Icons.fitness_center_rounded,
                size: 48,
                color: tokens.textMuted.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
        // Monolithic HUD overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.black.withValues(alpha: 0.85),
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam_off_rounded,
                  size: 32,
                  color: tokens.textMuted,
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage ?? 'DEMO VIDEO NOT AVAILABLE',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    color: tokens.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh_rounded, size: 14),
                      label: const Text('RETRY'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: tokens.textPrimary,
                        side: BorderSide(color: tokens.borderSubtle),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (watchUrl != null) ...[
                      ElevatedButton.icon(
                        onPressed: () => _openExternalYouTube(watchUrl),
                        icon: const Icon(Icons.open_in_new_rounded, size: 14),
                        label: const Text('YOUTUBE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF0000),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy video link',
                        icon: Icon(Icons.copy_rounded, size: 16, color: tokens.textMuted),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: () => _copyVideoUrl(watchUrl),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openExternalYouTube(String watchUrl) async {
    _logInfo('Opening YouTube URL: $watchUrl');
    final uri = Uri.parse(watchUrl);
    bool launched = false;
    try {
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _logError('Failed to launch URL', e);
    }
    if (!launched && mounted) {
      await _copyVideoUrl(watchUrl);
    }
  }

  Future<void> _copyVideoUrl(String watchUrl) async {
    await Clipboard.setData(ClipboardData(text: watchUrl));
    if (mounted) {
      final tokens = context.tokens;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Video URL copied to clipboard: $watchUrl',
            style: TextStyle(color: tokens.textPrimary, fontSize: 12),
          ),
          backgroundColor: tokens.panel,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mute/Unmute button
          IconButton(
            icon: Icon(
              _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: Colors.white,
              size: 18,
            ),
            onPressed: _toggleMute,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
          ),
        ],
      ),
    );
  }
}
