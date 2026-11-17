import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

import '../../core/constants/app_theme.dart';
import '../../features/workout/data/exercise_video_map.dart';
import '../../features/workout/domain/services/exercise_catalog.dart';
import 'youtube_exercise_player.dart';

/// Supported media modes inside [ExerciseMediaStage] (Wave 5.3).
enum ExerciseMediaMode {
  /// Seamless 4-6s anatomical/form loop when an owner-supplied loop asset/URL exists.
  form3d('3D FORM'),

  /// Primary curated, oEmbed-verified YouTube coaching video.
  coach1('COACH 1'),

  /// Secondary curated, oEmbed-verified YouTube coaching angle/failover.
  coach2('COACH 2'),

  /// Step-by-step execution instructions from the canonical catalog (always available).
  steps('STEPS');

  const ExerciseMediaMode(this.label);
  final String label;
}

/// Specification and naming contract for owner-supplied "3D Form" loops (Wave 5.3).
///
/// Naming convention:
/// - Loop video: `assets/media/loops/<exercise_id>_loop.mp4` (or `.webm`)
/// - Poster frame: `assets/media/posters/<exercise_id>_poster.webp`
/// - Manifest: `assets/data/exercise_media_manifest.json`
class ExerciseMediaLoopSpec {
  const ExerciseMediaLoopSpec({
    required this.exerciseId,
    required this.loopUri,
    this.posterUri,
  });

  final String exerciseId;
  final String loopUri;
  final String? posterUri;

  static String canonicalLoopFileName(String exerciseId, {bool webm = false}) =>
      '${exerciseId.toLowerCase().trim()}_loop.${webm ? "webm" : "mp4"}';

  static String canonicalPosterFileName(String exerciseId) =>
      '${exerciseId.toLowerCase().trim()}_poster.webp';
}

/// Unified exercise media stage replacing the duplicate `ExerciseVideoPlayer`
/// widgets across [ExerciseDetailScreen] and [ActiveExerciseCard] (Wave 5.3).
///
/// Features:
/// - Modes: `"3D Form"` (only when an owner-supplied loop exists), `"Coach 1"`,
///   `"Coach 2"` (when a second verified YouTube ID exists), and `"Steps"`.
/// - Tap-to-load YouTube iframes (`loadOnTap: true` by default) so mounting an
///   exercise card or detail screen never eagerly spawns background WebViews.
/// - Automatic disposal of controllers and subscriptions when switching tabs or
///   unmounting.
/// - Automatic fallback to canonical step-by-step instructions when no video or
///   loop is mapped for an exercise.
class ExerciseMediaStage extends StatefulWidget {
  const ExerciseMediaStage({
    super.key,
    required this.exerciseName,
    this.height = 220,
    this.muted = true,
    this.loadOnTap = true,
    this.formLoopUrlOverride,
    this.primaryVideoIdOverride,
    this.secondaryVideoIdOverride,
    this.instructionsOverride,
    this.onReady,
    this.onError,
  });

  final String exerciseName;
  final double height;
  final bool muted;
  final bool loadOnTap;
  final String? formLoopUrlOverride;
  final String? primaryVideoIdOverride;
  final String? secondaryVideoIdOverride;
  final List<String>? instructionsOverride;
  final VoidCallback? onReady;
  final void Function(String)? onError;

  @override
  State<ExerciseMediaStage> createState() => _ExerciseMediaStageState();
}

class _ExerciseMediaStageState extends State<ExerciseMediaStage> {
  late List<ExerciseMediaMode> _availableModes;
  late ExerciseMediaMode _activeMode;
  String? _primaryVideoId;
  String? _secondaryVideoId;
  String? _formLoopUrl;
  List<String> _instructions = const [];

  @override
  void initState() {
    super.initState();
    _resolveMediaConfig();
  }

  @override
  void didUpdateWidget(covariant ExerciseMediaStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.exerciseName != widget.exerciseName ||
        oldWidget.formLoopUrlOverride != widget.formLoopUrlOverride ||
        oldWidget.primaryVideoIdOverride != widget.primaryVideoIdOverride ||
        oldWidget.secondaryVideoIdOverride != widget.secondaryVideoIdOverride ||
        oldWidget.instructionsOverride != widget.instructionsOverride) {
      setState(_resolveMediaConfig);
    }
  }

  void _resolveMediaConfig() {
    _formLoopUrl = widget.formLoopUrlOverride ??
        ExerciseVideoMap.getFormLoopUrl(widget.exerciseName);
    _primaryVideoId = widget.primaryVideoIdOverride ??
        ExerciseVideoMap.getVideoId(widget.exerciseName);
    _secondaryVideoId = widget.secondaryVideoIdOverride ??
        ExerciseVideoMap.getSecondaryVideoId(widget.exerciseName);

    final def = ExerciseCatalog.getByName(widget.exerciseName);
    final parsedFromCatalog = def == null
        ? const <String>[]
        : def.instructions
            .split(RegExp(r'\.\s+|\n+'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .map((s) => s.endsWith('.') ? s : '$s.')
            .toList();
    _instructions = widget.instructionsOverride ??
        (parsedFromCatalog.isNotEmpty
            ? parsedFromCatalog
            : const [
                'Set a stable stance and brace your core before initiating the movement.',
                'Control the eccentric phase and drive smoothly through the target muscle.',
              ]);

    _availableModes = <ExerciseMediaMode>[
      if (_formLoopUrl != null && _formLoopUrl!.isNotEmpty)
        ExerciseMediaMode.form3d,
      if (_primaryVideoId != null && _primaryVideoId!.isNotEmpty)
        ExerciseMediaMode.coach1,
      if (_secondaryVideoId != null &&
          _secondaryVideoId!.isNotEmpty &&
          _secondaryVideoId != _primaryVideoId)
        ExerciseMediaMode.coach2,
      ExerciseMediaMode.steps,
    ];

    // Default to 3D Form if supplied, else Coach 1 if mapped, else Steps fallback
    _activeMode = _availableModes.first;
  }

  void _selectMode(ExerciseMediaMode mode) {
    if (_activeMode == mode) return;
    setState(() {
      _activeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        color: tokens.panel,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: tokens.borderSubtle, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mode switcher header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.ondemand_video_rounded,
                  size: 15,
                  color: tokens.kineticAccent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'FORM & COACHING',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                      color: tokens.textSecondary,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 4,
                  children: _availableModes.map((mode) {
                    final selected = mode == _activeMode;
                    return Semantics(
                      button: true,
                      selected: selected,
                      label: mode.label,
                      child: InkWell(
                        key: Key('media_stage_mode_${mode.name}'),
                        borderRadius: BorderRadius.circular(tokens.radiusSm),
                        onTap: () => _selectMode(mode),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? tokens.kineticAccent : tokens.card,
                            borderRadius: BorderRadius.circular(tokens.radiusSm),
                            border: Border.all(
                              color: selected
                                  ? tokens.kineticAccent
                                  : tokens.borderSubtle,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            mode.label,
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                              color: selected
                                  ? tokens.onAccent
                                  : tokens.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: tokens.borderSubtle),
          // Active viewport (keyed by mode so inactive controllers dispose cleanly)
          SizedBox(
            height: widget.height,
            child: KeyedSubtree(
              key: ValueKey<String>(
                '${widget.exerciseName}_${_activeMode.name}_${_primaryVideoId ?? ""}_${_secondaryVideoId ?? ""}',
              ),
              child: _buildModeViewport(context, tokens),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeViewport(BuildContext context, AppThemeTokens tokens) {
    switch (_activeMode) {
      case ExerciseMediaMode.form3d:
        return _FormLoopPlayer(
          loopUrl: _formLoopUrl!,
          tokens: tokens,
          onErrorFallbackToSteps: () {
            if (mounted) {
              setState(() => _activeMode = ExerciseMediaMode.steps);
            }
          },
        );
      case ExerciseMediaMode.coach1:
        return YouTubeExercisePlayer(
          key: ValueKey<String>('coach1_${widget.exerciseName}_$_primaryVideoId'),
          exerciseName: widget.exerciseName,
          videoIdOverride: _primaryVideoId,
          height: widget.height,
          muted: widget.muted,
          loadOnTap: widget.loadOnTap,
          onReady: widget.onReady,
          onError: widget.onError,
        );
      case ExerciseMediaMode.coach2:
        return YouTubeExercisePlayer(
          key: ValueKey<String>(
            'coach2_${widget.exerciseName}_$_secondaryVideoId',
          ),
          exerciseName: widget.exerciseName,
          videoIdOverride: _secondaryVideoId,
          height: widget.height,
          muted: widget.muted,
          loadOnTap: widget.loadOnTap,
          onReady: widget.onReady,
          onError: widget.onError,
        );
      case ExerciseMediaMode.steps:
        return _StepsFallbackView(
          exerciseName: widget.exerciseName,
          instructions: _instructions,
          hasCoachVideo: _primaryVideoId != null,
          tokens: tokens,
        );
    }
  }
}

class _StepsFallbackView extends StatelessWidget {
  const _StepsFallbackView({
    required this.exerciseName,
    required this.instructions,
    required this.hasCoachVideo,
    required this.tokens,
  });

  final String exerciseName;
  final List<String> instructions;
  final bool hasCoachVideo;
  final AppThemeTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('exercise_media_steps_view'),
      color: tokens.canvas,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_list_numbered_rounded,
                size: 15,
                color: tokens.kineticAccent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hasCoachVideo
                      ? 'EXECUTION STEPS'
                      : 'EXECUTION STEPS (NO VIDEO MAPPED)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: tokens.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: instructions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tokens.card,
                        borderRadius: BorderRadius.circular(tokens.radiusSm),
                        border: Border.all(
                          color: tokens.kineticAccent.withValues(alpha: 0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: tokens.kineticAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        instructions[index],
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 12,
                          height: 1.35,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FormLoopPlayer extends StatefulWidget {
  const _FormLoopPlayer({
    required this.loopUrl,
    required this.tokens,
    required this.onErrorFallbackToSteps,
  });

  final String loopUrl;
  final AppThemeTokens tokens;
  final VoidCallback onErrorFallbackToSteps;

  @override
  State<_FormLoopPlayer> createState() => _FormLoopPlayerState();
}

class _FormLoopPlayerState extends State<_FormLoopPlayer> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initLoop();
  }

  Future<void> _initLoop() async {
    try {
      final url = widget.loopUrl;
      VideoPlayerController controller;
      if (url.startsWith('http://') || url.startsWith('https://')) {
        final file = await DefaultCacheManager().getSingleFile(url);
        if (!mounted) return;
        controller = VideoPlayerController.file(file);
      } else {
        controller = VideoPlayerController.asset(url);
      }
      _controller = controller;
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0.0);
      await controller.play();
      if (mounted) {
        setState(() => _initialized = true);
      }
    } catch (_) {
      if (mounted) {
        widget.onErrorFallbackToSteps();
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized || _controller == null) {
      return Container(
        color: widget.tokens.canvas,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor:
                AlwaysStoppedAnimation<Color>(widget.tokens.kineticAccent),
          ),
        ),
      );
    }
    return ColoredBox(
      color: widget.tokens.canvas,
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}
