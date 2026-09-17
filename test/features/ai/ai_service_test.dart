import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:progression_tracker/features/ai/data/datasources/ai_service.dart';

/// Test file to verify OpenAI API key works
/// 
/// Run with: flutter test test/features/ai/ai_service_test.dart
void main() {
  group('OpenAI API Integration Tests', () {
    late AIService aiService;

    setUpAll(() async {
      // Load .env file
      await dotenv.load(fileName: '.env');
      aiService = AIService();
    });

    test('API key should be configured', () {
      expect(() => aiService.validateConfiguration(), returnsNormally);
    });

    test('Should send a simple message and get response', () async {
      final messages = [
        {'role': 'user', 'content': 'Say "Hello from IronFlow!" in exactly those words.'}
      ];

      final response = await aiService.sendMessage(
        messages,
        temperature: 0.0, // Use 0 for deterministic response
        maxTokens: 50,
      );

      print('✅ API Response: $response');
      expect(response, isNotEmpty);
      expect(response.toLowerCase(), contains('hello'));
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Should handle fitness coaching question', () async {
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

      print('✅ Fitness Advice: $response');
      expect(response, isNotEmpty);
      expect(response.length, lessThan(200)); // Should be concise
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('Should handle invalid API key gracefully', () async {
      final invalidService = AIService(apiKey: 'invalid-key-12345');
      
      final messages = [
        {'role': 'user', 'content': 'Test'}
      ];

      expect(
        () => invalidService.sendMessage(messages),
        throwsA(isA<AIServiceException>()),
      );
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
