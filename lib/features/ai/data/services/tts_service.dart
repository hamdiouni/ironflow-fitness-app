import 'package:flutter_tts/flutter_tts.dart';

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

/// Text-to-Speech Service
/// 
/// Provides FREE audio narration for AI responses using device TTS
/// - 100% FREE (uses device built-in TTS)
/// - No API keys required
/// - Works offline
/// - Multiple languages supported
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _isPaused = false;
  
  List<String> _availableVoices = [];
  String? _currentVoice;

  /// Initialize TTS with optimal settings
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set language to English (US)
      await _flutterTts.setLanguage('en-US');

      // Set speech rate (0.0 to 1.0, default 0.5)
      await _flutterTts.setSpeechRate(0.5);

      // Set volume (0.0 to 1.0, default 1.0)
      await _flutterTts.setVolume(1.0);

      // Set pitch (0.5 to 2.0, default 1.0)
      await _flutterTts.setPitch(1.0);
      
      // Get available voices
      await _loadAvailableVoices();

      // Set up completion handler
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _isPaused = false;
      });

      // Set up error handler
      _flutterTts.setErrorHandler((msg) {
        print('🔴 [TTS ERROR] $msg');
        _isSpeaking = false;
        _isPaused = false;
      });

      _isInitialized = true;
      print('✅ [TTS] Service initialized successfully');
    } catch (e) {
      print('❌ [TTS ERROR] Failed to initialize: $e');
    }
  }

  /// Speak the given text
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Stop any ongoing speech
      await stop();

      // Clean text for better speech
      final cleanText = _cleanTextForSpeech(text);

      print('🔊 [TTS] Speaking: ${cleanText.substring(0, cleanText.length > 50 ? 50 : cleanText.length)}...');

      _isSpeaking = true;
      _isPaused = false;

      await _flutterTts.speak(cleanText);
    } catch (e) {
      print('❌ [TTS ERROR] Failed to speak: $e');
      _isSpeaking = false;
    }
  }

  /// Pause speech
  Future<void> pause() async {
    if (_isSpeaking && !_isPaused) {
      try {
        await _flutterTts.pause();
        _isPaused = true;
        print('⏸️ [TTS] Paused');
      } catch (e) {
        print('❌ [TTS ERROR] Failed to pause: $e');
      }
    }
  }

  /// Resume speech
  Future<void> resume() async {
    if (_isSpeaking && _isPaused) {
      try {
        // Note: Flutter TTS doesn't have a resume method on all platforms
        // We'll need to continue from where we left off
        _isPaused = false;
        print('▶️ [TTS] Resumed');
      } catch (e) {
        print('❌ [TTS ERROR] Failed to resume: $e');
      }
    }
  }

  /// Stop speech
  Future<void> stop() async {
    if (_isSpeaking) {
      try {
        await _flutterTts.stop();
        _isSpeaking = false;
        _isPaused = false;
        print('⏹️ [TTS] Stopped');
      } catch (e) {
        print('❌ [TTS ERROR] Failed to stop: $e');
      }
    }
  }

  /// Check if currently speaking
  bool get isSpeaking => _isSpeaking;

  /// Check if paused
  bool get isPaused => _isPaused;

  /// Get available languages
  Future<List<String>> getLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return List<String>.from(languages);
    } catch (e) {
      print('❌ [TTS ERROR] Failed to get languages: $e');
      return ['en-US'];
    }
  }
  
  /// Load available voices
  Future<void> _loadAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      if (voices is List) {
        _availableVoices = voices
            .where((voice) {
              if (voice is Map) {
                final locale = voice['locale'] as String?;
                return locale != null && locale.startsWith('en');
              }
              return false;
            })
            .map((voice) => (voice as Map)['name'] as String)
            .toList();
        
        print('🎤 [TTS] Found ${_availableVoices.length} English voices');
        if (_availableVoices.isNotEmpty) {
          print('🎤 [TTS] Available voices: ${_availableVoices.take(5).join(", ")}...');
        }
      }
    } catch (e) {
      print('❌ [TTS ERROR] Failed to load voices: $e');
      _availableVoices = [];
    }
  }
  
  /// Get available voices
  List<String> get availableVoices => _availableVoices;
  
  /// Get current voice
  String? get currentVoice => _currentVoice;
  
  /// Set voice by name
  Future<void> setVoice(String voiceName) async {
    try {
      await _flutterTts.setVoice({'name': voiceName, 'locale': 'en-US'});
      _currentVoice = voiceName;
      print('🎤 [TTS] Voice set to: $voiceName');
    } catch (e) {
      print('❌ [TTS ERROR] Failed to set voice: $e');
    }
  }
  
  /// Apply a voice persona (voice + pitch + speed)
  Future<void> applyPersona(VoicePersona persona) async {
    try {
      // Set voice
      if (persona.voiceName != 'default') {
        await setVoice(persona.voiceName);
      }
      
      // Set pitch
      await setPitch(persona.pitch);
      
      // Set recommended speed
      await setSpeechRate(persona.recommendedSpeed);
      
      print('🎭 [TTS] Applied persona: ${persona.name}');
      print('   Voice: ${persona.voiceName}');
      print('   Pitch: ${persona.pitch}');
      print('   Speed: ${persona.recommendedSpeed}');
    } catch (e) {
      print('❌ [TTS ERROR] Failed to apply persona: $e');
    }
  }
  
  /// Get fitness-themed voice personas
  List<VoicePersona> getFitnessVoicePersonas() {
    // EXTREME differences for web browsers where voice selection doesn't work
    // Pitch range: 0.5 to 2.0 (we'll use 0.5 to 1.8)
    // Speed range: 0.1 to 1.0 (0.2x to 2.0x display)
    
    return [
      // VERY SLOW & LOW - Female
      VoicePersona(
        id: 'yoga_instructor',
        name: '🌸 Yoga Instructor',
        description: 'Very slow & peaceful',
        icon: '🌸',
        voiceName: _findBestVoice(['female', 'samantha', 'karen', 'moira', 'google us english female']),
        pitch: 0.5,  // VERY LOW
        recommendedSpeed: 0.15,  // 0.3x speed - EXTREMELY SLOW
      ),
      
      // SLOW & LOW - Female
      VoicePersona(
        id: 'calm_trainer',
        name: '🧘 Calm Trainer',
        description: 'Slow & soothing',
        icon: '🧘',
        voiceName: _findBestVoice(['female', 'zira', 'samantha', 'karen', 'google us english female']),
        pitch: 0.7,  // LOW
        recommendedSpeed: 0.25,  // 0.5x speed - VERY SLOW
      ),
      
      // NORMAL - Female
      VoicePersona(
        id: 'wellness_guide',
        name: '🌟 Wellness Guide',
        description: 'Normal & caring',
        icon: '🌟',
        voiceName: _findBestVoice(['female', 'samantha', 'karen', 'zira', 'google us english female']),
        pitch: 1.0,  // NORMAL
        recommendedSpeed: 0.5,  // 1.0x speed - NORMAL
      ),
      
      // FAST & HIGH - Female
      VoicePersona(
        id: 'energetic_trainer',
        name: '⚡ Energetic Trainer',
        description: 'Fast & upbeat',
        icon: '⚡',
        voiceName: _findBestVoice(['female', 'victoria', 'kate', 'zira', 'google us english female']),
        pitch: 1.4,  // HIGH
        recommendedSpeed: 0.75,  // 1.5x speed - FAST
      ),
      
      // VERY FAST & VERY HIGH - Female
      VoicePersona(
        id: 'intense_female',
        name: '🔥 Intense Coach',
        description: 'Very fast & powerful',
        icon: '🔥',
        voiceName: _findBestVoice(['female', 'kate', 'victoria', 'samantha', 'google us english female']),
        pitch: 1.8,  // VERY HIGH
        recommendedSpeed: 0.95,  // 1.9x speed - VERY FAST
      ),
      
      // SLOW & LOW - Male
      VoicePersona(
        id: 'professional_coach',
        name: '🎯 Professional Coach',
        description: 'Slow & authoritative',
        icon: '🎯',
        voiceName: _findBestVoice(['male', 'david', 'daniel', 'alex', 'google us english male']),
        pitch: 0.6,  // LOW
        recommendedSpeed: 0.3,  // 0.6x speed - SLOW
      ),
      
      // NORMAL - Male
      VoicePersona(
        id: 'friendly_coach',
        name: '😊 Friendly Coach',
        description: 'Normal & encouraging',
        icon: '😊',
        voiceName: _findBestVoice(['male', 'david', 'mark', 'james', 'google us english male']),
        pitch: 1.0,  // NORMAL
        recommendedSpeed: 0.5,  // 1.0x speed - NORMAL
      ),
      
      // FAST & HIGH - Male
      VoicePersona(
        id: 'motivational_coach',
        name: '💪 Motivational Coach',
        description: 'Fast & energetic',
        icon: '💪',
        voiceName: _findBestVoice(['male', 'david', 'mark', 'james', 'google us english male']),
        pitch: 1.5,  // HIGH
        recommendedSpeed: 0.8,  // 1.6x speed - FAST
      ),
      
      // VERY FAST & VERY HIGH - Male
      VoicePersona(
        id: 'intense_trainer',
        name: '⚡ Intense Trainer',
        description: 'Very fast & intense',
        icon: '⚡',
        voiceName: _findBestVoice(['male', 'mark', 'james', 'david', 'google us english male']),
        pitch: 1.8,  // VERY HIGH
        recommendedSpeed: 1.0,  // 2.0x speed - MAXIMUM SPEED
      ),
    ];
  }
  
  /// Find best matching voice from available voices
  String _findBestVoice(List<String> keywords) {
    if (_availableVoices.isEmpty) {
      return 'default';
    }
    
    // Try to find a voice matching any keyword
    for (final keyword in keywords) {
      final match = _availableVoices.firstWhere(
        (voice) => voice.toLowerCase().contains(keyword.toLowerCase()),
        orElse: () => '',
      );
      if (match.isNotEmpty) {
        return match;
      }
    }
    
    // Return first available voice as fallback
    return _availableVoices.first;
  }

  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    try {
      await _flutterTts.setSpeechRate(rate);
      print('🎚️ [TTS] Speech rate set to $rate');
    } catch (e) {
      print('❌ [TTS ERROR] Failed to set speech rate: $e');
    }
  }

  /// Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    try {
      await _flutterTts.setPitch(pitch);
      print('🎚️ [TTS] Pitch set to $pitch');
    } catch (e) {
      print('❌ [TTS ERROR] Failed to set pitch: $e');
    }
  }

  /// Clean text for better speech synthesis
  String _cleanTextForSpeech(String text) {
    String cleaned = text;

    // Remove markdown headers
    cleaned = cleaned.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');

    // Remove markdown bold/italic
    cleaned = cleaned.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'\1');
    cleaned = cleaned.replaceAll(RegExp(r'\*([^*]+)\*'), r'\1');
    cleaned = cleaned.replaceAll(RegExp(r'__([^_]+)__'), r'\1');
    cleaned = cleaned.replaceAll(RegExp(r'_([^_]+)_'), r'\1');

    // Remove markdown links but keep text
    cleaned = cleaned.replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'\1');

    // Remove markdown code blocks
    cleaned = cleaned.replaceAll(RegExp(r'```[^`]*```'), '');
    cleaned = cleaned.replaceAll(RegExp(r'`([^`]+)`'), r'\1');

    // Remove blockquotes
    cleaned = cleaned.replaceAll(RegExp(r'^>\s+', multiLine: true), '');

    // Remove bullet points and numbers
    cleaned = cleaned.replaceAll(RegExp(r'^[-*+]\s+', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'^\d+\.\s+', multiLine: true), '');

    // Remove emojis (optional - they can cause issues with some TTS engines)
    cleaned = cleaned.replaceAll(
      RegExp(
        r'[\u{1F600}-\u{1F64F}]|[\u{1F300}-\u{1F5FF}]|[\u{1F680}-\u{1F6FF}]|[\u{1F1E0}-\u{1F1FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
        unicode: true,
      ),
      '',
    );

    // Replace multiple spaces with single space
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    // Replace multiple newlines with period for better pauses
    cleaned = cleaned.replaceAll(RegExp(r'\n\n+'), '. ');
    cleaned = cleaned.replaceAll(RegExp(r'\n'), ' ');

    // Trim
    cleaned = cleaned.trim();

    return cleaned;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stop();
    _isInitialized = false;
  }
}
