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

  AIChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.streamingMessage,
    this.isOfflineFallback = false,
    this.isKeyMissing = false,
  });

  AIChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? streamingMessage,
    bool? isOfflineFallback,
    bool? isKeyMissing,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      streamingMessage: streamingMessage,
      isOfflineFallback: isOfflineFallback ?? this.isOfflineFallback,
      isKeyMissing: isKeyMissing ?? this.isKeyMissing,
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
      error: null,
    );
    _chatStorage?.saveMessages(state.messages);

    try {
      print('═══════════════════════════════════════');
      print('🚀 [AI CHAT] Starting message processing');
      print('📝 [AI CHAT] User message: $message');
      print('═══════════════════════════════════════');
      
      // Gather user data if personalization consent is granted
      final hasConsent = _ref.read(aiPersonalizationConsentProvider);
      UserProfile? profile;
      List<Workout> recentWorkouts = const [];
      List<DailyNutritionSummary> nutritionHistory = const [];
      NutritionTargets? nutritionTargets;
      List<BodyEntry> bodyEntries = const [];

      if (hasConsent) {
        print('📊 [AI CHAT] Step 1: Personalization consent ENABLED. Gathering user data...');
        try {
          final authRepo = _ref.read(authRepositoryProvider);
          final workoutRepo = _ref.read(workoutRepositoryProvider);
          final nutritionRepo = _ref.read(nutritionRepositoryProvider);
          final bodyRepo = _ref.read(bodyRepositoryProvider);

          final user = await authRepo.getCurrentUser();
          profile = user != null ? await authRepo.getUserProfile(user.id) : null;
          print('✅ [AI CHAT] User profile: ${profile?.name ?? "Guest"}');

          final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
          recentWorkouts = await workoutRepo.getWorkoutsByDateRange(
            thirtyDaysAgo,
            DateTime.now(),
          );
          print('✅ [AI CHAT] Found ${recentWorkouts.length} workouts');

          final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
          nutritionHistory = await nutritionRepo.getNutritionHistory(
            sevenDaysAgo,
            DateTime.now(),
          );
          nutritionTargets = await nutritionRepo.getNutritionTargets();
          print('✅ [AI CHAT] Found ${nutritionHistory.length} nutrition days');

          bodyEntries = await bodyRepo.getBodyEntriesByDateRange(
            thirtyDaysAgo,
            DateTime.now(),
          );
          print('✅ [AI CHAT] Found ${bodyEntries.length} body entries');
        } catch (e) {
          print('⚠️ [AI CHAT] Error gathering user telemetry: $e');
        }
      } else {
        print('🔒 [AI CHAT] Personalization consent DISABLED. Preserving user telemetry privacy.');
      }

      // Build system prompt with user context
      print('🔧 [AI CHAT] Step 2: Building system prompt...');
      final systemPrompt = _buildSystemPrompt(
        hasConsent: hasConsent,
        profile: profile,
        recentWorkouts: recentWorkouts,
        nutritionHistory: nutritionHistory,
        nutritionTargets: nutritionTargets,
        bodyEntries: bodyEntries,
      );
      print('✅ [AI CHAT] System prompt built (${systemPrompt.length} chars)');

      String responseText;
      bool isFallback = false;
      String? errorMessage;
      
      if (!_geminiService.isConfigured) {
        print('⚠️ [AI CHAT] No Gemini API key configured. Using Local AI Coach...');
        isFallback = true;
        errorMessage = 'Gemini API key is not configured. Running offline rule-based coach.';
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
          print('═══════════════════════════════════════');
          print('🤖 [AI CHAT] Step 7: Calling Gemini AI (FREE!)');
          print('📡 [AI CHAT] Sending request to Gemini API...');
          print('═══════════════════════════════════════');
          
          responseText = await _geminiService.sendMessage(
            [{'role': 'user', 'content': message}],
            systemPrompt: systemPrompt,
            temperature: 0.8,
            maxTokens: 8000,
          );
          
          print('═══════════════════════════════════════');
          print('✅ [AI CHAT] Gemini response received!');
          print('📝 [AI CHAT] Response length: ${responseText.length} chars');
          print('═══════════════════════════════════════');
        } catch (e, stackTrace) {
          print('═══════════════════════════════════════');
          print('❌ [AI CHAT ERROR] Gemini API failed!');
          print('🔴 [AI CHAT ERROR] Error type: ${e.runtimeType}');
          print('🔴 [AI CHAT ERROR] Error message: $e');
          print('🔴 [AI CHAT ERROR] Stack trace:');
          print(stackTrace.toString().split('\n').take(10).join('\n'));
          print('═══════════════════════════════════════');
          print('🔄 [AI CHAT] Falling back to LocalAI with transparent warning...');
          
          isFallback = true;
          final errorText = e is GeminiAIServiceException ? e.message : e.toString();
          errorMessage = 'Cloud AI error: $errorText. Responded with local fallback coach.';
          
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
      print('💾 [AI CHAT] Step 8: Saving response to chat...');
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
        print('📊 [Analytics] AI query event logged');
      } catch (e) {
        print('⚠️ [Analytics] Failed to log AI query event: $e');
      }
      
      print('═══════════════════════════════════════');
      print('🎉 [AI CHAT] Message processing complete!');
      print('📊 [AI CHAT] Total messages: ${state.messages.length}');
      print('═══════════════════════════════════════');
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════');
      print('❌❌❌ [AI CHAT FATAL ERROR] ❌❌❌');
      print('🔴 [AI CHAT ERROR] Error type: ${e.runtimeType}');
      print('🔴 [AI CHAT ERROR] Error message: $e');
      print('🔴 [AI CHAT ERROR] Full stack trace:');
      print(stackTrace);
      print('═══════════════════════════════════════');
      
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to generate response: $e',
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
    
    buffer.writeln('You are an expert fitness coach and nutritionist for IronFlow, a comprehensive fitness tracking app.');
    buffer.writeln('Your role is to provide detailed, professional, and evidence-based fitness and nutrition guidance.');
    buffer.writeln();
    buffer.writeln('RESPONSE FORMATTING (CRITICAL):');
    buffer.writeln('- Use Markdown formatting for ALL responses');
    buffer.writeln('- Use **bold** for exercise names, key terms, and important points');
    buffer.writeln('- Use ## for main section headers (e.g., ## Workout Program, ## Nutrition Plan)');
    buffer.writeln('- Use ### for subsections (e.g., ### Day 1: Upper Body)');
    buffer.writeln('- Use bullet points (-) for lists of exercises, tips, or recommendations');
    buffer.writeln('- Use numbered lists (1., 2., 3.) for step-by-step instructions or progression plans');
    buffer.writeln('- Use > for important notes or warnings (e.g., > ⚠️ Important: Always warm up first)');
    buffer.writeln('- Add emojis to make responses more engaging (💪 🏋️ 🥗 📈 ⚡ 🎯 ✅ ⚠️ 💡 🔥)');
    buffer.writeln();
    buffer.writeln('SAFETY AND MEDICAL GUARDRAILS (CRITICAL):');
    buffer.writeln('- You are an AI fitness intelligence core and educational coach, NOT a physician, doctor, or licensed physical therapist.');
    buffer.writeln('- NEVER provide clinical medical diagnoses or prescribe medications.');
    buffer.writeln('- If a user inquires about or reports chest pain, acute joint injury, dizziness, numbness, or severe pain, IMMEDIATELY instruct them to cease exercise and seek professional medical evaluation.');
    buffer.writeln('- Remind users to adhere to proper warmup protocols, progressive overload, and to differentiate between muscular fatigue (good) and joint/ligament strain (stop immediately).');
    buffer.writeln('- All nutritional targets are general guidelines and not tailored medical diets.');
    buffer.writeln();
    buffer.writeln('RESPONSE GUIDELINES:');
    buffer.writeln('- Provide comprehensive, detailed answers that demonstrate deep expertise');
    buffer.writeln('- Use specific numbers, sets, reps, weights, and percentages when relevant');
    buffer.writeln('- Explain the science and reasoning behind your recommendations');
    buffer.writeln('- Structure longer responses with clear sections using markdown headers');
    buffer.writeln('- Be conversational yet professional - like a knowledgeable personal trainer');
    buffer.writeln('- For workout programs: include specific exercises, sets, reps, rest periods, and progression plans');
    buffer.writeln('- For nutrition advice: include specific foods, macros, meal timing, and practical tips');
    buffer.writeln('- For form advice: provide detailed cues and common mistakes to avoid');
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
      buffer.writeln('USER PRIVACY TELEMETRY:');
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
    
    buffer.writeln('COACHING PHILOSOPHY:');
    buffer.writeln('- Provide evidence-based advice grounded in exercise science');
    buffer.writeln('- Be encouraging and motivating while maintaining high standards');
    buffer.writeln('- Give specific, actionable recommendations with clear implementation steps');
    buffer.writeln('- Explain the "why" behind every recommendation to educate the user');
    buffer.writeln('- Use progressive overload principles and periodization concepts');
    buffer.writeln('- Prioritize proper form, injury prevention, and long-term sustainability');
    buffer.writeln('- Adapt advice based on the user\'s experience level and available equipment');
    buffer.writeln('- When creating programs, think like a professional strength coach');
    buffer.writeln('- When giving nutrition advice, think like a registered dietitian');
    
    return buffer.toString();
  }

  Future<void> clearHistory() async {
    state = state.copyWith(messages: []);
    await _chatStorage?.clearMessages();
  }

  void clearError() {
    state = state.copyWith(error: null);
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
