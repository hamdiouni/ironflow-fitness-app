import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/features/ai/presentation/providers/ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/tts_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/image_generation_provider.dart';
import 'package:progression_tracker/features/ai/data/services/image_generation_service.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

/// Monolithic Sci-Fi AI Chat Screen for personalized fitness coaching
///
/// Features:
/// - Monolithic dark titanium sci-fi design system
/// - Live telemetry status (Online Gemini vs Local Fallback vs Key Missing)
/// - Rich markdown formatting with custom sci-fi styling
/// - Quick action protocol prompt chips
/// - Local chat history persistence
/// - Audio voice controls and TTS integration
class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({
    super.key,
    this.initialMessage,
  });

  /// Optional initial message to pre-populate in the input field.
  final String? initialMessage;

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null && widget.initialMessage!.trim().isNotEmpty) {
      _messageController.text = widget.initialMessage!;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    AppHaptics.shared.buttonPress();
    ref.read(aiChatProvider.notifier).sendMessage(message);
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _sendQuickAction(String action) {
    AppHaptics.shared.selectionChanged();
    String message;
    switch (action) {
      case 'generate_workout':
        message = 'Create a detailed workout program for me';
        break;
      case 'adjust_diet':
        message = 'Suggest nutrition changes based on my goals';
        break;
      case 'analyze_progress':
        message = 'Analyze my recent workout performance';
        break;
      case 'whats_next':
        message = 'What should I focus on next?';
        break;
      case 'plateau_tactics':
        message = 'How do I break through a strength plateau?';
        break;
      case 'form_cues':
        message = 'Give me form cues for standard compound lifts';
        break;
      default:
        return;
    }

    _messageController.text = message;
    _sendMessage(message);
  }

  void _showTTSSettings(BuildContext context) {
    AppHaptics.shared.selectionChanged();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _TTSSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);
    final tokens = AppThemeTokens.of(context);

    // Show error snackbar if error present
    if (chatState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: tokens.kineticAccent, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    chatState.error!,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: tokens.panel,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: tokens.borderSubtle),
            ),
            action: SnackBarAction(
              label: 'DISMISS',
              textColor: tokens.kineticAccent,
              onPressed: () {
                ref.read(aiChatProvider.notifier).clearError();
              },
            ),
          ),
        );
        ref.read(aiChatProvider.notifier).clearError();
      });
    }

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        backgroundColor: tokens.panel,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
          tooltip: 'Back',
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: tokens.card,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: tokens.kineticAccent.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.psychology,
                color: tokens.kineticAccent,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IronFlow AI Coach',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: tokens.textPrimary,
                  ),
                ),
                Text(
                  'Powered by Gemini',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_voice),
            onPressed: () => _showTTSSettings(context),
            tooltip: 'Voice settings',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              AppHaptics.shared.selectionChanged();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: tokens.panel,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: tokens.borderSubtle),
                  ),
                  icon: const Icon(
                    Icons.delete_forever,
                    size: 40,
                    color: Colors.redAccent,
                  ),
                  title: Text(
                    'Clear Chat History',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: tokens.textPrimary,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to clear all chat history? This cannot be undone.',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 12,
                      color: tokens.textSecondary,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          color: tokens.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: () {
                        AppHaptics.shared.buttonPress();
                        ref.read(aiChatProvider.notifier).clearHistory();
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Clear chat history',
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Telemetry Status Bar
          _buildTelemetryStatusBanner(tokens, chatState),

          // Quick Action Protocol Chips
          _buildQuickActionsBar(tokens),

          // Messages View or Empty State
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyState(tokens)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      return _ChatBubble(
                        role: message.role,
                        content: message.content,
                        timestamp: message.timestamp,
                        isFirst: index == 0,
                      );
                    },
                  ),
          ),

          // Loading Telemetry Indicator
          if (chatState.isLoading) _buildLoadingIndicator(tokens),

          // Terminal Message Input
          _buildTerminalInput(tokens, chatState),
        ],
      ),
    );
  }

  // ─── Status Banner ──────────────────────────────────────────────────────────

  Widget _buildTelemetryStatusBanner(AppThemeTokens tokens, AIChatState state) {
    if (state.isKeyMissing) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: tokens.warning.withValues(alpha: 0.12),
        child: Row(
          children: [
            Icon(Icons.vpn_key_off_outlined, size: 14, color: tokens.warning),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'STATUS: OFFLINE HEURISTIC // API KEY REQUIRED FOR GEMINI CLOUD',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: tokens.warning,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state.isOfflineFallback) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: tokens.cyanAccent.withValues(alpha: 0.1),
        child: Row(
          children: [
            Icon(Icons.sync_problem_rounded, size: 14, color: tokens.cyanAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'STATUS: LOCAL FALLBACK ACTIVE // HEURISTIC ENGINE RESPONDED',
                style: TextStyle(
                  fontFamily: AppTypography.displayFontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: tokens.cyanAccent,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: tokens.panel,
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: tokens.kineticAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: tokens.kineticAccent.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'STATUS: NEURAL CORE ONLINE // GEMINI-1.5-FLASH ACTIVE',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: tokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Quick Actions Bar ──────────────────────────────────────────────────────

  Widget _buildQuickActionsBar(AppThemeTokens tokens) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border(
          bottom: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _QuickActionButton(
              code: '01',
              label: 'Workout Plan',
              icon: Icons.fitness_center_rounded,
              onPressed: () => _sendQuickAction('generate_workout'),
            ),
            const SizedBox(width: 8),
            _QuickActionButton(
              code: '02',
              label: 'Nutrition',
              icon: Icons.restaurant_menu_rounded,
              onPressed: () => _sendQuickAction('adjust_diet'),
            ),
            const SizedBox(width: 8),
            _QuickActionButton(
              code: '03',
              label: 'Progress',
              icon: Icons.trending_up_rounded,
              onPressed: () => _sendQuickAction('analyze_progress'),
            ),
            const SizedBox(width: 8),
            _QuickActionButton(
              code: '04',
              label: "What's Next",
              icon: Icons.lightbulb_outline_rounded,
              onPressed: () => _sendQuickAction('whats_next'),
            ),
            const SizedBox(width: 8),
            _QuickActionButton(
              code: '05',
              label: 'Plateau Breaking',
              icon: Icons.speed_rounded,
              onPressed: () => _sendQuickAction('plateau_tactics'),
            ),
            const SizedBox(width: 8),
            _QuickActionButton(
              code: '06',
              label: 'Form Protocol',
              icon: Icons.accessibility_new_rounded,
              onPressed: () => _sendQuickAction('form_cues'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty State ────────────────────────────────────────────────────────────

  Widget _buildEmptyState(AppThemeTokens tokens) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: tokens.panel,
                shape: BoxShape.circle,
                border: Border.all(color: tokens.kineticAccent.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: tokens.kineticAccent.withValues(alpha: 0.25),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Icon(
                Icons.psychology,
                size: 36,
                color: tokens.kineticAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tactical Training Core',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me anything about workouts, nutrition, form, or your fitness journey',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13,
                color: tokens.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                _SuggestionChip(
                  icon: Icons.fitness_center_rounded,
                  label: 'Create workout',
                  onTap: () => _sendQuickAction('generate_workout'),
                ),
                _SuggestionChip(
                  icon: Icons.restaurant_rounded,
                  label: 'Nutrition tips',
                  onTap: () => _sendQuickAction('adjust_diet'),
                ),
                _SuggestionChip(
                  icon: Icons.trending_up_rounded,
                  label: 'Track progress',
                  onTap: () => _sendQuickAction('analyze_progress'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Loading Indicator ──────────────────────────────────────────────────────

  Widget _buildLoadingIndicator(AppThemeTokens tokens) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border(top: BorderSide(color: tokens.borderSubtle)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(tokens.kineticAccent),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'AI is analyzing your data...',
            style: TextStyle(
              fontFamily: AppTypography.displayFontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: tokens.kineticAccent,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Terminal Input ─────────────────────────────────────────────────────────

  Widget _buildTerminalInput(AppThemeTokens tokens, AIChatState chatState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tokens.panel,
        border: Border(
          top: BorderSide(color: tokens.borderSubtle, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: tokens.card,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: tokens.borderSubtle),
                ),
                child: TextField(
                  controller: _messageController,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 14,
                    color: tokens.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    hintStyle: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 13,
                      color: tokens.textMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    prefixIcon: Icon(
                      Icons.chat_bubble_outline,
                      color: tokens.kineticAccent.withValues(alpha: 0.7),
                      size: 18,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _sendMessage,
                  enabled: !chatState.isLoading,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: chatState.isLoading
                    ? tokens.borderSubtle
                    : tokens.kineticAccent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: chatState.isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: tokens.kineticAccent.withValues(alpha: 0.35),
                          blurRadius: 8,
                        ),
                      ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: chatState.isLoading
                    ? null
                    : () => _sendMessage(_messageController.text),
                color: Colors.black,
                iconSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick action button widget with Monolithic Sci-Fi styling
class _QuickActionButton extends StatelessWidget {
  final String code;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.code,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: tokens.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: tokens.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: tokens.kineticAccent),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                color: tokens.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Suggestion chip for empty state
class _SuggestionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: tokens.panel,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: tokens.borderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: tokens.kineticAccent),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                color: tokens.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Enhanced chat bubble with Monolithic Sci-Fi styling and markdown support
class _ChatBubble extends ConsumerWidget {
  final String role;
  final String content;
  final DateTime timestamp;
  final bool isFirst;

  const _ChatBubble({
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
                borderRadius: BorderRadius.circular(8),
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
                  // Call Sign / Role Tag
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isUser ? tokens.textMuted : tokens.kineticAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isUser ? 'OPERATOR // QUERY' : 'AI CORE // ADVISORY',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
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
              borderRadius: BorderRadius.circular(6),
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
                      color: theme.colorScheme.primary.withOpacity(0.5),
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
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
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
        //       side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.5)),
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
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPlayingThisMessage
                    ? theme.colorScheme.primary.withOpacity(0.3)
                    : theme.colorScheme.onSurface.withOpacity(0.2),
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
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  isPlayingThisMessage ? 'Stop' : 'Listen',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isPlayingThisMessage
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withOpacity(0.6),
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

/// TTS Settings Bottom Sheet
class _TTSSettingsSheet extends ConsumerWidget {
  const _TTSSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ttsState = ref.watch(ttsProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings_voice,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Voice Settings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Speed Control
            Text(
              '🎚️ Speech Speed',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.speed,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(ttsState.speechRate * 2).toStringAsFixed(1)}x',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Row(
                            children: [
                              _SpeedChip(
                                label: '0.5x',
                                value: 0.25,
                                currentValue: ttsState.speechRate,
                                onTap: () => ref.read(ttsProvider.notifier).setSpeechRate(0.25),
                              ),
                              const SizedBox(width: 8),
                              _SpeedChip(
                                label: '1x',
                                value: 0.5,
                                currentValue: ttsState.speechRate,
                                onTap: () => ref.read(ttsProvider.notifier).setSpeechRate(0.5),
                              ),
                              const SizedBox(width: 8),
                              _SpeedChip(
                                label: '1.5x',
                                value: 0.75,
                                currentValue: ttsState.speechRate,
                                onTap: () => ref.read(ttsProvider.notifier).setSpeechRate(0.75),
                              ),
                              const SizedBox(width: 8),
                              _SpeedChip(
                                label: '2x',
                                value: 1.0,
                                currentValue: ttsState.speechRate,
                                onTap: () => ref.read(ttsProvider.notifier).setSpeechRate(1.0),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: theme.colorScheme.primary,
                          inactiveTrackColor: theme.colorScheme.primary.withOpacity(0.2),
                          thumbColor: theme.colorScheme.primary,
                          overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: ttsState.speechRate,
                          min: 0.1,
                          max: 1.0,
                          divisions: 18,
                          onChanged: (value) {
                            ref.read(ttsProvider.notifier).setSpeechRate(value);
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Slower',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            'Faster',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Voice Personas
            Text(
              '🎭 Voice Personas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a coaching style that motivates you',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            
            // Persona Cards
            if (ttsState.personas.isNotEmpty)
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ttsState.personas.length,
                  itemBuilder: (context, index) {
                    final persona = ttsState.personas[index];
                    final isSelected = ttsState.selectedPersonaId == persona.id;
                    
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < ttsState.personas.length - 1 ? 12 : 0,
                      ),
                      child: _PersonaCard(
                        persona: persona,
                        isSelected: isSelected,
                        onTap: () {
                          ref.read(ttsProvider.notifier).applyPersona(persona);
                        },
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Voice personas are loading...',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

            // Advanced: Raw voice selection (collapsed by default)
            if (ttsState.availableVoices.isNotEmpty) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: Text(
                  'Advanced Voice Settings',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: Icon(
                  Icons.tune,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: ttsState.selectedVoice,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          hint: Row(
                            children: [
                              Icon(
                                Icons.record_voice_over,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Select system voice',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          items: ttsState.availableVoices.take(10).map((voice) {
                            return DropdownMenuItem<String>(
                              value: voice,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: 18,
                                    color: theme.colorScheme.primary.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      voice,
                                      style: theme.textTheme.bodyMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (voice) {
                            if (voice != null) {
                              ref.read(ttsProvider.notifier).setVoice(voice);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Test Button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  ref.read(ttsProvider.notifier).speak(
                    'Hello! This is a test of the text to speech voice. How does it sound?',
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Test Voice'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Speed selection chip
class _SpeedChip extends StatelessWidget {
  final String label;
  final double value;
  final double currentValue;
  final VoidCallback onTap;

  const _SpeedChip({
    required this.label,
    required this.value,
    required this.currentValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = (currentValue - value).abs() < 0.01;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected
                ? Colors.white
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Persona Card Widget
class _PersonaCard extends StatelessWidget {
  final VoicePersona persona;
  final bool isSelected;
  final VoidCallback onTap;

  const _PersonaCard({
    required this.persona,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Calculate display values
    final displaySpeed = '${(persona.recommendedSpeed * 2).toStringAsFixed(1)}x';
    final pitchLevel = persona.pitch < 0.8 ? 'Low' : persona.pitch > 1.3 ? 'High' : 'Normal';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with speed badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    persona.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const Spacer(),
                // Speed indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.3)
                        : theme.colorScheme.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    displaySpeed,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Name
            Text(
              persona.name.replaceAll(RegExp(r'[^\w\s]'), ''), // Remove emoji from name
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            
            // Description
            Flexible(
              child: Text(
                persona.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: isSelected
                      ? Colors.white.withOpacity(0.9)
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(height: 6),
            
            // Pitch indicator
            Row(
              children: [
                Icon(
                  pitchLevel == 'Low' ? Icons.arrow_downward : 
                  pitchLevel == 'High' ? Icons.arrow_upward : Icons.remove,
                  size: 10,
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  '$pitchLevel pitch',
                  style: TextStyle(
                    fontSize: 9,
                    color: isSelected
                        ? Colors.white.withOpacity(0.8)
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Selected indicator
            if (isSelected)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Active',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
