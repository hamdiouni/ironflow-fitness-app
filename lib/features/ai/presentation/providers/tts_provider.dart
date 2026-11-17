import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/providers/language_provider.dart';
import 'package:progression_tracker/features/ai/data/services/tts_service.dart';

// Export VoicePersona for use in UI
export 'package:progression_tracker/features/ai/data/services/tts_service.dart'
    show VoicePersona;

/// TTS Service Provider
final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  final locale = ref.watch(languageProvider);
  service.syncWithAppLanguage(locale.languageCode);

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
  final String languageTag;

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
    this.languageTag = 'en-US',
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
    String? languageTag,
    bool clearSelectedVoice = false,
  }) {
    return TtsState(
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isPaused: isPaused ?? this.isPaused,
      currentText: currentText ?? this.currentText,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      availableVoices: availableVoices ?? this.availableVoices,
      selectedVoice:
          clearSelectedVoice ? null : (selectedVoice ?? this.selectedVoice),
      personas: personas ?? this.personas,
      selectedPersonaId: selectedPersonaId ?? this.selectedPersonaId,
      languageTag: languageTag ?? this.languageTag,
    );
  }
}

/// TTS Notifier (Wave 7.4 — event-handler driven, zero fixed delays).
class TtsNotifier extends Notifier<TtsState> {
  TtsNotifier([this._injectedTtsService]);

  final TtsService? _injectedTtsService;
  late TtsService _ttsService;
  bool _disposed = false;

  @override
  TtsState build() {
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _ttsService.onStateChanged = null;
    });

    final locale = ref.watch(languageProvider);
    _ttsService = _injectedTtsService ?? ref.watch(ttsServiceProvider);
    _ttsService.onStateChanged = _syncFromService;

    _initAndSync(locale.languageCode);

    return TtsState(
      availableVoices: _ttsService.availableVoices,
      personas: _ttsService.getFitnessVoicePersonas(),
      languageTag: TtsService.resolveLanguageTag(locale.languageCode),
    );
  }

  Future<void> _initAndSync(String languageCode) async {
    await _ttsService.syncWithAppLanguage(languageCode);
    _syncFromService();
  }

  void _syncFromService() {
    if (_disposed) return;
    final voices = _ttsService.availableVoices;
    final personas = _ttsService.getFitnessVoicePersonas();
    final currentVoice = _ttsService.currentVoice;
    final validSelectedVoice =
        (currentVoice != null && voices.contains(currentVoice))
            ? currentVoice
            : (state.selectedVoice != null &&
                    voices.contains(state.selectedVoice))
                ? state.selectedVoice
                : null;

    state = state.copyWith(
      isSpeaking: _ttsService.isSpeaking,
      isPaused: _ttsService.isPaused,
      availableVoices: voices,
      personas: personas,
      selectedVoice: validSelectedVoice,
      clearSelectedVoice: validSelectedVoice == null,
      languageTag: _ttsService.currentLanguageTag,
    );
  }

  /// Speak text
  Future<void> speak(String text) async {
    state = state.copyWith(
      isSpeaking: true,
      isPaused: false,
      currentText: text,
    );

    await _ttsService.speak(text);
    _syncFromService();
  }

  /// Pause speech
  Future<void> pause() async {
    await _ttsService.pause();
    _syncFromService();
  }

  /// Resume speech
  Future<void> resume() async {
    await _ttsService.resume();
    _syncFromService();
  }

  /// Stop speech
  Future<void> stop() async {
    await _ttsService.stop();
    if (!_disposed) {
      state = state.copyWith(
        isSpeaking: false,
        isPaused: false,
        currentText: null,
      );
    }
  }

  /// Set speech rate
  Future<void> setSpeechRate(double rate) async {
    await _ttsService.setSpeechRate(rate);
    if (!_disposed) {
      state = state.copyWith(speechRate: rate);
    }
  }

  /// Set pitch
  Future<void> setPitch(double pitch) async {
    await _ttsService.setPitch(pitch);
    if (!_disposed) {
      state = state.copyWith(pitch: pitch);
    }
  }

  /// Set voice
  Future<void> setVoice(String voiceName) async {
    await _ttsService.setVoice(voiceName);
    if (!_disposed) {
      final valid = state.availableVoices.contains(voiceName) ? voiceName : null;
      state = state.copyWith(
        selectedVoice: valid,
        clearSelectedVoice: valid == null,
      );
    }
  }

  /// Apply persona
  Future<void> applyPersona(VoicePersona persona) async {
    await _ttsService.applyPersona(persona);
    if (!_disposed) {
      final validVoice = state.availableVoices.contains(persona.voiceName)
          ? persona.voiceName
          : null;
      state = state.copyWith(
        selectedPersonaId: persona.id,
        selectedVoice: validVoice,
        clearSelectedVoice: validVoice == null,
        speechRate: persona.recommendedSpeed,
        pitch: persona.pitch,
      );
    }
  }
}

/// TTS State Provider
final ttsProvider = NotifierProvider<TtsNotifier, TtsState>(TtsNotifier.new);
