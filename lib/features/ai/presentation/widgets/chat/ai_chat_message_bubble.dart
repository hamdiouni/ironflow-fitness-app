import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/ai/domain/services/ai_coach_action_parser.dart';
import 'package:progression_tracker/features/ai/presentation/providers/ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/tts_provider.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart'
    show currentUserIdProvider;
import 'package:progression_tracker/features/workout/domain/entities/exercise_definition.dart';
import 'package:progression_tracker/features/workout/domain/services/exercise_catalog.dart';
import 'package:progression_tracker/shared/widgets/exercise_media_stage.dart';

/// Enhanced chat bubble with Option B Iron Scoreboard styling, markdown support,
/// canonical exercise chips, and schema-validated "Tap to apply" action cards
/// with 1-tap Undo (Wave 7.2 & 7.3 — ADR-003).
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
                          color:
                              isUser ? tokens.textMuted : tokens.kineticAccent,
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
                          color:
                              isUser ? tokens.textMuted : tokens.kineticAccent,
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
                          onPlay: () =>
                              ref.read(ttsProvider.notifier).speak(content),
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

/// AI response content with markdown, canonical exercise chips, and "Tap to apply"
/// action cards (Wave 7.2 & 7.3).
class _AIResponseContent extends ConsumerWidget {
  final String content;

  const _AIResponseContent({required this.content});

  static List<ExerciseDefinition> _extractCanonicalExercises(String text) {
    final lower = text.toLowerCase();
    final matched = <ExerciseDefinition>[];
    for (final def in ExerciseCatalog.all) {
      if (lower.contains(def.name.toLowerCase())) {
        matched.add(def);
        if (matched.length >= 3) break;
      }
    }
    return matched;
  }

  void _openExercisePreviewSheet(
    BuildContext context,
    ExerciseDefinition exercise,
  ) {
    final tokens = AppThemeTokens.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: tokens.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radiusXl),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: tokens.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ExerciseMediaStage(
                  exerciseName: exercise.name,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final activeUserId = ref.watch(currentUserIdProvider);
    final appliedActionIds = ref.watch(
      aiChatProvider.select((s) => s.appliedActionIds),
    );

    final parsed = AiCoachActionParser.parse(
      content,
      currentUserId: activeUserId,
    );
    final mentionedExercises = _extractCanonicalExercises(
      parsed.displayMarkdown,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MarkdownBody(
          data: parsed.displayMarkdown,
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

        // Canonical ExerciseCatalog chips (replaces legacy Unsplash ExerciseImageDatabase)
        if (mentionedExercises.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mentionedExercises.map((exercise) {
              return ActionChip(
                key: Key('ai_exercise_chip_${exercise.id}'),
                avatar: Icon(
                  Icons.fitness_center_rounded,
                  size: 15,
                  color: tokens.kineticAccent,
                ),
                label: Text(
                  exercise.name,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
                backgroundColor: tokens.card,
                side: BorderSide(color: tokens.borderSubtle),
                onPressed: () => _openExercisePreviewSheet(context, exercise),
              );
            }).toList(),
          ),
        ],

        // Structured "Tap to apply" action cards with Undo (Wave 7.3 — ADR-003)
        if (parsed.actions.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final action in parsed.actions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AiActionCard(
                action: action,
                isApplied: appliedActionIds.contains(action.id),
              ),
            ),
        ],
      ],
    );
  }
}

class _AiActionCard extends ConsumerWidget {
  final AiCoachAction action;
  final bool isApplied;

  const _AiActionCard({
    required this.action,
    required this.isApplied,
  });

  IconData _iconForType(AiCoachActionType type) => switch (type) {
    AiCoachActionType.saveProgram => Icons.calendar_view_week_rounded,
    AiCoachActionType.swapExercise => Icons.swap_horiz_rounded,
    AiCoachActionType.logMeal => Icons.restaurant_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);

    return Container(
      key: Key('ai_action_card_${action.id}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(
          color: isApplied
              ? tokens.success.withValues(alpha: 0.5)
              : tokens.kineticAccent.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                _iconForType(action.type),
                size: 16,
                color: isApplied ? tokens.success : tokens.kineticAccent,
              ),
              Text(
                action.title,
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: tokens.textPrimary,
                ),
              ),
              if (action.isEstimate)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.warning.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(tokens.radiusXs),
                    border: Border.all(
                      color: tokens.warning.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    'ESTIMATE',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: tokens.warning,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            action.summary,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 12,
              color: tokens.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isApplied)
                FilledButton.icon(
                  key: Key('ai_action_apply_${action.id}'),
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.kineticAccent,
                    foregroundColor: tokens.onAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.touch_app_rounded, size: 16),
                  label: const Text(
                    'Tap to apply',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () async {
                    final err = await ref
                        .read(aiChatProvider.notifier)
                        .applyCoachAction(action);
                    if (!context.mounted) return;
                    if (err != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err)),
                      );
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Applied: ${action.title}'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            ref
                                .read(aiChatProvider.notifier)
                                .undoCoachAction(action.id);
                          },
                        ),
                      ),
                    );
                  },
                )
              else ...[
                Icon(Icons.check_circle_rounded, size: 16, color: tokens.success),
                const SizedBox(width: 4),
                Text(
                  'Applied',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: tokens.success,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  key: Key('ai_action_undo_${action.id}'),
                  icon: const Icon(Icons.undo_rounded, size: 15),
                  label: const Text(
                    'Undo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () async {
                    await ref
                        .read(aiChatProvider.notifier)
                        .undoCoachAction(action.id);
                  },
                ),
              ],
            ],
          ),
        ],
      ),
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
    final isPlayingThisMessage =
        ttsState.isSpeaking && ttsState.currentText == content;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
                  isPlayingThisMessage
                      ? Icons.stop_rounded
                      : Icons.volume_up_rounded,
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
                    fontWeight:
                        isPlayingThisMessage ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
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
