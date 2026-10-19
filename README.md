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

**IronFlow** is a production-ready, cross-platform fitness application built with Flutter that combines powerful workout tracking, nutrition monitoring, and AI-powered coaching into a seamless, offline-first experience. Whether you're a beginner or an advanced athlete, IronFlow adapts to your fitness journey with intelligent insights and personalized recommendations.

### Why IronFlow?

- **🧠 AI-Powered Coaching**: Get personalized workout and nutrition advice from integrated AI coaches (OpenAI, Gemini, NVIDIA)
- **📊 Progressive Overload Tracking**: Automatically track your strength gains and get smart progression suggestions
- **🥗 Comprehensive Nutrition**: Log meals with an extensive food database, track macros, and get AI-generated meal plans
- **📱 Offline-First**: All core features work without internet connectivity
- **⚡ Monolithic Sci-Fi UI**: High-contrast, telemetry-styled design system with dark/light tokens and smooth micro-animations
- **📳 Tactile Telemetry**: Centralized haptic feedback on sets, countdown timers, macro milestones, and navigation with settings toggle
- **🔄 Real-time Sync**: Cloud synchronization across all your devices via Firebase
- **🌍 Multi-language**: Support for English, Spanish, French, German, Japanese, Portuguese, and Chinese

---

## ✨ Features

### 🏋️‍♂️ Workout Management

- **Smart Workout Sessions**: Create, track, and manage workout sessions with intuitive UI
- **Exercise Library**: 500+ pre-loaded exercises with video demonstrations (YouTube integration)
- **Progressive Overload Engine**: AI-driven suggestions for weight and rep progression
- **Rest Timer**: Visual countdown timer between sets with haptic feedback
- **Personal Records**: Automatic PR detection with celebration animations
- **Workout History**: Detailed analytics and performance graphs
- **Custom Programs & Splits**: Full freedom to choose any training split (Full Body, Upper/Lower, Push/Pull/Legs, Arnold Split, Mix/Custom, and Hybrids like PPL x Arnold) across any weekly frequency (1..7 days/week) with deterministic exercise selection
- **Interactive Split Generator & Telemetry**: Live 7-day schedule matrix, in-place exercise swapping modal, real-time muscle frequency telemetry, and one-tap Undo protection
- **Volume Tracking**: Automatic calculation of training volume and intensity

### 🥗 Nutrition Tracking

- **Extensive Food Database**: 1000+ foods with complete nutritional information
- **Meal Logging**: Quick meal entry with smart search and favorites
- **Macro Tracking**: Real-time progress bars for protein, carbs, and fats
- **Custom Foods**: Create and save your own food items
- **AI Meal Planning**: Generate personalized meal plans based on your goals
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

- **Multi-Platform Support**: OpenAI GPT-4, Google Gemini, NVIDIA AI
- **Context-Aware**: AI knows your workout history, nutrition, and goals
- **Natural Conversations**: Chat interface for questions and advice
- **Personalized Insights**: Automatic insights based on your data
- **Voice Feedback**: Text-to-speech for hands-free coaching
- **Image Generation**: Visualize exercises or meal presentations (DALL-E integration)

### 🔔 Smart Notifications

- **Workout Reminders**: Schedule notifications for workout days
- **Meal Reminders**: Never miss a meal with customizable alerts
- **Achievement Notifications**: Celebrate milestones and PRs
- **Streak Tracking**: Build consistency with daily streak counters

### ☁️ Cloud Sync & Authentication

- **Firebase Integration**: Real-time data sync across devices
- **Multi-Auth Support**: Email/password, Google Sign-In, Apple Sign-In
- **Offline-First**: Local storage with Hive for instant access
- **Conflict Resolution**: Smart sync with automatic conflict handling
- **Data Export**: Export your data in JSON or CSV formats
- **Privacy First**: Your data belongs to you

### 🎨 UI/UX Features

- **Dark/Light Themes**: Eye-friendly themes with smooth transitions
- **Glassmorphism Design**: Modern frosted glass UI elements
- **Smooth Animations**: Lottie and Flutter Animate for engaging transitions
- **Responsive Layout**: Optimized for all screen sizes
- **Gesture Controls**: Swipe, drag, and tap for intuitive navigation
- **Material 3**: Latest Material Design guidelines

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
- **Firebase Realtime Database**: Real-time data sync (no billing required)
- **Firebase Storage**: File and image storage
- **Firebase Analytics**: Usage analytics
- **Firebase Crashlytics**: Crash reporting

### Local Storage
- **Hive**: Fast, lightweight NoSQL database
- **Flutter Secure Storage**: Encrypted storage for sensitive data
- **Path Provider**: File system access

### AI & Machine Learning
- **OpenAI GPT-4**: Advanced language model
- **Google Gemini**: Free-tier AI (60 req/min, 1500 req/day)
- **NVIDIA AI**: Embeddings and retrieval

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

## 🎨 Monolithic Sci-Fi Design System & Telemetry

IronFlow v1.1.0 introduces a cohesive, high-contrast **Monolithic Sci-Fi** aesthetic built directly into Flutter's `ThemeExtension` architecture.

### Architectural Tokens
- **`AppThemeTokens`** (`context.tokens`): Light and dark color palettes adhering strictly to WCAG AAA contrast ratios.
  - Dark Mode: Obsidian Canvas (`0xFF090A0C`), Panel Glass (`0xFF11141A`), Kinetic Cyan (`0xFF00E5FF`), Laser Amber (`0xFFFF9100`), Plasma Green (`0xFF00E676`), Neon Crimson (`0xFFFF1744`).
  - Light Mode: Architectural Titanium (`0xFFF0F2F5`), Crisp Panels (`0xFFFFFFFF`), High-Contrast Dark Slate text (`0xFF0F172A`).
- **`AppTypography`**: Two-tiered typography scale:
  - Display Font: `SpaceGrotesk` for titles, metrics, HUD readouts, and numerical telemetry.
  - Body Font: `Inter` for long-form workout notes, body descriptions, and guides.
- **`AppSpacings`**: 4px modular spacing grid (`xs: 4`, `sm: 8`, `md: 12`, `lg: 16`, `xl: 24`, `xxl: 32`).

### Shared Component Library (`lib/shared/presentation/components/`)
- **`AppCard`**: Panel container with subtle borders and optional kinetic glowing halos (`isGlowing: true`).
- **`AppButton`**: Tactical buttons supporting primary, secondary, outline, ghost, and danger variants with automatic loading spinners and a guaranteed minimum 48dp touch target.
- **`AppStatTile`**: Modular HUD metric readout with title, large numerical metric, unit, and delta status badge.
- **`AppProgress`**: Circular progress rings and segmented progress bars with kinetic gradient fills.
- **`AppChip`**: Filter and status tags with active highlight states.
- **`AppStateViews`**: Unified state feedback views for offline mode, sync errors, and empty states.
- **`AppSectionHeader`**: High-contrast category dividers with uppercase display typography and optional action CTA.

### Interactive Debug Design Gallery
In debug mode (`kDebugMode`), developers can explore, test, and audit every design token and shared component live:
- Navigate to **Profile → Settings → Design System Gallery (Debug Only)** or navigate to route `/design-gallery`.
- Includes live theme switching, component variant showcases, interactive states, and typography stress tests.

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
  - [OpenAI API Key](https://platform.openai.com/api-keys)
  - [Google Gemini API Key](https://makersuite.google.com/app/apikey) (FREE)
  - [NVIDIA API Key](https://build.nvidia.com/) (FREE)

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

IronFlow has a comprehensive test suite of **438 automated tests** covering unit, widget, domain logic, and property-based regression suites. All tests pass cleanly with **0 static analysis errors and 0 warnings**.

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

<!-- Add screenshots here when available -->
Coming soon!

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
