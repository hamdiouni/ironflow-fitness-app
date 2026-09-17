import '../entities/ai_response.dart';
import '../entities/chat_message.dart';

/// Repository interface for AI operations
abstract class AIRepository {
  /// Sends a message to the AI and gets a response
  /// 
  /// [message] - User message
  /// [context] - Optional context about user's fitness data
  Future<AIResponse> sendMessage(
    String message, {
    String? context,
  });

  /// Streams a message response from the AI
  /// 
  /// Returns a stream of response chunks
  Stream<String> streamMessage(
    String message, {
    String? context,
  });

  /// Gets the AI context based on user data
  /// 
  /// Gathers user profile, workouts, nutrition, etc.
  Future<String> getContext();

  /// Parses a raw AI response into structured format
  /// 
  /// [rawResponse] - Raw text response from AI
  /// [messageType] - Type of response expected
  AIResponse parseResponse(
    String rawResponse, {
    AIResponseType messageType = AIResponseType.text,
  });

  /// Gets chat history
  Future<List<ChatMessage>> getChatHistory();

  /// Saves a chat message
  Future<void> saveChatMessage(ChatMessage message);

  /// Clears chat history
  Future<void> clearChatHistory();
}
