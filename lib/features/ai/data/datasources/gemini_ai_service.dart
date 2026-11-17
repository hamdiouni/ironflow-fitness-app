import 'dart:async';
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
/// Wave 7.1 upgrades:
/// - Real `StreamedResponse` SSE chunk streaming (`streamMessage`)
/// - Native `systemInstruction` payload field instead of synthetic user/model turns
/// - Unified `defaultMaxOutputTokens = 1024`
/// - Responsible `BLOCK_MEDIUM_AND_ABOVE` safety thresholds (never `BLOCK_NONE`)
class GeminiAIService implements AiTransport {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String _model = 'gemini-2.5-flash';
  static const int _timeoutSeconds = 30;
  static const int maxPromptChars = 8000;
  static const int maxMessagesCount = 20;
  static const int defaultMaxOutputTokens = AiTransport.defaultMaxOutputTokens;

  /// Responsible safety thresholds enforced across all requests (Wave 7.1).
  static const List<Map<String, String>> defaultSafetySettings = [
    {
      'category': 'HARM_CATEGORY_HARASSMENT',
      'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
    },
    {
      'category': 'HARM_CATEGORY_HATE_SPEECH',
      'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
    },
    {
      'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
      'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
    },
    {
      'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
      'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
    },
  ];

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

  /// Checks whether an auth token is currently available when proxy mode is active.
  /// Used to avoid firing guaranteed-401 requests when offline or unauthenticated.
  Future<bool> hasAvailableAuthForProxy() async {
    if (!usesProxy) return true;
    final token = await _getAuthToken();
    return token != null && token.trim().isNotEmpty;
  }

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

  void _validateInputBounds(
    List<Map<String, String>> messages, {
    String? systemPrompt,
  }) {
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
    if (systemPrompt != null && systemPrompt.length > maxPromptChars) {
      throw GeminiAIServiceException(
        message:
            'System instruction exceeds maximum length of $maxPromptChars characters.',
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

  Map<String, dynamic> _buildRequestBody({
    required List<Map<String, String>> messages,
    String? systemPrompt,
    required double temperature,
    required int maxTokens,
    bool stream = false,
  }) {
    final (contents, combinedSystemText) = _convertToGeminiFormat(
      messages,
      systemPrompt,
    );

    final body = <String, dynamic>{
      'model': _model,
      if (stream) 'stream': true,
      'contents': contents,
      if (combinedSystemText != null && combinedSystemText.isNotEmpty)
        'systemInstruction': {
          'parts': [
            {'text': combinedSystemText},
          ],
        },
      'generationConfig': {
        'temperature': temperature,
        'maxOutputTokens': maxTokens,
        'topP': 0.95,
        'topK': 40,
      },
      'safetySettings': defaultSafetySettings,
    };
    return body;
  }

  Future<(Uri, Map<String, String>)> _resolveTargetUriAndHeaders(
    Map<String, dynamic> requestBody, {
    required bool stream,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (stream) 'Accept': 'text/event-stream',
    };

    final Uri targetUri;
    if (usesProxy) {
      final cleanProxy = _proxyUrl.trim();
      targetUri = Uri.parse(
        cleanProxy.endsWith('/generate') || cleanProxy.endsWith('/aiGenerate')
            ? cleanProxy
            : cleanProxy.endsWith('/')
                ? '${cleanProxy}generate'
                : '$cleanProxy/generate',
      );

      final token = await _getAuthToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final appCheckToken = await _getAppCheckToken();
      if (appCheckToken != null && appCheckToken.isNotEmpty) {
        headers['X-Firebase-AppCheck'] = appCheckToken;
      }
    } else {
      requestBody.remove('model');
      requestBody.remove('stream');
      final action =
          stream ? 'streamGenerateContent?alt=sse&' : 'generateContent?';
      targetUri = Uri.parse('$_baseUrl/models/$_model:${action}key=$_apiKey');
    }

    return (targetUri, headers);
  }

  static String _extractCandidateText(Map<String, dynamic> data) {
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
  }

  Never _throwMappedHttpError(int statusCode, String rawBody) {
    if (statusCode == 429) {
      throw GeminiAIServiceException(
        message:
            'AI request limit reached. Daily token quota resets at midnight UTC.',
        code: 'RATE_LIMIT_EXCEEDED',
      );
    }
    if (statusCode == 401 || statusCode == 403) {
      throw GeminiAIServiceException(
        message:
            'AI proxy authorization failed. Please check your credentials.',
        code: 'UNAUTHORIZED',
      );
    }

    var errorMessage = 'API request failed with status: $statusCode';
    String? errorCode;
    try {
      final errorData = jsonDecode(rawBody) as Map<String, dynamic>;
      final error = errorData['error'] as Map<String, dynamic>?;
      if (error != null) {
        errorMessage = error['message'] as String? ?? errorMessage;
        errorCode = (error['code'] ?? error['status'])?.toString();
      }
    } catch (_) {}

    throw GeminiAIServiceException(
      message: errorMessage,
      code: errorCode ?? 'HTTP_$statusCode',
    );
  }

  /// Sends a message to Gemini (via Proxy or Direct API) and returns the response
  @override
  Future<String> sendMessage(
    List<Map<String, String>> messages, {
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = defaultMaxOutputTokens,
  }) async {
    if (_isAiCoachEnabled != null && !_isAiCoachEnabled()) {
      throw GeminiAIServiceException(
        message: 'AI Coach is temporarily disabled by operator configuration.',
        code: 'FEATURE_DISABLED',
      );
    }
    validateConfiguration();
    _validateInputBounds(messages, systemPrompt: systemPrompt);

    final requestBody = _buildRequestBody(
      messages: messages,
      systemPrompt: systemPrompt,
      temperature: temperature,
      maxTokens: maxTokens,
    );
    final (targetUri, headers) = await _resolveTargetUriAndHeaders(
      requestBody,
      stream: false,
    );

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
        return _extractCandidateText(data);
      }
      _throwMappedHttpError(response.statusCode, response.body);
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

  /// Sends a transient meal photo (base64 in memory, never persisted to disk or
  /// Cloud Storage) through the proxy for macro estimation (Wave 7.3 — ADR-003).
  Future<String> estimateMealFromPhoto({
    required String base64Image,
    String mimeType = 'image/jpeg',
    String prompt =
        'Estimate the meal items, portion size, calories, protein (g), carbs (g), and fats (g) in this photo. Return a JSON block inside ```json ... ``` with type "log_meal".',
    String? systemPrompt,
    int maxTokens = defaultMaxOutputTokens,
  }) async {
    if (_isAiCoachEnabled != null && !_isAiCoachEnabled()) {
      throw GeminiAIServiceException(
        message: 'AI Coach is temporarily disabled by operator configuration.',
        code: 'FEATURE_DISABLED',
      );
    }
    validateConfiguration();
    if (base64Image.trim().isEmpty) {
      throw GeminiAIServiceException(
        message: 'Meal photo payload cannot be empty.',
        code: 'INVALID_MEDIA_FORMAT',
      );
    }

    final requestBody = <String, dynamic>{
      'model': _model,
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'inlineData': {
                'mimeType': mimeType,
                'data': base64Image.trim(),
              },
            },
            {'text': prompt},
          ],
        },
      ],
      if (systemPrompt != null && systemPrompt.trim().isNotEmpty)
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt.trim()},
          ],
        },
      'generationConfig': {
        'temperature': 0.3,
        'maxOutputTokens': maxTokens,
        'topP': 0.95,
        'topK': 40,
      },
      'safetySettings': defaultSafetySettings,
    };

    final (targetUri, headers) = await _resolveTargetUriAndHeaders(
      requestBody,
      stream: false,
    );

    try {
      final response = await _httpClient
          .post(
            targetUri,
            headers: headers,
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return _extractCandidateText(data);
      }
      _throwMappedHttpError(response.statusCode, response.body);
    } on GeminiAIServiceException {
      rethrow;
    } catch (e) {
      throw GeminiAIServiceException(
        message: 'Failed to estimate meal from photo: $e',
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

  /// Converts messages array to Gemini API format and separates native
  /// `systemInstruction` text instead of injecting synthetic user/model turns.
  (List<Map<String, dynamic>>, String?) _convertToGeminiFormat(
    List<Map<String, String>> messages,
    String? systemPrompt,
  ) {
    final geminiMessages = <Map<String, dynamic>>[];
    final systemParts = <String>[];

    if (systemPrompt != null && systemPrompt.trim().isNotEmpty) {
      systemParts.add(systemPrompt.trim());
    }

    for (final message in messages) {
      final role = message['role'];
      final content = message['content'] ?? '';

      if (role == 'system') {
        if (content.trim().isNotEmpty) {
          systemParts.add(content.trim());
        }
      } else if (role == 'user') {
        geminiMessages.add({
          'role': 'user',
          'parts': [
            {'text': content},
          ],
        });
      } else if (role == 'assistant' || role == 'model') {
        geminiMessages.add({
          'role': 'model',
          'parts': [
            {'text': content},
          ],
        });
      }
    }

    final combinedSystem =
        systemParts.isEmpty ? null : systemParts.join('\n\n');
    return (geminiMessages, combinedSystem);
  }

  /// Sends a multi-turn conversation and streams response chunks incrementally
  /// by reading `http.StreamedResponse.stream` through [parseSseChunks] (Wave 7.1).
  @override
  Stream<String> streamMessage(
    List<Map<String, String>> messages, {
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = defaultMaxOutputTokens,
  }) async* {
    if (_isAiCoachEnabled != null && !_isAiCoachEnabled()) {
      throw GeminiAIServiceException(
        message: 'AI Coach is temporarily disabled by operator configuration.',
        code: 'FEATURE_DISABLED',
      );
    }
    validateConfiguration();
    _validateInputBounds(messages, systemPrompt: systemPrompt);

    final requestBody = _buildRequestBody(
      messages: messages,
      systemPrompt: systemPrompt,
      temperature: temperature,
      maxTokens: maxTokens,
      stream: true,
    );
    final (targetUri, headers) = await _resolveTargetUriAndHeaders(
      requestBody,
      stream: true,
    );

    final request = http.Request('POST', targetUri)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestBody);

    final http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await _httpClient.send(request).timeout(
        const Duration(seconds: _timeoutSeconds),
        onTimeout: () {
          throw GeminiAIServiceException(
            message: 'Request timeout after $_timeoutSeconds seconds',
            code: 'TIMEOUT',
          );
        },
      );
    } on GeminiAIServiceException {
      rethrow;
    } catch (e) {
      throw GeminiAIServiceException(
        message: 'Failed to communicate with AI service: $e',
        code: 'NETWORK_ERROR',
      );
    }

    if (streamedResponse.statusCode != 200) {
      final errBody = await streamedResponse.stream.bytesToString();
      _throwMappedHttpError(streamedResponse.statusCode, errBody);
    }

    final lineBuffer = StringBuffer();
    final rawAccumulator = StringBuffer();
    var yieldedAnySseChunk = false;

    try {
      await for (final chunk
          in streamedResponse.stream.transform(utf8.decoder)) {
        rawAccumulator.write(chunk);
        lineBuffer.write(chunk);
        final current = lineBuffer.toString();
        final lastNewline = current.lastIndexOf('\n');
        if (lastNewline == -1) continue;

        final completeLines = current.substring(0, lastNewline + 1);
        final remainder = current.substring(lastNewline + 1);
        lineBuffer
          ..clear()
          ..write(remainder);

        final parsed = parseSseChunks(completeLines);
        for (final piece in parsed) {
          yieldedAnySseChunk = true;
          yield piece;
        }
      }

      if (lineBuffer.isNotEmpty) {
        final parsed = parseSseChunks(lineBuffer.toString());
        for (final piece in parsed) {
          yieldedAnySseChunk = true;
          yield piece;
        }
      }

      // Fallback for non-SSE JSON responses (e.g. MockClient returning standard JSON)
      if (!yieldedAnySseChunk) {
        final fullRaw = rawAccumulator.toString().trim();
        if (fullRaw.isNotEmpty) {
          final data = jsonDecode(fullRaw) as Map<String, dynamic>;
          final text = _extractCandidateText(data);
          if (text.isNotEmpty) {
            yield text;
          }
        }
      }
    } on GeminiAIServiceException {
      rethrow;
    } catch (e) {
      throw GeminiAIServiceException(
        message: 'Failed while reading AI response stream: $e',
        code: 'NETWORK_ERROR',
      );
    }
  }
}
