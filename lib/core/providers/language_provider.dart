import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// Provider for managing app language/locale.
///
/// Persists language preference to Hive storage.
/// **Validates: Requirements 10.1 (Multi-Language Support)**
final languageProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

/// Notifier for managing language state.
class LanguageNotifier extends StateNotifier<Locale> {
  static const String _boxName = 'app_settings';
  static const String _languageKey = 'language_code';

  LanguageNotifier() : super(const Locale('en')) {
    _loadLanguage();
  }

  /// Supported locales for the app.
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('fr'), // French
    Locale('de'), // German
    Locale('pt'), // Portuguese
    Locale('ja'), // Japanese
    Locale('zh'), // Chinese (Simplified)
  ];

  /// Language names for display in UI.
  static const Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'pt': 'Português',
    'ja': '日本語',
    'zh': '中文',
  };

  /// Loads language preference from Hive storage.
  Future<void> _loadLanguage() async {
    try {
      final box = await Hive.openBox<String>(_boxName);
      final languageCode = box.get(_languageKey, defaultValue: 'en');
      
      // Validate that the language code is supported
      final locale = supportedLocales.firstWhere(
        (l) => l.languageCode == languageCode,
        orElse: () => const Locale('en'),
      );
      
      state = locale;
    } catch (e) {
      print('Error loading language: $e');
      state = const Locale('en');
    }
  }

  /// Sets the language to a specific locale.
  Future<void> setLanguage(Locale locale) async {
    // Validate that the locale is supported
    if (!supportedLocales.contains(locale)) {
      print('Unsupported locale: ${locale.languageCode}');
      return;
    }

    state = locale;
    
    try {
      final box = await Hive.openBox<String>(_boxName);
      await box.put(_languageKey, locale.languageCode);
    } catch (e) {
      print('Error saving language: $e');
    }
  }

  /// Sets the language by language code.
  Future<void> setLanguageByCode(String languageCode) async {
    final locale = supportedLocales.firstWhere(
      (l) => l.languageCode == languageCode,
      orElse: () => const Locale('en'),
    );
    
    await setLanguage(locale);
  }

  /// Gets the display name for the current language.
  String get currentLanguageName {
    return languageNames[state.languageCode] ?? 'English';
  }

  /// Gets the display name for a specific language code.
  static String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }
}

/// Provider for getting the current locale.
final currentLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(languageProvider);
});
