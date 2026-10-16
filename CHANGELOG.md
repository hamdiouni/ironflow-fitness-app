# Changelog

All notable changes to IronFlow will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
