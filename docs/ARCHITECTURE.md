# IronFlow Architecture Map

## 1. System Overview
IronFlow is a fitness companion mobile application built with Flutter, structured around Clean Architecture principles and modular feature domains.

```
lib/
├── core/                  # Cross-cutting foundational modules
│   ├── config/            # AppConfig (keys, runtime env)
│   ├── constants/         # AppTheme, AppTypography, AppSpacings
│   ├── error/             # ErrorHandler, exceptions, failures
│   ├── models/            # Core shared models
│   ├── providers/         # Global Theme and system providers
│   ├── router/            # GoRouter configuration & route guards
│   ├── services/          # Background sync, notifications
│   ├── theme/             # Token extensions and color definitions
│   ├── utils/             # HiveManager, AppLogger, math utilities
│   └── widgets/           # Global core layout widgets
├── features/              # Feature modules (Clean Architecture)
│   ├── ai/                # Gemini client, prompt templates, local coach
│   ├── analytics/         # Consistency metrics, streak calculations
│   ├── auth/              # Firebase/Mock Auth, session persistence
│   ├── body/              # Weight entries, circumferences, progress photos
│   ├── design_system/     # Design tokens and UI gallery
│   ├── notifications/     # Local reminders and alarm scheduling
│   ├── nutrition/         # Food logging, verified USDA foods, budget swaps
│   ├── onboarding/        # 7-step profile setup, BMR/TDEE calculation
│   ├── profile/           # User settings, goals, preferences
│   ├── retention/         # Streak tracking, re-engagement logic
│   ├── settings/          # Export/import, privacy, account wipe
│   ├── sync/              # Offline sync queue & Firestore sync
│   └── workout/           # Splits, active tracker, catalog, volume config
├── l10n/                  # Localization (ARB files & generated classes)
└── shared/                # Reusable UI components (AppButton, AppCard, AppHaptics)
```

---

## 2. Core Architectural Pillars

### State Management
- **Library**: `flutter_riverpod: ^2.6.1` and `riverpod_annotation: ^2.6.1`.
- **Pattern**: `StateNotifierProvider` for stateful screen and session mutators (e.g. `WorkoutNotifier`, `ActiveProgramNotifier`, `AIChatNotifier`, `AuthNotifier`); `Provider` / `FutureProvider` for immutable read access, use cases, and repositories.
- **Rules**: Logic lives in domain use cases and presentation notifiers; widgets strictly watch state or trigger notifier methods.

### Routing & Navigation
- **Library**: `go_router: ^14.6.2`.
- **Location**: `lib/core/router/app_router.dart` (`routerProvider`).
- **Structure**: `StatefulShellRoute.indexedStack` maintains 4 bottom dock tabs:
  1. `AppRoutes.home` (`/home` - Today)
  2. `AppRoutes.workout` (`/workout` - Train)
  3. `AppRoutes.nutrition` (`/nutrition` - Fuel)
  4. `AppRoutes.progress` (`/progress` - Progress)
- **Route Redirection Guards**: `redirect:` inspects `authNotifierProvider` and `UserProfileStorage().isOnboardedSync(userId:)`. Unauthenticated requests route to `/login`; authenticated users without completed onboarding route to `/onboarding`.

### Storage & Persistence
- **Library**: `hive: ^2.2.3` & `hive_flutter: ^1.1.0`.
- **Location**: `lib/core/utils/hive_manager.dart`.
- **Storage Strategy**: Boxes store structured JSON maps (`Box<Map>`), deserialized into immutable entity models generated with `freezed` (`freezed_annotation: ^2.4.4`) and `json_serializable`.
- **Active Program Storage**: `active_program` box under key `current_active_program`, serialized via `ActiveProgramModel`. Provides automated JSON snapshot archiving for immediate UNDO restoration.
- **Profile Storage**: Namespaced box `user_profile_box_${userId}` preserves multi-user isolation on shared devices.

### Dependency Injection
- Pure Riverpod provider dependency wiring:
  `DataSource` -> `RepositoryImpl(DataSource)` -> `UseCase(Repository)` -> `StateNotifier(UseCase)`.
- No global service locator (no `GetIt`), allowing clean mocking in unit tests with `ProviderScope(overrides: [...])`.

### Localization
- **Framework**: Official Flutter `flutter_localizations` & `intl: 0.20.2`.
- **Configuration**: `l10n.yaml` with source files in `lib/l10n/app_en.arb`, `app_de.arb`, `app_es.arb`, `app_fr.arb`, `app_ja.arb`, `app_pt.arb`, `app_zh.arb`.
- **Requirement**: All user-facing strings must reside in ARB catalogs rather than ad-hoc inline text.

### Design System
- **Location**: `lib/core/constants/app_theme.dart` and `lib/features/design_system/`.
- **Theme Tokens**: `AppThemeTokens` accessed via `context.tokens` or `AppThemeTokens.of(context)`. Provides semantic colors (`canvas`, `panel`, `card`, `kineticAccent`, `cyanAccent`, `textPrimary`, `textSecondary`, `borderSubtle`).
- **Typography**: `SpaceGrotesk` for display headers and numbers; `Inter` for body copy.
- **Components**: Pre-built reusable widgets in `lib/shared/presentation/components/` (`AppButton`, `AppCard`, `AppTextField`, `AppStateView`).

### Charts & Visualization
- **Library**: `fl_chart: ^0.70.1`.
- **Existing Implementations**: `WeightTrendGraph` (LineChart), `_WorkoutFrequencyChart` (BarChart), `_VolumeProgressionChart` (LineChart), `_MuscleGroupChart` (PieChart).
- **Sampling Utility**: `ChartDataSampler` downsamples large historical data sets to maintain 60 FPS rendering.

---

## 3. Placement Map for New Requirements

| New Component | Architectural Layer | Recommended Location | Rationale |
| :--- | :--- | :--- | :--- |
| **Guided Split Picker Step** | Presentation (Onboarding) | `lib/features/onboarding/presentation/screens/onboarding_screen.dart` | Seamless insertion into 7-step stepper prior to plan generation. |
| **Split Plan Preview & Confirmation** | Presentation (Workout/Onboarding) | `lib/features/workout/presentation/widgets/split_generator/` | Reuses existing `ScheduleDayPreview` and `MuscleFrequencyCard`. |
| **Split Engine & Hybrids** | Domain (Workout) | `lib/features/workout/domain/splits/` | Pure Dart data-driven split generator, templates, and volume configs. |
| **Deterministic Meal Suggester** | Domain (Nutrition) | `lib/features/nutrition/domain/usecases/build_suggested_meal_plan_use_case.dart` | Pure logic matching user caloric/macro targets to budget tier verified foods. |
| **Suggested Meal Plan UI Card** | Presentation (Nutrition) | `lib/features/nutrition/presentation/widgets/suggested_meal_plan_card.dart` | Embedded in Fuel tab and previewable after onboarding. |
| **AI Screen-Context Prompts** | Domain & Presentation (AI) | `lib/features/ai/domain/services/ai_context_builder.dart` & `ai_provider.dart` | Calculates facts from local state and formats prompt rules. |
| **Tools Hub Screen** | Presentation (Tools) | `lib/features/workout/presentation/screens/tools_hub_screen.dart` | Dedicated home for calculators (Plate, 1RM, Calorie/Macro, Body Fat, Goal Planner, Water). |
| **Pure Calculator Functions** | Core / Domain Utils | `lib/core/utils/fitness_calculators.dart` | Pure, unit-tested functions for kg/lb, cm/in without side effects. |
| **Copy & Language Standards** | Documentation & L10n | `docs/COPY_GUIDE.md` & `lib/l10n/app_en.arb` | Centralized vocabulary standard and dictionary mapping. |
