# Audit Track K — Documentation & Client Handover Readiness

| ID | Severity | Finding | Measured Evidence | Prescribed Fix | Effort | Wave |
| :--- | :---: | :--- | :--- | :--- | :---: | :---: |
| **DOC-01** | **P1 HIGH** | Legacy docs contradict current security architecture | `docs/development/GEMINI_API_SETUP_COMPLETE.md`, `GEMINI_INTEGRATION_COMPLETE.md`, `OPTION_ONE_COMPLETE.md`, `FREE_AI_PLATFORMS_GUIDE.md`, and root `SECURITY_FIX_*.md` instruct developers to put raw API keys in `.env` for production rather than using the authenticated backend proxy (`AI_PROXY_URL`). | Archive or update outdated setup docs in Wave 7.3 (ASK before deleting any obsolete files) and replace with a single canonical `docs/setup/ENVIRONMENT_AND_FLAVORS.md`. | 3h | W7.3 |
| **DOC-02** | **P1 MEDIUM** | Missing operational runbooks and API specs | No runbooks exist for key rotation, Firebase rules deployment, incident response (flipping kill switches), backup/restore format specification, or new-developer Day-1 onboarding. | Author `docs/runbooks/` (deploy, key rotation, incident rollback, backup/restore) and `docs/CLIENT_PACK/` in Wave 7.3–7.4. | 6h | W7.3 / W7.4 |
