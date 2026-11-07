# IronFlow Localization & Translation Workflow Guide

This document outlines the standard operating procedure for maintaining, updating, and extending internationalization (i18n) across IronFlow.

---

## 1. Supported Locales

IronFlow natively supports 7 target locales with full 1:1 key parity:

| Locale Code | Language | Script / Direction | ARB Resource File |
| :---: | :--- | :---: | :--- |
| `en` | English (Template Locale) | LTR | `lib/l10n/app_en.arb` |
| `de` | German (`Deutsch`) | LTR | `lib/l10n/app_de.arb` |
| `es` | Spanish (`Español`) | LTR | `lib/l10n/app_es.arb` |
| `fr` | French (`Français`) | LTR | `lib/l10n/app_fr.arb` |
| `ja` | Japanese (`日本語`) | LTR | `lib/l10n/app_ja.arb` |
| `pt` | Portuguese (`Português`) | LTR | `lib/l10n/app_pt.arb` |
| `zh` | Simplified Chinese (`中文`) | LTR | `lib/l10n/app_zh.arb` |

---

## 2. Key Naming & Formatting Conventions

All user-facing strings must be declared in `.arb` files using `camelCase` identifiers and strict English descriptions:

```json
"workoutCompletedTitle": "Workout Completed!",
"@workoutCompletedTitle": {
  "description": "Title displayed on workout summary screen header"
}
```

### Plurals & Placeholders
For strings that vary with counts or dynamic numbers, use standard ICU message formatting:

```json
"setsCompletedCount": "{count, plural, =1{1 set completed} other{{count} sets completed}}",
"@setsCompletedCount": {
  "description": "Count of completed sets in a workout",
  "placeholders": {
    "count": {
      "type": "num",
      "format": "compact"
    }
  }
}
```

---

## 3. Translation Lifecycle

### Step 1: Add or Edit Strings in Template
Always modify `lib/l10n/app_en.arb` first:
1. Declare the new key and English text.
2. Provide an `@key` metadata object with a clear description for translators.

### Step 2: Propagate to All Target Locales
Update each corresponding `.arb` file:
- `lib/l10n/app_de.arb`
- `lib/l10n/app_es.arb`
- `lib/l10n/app_fr.arb`
- `lib/l10n/app_ja.arb`
- `lib/l10n/app_pt.arb`
- `lib/l10n/app_zh.arb`

### Step 3: Regenerate Dart Localizations
Run Flutter's code generation tool:

```bash
flutter gen-l10n
```

This updates `lib/l10n/app_localizations.dart` and the locale-specific delegates (`app_localizations_en.dart`, etc.).

### Step 4: Verification Gate
Run the localization integrity test suite:

```bash
flutter test test/localization/localization_completeness_and_rtl_test.dart
```

This enforces:
- 100% key parity across all 7 ARB files (zero missing keys).
- Zero runtime crashes when loading any supported locale.
- Clean layout rendering in both Left-to-Right and Right-to-Left (`RTL`) text directionalities.

---

## 4. Onboarding a New Locale (e.g. Arabic `ar`, Italian `it`)

1. Create `lib/l10n/app_<locale>.arb` by copying `app_en.arb`.
2. Translate all string values (leave keys unchanged).
3. Add the locale to `supportedLocales` in `lib/core/providers/language_provider.dart`:
   ```dart
   static const List<Locale> supportedLocales = [
     Locale('en'),
     ...
     Locale('ar'),
   ];
   ```
4. Declare the locale code in `ios/Runner/Info.plist` under `<key>CFBundleLocalizations</key>`.
5. Run `flutter gen-l10n` and verify with `flutter test`.

