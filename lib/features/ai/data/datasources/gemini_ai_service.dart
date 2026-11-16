import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:progression_tracker/core/config/app_config.dart';
import 'package:progression_tracker/core/services/app_check_service.dart';
import 'ai_transport.dart';

/// Exception thrown when Gemini AI service encounters an error
class GeminiAIServiceException implements Exception {
  final String message;
  final String? code;

  GeminiAIServiceException({required this.message, this.code});

  @override
  String toString() =>
      'GeminiAIServiceException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// AI Service with dual routing: secure backend proxy (production, AI-01 / ADR-001)
/// and direct Gemini Developer API for local debug development only.
///
/// Benefits:
/// - Client-side token protection via serverless Cloud Functions proxy
/// - Per-user durable rate limiting in Firestore
/// - Firebase Auth JWT + Firebase App Check attestation headers
/// - Direct API fallback is fail-closed outside debug builds
class GeminiAIService implements AiTransport {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _model = 'gemini-2.5-flash';
  static const int _timeoutSeconds = 30;
  static const int maxPromptChars = 8000;
  static const int maxMessagesCount = 20;

  final String _apiKey;
  final String _proxyUrl;
  final bool _allowDirectApiKey;
  final Future<String?> Function()? _authTokenProvider;
  final Future<String?> Function()? _appCheckTokenProvider;
  final bool Function()? _isAiCoachEnabled;
  final http.Client _httpClient;

  GeminiAIService({
    String? apiKey,
    String? proxyUrl,
    bool? allowDirectApiKey,
    Future<String?> Function()? authTokenProvider,
    Future<String?> Function()? appCheckTokenProvider,
    bool Function()? isAiCoachEnabled,
    http.Client? httpClient,
  })  : _apiKey = apiKey ?? AppConfig.getGeminiApiKey(),
        _proxyUrl = proxyUrl ?? AppConfig.getAiProxyUrl(),
        _allowDirectApiKey =
            allowDirectApiKey ?? AppConfig.allowDirectAiApiKeys,
        _authTokenProvider = authTokenProvider,
        _appCheckTokenProvider = appCheckTokenProvider,
        _isAiCoachEnabled = isAiCoachEnabled,
        _httpClient = httpClient ?? http.Client();

  bool get _hasUsableDirectKey => _allowDirectApiKey && _apiKey.isNotEmpty;
  bool get allowDirectApiKey => _allowDirectApiKey;

  /// Whether a usable Gemini route is configured under build policy.
  @override
  bool get isConfigured => _proxyUrl.isNotEmpty || _hasUsableDirectKey;

  /// Whether requests are routed through a secure backend proxy (AI-01)
  @override
  bool get usesProxy => _proxyUrl.isNotEmpty;

  /// The active proxy URL
  String get proxyUrl => _proxyUrl;

  /// Validates that service is configured
  void validateConfiguration() {
    if (_proxyUrl.isEmpty && _apiKey.isNotEmpty && !_allowDirectApiKey) {
      throw GeminiAIServiceException(
        message: 'Direct Gemini API keys are disabled outside debug builds. '
            'Configure AI_PROXY_URL for profile/release.',
        code: 'DIRECT_API_KEY_DISABLED',
      );
    }
    if (!isConfigured) {
      throw GeminiAIServiceException(
        message: 'Gemini AI service not configured. Configure AI_PROXY_URL '
            '(or a debug-only GEMINI_API_KEY for local development).',
        code: 'MISSING_API_KEY',
      );
    }
  }

  Future<String?> _getAuthToken() async {
    if (_authTokenProvider != null) {
      try {
        return await _authTokenProvider();
      } catch (_) {}
    }
    try {
      return await FirebaseAuth.instance.currentUser?.getIdToken();
    } catch (_) {}
    return null;
  }

  Future<String?> _getAppCheckToken() async {
    if (_appCheckTokenProvider != null) {
      try {
        return await _appCheckTokenProvider();
      } catch (_) {}
    }
    return AppCheckService.getToken();
  }

  void _validateInputBounds(List<Map<String, String>> messages) {
    if (messages.isEmpty) {
      throw GeminiAIServiceException(
        message: 'Cannot send an empty message list.',
        code: 'EMPTY_CONTENTS',
      );
    }
    if (messages.length > maxMessagesCount) {
      throw GeminiAIServiceException(
        message:
            'Conversation history exceeds maximum of $maxMessagesCount messages.',
        code: 'PAYLOAD_TOO_LARGE',
      );
    }
    for (final msg in messages) {
      final content = msg['content'] ?? '';
      if (content.length > maxPromptChars) {
        throw GeminiAIServiceException(
          message:
              'Message exceeds maximum length of $maxPromptChars characters.',
          code: 'PAYLOAD_TOO_LARGE',
        );
      }
    }
  }

  /// Sends a message to Gemini (via Proxy or Direct API) and returns the response
  @override
  Future<String> sendMessage(
    List<Map<String, String>> messages, {
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = 8000,
  }) async {
    if (_isAiCoachEnabled != null && !_isAiCoachEnabled()) {
      throw GeminiAIServiceException(
        message: 'AI Coach is temporarily disabled by operator configuration.',
        code: 'FEATURE_DISABLED',
      );
    }
    validateConfiguration();
    _validateInputBounds(messages);

    // Convert messages to Gemini format
    final geminiMessages = _convertToGeminiFormat(messages, systemPrompt);

    final requestBody = <String, dynamic>{
      'model': _model,
      'contents': geminiMessages,
      'generationConfig': {
        'temperature': temperature,
        'maxOutputTokens': maxTokens,
        'topP': 0.95,
        'topK': 40,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_NONE',
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_NONE',
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_NONE',
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_NONE',
        },
      ],
    };

    final Uri targetUri;
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (usesProxy) {
      final cleanProxy = _proxyUrl.trim();
      targetUri = Uri.parse(cleanProxy.endsWith('/generate') ||
              cleanProxy.endsWith('/aiGenerate')
          ? cleanProxy
          : cleanProxy.endsWith('/')
              ? '${cleanProxy}generate'
              : '$cleanProxy/generate');

      final token = await _getAuthToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final appCheckToken = await _getAppCheckToken();
      if (appCheckToken != null && appCheckToken.isNotEmpty) {
        headers['X-Firebase-AppCheck'] = appCheckToken;
      }
      if (kDebugMode) {
        debugPrint(
            '🔒 [GEMINI SERVICE] Routing request via secure proxy: $targetUri');
      }
    } else {
      requestBody.remove('model');
      targetUri =
          Uri.parse('$_baseUrl/models/$_model:generateContent?key=$_apiKey');
      if (kDebugMode) {
        debugPrint(
            '🌐 [GEMINI SERVICE] Routing request directly to Google Gemini API');
      }
    }

    try {
      final response = await _httpClient
          .post(
            targetUri,
            headers: headers,
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: _timeoutSeconds),
            onTimeout: () {
              throw GeminiAIServiceException(
                message: 'Request timeout after $_timeoutSeconds seconds',
                code: 'TIMEOUT',
              );
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Extract response text
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          throw GeminiAIServiceException(
            message: 'No response candidates returned from API',
            code: 'EMPTY_RESPONSE',
          );
        }

        final content = candidates[0]['content'] as Map<String, dynamic>?;
        if (content == null) {
          throw GeminiAIServiceException(
            message: 'No content in response',
            code: 'MISSING_CONTENT',
          );
        }

        final parts = content['parts'] as List<dynamic>?;
        if (parts == null || parts.isEmpty) {
          throw GeminiAIServiceException(
            message: 'No parts in content',
            code: 'MISSING_PARTS',
          );
        }

        final text = parts[0]['text'] as String?;
        if (text == null) {
          throw GeminiAIServiceException(
            message: 'No text in response',
            code: 'MISSING_TEXT',
          );
        }

        return text;
      } else if (response.statusCode == 429) {
        throw GeminiAIServiceException(
          message:
              'AI request limit reached. Daily token quota resets at midnight UTC.',
          code: 'RATE_LIMIT_EXCEEDED',
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw GeminiAIServiceException(
          message:
              'AI proxy authorization failed. Please check your credentials.',
          code: 'UNAUTHORIZED',
        );
      } else {
        String errorMessage =
            'API request failed with status: ${response.statusCode}';
        String? errorCode;

        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          final error = errorData['error'] as Map<String, dynamic>?;
          if (error != null) {
            errorMessage = error['message'] as String? ?? errorMessage;
            errorCode =
                (error['code'] ?? error['status'])?.toString();
          }
        } catch (_) {}

        throw GeminiAIServiceException(
          message: errorMessage,
          code: errorCode ?? 'HTTP_${response.statusCode}',
        );
      }
    } on GeminiAIServiceException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [GEMINI SERVICE ERROR] Unexpected exception: $e');
      }
      throw GeminiAIServiceException(
        message: 'Failed to communicate with AI service: $e',
        code: 'NETWORK_ERROR',
      );
    }
  }

  /// Extracts text chunks from a Server-Sent Events (SSE) payload returned
  /// by the Cloud Functions AI proxy when `stream: true` is used.
  static List<String> parseSseChunks(String rawBody) {
    final chunks = <String>[];
    for (final line in rawBody.split('\n')) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('data:')) continue;
      final payload = trimmed.substring(5).trim();
      if (payload.isEmpty || payload == '[DONE]') continue;
      try {
        final decoded = jsonDecode(payload) as Map<String, dynamic>;
        final candidates = decoded['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) continue;
        final content =
            candidates.first['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        if (parts == null || parts.isEmpty) continue;
        final text = parts.first['text'] as String?;
        if (text != null && text.isNotEmpty) {
          chunks.add(text);
        }
      } catch (_) {}
    }
    return chunks;
  }

  /// Converts messages array to Gemini API format
  List<Map<String, dynamic>> _convertToGeminiFormat(
    List<Map<String, String>> messages,
    String? systemPrompt,
  ) {
    final geminiMessages = <Map<String, dynamic>>[];

    // Add system prompt as first user message if provided
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      geminiMessages.add({
        'role': 'user',
        'parts': [
          {
            'text':
                'System instructions: $systemPrompt\n\nPlease follow these instructions in all your responses.'
          }
        ],
      });
      geminiMessages.add({
        'role': 'model',
        'parts': [
          {'text': 'Understood. I will follow these instructions.'}
        ],
      });
    }

    // Convert messages
    for (final message in messages) {
      final role = message['role'];
      final content = message['content'];

      if (role == 'system') {
        geminiMessages.add({
          'role': 'user',
          'parts': [
            {'text': 'System: $content'}
          ],
        });
        geminiMessages.add({
          'role': 'model',
          'parts': [
            {'text': 'Understood.'}
          ],
        });
      } else if (role == 'user') {
        geminiMessages.add({
          'role': 'user',
          'parts': [
            {'text': content}
          ],
        });
      } else if (role == 'assistant') {
        geminiMessages.add({
          'role': 'model',
          'parts': [
            {'text': content}
          ],
        });
      }
    }

    return geminiMessages;
  }

  /// Sends a message and streams the response
  @override
  Stream<String> streamMessage(
    List<Map<String, String>> messages, {
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = 8000,
  }) async* {
    final response = await sendMessage(
      messages,
      systemPrompt: systemPrompt,
      temperature: temperature,
      maxTokens: maxTokens,
    );

    yield response;
  }
}
