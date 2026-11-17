import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/providers/connectivity_provider.dart';
import 'package:progression_tracker/features/ai/data/datasources/ai_transport.dart';
import 'package:progression_tracker/features/ai/data/datasources/gemini_ai_service.dart';
import 'package:progression_tracker/features/ai/data/services/ai_insight_metrics_calculator.dart';
import 'package:progression_tracker/features/ai/data/services/change_detection_service_impl.dart';
import 'package:progression_tracker/features/ai/data/services/tts_service.dart';
import 'package:progression_tracker/features/ai/domain/services/ai_coach_action_parser.dart';
import 'package:progression_tracker/features/ai/domain/services/ai_coach_eval_rubric.dart';
import 'package:progression_tracker/features/ai/domain/services/ai_question_normalizer.dart';
import 'package:progression_tracker/features/ai/domain/services/local_ai_coach.dart';
import 'package:progression_tracker/features/ai/presentation/providers/ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/tts_provider.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/chat/ai_chat_message_bubble.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/chat/ai_tts_settings_sheet.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart'
    show currentUserIdProvider;
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/meal.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise.dart';
import 'package:progression_tracker/features/workout/domain/entities/exercise_type.dart';
import 'package:progression_tracker/features/workout/domain/entities/set_entry.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _InMemoryWorkoutRepo implements WorkoutRepository {
  List<Workout> workouts = [];

  @override
  Future<List<Workout>> getWorkoutsPaginated({
    int offset = 0,
    int limit = 20,
  }) async {
    if (offset >= workouts.length) return const [];
    final end = (offset + limit).clamp(0, workouts.length);
    return workouts.sublist(offset, end);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _InMemoryNutritionRepo implements NutritionRepository {
  List<DailyNutritionSummary> history = [];
  final List<Meal> loggedMeals = [];

  @override
  Future<DailyNutritionSummary> getDailyNutrition(DateTime date) async {
    return DailyNutritionSummary(
      date: date,
      meals: List<Meal>.from(loggedMeals),
      target: null,
    );
  }

  @override
  Future<List<DailyNutritionSummary>> getNutritionHistoryPaginated({
    int offset = 0,
    int limit = 20,
  }) async {
    if (offset >= history.length) return const [];
    final end = (offset + limit).clamp(0, history.length);
    return history.sublist(offset, end);
  }

  @override
  Future<void> saveMealEntry(Meal meal) async {
    loggedMeals.add(meal);
  }

  @override
  Future<void> deleteMealEntry(String id) async {
    loggedMeals.removeWhere((m) => m.id == id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _InMemoryBodyRepo implements BodyRepository {
  List<BodyEntry> entries = [];

  @override
  Future<List<BodyEntry>> getAllBodyEntries() async => entries;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubTtsNotifier extends TtsNotifier {
  _StubTtsNotifier(this._initialState);
  final TtsState _initialState;

  @override
  TtsState build() => _initialState;
}

class _FakeFlutterTts implements FlutterTts {
  final List<String> spokenTexts = [];
  String? lastLanguage;
  double? lastRate;
  double? lastPitch;
  @override
  VoidCallback? startHandler;
  @override
  VoidCallback? completionHandler;
  @override
  VoidCallback? pauseHandler;
  @override
  VoidCallback? continueHandler;
  @override
  VoidCallback? cancelHandler;

  @override
  Future<dynamic> setLanguage(String language) async {
    lastLanguage = language;
    return 1;
  }

  @override
  Future<dynamic> setSpeechRate(double rate) async {
    lastRate = rate;
    return 1;
  }

  @override
  Future<dynamic> setVolume(double volume) async => 1;

  @override
  Future<dynamic> setPitch(double pitch) async {
    lastPitch = pitch;
    return 1;
  }

  @override
  Future<dynamic> get getVoices async => [
    {'name': 'Samantha', 'locale': 'en-US'},
    {'name': 'Monica', 'locale': 'es-ES'},
  ];

  @override
  Future<dynamic> get getLanguages async => ['en-US', 'es-ES', 'fr-FR'];

  @override
  void setStartHandler(VoidCallback callback) => startHandler = callback;

  @override
  void setCompletionHandler(VoidCallback callback) =>
      completionHandler = callback;

  @override
  void setCancelHandler(VoidCallback callback) => cancelHandler = callback;

  @override
  void setPauseHandler(VoidCallback callback) => pauseHandler = callback;

  @override
  void setContinueHandler(VoidCallback callback) => continueHandler = callback;

  @override
  void setProgressHandler(
    void Function(String text, int start, int end, String word) callback,
  ) {}

  @override
  void setErrorHandler(void Function(dynamic message) callback) {}

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    spokenTexts.add(text);
    startHandler?.call();
    return 1;
  }

  @override
  Future<dynamic> pause() async {
    pauseHandler?.call();
    return 1;
  }

  @override
  Future<dynamic> stop() async {
    cancelHandler?.call();
    return 1;
  }

  @override
  Future<dynamic> setVoice(Map<String, String> voice) async => 1;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('Wave 7.1 — End-to-End SSE Streaming, Native systemInstruction & Safety', () {
    test('GeminiAIService.streamMessage reads StreamedResponse SSE chunks incrementally with native systemInstruction and BLOCK_MEDIUM_AND_ABOVE', () async {
      Map<String, dynamic>? capturedRequestJson;

      final mockClient = MockClient.streaming((request, bodyStream) async {
        final rawBody = await bodyStream.bytesToString();
        capturedRequestJson = jsonDecode(rawBody) as Map<String, dynamic>;

        final controller = StreamController<List<int>>();
        Future<void>.microtask(() async {
          controller.add(
            utf8.encode(
              'data: {"candidates":[{"content":{"parts":[{"text":" Progressive "}]}}]}\n\n',
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 5));
          controller.add(
            utf8.encode(
              'data: {"candidates":[{"content":{"parts":[{"text":"overload works."}]}}]}\n\n',
            ),
          );
          controller.add(utf8.encode('data: [DONE]\n\n'));
          await controller.close();
        });

        return http.StreamedResponse(
          controller.stream,
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      });

      final service = GeminiAIService(
        proxyUrl: 'https://us-central1-ironflow.cloudfunctions.net/aiGenerate',
        authTokenProvider: () async => 'firebase-jwt-token',
        appCheckTokenProvider: () async => 'appcheck-token',
        httpClient: mockClient,
      );

      final chunks = await service
          .streamMessage(
            const [
              {'role': 'user', 'content': 'How do I get stronger?'},
            ],
            systemPrompt: 'Coach system prompt.',
          )
          .toList();

      expect(chunks, equals([' Progressive ', 'overload works.']));
      expect(capturedRequestJson, isNotNull);
      expect(capturedRequestJson!['stream'], isTrue);
      // Native systemInstruction instead of fake user/model turns
      expect(
        capturedRequestJson!['systemInstruction'],
        equals({
          'parts': [
            {'text': 'Coach system prompt.'},
          ],
        }),
      );
      final contents = capturedRequestJson!['contents'] as List<dynamic>;
      expect(contents.length, 1);
      // Unified maxOutputTokens
      final genConfig =
          capturedRequestJson!['generationConfig'] as Map<String, dynamic>;
      expect(
        genConfig['maxOutputTokens'],
        equals(AiTransport.defaultMaxOutputTokens),
      );
      // Responsible safety thresholds (never BLOCK_NONE)
      final safety = capturedRequestJson!['safetySettings'] as List<dynamic>;
      expect(safety, isNotEmpty);
      for (final item in safety) {
        final map = item as Map<String, dynamic>;
        expect(map['threshold'], equals('BLOCK_MEDIUM_AND_ABOVE'));
      }
    });

    test('GeminiAIService.estimateMealFromPhoto sends inlineData and handles HTTP errors and non-SSE stream fallback', () async {
      Map<String, dynamic>? capturedMealRequest;
      final client = MockClient((request) async {
        capturedMealRequest = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': '{"type":"log_meal","mealName":"Oats","calories":350,"proteinG":15,"carbsG":55,"fatsG":7,"isEstimate":true}'},
                  ],
                },
              },
            ],
          }),
          200,
        );
      });

      final service = GeminiAIService(
        proxyUrl: 'https://us-central1-ironflow.cloudfunctions.net/aiGenerate',
        authTokenProvider: () async => 'jwt',
        appCheckTokenProvider: () async => 'appcheck',
        httpClient: client,
      );

      final result = await service.estimateMealFromPhoto(
        base64Image: 'aGVsbG8=',
        mimeType: 'image/png',
        systemPrompt: 'Nutrition estimator',
      );
      expect(result, contains('Oats'));
      expect(capturedMealRequest, isNotNull);

      // Non-SSE stream fallback on standard JSON response
      final fallbackChunks = await service
          .streamMessage(const [
            {'role': 'system', 'content': 'Rule 1'},
            {'role': 'assistant', 'content': 'Prior reply'},
            {'role': 'user', 'content': 'Hi'},
          ])
          .toList();
      expect(fallbackChunks, isNotEmpty);

      // Empty base64 throws INVALID_MEDIA_FORMAT
      expect(
        () => service.estimateMealFromPhoto(base64Image: '   '),
        throwsA(isA<GeminiAIServiceException>()),
      );
    });
  });

  group('Wave 7.2 — Composite Cache Keys, Edit/Delete Change Detection, Alias PRs & Retry/Offline Fixes', () {
    test('AiQuestionNormalizer isolates cache entries by locale, units, consent, and dataEpoch', () {
      final normalizer = AiQuestionNormalizer();

      normalizer.cacheResponse(
        'How should I structure my bench press sets?',
        'Use 3x5 at 80 kg.',
        locale: 'en',
        units: 'metric',
        hasConsent: true,
        dataEpoch: 101,
      );

      // Same context hits cache
      final hit = normalizer.resolve(
        'How should I structure my bench press sets?',
        locale: 'en',
        units: 'metric',
        hasConsent: true,
        dataEpoch: 101,
      );
      expect(hit.cachedResponse, 'Use 3x5 at 80 kg.');

      // Different units or dataEpoch misses cache
      final missUnits = normalizer.resolve(
        'How should I structure my bench press sets?',
        locale: 'en',
        units: 'imperial',
        hasConsent: true,
        dataEpoch: 101,
      );
      expect(missUnits.cachedResponse, isNull);

      final missEpoch = normalizer.resolve(
        'How should I structure my bench press sets?',
        locale: 'en',
        units: 'metric',
        hasConsent: true,
        dataEpoch: 102,
      );
      expect(missEpoch.cachedResponse, isNull);
    });

    test('ChangeDetectionServiceImpl detects in-place edits (updatedAt) and deletions (count change)', () async {
      final workoutRepo = _InMemoryWorkoutRepo();
      final nutritionRepo = _InMemoryNutritionRepo();
      final bodyRepo = _InMemoryBodyRepo();

      final detector = ChangeDetectionServiceImpl(
        workoutRepository: workoutRepo,
        nutritionRepository: nutritionRepo,
        bodyRepository: bodyRepo,
      );

      final baseDate = DateTime(2026, 6, 1, 10, 0);
      final lastGenerated = DateTime(2026, 6, 10, 12, 0);

      // 1. Two older workouts before lastGenerated -> first check records count=2, returns false
      workoutRepo.workouts = [
        Workout(
          id: 'w1',
          date: baseDate,
          duration: const Duration(minutes: 45),
          totalVolume: 1000,
          exercises: const [],
        ),
        Workout(
          id: 'w2',
          date: baseDate.add(const Duration(days: 1)),
          duration: const Duration(minutes: 45),
          totalVolume: 1200,
          exercises: const [],
        ),
      ];
      expect(await detector.hasWorkoutDataChanged(lastGenerated), isFalse);

      // 2. Edit an older workout (date is still June 1, but updatedAt is after lastGenerated)
      workoutRepo.workouts = [
        workoutRepo.workouts[0].copyWith(
          updatedAt: lastGenerated.add(const Duration(minutes: 5)),
        ),
        workoutRepo.workouts[1],
      ];
      expect(await detector.hasWorkoutDataChanged(lastGenerated), isTrue);

      // 3. Delete the top workout (top ID changes from w1 to w2, even with old dates)
      workoutRepo.workouts = [
        Workout(
          id: 'w2',
          date: baseDate,
          duration: const Duration(minutes: 45),
          totalVolume: 1000,
          exercises: const [],
        ),
      ];
      expect(await detector.hasWorkoutDataChanged(lastGenerated), isTrue);
    });

    test('AIInsightMetricsCalculator resolves exercise aliases via ExerciseCatalog for PR detection', () {
      const calc = AIInsightMetricsCalculator();
      final d1 = DateTime(2026, 6, 1);
      final d2 = DateTime(2026, 6, 8);

      final history = [
        Workout(
          id: 'w-old',
          date: d1,
          duration: const Duration(minutes: 45),
          totalVolume: 1000,
          exercises: [
            Exercise(
              id: 'e1',
              name: 'Barbell Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(id: 's1', reps: 5, weight: 100, timestamp: d1),
              ],
            ),
          ],
        ),
        Workout(
          id: 'w-new',
          date: d2,
          duration: const Duration(minutes: 45),
          totalVolume: 1050,
          exercises: [
            Exercise(
              id: 'e2',
              // Logged under alias "BB Bench Press"
              name: 'BB Bench Press',
              type: ExerciseType.strength,
              sets: [
                SetEntry(id: 's2', reps: 5, weight: 105, timestamp: d2),
              ],
            ),
          ],
        ),
      ];

      expect(
        calc.detectPR(history, specificExercise: 'Barbell Bench Press'),
        isTrue,
      );
      final prDetails = calc.getPRDetails(history);
      expect(prDetails['Bench Press'], 105.0);
      expect(prDetails['BB Bench Press'], 105.0);
    });

    test('retryLastMessage does not duplicate user message and offline proxy avoids 401 call', () async {
      var httpCallCount = 0;
      final failingClient = MockClient((request) async {
        httpCallCount++;
        return http.Response('{"error":{"message":"Unauthorized"}}', 401);
      });

      // Service with proxy URL but NO auth token available -> hasAvailableAuthForProxy is false
      final unauthProxyService = GeminiAIService(
        proxyUrl: 'https://us-central1-ironflow.cloudfunctions.net/aiGenerate',
        authTokenProvider: () async => null,
        httpClient: failingClient,
      );

      final container = ProviderContainer(
        overrides: [
          geminiAIServiceProvider.overrideWithValue(unauthProxyService),
          isOnlineProvider.overrideWith((ref) => Stream.value(false)),
          currentUserIdProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(aiChatProvider.notifier);
      await notifier.sendMessage('Give me a quick workout tip');

      // Because auth token is null / offline, zero HTTP requests were made (no 401!)
      expect(httpCallCount, 0);
      final stateAfterFirst = container.read(aiChatProvider);
      expect(stateAfterFirst.messages.length, 2);
      expect(stateAfterFirst.isOfflineFallback, isTrue);

      // Verify exercise_image_database.dart was retired per Owner Decision A1
      expect(
        File('lib/features/ai/domain/services/exercise_image_database.dart')
            .existsSync(),
        isFalse,
      );
    });
  });

  group('Wave 7.3 — Structured "Tap to apply" Actions with Ownership, Undo & Meal-Photo Estimate', () {
    test('AiCoachActionParser validates schemas and rejects mismatched userId ownership', () {
      const responseWithActions = '''
Here is your meal estimate and exercise swap:

```json
[
  {
    "type": "log_meal",
    "id": "act_meal_1",
    "mealName": "Grilled Salmon & Rice",
    "calories": 640,
    "proteinG": 48,
    "carbsG": 62,
    "fatsG": 21,
    "isEstimate": true
  },
  {
    "type": "swap_exercise",
    "id": "act_swap_foreign",
    "userId": "other_user_999",
    "fromExercise": "Barbell Bench Press",
    "toExercise": "Dumbbell Bench Press"
  }
]
```

**Next Step:** Tap Apply on the card below to log your meal.
''';

      final parsed = AiCoachActionParser.parse(
        responseWithActions,
        currentUserId: 'user_alice',
      );

      // Foreign userId action rejected; valid log_meal action kept
      expect(parsed.actions.length, 1);
      final mealAction = parsed.actions.first;
      expect(mealAction.type, AiCoachActionType.logMeal);
      expect(mealAction.mealName, 'Grilled Salmon & Rice');
      expect(mealAction.isEstimate, isTrue);
      expect(parsed.displayMarkdown.contains('"type": "log_meal"'), isFalse);
    });

    testWidgets('AIChatBubble renders "Tap to apply" card with ESTIMATE badge and applies + undoes on tap', (tester) async {
      final nutritionRepo = _InMemoryNutritionRepo();

      const assistantContent = '''
Estimated macros for your post-workout meal:

```json
{
  "type": "log_meal",
  "id": "meal_card_1",
  "mealName": "Chicken Rice Bowl",
  "calories": 580,
  "proteinG": 45,
  "carbsG": 60,
  "fatsG": 14,
  "isEstimate": true
}
```

**Next Step:** Review the portions and tap Apply.
''';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            nutritionRepositoryProvider.overrideWithValue(nutritionRepo),
            currentUserIdProvider.overrideWithValue('user_alice'),
            ttsProvider.overrideWith(() => _StubTtsNotifier(const TtsState())),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: AIChatBubble(
                  role: 'assistant',
                  content: assistantContent,
                  timestamp: DateTime(2026, 6, 15, 12, 0),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Must NOT auto-apply before user taps!
      expect(nutritionRepo.loggedMeals, isEmpty);
      expect(find.text('ESTIMATE'), findsOneWidget);
      final applyButton = find.byKey(const Key('ai_action_apply_meal_card_1'));
      expect(applyButton, findsOneWidget);

      // Tap to apply
      await tester.tap(applyButton);
      await tester.pump();

      expect(nutritionRepo.loggedMeals.length, 1);
      expect(
        nutritionRepo.loggedMeals.first.name,
        'Chicken Rice Bowl (Estimate)',
      );

      // Undo button appears and reverts the logged meal on tap
      final undoButton = find.byKey(const Key('ai_action_undo_meal_card_1'));
      expect(undoButton, findsOneWidget);
      await tester.tap(undoButton);
      await tester.pump();

      expect(nutritionRepo.loggedMeals, isEmpty);
    });
  });

  group('Wave 7.4 — Voice TTS Language Sync, Real Resume & Dropdown Guard', () {
    test('TtsService maps all 7 supported locales, syncs language, and resumes from paused character offset', () async {
      expect(TtsService.resolveLanguageTag('en'), 'en-US');
      expect(TtsService.resolveLanguageTag('es'), 'es-ES');
      expect(TtsService.resolveLanguageTag('fr'), 'fr-FR');
      expect(TtsService.resolveLanguageTag('de'), 'de-DE');
      expect(TtsService.resolveLanguageTag('pt'), 'pt-BR');
      expect(TtsService.resolveLanguageTag('ja'), 'ja-JP');
      expect(TtsService.resolveLanguageTag('zh'), 'zh-CN');

      final fakeTts = _FakeFlutterTts();
      final service = TtsService(flutterTts: fakeTts);
      var stateNotifications = 0;
      service.onStateChanged = () => stateNotifications++;

      await service.initialize(languageCode: 'en');
      expect(service.currentLanguageTag, 'en-US');
      expect(service.availableVoices, contains('Samantha'));

      await service.syncWithAppLanguage('es');
      expect(service.currentLanguageTag, 'es-ES');
      expect(fakeTts.lastLanguage, 'es-ES');

      await service.speak('First sentence here. Second sentence follows.');
      expect(service.isSpeaking, isTrue);
      expect(fakeTts.spokenTexts.last, 'First sentence here. Second sentence follows.');

      // Advance progress offset to character 21 ("Second sentence follows.")
      service.updateProgressForTest(21);
      await service.pause();
      expect(service.isPaused, isTrue);
      expect(service.remainingResumePreview, 'Second sentence follows.');

      await service.resume();
      expect(service.isPaused, isFalse);
      expect(service.isSpeaking, isTrue);
      expect(fakeTts.spokenTexts.last, 'Second sentence follows.');

      final personas = service.getFitnessVoicePersonas();
      expect(personas, isNotEmpty);
      await service.applyPersona(personas.first);
      expect(fakeTts.lastPitch, personas.first.pitch);
      expect(fakeTts.lastRate, personas.first.recommendedSpeed);

      final langs = await service.getLanguages();
      expect(langs, contains('es-ES'));
      expect(stateNotifications, greaterThan(0));

      await service.stop();
      expect(service.isSpeaking, isFalse);
      await service.dispose();
    });

    testWidgets('AITtsSettingsSheet guards DropdownButton when selectedVoice is not in availableVoices', (tester) async {
      final unguardedState = TtsState(
        availableVoices: const ['Voice A', 'Voice B'],
        selectedVoice: 'non_existent_voice_id',
        personas: const [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ttsProvider.overrideWith(() => _StubTtsNotifier(unguardedState)),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: AITtsSettingsSheet(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Expand Advanced Voice Settings
      await tester.tap(find.text('Advanced Voice Settings'));
      await tester.pumpAndSettle();

      // Zero DropdownButton assertion exceptions!
      expect(tester.takeException(), isNull);
    });
  });

  group('Wave 7.5 — AI Coach Evaluation Set & Rubric', () {
    test('all 12 evaluation prompts and canonical FAQs pass the AI Coach rubric', () {
      final coach = LocalAICoach();
      final normalizer = AiQuestionNormalizer();

      for (final spec in AiCoachRubricEvaluator.evaluationSet) {
        final resolution = normalizer.resolve(spec.prompt);
        final response =
            resolution.cachedResponse ?? coach.generateResponse(spec.prompt);

        final score = AiCoachRubricEvaluator.evaluate(
          spec: spec,
          response: response,
        );

        expect(
          score.passedAll,
          isTrue,
          reason:
              'Prompt ${spec.id} failed rubric: ${score.violations} (response: "$response")',
        );
      }
    });
  });
}
