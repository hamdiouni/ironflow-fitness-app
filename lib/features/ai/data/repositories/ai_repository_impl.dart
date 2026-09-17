import 'package:uuid/uuid.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_service.dart';

/// Implementation of AIRepository
class AIRepositoryImpl implements AIRepository {
  final AIService _aiService;
  final List<ChatMessage> _chatHistory = [];

  static const String _systemPrompt = '''You are an expert fitness coach with deep knowledge of:
- Strength training programming
- Nutrition science
- Body composition
- Performance optimization

You have access to the user's fitness data and must:
1. Provide personalized advice based on their data
2. Identify specific issues (e.g., "Your squat hasn't improved in 4 weeks")
3. Give actionable recommendations
4. Celebrate achievements
5. Never give generic advice

Keep responses concise and actionable. When suggesting changes, be specific about what to do and why.''';

  AIRepositoryImpl({required AIService aiService}) : _aiService = aiService;

  @override
  Future<AIResponse> sendMessage(
    String message, {
    String? context,
  }) async {
    try {
      // Save user message to history
      final userMessage = ChatMessage(
        id: const Uuid().v4(),
        role: 'user',
        content: message,
        timestamp: DateTime.now(),
      );
      _chatHistory.add(userMessage);

      // Build messages for API
      final messages = _chatHistory
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      // Add context if provided
      String finalSystemPrompt = _systemPrompt;
      if (context != null && context.isNotEmpty) {
        finalSystemPrompt += '\n\nUser Context:\n$context';
      }

      // Get response from AI service
      final responseText = await _aiService.sendMessage(
        messages,
        systemPrompt: finalSystemPrompt,
        temperature: 0.7,
        maxTokens: 2000,
      );

      // Save assistant message to history
      final assistantMessage = ChatMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        content: responseText,
        timestamp: DateTime.now(),
      );
      _chatHistory.add(assistantMessage);

      // Parse response
      return parseResponse(responseText);
    } on AIServiceException catch (e) {
      throw AIRepositoryException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw AIRepositoryException(
        message: 'Failed to send message: $e',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  @override
  Stream<String> streamMessage(
    String message, {
    String? context,
  }) async* {
    try {
      // Save user message to history
      final userMessage = ChatMessage(
        id: const Uuid().v4(),
        role: 'user',
        content: message,
        timestamp: DateTime.now(),
      );
      _chatHistory.add(userMessage);

      // Build messages for API
      final messages = _chatHistory
          .map((m) => {'role': m.role, 'content': m.content})
          .toList();

      // Add context if provided
      String finalSystemPrompt = _systemPrompt;
      if (context != null && context.isNotEmpty) {
        finalSystemPrompt += '\n\nUser Context:\n$context';
      }

      // Stream response from AI service
      String fullResponse = '';
      await for (final chunk in _aiService.streamMessage(
        messages,
        systemPrompt: finalSystemPrompt,
        temperature: 0.7,
        maxTokens: 2000,
      )) {
        fullResponse += chunk;
        yield chunk;
      }

      // Save assistant message to history
      final assistantMessage = ChatMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        content: fullResponse,
        timestamp: DateTime.now(),
      );
      _chatHistory.add(assistantMessage);
    } on AIServiceException catch (e) {
      throw AIRepositoryException(
        message: e.message,
        code: e.code,
      );
    } catch (e) {
      throw AIRepositoryException(
        message: 'Failed to stream message: $e',
        code: 'STREAM_ERROR',
      );
    }
  }

  @override
  Future<String> getContext() async {
    // TODO: Implement context building from user data
    // This will be implemented in task 5.2
    return '';
  }

  @override
  AIResponse parseResponse(
    String rawResponse, {
    AIResponseType messageType = AIResponseType.text,
  }) {
    // Basic parsing - can be enhanced to detect suggestions, etc.
    return AIResponse(
      id: const Uuid().v4(),
      type: messageType,
      text: rawResponse,
      suggestions: [],
      data: {},
      isActionable: false,
    );
  }

  @override
  Future<List<ChatMessage>> getChatHistory() async {
    return List.unmodifiable(_chatHistory);
  }

  @override
  Future<void> saveChatMessage(ChatMessage message) async {
    _chatHistory.add(message);
  }

  @override
  Future<void> clearChatHistory() async {
    _chatHistory.clear();
  }
}

/// Exception thrown by AI repository
class AIRepositoryException implements Exception {
  final String message;
  final String? code;

  AIRepositoryException({required this.message, this.code});

  @override
  String toString() => 'AIRepositoryException: $message${code != null ? ' (Code: $code)' : ''}';
}
