import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/features/ai/data/services/tts_service.dart';

// Export VoicePersona for use in UI
export 'package:progression_tracker/features/ai/data/services/tts_service.dart' show VoicePersona;

/// TTS Service Provider
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  service.initialize();
  
  // Dispose when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// TTS State
class TtsState {
  final bool isSpeaking;
  final bool isPaused;
  final String? currentText;
  final double speechRate;
  final double pitch;
  final List<String> availableVoices;
  final String? selectedVoice;
  final List<VoicePersona> personas;
  final String? selectedPersonaId;

  const TtsState({
    this.isSpeaking = false,
    this.isPaused = false,
    this.currentText,
    this.speechRate = 0.5,
    this.pitch = 1.0,
    this.availableVoices = const [],
    this.selectedVoice,
    this.personas = const [],
    this.selectedPersonaId,
  });

  TtsState copyWith({
    bool? isSpeaking,
    bool? isPaused,
    String? currentText,
    double? speechRate,
    double? pitch,
    List<String>? availableVoices,
    String? selectedVoice,
    List<VoicePersona>? personas,
    String? selectedPersonaId,
  }) {
    return TtsState(
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isPaused: isPaused ?? this.isPaused,
      currentText: currentText ?? this.currentText,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      availableVoices: availableVoices ?? this.availableVoices,
      selectedVoice: selectedVoice ?? this.selectedVoice,
      personas: personas ?? this.personas,
      selectedPersonaId: selectedPersonaId ?? this.selectedPersonaId,
    );
  }
}

/// TTS State Notifier
class TtsNotifier extends StateNotifier<TtsState> {
  final TtsService _ttsService;

  TtsNotifier(this._ttsService) : super(const TtsState()) {
    _loadVoices();
    _loadPersonas();
  }
  
  /// Load available voices
  Future<void> _loadVoices() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Wait for TTS to initialize
    final voices = _ttsService.availableVoices;
    state = state.copyWith(availableVoices: voices);
  }
  
  /// Load fitness personas
  Future<void> _loadPersonas() async {
    await Future.delayed(const Duration(milliseconds: 600)); // Wait for voices to load
    final personas = _ttsService.getFitnessVoicePersonas();
    state = state.copyWith(personas: personas);
  }

  /// Speak text
  Future<void> speak(String text) async {
    state = state.copyWith(
      isSpeaking: true,
      isPaused: false,
      currentText: text,
    );

    await _ttsService.speak(text);

    // Update state after a delay to check if still speaking
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        state = state.copyWith(
          isSpeaking: _ttsService.isSpeaking,
          isPaused: _ttsService.isPaused,
        );
      }
    });
  }

  /// Pause speech
  Future<void> pause() async {
    await _ttsService.pause();
    state = state.copyWith(isPaused: true);
  }

  /// Resume speech
  Future<void> resume() async {
    await _ttsService.resume();
    state = state.copyWith(isPaused: false);
  }

  /// Stop speech
  Future<void> stop() async {
    await _ttsService.stop();
    state = state.copyWith(
      isSpeaking: false,
      isPaused: false,
      currentText: null,
    );
  }

  /// Set speech rate
  Future<void> setSpeechRate(double rate) async {
    await _ttsService.setSpeechRate(rate);
    state = state.copyWith(speechRate: rate);
  }

  /// Set pitch
  Future<void> setPitch(double pitch) async {
    await _ttsService.setPitch(pitch);
    state = state.copyWith(pitch: pitch);
  }
  
  /// Set voice
  Future<void> setVoice(String voiceName) async {
    await _ttsService.setVoice(voiceName);
    state = state.copyWith(selectedVoice: voiceName);
  }
  
  /// Apply persona
  Future<void> applyPersona(VoicePersona persona) async {
    await _ttsService.applyPersona(persona);
    state = state.copyWith(
      selectedPersonaId: persona.id,
      selectedVoice: persona.voiceName,
      speechRate: persona.recommendedSpeed,
      pitch: persona.pitch,
    );
  }
}

/// TTS State Provider
final ttsProvider = StateNotifierProvider<TtsNotifier, TtsState>((ref) {
  final service = ref.watch(ttsServiceProvider);
  return TtsNotifier(service);
});
