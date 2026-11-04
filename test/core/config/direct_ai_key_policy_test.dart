import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/config/app_config.dart';
import 'package:progression_tracker/features/ai/data/datasources/gemini_ai_service.dart';

void main() {
  group('Direct AI Key Policy Security Gate', () {
    test('AppConfig.allowDirectAiApiKeys reflects kDebugMode policy', () {
      // In flutter test runner, kDebugMode is true
      expect(AppConfig.allowDirectAiApiKeys, isTrue);
    });

    test('GeminiAIService blocks direct API key when allowDirectApiKey is false', () {
      final service = GeminiAIService(
        apiKey: 'test-fake-key-for-test-only',
        proxyUrl: '',
        allowDirectApiKey: false,
      );

      expect(
        () => service.validateConfiguration(),
        throwsA(
          isA<GeminiAIServiceException>().having(
            (e) => e.code,
            'code',
            'DIRECT_API_KEY_DISABLED',
          ),
        ),
      );
    });

    test('GeminiAIService allows direct key when allowDirectApiKey is true in debug', () {
      final service = GeminiAIService(
        apiKey: 'test-fake-key-for-test-only',
        proxyUrl: '',
        allowDirectApiKey: true,
      );

      expect(() => service.validateConfiguration(), returnsNormally);
      expect(service.isConfigured, isTrue);
      expect(service.usesProxy, isFalse);
    });

    test('GeminiAIService allows proxy regardless of direct key setting', () {
      final service = GeminiAIService(
        apiKey: '',
        proxyUrl: 'https://proxy.example.com/ai',
        allowDirectApiKey: false,
      );

      expect(() => service.validateConfiguration(), returnsNormally);
      expect(service.isConfigured, isTrue);
      expect(service.usesProxy, isTrue);
    });

    test('GeminiAIService throws MISSING_API_KEY when unconfigured', () {
      final service = GeminiAIService(
        apiKey: '',
        proxyUrl: '',
        allowDirectApiKey: false,
      );

      expect(
        () => service.validateConfiguration(),
        throwsA(
          isA<GeminiAIServiceException>().having(
            (e) => e.code,
            'code',
            'MISSING_API_KEY',
          ),
        ),
      );
    });
  });
}

