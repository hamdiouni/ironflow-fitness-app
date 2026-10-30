# IronFlow UI/UX Upgrade Suggestions (Part 1.4)

This document presents **22 concrete UI/UX improvements** ranked by **Impact**, **Effort**, and **Risk**, backed by file-level and screenshot evidence from `docs/DESIGN_INVENTORY.md` and `docs/screenshots/before/`. All recommendations strictly follow the **UI-only** constraint (preserving business logic, data, storage, route contracts, and providers unless explicitly approved).

---

## Summary Ranking Table

| Rank | Area | Suggestion | Impact | Effort | Risk | Primary Evidence |
| ---: | --- | --- | :---: | :---: | :---: | --- |
| 1 | **Colors & Contrast** | Unify palette tokens, add `onAccent` / semantic foreground pairs, and fix WCAG AA failures in Light & Dark mode | High | S | Low | `app_colors.dart:1–87`, `app_button.dart:126`, `before_design_gallery_light_390x844.png` |
| 2 | **Buttons** | Standardize 5 button levels (`Primary`, `Secondary`, `Tertiary`, `Destructive`, `Icon`), 3 sizes, and all interactive states; retire raw Material buttons | High | M | Low | `app_button.dart:1–248`, `ai_coach_hero_card.dart:202`, `program_selection_screen.dart:599` |
| 3 | **Frames & Surfaces** | Enforce frame-light rules: one surface level per section, no default `1px` card borders, no card-in-card nesting, and zero `BackdropFilter` blur in lists | High | M | Low | `app_card.dart:62`, `workout_history_screen.dart:189`, `food_search_screen.dart` (`28` borders) |
| 4 | **Windows (Dialogs & Sheets)** | Apply a strict Dialog vs. Bottom Sheet vs. Full-Page matrix, fix `AppBottomSheet` header bug, and migrate all 28 raw `AlertDialog`s & 9 raw sheets | High | L | Low | `app_bottom_sheet.dart:89`, `app_dialog.dart:54` (`0` prod uses), `nutrition_screen.dart:1451` |
| 5 | **Web & Wide-Screen Layout** | Add responsive `NavigationRail` (`>= 840dp`), `1120px` max content width, `480px` auth card container, and adaptive grid columns | High | M | Low | `main.dart:252`, `exercise_catalog_screen.dart:245`, `chrome_live_login_1280x800.png`, `before_exercise_catalog_wide_1280x800.png` |
| 6 | **Feedback & Snackbars** | Add `SnackBarThemeData` + shared status/Undo snackbar helper to eliminate 13 white-on-neon contrast failures and add Undo to meal swipe-delete | High | S | Low | `active_workout_screen.dart:412`, `nutrition_screen.dart:181`, `reminder_settings_screen.dart:96`, `swipeable_meal_cards.dart:44` |
| 7 | **Semantic & Macro Colors** | Consolidate the 5 contradictory macro color schemes and standardize `Success`, `Warning`, `Error`, and `Info` meanings across all screens | High | S | Low | `app_colors.dart:64`, `onboarding_screen.dart:1392`, `home_screen.dart:998`, `profile_screen.dart:857`, `calculator_sheets.dart:460` |
| 8 | **Copy & Simple English** | Replace all remaining sci-fi/telemetry jargon across 21+ screens with warm, direct coaching English per `docs/COPY_GUIDE.md` | High | M | Low | `splash_screen.dart:171`, `login_screen.dart:227`, `food_search_screen.dart:170`, `privacy_settings_screen.dart:356` |
| 9 | **Complete `ThemeData`** | Define every Material 3 sub-theme (`FilledButton`, `OutlinedButton`, `InputDecoration`, `Chip`, `TabBar`, `Switch`, `PopupMenu`, `DatePicker`, `TimePicker`, `Scrollbar`, focus/hover, `SystemUiOverlayStyle`) | High | M | Low | `app_theme.dart:64–245`, `reminder_settings_screen.dart:451` |
| 10 | **Accessibility & Touch Targets** | Enforce `48×48dp` minimum tap targets, keyboard focus rings, `Semantics`, and `1.5x` text-scale safety across 20+ chips, toggles, and icon buttons | High | M | Low | `active_workout_screen.dart:1044, 1096`, `exercise_catalog_screen.dart:282`, `food_search_screen.dart:2034` |
| 11 | **Forms & Inputs** | Upgrade `AppTextField` with validation/formatter/focus support and replace 57 raw `TextField`/`TextFormField`s with token-consistent inputs | High | M | Low | `app_text_field.dart:8–172` (`0` prod uses), `login_screen.dart:293`, `food_search_screen.dart:2047` |
| 12 | **Pages & Header Hierarchy** | Standardize page headers, spacing rhythm, and single-primary-CTA hierarchy; declutter `WorkoutScreen`'s 5-icon AppBar and add header to `WorkoutSummaryScreen` | Medium | M | Low | `workout_screen.dart:70–125`, `home_screen.dart:175`, `workout_summary_screen.dart:210`, `before_workout_390x844.png` |
| 13 | **Navigation Chrome** | Upgrade `MainScaffold` to M3 `NavigationBar` / `NavigationRail`, localize tab labels, and visually suppress bottom chrome during immersive active-workout/summary views | High | M | Medium | `main.dart:264–314`, `app_router.dart:211–340`, `before_active_workout_390x844.png` |
| 14 | **Empty, Error & Loading States** | Adopt `AppShimmer` skeletons and `AppStateView` across async screens; fix visible dead-end error states lacking Retry styling and empty states with unstyled copy | High | M | Low | `app_shimmer.dart:8` (`0` prod uses), `app_state_views.dart:19` (`0` prod uses), `workout_history_screen.dart:111`, `swipeable_meal_cards.dart:29` |
| 15 | **Charts & Data Visualization** | Create a unified `fl_chart` theme with interactive touch tooltips, AA-compliant slice/axis labels, card framing, and consistent unit labels | Medium | M | Low | `macro_wheel_chart.dart:128`, `lifts_volume_tab.dart:329`, `exercise_detail_screen.dart:203`, `before_exercise_detail_390x844.png` |
| 16 | **Typography Hierarchy** | Eliminate 808 inline `fontSize:` overrides, reserve ALL-CAPS for compact eyebrow/badge labels, and enforce tabular numerals on every live metric/timer | Medium | M | Low | `app_typography.dart:1–160`, `food_search_screen.dart`, `onboarding_screen.dart` |
| 17 | **Icons & Visual Language** | Standardize rounded 20/24dp Material icon sizing, replace emoji section headers in AI TTS & notifications, and unify `IronFlowLogo` across Splash/Login | Medium | S | Low | `ironflow_logo.dart:56`, `splash_screen.dart:118`, `ai_chat_screen.dart:1633` |
| 18 | **AI Coach Chat & Media UI** | Migrate `_AIResponseContent`, `_AudioControls`, `_TTSSettingsSheet`, and `YouTubeExercisePlayer` error/overlay controls to tokens and fix the frozen 1s `_AudioWavePainter` | Medium | M | Low | `ai_chat_screen.dart:1066–1883`, `youtube_exercise_player.dart:192–444`, `before_ai_chat_390x844.png` |
| 19 | **Motion & Haptics** | Standardize 3 motion tiers (`120ms` micro, `200ms` surface, `280ms` page), respect `MediaQuery.disableAnimations` everywhere, and align haptics to key physical actions | Medium | S | Low | `splash_screen.dart:42`, `pr_celebration_animation.dart:14`, `app_spacings.dart:32` |
| 20 | **Lists, Tiles & Pickers** | Adopt `AppListTile` across Settings/Profile/Sheets, fix `dense: true` 40dp rows and deprecated `SwitchListTile(activeColor:)`, and theme `TimePicker` / `DatePicker` | Medium | M | Low | `app_list_tile.dart:8` (`0` prod uses), `profile_screen.dart:1261`, `privacy_settings_screen.dart:837` |
| 21 | **Web Host Page, Favicon & PWA** | Upgrade `web/index.html` with dark/light CSS background, branded loader, `<meta name="theme-color">`, IronFlow `manifest.json`, and IronFlow favicon/PWA icons | Medium | S | Low | `web/index.html:1–46`, `web/manifest.json:1–36`, `web/favicon.png` |
| 22 | **Native Icons, Splash & System Bars** | Add Android adaptive & monochrome notification icons, replace default Flutter iOS app icons & white launch storyboard, and configure `SystemUiOverlayStyle` | Medium | S | Low | `notification_service.dart:59`, `ios/Runner/Base.lproj/LaunchScreen.storyboard`, `android/app/src/main/res/` |

---

## Detailed Recommendations & Design Specifications

### 1. Colors, Palette & WCAG AA Contrast (`Impact: High | Effort: S | Risk: Low`)
- **Evidence**:
  - `lib/core/theme/app_colors.dart:23, 47` still uses Electric Hyper-Lime `#00FF87` (`darkKineticAccent`) and `#0A7C42` (`lightKineticAccent`).
  - `lib/shared/presentation/components/app_button.dart:126–129` and `lib/features/ai/presentation/widgets/ai_coach_hero_card.dart:205` hardcode `Colors.black` text on `tokens.kineticAccent`, producing **`3.97:1` contrast in Light Mode** (`< 4.5:1` WCAG AA failure; visible in `docs/screenshots/before/before_design_gallery_light_390x844.png`).
  - `darkTextMuted` (`#525866`) used on `MainScaffold` unselected tabs (`lib/main.dart:279` on `#13151A` = **`2.55:1`**) and `AppTextField` helper text (`app_text_field.dart:164` on `#1A1D24` = **`2.23:1`**) fails WCAG AA `4.5:1`.
- **Recommendation**:
  - Add explicit paired foreground tokens in `AppThemeTokens`: `onAccent`, `onSuccess`, `onWarning`, `onError`, `onInfo`, plus subtle semantic container fills (`successSubtle`, `warningSubtle`, `errorSubtle`, `infoSubtle`).
  - Raise `textMuted` luminance in dark mode (e.g., `#8B95A5`, `>= 5.3:1` on dark surfaces) and deepen `textMuted` in light mode (e.g., `#526071`, `>= 5.8:1` on white).
  - Reserve semantic meanings strictly:
    - **Primary Accent**: Main page CTA, active tab/chip, selected focus ring.
    - **Success**: Completed sets, personal records, target met, saved confirmation.
    - **Warning**: Rest timer ending, unsaved edits, Streak at risk, offline cache notice.
    - **Error**: Validation failure, failed sync, destructive delete/discard actions.

### 2. Button Hierarchy, Sizes & States (`Impact: High | Effort: M | Risk: Low`)
- **Evidence**: `lib/` mixes **8 button widget classes** (`AppButton`, `ElevatedButton`, `FilledButton`, `OutlinedButton`, `TextButton`, `IconButton`, `FloatingActionButton`, and `71` custom `InkWell`/`GestureDetector` boxes) with `14+` incompatible heights (`16dp` to `56dp`) and radii (`4px` to `999px`).
- **Recommendation**: Standardize all actions through `AppButton` (and matching `ThemeData` button themes for third-party/Material widgets):
  - **5 Levels**:
    1. `Primary` (filled `accent` + `onAccent` — **at most one per viewport**).
    2. `Secondary` (tonal `elevated` surface fill + `textPrimary`, no noisy outline).
    3. `Tertiary` / `Ghost` (transparent background + `accent` or `textSecondary` text for low-emphasis actions like `"Skip"`, `"Cancel"`, `"View All"`).
    4. `Destructive` (`error` fill + `onError` for final confirmations; subtle `errorSubtle` + `error` text for inline triggers like `"Discard"` or `"Log Out"`).
    5. `Icon` (`AppIconButton` with guaranteed `48×48dp` hit area, tooltip, and focus/hover ring).
  - **3 Sizes**: `sm` (`36dp` visual pill centered inside a `48dp` touch target), `md` (`48dp` default), `lg` (`54dp` hero CTA). Eliminate ad-hoc `height: 36..46` overrides (`home_screen.dart:850, 1096, 1343`, `active_workout_screen.dart:578`).
  - **Complete States**: Normal, Hover (`+6%` state overlay on web), Focused (`2px` `accent` ring), Pressed (`scale 0.98` or `+12%` overlay), Loading (`18dp` stroke-2 spinner preserving button width so layout never jumps), and Disabled (`elevated` fill at `48%` opacity with non-interactive cursor).

### 3. Frame-Light Surface Architecture (`Impact: High | Effort: M | Risk: Low`)
- **Evidence**:
  - `AppCard` (`lib/shared/presentation/components/app_card.dart:62–65`) draws a `1px` `borderSubtle` border on every card and offers neon `isGlowing` shadows.
  - `FoodSearchScreen` has `30` `Container`s and `28` borders; `WorkoutSummaryScreen:400` nests bordered `PRCelebrationAnimation` inside `AppCard`; `WorkoutHistoryScreen:189` runs `BackdropFilter(sigma: 10)` on every list row.
- **Recommendation**:
  - **3 Clear Tonal Planes**: `canvas` (page background) → `card` (section container, **no default border**) → `elevated` (interactive control or modal/sheet floating above page).
  - **No Card-Inside-Card**: Group related rows inside one `card` separated by whitespace (`12–16dp`) or subtle `1px` hairline dividers—never nested bordered boxes.
  - **Borders Only for State**: Reserve `1.5px–2px` borders exclusively for **Selected** (`accent`), **Keyboard/Input Focus** (`accent`), and **Validation Error** (`error`).
  - **Zero Blur/Glow in Lists**: Delete `AppTheme.glassmorphicCard()` usage in `WorkoutHistoryScreen:189`, `ExerciseDetailScreen:324`, and `StreakDisplay` to eliminate GPU raster jank.

### 4. Window Architecture: Dialog vs. Bottom Sheet vs. Full Page (`Impact: High | Effort: L | Risk: Low`)
- **Evidence**: `AppDialog` has `0` production usages (`28` raw `AlertDialog`s exist), `AppBottomSheet` drops `action` whenever `title != null` (`app_bottom_sheet.dart:89–102`), 5–7 field forms (`_LogMealDialog` `nutrition_screen.dart:1451`, `_CreateCustomFoodDialog` `food_search_screen.dart:1898`, `_showLogMeasurementsForm` `progress_screen.dart:648`) and full legal documents (`settings_screen.dart:178`) are crammed inside narrow `AlertDialog`s, and Logout dialogs (`profile_screen.dart:1074`, `settings_screen.dart:33`) use primary green buttons instead of destructive styling.
- **Recommendation**: Enforce a single **Window Decision Matrix**:

| Pattern | When to Use | Max Width | Standard Footer / Actions | Examples in IronFlow |
| --- | --- | --- | --- | --- |
| **Dialog (`AppDialog`)** | Short 1-question confirmations or destructive guards (`<= 2` sentences, at most 1 confirmation field like `"DELETE"`). | `400px` | Right-aligned or 2-column equal row: `Secondary/Tertiary Cancel` (left) + `Primary` or `Destructive Confirm` (right). | Discard Workout, Log Out (`isDestructive: true`), Clear AI Chat, Remove Diet Plan, Replace Active Split, Type-`DELETE` Purge. |
| **Bottom Sheet (`AppBottomSheet`)** | Quick contextual pickers, 1–5 field quick-loggers, calculators, or detail previews that keep parent context. Centered modal sheet (`maxWidth: 560px`) on wide web. | `560px` (web) / `100%` (phone) | Drag handle (`36×4`), title + `48dp` close button, keyboard-safe scroll body, sticky bottom `Primary` CTA. | Add-Food Quantity Sheet, Log Weight, Log Body Measurements, Log Custom Meal, Swap Meal, Exercise Picker/Swap, Calculators, Voice Settings. |
| **Full Page** | Multi-section workflows, `6+` input fields, searchable catalogs, or long-form reading. | `1120px` shell | Top `AppBar` with Back button + single primary action. | Create Custom Food (or spacious full-height sheet), Legal/Privacy Policy reader, Program Editor, Backup & Restore. |

### 5. Web & Wide-Screen Responsive Layout (`Impact: High | Effort: M | Risk: Low`)
- **Evidence**: `chrome_live_login_1280x800.png`, `before_home_wide_1280x800.png`, and `before_exercise_catalog_wide_1280x800.png` show login fields stretching `1280px` wide, a phone `BottomNavigationBar` spanning the entire desktop monitor (`lib/main.dart:264`), and `ExerciseCatalogScreen:245` / `ProgressScreen:1016` rendering massive 2-column tiles.
- **Recommendation**:
  - **Breakpoints**: Compact (`< 600dp`: phone bottom nav, single column), Medium (`600–839dp`: compact `NavigationRail`, centered `720px` content), Expanded (`>= 840dp`: labeled `NavigationRail` / sidebar, `maxWidth: 1120px` centered workspace, 2-column dashboard/progress grid, `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 260)` for Exercise Catalog & Progress Photos).
  - Constrain Auth (`LoginScreen`, `SignupScreen`) and `OnboardingScreen` to a centered `460px` surface card on tablet/desktop web.

### 6. Feedback: Snackbars, Undo & Haptics (`Impact: High | Effort: S | Risk: Low`)
- **Evidence**: `13` SnackBars set `#00FF87`, `#00E676`, or `#FFB800` backgrounds with white M3 default text (~`1.3:1` contrast), `reminder_settings_screen.dart:96` sets `tokens.panel` with inverse dark text (illegible), and `SwipeableMealCards` (`swipeable_meal_cards.dart:44`) deletes meals immediately on swipe with no Undo.
- **Recommendation**:
  - Add a shared `AppSnackBar.show(context, {message, tone, actionLabel, onAction})` helper + `SnackBarThemeData` using floating elevated dark/high-contrast surface (`maxWidth: 520px` on web), semantic leading icon (`check_circle`, `warning_amber`, `error_outline`), and guaranteed `>= 7:1` text & `"Undo"` button contrast.
  - Provide a 5-second `"Undo"` action on meal swipe-delete and progression/split changes.

### 7. Unified Macro & Semantic Color Tokens (`Impact: High | Effort: S | Risk: Low`)
- **Evidence**: 5 screens define 5 incompatible color mappings for Protein, Carbs, and Fats (`DESIGN_INVENTORY.md §1.6`).
- **Recommendation**: Single-source `tokens.protein`, `tokens.carbs`, and `tokens.fats` (with light-mode and dark-mode contrast-checked variants) across `MacroWheelChart`, `NutritionScreen`, `HomeScreen:998`, `OnboardingScreen:1392`, `ProfileScreen:857`, and `CalorieMacroSheet:460`. Always pair color with letter/label (`P`, `C`, `F`) so color-blind users never rely on hue alone.

### 8. Simple English Copy Sweep (`Impact: High | Effort: M | Risk: Low`)
- **Evidence**: `21+` files violate `docs/COPY_GUIDE.md` (`'BIOMETRIC TELEMETRY & TRAINING SYSTEM'`, `'TERMINAL ACCESS'`, `'INITIALIZE IDENTITY'`, `'NO ACTIVE PROTOCOL'`, `'FUEL DATABASE // VERIFIED NUTRITION TELEMETRY'`, `'ERADICATE LOCAL TELEMETRY'`, `'CONFIRM & DESTROY'`, `'ACKNOWLEDGE'`).
- **Recommendation**: Replace every banned sci-fi/military term with clear, encouraging everyday English (`"Welcome back"`, `"Create account"`, `"No active workout plan"`, `"Food search"`, `"Nutrition facts"`, `"Clear local data"`, `"Delete account"`, `"OK"`). Gate debug-only controls (`'AUTOFILL DEMO ACCOUNT'` in `login_screen.dart:462` and long-press state inspector in `settings_screen.dart:931`) appropriately or ask if any test relies on them before hiding.

### 9. Complete `ThemeData` Component Sub-Themes (`Impact: High | Effort: M | Risk: Low`)
- **Evidence**: `lib/core/constants/app_theme.dart:64–245` leaves `FilledButton`, `OutlinedButton`, `Chip`, `TabBar`, `Switch`, `Slider`, `Checkbox`, `Radio`, `PopupMenu`, `DropdownMenu`, `DatePicker`, `TimePicker`, `Tooltip`, `Scrollbar`, `TextSelectionTheme`, and `AppBarTheme.systemOverlayStyle` unconfigured—causing raw widgets (e.g. `reminder_settings_screen.dart:451` `showTimePicker`) to render illegible colors or M3 default purple/stadium shapes.
- **Recommendation**: Populate all Material 3 component themes in `AppTheme.darkTheme` and `AppTheme.lightTheme` directly from `AppThemeTokens` so even unstyled Material widgets match the chosen design automatically.

### 10. Accessibility, 48dp Touch Targets & Web Focus Rings (`Impact: High | Effort: M | Risk: Low`)
- **Evidence**: `20+` interactive controls measure `16dp–40dp` (`active_workout_screen.dart:1096` RPE toggle `16dp`, `nutrition_screen.dart:781` `SWAP` `22dp`, `food_search_screen.dart:2034` close button `20×20dp`, `exercise_catalog_screen.dart:282` `_EquipChip` `24dp`, `profile_screen.dart:1261` `dense: true` tiles `40dp`).
- **Recommendation**: Pad every interactive target to `>= 48×48dp` via `ConstrainedBox(constraints: BoxConstraints(minWidth: 48, minHeight: 48))`, wrap custom chips/segments in `Semantics(button: true, selected: ...)`, add visible `2px` keyboard focus outlines (`Focus` / `InkWell(focusColor:)`), and test all core screens at `360dp` width and `1.5x` `TextScaler`.

### 11. Forms & Input Standardization (`Impact: High | Effort: M | Risk: Low`)
- **Evidence**: `AppTextField` (`app_text_field.dart:8–172`) is used in `0` production screens because it lacks `validator`, `inputFormatters`, `focusNode`, `textInputAction`, `autofillHints`, and `onFieldSubmitted`.
- **Recommendation**: Extend `AppTextField` to wrap `TextFormField` with full validation, prefix/suffix unit badges, clear button on search fields, and AA-compliant helper/error text; migrate all `57` raw `TextField`/`TextFormField`s (keeping compact tabular `AppSetNumberInput` variant for `ActiveWorkoutScreen` set rows).

### 12. Page Headers, Spacing Rhythm & Single Primary Action (`Impact: Medium | Effort: M | Risk: Low`)
- **Evidence**: `WorkoutScreen:70–125` crowds 5 icon buttons into `AppBar.actions`; `WorkoutSummaryScreen` has no `AppBar`; `HomeScreen:743, 760` duplicates `'REST DAY'` twice in one header; `ReminderSettingsScreen:19` shows no back button when entered via `SettingsScreen`.
- **Recommendation**: Standardize a clean `AppPageHeader` / `AppBar` with sentence-case or consistent title hierarchy, max 2 top-bar trailing actions (moving secondary links like Tools, Catalog, and History into structured quick-access tiles on `WorkoutScreen`), consistent `16dp` mobile / `24dp` wide-web horizontal page padding, `20–24dp` section gaps, and **one unmistakable primary CTA per screen**. *(Note: Fixing `SettingsScreen`'s `context.go` vs `context.push` back-stack behavior or adding a safe fallback back button will be confirmed under the UI-only rule before changing route calls).*

### 13. Navigation Chrome & Immersive Flows (`Impact: High | Effort: M | Risk: Medium`)
- **Evidence**: `MainScaffold` (`lib/main.dart:264–314`) uses legacy M2 `BottomNavigationBar` with hardcoded ALL-CAPS English strings and remains visible during `ActiveWorkoutScreen` (`before_active_workout_390x844.png`) and `WorkoutSummaryScreen` (`before_workout_summary_390x844.png`).
- **Recommendation**: Upgrade `MainScaffold` to M3 `NavigationBar` (phone) and `NavigationRail` (tablet/desktop web) using `AppLocalizations` labels, and hide the shell navigation bar on immersive sub-screens (`/workout/active`, `/workout/summary`) via UI chrome visibility in `MainScaffold` (without altering route paths or `GoRouter` redirect logic).

### 14. Unified Loading Skeletons, Empty & Error States (`Impact: High | Effort: M | Risk: Low`)
- **Evidence**: `AppShimmer` and `AppStateView` have `0` production usages; `11` screens flash bare centered `CircularProgressIndicator`s; `4` error views (`profile_screen.dart:87`, `exercise_detail_screen.dart:44`, `lifts_volume_tab.dart:31`, `home_screen.dart:121`) show no Retry button; `2` empty states (`workout_history_screen.dart:111`, `swipeable_meal_cards.dart:29`) render buttons wired to empty `{}` callbacks.
- **Recommendation**: Replace full-page spinners with layout-matched `AppShimmer` skeletons, migrate all empty/error/offline views to `AppStateView` with clear plain-English explanations, and ask before wiring or hiding the 2 no-op empty-state callbacks if navigation behavior is affected.

### 15. Charts & Data Visualization Theme (`Impact: Medium | Effort: M | Risk: Low`)
- **Evidence**: `ExerciseDetailScreen:203–296` renders bare unframed `LineChart`s using legacy `AppTheme.primaryColor`/`accentColor` with no touch tooltips (`before_exercise_detail_390x844.png`); `LiftsVolumeTab` charts lack custom tooltips; `MacroWheelChart:128` hardcodes `Colors.black` text on colored slices.
- **Recommendation**: Introduce `AppChartTheme` for `fl_chart`: subtle horizontal grid lines only (`borderSubtle` at `40%`), rounded bar tops, high-contrast interactive touch tooltips (`elevated` surface + tabular value + date), framed chart cards with time-range pills and clear legends, and contrast-verified slice labels.

### 16. Typography Scale & Tabular Numerals (`Impact: Medium | Effort: M | Risk: Low`)
- **Evidence**: `808` inline `fontSize:` declarations bypass `AppTypography`, mixing `9px`, `10px`, `11px`, `13px`, `15px`, and `17px` ad-hoc sizes and overusing tracked ALL-CAPS on multi-line titles and body subtitles.
- **Recommendation**: Map all text strictly to `AppTypography` tokens (`displayLarge`, `headlineMedium`, `titleLarge`, `titleMedium`, `bodyLarge`, `bodyMedium`, `labelMedium`, `labelSmall`, `tabularMetric`), enforce minimum `12px` readable label size, use sentence case for headings/buttons (or clean title case per chosen direction), and apply `FontFeature.tabularFigures()` to every weight, rep, calorie, macro, and rest-timer counter.

### 17. Iconography & Brand Mark Consistency (`Impact: Medium | Effort: S | Risk: Low`)
- **Evidence**: `SplashScreen:118` draws a custom bracket box (`_MonolithicLogoMark`), `LoginScreen` uses a generic icon badge, `IronFlowLogo` hardcodes `#00E676`, and `AIChatScreen:1633` / `ReminderSettingsScreen:89` use raw emoji glyphs as UI icons.
- **Recommendation**: Tokenize `IronFlowLogo` so it adapts cleanly to dark/light themes across Splash, Login, Onboarding, and Web About headers, and replace inline emoji headers with crisp `20dp`/`24dp` rounded Material icons.

### 18. AI Coach Chat Bubbles, TTS Sheet & Exercise Video Player (`Impact: Medium | Effort: M | Risk: Low`)
- **Evidence**: `AIChatScreen:1066–1883` has `18` deprecated `.withOpacity()` calls and a frozen `_AudioWavePainter` (`L1270`); `YouTubeExercisePlayer:192, 414` has `28×28dp` Mute/Copy buttons, `'INITIALIZING TELEMETRY STREAM...'` jargon (`L229`), and raw `#FF0000` / unstyled buttons on its `"DEMO VIDEO NOT AVAILABLE"` error card (`L240–362`).
- **Recommendation**: Rebuild `_AIResponseContent`, `_AudioControls`, and `_TTSSettingsSheet` onto `AppCard` / `AppBottomSheet` / `AppChip` tokens, loop `_AudioWavePainter` smoothly while playing (honoring `disableAnimations`), and redesign the Exercise Video frame & fallback error card with `48dp` overlay buttons and `AppButton` actions.

### 19. Motion & Haptics Discipline (`Impact: Medium | Effort: S | Risk: Low`)
- **Evidence**: `SplashScreen:42` and `PRCelebrationAnimation:14` run animations without checking `MediaQuery.disableAnimationsOf(context)`.
- **Recommendation**: Centralize 3 motion tokens (`fast: 120ms`, `normal: 200ms`, `slow: 280ms` with `Curves.easeOutCubic`), short-circuit all repeating/transition animations when `MediaQuery.disableAnimationsOf(context)` is true, and trigger `AppHaptics` consistently on set completion, PR unlock, timer finish, and destructive confirmations.

### 20. Lists, Tiles, Dropdowns & Time/Date Pickers (`Impact: Medium | Effort: M | Risk: Low`)
- **Evidence**: `AppListTile` has `0` production usages; `ProfileScreen:1261` uses `40dp` `dense: true` tiles; `PrivacySettingsScreen:837` uses deprecated `SwitchListTile(activeColor:)`; `LiftsVolumeTab:262` & `ProgressPhotoComparison:192` use `36dp` dropdowns.
- **Recommendation**: Migrate settings, profile, and picker rows to `AppListTile` (`minHeight: 56dp`) and `AppSwitchTile`, wrap dropdowns in `48dp` token containers, and style `TimePickerThemeData` / `DatePickerThemeData` with high-contrast `onAccent` selection numerals.

### 21. Web Landing / Host Page, Manifest & Favicon (`Impact: Medium | Effort: S | Risk: Low`)
- **Evidence**: `web/index.html` flashes white on boot, lacks `<meta name="theme-color">`, sets `description="A new Flutter project."`, and `web/manifest.json` + `web/favicon.png` + `web/icons/*` still ship default `#0175C2` Flutter `"F"` branding.
- **Recommendation**: Style `web/index.html` with the chosen theme's dark/light `prefers-color-scheme` canvas background, a lightweight CSS IronFlow boot mark (zero external scripts), `<meta name="theme-color">`, accurate IronFlow description/titles, updated `web/manifest.json`, and rendered IronFlow PNG icons (`favicon.png`, `Icon-192`, `Icon-512`, maskable icons).

### 22. Native Launch Screens, App Icons & System Bars (`Impact: Medium | Effort: S | Risk: Low`)
- **Evidence**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/*` uses default Flutter `"F"` icons; `ios/Runner/Base.lproj/LaunchScreen.storyboard` flashes pure white; `NotificationService:59` uses opaque `@mipmap/ic_launcher` (rendering a blank square in the Android status bar); `0` occurrences of `SystemUiOverlayStyle` exist in `lib/`.
- **Recommendation**: Add a white-on-transparent monochrome `@drawable/ic_stat_ironflow` notification icon for Android, add Android 8+ adaptive launcher icon XML + Android 12+ splash style, update iOS `AppIcon.appiconset` and dark-matched `LaunchScreen.storyboard`, and wire `AppBarTheme.systemOverlayStyle` + root `AnnotatedRegion<SystemUiOverlayStyle>` so status and Android navigation bars always match active Dark/Light mode.

