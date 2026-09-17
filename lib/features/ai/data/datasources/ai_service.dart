import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Exception thrown when AI service encounters an error
class AIServiceException implements Exception {
  final String message;
  final String? code;

  AIServiceException({required this.message, this.code});

  @override
  String toString() => 'AIServiceException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// AI Service for communicating with OpenAI API
class AIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-4';
  static const int _timeoutSeconds = 30;

  final String _apiKey;
  final http.Client _httpClient;

  AIService({
    String? apiKey,
    http.Client? httpClient,
  })  : _apiKey = apiKey ?? dotenv.env['OPENAI_API_KEY'] ?? '',
        _httpClient = httpClient ?? http.Client();

  /// Validates that API key is configured
  void validateConfiguration() {
    if (_apiKey.isEmpty) {
      throw AIServiceException(
        message: 'OpenAI API key not configured. Set OPENAI_API_KEY in .env file.',
        code: 'MISSING_API_KEY',
      );
    }
  }

  /// Sends a message to OpenAI and returns the response
  /// 
  /// [messages] - List of message objects with 'role' and 'content'
  /// [systemPrompt] - Optional system prompt to set AI behavior
  /// [temperature] - Controls randomness (0.0-2.0, default 0.7)
  /// [maxTokens] - Maximum tokens in response (default 2000)
  Future<String> sendMessage(
    List<Map<String, String>> messages, {
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = 2000,
  }) async {
    validateConfiguration();

    final requestMessages = <Map<String, String>>[
      if (systemPrompt != null)
        {'role': 'system', 'content': systemPrompt},
      ...messages,
    ];

    final requestBody = {
      'model': _model,
      'messages': requestMessages,
      'temperature': temperature,
      'max_tokens': maxTokens,
    };

    try {
      final response = await _httpClient
          .post(
            Uri.parse('$_baseUrl/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            Duration(seconds: _timeoutSeconds),
            onTimeout: () => throw AIServiceException(
              message: 'Request timeout after $_timeoutSeconds seconds',
              code: 'TIMEOUT',
            ),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List<dynamic>?;
        
        if (choices == null || choices.isEmpty) {
          throw AIServiceException(
            message: 'No response choices returned from API',
            code: 'EMPTY_RESPONSE',
          );
        }

        final message = choices[0]['message']['content'] as String?;
        if (message == null) {
          throw AIServiceException(
            message: 'No message content in response',
            code: 'MISSING_CONTENT',
          );
        }

        return message;
      } else if (response.statusCode == 401) {
        throw AIServiceException(
          message: 'Invalid API key',
          code: 'INVALID_API_KEY',
        );
      } else if (response.statusCode == 429) {
        throw AIServiceException(
          message: 'Rate limit exceeded. Please try again later.',
          code: 'RATE_LIMIT',
        );
      } else if (response.statusCode == 500) {
        throw AIServiceException(
          message: 'OpenAI service error. Please try again later.',
          code: 'SERVICE_ERROR',
        );
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['error']?['message'] as String? ?? 'Unknown error';
        throw AIServiceException(
          message: errorMessage,
          code: 'HTTP_ERROR_${response.statusCode}',
        );
      }
    } on AIServiceException {
      rethrow;
    } catch (e) {
      throw AIServiceException(
        message: 'Unexpected error: $e',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Sends a message and streams the response
  /// 
  /// Returns a stream of response chunks
  Stream<String> streamMessage(
    List<Map<String, String>> messages, {
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = 2000,
  }) async* {
    validateConfiguration();

    final requestMessages = <Map<String, String>>[
      if (systemPrompt != null)
        {'role': 'system', 'content': systemPrompt},
      ...messages,
    ];

    final requestBody = {
      'model': _model,
      'messages': requestMessages,
      'temperature': temperature,
      'max_tokens': maxTokens,
      'stream': true,
    };

    try {
      final request = http.Request(
        'POST',
        Uri.parse('$_baseUrl/chat/completions'),
      );

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      });

      request.body = jsonEncode(requestBody);

      final streamedResponse = await _httpClient.send(request).timeout(
        Duration(seconds: _timeoutSeconds),
        onTimeout: () => throw AIServiceException(
          message: 'Request timeout after $_timeoutSeconds seconds',
          code: 'TIMEOUT',
        ),
      );

      if (streamedResponse.statusCode != 200) {
        final body = await streamedResponse.stream.bytesToString();
        final errorData = jsonDecode(body) as Map<String, dynamic>;
        final errorMessage = errorData['error']?['message'] as String? ?? 'Unknown error';
        throw AIServiceException(
          message: errorMessage,
          code: 'HTTP_ERROR_${streamedResponse.statusCode}',
        );
      }

      await for (final chunk in streamedResponse.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.isEmpty || line == '[DONE]') continue;
          if (!line.startsWith('data: ')) continue;

          try {
            final jsonStr = line.substring(6);
            final data = jsonDecode(jsonStr) as Map<String, dynamic>;
            final choices = data['choices'] as List<dynamic>?;
            
            if (choices != null && choices.isNotEmpty) {
              final delta = choices[0]['delta'] as Map<String, dynamic>?;
              final content = delta?['content'] as String?;
              if (content != null) {
                yield content;
              }
            }
          } catch (e) {
            // Skip malformed lines
            continue;
          }
        }
      }
    } on AIServiceException {
      rethrow;
    } catch (e) {
      throw AIServiceException(
        message: 'Unexpected error during streaming: $e',
        code: 'STREAM_ERROR',
      );
    }
  }
}
