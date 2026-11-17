# ADR-003: Structured AI Coach Actions ("Tap to Apply" + Undo) & Transient Meal-Photo Macro Estimate

- **Status:** Accepted (Wave 7.3)
- **Date:** 2026-11-17
- **Deciders:** Repository Owner, Architecture & AI Engineering

## Context
IronFlow's AI Coach assists users with program design, exercise substitutions, and nutrition logging. Previously, AI responses were plain text only, requiring users to manually copy workouts or macros into the app. At the same time, auto-mutating a user's active workout program or nutrition log without explicit confirmation risks overwriting user data or attributing records to the wrong account scope.

Additionally, users requested quick meal macro estimation from a camera/gallery photo without storing personal food photos in cloud storage, as well as an evaluation of exercise form checking from photos/videos.

## Decision

### 1. Schema-Validated "Tap to Apply" Action Cards with Ownership & Undo
1. **Supported Action Types (`AiCoachActionType`):**
   - `save_program`: Creates and activates a `WorkoutProgram` / `ActiveProgram` (`1..7` days, `1..12` exercises per day, `1..10` sets, `15..600s` rest).
   - `swap_exercise`: Replaces `fromExercise` with `toExercise` in the user's active program (resolved against `ExerciseCatalog`).
   - `log_meal`: Logs a `Meal` entry (`mealName`, `calories` `1..5000`, `proteinG` `0..500`, `carbsG` `0..800`, `fatsG` `0..300`) for today.
2. **Ownership Verification:**
   - Every parsed action is validated against the active user scope (`currentUserIdProvider` / `RecordOwnershipRules`). Payloads specifying a mismatched `userId` are rejected before rendering.
3. **Never Auto-Applied + 1-Tap Undo:**
   - Actions render as interactive **"Tap to apply"** cards inside `AIChatBubble`.
   - Tapping **Apply** executes the mutation, records a reversible snapshot (`priorActiveProgram` or created `mealId`), and surfaces an **Undo** button both on the card and via `SnackBar` that restores the exact prior state.

### 2. Opt-In Transient Meal-Photo Macro Estimate (`log_meal` with `ESTIMATE` Badge)
1. **Explicit Consent First:**
   - Meal-photo estimation requires `aiPersonalizationConsentProvider == true` (or explicit one-time confirmation in the sheet).
2. **Zero Photo Persistence:**
   - Image bytes are resized/encoded in memory as base64 (`image/jpeg`, `image/png`, or `image/webp`, `<= 1.5 MB` base64 cap) and sent transiently through the authenticated Cloud Functions proxy (`aiGenerate`). Neither the client nor the proxy writes the photo to disk, Hive, Firestore, or Firebase Storage.
3. **Prominent `"ESTIMATE"` Labeling:**
   - Every photo-derived nutrition card displays an explicit **`ESTIMATE — VERIFY PORTIONS`** badge (`isEstimate: true`) and requires the user to tap **"Tap to apply"** before logging.

### 3. Exercise Form Check from Photos/Video — Propose Only (Deferred)
- Accurate biomechanical form assessment (bar path, spinal flexion, knee valgus, tempo) cannot be safely inferred from a single static 2D smartphone photo and poses injury-liability risk if false reassurance is given.
- Exercise form checking from photos remains **propose-only** (not enabled in production builds); users are directed to the verified `ExerciseMediaStage` coaching videos and step-by-step form cues shipped in Wave 5.
