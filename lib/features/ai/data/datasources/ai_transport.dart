/// Transport abstraction for AI coaching requests (Wave 1 Step 6 & Wave 7.1 — ADR-001).
///
/// Decouples presentation notifiers (`AIChatNotifier`, `GlobalAINotifier`)
/// from the underlying HTTP mechanism so production builds route exclusively
/// through the authenticated Firebase Cloud Functions proxy while unit and
/// widget tests can inject deterministic mock/fake transports.
abstract class AiTransport {
  /// Unified default output token limit across proxy and client (Wave 7.1).
  static const int defaultMaxOutputTokens = 1024;

  /// Whether the transport is configured and ready to dispatch requests.
  bool get isConfigured;

  /// Whether requests are routed through the backend proxy rather than a
  /// debug-only developer API key.
  bool get usesProxy;

  /// Sends a multi-turn conversation and returns the assistant response text.
  Future<String> sendMessage(
    List<Map<String, String>> messages, {
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = defaultMaxOutputTokens,
  });

  /// Sends a multi-turn conversation and streams response chunks as they arrive
  /// over an HTTP `StreamedResponse` SSE connection.
  Stream<String> streamMessage(
    List<Map<String, String>> messages, {
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = defaultMaxOutputTokens,
  });
}
