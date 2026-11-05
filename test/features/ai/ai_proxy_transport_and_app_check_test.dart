import 'dart:convert';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:progression_tracker/core/services/app_check_service.dart';
import 'package:progression_tracker/features/ai/data/datasources/ai_transport.dart';
import 'package:progression_tracker/features/ai/data/datasources/gemini_ai_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AiTransport & GeminiAIService Proxy Routing (Wave 1 Step 6)', () {
    test('routes through proxy with Firebase Auth Bearer token and X-Firebase-AppCheck header', () async {
      late http.Request capturedRequest;

      final mockClient = MockClient((request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'Proxy coach response'}
                  ]
                }
              }
            ]
          }),
          200,
        );
      });

      final AiTransport transport = GeminiAIService(
        proxyUrl: 'https://aigenerate-test.a.run.app/aiGenerate',
        allowDirectApiKey: false,
        authTokenProvider: () async => 'firebase-id-token-123',
        appCheckTokenProvider: () async => 'app-check-token-456',
        httpClient: mockClient,
      );

      expect(transport.isConfigured, isTrue);
      expect(transport.usesProxy, isTrue);

      final reply = await transport.sendMessage([
        {'role': 'user', 'content': 'Build a push day workout.'},
      ]);

      expect(reply, equals('Proxy coach response'));
      expect(
        capturedRequest.url.toString(),
        equals('https://aigenerate-test.a.run.app/aiGenerate'),
      );
      expect(
        capturedRequest.headers['Authorization'],
        equals('Bearer firebase-id-token-123'),
      );
      expect(
        capturedRequest.headers['X-Firebase-AppCheck'],
        equals('app-check-token-456'),
      );

      final decodedBody = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
      expect(decodedBody['model'], equals('gemini-2.5-flash'));
    });

    test('fails closed in release mode when proxyUrl is empty even if direct apiKey is supplied', () {
      final service = GeminiAIService(
        apiKey: 'debug-direct-key',
        proxyUrl: '',
        allowDirectApiKey: false,
      );

      expect(service.isConfigured, isFalse);
      expect(
        () => service.validateConfiguration(),
        throwsA(
          isA<GeminiAIServiceException>().having(
            (e) => e.code,
            'code',
            equals('DIRECT_API_KEY_DISABLED'),
          ),
        ),
      );
    });

    test('enforces client-side input size limits before dispatching HTTP request', () async {
      var httpCalled = false;
      final mockClient = MockClient((_) async {
        httpCalled = true;
        return http.Response('{}', 200);
      });

      final service = GeminiAIService(
        proxyUrl: 'https://aigenerate-test.a.run.app/aiGenerate',
        httpClient: mockClient,
      );

      await expectLater(
        () => service.sendMessage([
          {
            'role': 'user',
            'content': 'x' * (GeminiAIService.maxPromptChars + 1),
          },
        ]),
        throwsA(
          isA<GeminiAIServiceException>().having(
            (e) => e.code,
            'code',
            equals('PAYLOAD_TOO_LARGE'),
          ),
        ),
      );
      expect(httpCalled, isFalse);
    });

    test('maps HTTP 429 and 401 responses to typed GeminiAIServiceException codes', () async {
      final rateLimitService = GeminiAIService(
        proxyUrl: 'https://aigenerate-test.a.run.app/aiGenerate',
        httpClient: MockClient((_) async => http.Response('{"error":{"code":"RATE_LIMIT_EXCEEDED"}}', 429)),
      );

      await expectLater(
        () => rateLimitService.sendMessage([
          {'role': 'user', 'content': 'Hi'},
        ]),
        throwsA(
          isA<GeminiAIServiceException>().having(
            (e) => e.code,
            'code',
            equals('RATE_LIMIT_EXCEEDED'),
          ),
        ),
      );

      final unauthService = GeminiAIService(
        proxyUrl: 'https://aigenerate-test.a.run.app/aiGenerate',
        httpClient: MockClient((_) async => http.Response('{"error":{"code":"UNAUTHENTICATED"}}', 401)),
      );

      await expectLater(
        () => unauthService.sendMessage([
          {'role': 'user', 'content': 'Hi'},
        ]),
        throwsA(
          isA<GeminiAIServiceException>().having(
            (e) => e.code,
            'code',
            equals('UNAUTHORIZED'),
          ),
        ),
      );
    });

    test('parseSseChunks extracts streamed text chunks from SSE payload', () {
      const ssePayload = '''
data: {"candidates":[{"content":{"parts":[{"text":"Warm up "}]}}]}

data: {"candidates":[{"content":{"parts":[{"text":"with 2 light sets."}]}}]}

data: [DONE]
''';
      final chunks = GeminiAIService.parseSseChunks(ssePayload);
      expect(chunks, equals(['Warm up ', 'with 2 light sets.']));
    });
  });

  group('AppCheckService Staged Rollout Configuration (Wave 1 Step 7)', () {
    test('defaults to monitor stage and selects PlayIntegrity/AppAttest in release mode vs debug in debug mode', () {
      expect(AppCheckService.currentStage, equals(AppCheckStage.monitor));
      expect(
        AppCheckService.resolveAndroidProvider(isReleaseMode: true),
        equals(AndroidProvider.playIntegrity),
      );
      expect(
        AppCheckService.resolveAndroidProvider(isReleaseMode: false),
        equals(AndroidProvider.debug),
      );
      expect(
        AppCheckService.resolveAppleProvider(isReleaseMode: true),
        equals(AppleProvider.appAttestWithDeviceCheckFallback),
      );
      expect(
        AppCheckService.resolveAppleProvider(isReleaseMode: false),
        equals(AppleProvider.debug),
      );
    });

    test('initialize and getToken tolerate uninitialized Firebase safely without throwing', () async {
      await AppCheckService.initialize();
      final token = await AppCheckService.getToken();
      expect(token, isNull);
    });
  });
}

