# Changelog

All notable changes to IronFlow will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-10-17

### Added
- **Monolithic Sci-Fi Design System**: Complete presentation-layer migration to a high-contrast monolithic sci-fi aesthetic.
  - Architectural tokens: `AppThemeTokens` (light/dark with Obsidian Canvas, Panel Glass, Kinetic Cyan accent, Laser Amber, Plasma Green, and Neon Crimson), `AppTypography` (`SpaceGrotesk` display font for HUD telemetry and metrics, `Inter` body font), `AppSpacings`, and `AppColors`.
  - Shared component library: `AppCard`, `AppButton`, `AppChip`, `AppStatTile`, `AppProgress` (rings and linear bars), `AppSectionHeader`, `AppShimmer`, `AppStateViews` (offline, error, empty), `AppTextField`, `AppBottomSheet`, and `AppDialog`.
  - Screen migrations: HomeScreen, Workout tab, ActiveWorkout, ExerciseCatalog, ProgramEditor, Nutrition tab, NutritionHistory, Analytics tab, Progress tab, ProfileScreen, and ReminderSettingsScreen.
  - Interactive Design Gallery (`/design-gallery`) accessible in `kDebugMode` for live component verification.
- **Unified AI Architecture**:
  - `AiCoachHeroCard` placed prominently on the HomeScreen with live prompt dispatch, workout/recovery telemetry, and graceful fallback when offline or unconfigured.
  - Universal `AiEntryButton` header trigger integrated into Home, Workout, Nutrition, and Analytics screens.
  - `ContextualInsightBanner` for dismissible contextual hints with local persistence.
  - Security gates: `AITestScreen` and `DesignGalleryScreen` restricted strictly behind `kDebugMode` with API key sanitization.
- **Tactile Telemetry (Haptics)**:
  - Centralized presentation abstraction `AppHaptics` utilizing Flutter's native `HapticFeedback` channels with zero external packages.
  - Semantic haptic dispatching: `setLogged()` (light impact on exercise set logging), `restTimerComplete()` (medium impact on countdown zero), `milestoneReached()` (medium impact on daily calorie/macro targets, throttled once per milestone per calendar day), `selectionChanged()` (selection click on bottom navigation tabs), `buttonPress()` (light impact on `AppButton`), and `error()` (heavy impact).
  - User-configurable toggle under **Tactile Telemetry** in Settings with Hive local storage persistence (`app_settings` box).
  - Clean Architecture boundary: removed direct platform channel calls from `RestTimerService` domain service.

### Fixed & Improved
- **Backup & Restore**: Implemented full local and cloud data restore pipeline (`RestoreDataUseCase`) validating schema integrity across workouts, nutrition, body measurements, and user profiles.
- **Configuration Security**: Unified runtime and compile-time key resolution with `--dart-define` support and secure `.env` separation.
- **Test Suite Verification**: Expanded automated test suite with haptics unit tests (`app_haptics_test.dart`), bringing the verified suite to 438/438 passing tests with 0 analyzer errors and 0 warnings.
- **CI Quality Gate**: Enforced GitHub Actions CI workflow (`.github/workflows/ci.yml`) automating dependency installation, static analysis (`--fatal-warnings`), test execution with coverage, and debug APK build.

## [1.0.1] - 2026-10-16

### Fixed
- **Authentication**: Resolved Android logout loading dialog hang by safely dismissing the dialog before async context transitions and tracking dialog state.
- **Analytics**: Fixed volume progression chart to maintain full `double` precision across all calculations without truncation or dead type casts.
- **AI Bottom Sheet**: Resolved 12px layout overflow in QuickFeedbackBottomSheet on compact screen sizes with scrollable content constraints.
- **Cloud Sync**: Completed end-to-end cloud sync pipeline (workouts, nutrition, programs, body measurements) to Firestore with transactional batch operations and removed dead code suppressions.
- **Static Analysis**: Resolved all 45 analyzer warnings across the codebase, bringing the analyzer baseline to 0 errors and 0 warnings.
- **State Persistence**: Hardened Hive test fixtures and active workout state recovery with isolated directories to prevent database lock contention.

### Added
- **Quality Gates**: Added GitHub Actions CI workflow (`.github/workflows/ci.yml`) automating dependencies installation, static analysis (`--fatal-warnings`), test execution with coverage, and Android debug APK compilation.
- **Unit Tests**: Added targeted domain calculation tests for `DailyNutritionSummary` (100% line coverage) and `WorkoutStateManager` active session persistence.
- **Security**: Added security documentation regarding `--dart-define` binary decompilation risks and recommended backend proxy architecture for production AI calls.

## [1.0.0] - 2024-09-17

### Added
- Complete workout tracking with progressive overload engine
- AI-powered coaching with OpenAI GPT-4, Google Gemini, and NVIDIA
- Nutrition monitoring with 1000+ food database
- Body tracking and progress photos
- Firebase authentication (Email, Google Sign-In, Apple Sign-In)
- Offline-first architecture with real-time cloud sync
- Multi-language support (7 languages)
- Smart notifications and reminders
- Analytics and performance tracking
- Clean Architecture implementation
- Comprehensive testing suite
- Property-based testing for correctness validation

### Features
- **Workout Module**: Exercise library, rest timer, PR detection, volume tracking
- **Nutrition Module**: Meal logging, macro tracking, AI meal plans
- **AI Coach**: Context-aware conversations, personalized insights, voice feedback
- **Analytics**: Strength progression, consistency metrics, performance predictions
- **Sync**: Real-time data synchronization across devices

### Technical
- Flutter 3.10.7+ with Dart
- Riverpod 2.6+ state management
- Firebase backend (Firestore, Realtime DB, Storage)
- Hive for local storage
- Freezed for immutable data classes
- 192,000+ lines of production code

---

## [Unreleased]

### Planned
- Wearable device integration (Apple Watch, Fitbit)
- Social features (share workouts, challenges)
- Advanced analytics with AI-powered trend prediction
- Meal photo recognition
- Voice commands for workout logging
- Custom workout templates marketplace

---

For full development history, see [docs/development/](docs/development/)
