# ADR-003: Riverpod 2.x/3.x State Management — Plain `Notifier` vs Code Generation

- **Status**: Proposed (Awaiting Owner Approval before Wave 3.2)
- **Date**: 2026-11-05
- **Wave**: Wave 3.2

## 1. Problem
All 30 stateful controllers in `lib/` still use legacy `StateNotifier<T>` and `StateNotifierProvider`, which are soft-deprecated in Riverpod 2.x and legacy in Riverpod 3.x. Meanwhile, `riverpod_annotation` and `riverpod_generator` are listed in `pubspec.yaml` with **0 usages**.

## 2. Options Considered

| Option | Description | Pros | Cons |
| :--- | :--- | :--- | :--- |
| **Option A: Plain Hand-Written `Notifier<T>` and `AsyncNotifier<T>` (No `@riverpod` code-gen)** | Migrate `class X extends StateNotifier<S>` to `class X extends Notifier<S>` (with `@override S build()`) and remove unused `riverpod_annotation` / `riverpod_generator`. | **Zero `build_runner` overhead**; no extra `.g.dart` files to generate in CI; unblocks upgrading `freezed` and `analyzer`; explicit, readable provider types. | Requires writing `final xProvider = NotifierProvider<X, S>(X.new);` (1 line of boilerplate per provider). |
| **Option B: Full `@riverpod` Code Generation (`riverpod_generator`)** | Annotate every notifier with `@riverpod` and generate `.g.dart` files via `build_runner`. | Auto-generates provider variables and family parameters. | Adds 50+ new `.g.dart` files, increases CI `build_runner` time by ~35–50s, and tightly couples `analyzer` versions across `freezed` and `riverpod_generator`. |

## 3. Recommendation
- **Option A (Plain `Notifier<T>` and `AsyncNotifier<T>`)** and **remove** unused `riverpod_annotation` and `riverpod_generator` from `pubspec.yaml`.
- **New Runtime Dependencies**: **-1** (removes `riverpod_annotation` and `riverpod_generator`).
- **Size Impact**: Slightly smaller bundle and faster CI builds.
- **Rollback**: Feature-by-feature commits with characterization tests passing before and after each notifier migration.
