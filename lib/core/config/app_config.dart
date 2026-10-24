import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized configuration provider for environment variables and API keys.
///
/// Direct provider API keys are treated as **debug-only developer
/// credentials**: a key compiled into, or bundled with, a shipped client is
/// extractable and must never be the production credential. Profile/release
/// builds therefore fail closed and must use [getAiProxyUrl] (an
/// authenticated backend proxy that owns provider keys, quotas, and cost
/// controls). Local debug builds may still use `--dart-define` or dotenv keys
/// for developer convenience unless `ALLOW_DIRECT_AI_KEYS=false` is set.
class AppConfig {
  const AppConfig._();

  static const String _envOpenAiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const String _envGeminiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _envNvidiaKey = String.fromEnvironment('NVIDIA_API_KEY');
  static const String _envAiProxyUrl = String.fromEnvironment('AI_PROXY_URL');
  static const bool _directAiKeysOptIn = bool.fromEnvironment(
    'ALLOW_DIRECT_AI_KEYS',
    defaultValue: true,
  );

  /// Whether direct client-side provider keys may be used at all.
  ///
  /// Debug-only by design. This is intentionally not overridable in
  /// profile/release: setting `ALLOW_DIRECT_AI_KEYS=true` there still returns
  /// false, so a production artifact cannot accidentally ship a usable
  /// provider key path.
  static bool get allowDirectAiApiKeys => kDebugMode && _directAiKeysOptIn;

  static String _directKey(String envValue, String dotenvKey) {
    if (!allowDirectAiApiKeys) return '';
    if (envValue.isNotEmpty) return envValue;
    if (dotenv.isInitialized) {
      return dotenv.env[dotenvKey] ?? '';
    }
    return '';
  }

  /// Retrieves the debug-only OpenAI API key, or empty when direct keys are
  /// disabled (including every profile/release build).
  static String getOpenAIApiKey() =>
      _directKey(_envOpenAiKey, 'OPENAI_API_KEY');

  /// Retrieves the debug-only Gemini API key, or empty when direct keys are
  /// disabled. Production Gemini traffic must use [getAiProxyUrl].
  static String getGeminiApiKey() =>
      _directKey(_envGeminiKey, 'GEMINI_API_KEY');

  /// Retrieves the debug-only NVIDIA API key, or empty when direct keys are
  /// disabled.
  static String getNvidiaApiKey() =>
      _directKey(_envNvidiaKey, 'NVIDIA_API_KEY');

  /// Retrieves AI Backend Proxy URL from `--dart-define` or local dotenv.
  static String getAiProxyUrl() {
    if (_envAiProxyUrl.isNotEmpty) return _envAiProxyUrl;
    if (dotenv.isInitialized) {
      return dotenv.env['AI_PROXY_URL'] ?? '';
    }
    return '';
  }

  /// Whether OpenAI is configured through an allowed debug direct key.
  static bool get hasOpenAI => getOpenAIApiKey().isNotEmpty;

  /// Whether Gemini is configured through the proxy or an allowed debug key.
  static bool get hasGemini => hasAiProxy || getGeminiApiKey().isNotEmpty;

  /// Whether NVIDIA is configured through an allowed debug direct key.
  static bool get hasNvidia => getNvidiaApiKey().isNotEmpty;

  /// Whether a secure AI backend proxy URL is configured.
  static bool get hasAiProxy => getAiProxyUrl().isNotEmpty;

  /// Whether any AI route is configured under the current build policy.
  static bool get hasAnyAi => hasAiProxy || hasOpenAI || hasGemini || hasNvidia;
}
