import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Exception thrown when Gemini AI service encounters an error
class GeminiAIServiceException implements Exception {
  final String message;
  final String? code;

  GeminiAIServiceException({required this.message, this.code});

  @override
  String toString() => 'GeminiAIServiceException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// FREE AI Service using Google Gemini API
/// 
/// Benefits:
/// - Completely FREE (60 requests/min)
/// - No credit card required
/// - High quality responses
/// - Easy to set up
/// 
/// Get your free API key: https://makersuite.google.com/app/apikey
class GeminiAIService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String _model = 'gemini-2.5-flash'; // Latest fast & free model
  static const int _timeoutSeconds = 30;

  final String _apiKey;
  final http.Client _httpClient;

  GeminiAIService({
    String? apiKey,
    http.Client? httpClient,
  })  : _apiKey = apiKey ?? dotenv.env['GEMINI_API_KEY'] ?? '',
        _httpClient = httpClient ?? http.Client();

  /// Validates that API key is configured
  void validateConfiguration() {
    if (_apiKey.isEmpty) {
      throw GeminiAIServiceException(
        message: 'Gemini API key not configured. Set GEMINI_API_KEY in .env file.\n'
            'Get your free key at: https://makersuite.google.com/app/apikey',
        code: 'MISSING_API_KEY',
      );
    }
  }

  /// Sends a message to Gemini and returns the response
  /// 
  /// [messages] - List of message objects with 'role' and 'content'
  /// [systemPrompt] - Optional system prompt to set AI behavior
  /// [temperature] - Controls randomness (0.0-2.0, default 0.7)
  /// [maxTokens] - Maximum tokens in response (default 8000)
  Future<String> sendMessage(
    List<Map<String, String>> messages, {
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = 8000, // Increased from 2000 to 8000
  }) async {
    print('═══════════════════════════════════════');
    print('🔧 [GEMINI SERVICE] Starting API call');
    print('═══════════════════════════════════════');
    
    try {
      print('🔑 [GEMINI SERVICE] Validating API key...');
      validateConfiguration();
      print('✅ [GEMINI SERVICE] API key validated');
    } catch (e) {
      print('❌ [GEMINI SERVICE ERROR] API key validation failed: $e');
      rethrow;
    }

    // Convert messages to Gemini format
    print('🔄 [GEMINI SERVICE] Converting messages to Gemini format...');
    final geminiMessages = _convertToGeminiFormat(messages, systemPrompt);
    print('✅ [GEMINI SERVICE] Converted ${geminiMessages.length} messages');

    final requestBody = {
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

    print('📦 [GEMINI SERVICE] Request body prepared');
    print('🌐 [GEMINI SERVICE] API URL: $_baseUrl/models/$_model:generateContent');

    try {
      print('📡 [GEMINI SERVICE] Sending HTTP POST request...');
      final response = await _httpClient
          .post(
            Uri.parse('$_baseUrl/models/$_model:generateContent?key=$_apiKey'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            Duration(seconds: _timeoutSeconds),
            onTimeout: () {
              print('⏰ [GEMINI SERVICE ERROR] Request timeout after $_timeoutSeconds seconds');
              throw GeminiAIServiceException(
                message: 'Request timeout after $_timeoutSeconds seconds',
                code: 'TIMEOUT',
              );
            },
          );

      print('📨 [GEMINI SERVICE] Response received');
      print('📊 [GEMINI SERVICE] Status code: ${response.statusCode}');
      print('📏 [GEMINI SERVICE] Response length: ${response.body.length} bytes');

      if (response.statusCode == 200) {
        print('✅ [GEMINI SERVICE] Success! Parsing response...');
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Extract response text
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) {
          print('❌ [GEMINI SERVICE ERROR] No response candidates');
          throw GeminiAIServiceException(
            message: 'No response candidates returned from API',
            code: 'EMPTY_RESPONSE',
          );
        }

        final content = candidates[0]['content'] as Map<String, dynamic>?;
        if (content == null) {
          print('❌ [GEMINI SERVICE ERROR] No content in response');
          throw GeminiAIServiceException(
            message: 'No content in response',
            code: 'MISSING_CONTENT',
          );
        }

        final parts = content['parts'] as List<dynamic>?;
        if (parts == null || parts.isEmpty) {
          print('❌ [GEMINI SERVICE ERROR] No parts in content');
          throw GeminiAIServiceException(
            message: 'No parts in content',
            code: 'MISSING_PARTS',
          );
        }

        final text = parts[0]['text'] as String?;
        if (text == null) {
          print('❌ [GEMINI SERVICE ERROR] No text in response');
          throw GeminiAIServiceException(
            message: 'No text in response',
            code: 'MISSING_TEXT',
          );
        }

        print('═══════════════════════════════════════');
        print('🎉 [GEMINI SERVICE] Success!');
        print('📝 [GEMINI SERVICE] Response text length: ${text.length} chars');
        print('💬 [GEMINI SERVICE] Preview: ${text.substring(0, text.length > 100 ? 100 : text.length)}...');
        print('═══════════════════════════════════════');
        
        return text;
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['error']?['message'] as String? ?? 'Invalid request';
        print('❌ [GEMINI SERVICE ERROR] 400 Bad Request: $errorMessage');
        print('📄 [GEMINI SERVICE ERROR] Full response: ${response.body}');
        throw GeminiAIServiceException(
          message: errorMessage,
          code: 'INVALID_REQUEST',
        );
      } else if (response.statusCode == 403) {
        print('❌ [GEMINI SERVICE ERROR] 403 Forbidden - Invalid API key');
        print('🔑 [GEMINI SERVICE ERROR] API key used: ${_apiKey.substring(0, 20)}...');
        throw GeminiAIServiceException(
          message: 'Invalid API key or API not enabled.\n'
              'Get your free key at: https://makersuite.google.com/app/apikey',
          code: 'INVALID_API_KEY',
        );
      } else if (response.statusCode == 429) {
        print('❌ [GEMINI SERVICE ERROR] 429 Rate Limit Exceeded');
        print('⏰ [GEMINI SERVICE ERROR] Free tier: 60 requests/min');
        throw GeminiAIServiceException(
          message: 'Rate limit exceeded. Free tier: 60 requests/min.\n'
              'Wait a moment and try again.',
          code: 'RATE_LIMIT',
        );
      } else if (response.statusCode == 500) {
        print('❌ [GEMINI SERVICE ERROR] 500 Internal Server Error');
        throw GeminiAIServiceException(
          message: 'Gemini service error. Please try again later.',
          code: 'SERVICE_ERROR',
        );
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['error']?['message'] as String? ?? 'Unknown error';
        print('❌ [GEMINI SERVICE ERROR] HTTP ${response.statusCode}: $errorMessage');
        print('📄 [GEMINI SERVICE ERROR] Full response: ${response.body}');
        throw GeminiAIServiceException(
          message: errorMessage,
          code: 'HTTP_ERROR_${response.statusCode}',
        );
      }
    } on GeminiAIServiceException {
      rethrow;
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════');
      print('❌❌❌ [GEMINI SERVICE FATAL ERROR] ❌❌❌');
      print('🔴 [GEMINI SERVICE ERROR] Error type: ${e.runtimeType}');
      print('🔴 [GEMINI SERVICE ERROR] Error message: $e');
      print('🔴 [GEMINI SERVICE ERROR] Stack trace:');
      print(stackTrace.toString().split('\n').take(15).join('\n'));
      print('═══════════════════════════════════════');
      throw GeminiAIServiceException(
        message: 'Unexpected error: $e',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Converts OpenAI-style messages to Gemini format
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
          {'text': 'System instructions: $systemPrompt\n\nPlease follow these instructions in all your responses.'}
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
        // Add system messages as user messages
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
  /// 
  /// Note: Gemini streaming requires different endpoint
  /// For now, this returns the full response as a single chunk
  Stream<String> streamMessage(
    List<Map<String, String>> messages, {
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = 8000, // Increased from 2000 to 8000
  }) async* {
    // For simplicity, return full response as single chunk
    // TODO: Implement proper streaming with streamGenerateContent endpoint
    final response = await sendMessage(
      messages,
      systemPrompt: systemPrompt,
      temperature: temperature,
      maxTokens: maxTokens,
    );
    
    yield response;
  }
}
