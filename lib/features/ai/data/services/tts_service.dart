import 'dart:ui';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';

/// Voice Persona for fitness coaching
class VoicePersona {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String voiceName;
  final double pitch;
  final double recommendedSpeed;

  const VoicePersona({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.voiceName,
    required this.pitch,
    required this.recommendedSpeed,
  });
}

/// Text-to-Speech Service (Wave 7.4).
///
/// Features:
/// - Syncs TTS language tag with the app's 7 supported locales (`en-US`, `es-ES`,
///   `fr-FR`, `de-DE`, `pt-BR`, `ja-JP`, `zh-CN`).
/// - Uses completion, progress, pause, and error handlers (`onStateChanged`)
///   instead of arbitrary `Future.delayed` timers.
/// - Implements real `resume()` using character progress offset tracking so
///   paused narration continues from the remaining text across all platforms.
class TtsService {
  TtsService({FlutterTts? flutterTts})
      : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isPaused = false;
  String _languageTag = 'en-US';
  String _lastCleanText = '';
  int _lastProgressOffset = 0;
  int _pausedOffset = 0;

  List<String> _availableVoices = [];
  String? _currentVoice;

  /// Callback invoked whenever speaking/paused/voices state changes.
  VoidCallback? onStateChanged;

  static const Map<String, String> localeToBcp47 = {
    'en': 'en-US',
    'es': 'es-ES',
    'fr': 'fr-FR',
    'de': 'de-DE',
    'pt': 'pt-BR',
    'ja': 'ja-JP',
    'zh': 'zh-CN',
  };

  /// Maps a 2-letter locale code (or BCP-47 tag) to a supported TTS language tag.
  static String resolveLanguageTag(String? localeCode) {
    if (localeCode == null || localeCode.trim().isEmpty) return 'en-US';
    final clean = localeCode.trim();
    if (clean.contains('-')) return clean;
    final prefix = clean.split('_').first.toLowerCase();
    return localeToBcp47[prefix] ?? 'en-US';
  }

  String get currentLanguageTag => _languageTag;
  String get remainingResumePreview =>
      (_pausedOffset > 0 && _pausedOffset < _lastCleanText.length)
          ? _lastCleanText.substring(_pausedOffset).trimLeft()
          : _lastCleanText;

  void _notifyStateChanged() {
    onStateChanged?.call();
  }

  /// Synchronizes TTS engine language and voice list with the active app language.
  Future<void> syncWithAppLanguage(String localeCode) async {
    final nextTag = resolveLanguageTag(localeCode);
    final languageChanged = _languageTag != nextTag;
    _languageTag = nextTag;

    if (!_isInitialized) {
      await initialize(languageCode: nextTag);
      return;
    }

    if (languageChanged) {
      try {
        await _flutterTts.setLanguage(_languageTag);
        await _loadAvailableVoices();
        _notifyStateChanged();
      } catch (e) {
        AppLogger.debug('❌ [TTS ERROR] Failed to sync language $_languageTag: $e');
      }
    }
  }

  /// Initialize TTS with event handlers and language settings.
  Future<void> initialize({String? languageCode}) async {
    if (languageCode != null && languageCode.trim().isNotEmpty) {
      _languageTag = resolveLanguageTag(languageCode);
    }
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage(_languageTag);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      await _loadAvailableVoices();

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        _isPaused = false;
        _notifyStateChanged();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _isPaused = false;
        _lastProgressOffset = 0;
        _pausedOffset = 0;
        _notifyStateChanged();
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        _isPaused = false;
        _notifyStateChanged();
      });

      _flutterTts.setPauseHandler(() {
        _isPaused = true;
        _pausedOffset = _lastProgressOffset;
        _notifyStateChanged();
      });

      _flutterTts.setContinueHandler(() {
        _isPaused = false;
        _isSpeaking = true;
        _notifyStateChanged();
      });

      _flutterTts.setProgressHandler(
        (String text, int startOffset, int endOffset, String word) {
          if (endOffset > 0) {
            _lastProgressOffset = (_pausedOffset + endOffset)
                .clamp(0, _lastCleanText.length);
          }
        },
      );

      _flutterTts.setErrorHandler((msg) {
        AppLogger.debug('🔴 [TTS ERROR] $msg');
        _isSpeaking = false;
        _isPaused = false;
        _notifyStateChanged();
      });

      _isInitialized = true;
      _notifyStateChanged();
      AppLogger.debug('✅ [TTS] Service initialized ($_languageTag)');
    } catch (e) {
      AppLogger.debug('❌ [TTS ERROR] Failed to initialize: $e');
    }
  }

  /// Speak the given text from the beginning.
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await stop();

      final cleanText = _cleanTextForSpeech(text);
      _lastCleanText = cleanText;
      _lastProgressOffset = 0;
      _pausedOffset = 0;

      if (cleanText.isEmpty) return;

      _isSpeaking = true;
      _isPaused = false;
      _notifyStateChanged();

      await _flutterTts.speak(cleanText);
    } catch (e) {
      AppLogger.debug('❌ [TTS ERROR] Failed to speak: $e');
      _isSpeaking = false;
      _notifyStateChanged();
    }
  }

  /// Pause speech and snapshot the current character offset for [resume].
  Future<void> pause() async {
    if (_isSpeaking && !_isPaused) {
      try {
        _pausedOffset = _lastProgressOffset;
        await _flutterTts.pause();
        _isPaused = true;
        _notifyStateChanged();
        AppLogger.debug('⏸️ [TTS] Paused at offset $_pausedOffset');
      } catch (e) {
        AppLogger.debug('❌ [TTS ERROR] Failed to pause: $e');
      }
    }
  }

  /// Resume speech from the paused character offset (Wave 7.4).
  Future<void> resume() async {
    if ((_isSpeaking || _lastCleanText.isNotEmpty) && _isPaused) {
      try {
        _isPaused = false;
        _isSpeaking = true;
        _notifyStateChanged();

        final remaining = remainingResumePreview;
        if (remaining.isNotEmpty) {
          await _flutterTts.speak(remaining);
        }
        AppLogger.debug('▶️ [TTS] Resumed (${remaining.length} chars remaining)');
      } catch (e) {
        AppLogger.debug('❌ [TTS ERROR] Failed to resume: $e');
        _isSpeaking = false;
        _notifyStateChanged();
      }
    }
  }

  /// Stop speech and reset offsets.
  Future<void> stop() async {
    if (_isSpeaking || _isPaused) {
      try {
        await _flutterTts.stop();
      } catch (e) {
        AppLogger.debug('❌ [TTS ERROR] Failed to stop: $e');
      }
      _isSpeaking = false;
      _isPaused = false;
      _lastProgressOffset = 0;
      _pausedOffset = 0;
      _notifyStateChanged();
    }
  }

  /// Simulates progress advancement in deterministic unit tests.
  void updateProgressForTest(int characterOffset) {
    _lastProgressOffset = characterOffset.clamp(0, _lastCleanText.length);
  }

  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;
  List<String> get availableVoices => List<String>.unmodifiable(_availableVoices);
  String? get currentVoice => _currentVoice;

  Future<List<String>> getLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      if (languages is List) {
        return List<String>.from(languages.map((e) => e.toString()));
      }
      return [_languageTag];
    } catch (e) {
      return [_languageTag];
    }
  }

  Future<void> _loadAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      if (voices is List) {
        final langPrefix = _languageTag.split('-').first.toLowerCase();
        final matched = <String>[];
        final allNames = <String>[];

        for (final voice in voices) {
          if (voice is Map) {
            final name = voice['name']?.toString() ?? '';
            final locale = voice['locale']?.toString().toLowerCase() ?? '';
            if (name.isEmpty) continue;
            if (!allNames.contains(name)) allNames.add(name);
            if (locale.startsWith(langPrefix) && !matched.contains(name)) {
              matched.add(name);
            }
          }
        }

        _availableVoices = matched.isNotEmpty ? matched : allNames;
      }
    } catch (e) {
      _availableVoices = [];
    }
  }

  Future<void> setVoice(String voiceName) async {
    try {
      await _flutterTts.setVoice({'name': voiceName, 'locale': _languageTag});
      _currentVoice = voiceName;
      _notifyStateChanged();
    } catch (e) {
      AppLogger.debug('❌ [TTS ERROR] Failed to set voice: $e');
    }
  }

  Future<void> applyPersona(VoicePersona persona) async {
    try {
      if (persona.voiceName != 'default') {
        await setVoice(persona.voiceName);
      }
      await setPitch(persona.pitch);
      await setSpeechRate(persona.recommendedSpeed);
      _notifyStateChanged();
    } catch (e) {
      AppLogger.debug('❌ [TTS ERROR] Failed to apply persona: $e');
    }
  }

  List<VoicePersona> getFitnessVoicePersonas() {
    return [
      VoicePersona(
        id: 'yoga_instructor',
        name: '🌸 Yoga Instructor',
        description: 'Very slow & peaceful',
        icon: '🌸',
        voiceName: _findBestVoice(['female', 'samantha', 'karen', 'moira', 'google']),
        pitch: 0.5,
        recommendedSpeed: 0.15,
      ),
      VoicePersona(
        id: 'calm_trainer',
        name: '🧘 Calm Trainer',
        description: 'Slow & soothing',
        icon: '🧘',
        voiceName: _findBestVoice(['female', 'zira', 'samantha', 'karen', 'google']),
        pitch: 0.7,
        recommendedSpeed: 0.25,
      ),
      VoicePersona(
        id: 'wellness_guide',
        name: '🌟 Wellness Guide',
        description: 'Normal & caring',
        icon: '🌟',
        voiceName: _findBestVoice(['female', 'samantha', 'karen', 'zira', 'google']),
        pitch: 1.0,
        recommendedSpeed: 0.5,
      ),
      VoicePersona(
        id: 'energetic_trainer',
        name: '⚡ Energetic Trainer',
        description: 'Fast & upbeat',
        icon: '⚡',
        voiceName: _findBestVoice(['female', 'victoria', 'kate', 'zira', 'google']),
        pitch: 1.4,
        recommendedSpeed: 0.75,
      ),
      VoicePersona(
        id: 'intense_female',
        name: '🔥 Intense Coach',
        description: 'Very fast & powerful',
        icon: '🔥',
        voiceName: _findBestVoice(['female', 'kate', 'victoria', 'samantha', 'google']),
        pitch: 1.8,
        recommendedSpeed: 0.95,
      ),
      VoicePersona(
        id: 'professional_coach',
        name: '🎯 Professional Coach',
        description: 'Slow & authoritative',
        icon: '🎯',
        voiceName: _findBestVoice(['male', 'david', 'daniel', 'alex', 'google']),
        pitch: 0.6,
        recommendedSpeed: 0.3,
      ),
      VoicePersona(
        id: 'friendly_coach',
        name: '😊 Friendly Coach',
        description: 'Normal & encouraging',
        icon: '😊',
        voiceName: _findBestVoice(['male', 'david', 'mark', 'james', 'google']),
        pitch: 1.0,
        recommendedSpeed: 0.5,
      ),
      VoicePersona(
        id: 'motivational_coach',
        name: '💪 Motivational Coach',
        description: 'Fast & energetic',
        icon: '💪',
        voiceName: _findBestVoice(['male', 'david', 'mark', 'james', 'google']),
        pitch: 1.5,
        recommendedSpeed: 0.8,
      ),
      VoicePersona(
        id: 'intense_trainer',
        name: '⚡ Intense Trainer',
        description: 'Very fast & intense',
        icon: '⚡',
        voiceName: _findBestVoice(['male', 'mark', 'james', 'david', 'google']),
        pitch: 1.8,
        recommendedSpeed: 1.0,
      ),
    ];
  }

  String _findBestVoice(List<String> keywords) {
    if (_availableVoices.isEmpty) {
      return 'default';
    }
    for (final keyword in keywords) {
      final match = _availableVoices.firstWhere(
        (voice) => voice.toLowerCase().contains(keyword.toLowerCase()),
        orElse: () => '',
      );
      if (match.isNotEmpty) {
        return match;
      }
    }
    return _availableVoices.first;
  }

  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (e) {
      AppLogger.debug('❌ [TTS ERROR] Failed to set speech rate: $e');
    }
  }

  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch);
    } catch (e) {
      AppLogger.debug('❌ [TTS ERROR] Failed to set pitch: $e');
    }
  }

  String _cleanTextForSpeech(String text) {
    String cleaned = text;
    cleaned = cleaned.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'\1');
    cleaned = cleaned.replaceAll(RegExp(r'\*([^*]+)\*'), r'\1');
    cleaned = cleaned.replaceAll(RegExp(r'__([^_]+)__'), r'\1');
    cleaned = cleaned.replaceAll(RegExp(r'_([^_]+)_'), r'\1');
    cleaned = cleaned.replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'\1');
    cleaned = cleaned.replaceAll(RegExp(r'```[^`]*```'), '');
    cleaned = cleaned.replaceAll(RegExp(r'`([^`]+)`'), r'\1');
    cleaned = cleaned.replaceAll(RegExp(r'^>\s+', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'^[-*+•]\s+', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '');
    cleaned = cleaned.replaceAll(
      RegExp(
        r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
        unicode: true,
      ),
      '',
    );
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\n\n+'), '. ');
    cleaned = cleaned.replaceAll(RegExp(r'\n'), ' ');
    return cleaned.trim();
  }

  Future<void> dispose() async {
    onStateChanged = null;
    await stop();
    _isInitialized = false;
  }
}
