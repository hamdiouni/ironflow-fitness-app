# 📚 IronFlow Documentation

Welcome to the IronFlow documentation! This directory contains all guides, architecture documentation, and development notes.

## 📖 Quick Navigation

### 🚀 Getting Started
- [Quick Start Guide](guides/QUICK_START_GUIDE.md) - Get up and running in 5 minutes
- [Firebase Setup](setup/FIREBASE_SETUP_GUIDE.md) - Complete Firebase configuration
- [Google Sign-In Setup](setup/GOOGLE_SIGNIN_SETUP_GUIDE.md) - Enable Google authentication
- [Free AI Setup](setup/SETUP_FREE_AI.md) - Configure AI providers

### 📘 User Guides
- [User Testing Instructions](guides/USER_TESTING_INSTRUCTIONS.md)
- [Deployment Guide](guides/DEPLOYMENT_GUIDE.md)
- [APK Build Guide](guides/APK_BUILD_GUIDE.md)
- [Mobile Testing on PC](guides/MOBILE_TESTING_ON_PC_GUIDE.md)

### 🏗️ Architecture
- [Video System Architecture](architecture/VIDEO_SYSTEM_ARCHITECTURE.md)
- [Firebase Architecture](architecture/FIREBASE_ARCHITECTURE.md)
- [Cloud Sync Implementation](architecture/CLOUD_SYNC_IMPLEMENTATION.md)
- [Clean Architecture Overview](#clean-architecture)

### 🧪 Testing
- [Testing Documentation](LOGGING.md)
- [Testing Guides](testing/)

### 🔧 Development
- [Development Logs](development/) - Phase completion reports, bug fixes, and implementation notes
- [Change History](#) - Track project evolution

## 🏗️ Clean Architecture

IronFlow follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── core/                    # Shared utilities and constants
│   ├── constants/          # App-wide constants
│   ├── providers/          # Global providers
│   ├── services/           # Global services
│   └── utils/              # Helper functions
│
├── features/               # Feature modules
│   ├── workout/
│   │   ├── data/          # Data sources & repositories
│   │   ├── domain/        # Business logic (entities, use cases)
│   │   └── presentation/  # UI (screens, widgets, providers)
│   │
│   ├── nutrition/         # Nutrition tracking
│   ├── ai/                # AI coach
│   ├── analytics/         # Analytics & insights
│   ├── auth/              # Authentication
│   └── ...                # Other features
│
└── shared/                # Shared widgets and animations
```

### Layer Rules

1. **Domain Layer** (Business Logic)
   - Pure Dart (no Flutter dependencies)
   - Contains entities and use cases
   - Defines repository interfaces

2. **Data Layer** (Implementation)
   - Implements repository interfaces
   - Handles data sources (Hive, Firebase, APIs)
   - Converts between models and entities

3. **Presentation Layer** (UI)
   - Flutter widgets and screens
   - State management (Riverpod)
   - Depends on domain layer only

## 🎯 Key Concepts

### Offline-First Architecture
- Local storage with Hive
- Background sync with Firebase
- Conflict resolution
- Queue management for offline operations

### State Management
- **Riverpod 2.6+** for reactive state
- **Code generation** with riverpod_generator
- **Freezed** for immutable data classes

### AI Integration
- Multiple providers (OpenAI, Gemini, NVIDIA)
- Context-aware conversations
- Smart caching to reduce costs
- Fallback mechanisms

### Testing Strategy
- **Unit tests**: Business logic
- **Widget tests**: UI components
- **Integration tests**: Complete flows
- **Property-based tests**: Correctness validation

## 📊 Project Statistics

- **Lines of Code**: 192,000+
- **Features**: 10+ major modules
- **Tests**: Comprehensive test coverage
- **Languages**: 7 (English, Spanish, French, German, Japanese, Portuguese, Chinese)
- **Platforms**: Android, iOS, Web (macOS, Windows, Linux support)

## 🔗 External Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## 🆘 Need Help?

1. Check the relevant guide in this documentation
2. Look through [development logs](development/) for similar issues
3. Check [GitHub Issues](https://github.com/hamdiouni/ironflow-fitness-app/issues)
4. Create a new issue with detailed information

---

**Happy coding!** 🚀
