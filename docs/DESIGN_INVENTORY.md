# IronFlow Design Inventory & Surface Audit

**Repository**: IronFlow Fitness  
**Audit Target**: UI/UX Upgrade using UI UX Pro Max  
**Reference Skill**: [ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) (commit `713eef5`)  
**Baseline Test Suite**: 812 passed, 0 failed  
**Baseline Static Analysis**: 0 errors, 7 warnings, 232 informational lints  

---

## 1. Executive Summary & Design Audit Findings

An exhaustive audit of the 139 UI surfaces across the IronFlow fitness application revealed core ergonomic, structural, and visual friction points:
1. **Repetitive Layout Skeleton**: Screens heavily rely on the same repetitive structure: top bar + monolithic vertical stack of bordered cards + bottom primary button, lacking visual cadence and purpose-driven layout diversity.
2. **Dense Paragraph-Style Copy**: Excessive explanatory prose in empty states, dialogs, and helper text exceeding standard mobile budgets, slowing down in-gym logging.
3. **Motion Deficit**: Page pushes and dialogs pop abruptly without spatial continuity; charts snap into existence without organic draw-in curves; sheets lack smooth drag-physics or micro-haptics.
4. **Sub-Optimal Touch Targets**: Filter chips, equipment selectors, video player controls, and stepper counters measure between 24dp and 38dp, falling short of the standard 44dp–48dp mobile touch guidelines (flagged by UI UX Pro Max mobile touch audit).
5. **Food/Fuel Experience Friction**: Add-food quantity sheet requires excessive vertical scrolling for portion adjustments; macro ring charts lack accessible pattern/symbol differentiation; empty meal slots lack actionable one-tap CTAs.
6. **Exercise & Media Experience Friction**: Video player embeds lack smooth transitions to full-bleed or in-app fallback states; exercise catalog filters feel cramped in high-density viewports.

---

## 2. Complete UI Surface Inventory Table

| ID | Surface / Screen / Component | File / Location | Design Condition | Main Problems / Audit Notes |
| :--- | :--- | :--- | :--- | :--- |
| **INV-F01** | Splash Screen (`SplashScreen`) | `lib/features/auth/presentation/screens/splash_screen.dart` | Monolithic Sci-Fi | Fixed delay timer, lacks branded fluid logo scale-in animation. |
| **INV-F02** | Login Screen (`LoginScreen`) | `lib/features/auth/presentation/screens/login_screen.dart` | Monolithic Sci-Fi | Dense form layout, text fields lack responsive wrap on small mobile viewports. |
| **INV-F03** | Signup Screen (`SignupScreen`) | `lib/features/auth/presentation/screens/signup_screen.dart` | Monolithic Sci-Fi | Redundant explanatory labels, password requirements presented as paragraph text. |
| **INV-F04** | Onboarding Wizard (`OnboardingScreen`) | `lib/features/onboarding/presentation/screens/onboarding_screen.dart` | Mixed | 7-step stepper lacks animated progress transition; sub-40dp option cards. |
| **INV-S01** | Initialization Error Screen | `lib/main.dart:118–194` | Legacy Raw | Bare red error text, lacks styled retry CTA and dark canvas containment. |
| **INV-S02** | Main Navigation Shell (`MainScaffold`) | `lib/main.dart:226–319` | Mixed | BottomNavigationBar lacks animated active pill indicator; tab switch destroys state. |
| **INV-S03** | Today / Home Tab (`HomeScreen`) | `lib/features/workout/presentation/screens/home_screen.dart` | Mixed Card Stack | Repetitive card stack; hero card competes with daily macro progress; no bento hierarchy. |
| **INV-S04** | Train / Workout Tab (`WorkoutScreen`) | `lib/features/workout/presentation/screens/workout_screen.dart` | Card Stack | Start workout button hidden behind scroll; recovery card uses dense jargon. |
| **INV-S05** | Active Workout (`ActiveWorkoutScreen`) | `lib/features/workout/presentation/screens/active_workout_screen.dart` | High Density | Numeric inputs cramped (32dp); rest timer stepper lacks tactile feedback; set logging lacks punch. |
| **INV-S06** | Workout Summary (`WorkoutSummaryScreen`) | `lib/features/workout/presentation/screens/workout_summary_screen.dart` | Sci-Fi Telemetry | Restrained PR celebration; volume metric cards look identical; lacks highlight cards. |
| **INV-S07** | Workout History (`WorkoutHistoryScreen`) | `lib/features/workout/presentation/screens/workout_history_screen.dart` | Legacy List | Dead CTA button in empty state; heavy backdrop filter per row causing micro-jank. |
| **INV-S08** | Split Generator (`ProgramSelectionScreen`) | `lib/features/workout/presentation/screens/program_selection_screen.dart` | Sci-Fi HUD | Monolithic frequency stepper has sub-40dp touch bounds; preview matrix is cramped. |
| **INV-S09** | Program Editor (`ProgramEditorScreen`) | `lib/features/workout/presentation/screens/program_editor_screen.dart` | Mixed List | Drag handles small; exercise edit cards have nested sub-cards causing visual clutter. |
| **INV-S10** | Exercise Catalog (`ExerciseCatalogScreen`) | `lib/features/workout/presentation/screens/exercise_catalog_screen.dart` | Dense Catalog | Equipment filter chips are only 24dp tall; search bar lacks animated clear trigger. |
| **INV-S11** | Exercise Picker (`ExercisePickerScreen`) | `lib/features/workout/presentation/screens/exercise_picker_screen.dart` | List Tile Modal | Raw FilterChip styles; lack of category badge hierarchy; thumbnail row cramped. |
| **INV-S12** | Exercise Detail (`ExerciseDetailScreen`) | `lib/features/workout/presentation/screens/exercise_detail_screen.dart` | Sci-Fi Tabs | Progression chart lacks draw-in animation; missing retry CTA in error state. |
| **INV-S13** | YouTube Exercise Player (`YouTubeExercisePlayer`) | `lib/shared/widgets/youtube_exercise_player.dart` | Raw Player | Overlay controls are 28dp (hard to tap); error fallback card lacks friendly action. |
| **INV-S14** | Fuel / Nutrition Tab (`NutritionScreen`) | `lib/features/nutrition/presentation/screens/nutrition_screen.dart` | Sci-Fi Macro Cards | Macro wheel chart snaps without animation; empty meal slots have disabled buttons. |
| **INV-S15** | Food Search Screen (`FoodSearchScreen`) | `lib/features/nutrition/presentation/screens/food_search_screen.dart` | Search Grid | Filter chips are 30–34dp; custom food creation dialog has raw text fields. |
| **INV-S16** | Nutrition History (`NutritionHistoryScreen`) | `lib/features/nutrition/presentation/screens/nutrition_history_screen.dart` | List View | Empty and error states use dense paragraphs; lacks smooth calendar day navigation. |
| **INV-S17** | Progress Tab (`ProgressScreen`) | `lib/features/body/presentation/screens/progress_screen.dart` | Bento Cards | TabBar indicator unstyled; compare button clamped to 38dp; photo slider web-sensitive. |
| **INV-S18** | Analytics Screen (`AnalyticsScreen`) | `lib/features/analytics/presentation/screens/analytics_screen.dart` | Legacy Analytics | Subtitle uses raw sci-fi jargon; missing retry action on query error. |
| **INV-S19** | Tools Hub (`ToolsHubScreen`) | `lib/features/tools/presentation/screens/tools_hub_screen.dart` | Card Grid | Cards share identical styling; lacks reduced-motion checks on hover/tap. |
| **INV-S20** | AI Coach Chat Screen (`AIChatScreen`) | `lib/features/ai/presentation/screens/ai_chat_screen.dart` | Mixed Chat | Quick prompt chips are 26dp; voice playback audio waveform has raw colors. |
| **INV-S21** | AI Coach Hero Card (`AiCoachHeroCard`) | `lib/features/ai/presentation/widgets/ai_coach_hero_card.dart` | Monolithic Card | Monolithic border glow dominates the Home screen; competes with primary workout CTA. |
| **INV-S22** | Profile Screen (`ProfileScreen`) | `lib/features/profile/presentation/screens/profile_screen.dart` | List Tile Stack | Dense list tiles (~40dp); sign-out progress indicator missing status label. |
| **INV-S23** | Settings Screen (`SettingsScreen`) | `lib/features/settings/presentation/screens/settings_screen.dart` | Standard List | Danger zone lacks distinct visual separation; snackbars use low contrast. |
| **INV-S24** | Reminders Screen (`ReminderSettingsScreen`) | `lib/features/notifications/presentation/screens/reminder_settings_screen.dart` | Form List | Time picker uses unstyled Material dialog; error states print raw exception strings. |
| **INV-S25** | Backup & Export (`ExportSettingsScreen`) | `lib/features/settings/presentation/screens/export_settings_screen.dart` | Form & Code Dump | Monospace telemetry dump panel lacks formatted syntax highlights. |
| **INV-S26** | Privacy Settings (`PrivacySettingsScreen`) | `lib/features/settings/presentation/screens/privacy_settings_screen.dart` | Danger Forms | Type-DELETE safety guard lacks inline validation styling; terms modal unstyled. |
| **INV-S27** | Design Gallery Screen (`DesignGalleryScreen`) | `lib/features/design_system/presentation/screens/design_gallery_screen.dart` | Debug Gallery | Hardcoded titles; theme switcher lacks smooth animated transition. |
| **INV-S28** | AI Test Screen (`AITestScreen`) | `lib/features/ai/presentation/screens/ai_test_screen.dart` | Debug Tool | Raw developer inputs; unconstrained text output. |
| **INV-D01** to **INV-D30** | Modal Dialogs (30 instances) | Various screens across features | Mixed | Unstandardized widths (300dp–480dp); some lack proper barrierDismissible logic. |
| **INV-B01** to **INV-B16** | Bottom Sheets (16 instances) | Quantity, calculators, swaps, filters | Mixed | Inconsistent drag handles; missing standard snap points; cramped paddings. |
| **INV-K01** to **INV-K07** | SnackBars (25+ instances) | Various callers | Ad-hoc | Fixed bottom position obscures navigation bar; contrast issues on colored backgrounds. |
| **INV-CH01** | Filter & Action Chips | Exercise catalog, picker, active workout, food search | Ad-hoc Heights | Touch targets range from 24dp to 34dp (WCAG/UI UX Pro Max requires $\ge 44$dp). |
| **INV-TB01**–**TB02** | Tabs & Segmented Controls | Progress, workout, nutrition, calculator sheets | Standard Material | Missing animated indicator pills; sub-44dp segmented control heights. |
| **INV-LT01** | List Tiles & Dismissible Cards | Meal items, exercise sets, history rows | Mixed | Dismissible meal cards lack Undo callback; ListTile heights under 48dp. |
| **INV-CT01**–**CT05** | Charts (Macro Wheel, Weight, Lifts, Progress) | Nutrition, Progress, Detail | Static Line/Ring | Charts snap without entry animation; lack color-blind accessible stroke patterns. |
| **INV-EM01**–**EM02** | Empty States | Workout history, nutrition history, progress | Plain Text | 2 dead CTA callbacks; dense multi-line paragraphs instead of 1-line prompt + button. |
| **INV-ER01**–**ER02** | Error States | Profile, exercise detail, lifts, home | Missing Retry | 4 screens lack retry buttons; 6 screens display raw Dart exception strings. |
| **INV-PL01**–**PL06** | Platform & Web Shell | `web/index.html`, `web/manifest.json`, Android | Default | White flash on initial web load; unbranded PWA splash colors. |

---

## 3. Deep-Dive Audit: Key Experience Domains

### 3.1 Food / Fuel Experience
- **Add-Food Quantity Sheet (`INV-B11`)**: The portion slider and stepper inputs require excessive scrolling; macro bar lacks instant reactive preview as portion changes.
- **Macro Target Visualization (`INV-CT01`)**: The macro chart uses solid colors without text percentage badges inside each arc segment; accessibility risk for color-deficient users.
- **Empty Meal Logging (`INV-EM01`)**: When no breakfast/lunch/dinner is logged, cards show empty space instead of an encouraging "+ Quick Add" action.
- **Custom Food Creation (`INV-D13`)**: Form uses 8 individual text fields without input formatting or keyboard `textInputAction: TextInputAction.next`.

### 3.2 Exercise & Video Experience
- **Catalog Navigation (`INV-S10`)**: Filtering by equipment or muscle requires horizontal scrolling across tiny 24dp chips that are difficult to tap with gym chalk or sweaty fingers.
- **Detail & Progression (`INV-S12`)**: Exercise history graph lacks date range filtering (1M, 3M, 6M, 1Y) and does not show PR markers on the curve.
- **Video Player (`INV-S13`)**: The YouTube embed lacks tap-to-expand overlay; fallback card shows raw error when offline rather than cached illustration/tips.

### 3.3 Workout Flow & Active Mode
- **Focus Mode Layout (`INV-S05`)**: Active workout mixes timer, plate calculator, and exercise notes onto one screen without clear visual hierarchy.
- **Rest Timer (`INV-D07`)**: Countdown ring lacks animated pulse as it nears 0:00; stepper buttons are small and cramped.
- **Workout Summary (`INV-S06`)**: Summary feels like an accounting receipt rather than a celebration of physical effort.

