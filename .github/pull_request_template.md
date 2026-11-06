## Summary
<!-- Describe what changed and why, linking the relevant Wave / ADR / issue ID. -->

## Wave / Track Reference
- **Wave**: `feat/prod-wave-___`
- **Finding / ADR IDs**: `___`

## Evidence & Verification Checklist
- [ ] **No Secrets**: `gitleaks` / `scripts/pre-commit-secrets-check.sh --ci-verify` passes with 0 findings; no keys in source, tests, or build artifacts.
- [ ] **Static Analysis**: `flutter analyze --no-fatal-infos` exits `0` (0 errors, 0 warnings).
- [ ] **Tests & Coverage Gate**: `flutter test --no-pub --coverage` passes 100% and `python3 scripts/check_coverage.py coverage/lcov.info` passes all layer thresholds (`domain`, `data`, `core`, `overall`).
- [ ] **Characterization First**: Any business-logic or data-layer change was preceded by characterization tests passing on the prior behavior.
- [ ] **Data Safety**: No destructive storage format change without a tested migration and safety snapshot; data remains strictly scoped per `userId`.
- [ ] **Builds Verified**:
  - [ ] `flutter build web`
  - [ ] `flutter build apk --debug`
- [ ] **UI / Design System** (if applicable): Uses Direction 4 (`AppThemeTokens`) components, supports Light & Dark mode, respects reduced motion, and keeps golden tests green.

## Screenshots / Recordings (Required for UI Changes)
| Before | After |
| :--- | :--- |
| <!-- attach before --> | <!-- attach after --> |

