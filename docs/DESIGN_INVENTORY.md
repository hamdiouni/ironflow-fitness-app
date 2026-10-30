# IronFlow UI Surface Inventory & Baseline Measurements

**Branch**: `feat/ui-upgrade` (baseline tag: `backup-before-ui-upgrade` @ `07b90ef1fe104d8169da474db0b1dad2507dfda6`)  
**Scope**: Read-only audit of every UI surface in `lib/`, `web/`, `android/app/src/main/`, and `ios/Runner/`.  
**Status Legend**:
- `new` — Uses `AppThemeTokens`, shared `lib/shared/presentation/components/`, and simple English per `docs/COPY_GUIDE.md`.
- `mixed` — Partially migrated to `AppThemeTokens` / `AppCard` / `AppButton`, but still mixes raw Material widgets, hardcoded colors/sizes, sub-48dp controls, or banned sci-fi jargon.
- `old` — Legacy hardcoded `AppTheme.*`, `Colors.*`, `BackdropFilter` glass blur, `.withOpacity()`, unstyled Material defaults, or unmodified Flutter boilerplate.

---

## 1. Quantitative Baseline Measurements (Part 1.3)

### 1.1 Hardcoded Values Outside Design-System Token Files
Scanned **392** non-generated `.dart` files in `lib/` outside `lib/core/theme/` and `lib/core/constants/app_theme.dart` (`397` total non-generated `.dart` files in `lib/`, excluding `*.g.dart` and `*.freezed.dart`):

| Metric | Count | Notes |
| --- | ---: | --- |
| Hardcoded `Color(0x...)` literals | **65** | Includes `#00E676`, `#FFB300`, `#FFD54F`, `#4FC3F7`, `#FFB74D`, `#F06292`, `#FF0000`, `#0A0A0A` |
| Hardcoded `Colors.*` references | **253** | Includes `Colors.black`, `Colors.white`, `Colors.white10`, `Colors.redAccent`, `Colors.amberAccent`, `Colors.grey[...]` |
| **Total hardcoded colors** | **318** | Outside `lib/core/theme/` and `app_theme.dart` |
| Hardcoded `fontSize:` occurrences | **808** | Inline `TextStyle(fontSize: ...)` bypassing `AppTypography` |
| Hardcoded `BorderRadius` / `Radius` | **523** | Inline `BorderRadius.circular(...)` / `Radius.circular(...)` bypassing `AppRadii` |
| Hardcoded `EdgeInsets.*` | **596** | Inline `EdgeInsets.all` / `symmetric` / `only` / `fromLTRB` bypassing `AppSpacings` |
| Hardcoded `SizedBox(height/width:)` | **985** | Inline numeric gaps bypassing `AppSpacings` |
| **Total hardcoded spacing occurrences** | **1,581** | `EdgeInsets.*` + `SizedBox(height/width:)` |

### 1.2 Bundled Fonts & Open-License Verification
No runtime font downloads (`google_fonts` is not in `pubspec.yaml`). Both bundled fonts in `assets/fonts/` carry open licenses embedded in their OpenType `name` tables:

| Font Family | Bundled Asset | Size | Version & Author | License |
| --- | --- | ---: | --- | --- |
| **Inter** | `assets/fonts/Inter.ttf` | 876,576 B | Version 4.001 — Copyright 2016 The Inter Project Authors (`https://github.com/rsms/inter`) | **SIL Open Font License, Version 1.1** (`https://openfontlicense.org`) |
| **SpaceGrotesk** | `assets/fonts/SpaceGrotesk.ttf` | 136,676 B | Version 2.000 — Copyright 2020 The Space Grotesk Project Authors / Florian Karsten (`https://github.com/floriankarsten/space-grotesk`) | **SIL Open Font License, Version 1.1** (`https://scripts.sil.org/OFL`) |

### 1.3 Nested Containers, Cards & Borders Per Screen File
Counts across every screen file in `lib/` (demonstrating widespread nested boxes, 1px borders on every container, and card-inside-card layering):

| Screen File | `Container` | `AppCard` | `Card` | `Border` / `BorderSide` |
| --- | ---: | ---: | ---: | ---: |
| `lib/features/nutrition/presentation/screens/food_search_screen.dart` | 30 | 1 | 0 | 28 |
| `lib/features/onboarding/presentation/screens/onboarding_screen.dart` | 28 | 0 | 0 | 22 |
| `lib/features/ai/presentation/screens/ai_chat_screen.dart` | 28 | 0 | 0 | 20 |
| `lib/features/auth/presentation/screens/signup_screen.dart` | 4 | 0 | 0 | 25 |
| `lib/features/workout/presentation/screens/active_workout_screen.dart` | 13 | 1 | 0 | 16 |
| `lib/features/settings/presentation/screens/settings_screen.dart` | 11 | 0 | 0 | 16 |
| `lib/features/settings/presentation/screens/export_settings_screen.dart` | 11 | 0 | 0 | 15 |
| `lib/features/auth/presentation/screens/login_screen.dart` | 5 | 0 | 0 | 15 |
| `lib/features/profile/presentation/screens/profile_screen.dart` | 16 | 0 | 0 | 14 |
| `lib/features/nutrition/presentation/screens/nutrition_screen.dart` | 16 | 3 | 0 | 13 |
| `lib/features/settings/presentation/screens/privacy_settings_screen.dart` | 8 | 0 | 0 | 13 |
| `lib/features/body/presentation/screens/progress_screen.dart` | 7 | 5 | 0 | 11 |
| `lib/features/workout/presentation/screens/home_screen.dart` | 9 | 14 | 1 | 9 |
| `lib/features/workout/presentation/screens/program_editor_screen.dart` | 0 | 0 | 0 | 8 |
| `lib/features/notifications/presentation/screens/reminder_settings_screen.dart` | 6 | 0 | 0 | 6 |
| `lib/features/workout/presentation/screens/workout_screen.dart` | 6 | 4 | 0 | 5 |
| `lib/features/analytics/presentation/screens/analytics_screen.dart` | 5 | 0 | 0 | 5 |
| `lib/features/workout/presentation/screens/program_selection_screen.dart` | 3 | 0 | 0 | 5 |
| `lib/features/auth/presentation/screens/splash_screen.dart` | 3 | 0 | 0 | 5 |
| `lib/features/workout/presentation/screens/exercise_catalog_screen.dart` | 5 | 1 | 0 | 4 |
| `lib/features/nutrition/presentation/screens/nutrition_history_screen.dart` | 5 | 0 | 0 | 3 |
| `lib/features/tools/presentation/screens/tools_hub_screen.dart` | 3 | 0 | 0 | 3 |
| `lib/features/design_system/presentation/screens/design_gallery_screen.dart` | 4 | 4 | 0 | 2 |
| `lib/features/ai/presentation/screens/ai_test_screen.dart` | 3 | 0 | 0 | 1 |
| `lib/features/workout/presentation/screens/workout_history_screen.dart` | 3 | 0 | 0 | 1 (+ `glassmorphicCard` per row) |
| `lib/features/workout/presentation/screens/workout_summary_screen.dart` | 3 | 3 | 0 | 0 (+ nested `PRCelebrationAnimation` & `ProgressionSuggestionCard` borders) |
| `lib/features/workout/presentation/screens/exercise_picker_screen.dart` | 2 | 0 | 0 | 0 |
| `lib/features/workout/presentation/screens/exercise_detail_screen.dart` | 1 | 0 | 0 | 0 (+ `glassmorphicCard` per history row) |

### 1.4 Button Styles in Use Across `lib/` (8 Widget Classes, 14+ Visual Variants)
Total interactive button/tap call sites counted across `lib/`: **254**

| Button Pattern | Count | Visual Variants & Inconsistencies |
| --- | ---: | --- |
| `AppButton` (`primary`, `secondary`, `ghost`, `destructive`) | **61** | Radius `10px` (`AppRadii.sm`), `SpaceGrotesk` 14px bold, `minTouchTarget: 48dp` — **but** 12 call sites pass `height: 36..46`, and `primary` hardcodes `Colors.black` text on `tokens.kineticAccent` (**3.97:1 WCAG AA failure** in light mode `#0A7C42`). |
| Custom `InkWell` / `GestureDetector` pill/box buttons | **71** | Radii range from `4px` to `999px`; heights range from **16dp** (RPE/RIR toggle) and **22dp** (`SWAP` meal pill) to **44dp**; most lack `Semantics(button: true)` and focus/hover states. |
| `IconButton` | **48** | Mostly 48dp default, **except** `_CreateCustomFoodDialog` close button (`20×20dp`), `ReminderSettingsScreen` test ping (`40×40dp`), and video overlay buttons (`28×28dp`). |
| `TextButton` | **39** | Used inside raw `AlertDialog` actions and inline links (`'VIEW ALL'`, `'CHANGE SPLIT'`, `'LOG TO TODAY'` with `minimumSize: Size.zero` ~24–26dp). |
| `ElevatedButton` / `ElevatedButton.icon` | **16** | Theme default is `kineticAccent` + `Colors.black` + `12px` radius, **overridden** in `ProgramSelectionScreen` (`cyanAccent`), `YouTubeExercisePlayer` (`#FF0000` red), `PrivacySettingsScreen` (`tokens.error`), and `ProgressionSuggestionCard` (`AppTheme.primaryColor`). |
| `FilledButton` / `FilledButton.icon` | **9** | No `FilledButtonThemeData` in `AppTheme` (falls back to M3 stadium pill `999px`!), overridden ad-hoc in `AiCoachHeroCard` (`10px` radius, `Colors.black` on `#0A7C42` light-mode contrast fail) and `AIChatScreen` (`Colors.redAccent`). |
| `OutlinedButton` / `OutlinedButton.icon` | **9** | No `OutlinedButtonThemeData` in `AppTheme` (falls back to M3 stadium pill), overridden with `8px`, `10px`, and `12px` radii across `YouTubeExercisePlayer`, `SuggestedDietPlanCard`, `ProgressionSuggestionCard`, and `ExportSettingsScreen`. |
| `FloatingActionButton` | **1** | Legacy floating action usage outside shared button tokens. |

### 1.5 Dialog & Bottom Sheet Styles in Use Across `lib/`
- **Dialogs (`30` total: `28` `AlertDialog` + `2` `Dialog`) — 6 distinct visual styles**:
  1. **`AppDialog`** (`Dialog` with `tokens.panel`, `1px borderSubtle`, `20px` radius, circular 48dp icon badge, dual `AppButton` footer): **0 production usages** (only `DesignGalleryScreen:424`).
  2. **Tokenized `AlertDialog` with `1px borderSubtle` & `16px`–`20px` radius**: Used in `SettingsScreen`, `ProfileScreen`, `ExportSettingsScreen`, `PrivacySettingsScreen`, `ActiveWorkoutScreen` (mixes `TextButton`, `ElevatedButton`, and `AppButton` actions).
  3. **Tokenized `AlertDialog` without border**: Used in `OnboardingScreen:257`, `ProgramEditorScreen:360`, `ProgramSelectionScreen:172`, `ProgressScreen:481, 648`.
  4. **Unstyled raw M3 `AlertDialog`** (inherits M3 default surface/purple tint or `DialogTheme` without token typography): `ErrorHandler:74`, `ProgramCompleteDialog:13`, `SuggestedDietPlanCard:535`, `SyncIndicator:190`.
  5. **Full custom `Dialog` with `20×20dp` close icon and scrolling 7-field form**: `_CreateCustomFoodDialog` (`food_search_screen.dart:1898`).
  6. **Non-dismissible blocking spinner `AlertDialog`**: Logout progress dialogs (`profile_screen.dart:1137`, `settings_screen.dart:95`).
- **Bottom Sheets (`15` modal sheets + `1` shared `AppBottomSheet` wrapper; `0` persistent sheets) — 4 distinct visual styles**:
  1. **`AppBottomSheet.show`** (`tokens.panel`, `20px` top radius, `36×4` drag handle, `1px` top border): Used in `DesignGalleryScreen` + 5 calculator sheets (`calculator_sheets.dart`). Has an `if (title != null) ... else ?action` header bug that drops trailing actions whenever `title` is present.
  2. **Custom `showModalBottomSheet` with drag handle & `tokens.panel`/`tokens.card`**: `PlateCalculatorSheet`, `ExerciseSelectionSheet`, `ExerciseSwapSheet`, `_showComparisonSheet`, `_showRestoreModal`.
  3. **`showModalBottomSheet` + `DraggableScrollableSheet` (`24px` top radius)**: `_FoodDetailAndQuantitySheet` (`food_search_screen.dart:807`), `_showPrivacyPolicyModal` (`privacy_settings_screen.dart:511`).
  4. **Raw unstyled `showModalBottomSheet` with NO drag handle**: `HomeScreen` User Hub (`home_screen.dart:242`), `_TTSSettingsSheet` (`ai_chat_screen.dart:1321`), `QuickFeedbackBottomSheet` (`quick_feedback_bottom_sheet.dart:53`).

### 1.6 Five Contradictory Macro Color Schemes
| Location | Protein | Carbs | Fats |
| --- | --- | --- | --- |
| 1. `AppColors` / `MacroWheelChart` / `NutritionScreen` | `#FF4B6E` (Coral Pink) | `#00D2FF` (Cyan) | `#FFB800` (Amber) |
| 2. `OnboardingScreen` Step 7 (`onboarding_screen.dart:1392–1410`) | `#4FC3F7` (Light Blue) | `#FFB74D` (Orange) | `#F06292` (Pink) |
| 3. `HomeScreen` `_DailyFuelSummaryBar` (`home_screen.dart:998–1002`) | `tokens.cyanAccent` | `tokens.warning` (Amber) | `tokens.violetAccent` |
| 4. `ProfileScreen` `_DietPlanCard` (`profile_screen.dart:857–888`) | `tokens.kineticAccent` (Green) | `tokens.cyanAccent` | `tokens.violetAccent` |
| 5. `CalorieMacroSheet` (`calculator_sheets.dart:460–484`) | `tokens.kineticAccent` (Green) | `Colors.lightBlueAccent` | `Colors.orangeAccent` |

---

## 2. Exhaustive UI Surface Inventory (Part 1.1)

### 2.1 Theme Foundation & Shared Design-System Components (`INV-F01`–`INV-F19`)

| ID | Surface / Component | File & Lines | Status | Main Problems |
| --- | --- | --- | --- | --- |
| `INV-F01` | Color palette (`AppColors`) | `lib/core/theme/app_colors.dart:1–87` | `mixed` | Still defines Electric Hyper-Lime `#00FF87` (`darkKineticAccent`) instead of Slate Teal; `darkTextMuted` (`#525866`) fails WCAG AA (`2.23:1`–`2.55:1` on dark surfaces). |
| `INV-F02` | Spacing, radii & motion tokens | `lib/core/theme/app_spacings.dart:1–40` | `new` | Clean token definitions, but bypassed `1,581` times (spacing) and `523` times (radii) in widgets. |
| `INV-F03` | Typography scale (`AppTypography`) | `lib/core/theme/app_typography.dart:1–160` | `new` | Clean `SpaceGrotesk` + `Inter` + tabular numerals, but bypassed `808` times via raw `fontSize:`. |
| `INV-F04` | Theme extension (`AppThemeTokens`) | `lib/core/theme/app_theme_tokens.dart:1–262` | `mixed` | Missing `onAccent` / `onKineticAccent` token and semantic container foreground tokens (`onSuccess`, `onWarning`, `onError`, `onInfo`). |
| `INV-F05` | `ThemeData` builder (`AppTheme`) | `lib/core/constants/app_theme.dart:1–326` | `mixed` | Retains dark-only static fields (`AppTheme.primaryColor`, `backgroundColor`, `glassmorphicCard()` `BackdropFilter` sigma `10`); omits `SnackBarThemeData`, `FilledButtonThemeData`, `OutlinedButtonThemeData`, `ChipThemeData`, `TabBarThemeData`, `SwitchThemeData`, `PopupMenuThemeData`, `DatePickerThemeData`, `TimePickerThemeData`, `NavigationBarThemeData`, `NavigationRailThemeData`, and `AppBarTheme.systemOverlayStyle`. |
| `INV-F06` | `AppButton` | `lib/shared/presentation/components/app_button.dart:1–248` | `mixed` | Hardcodes `fg = Colors.black` on `primary` (`3.97:1` WCAG AA fail on light-mode `#0A7C42`); lacks `tertiary` level and icon-only variant; callers pass `height: 36..46` fighting `minHeight: 48`. |
| `INV-F07` | `AppCard` | `lib/shared/presentation/components/app_card.dart:1–119` | `mixed` | Draws a permanent `1px` `borderSubtle` border on every card and supports neon `isGlowing` shadow, violating frame-light rules (borders only for selected/focus/error). |
| `INV-F08` | `AppStatTile` | `lib/shared/presentation/components/app_stat_tile.dart:1–161` | `new` | Underused across Workout Summary, Progress, Nutrition, and Profile (screens build ad-hoc stat boxes). |
| `INV-F09` | `AppSectionHeader` | `lib/shared/presentation/components/app_section_header.dart:1–115` | `mixed` | Trailing `InkWell` action (`L80–109`) is ~28dp tall (<48dp minimum touch target). |
| `INV-F10` | `AppDialog` | `lib/shared/presentation/components/app_dialog.dart:6–158` | `new` | **0 production usages** (only `DesignGalleryScreen:424`); inherits `AppButton` light-mode contrast bug. |
| `INV-F11` | `AppBottomSheet` | `lib/shared/presentation/components/app_bottom_sheet.dart:28–117` | `mixed` | **Bug (`L89–102`)**: `if (title != null) ... else ?action` drops `action` whenever `title` is non-null; lacks wide-web `maxWidth` constraint and keyboard `viewInsets.bottom` scroll handling. |
| `INV-F12` | `AppTextField` | `lib/shared/presentation/components/app_text_field.dart:8–172` | `mixed` | **0 production usages**; missing `validator`, `inputFormatters`, `focusNode`, `textInputAction`; helper text uses `tokens.textMuted` (`2.23:1` dark-mode contrast fail). |
| `INV-F13` | `AppChip` | `lib/shared/presentation/components/app_chip.dart:7–105` | `new` | 48dp-compliant, but used in only 2 production files (`ExerciseCatalogScreen`, `LiftsVolumeTab`). |
| `INV-F14` | `AppListTile` | `lib/shared/presentation/components/app_list_tile.dart:8–127` | `new` | **0 production usages** (only `DesignGalleryScreen`). |
| `INV-F15` | `AppProgressRing` & `AppProgressBar` | `lib/shared/presentation/components/app_progress.dart:1–198` | `new` | `AppProgressRing` has **0 production usages**. |
| `INV-F16` | `AppShimmer` | `lib/shared/presentation/components/app_shimmer.dart:8–104` | `new` | Honors `MediaQuery.disableAnimations`, but has **0 production usages**. |
| `INV-F17` | `AppStateView` (`empty`/`error`/`offline`) | `lib/shared/presentation/components/app_state_views.dart:1–145` | `new` | **0 production usages**. |
| `INV-F18` | Legacy `loading_states.dart` & `empty_state_widget.dart` | `lib/shared/widgets/loading_states.dart:5–331`; `lib/shared/widgets/empty_state_widget.dart:5–157` | `old` / `mixed` | Duplicate state widgets; `loading_states.dart` hardcodes `Colors.grey[800]`, ignores `disableAnimations`, and shadows Flutter's `ProgressIndicator`. |
| `INV-F19` | `IronFlowLogo` | `lib/shared/widgets/ironflow_logo.dart:1–130` | `mixed` | Hardcodes `#00E676` and `#0A0A0A`; bypassed on `SplashScreen` and `LoginScreen`. |

---

### 2.2 All Screens & Routes (`INV-S01`–`INV-S30`)

| ID | Screen / Surface | File & Lines | Route / Entry | Status | Main Problems |
| --- | --- | --- | --- | --- | --- |
| `INV-S01` | Boot Error App (`InitializationErrorApp`) | `lib/main.dart:118–194` | `runApp` fallback | `old` | Hardcoded dark-only `#0A0A0A`, `Colors.redAccent`, `Colors.white70`, no theme tokens. |
| `INV-S02` | Main 4-Tab Shell (`MainScaffold`) | `lib/main.dart:226–319` | `StatefulShellRoute` | `mixed` | Legacy M2 `BottomNavigationBar`; `textMuted` unselected contrast `2.55:1`; no `NavigationRail` or `maxWidth` on wide web; stays visible on immersive child routes (`/workout/active`, `/workout/summary`, `/workout/editor`, etc.); hardcoded English ALL-CAPS labels. |
| `INV-S03` | Splash Screen (`SplashScreen`) | `lib/features/auth/presentation/screens/splash_screen.dart:11–221` | `/` | `mixed` | Banned jargon `'BIOMETRIC TELEMETRY & TRAINING SYSTEM'`, `'// INITIALIZING TERMINAL'`; ignores `disableAnimations`; custom logo box instead of `IronFlowLogo`. |
| `INV-S04` | Login Screen (`LoginScreen`) | `lib/features/auth/presentation/screens/login_screen.dart:14–591` | `/login` | `mixed` | Jargon `'TERMINAL ACCESS'`; raw `TextFormField`s; no Forgot Password UI; unconditional `'AUTOFILL DEMO ACCOUNT'` (~24dp) in non-debug UI; stretches full width on desktop web. |
| `INV-S05` | Signup Screen (`SignupScreen`) | `lib/features/auth/presentation/screens/signup_screen.dart:14–710` | `/signup` | `mixed` | Jargon `'INITIALIZE IDENTITY'`, `'Establish new biometric telemetry profile...'`, `'Back to Authentication'`; `25` hardcoded border definitions; raw `TextFormField`s; stretches full width on desktop web. *(Note: `_nameController` value is validated in UI but not forwarded in `_handleEmailSignUp`).* |
| `INV-S06` | Onboarding Wizard (`OnboardingScreen`, 7 steps) | `lib/features/onboarding/presentation/screens/onboarding_screen.dart:31–2421` | `/onboarding` | `mixed` | Heavy jargon (`'STEP 01 // 07'`, `'ENVIRONMENT // 01'`, `'PROTOCOL INITIALIZED'`, `'START PROTOCOL'`); contradictory macro colors (`#4FC3F7`, `#FFB74D`, `#F06292`); `28` `Container`s & `22` borders; sub-48dp unit chips (~28dp); no Back/Cancel exit when opened from Profile/Settings; no wide-web `maxWidth`. |
| `INV-S07` | Today / Home Tab (`HomeScreen`) | `lib/features/workout/presentation/screens/home_screen.dart:22–1660` | `/home` (Tab 0) | `mixed` | Jargon (`'NO ACTIVE PROTOCOL'`, `'PROFILE & BIOMETRICS'`, `'OPEN FUEL DOCK'`); duplicate `'REST DAY'` title + pill; contradictory macro colors (`cyanAccent`/`warning`/`violetAccent`); nested bordered cards; sub-48dp button height overrides (`38`..`46`); hardcoded `'kg'`; `_ProfileSetupPrompt` lacks CTA button; single-column full-width stretch on wide web. |
| `INV-S08` | Train / Workout Tab (`WorkoutScreen`) | `lib/features/workout/presentation/screens/workout_screen.dart:31–852` | `/workout` (Tab 1) | `mixed` | Jargon (`'TELEMETRY ERROR'`, `'ACTIVE PROTOCOL'`, `'RECOVERY PHASE'`); 5 cramped icons in `AppBar`; embeds legacy glassmorphic `StreakDisplay`; sub-48dp `'CHANGE SPLIT'` (~20dp) & `'VIEW ALL'` (~24dp); hardcoded `'KG'`. |
| `INV-S09` | Active Workout (`ActiveWorkoutScreen`) | `lib/features/workout/presentation/screens/active_workout_screen.dart:30–1498` | `/workout/active` | `mixed` | Jargon (`'log sets with telemetry'`, `'workout protocol'`); 3 raw `AlertDialog`s (including blocking calorie dialog on Finish); `ExerciseSelectionSheet` uses hardcoded 45-string list instead of `ExerciseDatabase`; PR `SnackBar` white-on-`#00FF87` contrast failure; sub-48dp unit toggle (~28dp), rest timer buttons (`36dp`), set-type chips (~24dp), RPE/RIR toggle (~16dp); bottom nav remains visible. |
| `INV-S10` | Workout Summary (`WorkoutSummaryScreen`) | `lib/features/workout/presentation/screens/workout_summary_screen.dart:30–867` | `/workout/summary`, `/workout/summary/:workoutId` | `mixed` | Hardcoded `Colors.orange`, `Colors.purple`, `AppTheme.primaryColor`; nests `PRCelebrationAnimation` (`'TELEMETRY // MILESTONE'`, hardcoded `Colors.white` text invisible in light mode) inside `AppCard`; embeds legacy `ProgressionSuggestionCard` (`Colors.red`/`green`, raw Material buttons); no `AppBar`; hardcoded `'kg'`; bottom nav remains visible. |
| `INV-S11` | Workout History (`WorkoutHistoryScreen`) | `lib/features/workout/presentation/screens/workout_history_screen.dart:16–525` | `/workout/history` | `old` | Applies `AppTheme.glassmorphicCard` (`BackdropFilter` sigma `10`) to **every row** of a 1000-item `ListView.builder`; nested bordered `_ExerciseDetailItem`; **dead empty-state CTA** (`onStartWorkout: () {}`); hardcoded `'kg'`. |
| `INV-S12` | Split Generator (`ProgramSelectionScreen` + `split_generator/*`) | `lib/features/workout/presentation/screens/program_selection_screen.dart:39–647` | `/workout/program-selection` | `mixed` | Heavy jargon (`'PROTOCOL GENERATOR'`, `'APPLY PROTOCOL'`, `'7-DAY SCHEDULE MATRIX'`, `'HYBRID ARCHITECTURE MODE'`); raw `ElevatedButton` CTA in `cyanAccent`; raw `AlertDialog`; sub-48dp tabs (`28–36dp`); `ExerciseSwapSheet` limited to 3 items with no search. |
| `INV-S13` | Program Builder / Editor (`ProgramEditorScreen` + `ExerciseEditCard`) | `lib/features/workout/presentation/screens/program_editor_screen.dart:25–612` | `/workout/editor` | `mixed` | Jargon (`'EDIT PARAMETERS'`, `'Parameters updated successfully'`, `'RECOVERY DAY'`); raw `AlertDialog` with 3 raw `TextField`s and `height: 40` buttons; sub-48dp day chips (~32dp); no UI button to add a new exercise to a day. |
| `INV-S14` | Exercise Catalog (`ExerciseCatalogScreen`) | `lib/features/workout/presentation/screens/exercise_catalog_screen.dart:14–477` | `/workout/catalog` | `mixed` | Fixed `crossAxisCount: 2` (`aspectRatio: 0.80`) blows up to giant 600×750px cards on wide web; sub-48dp `_EquipChip` (~24dp); raw `TextField`; pushes `ExerciseDetailScreen` via `MaterialPageRoute`. |
| `INV-S15` | Exercise Picker (`ExercisePickerScreen`) | `lib/features/workout/presentation/screens/exercise_picker_screen.dart:17–229` | `/exercise-picker` | `old` | Unstyled Material `TextField`, `FilterChip`, `ListTile`, raw empty state; redundant picker implementation. |
| `INV-S16` | Exercise Detail (`ExerciseDetailScreen`) | `lib/features/workout/presentation/screens/exercise_detail_screen.dart:30–452` | `/workout/exercise/:name` | `old` | `AppTheme.glassmorphicCard` history rows; legacy `AppTheme.primaryColor`/`accentColor`; 2 bare `LineChart`s outside cards with no touch tooltips; error state lacks Retry button; hardcoded `'kg'`. |
| `INV-S17` | Exercise Video Area & Error Card (`YouTubeExercisePlayer`) | `lib/shared/widgets/youtube_exercise_player.dart:26–445` | Embedded in `ExerciseDetailScreen` | `mixed` | Jargon `'INITIALIZING TELEMETRY STREAM...'`; Video Error Card uses raw `OutlinedButton.icon` and `#FF0000` `ElevatedButton.icon`; Copy Link & Mute overlay buttons are `28×28dp` (<48dp); duplicate unused `workout/presentation/widgets/exercise_video_player.dart`. |
| `INV-S18` | Fuel / Nutrition Tab (`NutritionScreen` + `SuggestedDietPlanCard`) | `lib/features/nutrition/presentation/screens/nutrition_screen.dart:35–1867` | `/nutrition` (Tab 2) | `mixed` | Jargon (`'PROTOCOL & TARGET TELEMETRY'`, `'TELEMETRY OFFLINE'`, `'DAILY TARGET PROTOCOL'`, `'CALCULATING PROTOCOL...'`); **dead empty-state CTA** in `SwipeableMealCards` (`onLogMeal: () {}`); swipe-delete lacks Undo snackbar; 3 raw `AlertDialog`s; sub-48dp day tabs (~28dp) & `SWAP`/`LOG TO TODAY` buttons (~26dp); green SnackBar contrast failure (`#00E676` + white text). |
| `INV-S19` | Food Search (`FoodSearchScreen`) | `lib/features/nutrition/presentation/screens/food_search_screen.dart:24–2191` | Unrouted (`MaterialPageRoute`) | `mixed` | `30` `Container`s & `28` borders; heavy jargon (`'FUEL DATABASE'`, `'VERIFIED NUTRITION TELEMETRY'`, `'NEW FUEL ENTRY'`, `'SAVE FUEL'`); hardcoded `#00E676`, `#FFB300`, `#FFD54F`, `Colors.white10` dividers (invisible in light mode); sub-48dp `_SciFiPill` (`38dp`), `_BudgetPill` (`34dp`), and `20×20dp` dialog close button. |
| `INV-S20` | Nutrition History (`NutritionHistoryScreen`) | `lib/features/nutrition/presentation/screens/nutrition_history_screen.dart:14–473` | `/nutrition/history` | `mixed` | Jargon (`'LOG ARCHIVE UNREACHABLE'`, `'RETRY ARCHIVE FETCH'`, `'NO ARCHIVED TELEMETRY'`); ad-hoc empty/error widgets instead of `AppStateView`; bottom nav remains visible. |
| `INV-S21` | Progress Tab (`ProgressScreen` + `LiftsVolumeTab` + `ProgressPhotoComparison`) | `lib/features/body/presentation/screens/progress_screen.dart:33–1106` | `/progress` (Tab 3) | `mixed` | Jargon (`'start calibration'`, `'LATEST TELEMETRY'`, `'EXERCISE TARGET DENSITY'`); 2 raw `AlertDialog`s with raw `TextFormField`s, hardcoded `'kg'`/`'cm'`, and light-mode button contrast failure; `LiftsVolumeTab` error state lacks Retry button and charts lack tooltips; sub-48dp `'COMPARE BEFORE & AFTER'` (`38dp`); fixed 2-column photo grid on wide web; unguarded `Image.file(File(...))` on web. |
| `INV-S22` | Legacy Analytics Screen (`AnalyticsScreen`) | `lib/features/analytics/presentation/screens/analytics_screen.dart:13–708` | Unrouted (`/analytics` redirects) | `old` | Dead duplicate of `LiftsVolumeTab` + 4 dark-only chart widgets in `analytics/presentation/widgets/`. |
| `INV-S23` | Tools & Calculators Hub (`ToolsHubScreen`) | `lib/features/tools/presentation/screens/tools_hub_screen.dart:11–254` | `/tools` | `mixed` | Jargon `'SCIENTIFIC FITNESS PROTOCOLS'`; launches 6 calculator sheets with hardcoded metric units and sub-48dp controls. |
| `INV-S24` | AI Coach Chat Screen & Hero Card (`AIChatScreen` + `AiCoachHeroCard`) | `lib/features/ai/presentation/screens/ai_chat_screen.dart:23–1884`; `widgets/ai_coach_hero_card.dart:26–374` | `/ai-chat` + embedded | `mixed` | `28` `Container`s & `20` borders; `_AIResponseContent`, `_AudioControls`, and `_TTSSettingsSheet` use 18 deprecated `.withOpacity()` calls & emoji headers; `_AudioWavePainter` freezes after 1s; sub-48dp category/prompt/speed chips (`26–34dp`); `AiCoachHeroCard` CTA fails light-mode contrast (`3.97:1`); `AiNoKeyState` shows developer jargon. |
| `INV-S25` | Profile Screen (`ProfileScreen`) | `lib/features/profile/presentation/screens/profile_screen.dart:20–1331` | `/profile` | `mixed` | Jargon (`'Error loading profile telemetry'`, `'ACTIVE PROTOCOL'`, `'NUTRITION PROTOCOL'`, `'Terminating session...'`); error state lacks Retry button; 4th contradictory macro color scheme; hardcoded `'KG'`/`'CM'`; 2 raw `AlertDialog`s; sub-48dp `ListTile(dense: true)` (~40dp). |
| `INV-S26` | Settings Screen (`SettingsScreen`) | `lib/features/settings/presentation/screens/settings_screen.dart:29–1124` | `/settings` | `mixed` | Jargon (`'SYSTEM CONFIGURATION'`, `'MONOLITHIC DARK THEME'`, `'ENGINE ARCHITECTURE: MONOLITHIC SCI-FI'`); missing `ThemeMode.system`, Units (`kg`/`lb`, `cm`/`in`), and Language selectors; 5 raw `AlertDialog`s (including release-reachable state inspector on `onLongPress`); `context.go` calls strip back-navigation on child screens. |
| `INV-S27` | Reminders / Notifications Settings (`ReminderSettingsScreen`) | `lib/features/notifications/presentation/screens/reminder_settings_screen.dart:9–475` | `/settings/reminders` (`/profile/reminder-settings`) | `mixed` | **No back button** when opened from `SettingsScreen` via `context.go`; jargon (`'NOTIFICATION MATRIX'`, `'⚡ TELEMETRY PING'`, `'HAPTIC & AUDIO PROTOCOL'`); `40×40dp` test icon button; invisible `tokens.panel` SnackBar (`L96`); `showTimePicker` white-on-neon-green contrast failure (`L451`). |
| `INV-S28` | Backup, Restore & Data Export (`ExportSettingsScreen`) | `lib/features/settings/presentation/screens/export_settings_screen.dart:13–1063` | `/settings/export` (pushed via `MaterialPageRoute`) | `mixed` | Heavy jargon (`'LOCAL DATA SOVEREIGNTY'`, `'WORKOUT TELEMETRY'`, `'SYSTEM RESTORATION PROTOCOL'`, `'TELEMETRY FAULT'`, `'ACKNOWLEDGE'`); misleading `'Complete encrypted snapshot'` copy; 3 raw `AlertDialog`s + raw restore sheet; white-on-`#00FF87` SnackBars; unguarded `dart:io` backup listing on web. |
| `INV-S29` | Privacy Policy & Data Deletion (`PrivacySettingsScreen`) | `lib/features/settings/presentation/screens/privacy_settings_screen.dart:24–1060` | `/settings/privacy` (pushed via `MaterialPageRoute`) | `mixed` | Heavy jargon (`'PRIVACY & TELEMETRY'`, `'ERADICATE LOCAL TELEMETRY'`, `'CONFIRM & DESTROY'`, `'ACKNOWLEDGE'`); 4 deprecated `SwitchListTile(activeColor:)` calls; 3 raw `AlertDialog`s + raw policy sheet; divergent Privacy Policy text vs `SettingsScreen`. *(Note: `Navigator.pushNamed` calls at `L189` and `L933` fail under `MaterialApp.router`).* |
| `INV-S30` | Debug Screens (`AITestScreen` & `DesignGalleryScreen`) | `lib/features/ai/presentation/screens/ai_test_screen.dart:8–369`; `lib/features/design_system/presentation/screens/design_gallery_screen.dart:11–481` | `/ai-test`, `/design-gallery` (`kDebugMode`) | `old` (`AITestScreen`) / `new` (`DesignGalleryScreen`) | `AITestScreen` uses light-only `Colors.white`, `Colors.blue.shade50`, `.withOpacity()`; `DesignGalleryScreen` is clean `new` token showcase. |

---

### 2.3 All Dialogs (`INV-D01`–`INV-D30`)

| ID | Dialog Surface | File & Lines | Status | Main Problems |
| --- | --- | --- | --- | --- |
| `INV-D01` | `AppDialog` template showcase | `lib/shared/presentation/components/app_dialog.dart:54–156` | `new` | Unused in production; primary confirm button fails light-mode contrast via `AppButton`. |
| `INV-D02` | Generic error dialog (`ErrorHandler.handleError`) | `lib/core/utils/error_handler.dart:74–88` | `old` | Unstyled Material `AlertDialog` + raw `TextButton('OK')`. |
| `INV-D03` | Onboarding Sign Out confirmation | `lib/features/onboarding/presentation/screens/onboarding_screen.dart:257–293` | `mixed` | Raw `AlertDialog` + `TextButton`s instead of `AppDialog`. |
| `INV-D04` | Discard Active Workout confirmation | `lib/features/workout/presentation/screens/active_workout_screen.dart:261–296` | `mixed` | Raw `AlertDialog` + `TextButton`s instead of `AppDialog(isDestructive: true)`. |
| `INV-D05` | Finish Workout Calorie Input dialog | `lib/features/workout/presentation/screens/active_workout_screen.dart:508–594` | `mixed` | Mandatory blocking `AlertDialog` on every finish; jargon `'Record estimated energy expenditure'`; raw `TextField`; sub-48dp `AppButton(height: 42)`. |
| `INV-D06` | Program Complete celebration dialog (`ProgramCompleteDialog`) | `lib/features/workout/presentation/widgets/program_complete_dialog.dart:13–67` | `old` | Hardcoded `Colors.grey`, unstyled `AlertDialog` & `ElevatedButton`. |
| `INV-D07` | Standalone `RestTimerDialog` | `lib/features/workout/presentation/widgets/rest_timer_widget.dart:309–413` | `mixed` | Unreferenced dead dialog; raw `AlertDialog`; sub-48dp `_DurationChip` (~36dp). |
| `INV-D08` | Edit Exercise Sets/Reps dialog (`_showEditDialog`) | `lib/features/workout/presentation/screens/program_editor_screen.dart:360–533` | `mixed` | Jargon `'EDIT PARAMETERS'`; raw `AlertDialog` + 3 raw `TextField`s; `height: 40` buttons. |
| `INV-D09` | Replace Active Split confirmation | `lib/features/workout/presentation/screens/program_selection_screen.dart:172–213` | `mixed` | Jargon `'CHANGE ACTIVE PROTOCOL?'`; raw `AlertDialog` + `cyanAccent` `ElevatedButton`. |
| `INV-D10` | Log Custom Meal dialog (`_LogMealDialog`) | `lib/features/nutrition/presentation/screens/nutrition_screen.dart:1451–1653` | `mixed` | Raw `AlertDialog` + 5 raw `TextFormField`s (better suited as a bottom sheet); `height: 40` Save button. |
| `INV-D11` | Swap Meal Alternatives dialog (`_SwapMealDialog`) | `lib/features/nutrition/presentation/screens/nutrition_screen.dart:508–824` | `mixed` | Jargon `'BUDGET-OPTIMIZED EQUI-MACRO ALTERNATIVES'`; hardcoded `#00E676`; ~22dp `'SWAP'` button; dense list cramped in dialog instead of bottom sheet. |
| `INV-D12` | Remove Suggested Diet Plan dialog (`_confirmRemovePlan`) | `lib/features/nutrition/presentation/widgets/suggested_diet_plan_card.dart:535–555` | `old` | Unstyled default `AlertDialog`; hardcoded `Colors.redAccent`. |
| `INV-D13` | Create Custom Food dialog (`_CreateCustomFoodDialog`) | `lib/features/nutrition/presentation/screens/food_search_screen.dart:1898–2190` | `mixed` | 7-field form cramped inside `Dialog` instead of full page/sheet; jargon `'NEW FUEL ENTRY'`, `'SAVE FUEL'`; hardcoded `#00E676` & `Colors.redAccent`; `20×20dp` close button. |
| `INV-D14` | Log Body Weight dialog (`_showLogWeightDialog`) | `lib/features/body/presentation/screens/progress_screen.dart:481–580` | `mixed` | Raw `AlertDialog` + 2 raw `TextFormField`s; hardcoded `'Weight (kg)'`; light-mode `Colors.black` on `#0A7C42` button contrast fail. |
| `INV-D15` | Log Body Measurements dialog (`_showLogMeasurementsForm`) | `lib/features/body/presentation/screens/progress_screen.dart:648–747` | `mixed` | 5-field form cramped in `AlertDialog` instead of sheet; raw `TextFormField`s; hardcoded `'cm'`; light-mode CTA contrast fail. |
| `INV-D16` | Clear AI Chat History dialog (`_showClearChatDialog`) | `lib/features/ai/presentation/screens/ai_chat_screen.dart:211–267` | `mixed` | Raw `AlertDialog`, hardcoded `Colors.redAccent` & `Colors.white` `FilledButton`. |
| `INV-D17` | Sync Status dialog (`_showSyncDialog`) | `lib/features/sync/presentation/widgets/sync_indicator.dart:190–235` | `old` | Unstyled `AlertDialog`, hardcoded `Colors.red`. |
| `INV-D18` | Profile Log Out confirmation (`_showLogoutDialog`) | `lib/features/profile/presentation/screens/profile_screen.dart:1074–1128` | `mixed` | Raw `AlertDialog`; uses primary green `AppButton` instead of destructive button; duplicated in `SettingsScreen`. |
| `INV-D19` | Profile Log Out progress spinner | `lib/features/profile/presentation/screens/profile_screen.dart:1137–1166` | `mixed` | Jargon `'Terminating session...'`; raw `AlertDialog`. |
| `INV-D20` | Settings Log Out confirmation (`_showLogoutDialog`) | `lib/features/settings/presentation/screens/settings_screen.dart:33–93` | `mixed` | Duplicate of `INV-D18`; non-destructive green button. |
| `INV-D21` | Settings Log Out progress spinner | `lib/features/settings/presentation/screens/settings_screen.dart:95–125` | `mixed` | Duplicate of `INV-D19`; jargon `'Terminating session...'`. |
| `INV-D22` | Legal Document dialog (`Terms of Service` / `Privacy Policy`) | `lib/features/settings/presentation/screens/settings_screen.dart:178–224` | `mixed` | Long legal copy inside cramped `AlertDialog` instead of full page/sheet; contradicts `PrivacySettingsScreen` policy copy. |
| `INV-D23` | Debug Reset Onboarding dialog (`_resetOnboarding`) | `lib/features/settings/presentation/screens/settings_screen.dart:228–275` | `mixed` | Jargon `'RESET ONBOARDING PROTOCOL'`; raw `AlertDialog` + `ElevatedButton`. |
| `INV-D24` | State Inspector dialog (`_showStateInspector`) | `lib/features/settings/presentation/screens/settings_screen.dart:298–365` | `mixed` | Reachable in release builds via `onLongPress` on About card (`L931`); raw `AlertDialog`. |
| `INV-D25` | Overwrite All Data confirmation | `lib/features/settings/presentation/screens/export_settings_screen.dart:752–774` | `mixed` | Raw `AlertDialog` + `TextButton`s. |
| `INV-D26` | Undo Last Restore confirmation (`_confirmAndUndoRestore`) | `lib/features/settings/presentation/screens/export_settings_screen.dart:836–875` | `mixed` | Jargon `'REVERT RESTORE OPERATION'`, `'CONFIRM ROLLBACK'`; raw `AlertDialog`. |
| `INV-D27` | Export / Restore Error dialog (`_showError`) | `lib/features/settings/presentation/screens/export_settings_screen.dart:905–930` | `mixed` | Jargon `'TELEMETRY FAULT'`, `'ACKNOWLEDGE'`; exposes raw `$e` string. |
| `INV-D28` | Account Deletion Re-authentication dialog | `lib/features/settings/presentation/screens/privacy_settings_screen.dart:218–325` | `mixed` | Jargon `'SECURITY RE-AUTHENTICATION'`, `'CONFIRM & DESTROY'`; raw `AlertDialog` + raw `TextField`. |
| `INV-D29` | Type-`DELETE` Confirmation dialog (`Purge` & `Delete Account`) | `lib/features/settings/presentation/screens/privacy_settings_screen.dart:342–503` | `mixed` | Jargon `'ERADICATE LOCAL TELEMETRY'`, `'TERMINATION OF ACCOUNT AND TELEMETRY'`; raw `AlertDialog` + raw `TextField`. |
| `INV-D30` | Privacy Error dialog (`_showErrorDialog`) | `lib/features/settings/presentation/screens/privacy_settings_screen.dart:694–722` | `mixed` | Jargon `'ACKNOWLEDGE'`; raw `AlertDialog`. |

---

### 2.4 All Bottom Sheets (`INV-B01`–`INV-B16`)

| ID | Bottom Sheet Surface | File & Lines | Status | Main Problems |
| --- | --- | --- | --- | --- |
| `INV-B01` | `AppBottomSheet` shared template | `lib/shared/presentation/components/app_bottom_sheet.dart:28–117` | `mixed` | Drops `action` when `title != null`; no wide-web `maxWidth`; no automatic keyboard inset scroll wrapper. |
| `INV-B02` | `OneRepMaxSheet` | `lib/features/tools/presentation/widgets/calculator_sheets.dart:25–238` | `mixed` | Raw `TextField`s; hardcodes `'KG'` ignoring `unitsProvider`. |
| `INV-B03` | `CalorieMacroSheet` | `lib/features/tools/presentation/widgets/calculator_sheets.dart:248–565` | `mixed` | Raw `TextField`s; hardcodes `'KG'`/`'CM'`; 5th macro color scheme; ~32dp goal pills. |
| `INV-B04` | `BodyFatSheet` | `lib/features/tools/presentation/widgets/calculator_sheets.dart:575–749` | `mixed` | Raw `TextField`s; hardcodes `'CM'`. |
| `INV-B05` | `WeightGoalSheet` | `lib/features/tools/presentation/widgets/calculator_sheets.dart:759–913` | `mixed` | Raw `TextField`s; hardcodes `'KG'`. |
| `INV-B06` | `WaterIntakeSheet` | `lib/features/tools/presentation/widgets/calculator_sheets.dart:923–1060` | `mixed` | Raw `TextField`s; hardcodes `'KG'`/`'L'`. |
| `INV-B07` | `PlateCalculatorSheet` | `lib/features/workout/presentation/widgets/plate_calculator_sheet.dart:33–792` | `mixed` | Bypasses `AppBottomSheet`; jargon `'TARGET LOAD'`, `'SLEEVE CONFIGURATION'`; sub-48dp unit/step/bar chips (`26–32dp`). |
| `INV-B08` | Home User Hub sheet (`_openUserHub`) | `lib/features/workout/presentation/screens/home_screen.dart:242–356` | `mixed` | Bypasses `AppBottomSheet`; missing drag handle; jargon `'PROFILE & BIOMETRICS'`; raw `ListTile`s. |
| `INV-B09` | Active Workout `ExerciseSelectionSheet` | `lib/features/workout/presentation/screens/active_workout_screen.dart:1315–1497` | `mixed` | Bypasses `AppBottomSheet`; hardcoded 45-name list instead of `ExerciseDatabase`; raw `TextField`. |
| `INV-B10` | Split Generator `ExerciseSwapSheet` | `lib/features/workout/presentation/widgets/split_generator/exercise_swap_sheet.dart:28–174` | `mixed` | Bypasses `AppBottomSheet`; raw `ListTile`s; caps alternatives at 3 items with no search. |
| `INV-B11` | Add-Food Quantity & Detail Sheet (`_FoodDetailAndQuantitySheet`) | `lib/features/nutrition/presentation/screens/food_search_screen.dart:807–1538` | `mixed` | Heavy jargon (`'VERIFIED NUTRITION TELEMETRY'`, `'SCALED PROTOCOL MACROS'`, `'EXACT MICRONUTRIENT TELEMETRY'`); hardcoded `#00E676`, `#FFD54F`, `Colors.white10` dividers; sub-48dp serving multiplier chips (~30dp) & `'SWITCH TO THIS FOOD'` (~24dp). |
| `INV-B12` | Progress Before/After Photo Comparison Sheet (`_showComparisonSheet`) | `lib/features/body/presentation/screens/progress_screen.dart:879–936` | `mixed` | Bypasses `AppBottomSheet`; sub-48dp `DropdownButton`s (~36dp); unguarded `Image.file` on web. |
| `INV-B13` | AI Coach Voice Settings Sheet (`_TTSSettingsSheet`) | `lib/features/ai/presentation/screens/ai_chat_screen.dart:1321–1883` | `old` | Raw `showModalBottomSheet`, no drag handle, 12+ `.withOpacity()` calls, emoji headers, raw `DropdownButton` & `SwitchListTile`, ~28dp `_SpeedChip`s. |
| `INV-B14` | Post-Workout `QuickFeedbackBottomSheet` | `lib/features/ai/presentation/widgets/quick_feedback_bottom_sheet.dart:53–285` | `old` | Hardcoded `Colors.grey`/`amber`/`green`/`purple`, `.withOpacity()`, unimplemented TODO CTA. |
| `INV-B15` | Backup Restore JSON Sheet (`_showRestoreModal`) | `lib/features/settings/presentation/screens/export_settings_screen.dart:423–797` | `mixed` | Bypasses `AppBottomSheet`; jargon `'SYSTEM RESTORATION PROTOCOL'`; raw `TextField`; sub-48dp `OutlinedButton.icon`s. |
| `INV-B16` | Privacy Policy Sheet (`_showPrivacyPolicyModal`) | `lib/features/settings/presentation/screens/privacy_settings_screen.dart:511–655` | `mixed` | Bypasses `AppBottomSheet`; jargon `'PRIVACY POLICY & TELEMETRY CHARTER'`; raw `OutlinedButton` & `ElevatedButton`. |

---

### 2.5 Snackbars, Popup Menus, Dropdowns, Date & Time Pickers (`INV-K01`–`INV-P02`)

| ID | Surface Group | File & Lines | Status | Main Problems |
| --- | --- | --- | --- | --- |
| `INV-K01` | `ErrorHandler.showSnackBar` (5 callers in `nutrition_screen.dart` & `program_editor_screen.dart`) | `lib/core/utils/error_handler.dart:35–39` | `old` | Unstyled fixed M3 `SnackBar`; jargon `'Parameters updated successfully'` at `program_editor_screen.dart:513`. |
| `INV-K02` | Neon-green / amber SnackBars with unreadable white text (12 sites) | `active_workout_screen.dart:412`; `nutrition_screen.dart:181`; `food_search_screen.dart:63`; `settings_screen.dart:143, 282`; `profile_screen.dart:1185`; `export_settings_screen.dart:471, 530, 822, 886`; `privacy_settings_screen.dart:115, 625` | `old` / `mixed` | Sets `#00FF87`, `#00E676`, or `#FFB800` background without dark text (~`1.3:1` white-on-neon contrast failure). |
| `INV-K03` | Light-mode `Colors.black` on `#0A7C42` SnackBar | `lib/features/body/presentation/screens/progress_screen.dart:618–624` | `mixed` | Passes dark mode, fails light mode (`3.97:1` < 4.5:1 WCAG AA). |
| `INV-K04` | Invisible `tokens.panel` background SnackBar | `lib/features/notifications/presentation/screens/reminder_settings_screen.dart:96–104` | `mixed` | `backgroundColor: tokens.panel` with M3 inverse text produces dark-on-dark / light-on-light illegible text. |
| `INV-K05` | Undo & status SnackBars across Onboarding, Split Generator, Summary, Fuel, Reminders & Video (18 sites) | `onboarding_screen.dart:1974`; `program_selection_screen.dart:140, 234, 244`; `active_workout_screen.dart:436, 1246`; `workout_summary_screen.dart:814, 836, 850`; `nutrition_screen.dart:125, 151, 772, 1758`; `food_search_screen.dart:1991`; `suggested_diet_plan_card.dart:467, 512, 522`; `youtube_exercise_player.dart:384` | `mixed` | Random mix of `fixed` vs `floating`, `Colors.amberAccent` vs `tokens.kineticAccent` Undo buttons, and raw `const SnackBar`s. |
| `INV-M01` | `ExerciseEditCard` popup menu (`Replace`, `Edit`, `Delete`) | `lib/features/workout/presentation/widgets/exercise_edit_card.dart:133–185` | `new` | Clean 48dp target, `tokens.elevated` & rounded border. |
| `INV-M02` | `SwipeableMealCards` popup menu (`Swap Meal`) | `lib/shared/widgets/swipeable_meal_cards.dart:151–179` | `mixed` | Missing rounded border shape; `iconSize: 18`. |
| `INV-M03` | `SuggestedDietPlanCard` popup menu (`Regenerate`, `Remove`) | `lib/features/nutrition/presentation/widgets/suggested_diet_plan_card.dart:188–224` | `mixed` | Hardcoded `Colors.redAccent`, missing border shape & typography tokens. |
| `INV-DD01` | Custom food category `DropdownButtonFormField` | `lib/features/nutrition/presentation/screens/food_search_screen.dart:2059–2082` | `mixed` | Inline input border styling instead of shared dropdown component. |
| `INV-DD02` | Strength Progress exercise `DropdownButton` | `lib/features/body/presentation/widgets/lifts_volume_tab.dart:262–296` | `mixed` | Visual height ~36dp (<48dp touch target). |
| `INV-DD03` | Photo Comparison Before/After date `DropdownButton`s | `lib/features/body/presentation/widgets/progress_photo_comparison.dart:192–245` | `mixed` | Visual height ~36dp (<48dp touch target). |
| `INV-DD04` | AI Coach TTS language `DropdownButton` | `lib/features/ai/presentation/screens/ai_chat_screen.dart:1573–1621` | `old` | Legacy `colorScheme.surface` + `.withOpacity(0.2)`. |
| `INV-P01` | Reminder `showTimePicker` | `lib/features/notifications/presentation/screens/reminder_settings_screen.dart:451–466` | `mixed` | Overrides `colorScheme.primary: tokens.kineticAccent` without `onPrimary`, rendering white text on `#00FF87` neon green. |
| `INV-P02` | Date Picker (`showDatePicker` / `DatePickerThemeData`) | `lib/core/constants/app_theme.dart` | `old` | Unconfigured in `AppTheme` (`0` usages in `lib/`). |

---

### 2.6 Forms/Inputs, Chips, Tabs, Navigation, App Bars & Lists (`INV-IN01`–`INV-LT05`)

| ID | Surface Group | File & Lines | Status | Main Problems |
| --- | --- | --- | --- | --- |
| `INV-IN01` | Auth & Onboarding `TextFormField`s (9 fields) | `login_screen.dart:293, 355`; `signup_screen.dart:302, 360, 418, 492`; `onboarding_screen.dart:804, 838, 875` | `mixed` | Hand-rolled `OutlineInputBorder`s duplicating `AppTextField`; hardcoded metric labels in places. |
| `INV-IN02` | Workout & Catalog `TextField`s (11 fields) | `active_workout_screen.dart:542, 862, 1148, 1184, 1215, 1369`; `exercise_catalog_screen.dart:100`; `exercise_picker_screen.dart:42`; `program_editor_screen.dart:406, 441, 471` | `mixed` | Mix of inline borderless set inputs, custom search bars, and raw dialog `TextField`s. |
| `INV-IN03` | Nutrition & Food Search `TextField` / `TextFormField`s (14 fields) | `nutrition_screen.dart:1553–1609`; `food_search_screen.dart:211, 1136, 2047–2156` | `mixed` | Raw form inputs with custom borders and hardcoded `#00E676` focus accents. |
| `INV-IN04` | Progress, Calculators, AI & Settings inputs (23 fields) | `progress_screen.dart:510, 535, 673–707`; `calculator_sheets.dart` (12); `plate_calculator_sheet.dart:351`; `ai_chat_screen.dart:618`; `export_settings_screen.dart:616`; `privacy_settings_screen.dart:260, 450` | `mixed` | Bypass `AppTextField`; calculator & progress inputs hardcode `'kg'`/`'cm'`. |
| `INV-IN05` | Legacy unused input wrappers (`WeightInputField`, `HintedInputField`) | `lib/features/workout/presentation/widgets/weight_input_field.dart:14–133`; `lib/core/widgets/helpful_tooltip.dart:40–86` | `old` | Dead code with hardcoded `Colors.red` and `0–500kg`. |
| `INV-CH01` | Sub-48dp custom filter/action chips (9 surfaces) | `exercise_catalog_screen.dart:282` (`24dp`); `exercise_picker_screen.dart:74` (raw `FilterChip`); `active_workout_screen.dart:1044` (`24dp`) & `1096` (`16dp`); `program_editor_screen.dart:187` (`32dp`); `food_search_screen.dart:410` (`38dp`), `479` (`34dp`), `1189` (`30dp`); `ai_chat_screen.dart:415, 471, 1677` (`26–28dp`); `plate_calculator_sheet.dart:421` (`26dp`) | `mixed` / `old` | All below `48dp` minimum touch target and missing `Semantics(selected:)`. |
| `INV-TB01` | `ProgressScreen` 3-tab `TabBar` | `lib/features/body/presentation/screens/progress_screen.dart:118–158` | `new` | Clean 48dp `TabBar`, but styling is local rather than `TabBarThemeData`. |
| `INV-TB02` | Sub-48dp custom segmented controls (8 surfaces) | `onboarding_screen.dart:758` (`28dp`); `active_workout_screen.dart:178` (`28dp`); `program_selection_screen.dart:319` (`36dp`) & `479` (`28dp`); `hybrid_mode_selector.dart:24` (`40dp`); `suggested_diet_plan_card.dart:235` (`28dp`); `calculator_sheets.dart:356` (`32dp`); `plate_calculator_sheet.dart:729` (`26dp`) | `mixed` | All below `48dp` minimum touch target and missing `Semantics`. |
| `INV-AB01` | App Bars across all 28 screens | `workout_screen.dart:70`, `home_screen.dart:175`, `workout_summary_screen.dart`, `ai_chat_screen.dart:54`, `reminder_settings_screen.dart:19`, `workout_history_screen.dart:81`, `exercise_detail_screen.dart:36` | `mixed` | 4 inconsistent header patterns (2-line ALL-CAPS, custom `HomeScreen` row, Title-Case `AIChatScreen`, legacy 1-line `AppBar`, and missing `AppBar` on `WorkoutSummaryScreen`); 5 cramped icons on `WorkoutScreen`; missing back button on `ReminderSettingsScreen`. |
| `INV-LT01` | Raw `ListTile`, `SwitchListTile`, custom `InkWell` rows & `Dismissible` meal cards | `profile_screen.dart:1261` (`dense: true` ~40dp); `privacy_settings_screen.dart:822` (deprecated `activeColor`); `swipeable_meal_cards.dart:44` (no Undo on swipe-delete); `workout_history_screen.dart:170` (`BackdropFilter` per row) | `mixed` / `old` | `AppListTile` unused in production; inconsistent heights, borders, and feedback. |

---

### 2.7 Charts, Loading Skeletons, Empty & Error States (`INV-CT01`–`INV-ER04`)

| ID | Surface / Widget | File & Lines | Status | Main Problems |
| --- | --- | --- | --- | --- |
| `INV-CT01` | `MacroWheelChart` | `lib/shared/widgets/macro_wheel_chart.dart:11–271` | `mixed` | Canonical macro colors, but hardcodes `Colors.black` slice percentage labels (`L128, 136, 144`). |
| `INV-CT02` | `WeightTrendGraph` | `lib/shared/widgets/weight_trend_graph.dart:15–475` | `new` | Clean 7-day average + goal line, but lacks custom `LineTouchData` tooltip theme and unit conversion. |
| `INV-CT03` | `LiftsVolumeTab` charts (`LineChart`, `BarChart`, `PieChart`) | `lib/features/body/presentation/widgets/lifts_volume_tab.dart:329, 479, 625` | `mixed` | Tokenized inside `AppCard`, but lack touch tooltips and hardcode `'KG'` (`L97`). |
| `INV-CT04` | `ExerciseDetailScreen` charts (`Weight` & `Reps` `LineChart`s) | `lib/features/workout/presentation/screens/exercise_detail_screen.dart:203–296` | `old` | Legacy `AppTheme.primaryColor`/`accentColor`, bare charts outside cards, no touch tooltips, hardcoded `'kg'`. |
| `INV-CT05` | `_AudioWavePainter` | `lib/features/ai/presentation/screens/ai_chat_screen.dart:1270–1317` | `old` | `onEnd` callback is an empty comment, so the audio waveform freezes after 1 second. |
| `INV-CT06` | Dead legacy chart & timer widgets | `lib/features/analytics/presentation/widgets/*`; `lib/shared/animations/rest_timer_circular.dart` | `old` | Unreferenced dark-only `AppTheme.*` / `Colors.green` widgets. |
| `INV-LD01` | Bare `CircularProgressIndicator` on 11 async screens | `home_screen.dart:118`, `workout_screen.dart:132`, `workout_history_screen.dart:97`, `exercise_detail_screen.dart:42`, `nutrition_screen.dart:222`, `nutrition_history_screen.dart:118`, `progress_screen.dart:178`, `lifts_volume_tab.dart:28`, `profile_screen.dart:85`, `privacy_settings_screen.dart:736`, `reminder_settings_screen.dart:126` | `mixed` | Full-screen spinner flash instead of `AppShimmer` skeletons (`AppShimmer` has 0 production usages). |
| `INV-EM01` | 2 Dead Empty-State CTAs + 1 Missing CTA | `workout_history_screen.dart:111` (`onStartWorkout: () {}`); `swipeable_meal_cards.dart:29` (`onLogMeal: () {}`); `home_screen.dart:1617` (`_ProfileSetupPrompt` has no button) | `old` / `mixed` | Tapping `"Start First Workout"` or `"Log First Meal"` does nothing; `AppStateView.empty` has 0 production usages. |
| `INV-EM02` | Ad-hoc jargon empty states (8 screens) | `home_screen.dart:658`, `workout_screen.dart:166`, `active_workout_screen.dart:86`, `program_editor_screen.dart:58`, `nutrition_history_screen.dart:156`, `progress_screen.dart:280, 345`, `profile_screen.dart:102` | `mixed` | Jargon (`'NO ACTIVE PROTOCOL'`, `'NO ARCHIVED TELEMETRY'`, `'start calibration'`); inconsistent icons and buttons. |
| `INV-ER01` | Error states missing Retry buttons (4 screens) | `profile_screen.dart:87`, `exercise_detail_screen.dart:44`, `lifts_volume_tab.dart:31`, `home_screen.dart:121` | `old` / `mixed` | Dead-end error text with no Retry button; `AppStateView.error` has 0 production usages. |
| `INV-ER02` | Jargon & raw exception error states (6 screens) + `OfflineIndicator` | `workout_screen.dart:158`, `nutrition_screen.dart:246`, `nutrition_history_screen.dart:133`, `reminder_settings_screen.dart:138`, `export_settings_screen.dart:910`, `ai_no_key_state.dart:58`, `offline_indicator.dart:9` | `old` / `mixed` | Jargon (`'TELEMETRY ERROR'`, `'TELEMETRY OFFLINE'`, `'LOG ARCHIVE UNREACHABLE'`); `OfflineIndicator` lacks `SafeArea` and is unused. |

---

### 2.8 Notifications, Web Host Page, App Icons, Launch Screens & System Bars (`INV-NT01`–`INV-PL07`)

| ID | Platform / Branding Surface | File & Lines | Status | Main Problems |
| --- | --- | --- | --- | --- |
| `INV-NT01` | Android notification small status-bar icon | `lib/features/notifications/domain/services/notification_service.dart:59, 218, 284, 312, 340, 402, 461, 542` | `old` | Uses opaque `@mipmap/ic_launcher` (`#0A0A0A` square) instead of a white-on-transparent monochrome drawable — renders a blank white/grey square in Android's status bar. |
| `INV-NT02` | 5 Notification channels & copy (`workout_reminders`, `meal_reminders`, `streak_reminders`, `rest_timer`, `general`) | `lib/features/notifications/domain/services/notification_service.dart:207–545`; `reminder_settings_screen.dart:87–93` | `mixed` | Channel 1–4 texts are friendly English, **but** Channel 5 test notification uses sci-fi jargon `'⚡ TELEMETRY PING'` / `'IronFlow notification pipeline active.'`. |
| `INV-NT03` | Legacy retention notification use cases | `lib/features/retention/domain/usecases/schedule_{meal,workout}_reminder_use_case.dart` | `old` | References non-existent Android drawable `icon: 'app_icon'`. |
| `INV-PL01` | Web host page (`web/index.html`) | `web/index.html:1–46` | `mixed` | Title is `'IronFlow - Fitness Tracking'`, **but** `description` is still `'A new Flutter project.'` (`L21`), `apple-mobile-web-app-title` is `'progression_tracker'` (`L30`), `<meta name="theme-color">` is missing, and `<body>` has no dark CSS background/loader (pure white flash before Flutter boots). |
| `INV-PL02` | Web PWA manifest (`web/manifest.json`) | `web/manifest.json:1–36` | `old` | `"name": "progression_tracker"`, `"theme_color": "#0175C2"`, `"background_color": "#0175C2"` (default Flutter blue). |
| `INV-PL03` | Web favicon & PWA icons | `web/favicon.png`; `web/icons/Icon-{192,512,maskable-192,maskable-512}.png` | `old` | All 5 files are default blue Flutter `"F"` logos. |
| `INV-PL04` | Android launcher icons & native launch screen | `android/app/src/main/res/mipmap-*/ic_launcher.png`; `res/drawable*/launch_background.xml`; `res/values*/styles.xml` | `mixed` | Legacy raster PNGs have baked-in black corners; missing Android 8.0+ Adaptive Icon (`mipmap-anydpi-v26`) and Android 12+ SplashScreen API (`values-v31`). |
| `INV-PL05` | iOS app icons & launch storyboard | `ios/Runner/Assets.xcassets/AppIcon.appiconset/*`; `ios/Runner/Base.lproj/LaunchScreen.storyboard` | `old` | All iOS icons are default blue Flutter `"F"` logos; `LaunchScreen.storyboard` is pure white (`#FFFFFF` flash on launch). |
| `INV-PL06` | System status bar & Android system navigation bar (`SystemUiOverlayStyle`) | `lib/core/constants/app_theme.dart:95–108` (`0` occurrences across `lib/`) | `old` | Neither `AppBarTheme.systemOverlayStyle`, `SystemChrome.setSystemUIOverlayStyle`, nor `AnnotatedRegion<SystemUiOverlayStyle>` is configured anywhere in `lib/`. |

---

## 3. "Before" Screenshots & Target Reachability Manifest (Part 1.2)

All `"before"` screenshots are stored in `docs/screenshots/before/`:

### 3.1 Live Chrome Captures (`build/web` on Google Chrome 156.0.8078.74)
- `docs/screenshots/before/chrome_live_login_390x844.png` — Live compiled web app at `/#/login` (`390×844` phone viewport).
- `docs/screenshots/before/chrome_live_login_1280x800.png` — Live compiled web app at `/#/login` (`1280×800` wide desktop viewport, showing full-width stretched inputs).
- `docs/screenshots/before/chrome_live_signup_390x844.png` — Live compiled web app at `/#/signup` (`390×844` phone viewport).
- `docs/screenshots/before/chrome_live_signup_1280x800.png` — Live compiled web app at `/#/signup` (`1280×800` wide desktop viewport).

### 3.2 Real Flutter Engine Screen Captures (Bundled `Inter` & `SpaceGrotesk` Fonts + Fake In-Memory Providers)
Captured directly from the unaltered `lib/` widgets at commit `07b90ef` using fake in-memory Riverpod providers (zero real storage, Firebase, or AI calls):
- `before_splash_390x844.png` (`SplashScreen`)
- `before_login_390x844.png` & `before_login_1280x800.png` (`LoginScreen`)
- `before_signup_390x844.png` (`SignupScreen`)
- `before_onboarding_step1_390x844.png` (`OnboardingScreen` Step 1)
- `before_home_dark_390x844.png`, `before_home_light_390x844.png`, & `before_home_wide_1280x800.png` (`MainScaffold` + `HomeScreen` Dark, Light & Wide Web)
- `before_workout_390x844.png` (`WorkoutScreen`)
- `before_active_workout_390x844.png` (`ActiveWorkoutScreen`)
- `before_workout_summary_390x844.png` (`WorkoutSummaryScreen`)
- `before_workout_history_390x844.png` (`WorkoutHistoryScreen`)
- `before_program_selection_390x844.png` (`ProgramSelectionScreen`)
- `before_program_editor_390x844.png` (`ProgramEditorScreen`)
- `before_exercise_catalog_390x844.png` & `before_exercise_catalog_wide_1280x800.png` (`ExerciseCatalogScreen` Phone & Wide Web 2-column stretch)
- `before_exercise_detail_390x844.png` (`ExerciseDetailScreen`)
- `before_nutrition_390x844.png` (`NutritionScreen`)
- `before_food_search_390x844.png` (`FoodSearchScreen`)
- `before_nutrition_history_390x844.png` (`NutritionHistoryScreen`)
- `before_progress_lifts_390x844.png` & `before_progress_weight_390x844.png` (`ProgressScreen` Lifts & Body Weight tabs)
- `before_tools_hub_390x844.png` (`ToolsHubScreen`)
- `before_ai_chat_390x844.png` (`AIChatScreen`)
- `before_profile_390x844.png` (`ProfileScreen`)
- `before_settings_390x844.png` (`SettingsScreen`)
- `before_reminder_settings_390x844.png` (`ReminderSettingsScreen`)
- `before_export_settings_390x844.png` (`ExportSettingsScreen`)
- `before_privacy_settings_390x844.png` (`PrivacySettingsScreen`)
- `before_design_gallery_dark_390x844.png` & `before_design_gallery_light_390x844.png` (`DesignGalleryScreen` Dark & Light, showing light-mode primary `AppButton` contrast defect)

### 3.3 Surfaces & Targets Not Reached Live (`NOT VERIFIED` on Live Hardware/External Services)
Per project proof rules, the following items could not be captured on live hardware or external network services during the read-only baseline audit and are marked **`NOT VERIFIED` on live target**:
1. **Android Emulator (`Medium_Phone_API_36.1`) live runtime screenshots**: Emulator AVD is installed offline (not currently booted), and authenticated screens in a live `flutter run` build require live Firebase Authentication credentials (forbidden by fake-data/no-real-Firebase rules).
2. **iOS Simulator / macOS / Physical iPhone**: Host machine runs Windows; iOS native launch storyboard and status bar behavior are verified by source inspection only (`NOT VERIFIED` at runtime).
3. **Android OS Notification Shade & Status-Bar Small Icon Rendering**: Requires live Android OS notification dispatch (`NOT VERIFIED` on device; monochrome icon defect proven via `@mipmap/ic_launcher` asset inspection).
4. **Live Google / Apple OAuth Consent Popups & Live YouTube Embedded Video Stream**: External third-party network frames (`youtube_player_iframe` / Firebase OAuth) are not invoked in isolated offline audits.
5. **Flutter Web Progress Photo Grid with Local File Entries**: Crashes on Web due to unguarded `dart:io` `Image.file(File(...))` in `progress_screen.dart:1061`.
