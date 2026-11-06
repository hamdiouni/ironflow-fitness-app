# Wave 3.1 — Toolchain & Dependency Upgrades Report

- **Branch**: `feat/prod-wave-3`
- **Date**: 2026-11-06
- **Policy**: Verify every SDK and package against `pubspec.lock`, `dart pub outdated`, and native Gradle/iOS configurations; read breaking changes; apply safe non-breaking updates within verified constraints; document deferred major versions with explicit technical rationale.

---

## 1. SDK & Native Build Toolchain Verification

| Component | Verified Version | Target / Latest | Action in Wave 3.1 | Rationale |
| :--- | :--- | :--- | :--- | :--- |
| **Flutter SDK** | `3.41.7` (stable) | `3.41.7` | **KEEP** | Current stable channel; zero deprecations remaining in `lib/` after Wave 3.6. |
| **Dart SDK** | `3.11.5` (`^3.10.7`) | `3.11.5` | **KEEP** | Current stable Dart 3.11 with modern `Notifier` and Wasm static checks. |
| **Gradle Wrapper** | `8.14-all` | `8.14` | **KEEP** | Fully compatible with AGP `8.11.1` and JDK 17/21. |
| **Android Gradle Plugin (AGP)** | `8.11.1` | `8.11.1` | **KEEP** | Current stable AGP configured in `android/settings.gradle.kts`. |
| **Kotlin Android Plugin** | `2.2.20` | `2.2.20` | **KEEP** | Current Kotlin 2.2 toolchain with JVM target `17`. |
| **Google Services Plugin** | `4.4.2` | `4.4.2` | **KEEP** | Matches Firebase Android BoM `34.13.0`. |
| **Android Core Library Desugaring** | `2.0.4` -> **`2.1.4`** | `2.1.4` | **UPGRADED** | Updated `com.android.tools:desugar_jdk_libs` to `2.1.4` in `android/app/build.gradle.kts` (recommended for AGP 8.11+ and Java 17 API desugaring). |
| **Android Firebase BoM** | `34.13.0` | `34.13.0` | **KEEP** | Manages Android `firebase-analytics`, `firebase-auth`, and `firebase-firestore` native artifacts cleanly. |
| **iOS Target & CocoaPods** | `IPHONEOS_DEPLOYMENT_TARGET = 13.0` (`project.pbxproj`), `PrivacyInfo.xcprivacy` added in Wave 2 | iOS `15.0+` (CI macOS pod install) | **DEFERRED TO WAVE 5.1 (CI macOS)** | Windows host cannot run `pod install` locally; explicit `ios/Podfile` generation & deployment target bump to `15.0` will be validated on CI macOS runner in Wave 5.1. |

---

## 2. Safe Non-Breaking Pub Upgrades Applied (`flutter pub upgrade`)

All compatible minor and patch updates within existing `pubspec.yaml` caret constraints were applied and verified against the full test suite (`0` known CVEs):

| Package | Previous Locked | Upgraded Locked | Scope | Notes |
| :--- | :---: | :---: | :--- | :--- |
| `uuid` | `4.5.3` | `4.6.0` | Runtime | Minor release; RFC 9562 UUID v4/v7 perf improvements, 100% API compatible. |
| `image_picker` | `1.2.1` | `1.2.4` | Runtime | Android Photo Picker & iOS PHPicker stability fixes (`image_picker_android 0.8.13+25`). |
| `flutter_cache_manager` | `3.4.1` | `3.5.0` | Runtime | Cache eviction & HTTP header fixes backing `cached_network_image`. |
| `flutter_svg` | `2.2.4` | `2.3.2` | Runtime | Vector path parsing & shader fixes (prepares for Wave 4 2D SVG/Canvas Body Map). |
| `path_provider` | `2.1.5` | `2.1.6` | Runtime | Platform interface minor update (`path_provider_platform_interface 2.1.3`). |

---

## 3. Major Version Breaking-Change Evaluation (Deliberately Deferred)

| Package Family | Current Locked | Latest Major | Breaking Changes Verified | Decision |
| :--- | :---: | :---: | :--- | :--- |
| `flutter_riverpod` | `2.6.1` | `3.4.3` | Removes legacy `StateNotifierProvider` from primary surface, overhauls `AsyncNotifier` retry/mutation semantics, and requires `analyzer >=9.x` (incompatible with `freezed 2.5.8`). | **DEFER major** — Wave 3.2 completes migrating all `29` `StateNotifier` classes to `Notifier` / `AsyncNotifier` (`ADR-007`), making future Riverpod 3.x adoption mechanical once `freezed` is upgraded. |
| `riverpod_annotation` / `riverpod_generator` | `2.6.1` / `2.6.4` | `4.0.7` / `4.0.9` | `0` `@riverpod` annotations exist in `lib/`. `ADR-007` standardizes on plain `Notifier` / `AsyncNotifier`. | **CANDIDATE FOR REMOVAL (`ASK`)** — Listed for Owner approval to remove from `pubspec.yaml`. |
| `freezed` / `freezed_annotation` | `2.5.8` / `2.4.4` | `4.0.3` / `3.1.0` | Freezed 3+/4+ requires `abstract` or `sealed` modifiers on all `48` `@freezed` model/entity classes and full `.freezed.dart` regeneration. | **DEFER major** — Zero defects in current generated models; avoids high-churn regeneration across 48 data classes. |
| `go_router` | `14.8.1` | `18.1.3` | Alters `GoRouterState` URI/extra encoding rules and redirect edge cases. | **DEFER major** — Current `14.8.1` has `0` CVEs and passes all deep-link and auth-redirect tests. |
| `fl_chart` | `0.70.2` | `1.3.0` | Breaking `AxisTitles`, `LineTouchData`, and bar rod API changes across `9` chart files. | **DEFER major** — Revisit only if Wave 4/5 chart enhancements require 1.x APIs. |
| `firebase_*` FlutterFire suite | `core 3.15.2`, `firestore 5.6.12`, `auth 5.7.0`, `storage 12.4.10`, `app_check 0.3.2+10` | `core 5.1.0`, `firestore 7.1.0`, `auth 7.0.1`, `storage 14.0.1`, `app_check 0.5.1` | Coupled lockstep major upgrade requiring iOS `15.0+` CocoaPods Firebase SDK 12.x verification on macOS and updated Web JS SDK interop. | **DEFER major** — Current locked suite has `0` CVEs, builds cleanly on Android + Web, and should only be bumped alongside macOS CI `Podfile.lock` regeneration in Wave 5. |
| `flutter_secure_storage` | `9.2.4` | `11.2.0` | Migrates Android default cipher from `RSA/ECB/PKCS1Padding` + `AES/CBC` to Tink/OAEP; upgrading without an explicit Android Keystore read-fallback test risks stranding existing Wave 1.8 Hive AES-256 encryption keys on upgraded devices. `v11.x` also migrates Web to `package:web` for Wasm. | **DEFER to Wave 5.2 (Web/Wasm track)** — Must pair with an Android `resetOnError: false` + legacy cipher migration test on real Android target. |
| `flutter_local_notifications` + `timezone` | `17.2.4` + `0.9.4` | `22.3.3` + `0.11.2` | Removes legacy iOS <10 callbacks and changes `zonedSchedule` required named parameters (`androidScheduleMode` / `uiLocalNotificationDateInterpretation` removal). | **DEFER major** — Current notification scheduling and Wave 1.5 permission flow are tested and stable. |

