import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/features/ai/presentation/providers/ai_provider.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';
import '../widgets/chat/ai_chat_banners_and_chips.dart';
import '../widgets/chat/ai_chat_message_bubble.dart';
import '../widgets/chat/ai_tts_settings_sheet.dart';

/// Stripe AI Chat Screen for personalized fitness coaching
///
/// Features:
/// - Stripe design system
/// - Live telemetry status (Online Gemini vs Local Fallback vs Key Missing)
/// - Rich markdown formatting with custom sci-fi styling
/// - Quick action protocol prompt chips
/// - Local chat history persistence
/// - Audio voice controls and TTS integration
class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({
    super.key,
    this.initialMessage,
    this.contextScreen,
  });

  /// Optional initial message to pre-populate in the input field.
  final String? initialMessage;

  /// Optional source screen context ('today', 'workout', 'fuel', 'progress').
  final String? contextScreen;

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late String _selectedScreenCategory;

  static const Map<String, List<String>> _screenPromptChips = {
    'today': [
      'How should I warm up today?',
      'What should my focus be today?',
      'How can I improve my recovery?',
      'Quick 5-minute cooldown routine',
    ],
    'workout': [
      'How do I break through a strength plateau?',
      'Form cues for compound lifts',
      'How much rest between heavy sets?',
      "Finisher idea for today's session",
    ],
    'fuel': [
      'Am I eating enough protein?',
      'Can I swap chicken for tuna?',
      'What should I eat before my workout?',
      'High-protein budget snack ideas',
    ],
    'progress': [
      'Analyze my strength progress this month',
      'Is my weight trend on track for my goal?',
      'Am I applying progressive overload?',
      'Tips for staying consistent with tracking',
    ],
  };

  @override
  void initState() {
    super.initState();
    final incoming = widget.contextScreen?.toLowerCase();
    if (incoming == 'workout') {
      _selectedScreenCategory = 'workout';
    } else if (incoming == 'fuel' || incoming == 'nutrition') {
      _selectedScreenCategory = 'fuel';
    } else if (incoming == 'progress' || incoming == 'analytics') {
      _selectedScreenCategory = 'progress';
    } else {
      _selectedScreenCategory = 'today';
    }

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

  void _showTTSSettings(BuildContext context) {
    AppHaptics.shared.selectionChanged();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AITtsSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);
    final tokens = AppThemeTokens.of(context);

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
                borderRadius: BorderRadius.circular(tokens.radiusPill),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radiusPill)),
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
          // Live Status Bar
          AIChatTelemetryStatusBanner(tokens: tokens, state: chatState),

          // Contextual Prompt Chips Bar (Today, Workout, Fuel, Progress)
          AIChatContextualChipsBar(
            tokens: tokens,
            selectedCategory: _selectedScreenCategory,
            currentChips: _screenPromptChips[_selectedScreenCategory] ?? _screenPromptChips['today']!,
            onSelectCategory: (id) => setState(() => _selectedScreenCategory = id),
            onSelectPrompt: (prompt) {
              _messageController.text = prompt;
              _sendMessage(prompt);
            },
          ),

          // Messages View or Empty State
          Expanded(
            child: chatState.messages.isEmpty
                ? AIChatEmptyState(
                    tokens: tokens,
                    chips: _screenPromptChips[_selectedScreenCategory] ?? _screenPromptChips['today']!,
                    onSelectPrompt: (prompt) {
                      _messageController.text = prompt;
                      _sendMessage(prompt);
                    },
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      return AIChatBubble(
                        role: message.role,
                        content: message.content,
                        timestamp: message.timestamp,
                        isFirst: index == 0,
                      );
                    },
                  ),
          ),

          // Interactive Error Banner with Retry Button
          if (chatState.error != null) AIChatInteractiveErrorBanner(tokens: tokens, chatState: chatState),

          // Loading Indicator
          if (chatState.isLoading) AIChatLoadingIndicator(tokens: tokens),

          // Terminal Message Input
          _buildTerminalInput(tokens, chatState),
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
                  borderRadius: BorderRadius.circular(tokens.radiusPill),
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
                borderRadius: BorderRadius.circular(tokens.radiusPill),
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
