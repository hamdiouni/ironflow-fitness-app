import 'package:uuid/uuid.dart';
import '../../domain/entities/ai_response.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_service.dart';

/// Implementation of AIRepository.
///
/// The repository deliberately does **not** gather personal data itself.
/// Callers may inject a [contextBuilder] only after applying their own
/// consent/privacy gate (for example, an adapter around
/// `BuildAIContextUseCase`). Without a builder, [getContext] returns an
/// empty string and prompts must not claim user-specific knowledge.
class AIRepositoryImpl implements AIRepository {
  final AIService _aiService;
  final Future<String> Function()? _contextBuilder;
  final List<ChatMessage> _chatHistory = [];

  static const String _systemPrompt = '''You are an expert fitness coach with deep knowledge of:
- Strength training programming
- Nutrition science
- Body composition
- Performance optimization

Use only facts present in the supplied user context. If no user context is
supplied, be transparent that you do not have this user's personal history,
avoid inventing user-specific observations, and give safe general guidance or
ask for the missing details. When context is supplied, be specific,
actionable, concise, and celebrate real achievements.''';

  AIRepositoryImpl({
    required AIService aiService,
    Future<String> Function()? contextBuilder,
  })  : _aiService = aiService,
        _contextBuilder = contextBuilder;

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
    final builder = _contextBuilder;
    if (builder == null) return '';
    try {
      return await builder();
    } catch (_) {
      // Context is optional enrichment. A failed personal-data gather must
      // not leak partial data or break a non-personalized chat.
      return '';
    }
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
