import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/features/ai/domain/entities/chat_message.dart';
import 'package:progression_tracker/features/ai/domain/services/local_ai_coach.dart';
import 'package:progression_tracker/features/ai/data/datasources/gemini_ai_service.dart';
import 'package:progression_tracker/features/ai/data/datasources/ai_chat_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:progression_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/entities.dart';
import 'package:progression_tracker/features/body/presentation/providers/body_providers.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/core/providers/analytics_provider.dart';

/// Provider for local AI coach service (fallback)
final localAICoachProvider = Provider<LocalAICoach>((ref) {
  return LocalAICoach();
});

/// Provider for Gemini AI service (FREE!)
final geminiAIServiceProvider = Provider<GeminiAIService>((ref) {
  return GeminiAIService();
});

/// StateNotifier for AI personalization consent (Privacy-first: default is false)
final aiPersonalizationConsentProvider =
    StateNotifierProvider<AIPersonalizationConsentNotifier, bool>((ref) {
  return AIPersonalizationConsentNotifier();
});

class AIPersonalizationConsentNotifier extends StateNotifier<bool> {
  static const String key = 'ai_personalization_consent';

  AIPersonalizationConsentNotifier() : super(false) {
    _loadConsent();
  }

  Future<void> _loadConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final consent = prefs.getBool(key) ?? false;
      if (mounted) state = consent;
    } catch (_) {}
  }

  Future<void> setConsent(bool consent) async {
    state = consent;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, consent);
    } catch (_) {}
  }

  Future<void> toggle() => setConsent(!state);
}

/// State for AI chat
class AIChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String? streamingMessage;
  final bool isOfflineFallback;
  final bool isKeyMissing;
  final String? lastFailedMessage;

  AIChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.streamingMessage,
    this.isOfflineFallback = false,
    this.isKeyMissing = false,
    this.lastFailedMessage,
  });

  AIChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? streamingMessage,
    bool? isOfflineFallback,
    bool? isKeyMissing,
    String? lastFailedMessage,
    bool clearError = false,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      streamingMessage: streamingMessage,
      isOfflineFallback: isOfflineFallback ?? this.isOfflineFallback,
      isKeyMissing: isKeyMissing ?? this.isKeyMissing,
      lastFailedMessage: lastFailedMessage ?? this.lastFailedMessage,
    );
  }
}

class AIChatNotifier extends StateNotifier<AIChatState> {
  final LocalAICoach _localCoach;
  final GeminiAIService _geminiService;
  final Ref _ref;
  final AIChatStorage? _chatStorage;

  AIChatNotifier({
    required LocalAICoach localCoach,
    required GeminiAIService geminiService,
    required Ref ref,
    AIChatStorage? chatStorage,
  })  : _localCoach = localCoach,
        _geminiService = geminiService,
        _ref = ref,
        _chatStorage = chatStorage,
        super(AIChatState(
          isKeyMissing: !geminiService.isConfigured,
        )) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (_chatStorage == null) return;
    try {
      final history = await _chatStorage.loadMessages();
      if (history.isNotEmpty && mounted) {
        state = state.copyWith(messages: history);
      }
    } catch (_) {}
  }

  String _formatErrorMessage(Object error) {
    if (error is GeminiAIServiceException) {
      switch (error.code) {
        case 'TIMEOUT':
        case 'NETWORK_ERROR':
          return 'Could not connect to the fitness assistant. Please check your internet connection and try again.';
        case 'RATE_LIMIT_EXCEEDED':
          return 'The assistant is receiving high traffic right now. Please try again in a few minutes.';
        case 'UNAUTHORIZED':
          return 'Could not authenticate with the AI service. Please check your settings.';
        case 'MISSING_API_KEY':
          return 'AI assistant is in offline mode. Switched to basic coach.';
        default:
          return 'Could not get an answer right now. Please tap Retry to try again.';
      }
    }
    final str = error.toString().toLowerCase();
    if (str.contains('socket') || str.contains('timeout') || str.contains('network') || str.contains('connection')) {
      return 'Could not connect to the fitness assistant. Please check your internet connection and try again.';
    }
    return 'Something went wrong while contacting the coach. Please tap Retry to try again.';
  }

  Future<void> retryLastMessage() async {
    final failed = state.lastFailedMessage;
    if (failed != null && failed.trim().isNotEmpty) {
      state = state.copyWith(clearError: true);
      await sendMessage(failed);
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: 'user',
      content: message,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      clearError: true,
    );
    _chatStorage?.saveMessages(state.messages);

    try {
      AppLogger.debug('═══════════════════════════════════════');
      AppLogger.debug('🚀 [AI CHAT] Starting message processing');
      AppLogger.debug('📝 [AI CHAT] User message: $message');
      AppLogger.debug('═══════════════════════════════════════');
      
      // Gather user data if personalization consent is granted
      final hasConsent = _ref.read(aiPersonalizationConsentProvider);
      UserProfile? profile;
      List<Workout> recentWorkouts = const [];
      List<DailyNutritionSummary> nutritionHistory = const [];
      NutritionTargets? nutritionTargets;
      List<BodyEntry> bodyEntries = const [];

      if (hasConsent) {
        AppLogger.debug('📊 [AI CHAT] Step 1: Personalization consent ENABLED. Gathering user data...');
        try {
          final authRepo = _ref.read(authRepositoryProvider);
          final workoutRepo = _ref.read(workoutRepositoryProvider);
          final nutritionRepo = _ref.read(nutritionRepositoryProvider);
          final bodyRepo = _ref.read(bodyRepositoryProvider);

          final user = await authRepo.getCurrentUser();
          profile = user != null ? await authRepo.getUserProfile(user.id) : null;
          AppLogger.debug('✅ [AI CHAT] User profile: ${profile?.name ?? "Guest"}');

          final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
          recentWorkouts = await workoutRepo.getWorkoutsByDateRange(
            thirtyDaysAgo,
            DateTime.now(),
          );
          AppLogger.debug('✅ [AI CHAT] Found ${recentWorkouts.length} workouts');

          final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
          nutritionHistory = await nutritionRepo.getNutritionHistory(
            sevenDaysAgo,
            DateTime.now(),
          );
          nutritionTargets = await nutritionRepo.getNutritionTargets();
          AppLogger.debug('✅ [AI CHAT] Found ${nutritionHistory.length} nutrition days');

          bodyEntries = await bodyRepo.getBodyEntriesByDateRange(
            thirtyDaysAgo,
            DateTime.now(),
          );
          AppLogger.debug('✅ [AI CHAT] Found ${bodyEntries.length} body entries');
        } catch (e) {
          AppLogger.debug('⚠️ [AI CHAT] Error gathering user data: $e');
        }
      } else {
        AppLogger.debug('🔒 [AI CHAT] Personalization consent DISABLED. Preserving privacy.');
      }

      // Build system prompt with user context
      AppLogger.debug('🔧 [AI CHAT] Step 2: Building system prompt...');
      final systemPrompt = _buildSystemPrompt(
        hasConsent: hasConsent,
        profile: profile,
        recentWorkouts: recentWorkouts,
        nutritionHistory: nutritionHistory,
        nutritionTargets: nutritionTargets,
        bodyEntries: bodyEntries,
      );
      AppLogger.debug('✅ [AI CHAT] System prompt built (${systemPrompt.length} chars)');

      String responseText;
      bool isFallback = false;
      String? errorMessage;
      
      if (!_geminiService.isConfigured) {
        AppLogger.debug('⚠️ [AI CHAT] No Gemini API key configured. Using Local AI Coach...');
        isFallback = true;
        responseText = _localCoach.generateResponse(
          message,
          profile: profile,
          recentWorkouts: recentWorkouts,
          nutritionHistory: nutritionHistory,
          nutritionTargets: nutritionTargets,
          bodyEntries: bodyEntries,
        );
      } else {
        try {
          AppLogger.debug('═══════════════════════════════════════');
          AppLogger.debug('🤖 [AI CHAT] Step 7: Calling Gemini AI');
          AppLogger.debug('📡 [AI CHAT] Sending request to Gemini API...');
          AppLogger.debug('═══════════════════════════════════════');
          
          responseText = await _geminiService.sendMessage(
            [{'role': 'user', 'content': message}],
            systemPrompt: systemPrompt,
            temperature: 0.7,
            maxTokens: 1000,
          );
          
          AppLogger.debug('═══════════════════════════════════════');
          AppLogger.debug('✅ [AI CHAT] Gemini response received!');
          AppLogger.debug('📝 [AI CHAT] Response length: ${responseText.length} chars');
          AppLogger.debug('═══════════════════════════════════════');
        } catch (e, stackTrace) {
          AppLogger.debug('═══════════════════════════════════════');
          AppLogger.debug('❌ [AI CHAT ERROR] Gemini API failed!');
          AppLogger.debug('🔴 [AI CHAT ERROR] Error message: $e');
          AppLogger.debug('═══════════════════════════════════════');
          AppLogger.debug('🔄 [AI CHAT] Falling back to LocalAI with plain English notification...');
          
          isFallback = true;
          errorMessage = _formatErrorMessage(e);
          
          responseText = _localCoach.generateResponse(
            message,
            profile: profile,
            recentWorkouts: recentWorkouts,
            nutritionHistory: nutritionHistory,
            nutritionTargets: nutritionTargets,
            bodyEntries: bodyEntries,
          );
        }
      }

      // Add assistant message
      AppLogger.debug('💾 [AI CHAT] Step 8: Saving response to chat...');
      final assistantMessage = ChatMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        content: responseText,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
        isOfflineFallback: isFallback,
        error: errorMessage,
        lastFailedMessage: errorMessage != null ? message : null,
      );
      _chatStorage?.saveMessages(state.messages);
      
      // Track AI query event
      try {
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.logAIQuery(
          queryType: 'chat',
          query: message,
          responseLength: responseText.length,
        );
        AppLogger.debug('📊 [Analytics] AI query event logged');
      } catch (e) {
        AppLogger.debug('⚠️ [Analytics] Failed to log AI query event: $e');
      }
      
      AppLogger.debug('═══════════════════════════════════════');
      AppLogger.debug('🎉 [AI CHAT] Message processing complete!');
      AppLogger.debug('📊 [AI CHAT] Total messages: ${state.messages.length}');
      AppLogger.debug('═══════════════════════════════════════');
    } catch (e, stackTrace) {
      AppLogger.debug('═══════════════════════════════════════');
      AppLogger.debug('❌❌❌ [AI CHAT FATAL ERROR] ❌❌❌');
      AppLogger.debug('🔴 [AI CHAT ERROR] Error message: $e');
      AppLogger.debug(stackTrace);
      AppLogger.debug('═══════════════════════════════════════');
      
      state = state.copyWith(
        isLoading: false,
        error: _formatErrorMessage(e),
        lastFailedMessage: message,
      );
    }
  }

  /// Build system prompt with user context, privacy gating and safety guardrails
  String _buildSystemPrompt({
    bool hasConsent = false,
    UserProfile? profile,
    List<Workout> recentWorkouts = const [],
    List<DailyNutritionSummary> nutritionHistory = const [],
    NutritionTargets? nutritionTargets,
    List<BodyEntry> bodyEntries = const [],
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('You are an expert fitness coach and nutritionist for IronFlow, a fitness tracking app.');
    buffer.writeln('Your role is to provide short, accurate, evidence-based fitness and nutrition answers in plain English.');
    buffer.writeln();
    buffer.writeln('STRICT RESPONSE RULES (CRITICAL):');
    buffer.writeln('1. Under 80 words: Keep your entire response under 80 words. Be direct, clear, and concise.');
    buffer.writeln('2. Maximum 3 bullets: If you list items or recommendations, use at most 3 bullet points.');
    buffer.writeln('3. Exactly 1 next step: Always conclude your response with a clear heading or line "**Next Step:**" followed by exactly 1 practical action the user should take right now.');
    buffer.writeln('4. Simple English: Speak like an encouraging, knowledgeable human coach. Do NOT use sci-fi, military, or robotic jargon (avoid words like "operator", "directive", "protocol", "telemetry", "cipher", "heuristic", "neural core").');
    buffer.writeln();
    buffer.writeln('SAFETY AND MEDICAL GUARDRAILS (CRITICAL):');
    buffer.writeln('- You are a fitness coach, NOT a physician or doctor.');
    buffer.writeln('- NEVER provide clinical medical diagnoses or prescribe medications.');
    buffer.writeln('- If the user asks about chest pain, joint injury, acute dizziness, or sharp pain, instruct them to stop exercising immediately and consult a doctor.');
    buffer.writeln('- Remind users to adhere to proper warmup and progressive overload.');
    buffer.writeln();
    
    // Add user profile context only if user gave consent
    if (hasConsent && profile != null) {
      buffer.writeln('USER PROFILE:');
      buffer.writeln('- Name: ${profile.name ?? "User"}');
      
      // Handle goals
      if (profile.goals != null && (profile.goals as List).isNotEmpty) {
        buffer.writeln('- Goals: ${(profile.goals as List).join(", ")}');
      }
      
      // Handle fitness level
      if (profile.fitnessLevel != null) {
        buffer.writeln('- Fitness Level: ${profile.fitnessLevel}');
      }
      
      // Handle equipment
      if (profile.equipment != null && (profile.equipment as List).isNotEmpty) {
        buffer.writeln('- Available Equipment: ${(profile.equipment as List).join(", ")}');
      }
      
      buffer.writeln();
    } else if (!hasConsent) {
      buffer.writeln('USER PRIVACY:');
      buffer.writeln('- Detailed profile, workout and nutrition sharing is disabled for privacy.');
      buffer.writeln('- Provide general evidence-based training advice and ask clarifying questions if specifics are needed.');
      buffer.writeln();
    }
    
    // Add workout context only if user gave consent
    if (hasConsent && recentWorkouts.isNotEmpty) {
      buffer.writeln('RECENT ACTIVITY:');
      buffer.writeln('- ${recentWorkouts.length} workouts in last 30 days');
      buffer.writeln();
    }
    
    // Add nutrition context only if user gave consent
    if (hasConsent && nutritionHistory.isNotEmpty) {
      buffer.writeln('NUTRITION:');
      buffer.writeln('- Tracking nutrition for ${nutritionHistory.length} days');
      if (nutritionTargets != null) {
        buffer.writeln('- Has nutrition targets set');
      }
      buffer.writeln();
    }
    
    // Add body tracking context only if user gave consent
    if (hasConsent && bodyEntries.isNotEmpty) {
      buffer.writeln('PROGRESS TRACKING:');
      buffer.writeln('- ${bodyEntries.length} body measurements logged');
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  Future<void> clearHistory() async {
    state = state.copyWith(messages: []);
    await _chatStorage?.clearMessages();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for AI chat notifier
final aiChatProvider = StateNotifierProvider<AIChatNotifier, AIChatState>((ref) {
  return AIChatNotifier(
    localCoach: ref.watch(localAICoachProvider),
    geminiService: ref.watch(geminiAIServiceProvider),
    chatStorage: ref.watch(aiChatStorageProvider),
    ref: ref,
  );
});
