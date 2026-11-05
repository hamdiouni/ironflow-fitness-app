# Wave 0.4 — Complete Technology & Dependency Inventory

## 1. Core SDKs, Build Toolchains, and Infrastructure

| Component | Current Version | Latest / Target Verified | License | Where Used | Risk | Verdict & Notes |
| :--- | :--- | :--- | :--- | :--- | :---: | :--- |
| **Flutter SDK** | `3.41.7` (stable, commit `cc0734ac71`) | `3.41.7` (2026-04-15) | BSD-3-Clause | Entire app | LOW | **KEEP** — Current stable channel |
| **Dart SDK** | `3.11.5` (`pubspec.yaml` constraint `^3.10.7`) | `3.11.5` | BSD-3-Clause | Entire app | LOW | **KEEP** — Supports Wasm & modern patterns |
| **Gradle Wrapper** | `8.14-all` | `8.14` | Apache-2.0 | `android/gradle/wrapper/gradle-wrapper.properties` | LOW | **KEEP** — Compatible with Java 17/21 & AGP 8.11 |
| **Android Gradle Plugin (AGP)** | `8.11.1` | `8.11.1` | Apache-2.0 | `android/settings.gradle.kts` | LOW | **KEEP** — Configure flavors & R8 in Wave 2/5 |
| **Kotlin Android Plugin** | `2.2.20` | `2.2.20` | Apache-2.0 | `android/settings.gradle.kts` | LOW | **KEEP** |
| **Google Services Gradle Plugin** | `4.4.2` | `4.4.2` | Apache-2.0 | `android/settings.gradle.kts` | LOW | **KEEP** — Add `com.google.firebase.crashlytics` plugin in Wave 2 |
| **Java Compatibility Target** | `JavaVersion.VERSION_17` + `desugar_jdk_libs:2.0.4` | `Java 17` (`desugar_jdk_libs:2.1.4`) | GPLv2+CE | `android/app/build.gradle.kts` | LOW | **UPGRADE** `desugar_jdk_libs` in Wave 3.1 |
| **Android Firebase BoM** | `34.13.0` | `34.13.0` | Apache-2.0 | `android/app/build.gradle.kts` | LOW | **KEEP** |
| **iOS Deployment Target & CocoaPods** | Flutter default (`ios/Runner.xcodeproj`), no committed `ios/Podfile` | iOS `14.0+` recommended for Firebase 11+/12+ | MIT (CocoaPods) | `ios/` | HIGH | **REFACTOR** — Generate `ios/Podfile` with explicit platform `:ios, '14.0'` and add `PrivacyInfo.xcprivacy` in Wave 2/5 |
| **GitHub Actions CI** | `actions/checkout@v4`, `actions/setup-java@v4`, `subosito/flutter-action@v2`, `actions/cache@v4`, `actions/upload-artifact@v4` | Current v4 actions | MIT | `.github/workflows/ci.yml` | MEDIUM | **UPGRADE** workflow to add secret scan, coverage gate, and web build in Wave 2.4 |
| **Git History Rewrite Tool** | `git-filter-repo 2.47.0` | `2.47.0` | MIT | Local security maintenance | LOW | **KEEP** (dev machine tool) |

---

## 2. Direct Runtime Dependencies (`pubspec.yaml` -> `dependencies`)

> **Note on Release Dates**: `dart pub outdated --json` provides exact locked, upgradable, resolvable, and latest versions from `pub.dev`. Exact package publication timestamps are not stored in `pubspec.lock` and require live `pub.dev/api/packages/<pkg>` queries; versions below are verified from `dart pub outdated --json` run on 2026-11-05.

| Package | Locked Version | Upgradable | Resolvable | Latest on pub.dev | License (Verified in `.pub-cache`) | Import Count (`lib`+`test`) | Size / Platform Impact | Risk | Verdict & Rationale |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :--- | :---: | :--- |
| `flutter_riverpod` | `2.6.1` | `2.6.1` | `3.3.1` | `3.4.3` | Unknown | 122 | Low (pure Dart) — Core state management across all features | LOW | **KEEP (evaluate major 3.4.3 in W3.1)** |
| `riverpod_annotation` | `2.6.1` | `2.6.1` | `4.0.2` | `4.0.7` | Unknown | 0 | None (unused in runtime) — Declared in pubspec but 0 `@riverpod` annotations exist in `lib/` | LOW | **REMOVE (or use in W3.2)** |
| `hive` | `2.2.3` | `2.2.3` | `2.2.3` | `2.2.3` | Unknown | 50 | Low (~150 KB Dart) — Primary local NoSQL storage engine (24 box-opening files, 63 total files) | LOW | **KEEP** |
| `hive_flutter` | `1.1.0` | `1.1.0` | `1.1.0` | `1.1.0` | Unknown | 7 | Low — Flutter path initialization wrapper for Hive | LOW | **KEEP** |
| `go_router` | `14.8.1` | `14.8.1` | `17.5.0` | `18.1.3` | Unknown | 27 | Low — Declarative routing (`lib/core/router/app_router.dart`) | LOW | **KEEP (evaluate major 18.1.3 in W3.1)** |
| `freezed_annotation` | `2.4.4` | `2.4.4` | `3.1.0` | `3.1.0` | Unknown | 48 | Minimal (annotations only) — Immutable entity & model annotations (`@freezed`) | LOW | **KEEP (evaluate major 3.1.0 in W3.1)** |
| `json_annotation` | `4.9.0` | `4.9.0` | `4.11.0` | `4.12.0` | Unknown | 0 | Minimal — JSON serialization annotations (`@JsonSerializable`) | LOW | **KEEP (evaluate major 4.12.0 in W3.1)** |
| `uuid` | `4.5.3` | `4.6.0` | `4.6.0` | `4.6.0` | Unknown | 13 | Minimal — UUID v4 generation for workouts, sets, meals, sync actions | LOW | **UPGRADE (patch/minor -> 4.6.0)** |
| `collection` | `1.19.1` | `1.19.1` | `1.19.1` | `1.19.1` | Unknown | 1 | Minimal — Iterable utilities (`firstWhereOrNull`, grouping) | LOW | **KEEP** |
| `flutter_animate` | `4.5.2` | `4.5.2` | `4.5.2` | `4.5.2` | Unknown | 17 | Low — Declarative micro-animations on cards and transitions | LOW | **KEEP** |
| `lottie` | `3.3.0` | `3.3.0` | `3.7.0` | `3.8.2` | Unknown | 0 | Medium (~300 KB) — JSON vector animation rendering (`assets/animations/celebration.json`) | LOW | **KEEP (evaluate major 3.8.2 in W3.1)** |
| `fl_chart` | `0.70.2` | `0.70.2` | `1.3.0` | `1.3.0` | Unknown | 9 | Medium (~450 KB) — Line, bar, and radar charts in Analytics, Progress, and Fuel | LOW | **KEEP (evaluate major 1.3.0 in W3.1)** |
| `cupertino_icons` | `1.0.9` | `1.0.9` | `1.0.9` | `2.0.0` | Unknown | 0 | Medium (~250 KB font asset) — iOS-style icon font | LOW | **KEEP (evaluate major 2.0.0 in W3.1)** |
| `image_picker` | `1.2.1` | `1.2.4` | `1.2.4` | `1.2.4` | Unknown | 1 | Native plugin (Android/iOS/Web) — Progress photo & profile image selection | LOW | **UPGRADE (patch/minor -> 1.2.4)** |
| `cached_network_image` | `3.4.1` | `3.4.1` | `3.4.1` | `4.0.6` | Unknown | 7 | Medium (uses sqflite/path_provider) — Disk-cached network images for food & exercise thumbnails | LOW | **KEEP (evaluate major 4.0.6 in W3.1)** |
| `flutter_cache_manager` | `3.4.1` | `3.5.0` | `3.5.0` | `3.5.0` | Unknown | 0 | Medium — Backing cache manager for `cached_network_image` | LOW | **UPGRADE (patch/minor -> 3.5.0)** |
| `video_player` | `2.11.1` | `2.11.1` | `2.11.1` | `2.14.1` | Unknown | 0 | High (ExoPlayer on Android) — Exercise demonstration video playback | LOW | **KEEP (evaluate major 2.14.1 in W3.1)** |
| `youtube_player_iframe` | `5.2.2` | `5.2.2` | `6.0.2` | `6.0.2` | Unknown | 1 | Medium (WebView/iframe) — Embedded YouTube exercise demos (`exercise_database.dart`) | LOW | **KEEP (evaluate major 6.0.2 in W3.1)** |
| `flutter_svg` | `2.2.4` | `2.3.2` | `2.3.2` | `2.3.2` | Unknown | 0 | Medium (~350 KB) — SVG vector rendering (candidate for Body Map 2D paths) | LOW | **UPGRADE (patch/minor -> 2.3.2)** |
| `http` | `1.6.0` | `1.6.0` | `1.6.0` | `1.6.0` | Unknown | 6 | Low — REST client for Gemini AI proxy/direct calls | LOW | **KEEP** |
| `flutter_tts` | `4.2.5` | `4.2.5` | `4.2.5` | `4.2.5` | SDK/Flutter | 1 | Native + Web (blocks Wasm via legacy JS interop) — Text-to-speech voice playback in AI Coach (`ai_chat_screen.dart`) | MEDIUM | **KEEP (guard Web Wasm in W5.2)** |
| `firebase_core` | `3.15.2` | `3.15.2` | `5.1.0` | `5.1.0` | SDK/Flutter | 7 | High (native SDKs) — Firebase initialization (`lib/main.dart`) | MEDIUM | **UPGRADE (staged in W3.1)** |
| `cloud_firestore` | `5.6.12` | `5.6.12` | `7.1.0` | `7.1.0` | SDK/Flutter | 12 | High (~8-12 MB native APK impact) — Cloud sync & remote data purge (`features/sync`, `features/settings`) | MEDIUM | **UPGRADE (staged in W3.1)** |
| `firebase_auth` | `5.7.0` | `5.7.0` | `7.0.1` | `7.0.1` | SDK/Flutter | 3 | Medium (native SDKs) — Authentication & JWT token provider for AI proxy | MEDIUM | **UPGRADE (staged in W3.1)** |
| `firebase_storage` | `12.4.10` | `12.4.10` | `14.0.1` | `14.0.1` | SDK/Flutter | 3 | Medium (native SDKs) — Cloud storage for progress photos & profile avatars | MEDIUM | **UPGRADE (staged in W3.1)** |
| `firebase_crashlytics` | `4.3.10` | `4.3.10` | `6.0.1` | `6.0.1` | Unknown | 2 | Medium (native SDKs; missing Gradle plugin) — Crash reporting (`lib/main.dart`) | MEDIUM | **UPGRADE (staged in W3.1)** |
| `firebase_analytics` | `11.6.0` | `11.6.0` | `13.0.1` | `13.0.1` | Unknown | 2 | Medium (native SDKs) — Telemetry & retention event logging | MEDIUM | **UPGRADE (staged in W3.1)** |
| `google_sign_in` | `6.3.0` | `6.3.0` | `7.2.0` | `7.2.0` | Unknown | 3 | Medium (Play Services Auth) — Federated Google OAuth sign-in | LOW | **KEEP (evaluate major 7.2.0 in W3.1)** |
| `sign_in_with_apple` | `6.1.4` | `6.1.4` | `8.1.0` | `8.2.0` | Unknown | 1 | Low — Federated Apple OAuth sign-in (mandatory for iOS App Store when offering Google Sign-In) | LOW | **KEEP (evaluate major 8.2.0 in W3.1)** |
| `flutter_secure_storage` | `9.2.4` | `9.2.4` | `11.2.0` | `11.2.0` | Unknown | 1 | Medium (blocks Wasm on v9.2.4; v11.2.0 available) — Hardware-backed keystore/keychain storage for tokens & Hive encryption keys | MEDIUM | **UPGRADE (to 11.x for Web/Wasm)** |
| `connectivity_plus` | `6.1.5` | `6.1.5` | `7.3.2` | `7.3.2` | SDK/Flutter | 6 | Low — Network state monitoring for offline sync queue | LOW | **KEEP (evaluate major 7.3.2 in W3.1)** |
| `flutter_local_notifications` | `17.2.4` | `17.2.4` | `22.3.3` | `22.3.3` | Unknown | 4 | Medium (Android receivers) — Scheduled workout reminders & rest timer alerts | LOW | **KEEP (evaluate major 22.3.3 in W3.1)** |
| `timezone` | `0.9.4` | `0.9.4` | `0.11.2` | `0.11.2` | Unknown | 4 | Medium (~600 KB tzdb) — Timezone database for `flutter_local_notifications` | LOW | **KEEP (evaluate major 0.11.2 in W3.1)** |
| `intl` | `0.20.2` | `0.20.2` | `0.20.2` | `0.20.3` | Unknown | 12 | Medium — Locale date/number formatting and `AppLocalizations` | LOW | **KEEP (evaluate major 0.20.3 in W3.1)** |
| `flutter_dotenv` | `5.2.1` | `5.2.1` | `6.0.1` | `6.0.1` | Unknown | 2 | Low — Loads debug `.env` file (`lib/main.dart`) | LOW | **KEEP (evaluate major 6.0.1 in W3.1)** |
| `flutter_markdown_plus` | `1.0.12` | `1.0.12` | `1.0.12` | `1.0.12` | Unknown | 2 | Low — Renders formatted markdown responses in `ai_chat_screen.dart` | LOW | **KEEP** |
| `share_plus` | `10.1.4` | `10.1.4` | `13.3.1` | `13.3.1` | SDK/Flutter | 1 | Low — Exports CSV/JSON backups and workout share cards | LOW | **KEEP (evaluate major 13.3.1 in W3.1)** |
| `archive` | `3.6.1` | `3.6.1` | `4.6.0` | `4.6.0` | Unknown | 1 | Low — ZIP compression for full data export (`export_all_data_use_case.dart`) | LOW | **KEEP (evaluate major 4.6.0 in W3.1)** |
| `path_provider` | `2.1.5` | `2.1.6` | `2.1.6` | `2.1.6` | Unknown | 7 | Low — App document/temp directory lookup | LOW | **UPGRADE (patch/minor -> 2.1.6)** |
| `shared_preferences` | `2.5.6` | `2.5.6` | `2.5.6` | `2.5.6` | Unknown | 11 | Low — Stores telemetry consent booleans and simple flags | LOW | **KEEP** |
| `url_launcher` | `6.3.3` | `6.3.3` | `6.3.3` | `6.3.3` | Unknown | 1 | Low — Opens external documentation, privacy policy, and YouTube links | LOW | **KEEP** |

---

## 3. Direct Dev Dependencies (`pubspec.yaml` -> `dev_dependencies`)

| Package | Locked Version | Upgradable | Resolvable | Latest on pub.dev | License | Import Count | Verdict & Notes |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| `flutter_lints` | `6.0.0` | `6.0.0` | `6.0.0` | `6.0.0` | Unknown | 0 | **KEEP / UPGRADE in W3.1** — Static analyzer rule set (`analysis_options.yaml`) |
| `build_runner` | `2.5.4` | `2.5.4` | `2.15.1` | `2.17.1` | Unknown | 0 | **KEEP / UPGRADE in W3.1** — Code generation runner for Freezed and JSON Serializable |
| `freezed` | `2.5.8` | `2.5.8` | `3.2.5` | `4.0.3` | Unknown | 0 | **KEEP / UPGRADE in W3.1** — Code generator for `@freezed` entities and models |
| `json_serializable` | `6.9.5` | `6.9.5` | `6.13.0` | `6.15.2` | Unknown | 0 | **KEEP / UPGRADE in W3.1** — Code generator for `.g.dart` JSON serializers |
| `riverpod_generator` | `2.6.4` | `2.6.4` | `4.0.3` | `4.0.9` | Unknown | 0 | **REMOVE (if plain Notifier chosen in ADR-003)** — Declared in dev_dependencies, but 0 `@riverpod` annotations exist |
| `mockito` | `5.4.6` | `5.4.6` | `5.6.4` | `5.8.1` | Unknown | 9 | **KEEP / UPGRADE in W3.1** — Mock generation for unit/widget tests |

---

## 4. Vulnerability & Discontinued Package Audit (`dart pub outdated`)

- **Known CVEs in Locked Dart Packages**: 0 advisories reported by `dart pub outdated --json` against current `pubspec.lock`.
- **Wasm / Legacy Web Interop Risks**:
  - `flutter_secure_storage` (`9.2.4` -> `flutter_secure_storage_web 1.2.1`) imports legacy `dart:html` and `dart:js_util`. Upgrading to `flutter_secure_storage: ^11.2.0` (`flutter_secure_storage_web 2.x`) migrates to `package:web` and `dart:js_interop`.
  - `flutter_tts` (`4.2.0`) uses legacy JS interop on Web.
- **Unused Code-Gen Dependencies**: `riverpod_annotation` (`2.6.1`) and `riverpod_generator` (`2.6.4`) have **0** usages in `lib/`. Removing them (per ADR-003) simplifies `build_runner` and removes analyzer version constraints (`analyzer` pinned by `riverpod_generator`).
