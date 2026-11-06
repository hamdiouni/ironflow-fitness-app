# ADR-006: Stricter Lint Rules and Deprecation Policy

- **Status**: Accepted & Implemented (Wave 3.6)
- **Date**: 2026-11-06
- **Deciders**: Engineering & QA Lead

## 1. Problem Statement
During Wave 0 audit, `analysis_options.yaml` used only the default `package:flutter_lints/flutter.yaml` with no explicit safety rules for resource leaks (`cancel_subscriptions`, `close_sinks`), Web/Wasm numeric checks (`avoid_double_and_int_checks`), or deprecated Flutter Color APIs (`.withOpacity(...)`, which had 50 call sites across 5 AI presentation files).

## 2. Options Considered

### Option A: `flutter_lints` + Targeted Correctness & Wasm-Safety Rules + Automated CI Deprecation Guard (Recommended)
- Enable high-signal correctness, resource-safety, and Web/Wasm compatibility lint rules in `analysis_options.yaml`:
  - `avoid_double_and_int_checks: true`
  - `avoid_empty_else: true`
  - `avoid_relative_lib_imports: true`
  - `cancel_subscriptions: true`
  - `close_sinks: true`
  - `no_duplicate_case_values: true`
  - `throw_in_finally: true`
  - `unnecessary_statements: true`
  - `unrelated_type_equality_checks: true`
  - `valid_regexps: true`
- Exclude generated files (`**/*.g.dart`, `**/*.freezed.dart`, `lib/l10n/app_localizations*.dart`) from analyzer noise.
- Migrate all 50 `.withOpacity(...)` call sites to `.withValues(alpha: ...)` and enforce zero `.withOpacity(` regressions via an automated architecture test (`test/architecture/deprecation_and_lint_guard_test.dart`).
- **Pros**: Zero new dependencies; zero false-positive stylistic churn; catches real bugs and Wasm blockers; `flutter analyze --no-fatal-infos` passes with 0 errors and 0 warnings.

### Option B: Adopt `very_good_analysis` or `pedantic` third-party lint package
- **Pros**: Broad opinionated rule set.
- **Cons**: Requires adding a new dev dependency and triggers thousands of purely cosmetic diffs (`prefer_single_quotes`, line-length, doc comments on every private member) that obscure meaningful code review.

## 3. Decision
Adopt **Option A**. All 50 `.withOpacity(...)` calls have been migrated to `.withValues(alpha: ...)`, the Wasm `avoid_double_and_int_checks` violation in `ai_insights_engine_impl.dart` has been resolved, and `test/architecture/deprecation_and_lint_guard_test.dart` prevents regression.

