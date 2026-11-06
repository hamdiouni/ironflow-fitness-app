import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/ai/data/services/image_generation_service.dart';
import 'package:progression_tracker/features/ai/presentation/providers/tts_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/image_generation_provider.dart';

/// Enhanced chat bubble with Stripe styling and markdown support
class AIChatBubble extends ConsumerWidget {
  final String role;
  final String content;
  final DateTime timestamp;
  final bool isFirst;

  const AIChatBubble({
    super.key,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final isUser = role == 'user';
    final ttsState = ref.watch(ttsProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 580),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? tokens.card : tokens.panel,
                borderRadius: BorderRadius.circular(tokens.radiusLg),
                border: Border.all(
                  color: isUser
                      ? tokens.kineticAccent.withValues(alpha: 0.3)
                      : tokens.borderSubtle,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role Tag
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isUser ? tokens.textMuted : tokens.kineticAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isUser ? 'You' : 'Coach',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: isUser
                              ? tokens.textMuted
                              : tokens.kineticAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Message Content
                  isUser
                      ? Text(
                          content,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 14,
                            color: tokens.textPrimary,
                            height: 1.45,
                          ),
                        )
                      : _AIResponseContent(content: content),

                  const SizedBox(height: 8),

                  // Footer: timestamp & audio playback
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTimestamp(timestamp),
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 9,
                          color: tokens.textMuted,
                        ),
                      ),
                      if (!isUser)
                        _AudioControls(
                          content: content,
                          ttsState: ttsState,
                          onPlay: () => ref.read(ttsProvider.notifier).speak(content),
                          onStop: () => ref.read(ttsProvider.notifier).stop(),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'JUST NOW';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}M AGO';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}H AGO';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// AI response content with markdown and rich formatting
class _AIResponseContent extends ConsumerWidget {
  final String content;

  const _AIResponseContent({required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final theme = Theme.of(context);
    final imageState = ref.watch(imageGenerationProvider);
    
    // Extract exercise images from content
    final exercises = ExerciseImageDatabase.extractExercises(content);
    final exerciseImages = exercises
        .map((e) => ExerciseImageDatabase.getExerciseImage(e))
        .where((url) => url != null)
        .cast<String>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Markdown content
        MarkdownBody(
          data: content,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 14,
              color: tokens.textPrimary,
              height: 1.5,
            ),
            h1: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: tokens.kineticAccent,
              height: 1.3,
            ),
            h2: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: tokens.kineticAccent,
              height: 1.3,
            ),
            h3: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: tokens.cyanAccent,
              height: 1.3,
            ),
            strong: TextStyle(
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
            em: TextStyle(
              fontStyle: FontStyle.italic,
              color: tokens.textSecondary,
            ),
            code: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              backgroundColor: tokens.canvas,
              color: tokens.kineticAccent,
            ),
            codeblockDecoration: BoxDecoration(
              color: tokens.canvas,
              borderRadius: BorderRadius.circular(tokens.radiusPill),
              border: Border.all(color: tokens.borderSubtle),
            ),
            codeblockPadding: const EdgeInsets.all(10),
            blockquote: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              color: tokens.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            blockquoteDecoration: BoxDecoration(
              color: tokens.kineticAccent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
              border: Border(
                left: BorderSide(
                  color: tokens.kineticAccent,
                  width: 3,
                ),
              ),
            ),
            blockquotePadding: const EdgeInsets.all(10),
            listBullet: TextStyle(
              color: tokens.kineticAccent,
              fontWeight: FontWeight.bold,
            ),
            listIndent: 20,
            tableHead: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
            tableBorder: TableBorder.all(
              color: tokens.borderSubtle,
            ),
            tableColumnWidth: const FlexColumnWidth(),
            tableCellsPadding: const EdgeInsets.all(8),
          ),
        ),
        
        // Display exercise images if found
        if (exerciseImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: exerciseImages.take(3).map((imageUrl) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 100,
                    height: 100,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 100,
                    height: 100,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.fitness_center,
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        
        // Generated image display
        if (imageState.generatedImage != null) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              imageState.generatedImage!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
        
        // Image generation loading
        if (imageState.isGenerating) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '🎨 Generating custom image...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // Generate image button (disabled on web due to CORS)
        // Will work on Android/iOS apps
        // Uncomment for mobile testing:
        // if (ref.read(imageGenerationServiceProvider).shouldGenerateImage(content) &&
        //     imageState.generatedImage == null &&
        //     !imageState.isGenerating) ...[
        //   const SizedBox(height: 12),
        //   OutlinedButton.icon(
        //     onPressed: () {
        //       final prompt = content.split('\n').first.replaceAll(RegExp(r'[#*]'), '').trim();
        //       ref.read(imageGenerationProvider.notifier).generateImage(prompt);
        //     },
        //     icon: const Icon(Icons.image, size: 18),
        //     label: const Text('Generate Image'),
        //     style: OutlinedButton.styleFrom(
        //       foregroundColor: theme.colorScheme.primary,
        //       side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
        //     ),
        //   ),
        // ],
      ],
    );
  }
}

/// Audio controls widget for TTS playback
class _AudioControls extends StatelessWidget {
  final String content;
  final TtsState ttsState;
  final VoidCallback onPlay;
  final VoidCallback onStop;

  const _AudioControls({
    required this.content,
    required this.ttsState,
    required this.onPlay,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayingThisMessage = ttsState.isSpeaking && ttsState.currentText == content;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Play/Stop button
        InkWell(
          onTap: isPlayingThisMessage ? onStop : onPlay,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPlayingThisMessage
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPlayingThisMessage
                    ? theme.colorScheme.primary.withValues(alpha: 0.3)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPlayingThisMessage ? Icons.stop_rounded : Icons.volume_up_rounded,
                  size: 16,
                  color: isPlayingThisMessage
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  isPlayingThisMessage ? 'Stop' : 'Listen',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isPlayingThisMessage
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: isPlayingThisMessage ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Animated playing indicator
        if (isPlayingThisMessage) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return CustomPaint(
                  painter: _AudioWavePainter(
                    progress: value,
                    color: theme.colorScheme.primary,
                  ),
                );
              },
              onEnd: () {
                // Loop animation
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painter for audio wave animation
class _AudioWavePainter extends CustomPainter {
  final double progress;
  final Color color;

  _AudioWavePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final barWidth = size.width / 5;

    // Draw 3 animated bars
    for (int i = 0; i < 3; i++) {
      final x = (i + 1) * barWidth;
      final height = size.height * (0.3 + 0.4 * ((progress + i * 0.3) % 1.0));
      
      canvas.drawLine(
        Offset(x, centerY - height / 2),
        Offset(x, centerY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_AudioWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

