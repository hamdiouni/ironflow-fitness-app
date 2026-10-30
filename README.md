# 🏋️ IronFlow - AI-Powered Fitness Tracking Platform

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10.7+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Your personal fitness tracking companion with AI-powered insights, progressive overload tracking, and comprehensive nutrition monitoring.**

[Features](#-features) • [Getting Started](#-getting-started) • [Architecture](#-architecture) • [Screenshots](#-screenshots) • [Contributing](#-contributing)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-features)
- [Technology Stack](#-technology-stack)
- [Architecture](#-architecture)
- [Getting Started](#-getting-started)
- [Configuration](#-configuration)
- [Project Structure](#-project-structure)
- [Testing](#-testing)
- [Deployment](#-deployment)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Overview

**IronFlow** is an offline-first Flutter fitness application for serious lifters, combining workout tracking, nutrition monitoring, body progress, and optional AI coaching. The app is in active production-hardening: the local-first experience is the default, while real Firebase auth/sync must be explicitly enabled after deploying rules/indexes and completing platform auth setup.

### Why IronFlow?

- **🧠 AI-Assisted Coaching**: Optional AI explanations and chat when configured; production traffic is designed to go through a backend proxy (direct provider keys are debug-only)
- **📊 Progressive Overload Tracking**: Automatically track your strength gains and get smart progression suggestions
- **🥗 Comprehensive Nutrition**: Log meals with an extensive food database, track macros, and get AI-generated meal plans
- **📱 Offline-First**: All core features work without internet connectivity
- **🎨 Slate Teal Refined Design System**: Dual-mode architectural slate surfaces with kinetic teal accents, frame-light elevation, 3-tier standardized radii, and WCAG AA/AAA contrast compliance
- **📳 Tactile Telemetry**: Centralized haptic feedback on sets, countdown timers, macro milestones, and navigation with settings toggle
- **🔄 Offline-First Sync Engine**: Firestore outbox sync is available behind `USE_FIREBASE_AUTH=true` after Firebase rules/indexes are deployed; the default build remains local/mock-auth
- **🌍 Localization Foundation**: Generated delegates for English, Spanish, French, German, Japanese, Portuguese, and Chinese are wired at the app root; full UI string coverage is still being expanded

---

## ✨ Features

### 🏋️‍♂️ Workout Management

- **Smart Workout Sessions**: Create, track, and manage workout sessions with intuitive UI
- **Exercise Library**: Bundled exercise catalog (about 150 definition entries in the repo today), with YouTube links where present
- **Progressive Overload Engine**: Deterministic, history/RPE-based suggestions for weight and rep progression
- **Rest Timer**: Visual countdown timer between sets with haptic feedback
- **Personal Records**: Automatic PR detection with celebration animations
- **Workout History**: Detailed analytics and performance graphs
- **Custom Programs & Splits**: Full freedom to choose any training split (Full Body, Upper/Lower, Push/Pull/Legs, Arnold Split, Mix/Custom, and Hybrids like PPL x Arnold) across any weekly frequency (1..7 days/week) with deterministic exercise selection
- **Interactive Split Generator & Telemetry**: Live 7-day schedule matrix, in-place exercise swapping modal, real-time muscle frequency telemetry, and one-tap Undo protection
- **Volume Tracking**: Automatic calculation of training volume and intensity

### 🥗 Nutrition Tracking

- **Bundled Food Catalog**: Verified plus legacy food entries (hundreds, not thousands) with macros and available micros, plus user custom foods
- **Meal Logging**: Quick meal entry with smart search and favorites
- **Macro Tracking**: Real-time progress bars for protein, carbs, and fats
- **Custom Foods**: Create and save your own food items
- **Diet Planning**: Generate and save personalized diet plans based on your goals and budget
- **Nutrition History**: View past meals and analyze trends
- **Calorie Goals**: Set and track daily calorie and macro targets

### 📊 Body & Progress Tracking

- **Weight Tracking**: Log weight with trend visualization
- **Body Measurements**: Track chest, waist, hips, arms, and legs
- **Progress Photos**: Before/after comparison with date stamps
- **Analytics Dashboard**: Comprehensive stats on workouts, nutrition, and body composition
- **Strength Progression**: Visualize strength gains over time
- **Consistency Metrics**: Track workout frequency and adherence

### 🤖 AI Coach

- **Provider Configuration**: Gemini through an authenticated backend proxy in production; OpenAI direct access is debug-only until it is moved behind the proxy
- **Context-Aware Insights**: Local deterministic engines analyze workout, nutrition, and body data; AI chat context depends on the configured provider/consent path
- **Natural Conversations**: Chat interface for questions and advice
- **Personalized Insights**: Automatic insights based on your data
- **Voice Feedback**: Text-to-speech for hands-free coaching
- **Safety Boundary**: Training and nutrition calculations are deterministic; AI is used for explanation and conversation, not as the source of record

### 🔔 Smart Notifications

- **Workout Reminders**: Schedule notifications for workout days
- **Meal Reminders**: Never miss a meal with customizable alerts
- **Achievement Notifications**: Celebrate milestones and PRs
- **Streak Tracking**: Build consistency with daily streak counters

### ☁️ Cloud Sync & Authentication

- **Firebase Integration**: Firestore/Auth/Storage integration is present, but cloud sync is gated by `USE_FIREBASE_AUTH=true` plus deployed `firestore.rules`/`firestore.indexes.json`
- **Auth Paths**: Email/password works in mock and Firebase modes; Google/Apple code paths require platform OAuth configuration before production use
- **Offline-First**: Local storage with Hive for instant access
- **Conflict Handling**: Last-write-wins sync with tombstones and per-device pull cursors when Firebase sync is enabled
- **Data Export**: Export your data in JSON or CSV formats
- **Privacy First**: Your data belongs to you

### 🎨 UI/UX Features

- **Dual-Mode Slate Teal Themes**: Eye-friendly architectural dark (`#0B1218`) and light (`#F4F7F9`) palettes passing WCAG AA/AAA contrast ratios
- **Frame-Light Elevation**: Clean flat surface fills on canvas with borders reserved strictly for active selection, keyboard focus, and validation
- **Standardized 3-Tier Radius Scale**: Disciplined 8dp (chips), 12dp (inputs, buttons), and 14dp (cards, sheets, dialogs) rounding
- **Ergonomic Buttons**: 3 standardized touch-friendly sizes (Sm 36dp, Md 44dp, Lg 50dp) with primary, secondary, tertiary, and destructive variants
- **Responsive Multi-Device Shell**: Adaptive desktop left `NavigationRail` and 1120dp max-width centered container for screens ≥ 840dp; mobile bottom dock
- **Plain English Copy**: Clean, human-centered tone following `docs/COPY_GUIDE.md` without robotic jargon
- **Smooth Animations**: Lottie and Flutter Animate for engaging transitions
- **Material 3**: Latest Material Design guidelines integrated via custom `ThemeExtension` tokens

---

## 🛠️ Technology Stack

### Frontend Framework
- **Flutter 3.10.7+**: Cross-platform UI framework
- **Dart SDK**: Programming language

### State Management
- **Riverpod 2.6+**: Reactive state management
- **Freezed**: Immutable data classes
- **Code Generation**: Build runner for boilerplate reduction

### Backend & Cloud
- **Firebase Core**: Backend infrastructure
- **Cloud Firestore**: NoSQL database
- **Firebase Auth**: User authentication
- **Firebase Storage**: File and image storage
- **Firebase Analytics**: Usage analytics
- **Firebase Crashlytics**: Crash reporting

### Local Storage
- **Hive**: Fast, lightweight NoSQL database
- **Flutter Secure Storage**: Encrypted storage for sensitive data
- **Path Provider**: File system access

### AI & Machine Learning
- **AI backend proxy**: Production Gemini route with Firebase ID-token authentication
- **Google Gemini / OpenAI direct APIs**: Local debug development only; shipped builds fail closed without the proxy

### Networking
- **HTTP**: REST API calls
- **Connectivity Plus**: Network status monitoring

### Media & Content
- **Cached Network Image**: Efficient image loading
- **Video Player**: Exercise video playback
- **YouTube Player**: YouTube video integration
- **Image Picker**: Camera and gallery access
- **Flutter SVG**: Vector graphics support

### UI Components
- **FL Chart**: Beautiful data visualization
- **Lottie**: Animation rendering
- **Flutter Animate**: Declarative animations
- **Flutter Markdown**: Markdown rendering

### Utilities
- **UUID**: Unique identifier generation
- **Intl**: Internationalization
- **Timezone**: Time zone handling
- **Flutter TTS**: Text-to-speech
- **Share Plus**: Content sharing
- **Archive**: Data compression

### Development Tools
- **Build Runner**: Code generation
- **JSON Serializable**: JSON parsing
- **Mockito**: Unit testing mocks
- **Flutter Lints**: Code quality

---

## 🏗️ Architecture

IronFlow follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                    # Shared utilities and constants
│   ├── constants/          # App-wide constants and themes
│   ├── error/              # Error handling
│   ├── providers/          # Global providers (theme, language, etc.)
│   ├── router/             # App routing configuration
│   ├── services/           # Global services (analytics, sync)
│   ├── utils/              # Helper functions and extensions
│   └── widgets/            # Reusable widgets
│
├── features/               # Feature modules (Clean Architecture)
│   ├── workout/
│   │   ├── data/          # Data sources and repositories
│   │   ├── domain/        # Business logic (entities, use cases)
│   │   └── presentation/  # UI (screens, widgets, providers)
│   │
│   ├── nutrition/         # Nutrition tracking module
│   ├── body/              # Body tracking module
│   ├── ai/                # AI coach module
│   ├── analytics/         # Analytics and insights
│   ├── auth/              # Authentication
│   ├── sync/              # Cloud synchronization
│   ├── notifications/     # Reminder system
│   └── settings/          # App settings
│
├── l10n/                  # Localization files
├── shared/                # Shared widgets and animations
└── main.dart              # Application entry point
```

### Design Patterns

- **Repository Pattern**: Abstract data sources
- **Use Case Pattern**: Single responsibility business operations
- **Provider Pattern**: Dependency injection with Riverpod
- **Factory Pattern**: Object creation
- **Observer Pattern**: Reactive state updates

---

## 🎨 Slate Teal Refined Design System & Visual Architecture

IronFlow features a cohesive, professional **Slate Teal Refined (`01-slate-teal`)** design system built directly into Flutter's `ThemeExtension` architecture, balancing calm architectural slate surfaces with vibrant, focused kinetic teal accents.

### Architectural Tokens
- **`AppThemeTokens`** (`context.tokens`): Dual-mode color palette built for WCAG AA/AAA contrast compliance:
  - **Dark Mode**: Architectural Slate Canvas (`0xFF0B1218`), Deep Slate Panel (`0xFF131D26`), Elevated Card (`0xFF1C2A36`), Kinetic Teal Accent (`0xFF2DD4BF`), and High-Contrast Deep Ink text on accent (`0xFF042F2E`, 7.92:1 AAA ratio).
  - **Light Mode**: Cool Light Canvas (`0xFFF4F7F9`), Pure White Panels (`0xFFFFFFFF`), Soft Elevated Surfaces (`0xFFE9EFF3`), Deep Teal Accent (`0xFF0F766E`), and Pure White text on accent (`0xFFFFFFFF`, 5.31:1 AA ratio).
- **Frame-Light Elevation**: Default `AppCard` surfaces render without nested border clutter (`hasBorder = false`), reserving borders exclusively for active selections, keyboard focus rings, and validation errors.
- **Standardized 3-Tier Radius Scale**:
  - `tokens.chipRadius` (`8.0dp`): Filter tags, chips, status pills.
  - `tokens.buttonRadius` / `inputRadius` (`12.0dp`): Buttons, text fields, selectors.
  - `tokens.cardRadius` (`14.0dp`): Cards, bottom sheets, dialog modals.
  - `tokens.radiusPill` (`999.0dp`): Progress bars, floating pills, avatar badges.
- **`AppTypography`**: Two-tiered typography scale with open-license bundled fonts:
  - Display Font: `SpaceGrotesk` for headers, key metrics, and numerical values.
  - Body Font: `Inter` for exercise instructions, workout logs, nutrition cards, and chat bubbles.
- **`AppSpacings`**: 4px modular spacing grid (`xs: 4`, `sm: 8`, `md: 12`, `lg: 16`, `xl: 24`, `xxl: 32`).

### Shared Component Library (`lib/shared/presentation/components/`)
- **`AppCard`**: Frame-light panel container with flat fill on canvas and optional active highlight border.
- **`AppButton`**: 3 standardized sizes (`sm: 36dp`, `md: 44dp`, `lg: 50dp`) supporting `primary`, `secondary`, `tertiary`, `outline`, and `destructive` variants with guaranteed 48×48dp accessible touch bounds.
- **`AppDialog` & `AppBottomSheet`**: Constrained, responsive modal windows (dialog max 440dp width, sheet max 560dp width) with consistent action buttons.
- **`AppStatTile`**: Modular metric readout with title, large numerical metric, unit, and status badge.
- **`AppProgress`**: Circular progress rings and segmented bars with kinetic fills.
- **`AppChip`**: Standardized 8dp radius filter and status tags.
- **`AppStateViews`**: Unified state feedback views for empty, loading, offline, and error states.

### Interactive Live Design Gallery
In debug mode (`kDebugMode`), developers and testers can audit every design token and shared component live:
- Navigate to **Profile → Settings → Design System Gallery (Debug Only)** or route `/design-gallery`.
- Includes live dark/light mode switching, component states (normal, pressed, loading, disabled), typography scales, and modal previews.

### 📳 Tactile Telemetry (`AppHaptics`)
Haptic feedback is managed centrally through [`AppHaptics`](lib/shared/presentation/services/app_haptics.dart):
- **Set Logged**: Light impact pulse when completing an exercise set.
- **Rest Timer Complete**: Medium impact pattern when interval timer counts down to 00:00.
- **Macro Milestones**: Daily targets (calories, protein, carbs, fats) trigger a single medium impact celebration per calendar day.
- **Navigation Dock**: Subtle selection clicks when switching between bottom navigation tabs.
- **Toggleable in Settings**: Users can enable/disable tactile telemetry under **Profile → Settings → Tactile Telemetry**.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.10.7 or higher
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Firebase account (free tier works)
- AI API keys (optional but recommended):
  
### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/ironflow-fitness-app.git
   cd ironflow-fitness-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables & API keys**
   
   IronFlow uses a centralized `AppConfig` class that supports both compile-time `--dart-define` constants (recommended for production builds and CI/CD) and local `.env` files for development.

   *For local development:*
   Create a `.env` file in the root directory (never committed to git):
   ```bash
   cp .env.example .env
   ```
   Add your API keys to `.env`:
   ```env
   OPENAI_API_KEY=your_openai_api_key_here
   GEMINI_API_KEY=your_gemini_api_key_here
   NVIDIA_API_KEY=your_nvidia_api_key_here
   ```

   *For production builds or CI/CD without bundling secrets into assets:*
   Pass API keys via `--dart-define`:
   ```bash
   flutter run --dart-define=OPENAI_API_KEY=your_key --dart-define=GEMINI_API_KEY=your_key
   flutter build apk --release --dart-define=OPENAI_API_KEY=your_key --dart-define=GEMINI_API_KEY=your_key
   ```

   > [!WARNING]
   > **Security & Release Risk**: Strings compiled into client binaries with `--dart-define` can be reverse-engineered or extracted from decompiled APK/IPA packages using tools such as `strings` or Ghidra. For production client releases, direct client-to-AI calls pose a secret exposure risk. Production applications should route all AI coaching and LLM requests through an authenticated backend proxy or Cloud Function where secret keys remain protected server-side.

4. **Configure Firebase**
   
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS apps to your Firebase project
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`
   - Update `lib/firebase_options.dart` with your Firebase configuration
   
   See [FIREBASE_SETUP_GUIDE.md](FIREBASE_SETUP_GUIDE.md) for detailed instructions.

5. **Run code generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

### Quick Start (Without Firebase)

You can run the app in offline mode without Firebase:

1. The app will use mock authentication
2. All data will be stored locally with Hive
3. Cloud sync will be disabled
4. AI features will work if you have API keys in `.env`

---

## ⚙️ Configuration

### Firebase Setup

1. **Authentication**: Enable Email/Password, Google Sign-In, and Apple Sign-In
2. **Firestore**: Create database with rules from `firestore.rules`
3. **Realtime Database**: Enable for real-time sync (no billing required)
4. **Storage**: Enable for progress photos
5. **Analytics**: Enable for usage tracking
6. **Crashlytics**: Enable for crash reporting

**📖 Detailed Guide**: [docs/setup/FIREBASE_SETUP_GUIDE.md](docs/setup/FIREBASE_SETUP_GUIDE.md)

### Google Sign-In Setup

**📖 Complete Guide**: [docs/setup/GOOGLE_SIGNIN_SETUP_GUIDE.md](docs/setup/GOOGLE_SIGNIN_SETUP_GUIDE.md)

### AI Configuration

- **OpenAI**: Requires paid API key
- **Gemini**: Free tier (60 requests/minute, 1500/day)
- **NVIDIA**: Free tier for embeddings

Edit `.env` with your keys, and the app will automatically use available AI providers.

**📖 Setup Guide**: [docs/setup/SETUP_FREE_AI.md](docs/setup/SETUP_FREE_AI.md)

### Notifications

Local notifications are configured by default. See [docs/guides/](docs/guides/) for customization.

---

## 📚 Documentation

All documentation is organized in the [`docs/`](docs/) directory:

- **[Quick Start](docs/guides/QUICK_START_GUIDE.md)** - Get running in 5 minutes
- **[Setup Guides](docs/setup/)** - Firebase, Google Sign-In, AI configuration  
- **[User Guides](docs/guides/)** - Testing, deployment, and usage
- **[Architecture](docs/architecture/)** - System design and technical details
- **[Development Logs](docs/development/)** - Project evolution and implementation notes

**Full documentation index**: [docs/README.md](docs/README.md)

---

## 📁 Project Structure

### Key Directories

- **`lib/features/`**: Feature modules organized by domain (Clean Architecture)
- **`lib/core/`**: Shared code and utilities
- **`lib/l10n/`**: Localization and translations
- **`docs/`**: Complete documentation ([see docs/README.md](docs/README.md))
  - `docs/setup/`: Installation and configuration guides
  - `docs/guides/`: User and developer guides
  - `docs/architecture/`: System design documentation
  - `docs/testing/`: Testing documentation
  - `docs/development/`: Development logs and progress notes
- **`test/`**: Unit, widget, and integration tests
- **`scripts/`**: Utility scripts for development
- **`.kiro/specs/`**: Feature specifications and design documents

### Data Flow

```
UI (Presentation) 
    ↓
Providers (State Management)
    ↓
Use Cases (Business Logic)
    ↓
Repositories (Data Abstraction)
    ↓
Data Sources (Hive, Firestore, APIs)
```

---

## 🧪 Testing

IronFlow has a comprehensive test suite of **over 700 automated tests** covering unit, widget, domain logic, design token contrast verification, and property-based regression suites. All tests pass cleanly with **0 static analysis errors and 0 warnings**.

### Run all tests
```bash
flutter test
```

### Static Analysis
```bash
flutter analyze --no-fatal-infos --fatal-warnings
```

### Run specific test suite
```bash
flutter test test/shared/
flutter test test/features/workout/
```

### Run integration tests
```bash
flutter test integration_test/
```

### Test Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Property-Based Testing

The project includes property-based tests for critical features:
- Analytics calculations
- Workout counting logic
- Profile data persistence
- Theme switching
- Auth flow preservation

---

## 📱 Deployment

### Android

1. **Build Release APK (Standard)**
   ```bash
   flutter build apk --release
   ```

2. **Build Hardened Release APK (Obfuscated & Symbol-Split)**
   ```bash
   flutter build apk --release --obfuscate --split-debug-info=build/symbols
   ```
   > [!NOTE]
   > The `build/symbols` directory containing debugging symbols must be kept safely for Crashlytics stack deobfuscation and should never be committed into source control.

3. **Build App Bundle** (for Google Play Store)
   ```bash
   flutter build appbundle --release --obfuscate --split-debug-info=build/symbols
   ```

4. **Configure signing**: Configure release keystore in `android/key.properties` and reference in `android/app/build.gradle.kts`.

See [APK_BUILD_GUIDE.md](APK_BUILD_GUIDE.md) for detailed instructions.

### iOS

1. **Build IPA**
   ```bash
   flutter build ios --release
   ```

2. **Archive and upload**: Use Xcode for App Store submission

### Web

```bash
flutter build web --release
```

---

## 🎨 Screenshots

A full before-and-after screenshot audit and visual comparison catalog across mobile, desktop, dark mode, and light mode is documented in:
- **[Design Upgrade Report](docs/DESIGN_UPGRADE_REPORT.md)**: Full metrics, contrast ratios, and screen inventory.
- **[Before Screenshots](docs/screenshots/before/)**: 35 pre-upgrade mobile and desktop captures.
- **[After Screenshots (Direction 1)](docs/screenshots/after/)**: 35 post-upgrade mobile, desktop, and Chrome live captures.

---

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add amazing feature'`
4. **Push to the branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Run `flutter analyze` before committing
- Write tests for new features
- Update documentation as needed

### Commit Convention

Use conventional commits:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code refactoring
- `test:` Test changes
- `chore:` Build/config changes

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- OpenAI, Google, and NVIDIA for AI capabilities
- All open-source contributors

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/YOUR_USERNAME/ironflow-fitness-app/issues)
- **Discussions**: [GitHub Discussions](https://github.com/YOUR_USERNAME/ironflow-fitness-app/discussions)
- **Email**: support@ironflow.app (coming soon)

---

## 🗺️ Roadmap

- [ ] Wearable device integration (Apple Watch, Fitbit)
- [ ] Social features (share workouts, challenges)
- [ ] Advanced analytics (AI-powered trend prediction)
- [ ] Meal photo recognition (AI-powered nutrition logging)
- [ ] Voice commands for workout logging
- [ ] Custom workout templates marketplace
- [ ] Coach/trainer portal
- [ ] Integration with gym equipment

---

<div align="center">

**Built with ❤️ using Flutter**

⭐ Star this repo if you find it helpful!

</div>
