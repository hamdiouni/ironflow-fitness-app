import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:progression_tracker/features/ai/data/datasources/ai_service.dart';

void main() {
  group('OpenAI API Service Unit Tests (Mocked HTTP)', () {
    test('API key validation throws when key is empty', () {
      final unconfiguredService = AIService(apiKey: '');
      expect(
        () => unconfiguredService.validateConfiguration(),
        throwsA(isA<AIServiceException>()),
      );
    });

    test('API key validation passes when key is provided', () {
      final service = AIService(apiKey: 'test-valid-key');
      expect(() => service.validateConfiguration(), returnsNormally);
    });

    test('Should send a simple message and get response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://api.openai.com/v1/chat/completions');
        expect(request.headers['Authorization'], 'Bearer test-valid-key');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['messages'], isNotEmpty);

        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': 'Hello from IronFlow!'}
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final aiService = AIService(
        apiKey: 'test-valid-key',
        httpClient: mockClient,
      );

      final messages = [
        {'role': 'user', 'content': 'Say "Hello from IronFlow!" in exactly those words.'}
      ];

      final response = await aiService.sendMessage(
        messages,
        temperature: 0.0,
        maxTokens: 50,
      );

      expect(response, isNotEmpty);
      expect(response.toLowerCase(), contains('hello'));
    });

    test('Should handle fitness coaching question', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'choices': [
              {
                'message': {'content': 'Focus on progressive overload and retract your scapula.'}
              }
            ]
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final aiService = AIService(
        apiKey: 'test-valid-key',
        httpClient: mockClient,
      );

      final messages = [
        {
          'role': 'user',
          'content': 'I want to increase my bench press. Give me one specific tip in 20 words or less.'
        }
      ];

      final response = await aiService.sendMessage(
        messages,
        systemPrompt: 'You are a professional fitness coach. Be concise and specific.',
        temperature: 0.7,
        maxTokens: 100,
      );

      expect(response, isNotEmpty);
      expect(response.length, lessThan(200));
    });

    test('Should handle invalid API key gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': {'message': 'Incorrect API key provided'}}),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final invalidService = AIService(
        apiKey: 'invalid-key-12345',
        httpClient: mockClient,
      );

      final messages = [
        {'role': 'user', 'content': 'Test'}
      ];

      expect(
        () => invalidService.sendMessage(messages),
        throwsA(isA<AIServiceException>()),
      );
    });
  });
}
