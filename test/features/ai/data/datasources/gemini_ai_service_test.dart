import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:progression_tracker/features/ai/data/datasources/gemini_ai_service.dart';

class FakeHttpClient extends http.BaseClient {
  http.Request? capturedRequest;
  String? capturedBody;
  http.Response responseToReturn;

  FakeHttpClient(this.responseToReturn);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request is http.Request) {
      capturedRequest = request;
      capturedBody = request.body;
    }
    return http.StreamedResponse(
      Stream.value(responseToReturn.bodyBytes),
      responseToReturn.statusCode,
      headers: responseToReturn.headers,
    );
  }
}

void main() {
  group('GeminiAIService (AI-01 Proxy Architecture)', () {
    test('validateConfiguration throws when neither apiKey nor proxyUrl is configured', () {
      final service = GeminiAIService(apiKey: '', proxyUrl: '');
      expect(service.isConfigured, isFalse);
      expect(service.usesProxy, isFalse);
      expect(
        () => service.validateConfiguration(),
        throwsA(isA<GeminiAIServiceException>()),
      );
    });

    test('usesProxy is true and isConfigured is true when proxyUrl is supplied', () {
      final service = GeminiAIService(
        apiKey: '',
        proxyUrl: 'https://ai-proxy.ironflow.app',
      );
      expect(service.isConfigured, isTrue);
      expect(service.usesProxy, isTrue);
      expect(service.proxyUrl, 'https://ai-proxy.ironflow.app');
      expect(() => service.validateConfiguration(), returnsNormally);
    });

    test('routes request to secure proxy with Authorization Bearer header', () async {
      final sampleResponse = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'Focus on progressive overload with 2.5kg jumps.'}
              ]
            }
          }
        ]
      };

      final fakeClient = FakeHttpClient(
        http.Response(jsonEncode(sampleResponse), 200, headers: {'content-type': 'application/json'}),
      );

      final service = GeminiAIService(
        apiKey: '',
        proxyUrl: 'https://ai-proxy.ironflow.app',
        authTokenProvider: () async => 'test_firebase_jwt_token_123',
        httpClient: fakeClient,
      );

      final result = await service.sendMessage([
        {'role': 'user', 'content': 'How to bench 100kg?'}
      ]);

      expect(result, 'Focus on progressive overload with 2.5kg jumps.');

      // Verify outbound request URL and headers
      expect(fakeClient.capturedRequest, isNotNull);
      expect(
        fakeClient.capturedRequest!.url.toString(),
        'https://ai-proxy.ironflow.app/generate',
      );
      expect(
        fakeClient.capturedRequest!.headers['Authorization'],
        'Bearer test_firebase_jwt_token_123',
      );
      expect(
        fakeClient.capturedRequest!.headers['Content-Type'],
        'application/json',
      );
      // Client API key is NOT in the query parameters
      expect(fakeClient.capturedRequest!.url.queryParameters.containsKey('key'), isFalse);
    });

    test('routes to direct Gemini endpoint when proxyUrl is empty', () async {
      final sampleResponse = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'Direct response text.'}
              ]
            }
          }
        ]
      };

      final fakeClient = FakeHttpClient(
        http.Response(jsonEncode(sampleResponse), 200, headers: {'content-type': 'application/json'}),
      );

      final service = GeminiAIService(
        apiKey: 'local_dev_key_abc',
        proxyUrl: '',
        httpClient: fakeClient,
      );

      final result = await service.sendMessage([
        {'role': 'user', 'content': 'Direct test'}
      ]);

      expect(result, 'Direct response text.');
      expect(fakeClient.capturedRequest, isNotNull);
      expect(
        fakeClient.capturedRequest!.url.toString().contains('generativelanguage.googleapis.com'),
        isTrue,
      );
      expect(
        fakeClient.capturedRequest!.url.queryParameters['key'],
        'local_dev_key_abc',
      );
      expect(
        fakeClient.capturedRequest!.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test('direct key is rejected when direct-key policy is disabled', () {
      final service = GeminiAIService(
        apiKey: 'release_like_key',
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
            'DIRECT_API_KEY_DISABLED',
          ),
        ),
      );
    });

    test('handles HTTP 429 quota exhaustion gracefully', () async {
      final fakeClient = FakeHttpClient(
        http.Response('{"error": "Quota exceeded"}', 429),
      );

      final service = GeminiAIService(
        apiKey: '',
        proxyUrl: 'https://ai-proxy.ironflow.app',
        httpClient: fakeClient,
      );

      expect(
        () => service.sendMessage([{'role': 'user', 'content': 'Hello'}]),
        throwsA(
          isA<GeminiAIServiceException>()
              .having((e) => e.code, 'code', 'RATE_LIMIT_EXCEEDED'),
        ),
      );
    });

    test('handles HTTP 401 unauthorized gracefully', () async {
      final fakeClient = FakeHttpClient(
        http.Response('{"error": "Unauthorized"}', 401),
      );

      final service = GeminiAIService(
        apiKey: '',
        proxyUrl: 'https://ai-proxy.ironflow.app',
        httpClient: fakeClient,
      );

      expect(
        () => service.sendMessage([{'role': 'user', 'content': 'Hello'}]),
        throwsA(
          isA<GeminiAIServiceException>()
              .having((e) => e.code, 'code', 'UNAUTHORIZED'),
        ),
      );
    });
  });
}
