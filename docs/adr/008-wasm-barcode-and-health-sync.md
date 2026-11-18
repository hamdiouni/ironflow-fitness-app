# ADR-008: WebAssembly (Wasm) Compatibility, Open Food Facts Barcode Lookup (8.2), and Health Connect / HealthKit Sync Bridge (8.4)

- **Status:** Accepted & Implemented
- **Date:** 2026-11-18
- **Waves:** Post-Wave 9 Enhancement (Options 1 & 2)

## Context

1. **WebAssembly (`--wasm-dry-run`) Compatibility (Option 1):**
   `flutter build web` previously reported Wasm dry-run incompatibilities in two transitive web plugin implementations:
   - `flutter_secure_storage_web 1.2.1` imported legacy `dart:html`, `dart:js_util`, and `package:js/js.dart`.
   - `flutter_tts 4.2.5` cast `JSAny?` values directly to `int` and `String` in `flutter_tts_web.dart` (`invalid_runtime_check_with_js_interop_types`).
2. **Candidate 8.2 — Barcode Scanner & Open Food Facts Lookup:**
   Users need a fast, zero-permission-friction barcode lookup flow in the Food Search screen that resolves EAN-13 / UPC-A / GTIN barcodes against an offline verified gym-food catalog and the Open Food Facts API v2 (under ODbL v1.0 attribution).
3. **Candidate 8.4 — Health Connect & Apple HealthKit Two-Way Sync Bridge:**
   Users need opt-in two-way synchronization for body weight / body fat measurements and completed workout exports (duration, total volume, and MET-estimated active kilocalories) via a clean domain contract and platform channel bridge.

## Decision

1. **Wasm-Clean Web Plugin Overrides (`packages/`):**
   - Replaced `dart:html`, `dart:js_util`, and `package:js/js.dart` in `packages/flutter_secure_storage_web` with pure `dart:js_interop` bindings over `window.localStorage` and `window.crypto.subtle` (AES-GCM 256-bit), preserving 100% storage format compatibility.
   - Replaced unsafe `JSAny?` casts in `packages/flutter_tts/lib/flutter_tts_web.dart` with typed `JSNumber.toDartInt` and `JSString.toDart` conversions.
   - Verified `flutter build web --release --no-pub` passes the Wasm dry run with zero findings.
2. **Open Food Facts Barcode Lookup (`8.2`):**
   - Implemented pure-Dart `OpenFoodFactsService` (`lib/features/nutrition/domain/services/open_food_facts_service.dart`) with GS1 Modulo-10 check-digit verification, an instant offline gym-food barcode catalog, and Open Food Facts v2 JSON parsing with 4P+4C+9F fallback energy calculation.
   - Added `BarcodeScannerSheet` (`lib/features/nutrition/presentation/widgets/food_search/barcode_scanner_sheet.dart`) and wired it into `FoodSearchScreen`.
3. **Health Connect & HealthKit Sync Bridge (`8.4`):**
   - Implemented pure-Dart `HealthSyncService` (`lib/features/body/domain/services/health_sync_service.dart`) with MET active energy estimation and 5-minute timestamp deduplication.
   - Implemented `MethodChannelHealthGateway` (`lib/features/body/data/services/method_channel_health_gateway.dart`) over `com.ironflow.app/health_sync` with automatic fallback to a cross-platform simulation bridge.
   - Added `HealthSyncSettingsSheet` (`lib/features/settings/presentation/widgets/health_sync_settings_sheet.dart`) and wired it into `SettingsScreen`.
