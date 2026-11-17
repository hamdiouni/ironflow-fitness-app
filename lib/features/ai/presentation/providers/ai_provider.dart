import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/providers/analytics_provider.dart';
import 'package:progression_tracker/core/providers/connectivity_provider.dart';
import 'package:progression_tracker/core/providers/language_provider.dart';
import 'package:progression_tracker/core/providers/observability_provider.dart';
import 'package:progression_tracker/core/providers/units_provider.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:progression_tracker/core/utils/local_date_window.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import 'package:progression_tracker/features/ai/data/datasources/ai_chat_storage.dart';
import 'package:progression_tracker/features/ai/data/datasources/ai_transport.dart';
import 'package:progression_tracker/features/ai/data/datasources/gemini_ai_service.dart';
import 'package:progression_tracker/features/ai/data/repositories/ai_preferences_repository_impl.dart';
import 'package:progression_tracker/features/ai/data/services/change_detection_service_impl.dart';
import 'package:progression_tracker/features/ai/domain/entities/chat_message.dart';
import 'package:progression_tracker/features/ai/domain/repositories/ai_preferences_repository.dart';
import 'package:progression_tracker/features/ai/domain/services/ai_coach_action_parser.dart';
import 'package:progression_tracker/features/ai/domain/services/ai_question_normalizer.dart';
import 'package:progression_tracker/features/ai/domain/services/local_ai_coach.dart';
import 'package:progression_tracker/features/ai/presentation/providers/ai_chat_prompt_builder.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart'
    show currentUserIdProvider;
import 'package:progression_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/presentation/providers/body_providers.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/entities.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Provider for local AI coach service (fallback)
final localAICoachProvider = Provider<LocalAICoach>((ref) => LocalAICoach());

/// Provider for Gemini AI service
final geminiAIServiceProvider = Provider<GeminiAIService>((ref) {
  return GeminiAIService(
    isAiCoachEnabled: () =>
        ref.read(featureFlagsSnapshotProvider).isAiCoachActive,
  );
});

/// Provider for AI Question Normalizer and Cache (Wave 6.1 & Wave 7.2 — AI-05)
final aiQuestionNormalizerProvider = Provider<AiQuestionNormalizer>((ref) {
  return AiQuestionNormalizer();
});

/// Provider for AI preferences storage repository
final aiPreferencesRepositoryProvider = Provider<AIPreferencesRepository>((ref) {
  return AIPreferencesRepositoryImpl();
});

/// Notifier for AI personalization consent (Privacy-first: default is false)
final aiPersonalizationConsentProvider =
    NotifierProvider<AIPersonalizationConsentNotifier, bool>(
  AIPersonalizationConsentNotifier.new,
);

class AIPersonalizationConsentNotifier extends Notifier<bool> {
  static const String key = 'ai_personalization_consent';

  AIPersonalizationConsentNotifier({String? userId})
      : _injectedUserId = userId;

  final String? _injectedUserId;
  String? _userId;
  bool _disposed = false;

  String? get userId => _userId;

  @override
  bool build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _userId = _injectedUserId ??
        ref.watch(currentUserIdProvider) ??
        RecordOwnershipRules.guestUserId;
    _loadConsent();
    return false;
  }

  static String keyForUser(String? userId) {
    final scopeUserId = RecordOwnershipRules.normalizeUserId(userId);
    return scopeUserId == null ? key : '${key}_$scopeUserId';
  }

  static Future<bool> loadStoredConsent(
    SharedPreferences prefs, {
    String? userId,
  }) {
    return AIPreferencesRepositoryImpl.loadStoredConsentFromPrefs(
      prefs,
      userId: userId,
    );
  }

  Future<void> _loadConsent() async {
    try {
      final repo = ref.read(aiPreferencesRepositoryProvider);
      final consent = await repo.loadPersonalizationConsent(userId: userId);
      if (!_disposed) state = consent;
    } catch (_) {}
  }

  Future<void> setConsent(bool consent) async {
    state = consent;
    try {
      final repo = ref.read(aiPreferencesRepositoryProvider);
      await repo.savePersonalizationConsent(userId: userId, consent: consent);
    } catch (_) {}
  }

  Future<void> toggle() => setConsent(!state);
}

/// State for AI chat (Wave 7.1–7.5)
class AIChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final String? streamingMessage;
  final bool isOfflineFallback;
  final bool isKeyMissing;
  final String? lastFailedMessage;
  final Set<String> appliedActionIds;
  final int lastInputTokens;
  final int lastOutputTokens;
  final double lastRequestCostUsd;
  final int sessionTotalTokens;
  final double sessionTotalCostUsd;

  AIChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.streamingMessage,
    this.isOfflineFallback = false,
    this.isKeyMissing = false,
    this.lastFailedMessage,
    this.appliedActionIds = const {},
    this.lastInputTokens = 0,
    this.lastOutputTokens = 0,
    this.lastRequestCostUsd = 0.0,
    this.sessionTotalTokens = 0,
    this.sessionTotalCostUsd = 0.0,
  });

  AIChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    String? streamingMessage,
    bool clearStreamingMessage = false,
    bool? isOfflineFallback,
    bool? isKeyMissing,
    String? lastFailedMessage,
    bool clearError = false,
    Set<String>? appliedActionIds,
    int? lastInputTokens,
    int? lastOutputTokens,
    double? lastRequestCostUsd,
    int? sessionTotalTokens,
    double? sessionTotalCostUsd,
  }) {
    return AIChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      streamingMessage: clearStreamingMessage
          ? null
          : (streamingMessage ?? this.streamingMessage),
      isOfflineFallback: isOfflineFallback ?? this.isOfflineFallback,
      isKeyMissing: isKeyMissing ?? this.isKeyMissing,
      lastFailedMessage: lastFailedMessage ?? this.lastFailedMessage,
      appliedActionIds: appliedActionIds ?? this.appliedActionIds,
      lastInputTokens: lastInputTokens ?? this.lastInputTokens,
      lastOutputTokens: lastOutputTokens ?? this.lastOutputTokens,
      lastRequestCostUsd: lastRequestCostUsd ?? this.lastRequestCostUsd,
      sessionTotalTokens: sessionTotalTokens ?? this.sessionTotalTokens,
      sessionTotalCostUsd: sessionTotalCostUsd ?? this.sessionTotalCostUsd,
    );
  }
}

class AIChatNotifier extends Notifier<AIChatState> {
  static const int maxHistoryContextMessages = 10;

  AIChatNotifier({
    LocalAICoach? localCoach,
    GeminiAIService? geminiService,
    AIChatStorage? chatStorage,
    AiQuestionNormalizer? questionNormalizer,
    bool useInjectedStorage = false,
  })  : _injectedLocalCoach = localCoach,
        _injectedGeminiService = geminiService,
        _injectedChatStorage = chatStorage,
        _injectedQuestionNormalizer = questionNormalizer,
        _useInjectedStorage = useInjectedStorage;

  final LocalAICoach? _injectedLocalCoach;
  final GeminiAIService? _injectedGeminiService;
  final AIChatStorage? _injectedChatStorage;
  final AiQuestionNormalizer? _injectedQuestionNormalizer;
  final bool _useInjectedStorage;

  late LocalAICoach _localCoach;
  late GeminiAIService _geminiService;
  late AiQuestionNormalizer _questionNormalizer;
  AIChatStorage? _chatStorage;
  bool _disposed = false;
  final Map<String, Future<void> Function()> _undoCallbacks = {};

  @override
  AIChatState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _localCoach = _injectedLocalCoach ?? ref.watch(localAICoachProvider);
    _geminiService =
        _injectedGeminiService ?? ref.watch(geminiAIServiceProvider);
    _questionNormalizer =
        _injectedQuestionNormalizer ?? ref.watch(aiQuestionNormalizerProvider);
    _chatStorage = _useInjectedStorage
        ? _injectedChatStorage
        : (_injectedChatStorage ?? ref.watch(aiChatStorageProvider));
    _loadHistory();
    return AIChatState(isKeyMissing: !_geminiService.isConfigured);
  }

  Future<void> _loadHistory() async {
    if (_chatStorage == null) return;
    try {
      final history = await _chatStorage!.loadMessages();
      if (history.isNotEmpty && !_disposed) {
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
    if (str.contains('socket') ||
        str.contains('timeout') ||
        str.contains('network') ||
        str.contains('connection')) {
      return 'Could not connect to the fitness assistant. Please check your internet connection and try again.';
    }
    return 'Something went wrong while contacting the coach. Please tap Retry to try again.';
  }

  /// Retries the last failed prompt without duplicating the user's message bubble (Wave 7.2).
  Future<void> retryLastMessage() async {
    final failed = state.lastFailedMessage;
    if (failed != null && failed.trim().isNotEmpty) {
      final hasTrailingUserMessage = state.messages.isNotEmpty &&
          state.messages.last.role == 'user' &&
          state.messages.last.content == failed;
      state = state.copyWith(clearError: true);
      await _sendMessageInternal(
        failed,
        appendUserMessage: !hasTrailingUserMessage,
      );
    }
  }

  List<Map<String, String>> _buildBoundedConversationPayload() {
    final allMessages = state.messages;
    final startIdx = allMessages.length > maxHistoryContextMessages
        ? allMessages.length - maxHistoryContextMessages
        : 0;
    return allMessages
        .sublist(startIdx)
        .map((m) => <String, String>{'role': m.role, 'content': m.content})
        .toList();
  }

  Future<void> sendMessage(String message) =>
      _sendMessageInternal(message, appendUserMessage: true);

  Future<void> _sendMessageInternal(
    String message, {
    required bool appendUserMessage,
  }) async {
    if (message.trim().isEmpty) return;

    var updatedMessages = state.messages;
    if (appendUserMessage) {
      final userMessage = ChatMessage(
        id: const Uuid().v4(),
        role: 'user',
        content: message,
        timestamp: DateTime.now(),
      );
      updatedMessages = [...state.messages, userMessage];
    }

    state = state.copyWith(
      messages: updatedMessages,
      isLoading: true,
      clearError: true,
      clearStreamingMessage: true,
    );
    _chatStorage?.saveMessages(state.messages);

    try {
      final hasConsent = ref.read(aiPersonalizationConsentProvider);
      final units = ref.read(unitsProvider);
      final locale = ref.read(languageProvider);
      final isOnline = ref.read(isOnlineProvider).valueOrNull ?? true;

      UserProfile? profile;
      List<Workout> recentWorkouts = const [];
      List<DailyNutritionSummary> nutritionHistory = const [];
      NutritionTargets? nutritionTargets;
      List<BodyEntry> bodyEntries = const [];

      if (hasConsent) {
        try {
          final authRepo = ref.read(authRepositoryProvider);
          final workoutRepo = ref.read(workoutRepositoryProvider);
          final nutritionRepo = ref.read(nutritionRepositoryProvider);
          final bodyRepo = ref.read(bodyRepositoryProvider);

          final user = await authRepo.getCurrentUser();
          profile =
              user != null ? await authRepo.getUserProfile(user.id) : null;

          final now = DateTime.now();
          final thirtyDaysAgo =
              LocalDateWindow.rollingDaysWindow(30, now: now).start;
          recentWorkouts =
              await workoutRepo.getWorkoutsByDateRange(thirtyDaysAgo, now);

          final sevenDaysAgo =
              LocalDateWindow.rollingDaysWindow(7, now: now).start;
          nutritionHistory =
              await nutritionRepo.getNutritionHistory(sevenDaysAgo, now);
          nutritionTargets = await nutritionRepo.getNutritionTargets();
          bodyEntries =
              await bodyRepo.getBodyEntriesByDateRange(thirtyDaysAgo, now);
        } catch (e) {
          AppLogger.debug('⚠️ [AI CHAT] Error gathering user data: $e');
        }
      }

      final dataEpoch = ChangeDetectionServiceImpl.computeDataEpoch(
        workouts: recentWorkouts,
        nutrition: nutritionHistory,
        bodyEntries: bodyEntries,
      );

      final systemPrompt = _buildSystemPrompt(
        hasConsent: hasConsent,
        units: units,
        profile: profile,
        recentWorkouts: recentWorkouts,
        nutritionHistory: nutritionHistory,
        nutritionTargets: nutritionTargets,
        bodyEntries: bodyEntries,
      );

      String responseText = '';
      bool isFallback = false;
      String? errorMessage;

      final hasProxyAuth = await _geminiService.hasAvailableAuthForProxy();
      final canUseRemoteGemini =
          _geminiService.isConfigured && isOnline && hasProxyAuth;

      final resolution = _questionNormalizer.resolve(
        message,
        includeCanonicalFaqs: !canUseRemoteGemini,
        locale: locale.languageCode,
        units: units.name,
        hasConsent: hasConsent,
        dataEpoch: dataEpoch,
      );

      if (resolution.cachedResponse != null) {
        responseText = resolution.cachedResponse!;
      } else if (!canUseRemoteGemini) {
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
          final historyPayload = _buildBoundedConversationPayload();
          final buffer = StringBuffer();

          await for (final chunk in _geminiService.streamMessage(
            historyPayload,
            systemPrompt: systemPrompt,
            temperature: 0.7,
            maxTokens: AiTransport.defaultMaxOutputTokens,
          )) {
            buffer.write(chunk);
            if (!_disposed) {
              state = state.copyWith(streamingMessage: buffer.toString());
            }
          }

          responseText = buffer.toString().trim();
          if (responseText.isEmpty) {
            responseText = await _geminiService.sendMessage(
              historyPayload,
              systemPrompt: systemPrompt,
              temperature: 0.7,
              maxTokens: AiTransport.defaultMaxOutputTokens,
            );
          }

          _questionNormalizer.cacheResponse(
            message,
            responseText,
            locale: locale.languageCode,
            units: units.name,
            hasConsent: hasConsent,
            dataEpoch: dataEpoch,
          );
        } catch (e) {
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

      final inTokens = AiCostEstimator.estimateTokenCount(
        '$systemPrompt\n$message',
      );
      final outTokens = AiCostEstimator.estimateTokenCount(responseText);
      final cost = AiCostEstimator.calculateCostUsd(
        inputTokens: inTokens,
        outputTokens: outTokens,
      );

      final assistantMessage = ChatMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        content: responseText,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
        clearStreamingMessage: true,
        isOfflineFallback: isFallback,
        error: errorMessage,
        lastFailedMessage: errorMessage != null ? message : null,
        lastInputTokens: inTokens,
        lastOutputTokens: outTokens,
        lastRequestCostUsd: cost,
        sessionTotalTokens: state.sessionTotalTokens + inTokens + outTokens,
        sessionTotalCostUsd: state.sessionTotalCostUsd + cost,
      );
      _chatStorage?.saveMessages(state.messages);

      try {
        final analytics = ref.read(analyticsServiceProvider);
        await analytics.logAIQuery(
          queryType: 'chat',
          query: message,
          responseLength: responseText.length,
        );
      } catch (_) {}
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearStreamingMessage: true,
        error: _formatErrorMessage(e),
        lastFailedMessage: message,
      );
    }
  }

  /// Estimates meal macros from a transient base64 photo through the proxy
  /// with consent verification, zero photo storage, and an explicit `"ESTIMATE"`
  /// `"Tap to apply"` card (Wave 7.3 — ADR-003).
  Future<void> estimateMealPhoto({
    required String base64Image,
    String mimeType = 'image/jpeg',
    String? mealHint,
  }) async {
    final hasConsent = ref.read(aiPersonalizationConsentProvider);
    if (!hasConsent) {
      state = state.copyWith(
        error:
            'Personalization consent is required before estimating meal macros from a photo.',
      );
      return;
    }

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: 'user',
      content: mealHint != null && mealHint.trim().isNotEmpty
          ? '📷 Estimate meal macros: ${mealHint.trim()}'
          : '📷 Estimate meal macros from photo (transient, not stored)',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      clearError: true,
    );

    String responseText;
    final isOnline = ref.read(isOnlineProvider).valueOrNull ?? true;
    final hasProxyAuth = await _geminiService.hasAvailableAuthForProxy();

    if (_geminiService.isConfigured && isOnline && hasProxyAuth) {
      try {
        responseText = await _geminiService.estimateMealFromPhoto(
          base64Image: base64Image,
          mimeType: mimeType,
        );
      } catch (_) {
        responseText = AiChatPromptBuilder.buildFallbackMealPhotoEstimate(mealHint);
      }
    } else {
      responseText = AiChatPromptBuilder.buildFallbackMealPhotoEstimate(mealHint);
    }

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
    _chatStorage?.saveMessages(state.messages);
  }

  /// Applies a validated [AiCoachAction] on explicit user tap and registers a
  /// 1-tap `Undo` callback (Wave 7.3 — ADR-003).
  Future<String?> applyCoachAction(AiCoachAction action) async {
    final activeUserId = ref.read(currentUserIdProvider);
    if (!action.isOwnedBy(activeUserId)) {
      return 'Action rejected: ownership mismatch for current account.';
    }

    switch (action.type) {
      case AiCoachActionType.saveProgram:
        final programRepo = ref.read(activeProgramRepositoryProvider);
        final priorProgram = await programRepo.loadActiveProgram();
        final newProgram = WorkoutProgram(
          id: 'ai_prog_${const Uuid().v4()}',
          name: action.programName ?? 'AI Custom Program',
          description: action.summary,
          difficulty: action.difficulty ?? 'Intermediate',
          durationWeeks: action.durationWeeks ?? 8,
          days: action.programDays
              .map(
                (d) => ProgramDay(
                  dayNumber: d.dayNumber,
                  name: d.name,
                  focus: d.focus,
                  isRestDay: d.isRestDay,
                  exercises: d.exercises
                      .map(
                        (e) => ProgramExercise(
                          exerciseName: e.exerciseName,
                          exerciseDefinitionId: e.canonicalExerciseId,
                          sets: e.sets,
                          reps: e.reps,
                          restSeconds: e.restSeconds,
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        );
        final active = ActiveProgram(
          id: 'active_${const Uuid().v4()}',
          program: newProgram,
          currentDayIndex: 0,
          isActive: true,
          userId: activeUserId,
          updatedAt: DateTime.now(),
        );
        await programRepo.saveActiveProgram(active);
        ref.invalidate(activeProgramProvider);

        _undoCallbacks[action.id] = () async {
          if (priorProgram != null) {
            await programRepo.saveActiveProgram(priorProgram);
          } else {
            await programRepo.clearActiveProgram();
          }
          ref.invalidate(activeProgramProvider);
        };
        break;

      case AiCoachActionType.swapExercise:
        final programRepo = ref.read(activeProgramRepositoryProvider);
        final currentActive = await programRepo.loadActiveProgram();
        if (currentActive == null) {
          return 'No active program found to swap exercises in.';
        }
        final updatedDays = currentActive.program.days.map((day) {
          final updatedEx = day.exercises.map((ex) {
            if (ex.exerciseName.toLowerCase() ==
                (action.fromExercise ?? '').toLowerCase()) {
              return ex.copyWith(
                exerciseName: action.toExercise ?? ex.exerciseName,
                exerciseDefinitionId:
                    action.toCanonicalExerciseId ?? ex.exerciseDefinitionId,
              );
            }
            return ex;
          }).toList();
          return day.copyWith(exercises: updatedEx);
        }).toList();

        final updatedActive = currentActive.copyWith(
          program: currentActive.program.copyWith(days: updatedDays),
          updatedAt: DateTime.now(),
        );
        await programRepo.saveActiveProgram(updatedActive);
        ref.invalidate(activeProgramProvider);

        _undoCallbacks[action.id] = () async {
          await programRepo.saveActiveProgram(currentActive);
          ref.invalidate(activeProgramProvider);
        };
        break;

      case AiCoachActionType.logMeal:
        final nutritionRepo = ref.read(nutritionRepositoryProvider);
        final mealId = const Uuid().v4();
        final meal = Meal(
          id: mealId,
          name: action.isEstimate
              ? '${action.mealName} (Estimate)'
              : (action.mealName ?? 'Logged Meal'),
          macros: MealMacros(
            calories: action.calories ?? 0,
            protein: action.proteinG ?? 0,
            carbs: action.carbsG ?? 0,
            fats: action.fatsG ?? 0,
          ),
          micros: const MealMicros(fiber: 0, sugar: 0, sodium: 0, potassium: 0),
          vitamins: const MealVitamins(
            vitaminA: 0,
            vitaminB: 0,
            vitaminC: 0,
            vitaminD: 0,
            vitaminE: 0,
          ),
          minerals: const MealMinerals(
            calcium: 0,
            iron: 0,
            magnesium: 0,
            zinc: 0,
          ),
          timestamp: DateTime.now(),
          userId: activeUserId,
          updatedAt: DateTime.now(),
        );
        await nutritionRepo.saveMealEntry(meal);
        ref.invalidate(dailyNutritionSummaryProvider(todayNutritionDayKey()));

        _undoCallbacks[action.id] = () async {
          await nutritionRepo.deleteMealEntry(mealId);
          ref.invalidate(dailyNutritionSummaryProvider(todayNutritionDayKey()));
        };
        break;
    }

    state = state.copyWith(
      appliedActionIds: {...state.appliedActionIds, action.id},
    );
    return null;
  }

  /// Reverts a previously applied [AiCoachAction] by [actionId] (Wave 7.3).
  Future<bool> undoCoachAction(String actionId) async {
    final undo = _undoCallbacks.remove(actionId);
    if (undo == null) return false;
    await undo();
    final nextApplied = Set<String>.from(state.appliedActionIds)
      ..remove(actionId);
    state = state.copyWith(appliedActionIds: nextApplied);
    return true;
  }

  String _buildSystemPrompt({
    bool hasConsent = false,
    UnitsSystem units = UnitsSystem.metric,
    UserProfile? profile,
    List<Workout> recentWorkouts = const [],
    List<DailyNutritionSummary> nutritionHistory = const [],
    NutritionTargets? nutritionTargets,
    List<BodyEntry> bodyEntries = const [],
  }) =>
      AiChatPromptBuilder.buildSystemPrompt(
        hasConsent: hasConsent,
        units: units,
        profile: profile,
        recentWorkouts: recentWorkouts,
        nutritionHistory: nutritionHistory,
        nutritionTargets: nutritionTargets,
        bodyEntries: bodyEntries,
      );

  Future<void> clearHistory() async {
    _undoCallbacks.clear();
    state = state.copyWith(messages: [], appliedActionIds: const {});
    await _chatStorage?.clearMessages();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for AI chat notifier
final aiChatProvider = NotifierProvider<AIChatNotifier, AIChatState>(
  AIChatNotifier.new,
);
