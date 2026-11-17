# Wave 7 Plan — AI Coach Upgrade (V2)

> **Branch:** `feat/prod-v2-wave-7` (branched from `master` at `e231e12`, backed up by tag `backup/pre-prod-v2-wave-7`)  
> **Gate Rule:** Strictly **STOP for Owner `[ASK]` / ADR decisions** below before deleting any legacy file (`exercise_image_database.dart`) or enabling optional multimodal meal-photo estimation.  
> **Wave 6 Baseline Status (Verified on `master` `e231e12`):**  
> - `flutter analyze --no-pub --no-fatal-infos lib test`: `0` errors, `0` warnings  
> - `flutter test --no-pub --coverage --timeout=60s`: `1,092 / 1,092` passed (`0` failed, `0` skipped)  
> - `python scripts/check_coverage.py --baseline docs/quality/coverage_baseline.json --fail-on-drop`: `70.95%` overall (`21,692 / 30,575` lines across `382` files); `COVERAGE GATE PASSED`  
> - `python scripts/check_perf_budgets.py --require-release-apk --require-web --require-r8-mapping`: `All performance, size, & R8 checks PASSED`  
> - `gitleaks git --log-opts="backup/pre-prod-v2-wave-6..HEAD"`: `1` commit scanned, `no leaks found`

---

## Step 0 — Verified Baseline Audit (`e231e12`)

### Step 0A — What Exists Today

| Item | Exists? | Verified Evidence on `feat/prod-v2-wave-7` (`e231e12`) |
| :--- | :--- | :--- |
| **`7.1` Proxy SSE streaming (`functions/src/proxy_core.mjs`, `index.ts`)** | **Buffered (Unfixed)** | `functions/src/proxy_core.mjs:433-444` calls `const sseText = await upstreamResponse.text();`, buffering the entire upstream SSE stream in memory before sending `res.status(result.status).send(result.rawBody)` in `functions/src/index.ts:139-142`. |
| **`7.1` Client `StreamedResponse` SSE streaming (`gemini_ai_service.dart`)** | **Fake stream (Unfixed)** | `lib/features/ai/data/datasources/gemini_ai_service.dart:417-431` implements `streamMessage` by awaiting non-streaming `sendMessage(...)` and yielding the full response in one chunk instead of reading `http.StreamedResponse.stream` through `parseSseChunks`. |
| **`7.1` Native `systemInstruction` & multi-turn history** | **Unfixed** | `gemini_ai_service.dart:359-395` injects fake `'System instructions: ...'` and `'Understood.'` user/model turns instead of Gemini's native `systemInstruction: {'parts': [{'text': ...}]}`. `ai_provider.dart:360-365` sends only `[{'role': 'user', 'content': message}]` (1 turn) instead of bounded multi-turn history. |
| **`7.1` Unified `maxTokens` & safety thresholds** | **Unfixed** | `ai_transport.dart:20,28` and `gemini_ai_service.dart:147,421` default `maxTokens` to `8000`, `ai_provider.dart:364` passes `1000`, and `proxy_core.mjs:149` defaults to `2048` (max `4096`). `gemini_ai_service.dart:170-187` sets all 4 `safetySettings` categories to `'BLOCK_NONE'` instead of `'BLOCK_MEDIUM_AND_ABOVE'`. |
| **`7.2` Context builder (units, streak, recovery, consent)** | **Partial** | `ai_provider.dart:455-534` gates profile/workout/nutrition/body context on `hasConsent`, **but** omits `unitsProvider` (`kg` vs `lbs`), `WorkoutStreakCalculator` active streak, and `MuscleRecoveryCalculator` readiness scores. |
| **`7.2` Composite cache key (`AiQuestionNormalizer`)** | **Question-only** | `lib/features/ai/domain/services/ai_question_normalizer.dart:132-190` keys the LRU cache solely by `normalize(rawQuestion)`, ignoring `locale`, `units`, `consent` state, and `dataEpoch`. |
| **`7.2` Change detection for edits & deletes (`ChangeDetectionServiceImpl`)** | **Insert-only bug** | `lib/features/ai/data/services/change_detection_service_impl.dart:40-151` checks only `latestWorkout.date.isAfter(lastGenerated)` on `limit: 1`. Editing an older workout/meal/body entry (`updatedAt`) or deleting a record (count change) is not detected. |
| **`7.2` Alias resolution in `AIInsightMetricsCalculator`** | **Raw name match** | `lib/features/ai/data/services/ai_insight_metrics_calculator.dart:73-95, 123-147, 173-175` compares raw `exercise.name == histExercise.name` and `ExerciseDatabase.all` instead of resolving through `ExerciseCatalog` aliases (`exerciseDefinitionId` / `ExerciseCatalog.findByIdOrName`). (`formatMetricLabel` at `L224-257` already cleans raw snake_case/camelCase keys). |
| **`7.2` Duplicate retry message & offline 401 call (`AIChatNotifier`)** | **Unfixed** | `ai_provider.dart:238-262`: `retryLastMessage()` calls `sendMessage(failed)`, appending a duplicate user message bubble. When offline or unauthenticated on proxy mode (`_getAuthToken() == null`), `sendMessage` still dispatches a network request that fails with 401/network error instead of routing directly to `LocalAICoach`. |
| **`7.2` Legacy OpenAI / test screen / image services (`[ASK]`)** | **Mostly retired in W3** | `openai_ai_service.dart`, `ai_test_screen.dart`, and `image_generation_service.dart` were retired in Wave 3 (`test/architecture/architecture_hygiene_test.dart`). Only `lib/features/ai/domain/services/exercise_image_database.dart` (stock Unsplash URL map used in `ai_chat_message_bubble.dart:6,118`) remains — gated on Owner `[ASK Q1]`. |
| **`7.3` Structured `"Tap to apply"` actions with Undo & Meal-Photo ADR** | **Missing** | No structured action schema (`save_program`, `swap_exercise`, `log_meal`), ownership check, `"Tap to apply"` confirmation card, or Undo handler exists in `lib/features/ai/`. Meal-photo estimation ADR is gated on Owner `[ASK Q2]`. |
| **`7.4` Voice TTS (`tts_service.dart`, `tts_provider.dart`, `ai_tts_settings_sheet.dart`)** | **4 bugs found** | (1) `tts_service.dart:47,173,200` hardcodes `'en-US'` instead of syncing with `languageProvider`; (2) `tts_provider.dart:91,99,116` uses arbitrary `Future.delayed(500ms/600ms)` instead of completion/state handlers; (3) `tts_service.dart:120-131` `resume()` sets `_isPaused = false` without speaking remaining text from the last progress offset; (4) `ai_tts_settings_sheet.dart:258,277` passes unguarded `value: ttsState.selectedVoice` to `DropdownButton<String>` over `.take(10)`. |
| **`7.5` Evaluation set with rubric & cost tracking** | **Partial** | `AiCostEstimator` (`ai_question_normalizer.dart:17-52`) estimates tokens/USD in debug logs (`ai_provider.dart:396-402`), but no evaluation dataset + automated rubric test suite or session cost state tracking exists. |

### Step 0B — Claims Checked Against Master Plan V2

| Claim | Verified? | Evidence |
| :--- | :--- | :--- |
| "Proxy waits for the whole upstream body; client `streamMessage` does not read `StreamedResponse`" | **CONFIRMED** | `functions/src/proxy_core.mjs:434` (`await upstreamResponse.text()`) and `gemini_ai_service.dart:423` (`await sendMessage(...)`). |
| "`GeminiAIService` uses fake user/model system prompt turns and `BLOCK_NONE` safety thresholds" | **CONFIRMED** | `gemini_ai_service.dart:359-375` and `L170-187`. |
| "`retryLastMessage` duplicates the user message bubble and offline/unauthenticated proxy calls hit 401" | **CONFIRMED** | `ai_provider.dart:238-262` and `gemini_ai_service.dart:204-207`. |
| "`TtsNotifier` uses fixed `Future.delayed`, `resume()` is a no-op, and `DropdownButton` value is unguarded" | **CONFIRMED** | `tts_provider.dart:91,99,116`, `tts_service.dart:120-131`, and `ai_tts_settings_sheet.dart:258,277`. |

---

## Owner `[ASK]` Decisions Required Before File Deletion / ADR Scope

1. **`[ASK Q1]` Legacy `ExerciseImageDatabase` (`lib/features/ai/domain/services/exercise_image_database.dart`):**
   - `openai_ai_service.dart`, `ai_test_screen.dart`, and `image_generation_service.dart` were already retired in Wave 3.
   - `lib/features/ai/domain/services/exercise_image_database.dart` maps 24 exercise keywords to 6 generic Unsplash stock photos in `AIChatBubble`.
   - **Option A (Recommended):** Delete `exercise_image_database.dart` and replace generic Unsplash stock thumbnails in `AIChatBubble` with canonical `ExerciseCatalog` exercise chips that open the verified `ExerciseMediaStage` / detail view.
   - **Option B:** Keep `exercise_image_database.dart` as-is.
2. **`[ASK Q2]` Wave `7.3` Meal-Photo Estimate ADR & Action Cards Scope:**
   - **Option A (Recommended):** Ship the 3 schema-validated `"Tap to apply"` action cards (`save_program`, `swap_exercise`, `log_meal`) with ownership verification and 1-tap `Undo`, **plus** ADR-003 & opt-in Meal-Photo Macro Estimate flow (explicit consent check, transient base64 via proxy with zero cloud/disk photo storage, and prominent `"ESTIMATE"` badge; exercise form-check from photos remains propose-only in ADR-003).
   - **Option B:** Ship only the 3 `"Tap to apply"` action cards (`save_program`, `swap_exercise`, `log_meal`) with `Undo` and document Meal-Photo Estimate + Form-Check as propose-only in ADR-003.
