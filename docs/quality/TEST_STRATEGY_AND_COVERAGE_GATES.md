# IronFlow Test Strategy & Coverage Gates (`Wave 2.1`)

## 1. Philosophy: Real Evidence Over Vanity Counts
- Every business-logic or architectural change requires **characterization tests first** (tests that pass on existing code before refactoring).
- Generated files (`*.g.dart`, `*.freezed.dart`, `lib/l10n/*`) and isolated design-lab preview files (`lib/preview/*`) are excluded from coverage calculations so percentages reflect real production code.
- Coverage is measured and gated by architectural layer (`domain` > `data` > `core` > `presentation`) using [`scripts/check_coverage.py`](../../scripts/check_coverage.py).

---

## 2. Layer & Feature Thresholds

| Scope | Wave 0 Measured Baseline | Wave 2 Measured Result | Wave 2 Enforced Gate (`check_coverage.py`) | Wave 3 Target |
|---|---:|---:|---:|---:|
| **Domain Layer (`*/domain/*`)** | 56.98% | **74.43%** (`3,178 / 4,270` lines) | **>= 70.0%** | **>= 80.0%** |
| **Data Layer (`*/data/*`)** | 56.20% | **62.08%** (`2,814 / 4,533` lines) | **>= 60.0%** | **>= 70.0%** |
| **Core Layer (`lib/core/*`)** | 54.10% | **62.21%** (`894 / 1,437` lines) |Tracked | **>= 70.0%** |
| **Shared Layer (`lib/shared/*`)** | 71.00% | **73.97%** (`682 / 922` lines) | Tracked | **>= 75.0%** |
| **Presentation Layer (`*/presentation/*`)** | 58.10% | **59.06%** (`9,786 / 16,569` lines) | Tracked | **>= 62.0%** |
| **Overall Non-Generated Code** | 53.15% | **62.58%** (`17,354 / 27,731` lines) | **>= 60.0%** *(No-Drop Gate)* | **>= 65.0%** |

---

## 3. Critical Path Characterization Suites Added in Wave 1 & Wave 2

1. **Security Rules & Encryption**:
   - [`test/core/security/firebase_rules_security_test.dart`](../../test/core/security/firebase_rules_security_test.dart)
   - [`test/core/security/hive_encryption_migration_and_recovery_test.dart`](../../test/core/security/hive_encryption_migration_and_recovery_test.dart)
2. **Auth, Release Safety & Onboarding Gate**:
   - [`test/features/auth/release_safety_characterization_test.dart`](../../test/features/auth/release_safety_characterization_test.dart)
   - [`test/features/auth/auth_and_onboarding_gate_characterization_test.dart`](../../test/features/auth/auth_and_onboarding_gate_characterization_test.dart)
3. **Multi-Device Cloud Sync & Outbox Correctness**:
   - [`test/features/sync/sync_correctness_wave1_test.dart`](../../test/features/sync/sync_correctness_wave1_test.dart)
   - [`test/features/sync/sync_pipeline_test.dart`](../../test/features/sync/sync_pipeline_test.dart)
4. **Backup, Restore, Safety Snapshots & Account Deletion**:
   - [`test/features/settings/backup_restore_characterization_test.dart`](../../test/features/settings/backup_restore_characterization_test.dart)
   - [`test/features/settings/remote_data_purger_test.dart`](../../test/features/settings/remote_data_purger_test.dart)
5. **Workout Metrics, Analytics Math & Predictions**:
   - [`test/features/analytics/analytics_math_and_program_generation_test.dart`](../../test/features/analytics/analytics_math_and_program_generation_test.dart)
6. **Nutrition Scaling, Calorie Math & Daily Summaries**:
   - [`test/features/nutrition/nutrition_math_characterization_test.dart`](../../test/features/nutrition/nutrition_math_characterization_test.dart)
7. **End-to-End Multi-Feature Journeys (`Wave 2.2`)**:
   - [`integration_test/wave2_e2e_journeys_test.dart`](../../integration_test/wave2_e2e_journeys_test.dart)
   - [`test/integration/wave2_e2e_journeys_test.dart`](../../test/integration/wave2_e2e_journeys_test.dart)
8. **Direction 4 Design-System Light/Dark Component Goldens (`Wave 2.3`)**:
   - [`test/design_system/design_system_goldens_test.dart`](../../test/design_system/design_system_goldens_test.dart)

