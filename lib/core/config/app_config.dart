import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized configuration provider for environment variables and API keys.
///
/// Prioritizes compile-time `--dart-define` constants (best practice for production
/// and CI/CD builds), falling back to local `flutter_dotenv` for convenience in
/// local development if a `.env` file is loaded.
class AppConfig {
  const AppConfig._();

  static const String _envOpenAiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String _envGeminiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _envNvidiaKey = String.fromEnvironment('NVIDIA_API_KEY');

  /// Retrieves OpenAI API Key from `--dart-define` or local dotenv.
  static String getOpenAIApiKey() {
    if (_envOpenAiKey.isNotEmpty) return _envOpenAiKey;
    if (dotenv.isInitialized) {
      return dotenv.env['OPENAI_API_KEY'] ?? '';
    }
    return '';
  }

  /// Retrieves Google Gemini API Key from `--dart-define` or local dotenv.
  static String getGeminiApiKey() {
    if (_envGeminiKey.isNotEmpty) return _envGeminiKey;
    if (dotenv.isInitialized) {
      return dotenv.env['GEMINI_API_KEY'] ?? '';
    }
    return '';
  }

  /// Retrieves NVIDIA API Key from `--dart-define` or local dotenv.
  static String getNvidiaApiKey() {
    if (_envNvidiaKey.isNotEmpty) return _envNvidiaKey;
    if (dotenv.isInitialized) {
      return dotenv.env['NVIDIA_API_KEY'] ?? '';
    }
    return '';
  }

  /// Whether OpenAI is configured with a non-empty key.
  static bool get hasOpenAI => getOpenAIApiKey().isNotEmpty;

  /// Whether Gemini is configured with a non-empty key.
  static bool get hasGemini => getGeminiApiKey().isNotEmpty;

  /// Whether NVIDIA is configured with a non-empty key.
  static bool get hasNvidia => getNvidiaApiKey().isNotEmpty;
}
