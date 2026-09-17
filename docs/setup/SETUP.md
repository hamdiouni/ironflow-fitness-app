# Project Setup Guide

## Initial Setup Complete ✓

The Progression Tracker Flutter project has been successfully initialized with:

### ✅ Completed Tasks

1. **Flutter Project Initialization**
   - Created Flutter project with org: `com.progressiontracker`
   - Project name: `progression_tracker`
   - Flutter version: 3.38.7
   - Dart version: 3.10.7

2. **Dependencies Installed**
   - State Management: `flutter_riverpod`, `riverpod_annotation`
   - Local Storage: `hive`, `hive_flutter`
   - Routing: `go_router`
   - Data Classes: `freezed_annotation`, `json_annotation`
   - Utilities: `uuid`
   - Animations: `flutter_animate`, `lottie`
   - Charts: `fl_chart`
   - Code Generation: `build_runner`, `freezed`, `json_serializable`, `riverpod_generator`
   - Testing: `mockito`

3. **Clean Architecture Folder Structure**
   ```
   lib/
   ├── core/
   │   ├── constants/
   │   │   ├── app_constants.dart
   │   │   └── app_theme.dart
   │   ├── error/
   │   │   └── exceptions.dart
   │   └── utils/
   │       └── extensions.dart
   ├── features/
   │   ├── workout/
   │   │   ├── domain/
   │   │   │   ├── entities/
   │   │   │   ├── repositories/
   │   │   │   └── usecases/
   │   │   ├── data/
   │   │   │   ├── models/
   │   │   │   ├── datasources/
   │   │   │   └── repositories/
   │   │   └── presentation/
   │   │       ├── providers/
   │   │       ├── screens/
   │   │       └── widgets/
   │   ├── body/ (same structure)
   │   └── nutrition/ (same structure)
   ├── shared/
   │   ├── widgets/
   │   └── animations/
   └── main.dart
   ```

4. **Test Structure**
   ```
   test/
   ├── properties/      # Property-based tests
   ├── unit/
   │   ├── domain/
   │   └── data/
   ├── integration/
   └── widget/
   ```

5. **Configuration Files**
   - `build.yaml` - Build runner configuration
   - `pubspec.yaml` - Dependencies and assets
   - `.gitignore` - Excludes generated files
   - `README.md` - Project documentation

6. **Core Infrastructure**
   - Custom exception classes (AppException, InvalidRepsException, etc.)
   - App constants (timing, performance, UI, validation)
   - App theme (dark mode with neon green/blue accents)
   - Utility extensions (DateTime, Duration, Double, List)

7. **Assets Folder**
   - `assets/animations/` - For Lottie animation files

## Next Steps

### 1. Run Code Generation (When Needed)
After creating models with Freezed or JSON serialization:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Or use watch mode during development:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 2. Verify Installation
```bash
flutter doctor
flutter pub get
flutter analyze
```

### 3. Run the App
```bash
flutter run
```

### 4. Start Development
Begin implementing features following this order:
1. Domain entities (Workout, Exercise, SetEntry, etc.)
2. Repository interfaces
3. Use cases
4. Data models with Freezed
5. Data sources (Hive)
6. Repository implementations
7. Riverpod providers
8. UI screens and widgets
9. Tests

## Important Notes

### Code Generation
- Run `build_runner` after creating/modifying:
  - Freezed classes (`@freezed`)
  - JSON serializable classes (`@JsonSerializable`)
  - Riverpod providers (`@riverpod`)

### Clean Architecture Rules
1. Domain layer: NO Flutter imports (pure Dart)
2. Presentation depends on Domain abstractions only
3. Data layer implements Domain interfaces
4. No cross-feature imports

### Performance Requirements
- Visual feedback: <100ms
- Animations: 60 FPS
- Lazy loading: Lists >20 items
- Chart sampling: >100 data points

### Testing Requirements
- Property-based tests for business logic
- Unit tests for specific examples
- Integration tests for workflows
- Widget tests for UI components
- Target: 80% code coverage

## Troubleshooting

### Build Runner Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Hive Issues
```bash
# Clear Hive boxes during development
# Delete the app and reinstall
flutter clean
flutter run
```

### Dependency Conflicts
```bash
# Update dependencies
flutter pub upgrade
flutter pub outdated
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Freezed Documentation](https://pub.dev/packages/freezed)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## Project Status

✅ Task 1: Project setup and infrastructure - **COMPLETED**

Ready for Task 2: Domain layer implementation
