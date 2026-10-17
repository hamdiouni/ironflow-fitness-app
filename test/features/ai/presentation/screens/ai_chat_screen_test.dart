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
  _FakeAIChatNotifier([AIChatState? state]) : super(state ?? AIChatState());

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

    testWidgets('renders chat messages from state', (tester) async {
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
