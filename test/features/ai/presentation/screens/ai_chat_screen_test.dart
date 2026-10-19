import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/features/ai/domain/entities/chat_message.dart';
import 'package:progression_tracker/features/ai/presentation/providers/ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/screens/ai_chat_screen.dart';

import 'package:progression_tracker/features/ai/presentation/providers/tts_provider.dart';

class _FakeAIChatNotifier extends StateNotifier<AIChatState>
    implements AIChatNotifier {
  String? sentMessage;
  bool retryCalled = false;

  _FakeAIChatNotifier([AIChatState? state]) : super(state ?? AIChatState());

  @override
  Future<void> sendMessage(String message) async {
    sentMessage = message;
    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatMessage(
          id: 'test_msg',
          content: message,
          role: 'user',
          timestamp: DateTime.now(),
        ),
      ],
    );
  }

  @override
  Future<void> retryLastMessage() async {
    retryCalled = true;
  }

  @override
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTtsNotifier extends StateNotifier<TtsState>
    implements TtsNotifier {
  _FakeTtsNotifier() : super(const TtsState());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AIChatScreen Destination View Tests', () {
    testWidgets('renders AI Coach header and chat interface', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiChatProvider.overrideWith((ref) => _FakeAIChatNotifier()),
            ttsProvider.overrideWith((ref) => _FakeTtsNotifier()),
          ],
          child: const MaterialApp(
            home: AIChatScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('IronFlow AI Coach'), findsOneWidget);
      expect(find.text('Powered by Gemini'), findsOneWidget);
      expect(find.text('Online • Ready to help'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('pre-populates message field when initialMessage is provided',
        (tester) async {
      const prompt = 'Tell me more about: Optimal Recovery';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiChatProvider.overrideWith((ref) => _FakeAIChatNotifier()),
            ttsProvider.overrideWith((ref) => _FakeTtsNotifier()),
          ],
          child: const MaterialApp(
            home: AIChatScreen(initialMessage: prompt),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(prompt), findsOneWidget);
    });

    testWidgets('renders chat messages with simple English role tags (You, Coach)', (tester) async {
      final messages = [
        ChatMessage(
          id: '1',
          content: 'Hello, Coach!',
          role: 'user',
          timestamp: DateTime.now(),
        ),
        ChatMessage(
          id: '2',
          content: 'Hello! Ready to train hard today?',
          role: 'assistant',
          timestamp: DateTime.now(),
        ),
      ];

      final state = AIChatState(messages: messages);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiChatProvider.overrideWith((ref) => _FakeAIChatNotifier(state)),
            ttsProvider.overrideWith((ref) => _FakeTtsNotifier()),
          ],
          child: const MaterialApp(
            home: AIChatScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Hello, Coach!'), findsOneWidget);
      expect(find.text('Hello! Ready to train hard today?'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
      expect(find.text('Coach'), findsOneWidget);
      expect(find.text('OPERATOR // QUERY'), findsNothing);
      expect(find.text('AI CORE // ADVISORY'), findsNothing);
    });

    testWidgets('renders contextual chips based on contextScreen and allows tab switching',
        (tester) async {
      final fakeNotifier = _FakeAIChatNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiChatProvider.overrideWith((ref) => fakeNotifier),
            ttsProvider.overrideWith((ref) => _FakeTtsNotifier()),
          ],
          child: const MaterialApp(
            home: AIChatScreen(contextScreen: 'workout'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Workout chips should be visible
      expect(find.text('How do I break through a strength plateau?'), findsWidgets);

      // Switch to Fuel tab
      final fuelTab = find.byKey(const ValueKey('screen_tab_fuel'));
      expect(fuelTab, findsOneWidget);
      await tester.tap(fuelTab);
      await tester.pumpAndSettle();

      // Fuel chips should now be visible
      expect(find.text('Am I eating enough protein?'), findsWidgets);

      // Tapping chip sends the message
      await tester.tap(find.text('Am I eating enough protein?').first);
      await tester.pumpAndSettle();
      expect(fakeNotifier.sentMessage, 'Am I eating enough protein?');
    });

    testWidgets('renders interactive error banner with Retry button when error occurs',
        (tester) async {
      final fakeNotifier = _FakeAIChatNotifier(
        AIChatState(
          error: 'Could not connect to the fitness assistant. Please check your internet connection and try again.',
          lastFailedMessage: 'How to bench press?',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiChatProvider.overrideWith((ref) => fakeNotifier),
            ttsProvider.overrideWith((ref) => _FakeTtsNotifier()),
          ],
          child: const MaterialApp(
            home: AIChatScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('ai_chat_error_banner')), findsOneWidget);
      expect(
        find.text('Could not connect to the fitness assistant. Please check your internet connection and try again.'),
        findsOneWidget,
      );

      // Tap Retry button
      final retryButton = find.byKey(const ValueKey('ai_chat_retry_button'));
      expect(retryButton, findsOneWidget);
      await tester.tap(retryButton);
      await tester.pumpAndSettle();

      expect(fakeNotifier.retryCalled, isTrue);
    });

    testWidgets('back button pops route in GoRouter navigation', (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () => context.push('/ai-chat'),
                child: const Text('Go to AI'),
              ),
            ),
          ),
          GoRoute(
            path: '/ai-chat',
            builder: (context, state) => const AIChatScreen(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiChatProvider.overrideWith((ref) => _FakeAIChatNotifier()),
            ttsProvider.overrideWith((ref) => _FakeTtsNotifier()),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Go to AI Chat
      await tester.tap(find.text('Go to AI'));
      await tester.pumpAndSettle();
      expect(find.text('IronFlow AI Coach'), findsOneWidget);

      // Tap back button
      final backButton = find.byTooltip('Back');
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Should be back at Home
      expect(find.text('Go to AI'), findsOneWidget);
      expect(find.text('IronFlow AI Coach'), findsNothing);
    });
  });
}
