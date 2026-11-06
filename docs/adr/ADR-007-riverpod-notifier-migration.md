# ADR-007: Riverpod State Management Standardization — Plain `Notifier` / `AsyncNotifier` vs Code Generation

- **Status**: Accepted (Wave 3.2)
- **Date**: 2026-11-06
- **Deciders**: IronFlow Engineering / Wave 3 Architecture Track

---

## 1. Problem Statement

IronFlow (`flutter_riverpod: ^2.6.1`, imported by `122` files across `lib/` and `test/`) currently mixes legacy Riverpod 1.x `StateNotifier` / `StateNotifierProvider` (`27` files, `29` `StateNotifier` classes) with modern `Provider`, `FutureProvider`, and `StreamProvider` declarations. Meanwhile, `riverpod_annotation` (`2.6.1`) and `riverpod_generator` (`2.6.4`) are declared in `pubspec.yaml` with **zero** (`0`) `@riverpod` annotations anywhere in the codebase.

Legacy `StateNotifier` is slated for removal/deprecation in Riverpod 3.x (`flutter_riverpod 3.4.3`), lacks direct access to `Ref` lifecycle hooks (`ref.watch`, `ref.listen`, `ref.onDispose`), and forces boilerplate constructor injection from provider closures.

---

## 2. Options Evaluated

### Option A: Plain `Notifier<T>` / `AsyncNotifier<T>` (Handwritten `NotifierProvider` / `AsyncNotifierProvider`)
- **How it works**: Replace `class FooNotifier extends StateNotifier<FooState>` with `class FooNotifier extends Notifier<FooState>` (initializing synchronous state inside `@override FooState build()`) or `AsyncNotifier<FooState>` where asynchronous `AsyncValue<T>` lifecycles apply. Keep existing provider variable names (`fooProvider = NotifierProvider<FooNotifier, FooState>(FooNotifier.new)`).
- **Pros**:
  - **Zero new runtime dependencies** and zero `build_runner` overhead when editing state logic.
  - Unblocks `analyzer` / `freezed` / `json_serializable` upgrades (currently constrained by `riverpod_generator 2.6.4` pinning `analyzer ^7.x`).
  - Preserves **100% of existing provider symbol names** (`authNotifierProvider`, `workoutNotifierProvider`, `aiChatProvider`, etc.), avoiding churn across `122` consumer and test files.
  - Full `ref.read` / `ref.watch` / `ref.onDispose` support natively inside `build()`, making future Riverpod 3.x upgrades mechanical.
- **Cons**:
  - Requires explicit type arguments on `NotifierProvider<NotifierT, StateT>(NotifierT.new)`.

### Option B: `@riverpod` Code Generation (`riverpod_annotation` + `riverpod_generator`)
- **How it works**: Annotate classes with `@riverpod` / `@Riverpod(keepAlive: true)` and generate `*.g.dart` files via `dart run build_runner build`.
- **Pros**:
  - Concise syntax for family parameters and auto-dispose defaults.
- **Cons**:
  - Adds `27+` new `*.g.dart` generated files and slows CI/local iteration via `build_runner`.
  - Changes generated provider names or `autoDispose` defaults unless every provider is explicitly annotated `@Riverpod(keepAlive: true)` to match existing app-wide singleton behavior (e.g., `authNotifierProvider`, `workoutNotifierProvider`, `restTimerProvider`).
  - Tightly couples state management to `analyzer` version pins inside `riverpod_generator`.

---

## 3. Decision & Recommendation

**Selected: Option A — Plain `Notifier` / `AsyncNotifier` (`NotifierProvider` / `AsyncNotifierProvider`).**

All `29` `StateNotifier` classes across `27` files in `lib/` are migrated feature-by-feature (`core`/`shared` -> `retention`/`onboarding`/`notifications` -> `auth` -> `workout` -> `nutrition` -> `ai`) to `Notifier` (and `AsyncNotifier` / `AsyncValue` where async state applies), preserving all public provider identifiers, state types, and method contracts.

---

## 4. Package, License, Size & Cost Impact

- **New packages added**: `0`
- **License**: MIT (`flutter_riverpod 2.6.1`, verified on pub.dev)
- **Binary / Web bundle size impact**: `0 KB` delta (removes legacy `state_notifier` reliance; `riverpod_annotation` and `riverpod_generator` become candidates for removal once Owner approves `pubspec.yaml` cleanup).
- **Cloud / Runtime cost**: `$0`
- **Risk**: Low — each feature slice is migrated with existing unit/widget/integration tests verified green.
- **Rollback**: Revert individual feature commits or restore `Notifier` -> `StateNotifier` per provider without any storage or schema impact.

