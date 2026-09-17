import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/features/ai/domain/entities/chat_message.dart';
import 'package:progression_tracker/features/ai/domain/services/local_ai_coach.dart';
import 'package:progression_tracker/features/ai/data/datasources/gemini_ai_service.dart';
import 'package:uuid/uuid.dart';

// Import existing providers from their respective modules
import 'package:progression_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:progression_tracker/features/body/presentation/providers/body_providers.dart';
import 'package:progression_tracker/core/providers/analytics_provider.dart';

/// Provider for local AI coach service (fallback)
final localAICoachProvider = Provider<LocalAICoach>((ref) {
  return LocalAICoach();
});

/// Provider for Gemini AI service (FREE!)
final geminiAIServiceProvider = Provider<GeminiAIService>((ref) {
  return GeminiAIService();
});

/// State for AI chat
class AIChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String? streamingMessage;

  AIChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.streamingMessage,
  });

  AIChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? streamingMessage,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      streamingMessage: streamingMessage,
    );
  }
}

/// Notifier for AI chat
class AIChatNotifier extends StateNotifier<AIChatState> {
  final LocalAICoach _localCoach;
  final GeminiAIService _geminiService;
  final Ref _ref;

  AIChatNotifier({
    required LocalAICoach localCoach,
    required GeminiAIService geminiService,
    required Ref ref,
  })  : _localCoach = localCoach,
        _geminiService = geminiService,
        _ref = ref,
        super(AIChatState());

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

    try {
      print('═══════════════════════════════════════');
      print('🚀 [AI CHAT] Starting message processing');
      print('📝 [AI CHAT] User message: $message');
      print('═══════════════════════════════════════');
      
      // Gather user data from repositories
      print('📊 [AI CHAT] Step 1: Gathering user data...');
      final authRepo = _ref.read(authRepositoryProvider);
      final workoutRepo = _ref.read(workoutRepositoryProvider);
      final activeProgramRepo = _ref.read(activeProgramRepositoryProvider);
      final nutritionRepo = _ref.read(nutritionRepositoryProvider);
      final bodyRepo = _ref.read(bodyRepositoryProvider);

      // Get current user
      print('👤 [AI CHAT] Step 2: Getting user profile...');
      final user = await authRepo.getCurrentUser();
      final profile = user != null ? await authRepo.getUserProfile(user.id) : null;
      print('✅ [AI CHAT] User profile: ${profile?.name ?? "Guest"}');

      // Get recent workouts (last 30 days)
      print('🏋️ [AI CHAT] Step 3: Getting recent workouts...');
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentWorkouts = await workoutRepo.getWorkoutsByDateRange(
        thirtyDaysAgo,
        DateTime.now(),
      );
      print('✅ [AI CHAT] Found ${recentWorkouts.length} workouts');

      // Get nutrition history (last 7 days)
      print('🍎 [AI CHAT] Step 4: Getting nutrition history...');
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final nutritionHistory = await nutritionRepo.getNutritionHistory(
        sevenDaysAgo,
        DateTime.now(),
      );
      final nutritionTargets = await nutritionRepo.getNutritionTargets();
      print('✅ [AI CHAT] Found ${nutritionHistory.length} nutrition days');

      // Get body entries (last 30 days)
      print('📏 [AI CHAT] Step 5: Getting body measurements...');
      final bodyEntries = await bodyRepo.getBodyEntriesByDateRange(
        thirtyDaysAgo,
        DateTime.now(),
      );
      print('✅ [AI CHAT] Found ${bodyEntries.length} body entries');

      // Build system prompt with user context
      print('🔧 [AI CHAT] Step 6: Building system prompt...');
      final systemPrompt = _buildSystemPrompt(
        profile: profile,
        recentWorkouts: recentWorkouts,
        nutritionHistory: nutritionHistory,
        nutritionTargets: nutritionTargets,
        bodyEntries: bodyEntries,
      );
      print('✅ [AI CHAT] System prompt built (${systemPrompt.length} chars)');

      String responseText;
      
      try {
        print('═══════════════════════════════════════');
        print('🤖 [AI CHAT] Step 7: Calling Gemini AI (FREE!)');
        print('📡 [AI CHAT] Sending request to Gemini API...');
        print('═══════════════════════════════════════');
        
        responseText = await _geminiService.sendMessage(
          [{'role': 'user', 'content': message}],
          systemPrompt: systemPrompt,
          temperature: 0.8,
          maxTokens: 8000, // Increased from 2000 to 8000 for longer, complete responses
        );
        
        print('═══════════════════════════════════════');
        print('✅ [AI CHAT] Gemini response received!');
        print('📝 [AI CHAT] Response length: ${responseText.length} chars');
        print('💬 [AI CHAT] Response preview: ${responseText.substring(0, responseText.length > 100 ? 100 : responseText.length)}...');
        print('═══════════════════════════════════════');
      } catch (e, stackTrace) {
        print('═══════════════════════════════════════');
        print('❌ [AI CHAT ERROR] Gemini API failed!');
        print('🔴 [AI CHAT ERROR] Error type: ${e.runtimeType}');
        print('🔴 [AI CHAT ERROR] Error message: $e');
        print('🔴 [AI CHAT ERROR] Stack trace:');
        print(stackTrace.toString().split('\n').take(10).join('\n'));
        print('═══════════════════════════════════════');
        print('🔄 [AI CHAT] Falling back to LocalAI...');
        
        responseText = _localCoach.generateResponse(
          message,
          profile: profile,
          recentWorkouts: recentWorkouts,
          nutritionHistory: nutritionHistory,
          nutritionTargets: nutritionTargets,
          bodyEntries: bodyEntries,
        );
        
        print('✅ [AI CHAT] LocalAI response generated');
        print('📝 [AI CHAT] Response length: ${responseText.length} chars');
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
      );
      
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

  /// Build system prompt with user context
  String _buildSystemPrompt({
    dynamic profile,
    List<dynamic> recentWorkouts = const [],
    List<dynamic> nutritionHistory = const [],
    dynamic nutritionTargets,
    List<dynamic> bodyEntries = const [],
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('You are an expert fitness coach and nutritionist for IronFlow, a comprehensive fitness tracking app.');
    buffer.writeln('Your role is to provide detailed, professional, and highly personalized fitness and nutrition guidance.');
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
    
    // Add user profile context
    if (profile != null) {
      buffer.writeln('USER PROFILE:');
      buffer.writeln('- Name: ${profile.name ?? "User"}');
      
      // Handle goals (it's a List<String>?, not a single goal)
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
    }
    
    // Add workout context
    if (recentWorkouts.isNotEmpty) {
      buffer.writeln('RECENT ACTIVITY:');
      buffer.writeln('- ${recentWorkouts.length} workouts in last 30 days');
      buffer.writeln();
    } else {
      buffer.writeln('RECENT ACTIVITY:');
      buffer.writeln('- No workouts logged yet (new user)');
      buffer.writeln();
    }
    
    // Add nutrition context
    if (nutritionHistory.isNotEmpty) {
      buffer.writeln('NUTRITION:');
      buffer.writeln('- Tracking nutrition for ${nutritionHistory.length} days');
      if (nutritionTargets != null) {
        buffer.writeln('- Has nutrition targets set');
      }
      buffer.writeln();
    }
    
    // Add body tracking context
    if (bodyEntries.isNotEmpty) {
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
    ref: ref,
  );
});
