# Contributing to IronFlow

First off, thank you for considering contributing to IronFlow! 🎉

## 🤝 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the behavior
- **Expected behavior**
- **Actual behavior**
- **Screenshots** if applicable
- **Device/OS** information
- **App version**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear title and description**
- **Use case** - why is this needed?
- **Proposed solution**
- **Alternatives considered**

### Pull Requests

1. **Fork** the repository
2. **Create a branch** from `master`:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Make your changes** following our coding standards
4. **Write/update tests** for your changes
5. **Run tests** to ensure everything passes:
   ```bash
   flutter test
   ```
6. **Commit** your changes with a descriptive message:
   ```bash
   git commit -m "feat: add amazing feature"
   ```
7. **Push** to your fork:
   ```bash
   git push origin feature/amazing-feature
   ```
8. **Open a Pull Request**

## 📝 Coding Standards

### Dart/Flutter Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` before committing
- Format code with `dart format .`
- Use meaningful variable and function names
- Add comments for complex logic

### Architecture

IronFlow follows **Clean Architecture**:

```
lib/
├── features/
│   └── feature_name/
│       ├── data/          # Data sources & repositories
│       ├── domain/        # Entities & use cases
│       └── presentation/  # UI & state management
```

**Rules:**
- Domain layer has **no** framework dependencies
- Data layer implements domain interfaces
- Presentation layer depends on domain only

### Commit Convention

Use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting)
- `refactor:` Code refactoring
- `test:` Test changes
- `chore:` Build/config changes

**Examples:**
```
feat: add rest timer to workout screen
fix: resolve sync conflict in nutrition data
docs: update Firebase setup guide
test: add property-based tests for analytics
```

## 🧪 Testing

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/features/workout/workout_test.dart

# With coverage
flutter test --coverage
```

### Writing Tests

- **Unit tests**: Test business logic in domain layer
- **Widget tests**: Test UI components
- **Integration tests**: Test complete user flows
- **Property-based tests**: Test correctness properties

Example:
```dart
test('should calculate workout volume correctly', () {
  // Arrange
  final workout = Workout(...);
  
  // Act
  final volume = workout.calculateVolume();
  
  // Assert
  expect(volume, equals(expectedVolume));
});
```

## 📖 Documentation

- Update README.md if adding major features
- Add inline code comments for complex logic
- Create/update docs in `docs/` for architectural changes
- Include examples in documentation

## 🔍 Code Review Process

1. Automated checks must pass (tests, linting)
2. At least one maintainer review required
3. All conversations must be resolved
4. Branch must be up-to-date with master

## 📦 Setting Up Development Environment

1. **Install Flutter** (3.10.7+):
   ```bash
   flutter doctor
   ```

2. **Clone and setup**:
   ```bash
   git clone https://github.com/hamdiouni/ironflow-fitness-app.git
   cd ironflow-fitness-app
   flutter pub get
   ```

3. **Create .env file**:
   ```bash
   cp .env.example .env
   # Add your API keys
   ```

4. **Run code generation**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**:
   ```bash
   flutter run
   ```

## 🐛 Development Tips

### Hot Reload Issues

If hot reload isn't working:
```bash
flutter clean
flutter pub get
flutter run
```

### Code Generation

After modifying Freezed/Riverpod models:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Testing Firebase Locally

Use Firebase Emulator Suite:
```bash
firebase emulators:start
```

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 💬 Questions?

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and ideas
- **Email**: support@ironflow.app (coming soon)

---

**Thank you for contributing to IronFlow!** 🚀
